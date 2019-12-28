--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: X-12 Nuclear Locomotive
 * File: item.lua
 * Description: Adds item prototypes.
 --]]
 

local x12_nuclear_loco = optera_lib.copy_prototype(data.raw["item-with-entity-data"]["locomotive"], "x12-nuclear-locomotive")
x12_nuclear_loco.icon = "__TrainOverhaul__/graphics/icons/nuclear-locomotive.png"
x12_nuclear_loco.order = "a[train-system]-fxl[locomotive]"
x12_nuclear_loco.localised_name = {"item-name.x12-nuclear-locomotive"}

local x12_nuclear_loco_powered = optera_lib.copy_prototype(x12_nuclear_loco, "x12-nuclear-locomotive-powered")
x12_nuclear_loco_powered.order = "a[train-system]-fxl[locomotive2]"


data:extend({
  x12_nuclear_loco,
  x12_nuclear_loco_powered
})


local x12_nuclear_tender = optera_lib.copy_prototype(data.raw["item-with-entity-data"]["fluid-wagon"], "x12-nuclear-tender")
x12_nuclear_tender.icon = "__TrainOverhaul__/graphics/icons/heavy-fluid-wagon.png"
x12_nuclear_tender.order = "a[train-system]-fxt[locomotive]"

data:extend({
  x12_nuclear_tender
})
