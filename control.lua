--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: X-12 Nuclear Locomotive
 * File: control.lua
 * Description: Runtime operation script for replacing locomotives and updating fuel.
 * Functions:
 *  => On Train Created (any built, destroyed, coupled, or uncoupled rolling stock)
 *  ===> Check if each x-12-nuclear-locomotive has an adjacent x12-nuclear-tender.
 *  =====> Replace it with x-12-nuclear-locomotive-powered, add to global list of X12 pairs, reconnect train, etc.
 *  ===> Check if train contains existing X12 locomotive-tender pairs, and if those pairs are intact.
 *  =====> Replace any partial pairs with normal locomotives, remove from global list, reconnect trains
 *
 *  => On Mod Settings Changed (disabled flag changes to true)
 *  ===> Read through entire global list of MU pairs and replace them with normal locomotives
 
 *  => On Nth Tick (once per ~10 seconds)
 *  ===> Read through entire global list of MU pairs.  
 *  ===> Add steam to tenders 
 *
 --]]

replaceCarriage = require("__Robot256Lib__/script/carriage_replacement").replaceCarriage
blueprintLib = require("__Robot256Lib__/script/blueprint_replacement")

require("script.processTrainX12")
require("script.addPairToGlobal")
require("script.purgeLocoFromPairs")


local settings_debug = settings.global["x12-nuclear-locomotive-debug"].value
local settings_nth_tick = settings.global["x12-nuclear-locomotive-on_nth_tick"].value
local current_nth_tick = settings_nth_tick

local train_queue_semaphore = false

-- steam per tick
local steam_per_second = 60


------------------------- GLOBAL TABLE INITIALIZATION ---------------------------------------

-- Set up the mapping between normal and powered locomotives
-- Extract from the game prototypes list what MU locomotives are enabled
local function InitEntityMaps()

	global.x12_upgrade_pairs = {}
	global.x12_downgrade_pairs = {}	
	global.x12_tender_pairs = {}

	
	global.x12_upgrade_pairs["x12-nuclear-locomotive"] = "x12-nuclear-locomotive-powered"
	global.x12_downgrade_pairs["x12-nuclear-locomotive-powered"] = "x12-nuclear-locomotive"
	global.x12_tender_pairs["x12-nuclear-locomotive"] = "x12-nuclear-tender"
	
	-- Compatibility with Multiple Unit Train Control:
	--   Only the powered loco will have an MU version.
	--   MU versions that lose their tenders will be made non-MU.
	global.x12_downgrade_pairs["x12-nuclear-locomotive-powered-mu"] = "x12-nuclear-locomotive"
	
	
end


------------------------- LOCOMOTIVE REPLACEMENT CODE -------------------------------

-- Process replacement order immediately
--   Need to preserve x12_pairs across replacement
local function ProcessReplacement(r)
	if r[1] and r[1].valid then
		-- Replace the locomotive
		if settings_debug == "info" then
			game.print({"debug-message.x12-replacement-message",r[1].name,r[1].backer_name,r[2]})
		end
		local errorString = {"debug-message.x12-replacement-failed",r[1].name,r[1].backer_name,r[1].position.x,r[1].position.y}
		
		local newLoco = replaceCarriage(r[1], r[2])
		-- Find which x12_pair the old one was in and put the new one instead
		for _,p in pairs(global.x12_pairs) do
			if p[1] == r[1] then
				p[1] = newLoco
				break
			elseif p[2] == r[1] then
				p[2] = newLoco
				break
			end
		end
		-- Make sure it was actually replaced, show error message if not.
		if not newLoco and (settings_debug == "info" or settings_debug == "error") then
			game.print(errorString)
		end
	end
end


-- Read train state and determine if it is safe to replace
local function isTrainStopped(train)
	local state = train.state
	return train.speed==0 and (
	            (state == defines.train_state.wait_station) or 
	            (state == defines.train_state.wait_signal) or 
	            (state == defines.train_state.no_path) or 
	            (state == defines.train_state.no_schedule) or 
	            (state == defines.train_state.manual_control)
			)
end


