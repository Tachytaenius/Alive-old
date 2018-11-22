local concord = require("lib.concord")
local core = require("const.core")

return concord.component(
function(e, capacity, genericCost, food, water, dangerousExertionLevel)
		e.capacity = capacity
		e.genericCost = genericCost or 1 / (core.speed * 60 * 30)
		e.food = food or not water and capacity / 2
		e.water = water or capacity - e.food
		e.exertion = 0
		e.dangerousExertionLevel = dangerousExertionLevel
	end
)
