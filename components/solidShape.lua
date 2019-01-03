local concord = require("lib.concord")

return concord.component(
	function(e, immovability, clip, owner, shape, forRays, r, g, b, on)
		e.shape = shape
		e.forRays = forRays -- another shape, used for rays.
		-- tiles have padding but that is not to be shown while doing rays
		e.shape.owner = owner
		if forRays then forRays.owner = owner end
		e.immovability = immovability
		e.shape.bag = e
		e.clip = clip
		if r or g or b or a then
			e.occluderInfo = {r = r or 0, g = g or 0, b = b or 0, on = on}
		end
	end
)
