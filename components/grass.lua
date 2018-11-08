local concord = require("lib.concord")

return concord.component(
	function(e, health)
		e.health = health or 1
	end
)
