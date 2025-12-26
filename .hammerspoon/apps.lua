local map = require("map")
local M = {}

local apps = {
	a = "All Gravy",
	s = "Spotify",
	c = "Slack",
	t = "Telegram",
	d = "Docker Desktop",
	f = "Finder",
	m = "Spark Desktop",
	p = "1Password",
}

for key, app in pairs(apps) do
	map.meh(key, function()
		local runningApp = hs.application(app)
		if runningApp and runningApp:isFrontmost() then
			runningApp:hide()
		else
			hs.application.open(app)
		end
	end)
end

-- Track the current workspace/space
local currentSpace = nil

M.hideAppOnDeactivate = function(appName, eventType, appObject)
	if eventType == hs.application.watcher.activated then
		currentSpace = hs.spaces.focusedSpace()

		for _, app in pairs(apps) do
			if appName == app then
				local runningApp = hs.application(appName)
				local frame = hs.screen.mainScreen():frame()
				local window = runningApp:mainWindow()
				local width = math.max(frame.w / 2, 1500)
				local height = math.max(frame.h / 2, 1000)
				if appName == "Finder" then
					width = 1000
					height = 700
				end
				window:setFrame({
					w = width,
					h = height,
					x = frame.w / 2 - width / 2,
					y = frame.h / 2 - height / 2,
				})
			end
		end
	elseif eventType == hs.application.watcher.deactivated then
		local newSpace = hs.spaces.focusedSpace()

		if currentSpace == newSpace then
			for _, app in pairs(apps) do
				if appName == app then
					appObject:hide()
					break
				end
			end
		end

		currentSpace = newSpace
	end
end

return M
