local default = require("default")

local icons = {
	sf_symbols = {
		plus = "􀅼",
		loading = "􀖇",
		apple = "􀣺",
		gear = "􀍟",
		cpu = "􀫥",
		memory = "􀫦",
		clipboard = "􀉄",

		volume = {
			_100 = "􀊩",
			_66 = "􀊧",
			_33 = "􀊥",
			_10 = "􀊡",
			_0 = "􀊣",
		},
		battery = {
			_100 = "􀛨",
			_75 = "􀺸",
			_50 = "􀺶",
			_25 = "􀛩",
			_0 = "􀛪",
			charging = "􀢋",
		},
		wifi = {
			hotspot = "􀉤",
			connected = "􀙇",
			disconnected = "􀙈",
		},
		media = {
			back = "􀊊",
			forward = "􀊌",
			play_pause = "􀊈",
			play = "􀊄",
			pause = "􀊆",
		},
	},

	-- Alternative NerdFont icons
	nerdfont = {
		plus = "",
		loading = "",
		apple = "",
		gear = "",
		cpu = "",
		clipboard = "Missing Icon",

		switch = {
			on = "󱨥",
			off = "󱨦",
		},
		volume = {
			_100 = "",
			_66 = "",
			_33 = "",
			_10 = "",
			_0 = "",
		},
		battery = {
			_100 = "",
			_75 = "",
			_50 = "",
			_25 = "",
			_0 = "",
			charging = "",
		},
		wifi = {
			upload = "",
			download = "",
			connected = "󰖩",
			disconnected = "󰖪",
			router = "Missing Icon",
		},
		media = {
			back = "",
			forward = "",
			play_pause = "",
		},
	},
}

if not (default.icons == "NerdFont") then
	return icons.sf_symbols
else
	return icons.nerdfont
end
