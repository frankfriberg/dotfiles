local wezterm = require("wezterm")
local parse = wezterm.color.parse

return {
	nvim = {
		label = "Neovim",
		icon = "",
		color = parse("olivedrab"),
	},
	["carbon-reporting-frontend"] = {
		label = "CR Frontend",
		icon = "󰜈",
		color = parse("steelblue"),
	},
	["carbon-reporting"] = {
		label = "CR Backend",
		icon = "",
		color = parse("purple"),
	},
	inwi = {
		label = "Inwi",
		icon = "󰟫",
		color = parse("orange"),
	},
	hvorapp = {
		label = "HvorApp",
		icon = "",
		color = parse("skyblue"),
	},
	wezterm = {
		label = "Wezterm",
		icon = "󰢻",
		color = parse("MediumOrchid"),
	},
}
