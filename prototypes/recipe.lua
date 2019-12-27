--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: X-12 Nuclear Locomotive
 * File: recipe.lua
 * Description: Adds recipe prototypes.
 --]]


data:extend({
	{
		type = "recipe",
		name = "x12-nuclear-locomotive",
		category = "crafting-with-fluid",
		energy_required = 12,		
		enabled = false,
		ingredients =
		{
			{"locomotive", 1},
			{"steam-turbine", 1},
			{type="fluid", name= "lubricant", amount = 500},
			{"nuclear-reactor", 1},
			{"electric-engine-unit", 12},
		},
		result = "x12-nuclear-locomotive"
	},
	{
		type = "recipe",
		name = "x12-nuclear-tender",
		category = "advanced-crafting",
		energy_required = 8,
		enabled = false,
		ingredients =
		{
			{"fluid-wagon", 1},
			{"heat-exchanger", 2},
			{"heat-pipe", 10},
			{"steel-plate", 10},
		},
		result = "x12-nuclear-tender"
	},
})
