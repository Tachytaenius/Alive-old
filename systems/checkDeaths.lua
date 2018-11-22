local kill = require("util.kill")
local concord = require("lib.concord")
local components = require("components")
local checkDeaths = concord.system({"byDamage", components.life, components.integrity}, {"byEnergy", components.life, components.metabolism})

function checkDeaths:update()
	local rng = self:getInstance().rng
	for i = 1, self.byDamage.size do
		local e = self.byDamage:get(i)
		local integrity = e:get(components.integrity)
		if integrity.current <= 0 then kill(e, rng):apply() end
	end
	for i = 1, self.byEnergy.size do
		local e = self.byEnergy:get(i)
		local metabolism = e:get(components.metabolism)
		if metabolism.speed <= 0 then kill(e, rng):apply() end
	end
end

return checkDeaths
