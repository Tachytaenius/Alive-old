local json = require("lib/json")

-- Great for when you've just entered a state and want to keep any held-down inputs as on instead of forcing the player to repress them.
function getAllInputs()
	local inputs = {}
	for k, v in pairs(settings.controls) do
		if love.keyboard.isScancodeDown(k) then inputs[v] = true end
	end
	return inputs
end

function takeScreenshot(canvas)
	local info = love.filesystem.getInfo("screenshots")
	if not info or info.type ~= "directory" then
		warn("Couldn't find screenshots folder. Creating.")
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
