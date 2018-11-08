local concord = require("lib.concord")

return concord.component(
	function(e, current, maximum)
		e.current = current or maximum
		e.maximum = maximum
	end
)
