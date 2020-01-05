--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: X-12 Nuclear Locomotive
 * File: processTrainX12.lua
 * Description: Reads a train and locates locomotives to replace based on whether they have adjacent tenders.
 *    Upgraded pairs must have a tender directly behind the locomotive.
 *    Upgraded locomotives that are found with a tender will be downgraded.
--]]


function processTrainX12(t)

	local front_movers = t.locomotives["front_movers"]
	local back_movers = t.locomotives["back_movers"]
	local carriages = t.carriages
	
	local std_name = "x12-nuclear-locomotive"
	local pwr_name = "x12-nuclear-locomotive-powered"
	local tnd_name = "x12-nuclear-tender"
	
	-- We can convert locos only if there is an *unpaired tender* directly behind it.
	
	-- We can convert locos paired anywhere in the train
	-- Don't bother mapping the train, just see if each loco in front_movers has a partner in back_movers
	-- Start with trying to map existing MUs to each other. If that doesn't work, we have to upgrade
	local found_pairs = {}
	local upgrade_locos = {}
	local unpaired_locos = {}
	
	-- For every locomotive in the train, check if it is a x12-locomotive
	-- Start with front-facing locos
	for _,loco in pairs(front_movers) do
		local loco_done = false
		
		if global.x12_downgrade_pairs[loco.name] then
			local pwr_name = loco.name
			local std_name = global.x12_downgrade_pairs[pwr_name]
			local tnd_name = global.x12_tender_pairs[std_name]
			
			-- Found a Powered X12 pointing Front
			-- Find its index in the train
			local loco_index = nil
			for i,loco_temp in pairs(carriages) do
				if loco == loco_temp then
					loco_index = i
					break
				end
			end
			
			--game.print("Found Powered Loco facing Front at index " .. loco_index)
			
			-- Look for its tender immediately behind
			if carriages[loco_index+1] and carriages[loco_index+1].valid then
				local tender = carriages[loco_index+1]
				if tender.name == tnd_name then
					-- Found a tender!
					-- Potential twin, make sure it's not in a pair already
					local tender_free = true
					for _,this_pair in pairs(found_pairs) do
						if this_pair[2] == tender then  -- (tender is always member of a pair)
							tender_free = false
							break
						end
					end
					if tender_free then
						-- Found an tender, they are already a pair
						table.insert(found_pairs, {loco,tender} )
						loco_done = true
					end
				else
					--game.print("Adjacent wagon is not a tender.")
				end
			else
				--game.print("No wagon is behind the locomotive.")
			end
			if not loco_done then
				-- Didn't find a tender, have to downgrade this one :(
				table.insert(upgrade_locos,{loco,std_name})
				table.insert(unpaired_locos,loco)
			end
			
		elseif global.x12_upgrade_pairs[loco.name] then
			local std_name = loco.name
			local pwr_name = global.x12_upgrade_pairs[std_name]
			local tnd_name = global.x12_tender_pairs[std_name]
			
			-- Found an Unpowered X12 pointing Front
			-- Find its index in the train
			local loco_index = nil
			for i,loco_temp in pairs(carriages) do
				if loco == loco_temp then
					loco_index = i
					break
				end
			end
			
			--game.print("Found Unpowered Loco facing Front at index " .. loco_index)
			
			-- Look for its tender immediately behind
			if carriages[loco_index+1] and carriages[loco_index+1].valid then
				local tender = carriages[loco_index+1]
				if tender.name == tnd_name then
					-- Found a tender!
					-- Potential twin, make sure it's not in a pair already
					local tender_free = true
					for _,this_pair in pairs(found_pairs) do
						if this_pair[2] == tender then
							tender_free = false
							break
						end
					end
					if tender_free then
						-- Found a free tender, upgrade loco
						table.insert(found_pairs,{loco,tender})
						table.insert(upgrade_locos,{loco,pwr_name})
						loco_done = true
					end
				else
					--game.print("Adjacent wagon is not a tender.")
				end
			else
				--game.print("No wagon is behind the locomotive.")
			end
			
			-- If we didn't find a tender, do nothing to the unpowered loco.
			-- Unmatched tenders don't matter.
		end
	end
	
	-- Repeat for all the locos in back_movers
	for _,loco in pairs(back_movers) do
		local loco_done = false
		
		if global.x12_downgrade_pairs[loco.name] then
			local pwr_name = loco.name
			local std_name = global.x12_downgrade_pairs[pwr_name]
			local tnd_name = global.x12_tender_pairs[std_name]
			
			-- Found a Powered X12 pointing Back
			-- Find its index in the train
			local loco_index = nil
			for i,loco_temp in pairs(carriages) do
				if loco == loco_temp then
					loco_index = i
					break
				end
			end
			
			--game.print("Found Powered Loco facing Back at index " .. loco_index)
			
			-- Look for its tender immediately behind
			if carriages[loco_index-1] and carriages[loco_index-1].valid then
				local tender = carriages[loco_index-1]
				if tender.name == tnd_name then
					-- Found a tender!
					-- Potential twin, make sure it's not in a pair already
					local tender_free = true
					for _,this_pair in pairs(found_pairs) do
						if this_pair[2] == tender then  -- (tender is always 2nd member of a pair)
							tender_free = false
							break
						end
					end
					if tender_free then
						-- Found an tender, they are already a pair
						table.insert(found_pairs, {loco,tender} )
						loco_done = true
					end
				else
					--game.print("Adjacent wagon is not a tender.")
				end
			else
				--game.print("No wagon is behind the locomotive.")
			end
			if not loco_done then
				-- Didn't find a tender, have to downgrade this one :(
				table.insert(upgrade_locos,{loco,std_name})
				table.insert(unpaired_locos,loco)
			end
			
		elseif global.x12_upgrade_pairs[loco.name] then
			local std_name = loco.name
			local pwr_name = global.x12_upgrade_pairs[std_name]
			local tnd_name = global.x12_tender_pairs[std_name]
			
			-- Found an Unpowered X12 pointing Back
			-- Find its index in the train
			local loco_index = nil
			for i,loco_temp in pairs(carriages) do
				if loco == loco_temp then
					loco_index = i
					break
				end
			end
			
			--game.print("Found Unpowered Loco facing Back at index " .. loco_index)
			
			-- Look for its tender immediately behind
			if carriages[loco_index-1] and carriages[loco_index-1].valid then
				local tender = carriages[loco_index-1]
				if tender.name == tnd_name then
					-- Found a tender!
					-- Potential twin, make sure it's not in a pair already
					local tender_free = true
					for _,this_pair in pairs(found_pairs) do
						if this_pair[2] == tender then
							tender_free = false
							break
						end
					end
					if tender_free then
						-- Found a free tender, upgrade loco
						table.insert(found_pairs,{loco,tender})
						table.insert(upgrade_locos,{loco,pwr_name})
						loco_done = true
					end
				else
					--game.print("Adjacent wagon is not a tender.")
				end
			else
				--game.print("No wagon is behind the locomotive.")
			end
			
			-- If we didn't find a tender, do nothing to the unpowered loco.
			-- Unmatched tenders don't matter.
		end
	end
	
	return found_pairs, upgrade_locos, unpaired_locos
end

return processTrainX12

