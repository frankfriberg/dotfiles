local wezterm = require("wezterm")
local parse = wezterm.color.parse
local M = {}

M.dark_scheme = "rose-pine-moon"
M.light_scheme = "rose-pine-dawn"

local function get_appearance()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
	return "Dark"
end

M.custom_colors = function()
	local scheme_colors = M.get_scheme_colors()

	local colors = {
		split = scheme_colors.foreground,
		tab_bar = {
			background = scheme_colors.background:darken(0.5),
			active_tab = {
				bg_color = scheme_colors.background,
				fg_color = scheme_colors.foreground,
			},
			inactive_tab = {
				bg_color = scheme_colors.background:darken(0.3),
				fg_color = scheme_colors.foreground:darken(0.1),
			},
		},
	}

	if scheme_colors.selection_bg == scheme_colors.background then
		colors["selection_bg"] = "plum"
	end

	return colors
end

M.colors = {
	white = parse("snow"),
	green = parse("olivedrab"),
	blue = parse("steelblue"),
	purple = parse("plum"),
	yellow = parse("palegoldenrod"),
	aqua = parse("mediumturquoise"),
}

M.get_scheme_colors = function()
	local scheme = M.scheme_for_appearance()
	local scheme_colors = wezterm.color.get_builtin_schemes()[scheme]

	return {
		ansi = {
			parse(scheme_colors.ansi[1]),
			parse(scheme_colors.ansi[2]),
			parse(scheme_colors.ansi[3]),
			parse(scheme_colors.ansi[4]),
			parse(scheme_colors.ansi[5]),
			parse(scheme_colors.ansi[6]),
			parse(scheme_colors.ansi[7]),
			parse(scheme_colors.ansi[8]),
		},
		brights = {
			parse(scheme_colors.brights[1]),
			parse(scheme_colors.brights[2]),
			parse(scheme_colors.brights[3]),
			parse(scheme_colors.brights[4]),
			parse(scheme_colors.brights[5]),
			parse(scheme_colors.brights[6]),
			parse(scheme_colors.brights[7]),
			parse(scheme_colors.brights[8]),
		},
		background = parse(scheme_colors.background),
		cursor_bg = parse(scheme_colors.cursor_bg),
		cursor_border = parse(scheme_colors.cursor_border),
		cursor_fg = parse(scheme_colors.cursor_fg),
		foreground = parse(scheme_colors.foreground),
		indexed = scheme_colors.indexed,
		selection_bg = parse(scheme_colors.selection_bg),
		selection_fg = parse(scheme_colors.selection_fg),
	}
end

M.scheme_for_appearance = function()
	if get_appearance():find("Dark") then
		return M.dark_scheme
	else
		return M.light_scheme
	end
end

return M
