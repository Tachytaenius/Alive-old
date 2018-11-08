local concord = require("lib.concord")
local components = require("components")
local clean = concord.system({"deleteViewSector", components.viewSector}, {"unseeShapes", components.seenShapes}, {"invalidateReach", components.reach})

function clean:update()
	for i = 1, self.unseeShapes.size do
		self.unseeShapes:get(i):get(components.seenShapes).updated = false
	end
	
	for i = 1, self.invalidateReach.size do
		self.invalidateReach:get(i):get(components.reach).updated = false
	end
	
	local collider = self:getInstance().collider
	for i = 1, self.deleteViewSector.size do
		local viewSector = self.deleteViewSector:get(i):get(components.viewSector)
		if viewSector.shape then collider:remove(viewSector.shape) end
		viewSector.vertices, viewSector.shape = nil, nil
	end
end

return clean
