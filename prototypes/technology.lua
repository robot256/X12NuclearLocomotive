--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: X-12 Nuclear Locomotive
 * File: technology.lua
 * Description: Adds technology prototypes.
 --]]
 
 
data:extend({
  {
    type = "technology",
    name = "x12-nuclear-locomotive",
    icon = "__TrainOverhaul__/graphics/icons/tech-nuclear-locomotive.png",
    icon_size = 64,
    prerequisites = {"improved-trains", "nuclear-power", "production-science-pack"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "x12-nuclear-locomotive"
      },
	  {
        type = "unlock-recipe",
        recipe = "x12-nuclear-tender"
      }
    },
    unit =
    {
      count = 1000,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
      },
      time = 30
    },
    order = "c-g-c"
  },
})