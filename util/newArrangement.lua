local core = require("const.core")

return function(mapFunction)
	local tile = love.image.newImageData(core.terrainScale, core.terrainScale)
	tile:mapPixel(mapFunction)
	return love.graphics.newImage(tile)
end
