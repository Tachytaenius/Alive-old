local core = require("const.core")
local commands = require("const.commands")
local json = require("lib.json")
local knowledged = require("lib.knowledged")

local settings = {}

function settings.write()
	-- TODO
end

-- TODO: Redesign and stuff.

function settings.read()
	-- If there is no settings.json then defaults.json is used to create one.
	-- If settings.json is missing any settings, then defaults are used. These may not be the same defaults as defaults.json, an example being graphics.fullscreen: it's 2 in defaults.json-- (the recommended settings) and 1 in this function (the natural choice for a fallback value)
	
	local info = love.filesystem.getInfo("settings.json")
	if not info or info.type ~= "file" then
		knowledged.warn("Couldn't find settings.json. Creating.")
		love.filesystem.write("settings.json", love.filesystem.read("defaults.json"))
	end
	
	local decoded = json.decode(love.filesystem.read("settings.json"))
	
	settings.controls = {}
	if type(decoded.controls) == "table" then
		for k, v in pairs(decoded.controls) do
			if commands[v] then
				if pcall(love.keyboard.isScancodeDown, k) then
					settings.controls[k] = v
				else
					knowledged.warn("\"" .. k .. "\" is not a valid scancode to bind to an input.")
				end
			else
				knowledged.warn("\"" .. v .. "\" is not a valid input to bind scancodes to.")
			end
		end
	else
		knowledged.warn("Controls is not a table; no mappings defined.")
	end
	
	settings.graphics = {scale = 1, fullscreen = false, showPerformance = false}
	if type(decoded.graphics) == "table" then
		if type(decoded.graphics.fullscreen) == "boolean" then
			settings.graphics.fullscreen = decoded.graphics.fullscreen
		else
			knowledged.warn("Fullscreen is not a boolean. Using default.")
		end
		
		if decoded.graphics.scale >= 0 and math.isInteger(decoded.graphics.scale) then
			settings.graphics.scale = decoded.graphics.scale
		else
			knowledged.warn("Scale is not a positive integer. Using default.")
		end
		
		if type(decoded.graphics.showPerformance) == "boolean" then
			settings.graphics.showPerformance = decoded.graphics.showPerformance
		else
			knowledged.warn("Show performance is not a boolean. Using default.")
		end
	else
		knowledged.warn("Graphics is not a table. Using defaults.")
	end
	
	settings.autosave = {quit = false, load = false}
	if type(decoded.autosave) == "table" then
		if type(decoded.autosave.quit) == "boolean" then
			settings.autosave.quit = decoded.autosave.quit
		else
			knowledged.warn("Quit is not a boolean. Using default.")
		end
		
		if type(decoded.autosave.load) == "boolean" then
			settings.autosave.load = decoded.autosave.load
		else
			knowledged.warn("Load is not a boolean. Using default.")
		end
	else
		knowledged.warn("Autosave is not a table. Using defaults.")
	end
	
	settings.updateWindow()
end

function settings.updateWindow()
	if settings.graphics.fullscreen then
		local width, height = love.window.getDesktopDimensions()
		local x = (width - core.width * settings.graphics.scale) / 2
		local y = (height - core.height * settings.graphics.scale) / 2
		-- TODO: Are the default flags what we want in 11.1?
		love.window.setMode(width, height, {fullscreen = true, borderless = true})
		return x, y
	else
		love.window.setMode(core.width * settings.graphics.scale, core.height * settings.graphics.scale, {fullscreen = false, borderless = false})
		return 0, 0
	end
end

return settings
