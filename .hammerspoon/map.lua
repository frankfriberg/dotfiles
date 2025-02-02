local M = {}

M.hyper = function(key, callback)
	return hs.hotkey.bind({ "ctrl", "shift", "alt", "cmd" }, key, callback)
end

M.meh = function(key, callback)
	return hs.hotkey.bind({ "ctrl", "shift", "alt" }, key, callback)
end

return M
