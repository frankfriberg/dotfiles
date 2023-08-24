local wezterm = require("wezterm")
local colors = require("colors")

local space = { Text = " " }
local spacer = { Text = " · " }

local function merge_table(table1, table2)
  for _, value in ipairs(table2) do
    table1[#table1 + 1] = value
  end
  return table1
end

local rightStatus = function(window)
  local date = { Text = wezterm.strftime("%b %-d %H:%M:%S ") }
  local workspace = { Text = wezterm.mux.get_active_workspace() }
  local status = {}
  if window:leader_is_active() then
    status = {
      { Foreground = { Color = colors.bg0 } },
      { Background = { Color = colors.green } },
      { Text = " Leader " },
      "ResetAttributes",
    }
  end

  if window:active_key_table() then
    local table = window:active_key_table()
    status = {
      { Foreground = { Color = colors.bg0 } },
      { Background = { Color = colors.fg } },
      { Text = " Table: " .. table:gsub("^%l", string.upper) .. " " },
      "ResetAttributes",
    }
  end

  window:set_right_status(wezterm.format(merge_table(status, {
    space,
    workspace,
    spacer,
    date,
  })))
end

return rightStatus
