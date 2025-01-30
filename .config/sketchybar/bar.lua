sbar.add("event", "appleThemeNotification", "AppleInterfaceThemeChangedNotification")
sbar.add("event", "theme_changed")

sbar.bar({
	topmost = "window",
	height = 30,
	color = 0x00000000,
	padding_right = 8,
	padding_left = 8,
	y_offset = 8,
})
