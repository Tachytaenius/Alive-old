local components = require("components")

return function(entity, reach)
	local reach, position = reach or entity:get(components.reach), entity:get(components.position)
	local dx, dy = reach.length * math.cos(position.theta + math.tau / 4), reach.length * math.sin(position.theta + math.tau / 4)
	reach.x, reach.y = position.x + dx, position.y + dy
	reach.dx, reach.dy = 0, -reach.length
	reach.updated = true
end
