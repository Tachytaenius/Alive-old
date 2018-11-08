local concord = require("lib.concord")
local components = require("components")
local updateViewSectors = concord.system({"forDrawing", components.viewSector, components.camera}, {"forThinking", components.viewSector, components.ai, components.actor})

local insert, tau, cos, sin = table.insert, math.tau, math.cos, math.sin
local function generate(e, collider)
	local viewSector = e:get(components.viewSector)
	local vertices = {}
	viewSector.vertices = vertices
	
	local falloff = viewSector.falloff
	local angle = viewSector.fov
	insert(vertices, 0)
	insert(vertices, 0)
	for theta = -angle/2, angle/2, angle / 4 do -- TODO: Sort out this maths (it was done with little water in my brain)
		theta = -theta % tau - tau/2
		insert(vertices, falloff * cos(theta + tau/4))
		insert(vertices, falloff * sin(theta + tau/4))
	end
	
	viewSector.currentFalloff, viewSector.currentFov = falloff, angle -- Yes, we're up to date.
end

local function update(e, collider)
	local epos = e:get(components.position)
	local viewSector = e:get(components.viewSector)
	if viewSector.shape then collider:remove(viewSector.shape) end
	local sector = collider:polygon(unpack(viewSector.vertices))
	sector:move(epos.x, epos.y)
	sector:rotate(epos.theta + math.tau / 2, epos.x, epos.y)
	viewSector.shape = sector
end

function updateViewSectors:update()
	local collider = self:getInstance().collider
	local updatedBecauseCamera = {}
	for i = 1, self.forDrawing.size do
		local e = self.forDrawing:get(i)
		local viewSector = e:get(components.viewSector)
		if not viewSector.baseShape or not (viewSector.currentFalloff == viewSector.falloff and viewSector.currentFov == viewSector.fov) then
			generate(e, collider)
			updatedBecauseCamera[e] = true
		end
		update(e, collider)
	end
	for i = 1, self.forThinking.size do
		local e = self.forThinking:get(i)
		if not updatedBecauseCamera[e] then
			local ai = e:get(components.ai)
			local viewSector = e:get(components.viewSector)
			if ai and ai.active and (ai.following or ai.pathfinding) or not (viewSector.currentFalloff == viewSector.falloff and viewSector.currentFov == viewSector.fov) then
				generate(e, collider)
				update(e, collider)
			end
		end
	end
end

return updateViewSectors
