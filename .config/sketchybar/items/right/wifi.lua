local icons = require("icons")
local colors = require("colors")

local wifi = sbar.add("item", "widgets.wifi.item", {
	position = "right",
})

wifi:subscribe({ "wifi_change", "system_woke", "theme_changed" }, function()
	sbar.exec("ipconfig getsummary en0", function(data)
		local ssid = data:match("[^B]SSID%s*:%s*([^\n]+)")
		local connected = ssid ~= nil
		local color
		local icon

		local router_ip = data:match("router %(ip_mult%): {([^}]+)}")
		local is_hotspot = router_ip and router_ip:match("^172%.20%.")

		if not connected then
			icon = icons.wifi.disconnected
			color = colors.currentPalette.red
		elseif is_hotspot then
			icon = icons.wifi.hotspot
			color = colors.currentPalette.yellow
		else
			icon = icons.wifi.connected
			color = colors.currentPalette.cyan
		end

		wifi:set({
			icon = {
				string = icon,
				color = color,
				padding_right = 5,
			},
			label = {
				drawing = connected,
				string = connected and ssid or "",
			},
		})
	end)
end)

return wifi
