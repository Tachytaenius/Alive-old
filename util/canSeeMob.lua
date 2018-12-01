local components = require("components")

return function(realm, viewer, viewee, minimumVisibility)
	minimumVisibility = minimumVisibility or 0.03125
	
	local vieweeShape = viewee:get(components.solidShape).shape
	local inSector = viewer:has(components.viewSector) and realm.collider:collisions(viewer:get(components.viewSector).shape)[vieweeShape]
	local inCircle = viewer:has(components.viewSector) and realm.collider:collisions(viewer:get(components.viewSector).shape)[vieweeShape]
	if not inSector and not inCircle then return false end
	
	local erpos = viewer:get(components.position)
	local eepos = viewee:get(components.position)
	local toCheck = realm.collider:hash():cellAt(eepos.x, eepos.y)
	local toCheck2 = {}
	for shape in pairs(toCheck) do
		if shape:contains(eepos.x, eepos.y) then toCheck2[shape] = true end
	end
	if viewer:has(components.solidShape) then
		toCheck2[viewer:get(components.solidShape).shape] = nil
	end
	toCheck2[vieweeShape] = nil
	
	local viewR, viewG, viewB = 1, 1, 1
	local lampR, lampG, lampB = realm:getLightLevel()
	
	for shape in pairs(toCheck2) do
		if shape.bag and shape.emitter then
			local shapes = realm.collider:collisions(shape)
			local cx, cy = shape:center()
			local intensity = 1 - (math.distance(eepos.x - cx, eepos.y - cy) / shape.bag.energy)
			local r, g, b = shape.bag.r * intensity, shape.bag.g * intensity, shape.bag.b * intensity
			for shape2 in pairs(shapes) do
				if shape.bag then
					local shape2 = shape2.bag.forRays or shape2
					if shape2 ~= viewee and shape2:intersectsRay(cx, cy, eepos.x - cx, eepos.y - cy) then
						local occInfo = not (shape2.bag.owner and shape2.bag.owner:get(components.mob)) and shape2.bag.occluderInfo
						if occInfo then
							r, g, b = math.min(r, occInfo.r), math.min(g, occInfo.g), math.min(b, occInfo.b)
						end
					end
				end
			end
			lampR, lampG, lampB = lampR + r, lampG + g, lampB + b
		end
	end
	
	local toCheck3 = {}
	local x0, y0 = erpos.x, erpos.y
	local x1, y1 = eepos.x, eepos.y
	local dx, dy = math.abs(x1 - x0), math.abs(y1 - y0)
	local ix, iy = x0 < x1 and 1 or -1, y0 < y1 and 1 or -1
	local error = 0
	local hash = realm.collider:hash()
	for i = 1, dx + dy do
		for shape in pairs(hash:cellAt(x0, y0)) do
			if shape.bag and not (shape.bag.owner and shape.bag.owner:get(components.mob)) and shape.bag.occluderInfo then toCheck3[shape] = true end
		end
		local e1, e2 = error + dy, error - dx
		if math.abs(e1) < math.abs(e2) then
			x0 = x0 + ix
			error = e1
		else
			y0 = y0 + iy
			error = e2
		end
	end
	
	for shape in pairs(toCheck3) do
		if shape:intersectsRay(erpos.x, erpos.y, eepos.x - erpos.x, eepos.y - erpos.y) then
			local occInfo = shape.bag and not (shape.bag.owner and shape.bag.owner:get(components.mob)) and shape.bag.occluderInfo
			if occInfo then
				viewR, viewG, viewB = math.min(viewR, occInfo.r), math.min(viewG, occInfo.g), math.min(viewB, occInfo.b)
			end
		end
	end
	
	return (lampR * viewR + lampG * viewG + lampB * viewB) / 3 * (vieweeShape.occluderInfo and (1 - (vieweeShape.occluderInfo.r + vieweeShape.occluderInfo.g + vieweeShape.occluderInfo.b) / 3) or 1) >= minimumVisibility
end
