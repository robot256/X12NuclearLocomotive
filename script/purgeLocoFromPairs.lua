--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: X-12 Nuclear Locomotive
 * File: purgeLocoFromPairs.lua
 * Description: Removes references to downgraded locos from the X12 pair list.
--]]


function purgeLocoFromPairs(loco)
	-- Purge pairs with these same locomotives before adding a new pair with them
	-- Safe remove-while-iterating algorithm from 
	-- https://stackoverflow.com/questions/12394841/safely-remove-items-from-an-array-table-while-iterating
	local n = #global.x12_pairs
	local done = false
	for i=1,n do
		entry = global.x12_pairs[i]
		if (entry[1] == loco or entry[2] == loco) then
			-- This old pair has the given loco, so it is invalid
			global.x12_pairs[i] = nil
		end
	end
	local j=0
	for i=1,n do
		if global.x12_pairs[i] ~= nil then
			j = j+1
			global.x12_pairs[j] = global.x12_pairs[i]
		end
	end
	for i=j+1,n do
		global.x12_pairs[i] = nil
	end

end

return purgeLocoFromPairs