local settings = require("settings")
local colors = require("colors")

local defaults = {
	updates = "when_shown",
	icon = {
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Bold"],
			size = 14.0,
		},
		color = colors.foreground,
		padding_left = settings.paddings,
		padding_right = settings.paddings,
		background = {
			image = {
				corner_radius = 5,
			},
		},
	},
	label = {
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Semibold"],
			size = 13.0,
		},
		color = colors.foreground,
		padding_left = settings.paddings,
		padding_right = settings.paddings,
	},
	background = {
		height = 30,
		corner_radius = 10,
		border_width = 1,
		border_color = colors.background,
		image = {
			corner_radius = 10,
		},
	},
	popup = {
		background = {
			border_width = 1,
			corner_radius = 10,
			border_color = colors.popup.border,
			color = colors.popup.bg,
			shadow = { drawing = true },
		},
		blur_radius = 50,
	},
	padding_left = 5,
	padding_right = 5,
	scroll_texts = true,
}

local theme_watcher = Sbar.add("item", { drawing = false })
theme_watcher:subscribe("theme_changed", function(data)
	Sbar.exec(
		"osascript -e 'tell application \"System Events\" to tell appearance preferences to get dark mode'",
		function(is_dark)
			if is_dark == "true" then
				defaults.label.color = colors.red
			end
		end
	)
end)

-- Equivalent to the --default domain
Sbar.default(defaults)
