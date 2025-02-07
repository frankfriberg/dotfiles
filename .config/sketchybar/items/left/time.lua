local time = sbar.add("item", "widgets.time.item", {
	icon = {
		padding_right = 5,
		font = {
			size = 16,
		},
	},
	position = "left",
	update_freq = 30,
	padding_right = 8,
})

time:subscribe({ "forced", "routine", "system_woke" }, function()
	local clocks = {
		["12"] = "󱑊",
		["01"] = "󱐿",
		["02"] = "󱑀",
		["03"] = "󱑁",
		["04"] = "󱑂",
		["05"] = "󱑃",
		["06"] = "󱑄",
		["07"] = "󱑅",
		["08"] = "󱑆",
		["09"] = "󱑇",
		["10"] = "󱑈",
		["11"] = "󱑉",
	}

	time:set({
		label = os.date("%H:%M"),
		icon = {
			string = clocks[os.date("%I")],
		},
	})
end)

return time.name
