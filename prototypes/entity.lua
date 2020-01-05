--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: X-12 Nuclear Locomotive
 * File: entity.lua
 * Description: Adds prototypes for x12-nuclear-locomotive, x12-nuclear-locomotive-powered, and x12-nuclear-tender.
 --]]
 
 
local standard_train_wheels = data.raw["locomotive"]["locomotive"].wheels

-- Copied from base game:
-- {
  -- priority = "very-low",
  -- width = 115,
  -- height = 115,
  -- direction_count = 256,
  -- filenames =
  -- {
    -- "__base__/graphics/entity/diesel-locomotive/train-wheels-01.png",
    -- "__base__/graphics/entity/diesel-locomotive/train-wheels-02.png"
  -- },
  -- line_length = 8,
  -- lines_per_file = 16,
  -- hr_version =
  -- {
    -- priority = "very-low",
    -- width = 229,
    -- height = 227,
    -- direction_count = 256,
    -- filenames =
    -- {
      -- "__base__/graphics/entity/diesel-locomotive/hr-train-wheels-1.png",
      -- "__base__/graphics/entity/diesel-locomotive/hr-train-wheels-2.png",
      -- "__base__/graphics/entity/diesel-locomotive/hr-train-wheels-3.png",
      -- "__base__/graphics/entity/diesel-locomotive/hr-train-wheels-4.png",
      -- "__base__/graphics/entity/diesel-locomotive/hr-train-wheels-5.png",
      -- "__base__/graphics/entity/diesel-locomotive/hr-train-wheels-6.png",
      -- "__base__/graphics/entity/diesel-locomotive/hr-train-wheels-7.png",
      -- "__base__/graphics/entity/diesel-locomotive/hr-train-wheels-8.png"
    -- },
    -- line_length = 4,
    -- lines_per_file = 8,
    -- --shift = {0.015625, -0.453125}, original shifting from spritesheeter (likely needs doubling or halving)
    -- scale = 0.5
  -- }
-- }



local x12_train_wheels =
{
  priority = "very-low",
  width = 115,
  height = 115,
  direction_count = 128,
  filenames =
  {
    "__X12NuclearLocomotive__/graphics/entities/x12_nuclear_locomotive/Combined_Trucks.png"
  },
  line_length = 4,
  lines_per_file = 32
}


function rolling_stock_back_light(length)
  if not length then length = 6 end
  return
  {
    {
      minimum_darkness = 0.3,
      color = { r = 1, g = 0.1, b = 0.05, a = 0 },
      shift = {-0.6, ((length+1)/2)},
      size = 2,
      intensity = 0.6,
      add_perspective = true
    },
    {
      minimum_darkness = 0.3,
      color = { r = 1, g = 0.1, b = 0.05, a = 0 },
      shift = {0.6, ((length+1)/2)},
      size = 2,
      intensity = 0.6,
      add_perspective = true
    }
  }
end

function rolling_stock_stand_by_light(length)
  if not length then length = 6 end
  return
  {
    {
      minimum_darkness = 0.3,
      color = { r = 0.05, g = 0.2, b = 1, a = 0 },
      shift = {-0.6, -((length+1)/2)},
      size = 2,
      intensity = 0.5,
      add_perspective = true
    },
    {
      minimum_darkness = 0.3,
      color = { r = 0.05, g = 0.2, b = 1, a = 0 },
      shift = {0.6, -((length+1)/2)},
      size = 2,
      intensity = 0.5,
      add_perspective = true
    }
  }
end




local base_loco = data.raw["locomotive"]["locomotive"]

local x12_powered = optera_lib.copy_prototype(base_loco, "x12-nuclear-locomotive-powered")
x12_powered.icon = "__TrainOverhaul__/graphics/icons/nuclear-locomotive.png"
x12_powered.minable = {mining_time = 1, result = "x12-nuclear-locomotive"}
x12_powered.max_health = 3000
x12_powered.weight = 9000
x12_powered.max_speed = 1.4 --302.4km/h
--x12_powered.max_speed = 1.2 --259.2km/h
x12_powered.max_power = "5000kW"
x12_powered.reversing_power_modifier = 1
x12_powered.braking_force = 40
x12_powered.friction_force = 0.50
x12_powered.air_resistance = 0.015

