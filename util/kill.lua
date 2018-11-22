local components = require("components")

return function(e, rng, type)
	local pose = e:get(components.pose)
	if pose then
		local choices = pose.deaths.all or type and pose.deaths and pose.deaths[type]
		if choices then
			local choice = choices[rng:random(#choices)]
			pose.moved = false
			pose.walkTimer = 0
			pose.current = choice
			pose.impact = pose.byName[choice]
		end
	end
	
	local blink = e:get(components.blink)
	if blink then
		blink.current, blink.impact = 0, 1
	end
	
	local light = e:get(components.light)
	if light then
		light.on = false
	end
	
	if e:has(components.metabolism) then
		e:remove(components.life):give(components.rot)
	end
	
	return e
end
