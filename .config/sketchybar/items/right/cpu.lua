local icons = require("icons")
local colors = require("colors")

local cpu = sbar.add("item", "widgets.cpu.item", {
	position = "right",
	icon = {
		string = icons.cpu,
		padding_right = 7,
		padding_left = 3,
	},
	label = {
		string = "??",
		width = 30,
		align = "right",
		padding_right = 4,
	},
	update_freq = 2,
	background = {
		height = 20,
		corner_radius = 5,
	},
	padding_right = 2,
	padding_left = 2,
})

cpu:subscribe({ "routine", "system_woke", "theme_changed" }, function()
	sbar.exec("top -l 1 | grep 'CPU usage' | awk '{printf \"%d\", $3 + $5}'", function(result)
		local palette = colors.currentPalette
		local fg = palette.fg
		local bg = palette.bg
		local usage = tonumber(result)

		if usage > 40 then
			bg = palette.yellow
			fg = palette.bg
			if usage > 60 then
				bg = palette.peach
			end
			if usage > 80 then
				bg = palette.red
			end
		end

		cpu:set({
			label = {
				string = usage .. "%",
				color = fg,
			},
			icon = {
				color = fg,
			},
			background = {
				color = bg,
			},
		})
	end)
end)

return cpu
