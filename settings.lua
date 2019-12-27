--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: X-12 Nuclear Locomotive
 * File: settings.lua
 * Description: Setting to control X12 mod operation.
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