x12_powered.burner =
    {
      fuel_category = "nuclear",
      effectivity = 0.85,
      fuel_inventory_size = 1,
      burnt_inventory_size = 1,
      smoke =
      {
        {
          name = "turbine-smoke",
          deviation = {0.3, 0.3},
          frequency = 60,
          position = {0.2, 5.7},
          starting_frame = 0,
          starting_frame_deviation = 60,
          height = 2,
          height_deviation = 0.5,
          starting_vertical_speed = 0.15,
          starting_vertical_speed_deviation = 0.1
        }
      }
    }
  

x12_powered.stop_trigger =
    {
      -- left side
      {
        type = "create-trivial-smoke",
        repeat_count = 125,
        smoke_name = "smoke-train-stop",
        initial_height = 0,
        -- smoke goes to the left
        speed = {-0.03, 0},
        speed_multiplier = 0.75,
        speed_multiplier_deviation = 1.1,
        offset_deviation = {{-0.75, -5.7}, {-0.3, -1.7}}
      },
    {
        type = "create-trivial-smoke",
        repeat_count = 125,
        smoke_name = "smoke-train-stop",
        initial_height = 0,
        -- smoke goes to the left
        speed = {-0.03, 0},
        speed_multiplier = 0.75,
        speed_multiplier_deviation = 1.1,
        offset_deviation = {{-0.75, 1.7}, {-0.3, 5.7}}
      },
      -- right side
      {
        type = "create-trivial-smoke",
        repeat_count = 125,
        smoke_name = "smoke-train-stop",
        initial_height = 0,
        -- smoke goes to the right
        speed = {0.03, 0},
        speed_multiplier = 0.75,
        speed_multiplier_deviation = 1.1,
        offset_deviation = {{0.3, -5.7}, {0.75, -1.7}}
      },
    {
        type = "create-trivial-smoke",
        repeat_count = 125,
        smoke_name = "smoke-train-stop",
        initial_height = 0,
        -- smoke goes to the right
        speed = {0.03, 0},
        speed_multiplier = 0.75,
        speed_multiplier_deviation = 1.1,
        offset_deviation = {{0.3,1.7}, {0.75, 5.7}}
      },
      {
        type = "play-sound",
        sound =
        {
          {
            filename = "__base__/sound/train-breaks.ogg",
            volume = 0.6
          }
        }
      }
    }


x12_powered.working_sound.sound.filename = "__base__/sound/idle1.ogg"
x12_powered.working_sound.sound.volume = 1.3
x12_powered.working_sound.idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 1 }


-- Fill these in once we have graphics that make sense.
x12_powered.color = nil


x12_powered.front_light =
    {
      {
        type = "oriented",
        minimum_darkness = 0.3,
        picture =
        {
          filename = "__core__/graphics/light-cone.png",
          priority = "extra-high",
          flags = { "light" },
          scale = 2,
          width = 200,
          height = 200
        },
        shift = {-0.8, -25},
        size = 3,
        intensity = 0.8,
        color = {r = 1.0, g = 0.9, b = 0.9}
      },
      {
        type = "oriented",
        minimum_darkness = 0.3,
        picture =
        {
          filename = "__core__/graphics/light-cone.png",
          priority = "extra-high",
          flags = { "light" },
          scale = 2,
          width = 200,
          height = 200
        },
        shift = {0.8, -25},
        size = 3  ,
        intensity = 0.8,
        color = {r = 1.0, g = 0.9, b = 0.9}
      }
    }
x12_powered.back_light = rolling_stock_back_light(13)
x12_powered.stand_by_light = rolling_stock_stand_by_light(13)


-- Default values for 6-long locomotive
--x12_powered.connection_distance = 3
--x12_powered.joint_distance = 4
--x12_powered.collision_box = {{-0.6, -2.6}, {0.6, 2.6}}
--x12_powered.selection_box = {{-1, -3}, {1, 3}}
--x12_powered.drawing_box = {{-1, -4}, {1, 3}}
--x12_powered.drive_over_tie_trigger = drive_over_tie()
--x12_powered.tie_distance = 50

-- New values for 13-long locomotive
x12_powered.connection_distance = 3
x12_powered.joint_distance = 11
x12_powered.collision_box = {{-0.6, -6.1}, {0.6, 6.1}}
x12_powered.selection_box = {{-1, -6.5}, {1, 6.5}}
x12_powered.drawing_box = {{-1, -7.5}, {1, 6.5}}

