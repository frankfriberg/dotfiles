local wezterm = require("wezterm")
local workspaces = require("workspaces")

local function basename(s)
	return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

local Workspaces = function(window)
	local tab_colors = window:effective_config().resolved_palette.tab_bar
	local active_workspaces = wezterm.mux.get_workspace_names()
	local current_workspace = window:active_workspace()

	local display = {}

	for _, workspace_path in ipairs(active_workspaces) do
		local workspace = basename(workspace_path)
		local foreground = { Foreground = { Color = tab_colors.active_tab.fg_color } }
		local background = { Background = { Color = tab_colors.active_tab.bg_color } }

		if workspace_path ~= current_workspace then
			foreground.Foreground.Color = tab_colors.inactive_tab.fg_color
			background.Background.Color = tab_colors.inactive_tab.bg_color
		end

		table.insert(display, { Foreground = { Color = background.Background.Color } })
		table.insert(display, { Background = { Color = wezterm.color.parse(tab_colors.background):darken(0.3) } })
		table.insert(display, { Text = "🮋" })

		local label = workspaces[workspace] and workspaces[workspace].label or workspace
		local icon = workspaces[workspace] and workspaces[workspace].icon or "$"
		table.insert(display, foreground)
		table.insert(display, background)
		table.insert(display, { Text = string.format("  %s %s  ", icon, label) })
	end

	return display
end

local rightStatus = function(window)
	window:set_right_status(wezterm.format(Workspaces(window)))
end

return rightStatus
