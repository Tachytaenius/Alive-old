local concord = require("lib.concord")

return concord.component(
	function(e, leftStrength, rightStrength)
		e.leftStrength, e.rightStrength = leftStrength, rightStrength
	end
)