------------
-- Process one valid train. Do replacemnts immediately.
local function ProcessTrain(t)
	local found_pairs = {}
	local upgrade_locos = {}
	local unpaired_locos = {}
	
	found_pairs,upgrade_locos,unpaired_locos = processTrainX12(t)
	
	-- Remove pairs involving the now-unpaired locos.
	for _,entry in pairs(unpaired_locos) do
		purgeLocoFromPairs(entry)
	end
	
	-- Add pairs to the pair lists.  (pairs will need to be updated when the replacements are made)
	for _,entry in pairs(found_pairs) do
		addPairToGlobal(entry)
	end
	
	-- Replace locomotives immediately
	for _,entry in pairs(upgrade_locos) do
		ProcessReplacement(entry)
	end
end


----------------------------------------------
------ EVENT HANDLING ---

--== ON_TRAIN_CHANGED_STATE EVENT ==--
-- Fires when train pathfinder changes state, executes if the train is in the update list.
-- Use this to replace locomotives at a safe (stopped) time.
local function OnTrainChangedState(event)	
	local id = event.train.id
			
	--game.print("Train ".. id .. " In OnTrainChangedState!")
	-- Event contains train, old_train_state
	-- If this train is queued for replacement, check state and maybe process now
	if global.x12_moving_trains[id] then
		local t = event.train
		-- We are waitng to process it, check everything!
		if t and t.valid then
			-- Check if this train is in a safe state
			if isTrainStopped(t) then
				-- Immediately replace these locomotives
				--game.print("Train " .. id .. " being processed.")
				if train_queue_semaphore == false then
					train_queue_semaphore = true
					ProcessTrain(t)
					global.x12_moving_trains[id] = nil
					train_queue_semaphore = false
				elseif (settings_debug == "info" or settings_debug == "error") then
					game.print("(X12) OnChange Train " .. id .. " event ignored because semaphore is occupied (this is weird!)")
				end
			end
		end
	end
	if not next(global.x12_moving_trains) then
		script.on_event(defines.events.on_train_changed_state, nil)
	end
	
	--game.print("Train " .. id .. " Exiting OnTrainChangedState")
end


-------------
-- Enables the on_train_changed_state event according to current variables
local function StartTrainWatcher()
	if global.x12_moving_trains and next(global.x12_moving_trains) then
		-- Set up the action to process train after it comes to a stop
		script.on_event(defines.events.on_train_changed_state, OnTrainChangedState)
	else
		script.on_event(defines.events.on_train_changed_state, nil)
	end
end


----------
-- Try to process newly created trains immediately
local function ProcessTrainQueue()
	-- Check if we are already processing a train.
	-- Don't execute this again if it was triggered by an intermediate on_train_created event.
	if train_queue_semaphore==false then
		train_queue_semaphore = true
		
		if global.x12_created_trains then
			--game.print("ProcessTrainQueue has a train in the queue")
			-- Keep looping until we discard all the invalid intermediate trains
			local moving_trains = {}
			while next(global.x12_created_trains) do
				local t = table.remove(global.x12_created_trains,1)
				if t and t.valid then
					-- Check if this train is in a safe state
					if isTrainStopped(t) then
						-- Immediately replace these locomotives
						--game.print("Train " .. id .. " being processed.")
						ProcessTrain(t)
						-- Don't process any more trains this tick
						break
					else
						-- Flag this train to be processed on a ChangedState event
						global.x12_moving_trains[t.id] = t
						--game.print("Train " .. id .. " still moving.")
					end
				end
			end
		end
		
		train_queue_semaphore = false
		return true
	else
		--game.print("Queue already being processed")
		return false
	end
end


