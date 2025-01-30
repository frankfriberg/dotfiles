local default_bracket = require("default").default_bracket

local battery = require("items.right.battery")
local volume = require("items.right.volume")
local wifi = require("items.right.wifi")
local memory = require("items.right.memory")
local cpu = require("items.right.cpu")

sbar.add("bracket", "container.right", {
	battery.name,
	volume.name,
	wifi.name,
	cpu.name,
	memory.name,
}, default_bracket)

sbar.add("item", "spacer.right", {
	position = "right",
	width = 8,
	label = "",
})

require("items.right.media")
