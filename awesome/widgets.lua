local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

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
