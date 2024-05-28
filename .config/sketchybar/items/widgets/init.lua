local default_bracket = require("settings").default_bracket

local cal = require("items.widgets.calendar")
local battery = require("items.widgets.battery")
local volume = require("items.widgets.volume")
local wifi = require("items.widgets.wifi")
local cpu = require("items.widgets.cpu")
local slack = require("items.widgets.slack")
local mail = require("items.widgets.mail")
local telegram = require("items.widgets.telegram")

Sbar.add("bracket", "widgets.bracket", {
	cal.name,
	battery.name,
	volume.name,
	wifi.name,
	cpu.name,
	slack.name,
	mail.name,
	telegram.name,
}, default_bracket)
