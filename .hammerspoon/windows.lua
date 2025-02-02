local M = {}
local filledWindows = {}

local gutter = 8
local topBar = 22 + 8

local function hasNotch(screen)
	local screenName = screen:name()
	return screenName:match("Built%-in Liquid Retina XDR Display") or screenName:match("Built%-in Retina Display")
end

local function getTopPadding()
	local screen = hs.screen.mainScreen()

	local topPadding = gutter
	if not hasNotch(screen) then
		topPadding = topPadding + topBar
	end

	return topPadding
end

local function getHeight(frame, rows)
	local topPadding = getTopPadding()
	local height = (frame.h - topPadding - gutter * rows) / rows
	return height
end

local function getWidth(frame, columns)
	local width = (frame.w - gutter * (columns + 1)) / columns

	return width
end

local function getFullVertical(frame)
	local height = getHeight(frame, 1)
	local topPadding = getTopPadding()
	local y = frame.y + topPadding

	return height, y
end

local horizontalBalance = function(windows)
	local screen = hs.screen.mainScreen()
	local frame = screen:frame()

	local numColumns = #windows
	local width = getWidth(frame, numColumns)
	local height, y = getFullVertical(frame)

	for index, window in ipairs(windows) do
		local col = (index - 1) % numColumns
		local x = frame.x + gutter + (col * (width + gutter))

		window:setFrame({
			x = x,
			y = y,
			w = width,
			h = height,
		})
	end
end

local verticalBalance = function(windows)
	local screen = hs.screen.mainScreen()
	local frame = screen:frame()
	local topPadding = getTopPadding()

	local numRows = #windows
	local width = getWidth(frame, 1)
	local height = getHeight(frame, numRows)

	for index, window in ipairs(windows) do
		local row = (index - 1) % numRows
		local y = frame.y + topPadding + (row * (height + gutter))
		local x = frame.x + gutter

		window:setFrame({
			x = x,
			y = y,
			w = width,
			h = height,
		})
	end
end

local split = function(callback)
	local focusedWin = hs.window.focusedWindow()
	local targetWin = focusedWin:otherWindowsSameScreen()

	if #targetWin > 1 then
		local options = {}

		for _, window in ipairs(targetWin) do
			table.insert(options, {
				["text"] = string.format("%s: %s", window:application():name(), window:title()),
				["window"] = window,
			})
		end

		hs.chooser
			.new(function(choice)
				if not choice then
					return
				end

				callback({ focusedWin, choice.window })
			end)
			:choices(options)
			:show()
	else
		callback({ focusedWin, targetWin[1] })
	end
end

M.balanceWindows = function()
	local windows = hs.window.visibleWindows()
	horizontalBalance(windows)
end

M.splitHorizontal = function()
	split(horizontalBalance)
end

M.splitVertical = function()
	split(verticalBalance)
end

M.cycleAllWindowsInSpace = function(forward)
	local windows = hs.window.visibleWindows()

	local currentWindow = hs.window.focusedWindow()
	local currentIndex = 1

	for i, win in ipairs(windows) do
		if win == currentWindow then
			currentIndex = i
			break
		end
	end

	local nextIndex
	if forward then
		nextIndex = currentIndex + 1
		if nextIndex > #windows then
			nextIndex = 1
		end
	else
		nextIndex = currentIndex - 1
		if nextIndex < 1 then
			nextIndex = #windows
		end
	end

	local nextWindow = windows[nextIndex]
	nextWindow:focus()
end

M.leftHalf = function()
	local win = hs.window.focusedWindow()
	local screen = win:screen()
	local frame = screen:frame()

	local height, y = getFullVertical(frame)
	local width = getWidth(frame, 2)

	win:setFrame({
		x = frame.x + gutter,
		y = y,
		w = width,
		h = height,
	})
end

M.rightHalf = function()
	local win = hs.window.focusedWindow()
	local screen = win:screen()
	local frame = screen:frame()

	local height, y = getFullVertical(frame)
	local width = getWidth(frame, 2)

	win:setFrame({
		x = frame.x + (frame.w / 2) + (gutter / 2),
		y = y,
		w = width,
		h = height,
	})
end

M.fillScreen = function()
	local win = hs.window.focusedWindow()
	local screen = win:screen()
	local frame = screen:frame()

	local height, y = getFullVertical(frame)
	local width = getWidth(frame, 1)

	local fillFrame = {
		x = frame.x + gutter,
		y = y,
		w = width,
		h = height,
	}

	win:setFrame(fillFrame)
end

hs.screen.watcher.new(function()
	for _, win in pairs(filledWindows) do
		local screen = win:screen()
		local frame = screen:frame()
		local height, y = getFullVertical(frame)
		local width = getWidth(frame, 1)

		local fillFrame = {
			x = frame.x + gutter,
			y = y,
			w = width,
			h = height,
		}

		win:setFrame(fillFrame)
	end
end)

return M
