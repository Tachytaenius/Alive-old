local concord = require("lib.concord")
local components = require("components")
local core = require("const.core")
local preact = concord.system({"actors", components.actor}, {"movers", components.actor, components.mob})

function preact:update(commands, deltaCommands)
	for i = 1, self.actors.size do
		local e = self.actors:get(i)
		e:get(components.actor).actions = {}
	end
	for i = 1, self.movers.size do
		local e = self.movers:get(i)
		local actor = e:get(components.actor)
		actor.actions.x, actor.actions.y, actor.actions.theta = 0, 0, 0
		if actor.player then
			local playersCommands = commands[actor.player]
			local deltaPlayersCommands = deltaCommands[actor.player]
			
			local speed
			if playersCommands.run and not playersCommands.sneak then
				actor.actions.speedMultiplier = 2
				speed = e:get(components.mob).speed * 2
			elseif not playersCommands.run and playersCommands.sneak then
				actor.actions.speedMultiplier = 0.5
				speed = e:get(components.mob).speed * 0.5
			else
				actor.actions.speedMultiplier = 1
				speed = e:get(components.mob).speed * 1
			end
			-- Are we moving on both axes?
			if ((playersCommands.strafeLeft and not playersCommands.strafeRight) or (not playersCommands.strafeLeft and playersCommands.strafeRight)) and ((playersCommands.forwards and not playersCommands.backwards) or (not playersCommands.forwards and playersCommands.backwards)) then
				speed = speed / 2 -- The speed is per-axis. Doing this if we're moving on both axes reduces the total speed to what it should be.
			end
			if playersCommands.turnLeft then actor.actions.theta = actor.actions.theta - math.tau / 80 * actor.actions.speedMultiplier end
			if playersCommands.turnRight then actor.actions.theta = actor.actions.theta + math.tau / 80 * actor.actions.speedMultiplier end
			if playersCommands.forwards and not playersCommands.backwards then actor.actions.y = speed end
			if playersCommands.backwards and not playersCommands.forwards then actor.actions.y = -speed end
			if playersCommands.strafeRight and not playersCommands.strafeLeft then actor.actions.x = -speed end
			if playersCommands.strafeLeft and not playersCommands.strafeRight then actor.actions.x = speed end
			
			-- TODO: take components into account
			if deltaPlayersCommands.attack then actor.actions.punch = true end
			if deltaPlayersCommands.use then actor.actions.build = true end
			if deltaPlayersCommands.actionMenu then actor.actions.toggleOutfit = true end
		elseif e:has(components.ai) and e:get(componants.ai).active then
			
		end
	end
end

return preact
