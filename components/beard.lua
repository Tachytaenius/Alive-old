local concord = require("lib.concord")

return concord.component(
	function(e, maximum, current)
		e.maximum = maximum
		e.current = current or 0
		e.maxImpact = 1 -- TODO: more beard sprites
	end
)
