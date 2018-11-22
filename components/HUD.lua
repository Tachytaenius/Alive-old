local concord = require("lib.concord")

return concord.component(
	function(e, useMetabolismGraph)
		if useMetabolismGraph then
			e.metabolismGraph = {}
		end
	end
)
