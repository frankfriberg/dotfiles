local wezterm = require("wezterm")
local Space = { Text = " " }
local Spacer = { Text = " · " }

local get_process_icon = function(process_name)
	local process_icons = {
		["docker"] = "󰡨",
		["docker-compose"] = "󰡨",
		["nvim"] = "􀤙 ",
		["vim"] = "",
		["node"] = "󰋘",
		["zsh"] = "",
		["fish"] = "",
		["bash"] = "",
		["cargo"] = "󱘗",
		["git"] = "",
		["lazygit"] = "",
		["lua"] = "",
		["wget"] = "󰜯",
		["curl"] = "󰜯",
		["go"] = "",
		["gh"] = "",
		["php"] = "",
	}

	return { Text = process_icons[process_name] or "󰅩" }
end

local function basename(s)
	return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

local tabs = function(tab, _, _, config)
	local pane = tab.active_pane
	local cwd = pane.current_working_dir and basename(pane.current_working_dir.file_path)
	local process_name = pane.foreground_process_name and basename(pane.foreground_process_name)

	local Dir = { Text = cwd or pane.title }
	local ProcessIcon = get_process_icon(process_name)
	local ProcessName = { Text = process_name or "wezterm" }
	local tab_foreground = config.resolved_palette.tab_bar.active_tab.bg_color
	local tab_background = config.resolved_palette.tab_bar.background
	local sperator_color = tab.is_active and tab_foreground or tab_background

	return wezterm.format({
		Space,
		Space,
		ProcessIcon,
		Space,
		ProcessName,
		Spacer,
		Dir,
		Space,
		{ Foreground = { Color = sperator_color } },
		{ Background = { Color = wezterm.color.parse(tab_background):darken(0.3) } },
		{ Text = "▉" },
	})
end

return tabs
