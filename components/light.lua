local concord = require("lib.concord")

return concord.component(
	function(e, energy, collider, r, g, b, emitter, x, y, on)
		e.on = on or true
		e.shape = collider:circle(x, y, energy)
		e.shape.emitter = emitter
		e.shape.bag = e
		e.r, e.g, e.b, e.energy = r, g, b, energy
	end
)
