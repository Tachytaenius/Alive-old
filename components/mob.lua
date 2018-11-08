local concord = require("lib.concord")

return concord.component(
	function(e, speed)
		e.speed = speed
		e.moved = false
	end
)
