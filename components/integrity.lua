local concord = require("lib.concord")

return concord.component(
	function(e, maximum, current)
		e.maximum = maximum
		e.current = current or maximum
	end
)
