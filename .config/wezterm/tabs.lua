local wezterm = require("wezterm")
local colors = require("colors")
local space = { Text = " " }
local spacer = { Text = " · " }

local get_process = function(tab)
  local process_name = string.gsub(tab.active_pane.foreground_process_name, "(.*[/\\])(.*)", "%2")
  local nf = wezterm.nerdfonts

  if string.len(process_name) == 0 then
    return nil
  end

  local function icon(color, text)
    return {
      { Foreground = { Color = color } },
      text and { Text = text },
    }
  end

  local process_icons = {
    ["docker"] = icon(colors.blue, "󰡨"),
    ["docker-compose"] = icon(colors.blue, "󰡨"),
    ["nvim"] = icon(colors.green, "󰬕"),
    ["vim"] = icon(colors.green, ""),
    ["node"] = icon(colors.green, "󰋘"),
    ["zsh"] = icon(colors.blue, ""),
    ["fish"] = icon(colors.blue, ""),
    ["bash"] = icon(colors.fg, ""),
    ["cargo"] = icon(colors.purple, "󱘗"),
    ["go"] = icon(colors.aqua, ""),
    ["lazydocker"] = icon(colors.blue, "󰡨"),
    ["git"] = icon(colors.purple, ""),
    ["lazygit"] = icon(colors.purple, ""),
    ["lua"] = icon(colors.blue, ""),
    ["wget"] = icon(colors.yellow, "󰜯"),
    ["curl"] = icon(colors.yellow, "󰜯"),
    ["gh"] = icon(colors.aqua, ""),
    ["php"] = icon(colors.blue, ""),
  }

  return wezterm.format(process_icons[process_name] or icon(colors.skyblue, nf.cod_code))
end

local tabs = function(tab)
  local title = { Text = string.gsub(tab.active_pane.foreground_process_name, "(.*[/\\])(.*)", "%2") }
  local dir = { Text = string.gsub(tab.active_pane.current_working_dir, "(.*[/\\])(.*)", "%2") }
  local process = { Text = get_process(tab) or "" }

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
