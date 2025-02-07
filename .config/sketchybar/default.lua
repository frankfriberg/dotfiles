local colors = require("colors")

local default_settings = {
	paddings = 3,
	icons = "sf-symbols",
	font = require("helpers.default_font"),
}

local defaults = {
	updates = "when_shown",
	icon = {
		font = {
			family = default_settings.font.text,
			style = default_settings.font.style_map["Semibold"],
			size = 13.0,
		},
	},
	label = {
		font = {
			family = default_settings.font.text,
			style = default_settings.font.style_map["Semibold"],
			size = 13.0,
		},
	},
	background = {
		color = 0x00000000,
		height = 22,
		corner_radius = 5,
	},
	scroll_texts = true,
	padding_right = default_settings.paddings,
	padding_left = default_settings.paddings,
}

colors.refreshColors()

local theme_watcher = sbar.add("item", { drawing = false })

theme_watcher:subscribe("appleThemeNotification", function()
	colors.refreshColors()
end)

-- Equivalent to the --default domain
sbar.default(defaults)

return default_settings
