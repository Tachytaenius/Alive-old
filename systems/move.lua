local concord = require("lib.concord")
local components = require("components")
local updateShapes = require("util.updateShapes")
local move = concord.system({components.actor, components.position, components.mob, components.life})

function move:update()
	for i = 1, self.pool.size do
		local e = self.pool:get(i)
		local actions = e:get(components.actor).actions
		local position = e:get(components.position)
		local s, c
		if position.theta then
			position.theta = (position.theta + actions.theta) % math.tau
			s = math.sin(position.theta)
			c = math.cos(position.theta)
		else
			s, c = 0, 1
		end
		local xMove = (actions.x * c - actions.y * s)
		local yMove = (actions.x * s + actions.y * c)
		position.x, position.y = position.x + xMove, position.y + yMove
		
		local metabolism = e:get(components.metabolism)
		if metabolism then
			metabolism.exertion = metabolism.exertion + math.sqrt(xMove ^ 2 + yMove ^ 2) / 4000 + math.abs(actions.theta) / 2000
		end
		updateShapes(e)
	end
end

return move
