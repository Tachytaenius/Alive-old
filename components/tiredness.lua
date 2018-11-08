local concord = require("lib.concord")

-- A more organic version of capacitors
return concord.component(
	function(e, endurance, current)
		e.current = current or 0
		e.endurance = endurance
	end
)
