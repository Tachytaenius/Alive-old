local concord = require("lib.concord")

return concord.component(
	function(e, size, collider, immovability, shape, clip, owner, x, y, r, g, b, texture)
		if shape == "circle" then
			e.shape = collider:circle(x, y, size)
		elseif shape == "square" then
			e.shape = collider:rectangle(x - size, y - size, size * 2, size * 2)
		else
			error("Invalid shape supplied to solidShape constructor.")
		end
		e.immovability = immovability
		e.shape.owner = owner
		e.shape.bag = e
		e.clip = clip
		if r or g or b or texture then
			e.occluderInfo = {r = r or 1, g = g or 1, b = b or 1, texture = texture}
		end
	end
)
