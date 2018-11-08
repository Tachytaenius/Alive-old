local concord = require("lib.concord")

return concord.component(
	function(e, effortRequired, timeRequired, toggled)
		-- timeRequired is in ticks.
		-- effortRequired is the amount of extertion units per tick
		e.cost = effortRequired
		e.timeRequired = timeRequired
		e.state = toggled and timeRequired or -timeRequired
		e.maxImpact = 1
		e.toggling = toggled and 1 or -1
	end
)
