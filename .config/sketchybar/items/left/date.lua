local colors = require("colors")

local cal = sbar.add("item", "widgets.date.item", {
	icon = {
		string = "􀉉",
		padding_right = 5,
		padding_left = 5,
	},
	label = {
		padding_right = 5,
	},
	position = "left",
	update_freq = 5,
})

local function format_events(input)
	local events = {}

	for line in input:gmatch("[^\r\n]+") do
		local title, times = line:match("^(.-)|(.+)$")
		if title and times then
			local start_time, end_time = times:match("([%d%.]+)%s*-%s*([%d%.]+)")
			if start_time and end_time then
				local event = {
					title = title,
					start_at = start_time,
					end_at = end_time,
				}

				table.insert(events, event)
			end
		end
	end

	return events
end

local function parse_time(time_string)
	local hour, minute = time_string:match("(%d+).(%d+)")
	if hour and minute then
		local current_date = os.date("*t") -- Get today's date
		return os.time({
			year = current_date.year,
			month = current_date.month,
			day = current_date.day,
			hour = tonumber(hour),
			min = tonumber(minute),
			sec = 0,
		})
	end
	return nil
end

cal:subscribe({ "forced", "routine", "system_woke" }, function()
	sbar.exec(
		"icalBuddy -n -nc -b '' -iep 'title,datetime' -po 'title,datetime' -ps '/|/' -ea eventsToday",
		function(result)
			local events = format_events(result)
			local palette = colors.currentPalette

			local event_label = ""
			local is_now = false
			local is_soon = false

			if events[1] and events[1].title then
				local start_epoch = parse_time(events[1].start_at)
				local end_epoch = parse_time(events[1].end_at)
				local now_epoch = os.time()

				if start_epoch < now_epoch and now_epoch < end_epoch then
					is_now = true
				end

				if not is_now and start_epoch - now_epoch <= 600 and start_epoch - now_epoch > 0 then
					is_soon = true
				end

				event_label = string.format(
					": %s %s %s",
					events[1].title,
					is_now and "to" or "from",
					is_now and events[1].end_at or events[1].start_at
				)
			end

			local date = string.format("%s %s", "􀉉", os.date("%a %d %b"))

			sbar.animate("tanh", 10, function()
				cal:set({
					background = {
						color = ((is_now and palette.blue) or (is_soon and palette.peach)),
					},
					icon = {
						string = date,
					},
					label = {
						string = event_label,
					},
				})
			end)
		end
	)
end)

return cal.name
