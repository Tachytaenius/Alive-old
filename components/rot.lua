local concord = require("lib.concord")

return concord.component(
	function(e, speed, stages, current)
		e.speed = speed or 0
		e.stages = stages or 1
		e.current = current or 0
	end
)
