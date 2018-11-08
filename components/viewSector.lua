local concord = require("lib.concord")

return concord.component(
	function(e, fov, falloff)
		e.fov = fov
		e.falloff = falloff
	end
)
