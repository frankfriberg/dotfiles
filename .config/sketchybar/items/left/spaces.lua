local colors = require("colors")
local palette = colors.currentPalette

-- local app_list = {}
-- local space_watcher = sbar.add("item", {})
-- space_watcher:subscribe("space_windows_change", function(env)
-- 	local apps = env.INFO.apps
--
-- 	for _, app in ipairs(app_list) do
-- 		local item = sbar.item(app)
-- 		print(item.name)
-- 	end
--
-- 	for name, _ in pairs(apps) do
-- 		local app = sbar.add("item", {
-- 			label = name,
-- 		})
--
-- 		apps[name] = app.name
-- 	end
-- end)

local spaces_list = {}
local app_list = {}

sbar.exec("hs -c 'hs.json.encode(hs.spaces.spacesForScreen())'", function(spaces)
	for index, _ in ipairs(spaces) do
		local space = sbar.add("space", {
			associated_space = index,
			icon = {
				string = index,
				padding_left = 5,
				padding_right = 5,
				color = palette.fg,
			},
			label = {
				padding_right = 5,
				drawing = false,
			},
			background = {
				color = palette.red,
				drawing = false,
			},
		})

		spaces_list[index] = space.name

		space:subscribe("space_change", function(env)
			sbar.set(env.NAME, {
				background = {
					drawing = env.SELECTED,
				},
			})
		end)

		space:subscribe("space_windows_change", function(env)
			local apps = env.INFO.apps

			for _, item in ipairs(app_list) do
				sbar.remove(item)
			end

			for name, _ in pairs(apps) do
				local app = sbar.add("item", {
					label = name,
				})
				table.insert(app_list, app.name)
			end

			-- sbar.set(spaces_list[env.INFO.space], {
			-- 	label = {
			-- 		drawing = true,
			-- 		string = table.concat(list, " "),
			-- 	},
			-- })
		end)

		space:subscribe("front_app_switched", function(app) end)
	end
end)
