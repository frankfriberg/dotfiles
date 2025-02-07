local icons = require("icons")
local colors = require("colors")

local memory = sbar.add("item", "widgets.memory.item", {
	position = "right",
	icon = {
		string = icons.memory,
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
})

memory:subscribe({ "routine", "system_woke", "theme_changed" }, function()
	sbar.exec(
		"memory_pressure | grep 'System-wide memory free percentage' | awk '{printf \"%d\", $5}'",
		function(free_memory)
			local palette = colors.currentPalette
			local fg = palette.fg
			local bg = palette.transparent
			local usage = 100 - tonumber(free_memory)

			if usage > 60 then
				bg = palette.yellow
				fg = palette.bg
				if usage > 75 then
					bg = palette.peach
				end
				if usage > 90 then
					bg = palette.red
				end
			end

			memory:set({
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
		end
	)
end)

return memory
