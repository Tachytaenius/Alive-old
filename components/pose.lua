local concord = require("lib.concord")

return concord.component(
	function(e, poses, current, deaths, walkStages, walkFrameTime)
		local reversePoses = {}
		for i, v in ipairs(poses) do
			reversePoses[v] = i
		end
		e.list = poses
		e.byName = reversePoses
		e.current = reversePoses[current] and current or error("Nonexistent pose supplied to constructor.")
		e.deaths = deaths
		if walkStages then
			e.walkStart = reversePoses.walk1
			e.walkEnd = e.walkStart + walkStages - 1
			e.walkStages = walkStages
			e.walkFrameTime = walkFrameTime
			e.walkLoopSpeed = walkFrameTime * walkStages
			e.walkTimer = 0
		end
	end
)
