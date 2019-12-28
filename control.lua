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

require("util.mapBlueprint")
require("util.saveItemRequestProxy")
require("util.saveBurner")
require("util.saveGrid")
require("util.replaceLocomotive")
require("script.processTrainX12")
require("script.addPairToGlobal")
require("script.purgeLocoFromPairs")


local settings_debug = settings.global["x12-nuclear-locomotive-debug"].value

local train_queue_semaphore = false


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
		
		local newLoco = replaceLocomotive(r[1], r[2])
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
	mapBlueprint(event,global.x12_downgrade_pairs)
end


--== ON_PLAYER_PIPETTE ==--
-- Fires when player presses 'Q'.  We need to sneakily grab the correct item from inventory if it exists,
--  or sneakily give the correct item in cheat mode.
local function OnPlayerPipette(event)
	mapPipette(event,global.x12_downgrade_pairs)
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
	--game.print("in mod_settings_changed!")
	if event.setting == "multiple-unit-train-control-mode" then
		settings_mode = settings.global["multiple-unit-train-control-mode"].value
		-- Scrub existing trains according to new settings
		QueueAllTrains()  -- This will execute some replacements immediately
		if settings_mode == "disabled" then
			-- Clean globals when disabled
			global.x12_pairs = {}
		end
		-- Enable or disable events based on setting state
		init_events()
	
	elseif event.setting == "multiple-unit-train-control-on_nth_tick" then
		-- When interval changes, clear the saved update rate and start over
		settings_nth_tick = settings.global["multiple-unit-train-control-on_nth_tick"].value
		global.current_nth_tick = nil
		StartBalanceUpdates()
	
	elseif event.setting == "multiple-unit-train-control-debug" then
		settings_debug = settings.global["multiple-unit-train-control-debug"].value
		
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
