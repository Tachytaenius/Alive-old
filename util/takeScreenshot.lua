local knowledged = require("lib.knowledged")

return function(canvas)
	local info = love.filesystem.getInfo("screenshots")
	if not info or info.type ~= "directory" then
		knowledged.warn("Couldn't find screenshots folder. Creating.")
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
	data:mapPixel(
		function(x, y, r, g, b, a)
			return math.round(r, 15), math.round(g, 15), math.round(b, 15), 1
		end
	)
	data:encode("png", "screenshots/" .. current + 1 .. ".png")
end
