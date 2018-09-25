local CORE, TITULAR = require("const/core"), require("const/titular")
local json = require("lib/json") -- TODO: caps 'cause it's a constant, right??
local knowledged = require("lib/knowledged")

local settings = {}

function settings.write()
	-- TODO
end

function settings.read()
	-- If there is no settings.json then default_settings.json is created.
	-- If settings.json is missing any settings, then defaults are used. These may not be the same defaults as default_settings.json, an example being graphics.fullscreen: it's 2 in default_settings.json-- (the recommended settings) and 1 in this function (the natural choice for a fallback value)
	
	local info = love.filesystem.getInfo("settings.json")
	if not info or info.type ~= "file" then
		knowledged:warn("Couldn't find settings.json. Creating.")
		love.filesystem.write("settings.json", love.filesystem.read("default_settings.json"))
	end
	
	local decoded = json.decode(love.filesystem.read("settings.json"))
	
	settings.controls = {}
	if type(decoded.controls) == "table" then
		for k, v in pairs(decoded.controls) do
			if CORE.INPUTS[v] then
				if pcall(love.keyboard.isScancodeDown, k) then
					settings.controls[k] = v
				else
					knowledged:warn("\"" .. k .. "\" is not a valid scancode to bind to an input.")
				end
			else
				knowledged:warn("\"" .. v .. "\" is not a valid input to bind scancodes to.")
			end
		end
	else
		knowledged:warn("Controls is not a table; no mappings defined.")
	end
	
	local previousUseTitleVariation = settings.graphics and settings.graphics.useTitleVariation
	settings.graphics = {scale = 1, fullscreen = false, showPerformance = false, useTitleVariation = false, showVariantInfo = false}
	if type(decoded.graphics) == "table" then
		if type(decoded.graphics.fullscreen) == "boolean" then
			settings.graphics.fullscreen = decoded.graphics.fullscreen
		else
			knowledged:warn("Fullscreen is not a boolean. Using default.")
		end
		
		if decoded.graphics.scale >= 0 and math.isInteger(decoded.graphics.scale) then
			settings.graphics.scale = decoded.graphics.scale
		else
			knowledged:warn("Scale is not a positive integer. Using default.")
		end
		
		if type(decoded.graphics.showPerformance) == "boolean" then
			settings.graphics.showPerformance = decoded.graphics.showPerformance
		else
			knowledged:warn("Show performance is not a boolean. Using default.")
		end
		
		if type(decoded.graphics.useTitleVariation) == "boolean" then
			settings.graphics.useTitleVariation = decoded.graphics.useTitleVariation
		else
			knowledged:warn("Use title variation is not a boolean. Using default.")
		end
		
		if type(decoded.graphics.showVariantInfo) == "boolean" then
			settings.graphics.showVariantInfo = decoded.graphics.showVariantInfo
		else
			knowledged:warn("Show variant info is not a boolean. Using default.")
		end
		
		if previousUseTitleVariation ~= settings.graphics.useTitleVariation then
			settings.updateTitle()
		end
	else
		knowledged:warn("Graphics is not a table. Using defaults.")
	end
	
	settings.updateWindow()
end

function settings.updateTitle()
	local title
	if settings.graphics.useTitleVariation then
		local choice = love.math.random(#TITULAR)
		title = TITULAR.PLAIN .. ": " .. TITULAR[choice]
		if settings.graphics.showVariantInfo then
			title = title .. " (" .. choice .. " of " .. #TITULAR .. ")"
		end
	else
		title = TITULAR.PLAIN
	end 
	love.window.setTitle(title)
end

function settings.updateWindow()
	if settings.graphics.fullscreen then
		local width, height = love.window.getDesktopDimensions()
		local x = (width - CORE.WIDTH * settings.graphics.scale) / 2
		local y = (height - CORE.HEIGHT * settings.graphics.scale) / 2
		-- TODO: Are the default flags what we want in 11.1?
		love.window.setMode(width, height, {fullscreen = true, borderless = true})
		return x, y
	else
		love.window.setMode(CORE.WIDTH * settings.graphics.scale, CORE.HEIGHT * settings.graphics.scale, {fullscreen = false, borderless = false})
		return 0, 0
	end
end

return settings
