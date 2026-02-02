local M = {}
local filledWindows = {}
local gutter = 8

-- Define app lists for each space by index (1, 2, 3, etc.)
-- Configure which apps to cycle through on each space
local spaceAppLists = {
	{ "Arc", "Ghostty" },
	{ "MongoDB Compass", "Table Plus", "Linear" },
	{ "Postman" },
}

-- Default app list if no specific list is configured for a space
local defaultAppList = {
	"All Gravy",
	"Spotify",
	"Slack",
	"Telegram",
	"Finder",
	"Spark Desktop",
	"1Password",
	"Docker Desktop",
}

-- Track the current index for each space
local currentAppIndex = {}

-- Helper function to get space index from space ID
local function getSpaceIndex(spaceId)
	local allSpaces = hs.spaces.allSpaces()
	local screens = hs.screen.allScreens()

	-- Iterate through screens and their spaces
	for _, screen in ipairs(screens) do
		local uuid = screen:getUUID()
		local spaces = allSpaces[uuid]
		if spaces then
			for index, id in ipairs(spaces) do
				if id == spaceId then
					return index
				end
			end
		end
	end

	return 1 -- Default to space 1 if not found
end

local function getAppListForSpace(spaceIndex)
	return spaceAppLists[spaceIndex] or defaultAppList
end

local function getCurrentAppIndex(spaceIndex)
	return currentAppIndex[spaceIndex] or 1
end

local function setCurrentAppIndex(spaceIndex, index)
	currentAppIndex[spaceIndex] = index
end

-- Cycle through apps in the configured list for the current space
M.cycleAppsInSpace = function(forward)
	local spaceId = hs.spaces.focusedSpace()
	local spaceIndex = getSpaceIndex(spaceId)
	local appList = getAppListForSpace(spaceIndex)

	if #appList == 0 then
		return
	end

	local currentIndex = getCurrentAppIndex(spaceIndex)
	local startIndex = currentIndex
	local nextIndex = currentIndex
	local attempts = 0
	local maxAttempts = #appList

	-- Keep cycling until we find a running app or we've checked all apps
	repeat
		if forward then
			nextIndex = nextIndex + 1
			if nextIndex > #appList then
				nextIndex = 1
			end
		else
			nextIndex = nextIndex - 1
			if nextIndex < 1 then
				nextIndex = #appList
			end
		end

		local appName = appList[nextIndex]
		local runningApp = hs.application.get(appName)

		-- If app is running, focus it and update index
		if runningApp then
			runningApp:activate()
			setCurrentAppIndex(spaceIndex, nextIndex)
			return
		end

		attempts = attempts + 1
	until attempts >= maxAttempts

	-- If no running apps found, show notification
	hs.notify
		.new({
			title = "App Cycling",
			informativeText = "No apps from the list are currently running",
		})
		:send()
end

local function getFrameDimensions(frame, numColumns, numRows)
	local width = (frame.w - gutter * (numColumns - 1)) / numColumns
	local height = (frame.h - gutter * (numRows - 1)) / numRows
	return width, height
end

local function createFrame(x, y, w, h)
	return { x = x, y = y, w = w, h = h }
end

local function createFullscreenFrame(frame)
	return createFrame(frame.x, frame.y, frame.w, frame.h)
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
			local x = frame.x + (col * (width + gutter))

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
		window:setFrame(createFrame(frame.x, frame.y + (row * (height + gutter)), width, height))
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

local function isPipWindow(win)
	local title = win:title()
	return title == nil or title == "" or title == "Picture-in-Picture" or title == "PiP"
end

M.cycleAllWindowsInSpace = function(forward)
	local currentSpace = hs.spaces.focusedSpace()
	local currentWindow = hs.window.focusedWindow()

	-- If no window is focused, just focus the first available window
	if not currentWindow then
		local firstWin = hs.window.frontmostWindow()
		if firstWin then
			firstWin:focus()
		end
		return
	end

	-- Get all windows and filter by current space
	local allWindows = hs.window.allWindows()
	local spaceWindows = {}

	for _, win in ipairs(allWindows) do
		if win:isVisible() and win:isStandard() and not isPipWindow(win) then
			local winSpaces = hs.spaces.windowSpaces(win)
			if winSpaces then
				for _, spaceId in ipairs(winSpaces) do
					if spaceId == currentSpace then
						table.insert(spaceWindows, win)
						break
					end
				end
			end
		end
	end

	if #spaceWindows <= 1 then
		return
	end

	-- Sort by window ID for consistent ordering
	table.sort(spaceWindows, function(a, b)
		return a:id() < b:id()
	end)

	local currentIndex = 1
	for i, win in ipairs(spaceWindows) do
		if win:id() == currentWindow:id() then
			currentIndex = i
			break
		end
	end

	-- Calculate next index
	local nextIndex
	if forward then
		nextIndex = currentIndex + 1
		if nextIndex > #spaceWindows then
			nextIndex = 1
		end
	else
		nextIndex = currentIndex - 1
		if nextIndex < 1 then
			nextIndex = #spaceWindows
		end
	end

	spaceWindows[nextIndex]:focus()
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
