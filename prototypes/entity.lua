--[[ Copyright (c) 2018 Optera
 * Part of Train Overhaul
 *
 * See LICENSE.md in the project directory for license information.
--]]
local base_loco = data.raw["locomotive"]["locomotive"]

local x12_nuclear_loco = optera_lib.copy_prototype(base_loco, "x12-nuclear-locomotive")
x12_nuclear_loco.icon = "__TrainOverhaul__/graphics/icons/nuclear-locomotive.png"
x12_nuclear_loco.color = { r = 0, g = 0.75, b = 0.5, a = 0.5 }
x12_nuclear_loco.max_health = 3000
x12_nuclear_loco.weight = 9000
x12_nuclear_loco.max_speed = 1.4 --302.4km/h
--x12_nuclear_loco.max_speed = 1.2 --259.2km/h
x12_nuclear_loco.max_power = "4800kW"
x12_nuclear_loco.reversing_power_modifier = 1
x12_nuclear_loco.braking_force = 45
x12_nuclear_loco.friction_force = 0.50
x12_nuclear_loco.air_resistance = 0.015
x12_nuclear_loco.burner.fuel_category = "nuclear"
x12_nuclear_loco.burner.effectivity = 0.85
x12_nuclear_loco.burner.fuel_inventory_size = 1
x12_nuclear_loco.burner.burnt_inventory_size = 1
x12_nuclear_loco.working_sound.sound.filename = "__base__/sound/idle1.ogg"
x12_nuclear_loco.working_sound.sound.volume = 1.3
x12_nuclear_loco.working_sound.idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 1.3 }

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


data:extend({
  x12_nuclear_tender
})