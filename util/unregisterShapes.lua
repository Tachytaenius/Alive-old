local components = require("components")

return function(instance, e)
	local collider = instance.collider
	local solidShape = e:get(components.solidShape)
	if solidShape then
		collider:remove(solidShape.shape)
	end
	local senseCircle = e:get(components.senseCircle)
	if senseCircle then
		collider:remove(senseCircle.shape)
	end
	local light = e:get(components.light)
	if light then
		collider:remove(light.shape)
	end
end
