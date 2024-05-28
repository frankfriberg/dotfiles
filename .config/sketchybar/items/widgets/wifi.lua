local icons = require("icons")

local wifi = Sbar.add("item", "widgets.wifi.padding", {
	position = "right",
})

-- Background around the item
local wifi_bracket = Sbar.add("bracket", "widgets.wifi.bracket", {
	wifi.name,
}, {
	-- background = { color = colors.bg1 },
	popup = { align = "center", height = 30 },
})

wifi:subscribe({ "wifi_change", "system_woke" }, function()
	Sbar.exec("networksetup -getairportnetwork en0", function(network)
		local ssid = string.match(network, "Current Wi%-Fi Network: (.*)")
		local connected = not (ssid == nil)
		wifi:set({
			icon = {
				string = connected and icons.wifi.connected or icons.wifi.disconnected,
			},
			label = { string = connected and ssid or "" },
		})
	end)
end)

return wifi_bracket
