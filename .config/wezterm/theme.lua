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

local function relative_luminance(color)
	local function luminanceComponent(component)
		local c = component / 255
		if c <= 0.03928 then
			return c / 12.92
		else
			return ((c + 0.055) / 1.055) ^ 2.4
		end
	end

	local r, g, b = color:srgba_u8()
	local R = luminanceComponent(r)
	local G = luminanceComponent(g)
	local B = luminanceComponent(b)

	return 0.2126 * R + 0.7152 * G + 0.0722 * B
end

M.contrast_ratio = function(color1, color2)
	local L1 = relative_luminance(color1)
	local L2 = relative_luminance(color2)

	local lighter = math.max(L1, L2)
	local darker = math.min(L1, L2)

	return (lighter + 0.1) / (darker + 0.1)
end

M.custom_colors = function()
	local scheme_colors = M.get_scheme_colors()
	local workspace_color = M.get_workspace_background()
	local foreground_contrast = M.contrast_ratio(scheme_colors.foreground, workspace_color)
	local tab_foreground = foreground_contrast < 2.5 and scheme_colors.background or scheme_colors.foreground

	local colors = {
		split = scheme_colors.foreground,
		tab_bar = {
			background = workspace_color,
			active_tab = {
				bg_color = scheme_colors.background,
				fg_color = scheme_colors.foreground,
			},
			inactive_tab = {
				bg_color = workspace_color,
				fg_color = tab_foreground,
			},
		},
		selection_fg = "none",
	}

	if scheme_colors.selection_bg == scheme_colors.background then
		colors["selection_bg"] = "rgba(50%, 50%, 50%, 50%)"
	end

	return colors
end

local blend_colors = function(first_color, second_color, percentage)
	local p = math.max(0, math.min(1, percentage))
	local first_r, first_g, first_b = first_color:srgba_u8()
	local second_r, second_g, second_b = second_color:srgba_u8()

	local r = first_r * (1 - p) + second_r * p
	local g = first_g * (1 - p) + second_g * p
	local b = first_b * (1 - p) + second_b * p

	local toHex = function(value)
		return string.format("%02x", math.floor(value + 0.5))
	end

	local hexColor = "#" .. toHex(r) .. toHex(g) .. toHex(b)

	return parse(hexColor)
end

M.get_workspace_background = function()
	local function basename(s)
		return string.gsub(s, "(.*[/\\])(.*)", "%2")
	end

	local workspace = basename(wezterm.mux.get_active_workspace())
	local workspaces_config = require("workspaces")
	local scheme_colors = M.get_scheme_colors()
	local workspace_color = workspaces_config[workspace]
		and blend_colors(workspaces_config[workspace].color, scheme_colors.background, 0.5)

	return workspace_color or scheme_colors.background:darken(0.3)
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
