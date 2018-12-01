local concord = require("lib.concord")

return concord.component(
	function(e, immovability, clip, owner, shape, forRays, r, g, b)
		e.shape = shape
		e.forRays = forRays -- another shape, used for rays.
		-- tiles have padding but that is not to be shown while doing rays
		
		e.immovability = immovability
		e.shape.owner = owner
		e.shape.bag = e
		e.clip = clip
		if r or g or b then
			e.occluderInfo = {r = r or 1, g = g or 1, b = b or 1}
		end
	end
)
