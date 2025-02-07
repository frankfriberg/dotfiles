local icons = require("icons")
local colors = require("colors")

local wifi = sbar.add("item", "widgets.wifi.item", {
	position = "right",
	icon = {
		padding_left = 5,
		padding_right = 6,
	},
	label = {
		padding_right = 6,
	},
})

wifi:subscribe({ "wifi_change", "system_woke", "theme_changed" }, function()
	sbar.exec("ipconfig getsummary en0", function(data)
		local ssid = data:match("[^B]SSID%s*:%s*([^\n]+)")
		local connected = ssid ~= nil
		local color
		local palette = colors.currentPalette
		local fg = palette.bg
		local icon

		local router_ip = data:match("router %(ip_mult%): {([^}]+)}")
		local is_hotspot = router_ip and router_ip:match("^172%.20%.")

		if not connected then
			icon = icons.wifi.disconnected
			color = palette.red
		elseif is_hotspot then
			icon = icons.wifi.hotspot
			color = colors.currentPalette.green
		else
			icon = icons.wifi.connected
			color = colors.currentPalette.blue
		end

		wifi:set({
			icon = {
				color = fg,
				string = icon,
			},
			label = {
				color = fg,
				string = connected and ssid or "Disconnected",
			},
			background = {
				color = color,
			},
		})
	end)
end)

return wifi
