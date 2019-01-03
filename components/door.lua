local concord = require("lib.concord")

return concord.component(
	function(e, axis, x, y, xForRays, yForRays, drawnTexture, owner, on, r, g, b)
		e.occluderInfo = {r = r or 0, g = g or 0, b = b or 0, on = on}
		e.x = x
		e.xForRays = xForRays
		x.bag = e
		e.clip = true
		x.owner = owner
		e.y = y
		y.bag = e
		y.owner = owner
		e.yForRays = yForRays
		e.axis = axis
		e.shape = e[axis]
		e.forRays = e[axis .. "ForRays"]
	end
)
