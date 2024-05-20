local wezterm = require("wezterm")
local workspaces = require("workspaces")
local colors = require("theme").colors

local addPadding = function(window)
  local window_dims = window:get_dimensions();
  local overrides = window:get_config_overrides() or {}

  local third_width = math.floor(window_dims.pixel_width / 3)
  local third_height = math.floor(window_dims.pixel_height / 3)
  local new_padding = {
    left = third_width,
    right = third_width,
    top = third_height,
    bottom = third_height
  };
  if overrides.window_padding and new_padding.left == overrides.window_padding.left then
    -- padding is same, avoid triggering further changes
    return
  end
  overrides.window_padding = new_padding

  window:set_config_overrides(overrides)
end

local createWorkspace = wezterm.action.PromptInputLine({
  description = "Enter name for new workspace",
  action = wezterm.action_callback(function(window, pane, line)
    if line then
      window:perform_action(
        wezterm.action.SwitchToWorkspace({
          name = line,
        }),
        pane
      )
    end
  end)
})

local renameWorkspace = wezterm.action.PromptInputLine({
  description = "Rename current workspace",
  action = wezterm.action_callback(function(_, _, line)
    if line then
      wezterm.mux.rename_workspace(
        wezterm.mux.get_active_workspace(),
        line
      )
    end
  end)
})

local format_active = function(label, current)
  label = current and " " .. label or label
  local format = {
    { Foreground = { Color = colors.green } },
    { Text = label },
    'ResetAttributes'
  }

  return wezterm.format(format)
end

local format_current = function(label)
  local format = {
    { Foreground = { Color = colors.blue } },
    { Text = "  " .. label .. " " },
    'ResetAttributes'
  }

  return wezterm.format(format)
end

local chooseWorkspace = wezterm.action_callback(function(window, pane, id, label)
  window:set_config_overrides({})

  if not id and not label then
    return wezterm.log_info "Cancelled"
  end

  if id == "1_create" then
    return window:perform_action(createWorkspace, pane)
  end

  if id == "2_rename" then
    return window:perform_action(renameWorkspace, pane)
  end

  window:perform_action(
    wezterm.action.SwitchToWorkspace({
      name = id,
      spawn = workspaces[id]
    }),
    pane
  )
end)

local inputmenu = wezterm.action_callback(function(window, pane)
  addPadding(window)
  local muxspaces = wezterm.mux.get_workspace_names()
  local current_workspace = wezterm.mux.get_active_workspace()
  local choices = {
    {
      label = "Create new workspace",
      id = "1_create"
    },
    {
      label = "Rename workspace",
      id = "2_rename"
    }
  }

  for id, workspace in pairs(workspaces) do
    local isNameInMuxspaces = false
    for _, muxspace in ipairs(muxspaces) do
      if muxspace == id then
        isNameInMuxspaces = true
        break
      end
    end

    if not isNameInMuxspaces then
      table.insert(choices, { id = id, label = workspace.label })
    else
      local is_current_workspace = current_workspace == id
      table.insert(choices, { id = id, label = format_active(workspace.label, is_current_workspace) })
    end
  end

  for _, name in ipairs(muxspaces) do
    local isNameInChoices = false
    for _, choice in ipairs(choices) do
      if choice.id == name then
        isNameInChoices = true
        break
      end
    end

    local label = name == current_workspace and format_current(name) or name
    if not isNameInChoices then
      table.insert(choices, { id = name, label = label })
    end
  end

  table.sort(choices, function(a, b)
    return a.id < b.id
  end)

  window:perform_action(
    wezterm.action.InputSelector({
      action = chooseWorkspace,
      title = "Workspaces",
      choices = choices,
      alphabet = "qwertasdf"
    }),
    pane
  )
end)

return inputmenu
