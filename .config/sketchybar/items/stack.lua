local settings = require("settings")
local yabai_query = 'yabai -m query --windows --space | jq \'.[] | select(."stack-index" > 0) | {"app"}\''

local stack_bracket = Sbar.add("bracket", settings.default_bracket)

stack_bracket:subscribe("space_change", function()
	local stack = Sbar.exec(yabai_query)
	local stack_count = #stack
	if stack_count > 0 then
		stack_bracket:set({
			background = {
				color = settings.colors.red,
			},
		})
	else
		stack_bracket:set({
			background = {
				color = settings.colors.background,
			},
		})
	end
end)
