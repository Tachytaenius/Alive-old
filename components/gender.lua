local concord = require("lib.concord")

return concord.component(
	function(e, which)
		if not (which == "male" or which == "female") then error("Invalid gender supplied to constructor.") end
		e.which = which
	end
)
