local icons = require("icons")
local colors = require("colors")
local default_bracket = require("settings").default_bracket
local app_icons = require("helpers.app_icons")

local whitelist = {
	["Spotify"] = true,
	["Music"] = true,
}

-- local media_cover = Sbar.add("item", {
-- 	position = "right",
-- 	background = {
-- 		image = {
-- 			string = "media.artwork",
-- 			scale = 0.7,
-- 		},
-- 		border_width = 0,
-- 		color = colors.transparent,
-- 		padding_right = 5,
-- 	},
-- 	updates = true,
-- })

local player_icon = Sbar.add("item", {
	position = "right",
	icon = {
		font = "sketchybar-app-font:Regular:18.0",
		string = app_icons["Spotify"],
		color = colors.green,
		padding_right = 0,
	},
	padding_left = 0,
	padding_right = 0,
	updates = true,
})

local media_artist = Sbar.add("item", {
	position = "right",
	padding_left = 3,
	padding_right = 0,
	width = 0,
	icon = { drawing = false },
	label = {
		width = 0,
		font = { size = 9 },
		color = colors.with_alpha(colors.foreground, 0.6),
		max_chars = 30,
		y_offset = 6,
	},
})

local media_title = Sbar.add("item", {
	position = "right",
	padding_left = 3,
	padding_right = 0,
	icon = { drawing = false },
	label = {
		font = { size = 11 },
		width = 0,
		max_chars = 30,
		y_offset = -5,
	},
})

local media_bracket = Sbar.add("bracket", "widgets.media.bracket", {
	-- media_cover.name,
	player_icon.name,
	media_artist.name,
	media_title.name,
}, {
	popup = {
		align = "center",
		horizontal = true,
	},
	background = default_bracket.background,
	blur_radius = default_bracket.blur_radius,
})

Sbar.add("item", {
	position = "popup." .. media_bracket.name,
	icon = { string = icons.media.back },
	label = { drawing = false },
	click_script = "nowplaying-cli previous",
})

local play_pause = Sbar.add("item", {
	position = "popup." .. media_bracket.name,
	icon = { width = 20, align = "center", string = icons.media.play_pause },
	label = { drawing = false },
	click_script = "nowplaying-cli togglePlayPause",
})

Sbar.add("item", {
	position = "popup." .. media_bracket.name,
	icon = { string = icons.media.forward },
	label = { drawing = false },
	click_script = "nowplaying-cli next",
})

media_bracket:subscribe("media_change", function(env)
	if whitelist[env.INFO.app] then
		if env.INFO.state == "playing" then
			play_pause:set({ icon = { string = icons.media.pause } })
		else
			play_pause:set({ icon = { string = icons.media.play } })
		end

		media_artist:set({ label = env.INFO.artist })
		media_title:set({ label = env.INFO.title })

		Sbar.animate("tanh", 30, function()
			media_artist:set({ label = { width = "dynamic" } })
			media_title:set({ label = { width = "dynamic" } })
		end)
	end
end)

media_bracket:subscribe("mouse.entered", function()
	media_bracket:set({ popup = { drawing = "toggle" } })
end)

media_bracket:subscribe("mouse.exited.global", function()
	media_bracket:set({ popup = { drawing = false } })
end)
