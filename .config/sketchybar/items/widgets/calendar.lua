local settings = require("settings")
local colors = require("colors")

local cal = Sbar.add("item", {
	icon = {
		color = colors.foreground,
		padding_left = 8,
	},
	label = {
		color = colors.foreground,
		padding_right = 8,
		width = 49,
		align = "right",
		font = { family = settings.font.numbers },
	},
	position = "right",
	update_freq = 30,
	padding_left = 1,
	padding_right = 1,
})

cal:subscribe({ "forced", "routine", "system_woke" }, function()
	cal:set({ icon = os.date("%a %d %b."), label = os.date("%H:%M") })
end)

return cal
