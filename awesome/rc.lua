-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors,
	})
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		-- Make sure we don't go into an endless error loop
		if in_error then
			return
		end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = tostring(err),
		})
		in_error = false
	end)
end
-- }}}

-- Themes define colours, icons, font and wallpapers.
beautiful.init("~/.config/awesome/theme/theme.lua")

-- Launch at startup
os.execute("picom -b")

--[[------------
|				|
|	MY APPS		|
|				|
---------------]]
launcher = "rofi -show drun"
terminal = "alacritty"
browser = "firefox"
editor = os.getenv("EDITOR") or "vi"
editor_cmd = terminal .. " -e " .. editor
obsidian = "flatpak run md.obsidian.Obsidian"
discord = "flatpak run com.discordapp.Discord"
files = "thunar"
browser = "firefox"
txteditor = terminal .. " -e nvim"
settings = "xfce4-settings-manager"

tag_icons = {}
tag_icons[1] = "󰖟"
tag_icons[2] = ""
tag_icons[3] = "󱞁"
tag_icons[4] = "󰍹"
tag_icons[5] = "󱓷"
tag_icons[6] = "󰝰"
tag_icons[7] = "󰭻"
tag_icons[8] = "󰝚"

-- Modkey
modkey = "Mod1"

-- Windows gaps
beautiful.useless_gap = 7

--[[---------------
|			      |
|	MY LAYOUTS    |
|			      |
-----------------]]

awful.layout.layouts = {
	awful.layout.suit.tile,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.spiral.dwindle,
	awful.layout.suit.floating,
}

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

local function set_wallpaper(s)
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

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
	-- Wallpaper
	set_wallpaper(s)

	-- Each screen has its own tag table.
	awful.tag(tag_icons, s, awful.layout.layouts[1])
end)

