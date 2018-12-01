local concord = require("lib.concord")
local components = require("components")
local tick = concord.system({"beards", components.life, components.beard}, {"blinkers", components.life, components.blink}, {"walkers", components.actor, components.pose, components.life}, {"outfitTogglers", components.life, components.toggleOutfit}, {"corpses", components.rot})

function tick:update()
	local instance = self:getInstance()
	local rng = instance.rng
	instance.time = (instance.time + 1) % instance.dayLength
	
	for i = 1, self.beards.size do
		local beard = self.beards:get(i):get(components.beard)
		beard.current = math.min(beard.current + 1, beard.maximum)
		if beard.current == beard.maximum then beard.impact = 1 else beard.impact = 0 end
	end
	
	for i = 1, self.blinkers.size do
		local blink = self.blinkers:get(i):get(components.blink)
		blink.current = (blink.current + 1) % blink.speed * blink.modifier
		if blink.current < blink.length / blink.modifier then blink.impact = 1 else blink.impact = 0 end
	end
	
	for i = 1, self.walkers.size do
		local e = self.walkers:get(i)
		local actor, pose = e:get(components.actor), e:get(components.pose)
		if pose.walkStages then
			if actor.actions.x ~= 0 or actor.actions.y ~= 0 then
				pose.moved = true
				pose.walkTimer = (pose.walkTimer + actor.actions.speedMultiplier) % pose.walkLoopSpeed
				pose.impact = pose.walkStart + math.floor(pose.walkTimer / pose.walkFrameTime) - 1
			elseif pose.moved then
				pose.moved = false
				pose.walkTimer = 0
				pose.current = "stand"
				pose.impact = pose.byName.stand
			end
		end
	end
	
	for i = 1, self.outfitTogglers.size do
		local e = self.outfitTogglers:get(i)
		local toggleOutfit = e:get(components.toggleOutfit)
		local actor = e:get(components.actor)
		toggleOutfit.toggling = toggleOutfit.toggling * (actor.actions.toggleOutfit and -1 or 1)
		local tiredness = e:get(components.tiredness)
		if tiredness and math.abs(toggleOutfit.state) ~= toggleOutfit.timeRequired / 2 then
			tiredness.current = tiredness.current + toggleOutfit.cost
			toggleOutfit.impact = (math.sgn(toggleOutfit.state) + 1) / 2
		end
		toggleOutfit.state = math.min(math.max(-toggleOutfit.timeRequired / 2, toggleOutfit.state + toggleOutfit.toggling), toggleOutfit.timeRequired / 2)
	end
	
	for i = 1, self.corpses.size do
		local e = self.corpses:get(i)
		local rot = e:get(components.rot)
		rot.current = math.min(rot.current + rot.speed, rot.stages)
	end
end

return tick