-- Switch these to use new truck sprites
--x12_powered.wheels = x12_train_wheels
x12_powered.wheels = standard_train_wheels
    
x12_powered.pictures =
    {
      layers =
      {
        {
          slice = 4,
          priority = "very-low",
          width = 476,
          height = 460,
          direction_count = 128,
          allow_low_quality_rotation = true,
          filenames =
          {
            "__X12NuclearLocomotive__/graphics/entities/x12_nuclear_locomotive/Locomotive_01.png",
            "__X12NuclearLocomotive__/graphics/entities/x12_nuclear_locomotive/Locomotive_02.png",
            "__X12NuclearLocomotive__/graphics/entities/x12_nuclear_locomotive/Locomotive_03.png",
            "__X12NuclearLocomotive__/graphics/entities/x12_nuclear_locomotive/Locomotive_04.png"
          },
          line_length = 4,
          lines_per_file = 8,
          shift = {0.0, -.25},
          scale = 0.95
        }
        
        
      }
    }
  
  
  
x12_powered.minimap_representation =
    {
      filename = "__X12NuclearLocomotive__/graphics/entities/x12_nuclear_locomotive/x12-locomotive-minimap-representation.png",
      flags = {"icon"},
      size = {20, 88},
      scale = 0.5
    }
  
x12_powered.selected_minimap_representation =
    {
      filename = "__X12NuclearLocomotive__/graphics/entities/x12_nuclear_locomotive/x12-locomotive-selected-minimap-representation.png",
      flags = {"icon"},
      size = {20, 88},
      scale = 0.5
    }



---------
-- Now modify it for the unpowered (default) version
local x12_unpowered = optera_lib.copy_prototype(x12_powered, "x12-nuclear-locomotive")

x12_unpowered.max_power = "1kW"
x12_unpowered.working_sound = nil
x12_unpowered.minable = {mining_time = 1, result = "x12-nuclear-locomotive"}
x12_unpowered.burner.smoke = nil
x12_unpowered.stop_trigger = nil


----------
-- Create the Nuclear Tender
local base_fluid_wagon = data.raw["fluid-wagon"]["fluid-wagon"]

local x12_nuclear_tender = optera_lib.copy_prototype(base_fluid_wagon, "x12-nuclear-tender")
x12_nuclear_tender.icon = "__TrainOverhaul__/graphics/icons/heavy-fluid-wagon.png"
x12_nuclear_tender.color = {r = 1, g = 1, b = 1, a = 0.7}
x12_nuclear_tender.max_health = 1500
x12_nuclear_tender.weight = 4000
x12_nuclear_tender.max_speed = 1.4
x12_nuclear_tender.braking_force = 10
x12_nuclear_tender.capacity = 10000
--x12_nuclear_tender.connection_distance = 5

x12_nuclear_tender.stop_trigger =
    {
      -- left side
      {
        type = "create-trivial-smoke",
        repeat_count = 125,
        smoke_name = "smoke-train-stop",
        initial_height = 0,
        -- smoke goes to the left
        speed = {-0.03, 0},
        speed_multiplier = 0.75,
        speed_multiplier_deviation = 1.1,
        offset_deviation = {{-0.75, -2.7}, {-0.3, 2.7}}
      },
      -- right side
      {
        type = "create-trivial-smoke",
        repeat_count = 125,
        smoke_name = "smoke-train-stop",
        initial_height = 0,
        -- smoke goes to the right
        speed = {0.03, 0},
        speed_multiplier = 0.75,
        speed_multiplier_deviation = 1.1,
        offset_deviation = {{0.3, -2.7}, {0.75, 2.7}}
      }
  }
  
x12_nuclear_tender.pictures =
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
            "__X12NuclearLocomotive__/graphics/entities/x12_nuclear_tender/Tender_01.png",
            "__X12NuclearLocomotive__/graphics/entities/x12_nuclear_tender/Tender_02.png",
            "__X12NuclearLocomotive__/graphics/entities/x12_nuclear_tender/Tender_03.png",
            "__X12NuclearLocomotive__/graphics/entities/x12_nuclear_tender/Tender_04.png"
          },
          line_length = 4,
          lines_per_file = 8,
          shift = {0.0, -1.125},
          scale = 0.95
        }
      }
    }
  
data:extend({
  x12_powered,
  x12_unpowered,
  x12_nuclear_tender
})