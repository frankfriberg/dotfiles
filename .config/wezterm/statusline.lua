local wezterm = require("wezterm")
local theme = require("theme")

local spacer = { Text = " · " }

local function merge_tables(tables)
	local merged_table = {}
	for _, value in ipairs(tables) do
		for _, item in ipairs(value) do
			table.insert(merged_table, item)
		end
	end
	return merged_table
end

local rightStatus = function(window)
	local schema = theme.scheme_for_appearance()
	local colors = wezterm.color.get_builtin_schemes()[schema]

	local date = { Text = wezterm.strftime("%b %-d %H:%M:%S ") }
	local workspace = { Text = wezterm.mux.get_active_workspace() }

	local items = merge_tables({
		{
			"ResetAttributes",
			{ Foreground = { Color = colors.foreground } },
			workspace,
			spacer,
			date,
			"ResetAttributes",
		},
	})

	window:set_right_status(wezterm.format(items))
end

return rightStatus
