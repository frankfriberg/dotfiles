local mail = Sbar.add("item", {
	background = {
		color = "0xff3A74EA",
		height = 20,
		corner_radius = 7,
	},
	position = "right",
	icon = {
		string = "􀈤",
		font = {
			size = 9,
		},
		padding_left = 3,
		padding_right = 4,
		y_offset = 1,
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

mail:subscribe({ "slack", "routine", "system_woke" }, function()
	Sbar.exec("lsappinfo info -only StatusLabel Mail", function(mail_info)
		local label = nil

		if mail_info:match('"label"="•"') then
			label = "•"
		elseif mail_info:match('"label"="[0-9]+"') then
			label = mail_info:match('"label"="([0-9]+)"')
		end

		if label then
			mail:set({
				label = {
					drawing = true,
					string = label,
				},
			})
		else
			mail:set({
				label = {
					drawing = false,
				},
			})
		end
	end)
end)

mail:subscribe("mouse.clicked", function()
	Sbar.exec("yabai -m window --toggle slack || open -a Slack")
end)

return mail
