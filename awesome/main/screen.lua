local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

local M = {}

-- TODO: to move !!!
modkey = "Mod1"

mytextclock = wibox.widget.textclock()

local taglist_buttons = gears.table.join(
	awful.button({}, 1, function(t)
		t:view_only()
	end),
	awful.button({ modkey }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end),
	awful.button({}, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end),
	awful.button({}, 4, function(t)
		awful.tag.viewnext(t.screen)
	end),
	awful.button({}, 5, function(t)
		awful.tag.viewprev(t.screen)
	end)
)

-- task rightclick menu
local tasklist_buttons = gears.table.join(
	awful.button({}, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			c:emit_signal("request::activate", "tasklist", { raise = true })
		end
	end),
	awful.button({}, 3, function()
		awful.menu.client_list({ theme = { width = 150 } })
	end),
	awful.button({}, 4, function()
		awful.client.focus.byidx(1)
	end),
	awful.button({}, 5, function()
		awful.client.focus.byidx(-1)
	end)
)

function M.set_wallpaper(s)
	-- Wallpaper
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, false)
	end
end

function M.setup_screen(s)
	-- Wallpaper
	M.set_wallpaper(s)

	-- Each screen has its own tag table.
	awful.tag(tag_icons, s, awful.layout.layouts[1])
	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt()
	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(gears.table.join(
		awful.button({}, 1, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 3, function()
			awful.layout.inc(-1)
		end),
		awful.button({}, 4, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 5, function()
			awful.layout.inc(-1)
		end)
	))
	local gradient_bg = gears.color.create_pattern({
		type = "linear",
		from = { 50, -50 },
		to = { 50, 50 },
		stops = { { 0, "#343d5e" }, { 1, "#1C1C2E" } },
	})

	local gradient_focus = gears.color.create_pattern({
		type = "linear",
		from = { 1, 20 },
		to = { 1, 28 },
		stops = { { 1, "#94b6ff" }, { 0, "#11121a" } },
	})

	local gradient_urgent = gears.color.create_pattern({
		type = "linear",
		from = { 1, 15 },
		to = { 1, 28 },
		stops = { { 1, "#b294f2" }, { 0, "#22283c" } },
	})

	local function rounded(radius)
		return function(cr, width, height)
			gears.shape.rounded_rect(cr, width, height, radius)
		end
	end

	s.mytaglist = awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = taglist_buttons,
		style = {
			fg_focus = "#FFFFFF",
			bg_focus = gradient_focus,

			fg_occupied = "#FFFFFF",
			fg_empty = "#FFFFFF",
			bg_occupied = gradient_bg,
			bg_empty = gradient_bg,

			bg_urgent = gradient_urgent,
			shape = rounded(15),
			font = "DejaVuSansM Nerd Font Propo 17",
		},
		layout = {
			layout = wibox.layout.fixed.horizontal,
		},
		widget_template = {
			{
				{
					{
						id = "text_role",
						widget = wibox.widget.textbox,
					},
					layout = wibox.layout.fixed.horizontal,
				},
				left = 13,
				right = 13,
				widget = wibox.container.margin,
			},
			id = "background_role",
			widget = wibox.container.background,

			create_callback = function(self, t)
				self:connect_signal("mouse::enter", function()
					self.backup = self.bg
					if not t.selected then
						self.bg = "#3f4263"
					end
				end)
				self:connect_signal("mouse::leave", function()
					-- if self.backup then
					if t.selected then
						self.bg = gradient_focus
					else
						self.bg = self.backup
					end
					-- end
				end)
			end,
		},
	})

	-- Create a tasklist widget
	s.mytasklist = awful.widget.tasklist({
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_buttons,
		style = {
			bg_focus = gradient_focus,
			fg_focus = "#FFFFFF",

			bg_normal = gradient_bg,
			fg_normal = "#FFFFFF",
			bg_urgent = gradient_urgent,
			shape = rounded(3),
		},
		widget_template = {
			{
				{
					{
						{
							id = "icon_role",
							widget = wibox.widget.imagebox,
						},
						widget = wibox.container.margin,
					},
					{
						id = "text_role",
						widget = wibox.widget.textbox,
					},
					layout = wibox.layout.fixed.horizontal,
					spacing = 10,
				},
				left = 10,
				right = 10,
				widget = wibox.container.margin,
			},
			id = "background_role",
			widget = wibox.container.background,
			forced_width = 200,
		},
	})
	--- Define the font size and button text
	local button_text = "" -- Example icon, adjust as needed
	local font_name = "DejaVuSansM Nerd Font Propo 16"

	-- Create a text widget with the specified font
	local logoff_button_text = wibox.widget.textbox(button_text)
	logoff_button_text.font = font_name

	-- Create a container for padding (left and right padding)
	local padding_container = wibox.container.margin()
	padding_container:set_widget(logoff_button_text)
	padding_container:set_left(10) -- Set left padding (adjust as needed)
	padding_container:set_right(10) -- Set right padding (adjust as needed)

	-- Create a background container for styling with rounded corners
	local logoff_button = wibox.container.background()
	logoff_button:set_widget(padding_container)
	logoff_button:set_bg(gradient_bg) -- Default background color
	logoff_button:set_fg(gears.color("#FFFFFF")) -- Default text color
	logoff_button.shape = function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, 10) -- Rounded corners with radius 10
	end

	-- clock
	local time_format = "󰥔 %H:%M"

	-- Create a custom clock widget
	local my_clock = wibox.widget.textclock(time_format)

	-- Optionally, apply some padding or styling if needed
	local clock_widget = wibox.container.margin(my_clock, 10, 10, 5, 5) -- Adjust padding as needed

	-- Add a click action to the button
	logoff_button:buttons(gears.table.join(awful.button({}, 1, function()
		-- Change the background color on click
		logoff_button:set_bg(gradient_focus)

		-- Execute the command
		awful.spawn("xfce4-session-logout")
	end)))

	--clock
	-- Define the custom time format with an icon and the time
	local time_format = "󰥔 %H:%M"

	-- Create a custom clock widget with the desired format
	local my_clock = wibox.widget.textclock(time_format)

	-- Set the desired font and color using a widget container
	local clock_widget = wibox.container.background()
	clock_widget:set_widget(my_clock)
	clock_widget:set_fg(gears.color("#FFFFFF")) -- Set text color to white
	clock_widget:set_bg(gears.color("#00000000")) -- Optional: Transparent background, if needed
	my_clock.font = "DejaVuSansM Nerd Font Propo 14" -- Set the desired font

	-- Apply padding if necessary
	local padded_clock = wibox.container.margin(clock_widget, 10, 10, 5, 5) -- Adjust padding as needed

	-- layoutbox
	local padded_layoutbox = wibox.container.margin(s.mylayoutbox)
	padded_layoutbox:set_top(3) -- Add 5 pixels of padding at the top (adjust as needed)
	padded_layoutbox:set_bottom(3)

	--bluetooth
	-- Define the Bluetooth widget
	local bluetooth_widget = wibox.widget({
		text = "Bluetooth",
		align = "center",
		valign = "center",
		widget = wibox.widget.textbox,
	})

	-- Style the widget
	local bluetooth_button = wibox.container.background()
	bluetooth_button:set_widget(bluetooth_widget)
	bluetooth_button:set_bg(gears.color("#0000ff")) -- Set background color
	bluetooth_button:set_fg(gears.color("#ffffff")) -- Set text color

	-- Variable to store the spawned blueman-manager client
	local blueman_client = nil

	-- Function to toggle blueman-manager
	local function toggle_bluetooth_manager()
		if blueman_client and blueman_client.valid then
			-- Check if the client is minimized
			if blueman_client.minimized then
				blueman_client:emit_signal("request::activate", "mouse_click", { raise = true })
				return
			end

			-- Close the blueman-manager window
			blueman_client:kill()
			blueman_client = nil
		else
			-- Spawn blueman-manager and store the client
			awful.spawn.with_shell("blueman-manager", function(c)
				blueman_client = c
				-- Set rules for placement and other properties
				c:connect_signal("manage", function()
					c:connect_signal("focus", function()
						if not c:isvisible() then
							c:kill()
						end
					end)
					c:connect_signal("unfocus", function()
						gears.timer.start_new(0.5, function()
							if not c:isvisible() then
								c:kill()
							end
						end)
					end)
				end)
			end)
		end
	end

	-- Set up the button action
	bluetooth_button:buttons(gears.table.join(awful.button({}, 1, toggle_bluetooth_manager)))
	--[[---------
|			|
|	WIBOX	|
|			|
-----------]]
	-- Create the wibox
	s.mywibox = awful.wibar({
		position = "top",
		screen = s,
		visible = true,
		height = 28,
	})

	-- wibox background color
	s.mywibox.bg = gradient_bg
	-- Add widgets to the wibox
	s.mywibox:setup({
		layout = wibox.layout.align.horizontal,
		{ -- Left widgets
			layout = wibox.layout.fixed.horizontal,
			wibox.container.margin(s.mytaglist, 6, 6, 0, 0),
			wibox.container.constraint(s.mytasklist, "max", (s.geometry.width - 650)),
		},
		nil, --removed the center section
		{ -- Right widgets
			layout = wibox.layout.fixed.horizontal,
			wibox.widget.systray(),
			bluetooth_button,
			padded_clock,
			padded_layoutbox,
			logoff_button,
		},
	})
end
return M
