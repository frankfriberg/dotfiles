local M = {}

local exec = sbar.exec

local function parse_string_to_table(s)
	local result = {}
	for line in s:gmatch("([^\n]+)") do
		table.insert(result, line)
	end

	return result
end

local function aero_cmd(command, list)
	print("running aero cmd", command)
	local cmd = string.format("aerospace %s", command)
	local handle = io.popen(cmd)
	local result = handle:read("*a")
	handle:close()
	print("done with aero cmd", command)
	if list then
		return parse_string_to_table(result)
	else
		return result
	end
end

local function aero_wincmd(command, list)
	return aero_cmd(string.format("list-windows %s %s", command, "--format %{app-name}"), list)
end

M.workspaces = {
	current = function()
		return aero_cmd("list-workspaces --focused")
	end,
	all = function(callback)
		return exec("aerospace list-workspaces --all", function(result)
			callback(parse_string_to_table(result))
		end)
	end,
}

M.windows = {
	current = function()
		return aero_wincmd("--focused")
	end,
	workspace = function(workspace, callback)
		return exec(
			string.format("aerospace list-windows --workspace %s %s", workspace, "--format %{app-name}"),
			function(result)
				callback(parse_string_to_table(result))
			end
		)
		-- return aero_wincmd(string.format("--workspace %s", workspace), true)
	end,
	all = function()
		return aero_wincmd("--all", true)
	end,
}

return M
