hs.loadSpoon("EmmyLua")

require("hs.ipc")

local map = require("map")
local windows = require("windows")
local apps = require("apps")

appWatcher = hs.application.watcher.new(apps.hideAppOnDeactivate)
appWatcher:start()

hs.window.animationDuration = 0.05
hs.notify.show("Hammerspoon", "", "Loaded config")

map.meh("r", function()
	hs.reload()
end)

-- Windows
map.meh("q", windows.leftHalf)
map.meh("w", windows.rightHalf)
map.meh("v", windows.splitVertical)
map.meh("s", windows.splitHorizontal)
map.meh("f", windows.fillScreen)
map.meh("e", function()
	windows.cycleAllWindowsInSpace(false)
end)
map.meh("d", function()
	windows.cycleAllWindowsInSpace(true)
end)
map.meh("b", windows.balanceWindows)
