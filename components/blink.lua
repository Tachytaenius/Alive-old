local concord = require("lib.concord")

return concord.component(
	function(e, speed, length, current)
		e.speed = speed
		e.length = length
		e.modifier = 1 -- for sandstorms and the like
		e.current = current or 0
		e.maxImpact = 1 -- TODO: more "resolution in blinking" for things with huge eyes
	end
)
