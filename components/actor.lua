local concord = require("lib.concord")

return concord.component(
	function(e, player)
		e.player = player
		e.actions = {}
	end
)
