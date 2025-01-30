local default_bracket = require("default").default_bracket

local time = require("items.left.time")
local date = require("items.left.date")

sbar.add("bracket", "container.left", { time, date }, default_bracket)

sbar.add("item", string.format("left.spacer"), {
	label = "",
	width = 8,
})

require("items.left.workspaces")
