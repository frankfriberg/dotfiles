local icons = require("icons")

local volume_percent = sbar.add("item", "widgets.volume.percentage.item", {
	position = "right",
	icon = {
		padding_right = 7,
	},
	label = {
		string = "??%",
		align = "right",
	},
})

volume_percent:subscribe("volume_change", function(env)
	local volume = tonumber(env.INFO)
	local icon = icons.volume._0
	if volume > 60 then
		icon = icons.volume._100
	elseif volume > 30 then
		icon = icons.volume._66
	elseif volume > 10 then
		icon = icons.volume._33
	elseif volume > 0 then
		icon = icons.volume._10
	end

	local label = string.format("%s%%", volume)

	volume_percent:set({ icon = icon, label = label })
end)

return volume_percent
