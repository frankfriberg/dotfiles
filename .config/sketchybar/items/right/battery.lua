local defaults = require("default")
local icons = require("icons")
local colors = require("colors")

local battery = sbar.add("item", "widgets.battery.item", {
	position = "right",
	update_freq = 180,
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
				bg = palette.transparent
			elseif found and charge > 20 then
				icon = icons.battery._25
				bg = palette.peach
				fg = palette.bg
			else
				icon = icons.battery._0
				bg = palette.red
				fg = palette.bg
			end
		end

		battery:set({
			icon = {
				string = icon,
				color = fg,
				padding_right = 5,
			},
			label = {
				string = label,
				color = fg,
				padding_right = bg and 5,
			},
			background = {
				color = bg,
				padding_left = bg and 5,
			},
		})
	end)
end)

return battery
