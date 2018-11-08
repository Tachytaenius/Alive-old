local concord = require("lib.concord")

return concord.component(
	function(e, rotSpeed, rotStages)
		e.rotSpeed = rotSpeed or 0
		e.rotStages = rotStages or 1
	end
)
