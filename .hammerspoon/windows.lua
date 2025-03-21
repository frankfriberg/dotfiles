local M = {}
local filledWindows = {}
local gutter = 8

local function getFrameDimensions(frame, numColumns, numRows)
	local width = (frame.w - gutter * (numColumns + 1)) / numColumns
	local height = (frame.h - gutter * (numRows + 1)) / numRows
	return width, height
end

local function createFrame(x, y, w, h)
	return { x = x, y = y, w = w, h = h }
end

local function createFullscreenFrame(frame)
	return createFrame(frame.x + gutter, frame.y, frame.w - (gutter * 2), frame.h - gutter)
end

local function areWindowsInLayout(windows, checkFn)
	for _, window in ipairs(windows) do
		if not checkFn(window) then
			return false
		end
	end
	return true
end

local function horizontalBalance(windows)
	local screen = hs.screen.mainScreen()
	local frame = screen:frame()
	local numColumns = #windows

	local width, height = getFrameDimensions(frame, numColumns, 1)

	local function isHorizontallyBalanced(window)
		local wf = window:frame()
		return math.abs(wf.w - width) < 2 and math.abs(wf.h - height) < 2
	end

	if areWindowsInLayout(windows, isHorizontallyBalanced) then
		local fullFrame = createFullscreenFrame(frame)
		for _, window in ipairs(windows) do
			window:setFrame(fullFrame)
		end
	else
		for index, window in ipairs(windows) do
			local col = (index - 1) % numColumns
			local x = frame.x + gutter + (col * (width + gutter))

			window:setFrame(createFrame(x, frame.y, width, height))
		end
	end
end

local function verticalBalance(windows)
	local screen = hs.screen.mainScreen()
	local frame = screen:frame()

	local numRows = #windows
	-- Use getFrameDimensions to calculate width and height
	local width, height = getFrameDimensions(frame, 1, numRows)

	for index, window in ipairs(windows) do
		local row = (index - 1) % numRows
		window:setFrame(createFrame(frame.x + gutter, frame.y + gutter + (row * (height + gutter)), width, height))
	end
end

local function split(callback)
	local focusedWin = hs.window.focusedWindow()
	local targetWin = focusedWin:otherWindowsSameScreen()

	if #targetWin > 1 then
		local options = {}

		for _, window in ipairs(targetWin) do
			table.insert(options, {
				text = string.format("%s: %s", window:application():name(), window:title()),
				window = window,
			})
		end

		hs.chooser
			.new(function(choice)
				if choice then
					callback({ focusedWin, choice.window })
				end
			end)
			:choices(options)
			:show()
	else
		callback({ focusedWin, targetWin[1] })
	end
end

local function rotateWindows(windows)
	if #windows <= 1 then
		return
	end

	local frames = {}
	for _, win in ipairs(windows) do
		table.insert(frames, win:frame())
	end

	for i, win in ipairs(windows) do
		local nextIndex = i % #windows + 1
		win:setFrame(frames[nextIndex])
	end
end

M.balanceWindows = function()
	horizontalBalance(hs.window.visibleWindows())
end

M.splitHorizontal = function()
	split(horizontalBalance)
end

M.splitVertical = function()
	split(verticalBalance)
end

M.rotateWindows = function()
	local windows = hs.window.visibleWindows()
	rotateWindows(windows)
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

	local nextIndex = forward and currentIndex + 1 or currentIndex - 1
	if nextIndex > #windows then
		nextIndex = 1
	end
	if nextIndex < 1 then
		nextIndex = #windows
	end

	windows[nextIndex]:focus()
end

M.leftHalf = function()
	local win = hs.window.focusedWindow()
	local screen = win:screen()
	local frame = screen:frame()

	-- Use getFrameDimensions to calculate width
	local width, height = getFrameDimensions(frame, 2, 1)

	win:setFrame(createFrame(frame.x + gutter, frame.y + gutter, width, height))
end

M.rightHalf = function()
	local win = hs.window.focusedWindow()
	local screen = win:screen()
	local frame = screen:frame()

	-- Use getFrameDimensions to calculate width
	local width, height = getFrameDimensions(frame, 2, 1)

	win:setFrame(createFrame(frame.x + width + (gutter * 2), frame.y + gutter, width, height))
end

M.fillScreen = function()
	local win = hs.window.focusedWindow()
	win:setFrame(createFullscreenFrame(win:screen():frame()))
	-- Track filled window if needed
	filledWindows[win:id()] = win
end

-- Initialize the screen watcher
local screenWatcher = hs.screen.watcher.new(function()
	for id, win in pairs(filledWindows) do
		if win:isVisible() then
			win:setFrame(createFullscreenFrame(win:screen():frame()))
		else
			filledWindows[id] = nil -- Clean up windows that are no longer visible
		end
	end
end)
screenWatcher:start()

return M
