local json = require("lib/json")

function image(path)
	return love.graphics.newImage("assets/images/" .. path .. ".png")
end

function warn(message)
	print(message)
	-- TODO: In-game popup.
end

-- Great for when you've just entered a state and want to keep any held-down inputs as on instead of forcing the player to repress them.
function getAllInputs()
	local inputs = {}
	for k, v in pairs(settings.controls) do
		if love.keyboard.isScancodeDown(k) then inputs[v] = true end
	end
	return inputs
end

local round = math.round
local function depth(x, y, r, g, b, a)
	return round(r, 15), round(g, 15), round(b, 15), 1
end

function takeScreenshot(canvas)
	local info = love.filesystem.getInfo("screenshots")
	if not info or info.type ~= "directory" then
		warn("Couldn't find screenshoots folder. Creating.")
		love.filesystem.createDirectory("screenshots")
	end
	local screenshots = love.filesystem.getDirectoryItems("screenshots")
	local current = 0
	for _, filename in pairs(screenshots) do
		local name = string.sub(filename, 1, -5) -- remove ".png"
		if name then
			local number = tonumber(name)
			if number and number > current then current = number end
		end
	end
	local data = canvas:newImageData()
	data:mapPixel(depth)
	data:encode("png", "screenshots/" .. current + 1 .. ".png")
end

function setSettings()
	-- TODO
end

function getSettings()
	-- If there is no settings.json then defaults.json is created.
	-- If settings.json is missing any settings, then defaults are used. These may not be the same defaults as defaults.json, an example being graphics.fullscreen: it's 2 in defaults.json-- (the recommended settings) and 1 in this function (the natural choice for a fallback value)
	
	local info = love.filesystem.getInfo("settings.json")
	if not info or info.type ~= "file" then
		warn("Couldn't find settings.json. Creating.")
		love.filesystem.write("settings.json", love.filesystem.read("defaults.json"))
	end
	
	local decoded = json.decode(love.filesystem.read("settings.json"))
	local settings = {}
	
	settings.info = {showPerformance = false}
	if type(decoded.info) == "table" then
		if type(decoded.info.showPerformance) == "boolean" then
			settings.info.showPerformance = decoded.info.showPerformance
		else
			warn("Show performance is not a boolean. Using default.")
		end
	else
		warn("Info is not a table. Using defaults.")
	end
	
	settings.controls = {}
	if type(decoded.controls) == "table" then
		for k, v in pairs(decoded.controls) do
			if constants.inputs[v] then
				if pcall(love.keyboard.isScancodeDown, k) then
					settings.controls[k] = v
				else
					warn("\"" .. k .. "\" is not a valid scancode to bind to an input.")
				end
			else
				warn("\"" .. v .. "\" is not a valid input to bind scancodes to.")
			end
		end
	else
		warn("Controls is not a table; no mappings defined.")
	end
	
	settings.graphics = {scale = 1, fullscreen = false}
	if type(decoded.graphics) == "table" then
		if type(decoded.graphics.fullscreen) == "boolean" then
			settings.graphics.fullscreen = decoded.graphics.fullscreen
		else
			warn("Fullscreen is not a boolean. Using default.")
		end
		
		if decoded.graphics.scale >= 0 and math.isInteger(decoded.graphics.scale) then
			settings.graphics.scale = decoded.graphics.scale
		else
			warn("Scale is not a positive integer. Using default.")
		end
	else
		warn("Graphics is not a table. Using defaults.")
	end
	
	return settings
end

function renewScreen()
	if settings.graphics.fullscreen then
		local width, height = love.window.getDesktopDimensions()
		local x = (width - constants.screenWidth * settings.graphics.scale) / 2
		local y = (height - constants.screenHeight * settings.graphics.scale) / 2
		-- TODO: Are the default flags what we want in 11.1?
		love.window.setMode(width, height, {fullscreen = true, borderless = true})
		return x, y
	else
		love.window.setMode(constants.screenWidth * settings.graphics.scale, constants.screenHeight * settings.graphics.scale, {fullscreen = false, borderless = false})
	end
end

-- Returns a table for which all keys in "a" whose value's truth differs to that of the value of the same key in "b" is a boolean representing the truth of the value that the key held in "b."
-- For example, if "a" is the table of inputs for one frame and "b" is a table of inputs for the next one, then every non-nil value in "getDeltas(a, b)" would be true if the input its key represented was newly pressed between the frames and false if it was released. That is the main purpose of this function.
function getDeltas(a, b)
	c = {}
	for k in pairs(a) do
		if not a[k] and b[k] then
			c[k] = true
		elseif a[k] and not b[k] then
			c[k] = false
		end
	end
	for k in pairs(b) do
		if c[k] == nil then -- A did not have this key, but more relevantly: B does. This is part of the intersection and thus must be accounted for.
			-- Surrounding this in an IF statement was merely an optimisation, the return table would be the same either way.
			if not a[k] and b[k] then
				c[k] = true
			elseif a[k] and not b[k] then
				c[k] = false
			end
		end
	end
	return c
end

function tableEqual(t1, t2)
	for k, v in pairs(t1) do
		if t2[k] ~= v then return false end
	end
	-- And in case t2 contains keys that t1 does not...
	for k, v in pairs(t2) do
		if t1[k] ~= v then return false end
	end
	return true
end

-- Shallow copy.
function copy(t)
	local t2 = {}
	for k, v in pairs(t) do
		t2[k] = v
	end
	return t2
end
