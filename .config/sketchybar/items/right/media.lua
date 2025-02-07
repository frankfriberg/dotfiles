local player_icon = sbar.add("item", "widgets.media.icon", {
	position = "right",
	icon = {
		string = "􀊘 ",
		font = {
			size = 16,
		},
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

media_title:subscribe("media_change", function(env)
	local playing = env.INFO.state == "playing"
	media_artist:set({ label = env.INFO.artist })
	media_title:set({ label = env.INFO.title })
	player_icon:set({ icon = playing and "􀊖" or "􀊘" })

	sbar.animate("tanh", 30, function()
		media_artist:set({ label = { width = "dynamic" } })
		media_title:set({ label = { width = "dynamic" } })
	end)
end)
