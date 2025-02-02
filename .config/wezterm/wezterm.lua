local wezterm = require("wezterm")
local act = wezterm.action

local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
workspace_switcher.zoxide_path = "/opt/homebrew/bin/zoxide"
resurrect.periodic_save({
	interval_seconds = 60,
})

local theme = require("theme")
local inputmenu = require("inputmenu")
local tabs = require("tabs")
local rightStatus = require("statusline")
local splitNav = require("smartsplits")

wezterm.on("format-tab-title", tabs)
wezterm.on("window-config-reloaded", function(window)
	local overrides = window:get_config_overrides() or {}
	local scheme = theme.scheme_for_appearance()
	if overrides.color_scheme ~= scheme then
		overrides.color_scheme = scheme
		overrides.colors = theme.custom_colors()
		window:set_config_overrides(overrides)
	end

	rightStatus(window)
end)

workspace_switcher.workspace_formatter = function(label)
	local scehemeColors = theme.get_scheme_colors()

	return wezterm.format({
		{ Attribute = { Italic = true } },
		{ Foreground = { Color = scehemeColors.ansi[3] } },
		{ Background = { Color = scehemeColors.background } },
		{ Text = "󱂬 : " .. label },
	})
end

-- loads the state whenever I create a new workspace
wezterm.on("smart_workspace_switcher.workspace_switcher.created", function(window, path, label)
	local workspace_state = resurrect.workspace_state

	workspace_state.restore_workspace(resurrect.load_state(label, "workspace"), {
		window = window,
		relative = true,
		restore_text = true,
		on_pane_restore = resurrect.tab_state.default_on_pane_restore,
	})
end)

-- wezterm.on("smart_workspace_switcher.workspace_switcher.chosen", function(window, path, label)
-- 	window:set_config_overrides({})
-- 	rightStatus(window)
-- end)

wezterm.on("smart_workspace_switcher.workspace_switcher.selected", function(window, path, label)
	window:set_config_overrides({})
	rightStatus(window)
	local workspace_state = resurrect.workspace_state
	resurrect.save_state(workspace_state.get_workspace_state())
end)

local config = {
	adjust_window_size_when_changing_font_size = false,
	audible_bell = "Disabled",
	check_for_updates = false,
	color_scheme = theme.scheme_for_appearance(),
	colors = theme.custom_colors(),
	default_workspace = "neovim",
	default_cwd = "/Users/ff/.config/nvim",
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
	mouse_wheel_scrolls_tabs = false,
	keys = {
		{ key = "w", mods = "SHIFT|CMD", action = workspace_switcher.switch_workspace() },
		{ key = "s", mods = "SHIFT|CMD", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{ key = "v", mods = "SHIFT|CMD", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "o", mods = "SHIFT|CMD", action = act.TogglePaneZoomState },
		{ key = "c", mods = "SHIFT|CMD", action = act.CloseCurrentPane({ confirm = true }) },
		{ key = "d", mods = "SHIFT|CMD", action = act.ShowDebugOverlay },
		{ key = "l", mods = "SHIFT|ALT", action = act.MoveTabRelative(1) },
		{ key = "h", mods = "SHIFT|ALT", action = act.MoveTabRelative(-1) },
		{ key = "k", mods = "CTRL", action = act.SendKey({ key = "UpArrow" }) },
		{ key = "j", mods = "CTRL", action = act.SendKey({ key = "DownArrow" }) },
		{ key = "t", mods = "CMD", action = act.SpawnTab("CurrentPaneDomain") },
		{ key = "n", mods = "CMD", action = act.SpawnWindow },
		{ key = "v", mods = "CMD", action = act.PasteFrom("Clipboard") },
		{ key = "c", mods = "CMD", action = act.CopyTo("ClipboardAndPrimarySelection") },
		{ key = "f", mods = "CMD", action = act.Search({ CaseSensitiveString = "" }) },
		{ key = "w", mods = "CMD", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
		{ key = "LeftArrow", mods = "ALT", action = wezterm.action({ SendString = "\x1bb" }) },
		{ key = "RightArrow", mods = "ALT", action = wezterm.action({ SendString = "\x1bf" }) },
		{ key = "LeftArrow", mods = "CMD", action = wezterm.action({ SendString = "\x1bOH" }) },
		{ key = "RightArrow", mods = "CMD", action = wezterm.action({ SendString = "\x1bOF" }) },
		{
			key = "p",
			mods = "SHIFT|CMD",
			action = wezterm.action_callback(function(window, pane)
				window:set_config_overrides({})
				window:perform_action(wezterm.action.SwitchWorkspaceRelative(1), pane)
			end),
		},
		{
			key = "n",
			mods = "SHIFT|CMD",
			action = wezterm.action_callback(function(window, pane)
				window:set_config_overrides({})
				window:perform_action(act.SwitchWorkspaceRelative(-1), pane)
			end),
		},
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

for i, value in ipairs({ "!", '"', "#", "€", "%", "&", "/" }) do
	table.insert(config.keys, {
		key = tostring(value),
		mods = "SHIFT | ALT | CTRL | SUPER",
		action = wezterm.action_callback(function(window, pane)
			local workspaces = wezterm.mux.get_workspace_names()

			window:set_config_overrides({})
			window:perform_action(act.SwitchToWorkspace({ name = workspaces[i] }), pane)
		end),
	})
end

for i = 1, 8 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "CMD",
		action = act.ActivateTab(i - 1),
	})
end

return config
