local components = require("components")

return function(e)
	local position = e:get(components.position)
	local solidShape = e:get(components.solidShape)
	if solidShape then
		solidShape.shape:moveTo(position.x, position.y)
	end
	local senseCircle = e:get(components.senseCircle)
	if senseCircle then
		senseCircle.shape:moveTo(position.x, position.y)
	end
	local light = e:get(components.light)
	if light then
		light.shape:moveTo(position.x, position.y)
	end
end
