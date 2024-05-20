local wezterm = require("wezterm")
local colors = require("theme").colors
local space = { Text = " " }
local spacer = { Text = " · " }

local get_process = function(process_name)
	if string.len(process_name) == 0 then
		return nil
	end

	local function icon(color, text)
		return {
			{ Foreground = { Color = color } },
			{ Text = text },
		}
	end

	local process_icons = {
		["docker"] = icon(colors.blue, "󰡨"),
		["docker-compose"] = icon(colors.blue, "󰡨"),
		["nvim"] = icon(colors.green, ""),
		["vim"] = icon(colors.green, ""),
		["node"] = icon(colors.green, "󰋘"),
		["zsh"] = icon(colors.white, ""),
		["fish"] = icon(colors.blue, ""),
		["bash"] = icon(colors.white, ""),
		["cargo"] = icon(colors.purple, "󱘗"),
		["git"] = icon(colors.purple, ""),
		["lazygit"] = icon(colors.purple, ""),
		["lua"] = icon(colors.blue, ""),
		["wget"] = icon(colors.yellow, "󰜯"),
		["curl"] = icon(colors.yellow, "󰜯"),
		["go"] = icon(colors.aqua, ""),
		["gh"] = icon(colors.aqua, ""),
		["php"] = icon(colors.blue, ""),
	}

	if not process_icons[process_name] then
		return icon(colors.blue, "󰅩")
	end

	return wezterm.format(process_icons[process_name])
end

local function basename(s)
	return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

local tabs = function(tab)
	local pane = tab.active_pane
	local cwd = pane.current_working_dir and basename(pane.current_working_dir.file_path)
	local process_name = pane.foreground_process_name and basename(pane.foreground_process_name)

	local title = { Text = process_name }
	local dir = { Text = cwd or pane.title }
	local process = { Text = get_process(process_name) or "wezterm" }

	return wezterm.format({
		space,
		space,
		process,
		space,
		title,
		spacer,
		dir,
		space,
		space,
	})
end

return tabs
