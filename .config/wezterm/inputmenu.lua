local wezterm = require("wezterm")
local workspaces = require("workspaces")

local workspaceInput = wezterm.action.PromptInputLine({
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
  action = wezterm.action_callback(function(window, pane, line)
    if line then
      wezterm.mux.rename_workspace(
        wezterm.mux.get_active_workspace(),
        line
      )
    end
  end)
})


local chooseWorkspace = wezterm.action_callback(function(window, pane, id, label)
  if not id and not label then
    return wezterm.log_info "Cancelled"
  end

  if id == "input" then
    return window:perform_action(workspaceInput, pane)
  end

  if id == "rename" then
    return window:perform_action(renameWorkspace, pane)
  end

  window:perform_action(
    wezterm.action.SwitchToWorkspace({
      name = label,
      spawn = workspaces[label]
    }),
    pane
  )
end)

local inputmenu = wezterm.action_callback(function(window, pane)
  local muxspaces = wezterm.mux.get_workspace_names()
  local choices = {
    {
      label = "Create new workspace",
      id = "input"
    },
    {
      label = "Rename workspace",
      id = "rename"
    }
  }

  for name, _ in pairs(workspaces) do
    table.insert(choices, { label = name })
  end

  for _, name in ipairs(muxspaces) do
    table.insert(choices, { label = name })
  end

  window:perform_action(
    wezterm.action.InputSelector({
      action = chooseWorkspace,
      title = "Workspaces",
      choices = choices,
    }),
    pane
  )
end)

return inputmenu
