local components = require("components")
local assets = require("assets")
local core = require("const.core")

return function(e, x, y, instance)
	local x, y = (x + 0.5) * core.terrainScale, (y + 0.5) * core.terrainScale
	return e
		:give(components.position, x, y)
		:give(components.solidShape, core.terrainScale / 2 + core.tilePadding, instance.collider, math.huge, "square", false, e, x, y)
		:give(components.tile)
end
