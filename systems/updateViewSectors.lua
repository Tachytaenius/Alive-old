local concord = require("lib.concord")
local components = require("components")
local updateViewSectors = concord.system({components.viewSector})

local insert, tau, cos, sin = table.insert, math.tau, math.cos, math.sin
local function generate(e, collider, viewSector)
	local vertices = {}
	
	local falloff = viewSector.falloff
	local angle = viewSector.fov
	insert(vertices, 0)
	insert(vertices, 0)
	for theta = -angle/2, angle/2, angle / 4 do -- TODO: Sort out this maths (it was done with little water in my brain)
		theta = -theta % tau - tau/2
		insert(vertices, falloff * cos(theta + tau/4))
		insert(vertices, falloff * sin(theta + tau/4))
	end
	
	if viewSector.shape then collider:remove(viewSector.shape) end
	viewSector.shape = collider:polygon(unpack(vertices))
	viewSector.basePolygon = viewSector.shape._polygon
	viewSector.currentFalloff, viewSector.currentFov = falloff, angle -- Yes, we're up to date.
end

local function update(e, collider, viewSector)
	local epos = e:get(components.position)
	viewSector.shape._polygon = viewSector.basePolygon:clone()
	viewSector.shape:move(epos.x, epos.y)
	viewSector.shape:rotate(epos.theta + math.tau / 2, epos.x, epos.y)
end

function updateViewSectors:update()
	local collider = self:getInstance().collider
	for i = 1, self.pool.size do
		local e = self.pool:get(i)
		local viewSector = e:get(components.viewSector)
		local ai = e:get(components.ai)
		local updateForDraw = e:has(components.camera)
		local updateForThink = ai and ai.active and (ai.following or ai.pathfinding)
		if updateForDraw or updateForThink then
			if not (viewSector.currentFalloff == viewSector.falloff and viewSector.currentFov == viewSector.fov) or not viewSector.basePolygon then
				generate(e, collider, viewSector)
			end
			update(e, collider, viewSector)
		end
	end
end

return updateViewSectors
