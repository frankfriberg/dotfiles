local defaults = require("default")
local icons = require("icons")
local colors = require("colors")

local battery = sbar.add("item", "widgets.battery.item", {
	position = "right",
	update_freq = 180,
	padding_right = 10,
	padding_left = defaults.paddings,
	icon = {
		padding_right = 5,
		padding_left = 5,
	},
})

battery:subscribe({ "routine", "power_source_change", "system_woke", "theme_changed" }, function()
	sbar.exec("pmset -g batt", function(batt_info)
		local icon = "!"
		local label = "?"

		local palette = colors.currentPalette
		local bg = palette.transparent
		local fg = palette.fg

		local found, _, charge = batt_info:find("(%d+)%%")
		if found then
			charge = tonumber(charge)
			label = charge .. "%"
		end

		local color = palette.green
		local charging, _, _ = batt_info:find("AC Power")

		if charging then
			icon = icons.battery.charging
		else
			if found and charge > 80 then
				icon = icons.battery._100
			elseif found and charge > 60 then
				icon = icons.battery._75
			elseif found and charge > 40 then
				icon = icons.battery._50
			elseif found and charge > 20 then
				icon = icons.battery._25
				bg = palette.peach
				color = palette.bg
				fg = palette.bg
			else
				icon = icons.battery._0
				bg = palette.red
				color = palette.bg
				fg = palette.bg
			end
		end

		battery:set({
			icon = {
				string = icon,
				color = color,
				padding_right = 5,
			},
			label = {
				string = label,
				color = fg,
			},
			background = {
				color = bg,
			},
		})
	end)
end)

return battery
