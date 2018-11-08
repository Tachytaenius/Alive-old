local concord = require("lib.concord")

return concord.component(
	function(e, x, y, theta)
		e.x = x
		e.y = y
		
		e.theta = theta
	end
)
