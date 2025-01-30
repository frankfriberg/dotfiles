local defaults = require("default")

sbar.add("event", "aerospace_workspace_change")

local function highlight_selected(name, selected)
	sbar.animate("tanh", 10, function()
		sbar.set(name, {
			label = {
				highlight = selected,
			},
		})
	end)
end

local function space_selection(env)
	local id = string.match(env.NAME, "workspace%.([^%.]+)%.item")
	local selected = id == env.FOCUSED

	highlight_selected(env.NAME, selected)
end

sbar.exec("aerospace list-workspaces --all", function(workspaces)
	for workspace in workspaces:gmatch("[^\n]+") do
		local item_name = string.format("workspace.%s.item", workspace)
		local workspace_item = sbar.add("item", item_name, {
			label = {
				string = workspace,
			},
			background = {
				height = 20,
				corner_radius = 7,
			},
			padding_left = 10,
			padding_right = 10,
			position = "left",
		})

		workspace_item:subscribe("workspace_change", space_selection)
	end

	sbar.exec("aerospace list-workspaces --focused", function(raw)
		local focused_workspace = raw:gsub("[\n\r]", "")
		highlight_selected(string.format("workspace.%s.item", focused_workspace), true)
	end)

	local workspaceBracket = sbar.add("bracket", "container.workspaces", { "/workspace.*/" }, defaults.default_bracket)

	workspaceBracket:subscribe("theme_changed", function(palette)
		sbar.set("/workspace.*/", {
			label = {
				color = palette.faded,
				highlight_color = palette.fg,
			},
		})
	end)
end)
