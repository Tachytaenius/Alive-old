local components = require("components")
local core = require("const.core")
local assets = require("assets")

return function(e, x, y, thickness, hingeX, hingeY, axis, collider, drawnTexture, windowWidth, barCount, on, r, g, b)
	local xDoor = collider:rectangle(x * core.terrainScale - core.tilePadding, y * core.terrainScale * (hingeY and core.terrainScale - thickness or 0) - core.tilePadding, core.terrainScale + core.tilePadding, thickness + core.tilePadding)
	local yDoor = collider:rectangle(x * core.terrainScale * (hingeX and core.terrainScale - thickness or 0) - core.tilePadding, y * core.terrainScale - core.tilePadding, thickness + core.tilePadding, core.terrainScale + core.tilePadding)
	local xDoorForRays = collider:rectangle(x * core.terrainScale, y * core.terrainScale * (hingeY and core.terrainScale - thickness or 0), core.terrainScale, thickness)
	local yDoorForRays = collider:rectangle(x * core.terrainScale * (hingeX and core.terrainScale - thickness or 0), y * core.terrainScale, thickness, core.terrainScale)
	return e
		:give(components.door, (axis == "x" or axis == "y") and axis or error("Incorrect axis supplied to door constructor."), xDoor, yDoor, xDoorForRays, yDoorForRays, drawnTexture, e, on, r, g, b)
		:give(components.position, x * core.terrainScale + (hingeX and core.terrainScale - thickness or thickness), y * core.terrainScale + (hingeY and core.terrainScale - thickness or thickness), 0)
end
