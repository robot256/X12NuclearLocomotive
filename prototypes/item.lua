--[[ Copyright (c) 2018 Optera
 * Part of Train Overhaul
 *
 * See LICENSE.md in the project directory for license information.
--]]

local x12_nuclear_loco = optera_lib.copy_prototype(data.raw["item-with-entity-data"]["locomotive"], "x12-nuclear-locomotive")
x12_nuclear_loco.icon = "__TrainOverhaul__/graphics/icons/nuclear-locomotive.png"
x12_nuclear_loco.order = "a[train-system]-fxl[locomotive]"

data:extend({
  x12_nuclear_loco,
})

local x12_nuclear_tender = optera_lib.copy_prototype(data.raw["item-with-entity-data"]["fluid-wagon"], "x12-nuclear-tender")
x12_nuclear_tender.icon = "__TrainOverhaul__/graphics/icons/heavy-fluid-wagon.png"
x12_nuclear_tender.order = "a[train-system]-fxt[locomotive]"

data:extend({
  x12_nuclear_tender
})
