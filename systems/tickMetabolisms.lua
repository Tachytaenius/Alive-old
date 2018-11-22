local concord = require("lib.concord")
local graphics = require("const.graphics")
local components = require("components")
local tickMetabolisms = concord.system({components.metabolism, components.life})

function tickMetabolisms:update()
	for i = 1, self.pool.size do
		local e = self.pool:get(i)
		local metabolism = e:get(components.metabolism)
		
		metabolism.speed = math.min(metabolism.food, metabolism.water) / (metabolism.capacity / 2)
		
		local cost = math.min(metabolism.food, metabolism.water, metabolism.exertion + metabolism.genericCost * metabolism.speed)
		metabolism.food = metabolism.food - cost
		metabolism.water = metabolism.water - cost
		
		local HUD = e:get(components.HUD)
		if HUD then
			if #HUD.metabolismGraph == graphics.barWidth + graphics.barOutlineThickness * 2 then
				table.remove(HUD.metabolismGraph, 1)
			end
			table.insert(HUD.metabolismGraph, metabolism.exertion)
		end
		
		metabolism.exertion = 0
	end
end

return tickMetabolisms
