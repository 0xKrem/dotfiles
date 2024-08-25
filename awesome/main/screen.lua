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

local tasklist_buttons = gears.table.join(
	awful.button({}, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			c:emit_signal("request::activate", "tasklist", { raise = true })
		end
	end),
	awful.button({}, 3, function()
		awful.menu.client_list({ theme = { width = 250 } })
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
		from = { 1, 16 },
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
			shape = rounded(50),
			font = "DejaVuSansM Nerd Font Propo 16",
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
			shape = rounded(4),
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
			mytextclock,
			s.mylayoutbox,
		},
	})
end
return M
