local M = {}

local rosePineMoon = {
	base = 0xff232136,
	surface = 0xff2a273f,
	overlay = 0xff393552,
	muted = 0xff6e6a86,
	subtle = 0xff908caa,
	text = 0xffe0def4,
	love = 0xffeb6f92,
	gold = 0xfff6c177,
	rose = 0xffea9a97,
	pine = 0xff3e8fb0,
	foam = 0xff9ccfd8,
	iris = 0xffc4a7e7,
	leaf = 0xff95b1ac,
}

local rosePineDawn = {
	base = 0xfffaf4ed,
	surface = 0xfffffaf3,
	overlay = 0xfff2e9e1,
	muted = 0xff9893a5,
	subtle = 0xff797593,
	text = 0xff575279,
	love = 0xffb4637a,
	gold = 0xffea9d34,
	rose = 0xffd7827e,
	pine = 0xff286983,
	foam = 0xff56949f,
	iris = 0xff907aa9,
	leaf = 0xff6d8f89,
}

local setColorPalette = function(palette)
	return {
		bg = palette.base,
		fg = 0xFFFFFFFF,
		faded = palette.subtle,
		border = 0x00000000,
		red = palette.love,
		blue = palette.pine,
		cyan = palette.foam,
		green = palette.leaf,
		yellow = palette.gold,
		purple = palette.iris,
		peach = palette.rose,
		transparent = 0x00000000,
	}
end

M.currentPalette = setColorPalette(rosePineMoon)

M.getColorPalette = function(isDarkMode)
	local palette = isDarkMode and rosePineMoon or rosePineDawn
	local currentPalette = setColorPalette(palette)
	M.currentPalette = currentPalette
	return currentPalette
end

M.refreshColors = function()
	sbar.exec(
		"osascript -e 'tell application \"System Events\" to tell appearance preferences to get dark mode' | xargs",
		function(result)
			local isDarkMode = result and string.find(result, "true") or false
			local palette = M.getColorPalette(isDarkMode)

			sbar.animate("tanh", 10, function()
				sbar.set("/.*item/", {
					label = {
						color = palette.fg,
					},
					icon = {
						color = palette.fg,
					},
				})
			end)

			sbar.trigger("theme_changed", palette)
		end
	)
end

return M