-- {{{ Key bindings
globalkeys = gears.table.join(
	--[[------------------
	|					 |
	|	XFCE BINDINGS    |
	|					 |
	--------------------]]
	--lock screen
	awful.key(
		{ "Mod4" }, --Modifier
		"l", --Key
		function() --Action
			awful.spawn("xfce4-screensaver-command -l")
		end,
		{ description = "lock screen", group = "Multimedia" }
	),
	--Display settings
	awful.key(
		{ "Mod4" }, --Modifier
		"p", --Key
		function() --Action
			awful.spawn("xfce4-display-settings -m")
		end,
		{ description = "display settings", group = "Multimedia" }
	),
	--[[--------------------
	|					   |
	|	WINDOW BINDINGS    |
	|					   |
	----------------------]]
	--show help
	awful.key(
		{ modkey }, -- Modifier
		"ù", -- Key
		hotkeys_popup.show_help, --Action
		{ description = "show help", group = "awesome" }
	),
	--view previous
	awful.key(
		{ modkey }, -- Modifier
		"Left", -- Key
		awful.tag.viewprev, --Action
		{ description = "view previous", group = "tag" }
	),
	--view next
	awful.key(
		{ modkey }, -- Modifier
		"Right", -- Key
		awful.tag.viewnext, --Action
		{ description = "view next", group = "tag" }
	),
	--go back
	awful.key(
		{ modkey }, -- Modifier
		"Escape", -- Key
		awful.tag.history.restore, --Action
		{ description = "go back", group = "tag" }
	),

	--focus next by index
	awful.key(
		{ modkey }, --Modifier
		"j", --Key
		function() --Action
			awful.client.focus.byidx(1)
		end,
		{ description = "focus next by index", group = "client" }
	),
	--focus previous by index
	awful.key(
		{ modkey }, --Modifier
		"k", --Key
		function() --Action
			awful.client.focus.byidx(-1)
		end,
		{ description = "focus previous by index", group = "client" }
	),
	--
	awful.key(
		{
			modkey, --Modiswap with next client by indexfier
			"Shift",
		}, --Key
		"j",
		function() --Action
			awful.client.swap.byidx(1)
		end,
		{ description = "swap with next client by index", group = "client" }
	),
	awful.key(
		{
			modkey, --Modifier
			"Shift",
		}, --Key
		"k",
		function() --Action
			awful.client.swap.byidx(-1)
		end,
		{ description = "swap with previous client by index", group = "client" }
	),

	awful.key(
		{
			modkey, --Modifier
			"Control",
		}, --Key
		"j",
		function() --Action
			awful.screen.focus_relative(1)
		end,
		{ description = "focus the next screen", group = "screen" }
	),
	awful.key(
		{
			modkey, --Modifier
			"Control",
		}, --Key
		"k",
		function() --Action
			awful.screen.focus_relative(-1)
		end,
		{ description = "focus the previous screen", group = "screen" }
	),
	--jump to urgent client
	awful.key(
		{ modkey }, -- Modifier
		"u", -- Key
		awful.client.urgent.jumpto, --Action
		{ description = "jump to urgent client", group = "client" }
	),
	awful.key({ modkey }, "Tab", function()
		awful.client.focus.history.previous()
		if client.focus then
			client.focus:raise()
		end
	end, { description = "go back", group = "client" }),

	--Restart Awesome
	awful.key(
		{
			modkey, -- Modifier
			"Control",
		}, -- Key
		"r", --Action
		awesome.restart,
		{ description = "reload awesome", group = "awesome" }
	),

	--Resize window
	awful.key(
		{ modkey }, --Modifier
		"l", --Key
		function() --Action
			awful.tag.incmwfact(0.035)
		end,
		{ description = "increase master width factor", group = "layout" }
	),
	awful.key(
		{ modkey }, --Modifier
		"h", --Key
		function() --Action
			awful.tag.incmwfact(-0.035)
		end,
		{ description = "decrease master width factor", group = "layout" }
	),

	--Change layout
	awful.key(
		{
			modkey, --Modifier
			"Shift",
		}, --Key
		"h",
		function() --Action
			awful.tag.incnmaster(1, nil, true)
		end,
		{ description = "increase the number of master clients", group = "layout" }
	),
	awful.key(
		{
			modkey, --Modifier
			"Shift",
		}, --Key
		"l",
		function() --Action
			awful.tag.incnmaster(-1, nil, true)
		end,
		{ description = "decrease the number of master clients", group = "layout" }
	),

	awful.key(
		{ modkey }, --Modifier
		"space", --Key
		function() --Action
			awful.layout.inc(1)
		end,
		{ description = "select next", group = "layout" }
	),
	awful.key(
		{
			modkey, --Modifier
			"Shift",
		}, --Key
		"space",
		function() --Action
			awful.layout.inc(-1)
		end,
		{ description = "select previous", group = "layout" }
	),

	awful.key({ modkey, "Control" }, "n", function()
		local c = awful.client.restore()
		-- Focus restored client
		if c then
			c:emit_signal("request::activate", "key.unminimize", { raise = true })
		end
	end, { description = "restore minimized", group = "client" }),
	--[[-----------------
	|					|
	|	APP BINDINGS	|
	|					|
	-------------------]]
	--Terminal
	awful.key(
		{ modkey }, --Modifier
		"Return", --Key
		function() --Action
			awful.spawn(terminal)
		end,
		{ description = "open a terminal", group = "launcher" }
	),

	--Rofi
	awful.key(
		{ modkey }, --Modifier
		"a", --Key
		function() --Action
			awful.spawn(launcher)
		end,
		{ description = "rofi", group = "launcher" }
	),

	--Obsidian
	awful.key(
		{ modkey }, --Modifier
		"o", --Key
		function() --Action
			awful.spawn(obsidian)
		end,
		{ description = "open Obsidian", group = "launcher" }
	),

	--Discord
	awful.key(
		{ modkey }, --Modifier
		"c", --Key
		function() --Action
			awful.spawn(discord)
		end,
		{ description = "open Discord", group = "launcher" }
	),

	--File explorer
	awful.key(
		{ modkey }, --Modifier
		"t", --Key
		function() --Action
			awful.spawn(files)
		end,
		{ description = "open file explorer", group = "launcher" }
	),

	--Browser
	awful.key(
		{ modkey }, --Modifier
		"b", --Key
		function() --Action
			awful.spawn(browser)
		end,
		{ description = "open browser", group = "launcher" }
	),

	--Vim
	awful.key(
		{ modkey }, --Modifier
		"v", --Key
		function() --Action
			awful.spawn(txteditor)
		end,
		{ description = "open txteditor", group = "launcher" }
	),

	--Settings
	awful.key(
		{ modkey }, --Modifier
		"p", --Key
		function() --Action
			awful.spawn(settings)
		end,
		{ description = "open a settings", group = "launcher" }
	),

	--Print screen
	awful.key(
		{}, --Modifier
		"Print", --Key
		function() --Action
			awful.spawn("flameshot gui")
		end,
		{ description = "Print screen", group = "Multimedia" }
	),
	awful.key(
		{ modkey }, --Modifier
		"s", --Key
		function() --Action
			awful.spawn("flameshot gui")
		end,
		{ description = "Print screen", group = "Multimedia" }
	)
)

clientkeys = gears.table.join(
	awful.key({ modkey }, "f", function(c)
		c.fullscreen = not c.fullscreen
		c:raise()
	end, { description = "toggle fullscreen", group = "client" }),
	awful.key({ modkey, "Shift" }, "q", function(c)
		c:kill()
	end, { description = "close", group = "client" }),
	awful.key(
		{ modkey, "Control" },
		"space",
		awful.client.floating.toggle,
		{ description = "toggle floating", group = "client" }
	),
	awful.key({ modkey, "Control" }, "Return", function(c)
		c:swap(awful.client.getmaster())
	end, { description = "move to master", group = "client" }),

	--awful.key({ modkey }, "o", function(c)
	--c:move_to_screen()
	--end, { description = "move to screen", group = "client" }),

	--awful.key({ modkey }, "t", function(c)
	--c.ontop = not c.ontop
	--end, { description = "toggle keep on top", group = "client" }),

	awful.key({ modkey }, "n", function(c)
		c.minimized = true
	end, { description = "minimize", group = "client" }),

	awful.key({ modkey }, "m", function(c)
		c.maximized = not c.maximized
		c:raise()
	end, { description = "(un)maximize", group = "client" })
)

local max_workspace = 9
local tag_keys = { "&", "é", '"', "'", "(", "-", "è", "_", "ç" }
for i = 1, max_workspace do
	globalkeys = gears.table.join(
		globalkeys,
		--
		-- View tag only.
		awful.key({ modkey }, tag_keys[i], function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				tag:view_only()
			end
		end, { description = "view tag #" .. i, group = "tag" }),

		-- Toggle tag display.
		awful.key({ modkey, "Control" }, tag_keys[i], function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end, { description = "toggle tag #" .. i, group = "tag" }),

		-- Move client to tag.
		awful.key({ modkey, "Shift" }, tag_keys[i], function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end, { description = "move focused client to tag #" .. i, group = "tag" }),

		-- Toggle tag on focused client.
		awful.key({ modkey, "Control", "Shift" }, tag_keys[i], function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end, { description = "toggle focused client on tag #" .. i, group = "tag" })
	)
end

clientbuttons = gears.table.join(

	awful.button({}, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
	end),

	awful.button({ modkey }, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.move(c)
	end),

	awful.button({ modkey }, 3, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.resize(c)
	end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
		},
	},

	-- Floating clients.
	{
		rule_any = {
			instance = {
				"DTA", -- Firefox addon DownThemAll.
				"copyq", -- Includes session name in class.
				"pinentry",
			},
			class = {
				"Arandr",
				"Gpick",
				"Kruler",
				"MessageWin", -- kalarm.
				"Sxiv",
				"Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
				"Wpa_gui",
				"veromix",
				"xtightvncviewer",
				"Galculator",
			},

			-- Note that the name property shown in xprop might be set slightly after creation of the client
			-- and the name shown there might not match defined rules here.
			name = {
				"Event Tester", -- xev.
			},
			role = {
				"AlarmWindow", -- Thunderbird's calendar.
				"ConfigManager", -- Thunderbird's about:config.
				"pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
			},
		},
		properties = { floating = true },
	},

	-- Add titlebars to normal clients and dialogs
	{ rule_any = { type = { "normal", "dialog" } }, properties = { titlebars_enabled = false } },

	--#########################################################
	-- Window Rules
	{ rule = { class = "obsidian" }, properties = { screen = 1, tag = tag_icons[3] } },
	{ rule = { class = "virt-manager" }, properties = { screen = 1, tag = tag_icons[4] } },
	{ rule = { class = "Evince" }, properties = { screen = 1, tag = tag_icons[5] } },
	{ rule = { class = "Thunar" }, properties = { screen = 1, tag = tag_icons[6] } },
	{ rule = { class = "discord" }, properties = { screen = 1, tag = tag_icons[7] } },
	{ rule = { class = "easyeffects" }, properties = { screen = 1, tag = tag_icons[8] } },

	-- show bluetooth connection window under the tray
	{
		rule = { class = "Blueman-manager" },
		properties = {
			floating = true,
			screen = awful.screen.focused(),
			placement = awful.placement.top_right,
			border_width = 0,
			ontop = true,
		},
	},
	-- xfce panel no borders
	{ rule = { class = "Xfce4-panel" }, properties = { border_width = 0 } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	-- if not awesome.startup then awful.client.setslave(c) end

	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
	-- buttons for the titlebar
	local buttons = gears.table.join(
		awful.button({}, 1, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.move(c)
		end),
		awful.button({}, 3, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.resize(c)
		end)
	)

	awful.titlebar(c):setup({
		{ -- Left
			awful.titlebar.widget.iconwidget(c),
			buttons = buttons,
			layout = wibox.layout.fixed.horizontal,
		},
		{ -- Middle
			{ -- Title
				align = "center",
				widget = awful.titlebar.widget.titlewidget(c),
			},
			buttons = buttons,
			layout = wibox.layout.flex.horizontal,
		},
		{ -- Right
			awful.titlebar.widget.floatingbutton(c),
			awful.titlebar.widget.maximizedbutton(c),
			awful.titlebar.widget.stickybutton(c),
			awful.titlebar.widget.ontopbutton(c),
			awful.titlebar.widget.closebutton(c),
			layout = wibox.layout.fixed.horizontal(),
		},
		layout = wibox.layout.align.horizontal,
	})
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c)
	c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_normal
end)
