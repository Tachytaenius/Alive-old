local concord = require("lib.concord")

return concord.component(
	function(e, length)
		e.length = length
		e.updated = false
		-- e.x = nil
		-- e.y = nil
	end
)
