--[[ Copyright (c) 2018 Optera
 * Part of Train Overhaul
 *
 * See LICENSE.md in the project directory for license information.
--]]



local standard_train_wheels =
{
  priority = "very-low",
  width = 115,
  height = 115,
  direction_count = 256,
  filenames =
  {
    "__base__/graphics/entity/diesel-locomotive/train-wheels-01.png",
    "__base__/graphics/entity/diesel-locomotive/train-wheels-02.png"
  },
  line_length = 8,
  lines_per_file = 16,
  hr_version =
  {
    priority = "very-low",
    width = 229,
    height = 227,
    direction_count = 256,
    filenames =
    {
      "__base__/graphics/entity/diesel-locomotive/hr-train-wheels-1.png",
      "__base__/graphics/entity/diesel-locomotive/hr-train-wheels-2.png",
      "__base__/graphics/entity/diesel-locomotive/hr-train-wheels-3.png",
      "__base__/graphics/entity/diesel-locomotive/hr-train-wheels-4.png",
      "__base__/graphics/entity/diesel-locomotive/hr-train-wheels-5.png",
      "__base__/graphics/entity/diesel-locomotive/hr-train-wheels-6.png",
      "__base__/graphics/entity/diesel-locomotive/hr-train-wheels-7.png",
      "__base__/graphics/entity/diesel-locomotive/hr-train-wheels-8.png"
    },
    line_length = 4,
    lines_per_file = 8,
    --shift = {0.015625, -0.453125}, original shifting from spritesheeter (likely needs doubling or halving)
    scale = 0.5
  }
}

local x12_train_wheels =
{
  priority = "very-low",
  width = 115,
  height = 115,
  direction_count = 128,
  filenames =
  {
    "__X12NuclearLocomotive__/graphics/x12-nuclear-locomotive/Combined_Trucks.png"
  },
  line_length = 4,
  lines_per_file = 32
  
}



local base_loco = data.raw["locomotive"]["locomotive"]

local x12_nuclear_loco = optera_lib.copy_prototype(base_loco, "x12-nuclear-locomotive")
x12_nuclear_loco.icon = "__TrainOverhaul__/graphics/icons/nuclear-locomotive.png"
x12_nuclear_loco.max_health = 3000
x12_nuclear_loco.weight = 9000
x12_nuclear_loco.max_speed = 1.4 --302.4km/h
--x12_nuclear_loco.max_speed = 1.2 --259.2km/h
x12_nuclear_loco.max_power = "5000kW"
x12_nuclear_loco.reversing_power_modifier = 1
x12_nuclear_loco.braking_force = 45
x12_nuclear_loco.friction_force = 0.50
x12_nuclear_loco.air_resistance = 0.015
x12_nuclear_loco.burner.fuel_category = "nuclear"
x12_nuclear_loco.burner.effectivity = 0.85
x12_nuclear_loco.burner.fuel_inventory_size = 1
x12_nuclear_loco.burner.burnt_inventory_size = 1
x12_nuclear_loco.burner.smoke = nil
x12_nuclear_loco.working_sound.sound.filename = "__base__/sound/idle1.ogg"
x12_nuclear_loco.working_sound.sound.volume = 1.3
x12_nuclear_loco.working_sound.idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 1.3 }

x12_nuclear_loco.front_light = nil
x12_nuclear_loco.back_light = nil
x12_nuclear_loco.stand_by_light = nil
x12_nuclear_loco.color = nil



--x12_nuclear_loco.connection_distance = 3
--x12_nuclear_loco.joint_distance = 4
--x12_nuclear_loco.collision_box = {{-0.6, -2.6}, {0.6, 2.6}}
--x12_nuclear_loco.selection_box = {{-1, -3}, {1, 3}}
--x12_nuclear_loco.drawing_box = {{-1, -4}, {1, 3}}
--x12_nuclear_loco.drive_over_tie_trigger = drive_over_tie()
--x12_nuclear_loco.tie_distance = 50

x12_nuclear_loco.connection_distance = 3
x12_nuclear_loco.joint_distance = 11

x12_nuclear_loco.collision_box = {{-0.6, -6.1}, {0.6, 6.1}}
x12_nuclear_loco.selection_box = {{-1, -6.5}, {1, 6.5}}
x12_nuclear_loco.drawing_box = {{-1, -7.5}, {1, 6.5}}

--x12_nuclear_loco.wheels = x12_train_wheels
x12_nuclear_loco.wheels = standard_train_wheels
    
x12_nuclear_loco.pictures =
    {
      layers =
      {
        {
          slice = 4,
          priority = "very-low",
          width = 238,
          height = 230,
          direction_count = 128,
          allow_low_quality_rotation = true,
          filenames =
          {
		  "__X12NuclearLocomotive__/graphics/x12-nuclear-locomotive/Combined_Sheets.png"
            --"__X12NuclearLocomotive__/graphics/x12-nuclear-locomotive/Sheet01.png",
            --"__X12NuclearLocomotive__/graphics/x12-nuclear-locomotive/Sheet02.png",
			--"__X12NuclearLocomotive__/graphics/x12-nuclear-locomotive/Sheet03.png",
			--"__X12NuclearLocomotive__/graphics/x12-nuclear-locomotive/Sheet04.png",
			--"__X12NuclearLocomotive__/graphics/x12-nuclear-locomotive/Sheet05.png",
			--"__X12NuclearLocomotive__/graphics/x12-nuclear-locomotive/Sheet06.png",
			--"__X12NuclearLocomotive__/graphics/x12-nuclear-locomotive/Sheet07.png"
          },
          line_length = 4,
          lines_per_file = 32,
          shift = {0.0, -0.5},
          scale = 1.9
        }
        
        
      }
    }



data:extend({
	x12_nuclear_loco
})

local base_fluid_wagon = data.raw["fluid-wagon"]["fluid-wagon"]

local x12_nuclear_tender = optera_lib.copy_prototype(base_fluid_wagon, "x12-nuclear-tender")
x12_nuclear_tender.icon = "__TrainOverhaul__/graphics/icons/heavy-fluid-wagon.png"
x12_nuclear_tender.color = {r = 0, g = 0.53, b = 0, a = 0.5}
x12_nuclear_tender.max_health = 1500
x12_nuclear_tender.weight = 4000
x12_nuclear_tender.max_speed = 1.4
x12_nuclear_tender.braking_force = 10
x12_nuclear_tender.capacity = 25000
--x12_nuclear_tender.connection_distance = 5

data:extend({
  x12_nuclear_tender
})