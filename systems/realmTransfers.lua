local concord = require("lib.concord")
local components = require("components")
local realmTransfers = concord.system({components.actor})

function realmTransfers:update(_, _, realmChanges)
	for i = 1, self.pool.size do
		local e = self.pool:get(i)
		local actions = e:get(components.actor).actions
		if actions.toRealm then
			realmChanges[{from = self:getInstance(), to = toRealm, entity = e}] = true
		end
	end
end

return realmTransfers
