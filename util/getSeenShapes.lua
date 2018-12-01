local components = require("components")

return function(e, collider)
	local tiles, mobs, lights = {}, {}, {}
	local occluders = {} -- you might not be able to see them directly but their shadows are relevant
	
	local seenCircle = e:has(components.senseCircle) and collider:collisions(e:get(components.senseCircle).shape) or {}
	if e:has(components.viewSector) then
		local seenSector = collider:collisions(e:get(components.viewSector).shape)
		for k in pairs(seenSector) do
			if k.emitter and not k.light then
				lights[k] = true
				seenCircle[k] = nil
			elseif k.owner then
				if k.owner:has(components.mob) then
					mobs[k] = true
					seenCircle[k] = nil
				else
					tiles[k] = true
				end
				local occluderInfo = k.bag.occluderInfo
				if occluderInfo and not (occluderInfo.r == 1 and occluderInfo.g == 1 and occluderInfo.b == 1) then
					occluders[k] = true
					seenCircle[k] = nil
				end
			end
		end
	end
	
	for k in pairs(seenCircle) do
		if k.emitter and not k.light then
			lights[k] = true
		elseif k.owner then
			if k.owner:has(components.mob) then
				mobs[k] = true
			else
				tiles[k] = true
			end
			if occluderInfo and not (occluderInfo.r == 1 and occluderInfo.g == 1 and occluderInfo.b == 1) then
				occluders[k] = true
				seenCircle[k] = nil
			end
		end
	end
	
	for light in pairs(lights) do
		local potentialNewOccluders = collider:collisions(light)
		for potentialOccluder in pairs(potentialNewOccluders) do
			local occluderInfo = potentialOccluder.bag and potentialOccluder.bag.occluderInfo
			if occluderInfo and not (occluderInfo.r == 1 and occluderInfo.g == 1 and occluderInfo.b == 1) then
				occluders[potentialOccluder] = true
			end
		end
	end
	
	local seenShapes = e:get(components.seenShapes)
	seenShapes.tiles, seenShapes.mobs, seenShapes.lights, seenShapes.occluders, seenShapes.updated = tiles, mobs, lights, occluders, true
end
