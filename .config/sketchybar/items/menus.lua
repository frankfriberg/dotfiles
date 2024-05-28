local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local menu_watcher = Sbar.add("item", {
	drawing = false,
	updates = true,
})

local apple = Sbar.add("item", {
	icon = {
		font = { size = 16.0 },
		string = icons.apple,
		padding_right = 4,
		padding_left = 8,
		y_offset = 1,
	},
	label = { drawing = false },
	click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s 0",
})

local max_items = 15
local menu_items = {}
for i = 1, max_items, 1 do
	local menu = Sbar.add("item", "menu." .. i, {
		padding_left = settings.paddings,
		padding_right = settings.paddings,
		icon = { drawing = false },
		label = {
			font = {
				style = settings.font.style_map[i == 1 and "Heavy" or "Semibold"],
			},
			padding_left = 6,
			padding_right = 6,
		},
		click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s " .. i,
	})

	menu_items[i] = menu
end

Sbar.add("bracket", { apple.name, "/menu\\..*/" }, {
	background = { color = colors.background },
})

local function update_menus(env)
	Sbar.exec("$CONFIG_DIR/helpers/menus/bin/menus -l", function(menus)
		Sbar.set("/menu\\..*/", { drawing = false })
		local id = 1
		for menu in string.gmatch(menus, "[^\r\n]+") do
			if id < max_items then
				menu_items[id]:set({ label = menu, drawing = true })
			else
				break
			end
			id = id + 1
		end
	end)
end

menu_watcher:subscribe("front_app_switched", update_menus)
