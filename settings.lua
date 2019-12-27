--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: settings.lua
 * Description: Setting to control MU operation.
--]]

data:extend({
  
  {
    type = "string-setting",
	name = "x12-nuclear-locomotive-debug",
	order = "ac",
	setting_type = "runtime-global",
	default_value = "info",
	allowed_values = {"none","error","info"}
  },
})