----------
-- Try to generate steam in the tender by consuming nuclear fuel
function GenerateSteam(p)
  -- Just add steam every tick for now
  local burner = p[1].burner
  local tender = p[2]
  -- Purge non-steam liquids
  local contents = tender.get_fluid_contents()
  if table_size(contents) > 0 and not contents["steam"] then
    tender.clear_fluid_inside()  -- Remove non-steam liquids
  else
    -- Remove cold steam (no other way to see temperature contents???
    tender.remove_fluid{name="steam", 
                        amount=tender.prototype.fluid_capacity, 
                        maximum_temperature=499.9}
  end
  
  
  -- Add hot steam
  local steamWanted = steam_per_second*current_nth_tick/60
  local steamAdded = tender.insert_fluid{name="steam",amount=steamWanted,temperature=500}
  local heatWanted = steamAdded*97000 -- Joules per unit steam
  
  -- Check if there is existing fuel burning
  if burner.currently_burning then
    -- Remove burner fuel
    local heatUsed = math.min(burner.remaining_burning_fuel, heatWanted)
    burner.remaining_burning_fuel = burner.remaining_burning_fuel - heatUsed
    heatWanted = heatWanted - heatUsed
    if burner.remaining_burning_fuel == 0 then
      -- See if we need to insert burnt fuel
      if burner.currently_burning.burnt_result then
        local burnt_inserted = burner.burnt_result_inventory.insert{name=burner.currently_burning.burnt_result.name}
        if burnt_inserted > 0 then
          -- We got the burnt cell out, now nothing is burning
          burner.currently_burning = nil
        end
      else
        -- No burnt result, we are now burning nothing
        burner.currently_burning = nil
      end
    end
  end
  
  -- Check if we still need more fuel
  if heatWanted > 0 then
    -- Now see if we can insert new fuel from inventory
    name,count = next(burner.inventory.get_contents())
    if name then
      fuel_item = game.item_prototypes[name]  -- get fuel item prototype
      -- Check that we will be able to insert the burnt result when it is done, or that there is no burnt result
      if not (fuel_item.burnt_result and not burner.burnt_result_inventory.can_insert{name=fuel_item.burnt_result.name}) then
        burner.inventory.remove{name=name, count=1}  -- remove one fuel
        burner.currently_burning = fuel_item
        burner.remaining_burning_fuel = fuel_item.fuel_value - heatWanted
        heatWanted = 0
      end
    end
  end
  
  -- Check if we came up short energy-wise
  if heatWanted > 0 then
    -- Remove steam that we couldn't produce
    local excessSteam = heatWanted/97000
    tender.remove_fluid{name="steam", amount=excessSteam}
  end
  
end


--== ON_NTH_TICK EVENT ==--
-- Process steam generation and standby heat consumption
local function OnNthTick(event)
  if global.x12_pairs and next(global.x12_pairs) then
    local n = #global.x12_pairs
		local done = false
		for i=1,n do
      entry = global.x12_pairs[i]
      if (entry[1] and entry[2] and entry[1].valid and entry[2].valid) then
			  -- Add steam only if train is stopped
        if entry[1].train.speed==0 then
          GenerateSteam(entry)
        end
      else
				-- This pair has one or more invalid locomotives, or they don't have burners at all, remove it from the list
				global.x12_pairs[i] = nil
			end
    end
    local j=0
		for i=1,n do  -- Condense the list
			if global.x12_pairs[i] ~= nil then
				j = j+1
				global.x12_pairs[j] = global.x12_pairs[i]
			end
		end
		for i=j+1,n do
			global.x12_pairs[i] = nil
		end
	end
end


--== ONTICK EVENT ==--
-- Process items queued up by other actions
-- Only one action allowed per tick
local function OnTick(event)
	
	-- Process created trains one per tick
	ProcessTrainQueue()
	-- Enable state change handler if we found moving trains
	StartTrainWatcher()
	
	if (not next(global.x12_created_trains)) then
		-- All on_tick queues are empty, unsubscribe from OnTick to save UPS
		--game.print("Turning off OnTick")
		script.on_event(defines.events.on_tick, nil)
	end
  
end


--== ON_TRAIN_CREATED EVENT ==--
-- Record every new train in global queue, so we can process them one at a time.
--   Many of these events will be triggered by our own replacements, and those
--   "intermediate" trains will be invalid by the time we pull them from the queue.
--   This is the desired behavior. 
local function OnTrainCreated(event)
	-- Event contains train, old_train_id_1, old_train_id_2
	local id = event.train.id
	--game.print("Train "..id.." In OnTrainCreated!")

	-- Add this train to the train processing list, wait for it to stop
	table.insert(global.x12_created_trains, event.train)
	
	--game.print("Train " .. event.train.id .. " queued.")
	
	-- Try to process it immediately. Will exit if we are already processing stuff
	script.on_event(defines.events.on_tick, OnTick)
	--game.print("Train "..id.." Exiting OnTrainCreated!")
end


--== ON_PLAYER_CONFIGURED_BLUEPRINT EVENT ==--
-- ID 70, fires when you select a blueprint to place
--== ON_PLAYER_SETUP_BLUEPRINT EVENT ==--
-- ID 68, fires when you select an area to make a blueprint or copy
local function OnPlayerSetupBlueprint(event)
	blueprintLib.mapBlueprint(event,global.x12_downgrade_pairs)
end


--== ON_PLAYER_PIPETTE ==--
-- Fires when player presses 'Q'.  We need to sneakily grab the correct item from inventory if it exists,
--  or sneakily give the correct item in cheat mode.
local function OnPlayerPipette(event)
	blueprintLib.mapPipette(event,global.x12_downgrade_pairs)
end

-------------
-- Enables the on_nth_tick event according to the mod setting value
--   Safe to run inside on_load().
local function StartSteamUpdates()

	if settings_nth_tick == 0 or settings_mode == "disabled" then
		-- Value of zero disables steam creation
		--game.print("Disabling Nth Tick due to setting")
		script.on_nth_tick(nil)
	else
		-- See if we stored a longer update rate in global
		if global.current_nth_tick and global.current_nth_tick > settings_nth_tick then
			current_nth_tick = global.current_nth_tick
		else
			current_nth_tick = settings_nth_tick
		end
		-- Start the event
		--game.print("Enabling Nth Tick with setting " .. settings_nth_tick)
		script.on_nth_tick(nil)
		script.on_nth_tick(current_nth_tick, OnNthTick)
	end
end


-----------
-- Queues all existing trains for updating with new settings
local function QueueAllTrains()
	for _, surface in pairs(game.surfaces) do
		local trains = surface.get_trains()
		for _,train in pairs(trains) do
			-- Pretend this train was just created. Don't worry how long it takes.
			table.insert(global.x12_created_trains, train)
			--game.print("Train " .. train.id .. " queued for scrub.")
		end
	end
	if next(global.x12_created_trains) then
		script.on_event(defines.events.on_tick, OnTick)
	end
end


---- Bootstrap ----
do
local function init_events()

	-- Subscribe to Blueprint activity
	script.on_event({defines.events.on_player_setup_blueprint,defines.events.on_player_configured_blueprint}, OnPlayerSetupBlueprint)
	script.on_event(defines.events.on_player_pipette, OnPlayerPipette)
	
	-- Subscribe to On_Nth_Tick according to saved global and settings
	StartSteamUpdates()
	
  -- Subscribe to On_Train_Changed_state according to global queue
	StartTrainWatcher()
	
	-- Subscribe to On_Train_Created according to mod enabled setting
	if settings_mode ~= "disabled" then
		script.on_event(defines.events.on_train_created, OnTrainCreated)
	end
	
	-- Set conditional OnTick event handler correctly on load based on global queues, so we can sync with a multiplayer game.
	if (global.x12_created_trains and next(global.x12_created_trains)) then
		script.on_event(defines.events.on_tick, OnTick)
	end
	
end

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
	if event.setting == "x12-nuclear-locomotive-debug" then
		settings_debug = settings.global["x12-nuclear-locomotive-debug"].value
	elseif event.setting == "x12-nuclear-locomotive-on_nth_tick" then
		-- When interval changes, clear the saved update rate and start over
		settings_nth_tick = settings.global["x12-nuclear-locomotive-on_nth_tick"].value
		global.current_nth_tick = nil
		StartSteamUpdates()
	end
	
end)

----------
-- When game is loaded (from save or server), only set up events to match previous state
script.on_load(function()
	init_events()
end)

-- When game is created, initialize globals and events
script.on_init(function()
	--game.print("In on_init!")
	global.x12_created_trains = {}
	global.x12_moving_trains = {}
	global.x12_pairs = {}
	InitEntityMaps()
	init_events()
	
end)

-- When mod list/versions change, reinitialize globals and scrub existing trains
script.on_configuration_changed(function(data)
	--game.print("In on_configuration_changed!")
	global.x12_created_trains = global.x12_created_trains or {}
	global.x12_moving_trains = global.x12_moving_trains or {}
	global.x12_pairs = global.x12_pairs or {}
	InitEntityMaps()
	-- On config change, scrub the list of trains
	QueueAllTrains()
	init_events()
	
end)

end
