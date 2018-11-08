local concord = require("lib.concord")

return concord.component(
	function(e, topping, stairsDown)
		e.topping = topping
		e.stairsDown = stairsDown
	end
)
