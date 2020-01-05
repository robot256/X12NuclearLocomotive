--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: X-12 Nuclear Locomotive
 * File: settings.lua
 * Description: Setting to control X12 mod operation.
--]]

data:extend({
  {
    type = "int-setting",
    name = "x12-nuclear-locomotive-on_nth_tick",
    order = "ab",
    setting_type = "runtime-global",
    minimum_value = 0,
    default_value = 30
  },
  {
    type = "int-setting",
    name = "x12-nuclear-locomotive-steam_per_second",
    order = "ab",
    setting_type = "runtime-global",
    minimum_value = 0,
    default_value = 60
  },
  {
    type = "string-setting",
    name = "x12-nuclear-locomotive-debug",
    order = "ac",
    setting_type = "runtime-global",
    default_value = "info",
    allowed_values = {"none","error","info"}
  },
})
