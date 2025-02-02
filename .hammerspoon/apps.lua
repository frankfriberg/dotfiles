local map = require("map")
local M = {}

local apps = {
	s = "Slack",
	t = "Telegram",
	d = "Docker Desktop",
	f = "Finder",
	m = "Mail",
	p = "1Password",
}

for key, app in pairs(apps) do
	map.hyper(key, function()
		hs.application.open(app)
	end)
end

M.hideAppOnDeactivate = function(appName, eventType, appObject)
	if eventType == hs.application.watcher.deactivated then
		for _, app in pairs(apps) do
			if appName == app then
				appObject:hide()
				break
			end
		end
	end
end

return M
