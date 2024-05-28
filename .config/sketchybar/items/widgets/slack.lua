local app_icons = require("helpers.app_icons")

local slack = Sbar.add("item", {
	background = {
		color = "0xff34785C",
		height = 20,
		corner_radius = 7,
	},
	position = "right",
	icon = {
		font = "sketchybar-app-font:Regular:12.0",
		string = app_icons["Slack"],
		padding_left = 5,
		padding_right = 3,
	},
	label = {
		drawing = false,
		font = {
			size = 11,
		},
		padding_left = 0,
		padding_right = 5,
	},
	update_freq = 10,
	padding_right = 2,
	padding_left = 2,
})

slack:subscribe({ "slack", "routine", "system_woke" }, function()
	Sbar.exec("lsappinfo info -only StatusLabel Slack", function(slack_info)
		local label = nil

		if slack_info:match('"label"="•"') then
			label = "•"
		elseif slack_info:match('"label"="[0-9]+"') then
			label = slack_info:match('"label"="([0-9]+)"')
		end

		if label then
			slack:set({
				label = {
					drawing = true,
					string = label,
				},
			})
		else
			slack:set({
				label = {
					drawing = false,
				},
			})
		end
	end)
end)

slack:subscribe("mouse.clicked", function()
	Sbar.exec("yabai -m window --toggle slack || open -a Slack")
end)

return slack
