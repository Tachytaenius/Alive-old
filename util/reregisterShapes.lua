local components = require("components")

return function(instance, e)
	local collider = instance.collider
	
	local solidShape = e:get(components.solidShape)
	if solidShape then
		collider:register(solidShape.shape)
	end
	local senseCircle = e:get(components.senseCircle)
	if senseCircle then
		collider:register(senseCircle.shape)
	end
	local light = e:get(components.light)
	if light then
		collider:register(light.shape)
	end
	local door = e:get(components.door)
	if door then
		collider:register(door.x)
		collider:register(door.y)
	end
end
