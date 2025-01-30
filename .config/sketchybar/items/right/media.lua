local default_bracket = require("default").default_bracket
local app_icons = require("helpers.app_icons")

local whitelist = {
	["Spotify"] = true,
	["Music"] = true,
}

local player_icon = sbar.add("item", "widgets.media.icon", {
	position = "right",
	icon = {
		font = "sketchybar-app-font:Regular:18.0",
		string = app_icons["Spotify"],
	},
	label = {
		drawing = false,
	},
	updates = true,
	padding_right = 7,
	padding_left = 5,
})

local media_artist = sbar.add("item", "widgets.media.artist.item", {
	position = "right",
	padding_left = 3,
	padding_right = 0,
	width = 0,
	icon = { drawing = false },
	label = {
		width = 0,
		font = { size = 9 },
		max_chars = 30,
		y_offset = 6,
		padding_left = 5,
	},
})

local media_title = sbar.add("item", "widgets.media.title.item", {
	position = "right",
	padding_left = 3,
	padding_right = 0,
	icon = { drawing = false },
	label = {
		font = { size = 11 },
		width = 0,
		max_chars = 30,
		y_offset = -5,
		padding_left = 5,
	},
})

local media_bracket = sbar.add("bracket", "container.widgets.media", {
	player_icon.name,
	media_artist.name,
	media_title.name,
}, default_bracket)

player_icon:subscribe("theme_changed", function(palette)
	player_icon:set({ icon = { color = palette.green } })
end)

media_bracket:subscribe("media_change", function(env)
	if whitelist[env.INFO.app] then
		media_artist:set({ label = env.INFO.artist })
		media_title:set({ label = env.INFO.title })
		player_icon:set({ icon = { string = app_icons[env.INFO.app] } })

		sbar.animate("tanh", 30, function()
			media_artist:set({ label = { width = "dynamic" } })
			media_title:set({ label = { width = "dynamic" } })
		end)
	end
end)
