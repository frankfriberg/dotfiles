local telegram = Sbar.add("item", {
	background = {
		color = "0xff499AD6",
		height = 20,
		corner_radius = 7,
	},
	position = "right",
	icon = {
		string = "􀈢",
		font = {
			size = 12,
		},
		y_offset = 1,
		width = 20,
	},
	label = {
		drawing = false,
		font = {
			size = 11,
		},
	},
	update_freq = 10,
	padding_right = 2,
})

telegram:subscribe({ "slack", "routine", "system_woke" }, function()
	Sbar.exec("lsappinfo info -only StatusLabel Telegram", function(telegram_info)
		local label = " "

		if telegram_info:match('"label"="•"') then
			label = "•"
		elseif telegram_info:match('"label"="[0-9]+"') then
			label = telegram_info:match('"label"="([0-9]+)"')
		end

		telegram:set({
			label = {
				string = label,
				padding_right = 5,
			},
		})
	end)
end)

telegram:subscribe("mouse.clicked", function()
	Sbar.exec("yabai -m window --toggle telegram || open -a Telegram")
end)

return telegram
