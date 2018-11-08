local concord = require("lib.concord")

return concord.component(
	function(e, image, size)
		e.image = image
		e.size = size
	end
)
