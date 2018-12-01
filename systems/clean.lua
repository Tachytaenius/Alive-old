local concord = require("lib.concord")
local components = require("components")
local clean = concord.system({"unseeShapes", components.seenShapes}, {"invalidateReach", components.reach})

function clean:update()
	for i = 1, self.unseeShapes.size do
		self.unseeShapes:get(i):get(components.seenShapes).updated = false
	end
	
	for i = 1, self.invalidateReach.size do
		self.invalidateReach:get(i):get(components.reach).updated = false
	end
end

return clean
