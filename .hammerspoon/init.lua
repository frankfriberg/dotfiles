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
map.hyper("q", windows.leftHalf)
map.hyper("w", windows.rightHalf)
map.hyper("v", windows.splitVertical)
map.hyper("s", windows.splitHorizontal)
map.hyper("f", windows.fillScreen)
map.hyper("e", function()
	windows.cycleAppsInSpace(true)
end)
map.hyper("d", function()
	windows.cycleAppsInSpace(false)
end)
map.hyper("b", windows.balanceWindows)
map.hyper("r", windows.rotateWindows)
