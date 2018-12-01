local components = require("components")
local assets = require("assets")
local core = require("const.core")

return function(e, x, y, instance)
	local x, y = x * core.terrainScale, y * core.terrainScale
	local shape = instance.collider:rectangle(x - core.tilePadding, y - core.tilePadding, core.terrainScale + core.tilePadding * 2, core.terrainScale + core.tilePadding * 2)
	local forRays = instance.collider:rectangle(x, y, core.terrainScale, core.terrainScale)
	instance.collider:remove(forRays)
	return e
		:give(components.position, x + core.terrainScale / 2, y + core.terrainScale / 2)
		:give(components.solidShape, math.huge, false, e, shape, forRays)
		:give(components.tile)
end
