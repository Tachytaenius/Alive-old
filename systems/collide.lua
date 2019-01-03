local concord = require("lib.concord")
local components = require("components")
local core = require("const.core")
local collide = concord.system({"colliders", components.solidShape, components.mob}, {"punchers", components.puncher})
local updateShapes = require("util.updateShapes")

function collide:update()
	local collider = self:getInstance().collider
	local relevantTilesAndDoors = {}
	local indices = {}
	for i = 1, self.colliders.size do
		local e = self.colliders:get(i)
		for shape in pairs(collider:collisions(e:get(components.solidShape).shape)) do
			local owner = shape.owner
			if owner and not owner:has(components.mob) then
				local door = owner:get(components.door)
				if door then
					if door.shape == shape then relevantTilesAndDoors[shape] = true end
				else
					relevantTilesAndDoors[shape] = true
				end
			end
		end
		indices[e] = i
	end
	local xShifts, yShifts = {}, {}
	for shape in pairs(relevantTilesAndDoors) do
		if shape.bag.clip then
			for other, vector in pairs(collider:collisions(shape)) do
				if other.owner and other.owner:has(components.mob) then
					xShifts[other.owner] = xShifts[other.owner] and xShifts[other.owner] -vector.x or -vector.x
					yShifts[other.owner] = yShifts[other.owner] and yShifts[other.owner] -vector.y or -vector.y
				end
			end
		end
	end
	local rng = self:getInstance().rng
	local state = rng:getState()
	for i = 1, self.colliders.size do
		local e = self.colliders:get(i)
		for other, vector in pairs(collider:collisions(e:get(components.solidShape).shape)) do
			if other.owner and other.owner:get(components.mob) then
				if e:get(components.solidShape).clip or other.bag.clip then
					local pusherImmovability, pusheeImmovability = e:get(components.solidShape).immovability, other.bag.immovability / core.pusheePenalty
					local pusherFactor
					if pusheeImmovability == pusherImmovability then
						pusherFactor = 0.5
					elseif pusheeImmovability == math.huge and pusherImmovability ~= math.huge then
						pusherFactor = 1
					elseif pusheeImmovability ~= math.huge and pusherImmovability == math.huge then
						pusherFactor = 0
					else
						pusherFactor = pusheeImmovability / (pusherImmovability + pusheeImmovability)
					end
					local pusheeFactor = 1 - pusherFactor
					local vx, vy = vector.x, vector.y
					if e:get(components.position).x == other.owner:get(components.position).x and e:get(components.position).y == other.owner:get(components.position).y then
						rng:setState("0x" .. string.format("%x", (tonumber(string.sub(state, 3), 16) + 4096 * indices[other.owner]) % 2 ^ 53))
						local angle = rng:random() * math.tau  -- random should be in [0, 1)
					 	local distance = math.sqrt(vx ^ 2 + vy ^ 2)
						vx, vy = math.polarToCartesian(distance, angle)
					end
					
					xShifts[other.owner] = xShifts[other.owner] and xShifts[other.owner] + pusheeFactor * -vx or pusheeFactor * -vx
					yShifts[other.owner] = yShifts[other.owner] and yShifts[other.owner] + pusheeFactor * -vy or pusheeFactor * -vy
					xShifts[e] = xShifts[e] and xShifts[e] + pusherFactor * vx or pusherFactor * vx
					yShifts[e] = yShifts[e] and yShifts[e] + pusherFactor * vy or pusherFactor * vy
				end
			end
		end
	end
	rng:setState(state)
	for i = 1, self.punchers.size do
		local e = self.punchers:get(i)
		local actor = e:get(components.actor)
		if actor.actions.punch then
			-- TODO: left, right etc
			local rightStrength = e:get(components.puncher).rightStrength
			local reach = e:get(components.reach).length
			local epos = e:get(components.position)
			-- punchable shapes are shapes that have a collisionType of wall or are entities without nonBlocking
			-- punched needs to be a set of the punchables for which no punchable is closer (ie "the" closest punchable and any punchables that tied with it)
			local x0, y0 = epos.x, epos.y
			local x1, y1 = epos.x + reach * math.cos(epos.theta + math.tau / 4), epos.y + reach * math.sin(epos.theta + math.tau / 4)
			local dx, dy = math.abs(x1 - x0), math.abs(y1 - y0)
			local ix, iy = x0 < x1 and 1 or -1, y0 < y1 and 1 or -1
			local error = 0
			local punched = {}
			local shapeCount = 0
			local currentDistance = reach
			local hash = collider:hash()
			local toCheck = {}
			for i = 1, dx + dy do
				for shape in pairs(hash:cellAt(x0, y0)) do
					toCheck[shape] = true
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
			if e:has(components.solidShape) then
				toCheck[e:get(components.solidShape).shape] = nil
			end
			local dx, dy = x1 - epos.x, y1 - epos.y
			for shape in pairs(toCheck) do
				if shape.bag and shape.bag.clip then
					local rayParameters = shape:intersectionsWithRay(epos.x, epos.y, dx, dy)
					local distance = math.huge
					for _, v in pairs(rayParameters) do
						if v >= 0 and v <= 1 then
							v = v * reach
							distance = v < distance and v or distance
						end
					end
					if distance then
						if distance < currentDistance then
							currentDistance = distance
							punched = {[shape] = true}
							shapeCount = 1
						elseif distance == currentDistance then
							punched[shape] = true
							shapeCount = shapeCount + 1
						end
					end
				end
			end
			
			local damage = (rng:random() * 0.25 + 0.75) * rightStrength * (1 - currentDistance / reach)
			local metabolism = e:get(components.metabolism)
			if metabolism then
				metabolism.exertion = metabolism.exertion + math.min(reach, currentDistance) / 400
			end
			local knockX, knockY = dx / reach * math.abs(reach - currentDistance), dy / reach * math.abs(reach - currentDistance)
			for punchable in pairs(punched) do
				if punchable.owner:has(components.mob) then
					local integrity = punchable.owner:get(components.integrity)
					if integrity then
						integrity.current = math.max(integrity.current - damage / shapeCount, 0)
					end
					xShifts[punchable.owner] = xShifts[punchable.owner] and xShifts[punchable.owner] + knockX / punchable.bag.immovability or knockX / punchable.bag.immovability
					yShifts[punchable.owner] = yShifts[punchable.owner] and yShifts[punchable.owner] + knockY / punchable.bag.immovability or knockY / punchable.bag.immovability
				else
					local wall = punchable.owner:get(components.tile).topping.superTopping
					-- TODO: fling constituents out of the wall
				end
			end
		end
	end
	for entity, xShift in pairs(xShifts) do
		local position = entity:get(components.position)
		position.x = position.x + xShift
		position.y = position.y + yShifts[entity]
		updateShapes(entity)
	end
end

return collide
