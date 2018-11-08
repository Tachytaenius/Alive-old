local concord = require("lib.concord")

return concord.component(
	function(e, radius, collider, x, y)
		e.shape = collider:circle(x, y, radius)
		e.radius = radius
	end
)
