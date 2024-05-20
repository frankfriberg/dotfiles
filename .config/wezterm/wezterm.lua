local wezterm = require("wezterm")
local act = wezterm.action

local theme = require("theme")
local inputmenu = require("inputmenu")
local tabs = require("tabs")
local rightStatus = require("statusline")
local splitNav = require("smartsplits")

wezterm.on("format-tab-title", tabs)
wezterm.on("update-right-status", rightStatus)
wezterm.on("window-config-reloaded", function(window)
	local overrides = window:get_config_overrides() or {}
	local scheme = theme.scheme_for_appearance()
	if overrides.color_scheme ~= scheme then
		overrides.color_scheme = scheme
		overrides.colors = theme.custom_colors()
		window:set_config_overrides(overrides)
	end
end)

local config = {
	adjust_window_size_when_changing_font_size = false,
	audible_bell = "Disabled",
	check_for_updates = false,
	color_scheme = theme.scheme_for_appearance(),
	colors = theme.custom_colors(),
	font = wezterm.font_with_fallback({
		{
			family = "JetBrainsMono Nerd Font",
			weight = "Medium",
			harfbuzz_features = { "calt=0", "clig=0", "liga=0", "cv06=1", "cv07=1", "cv17=1", "zero" },
		},
		{
			family = "SF Mono",
			weight = "Medium",
		},
		{
			family = "SF Pro",
			weight = "Medium",
		},
	}),
	font_size = 14,
	-- line_height = 1.1,
	inactive_pane_hsb = {
		saturation = 1,
		brightness = 0.85,
	},
	send_composed_key_when_left_alt_is_pressed = true,
	show_new_tab_button_in_tab_bar = false,
	tab_bar_at_bottom = true,
	tab_max_width = 9999,
	term = "wezterm",
	underline_position = -3,
	underline_thickness = "1pt",
	use_dead_keys = false,
	use_fancy_tab_bar = false,
	window_decorations = "RESIZE",
	keys = {
		{ key = "p", mods = "SHIFT|CMD", action = act.ActivateCommandPalette },
		{ key = "w", mods = "SHIFT|CMD", action = inputmenu },
		{ key = "s", mods = "SHIFT|CMD", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{ key = "v", mods = "SHIFT|CMD", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "o", mods = "SHIFT|CMD", action = act.TogglePaneZoomState },
		{ key = "c", mods = "SHIFT|CMD", action = act.CloseCurrentPane({ confirm = true }) },
		{ key = "d", mods = "SHIFT|CMD", action = act.ShowDebugOverlay },
		{ key = "p", mods = "SHIFT|CMD", action = act.SwitchWorkspaceRelative(1) },
		{ key = "n", mods = "SHIFT|CMD", action = act.SwitchWorkspaceRelative(-1) },
		{ key = "l", mods = "SHIFT|ALT", action = act.MoveTabRelative(1) },
		{ key = "h", mods = "SHIFT|ALT", action = act.MoveTabRelative(-1) },
		{ key = "k", mods = "CTRL", action = act.SendKey({ key = "UpArrow" }) },
		{ key = "j", mods = "CTRL", action = act.SendKey({ key = "DownArrow" }) },
		{ key = "t", mods = "CMD", action = act.SpawnTab("CurrentPaneDomain") },
		{ key = "n", mods = "CMD", action = act.SpawnWindow },
		{ key = "v", mods = "CMD", action = act.PasteFrom("Clipboard") },
		{ key = "c", mods = "CMD", action = act.CopyTo("ClipboardAndPrimarySelection") },
		{ key = "f", mods = "CMD", action = act.Search({ CaseSensitiveString = "" }) },
		{ key = "h", mods = "OPT", action = act.SendKey({ key = "b", mods = "ALT" }) },
		{ key = "l", mods = "OPT", action = act.SendKey({ key = "f", mods = "ALT" }) },
		splitNav("move", "h"),
		splitNav("move", "j"),
		splitNav("move", "k"),
		splitNav("move", "l"),
		splitNav("resize", "h"),
		splitNav("resize", "j"),
		splitNav("resize", "k"),
		splitNav("resize", "l"),
	},
}

for i = 1, 8 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "CMD",
		action = act.ActivateTab(i - 1),
	})
end

return config
