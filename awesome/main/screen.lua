local gears = require("gears")
local beautiful = require("beautiful")

local M = {}

-- TODO: to move !!!

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
end
return M
