local concord = require("lib.concord")
local assets = require("assets")
local components = require("components")
local renderHUD = concord.system({components.HUD})

local graphics, core = require("const.graphics"), require("const.core")

local setColor, rectangle, printf, line = love.graphics.setColor, love.graphics.rectangle, love.graphics.printf, love.graphics.line

function renderHUD:draw(targetPlayer)
	if not targetPlayer then return end
	local e
	for i = 1, self.pool.size do
		local _e = self.pool:get(i)
		local player = _e:has(components.camera) and _e:get(components.camera).player
		if targetPlayer == player then -- TODO: Just "if targetPlayer is in pool"
			e = _e
			break
		end
	end
	if not e then return end
	
	local HUD = e:get(components.HUD)
	
	local integrity = e:get(components.integrity)
	if integrity then
		local x, y = 2 + graphics.barOutlineThickness, core.height - (2 + graphics.barHeight + graphics.barOutlineThickness)
		setColor(graphics.barOutlineColour)
		rectangle("fill", x - graphics.barOutlineThickness,  y - graphics.barOutlineThickness, graphics.barWidth + graphics.barOutlineThickness * 2, graphics.barHeight + graphics.barOutlineThickness * 2)
		setColor(0.1, 0.1, 0.1)
		rectangle("fill", x, y, graphics.barWidth, graphics.barHeight)
		setColor(0.8, 0.2, 0.2)
		rectangle("fill", x, y, graphics.barWidth * integrity.current / integrity.maximum, graphics.barHeight)
		setColor(1, 1, 1)
		printf(math.round(integrity.maximum), x, y - 2, graphics.barWidth, "center")
	end
	local metabolism = e:get(components.metabolism)
	if metabolism then
		local x, y = core.width - (2 + graphics.barOutlineThickness + graphics.barWidth), core.height - (2 + graphics.barHeight + graphics.barOutlineThickness)
		setColor(graphics.barOutlineColour)
		rectangle("fill", x - graphics.barOutlineThickness,  y - graphics.barOutlineThickness, graphics.barWidth + graphics.barOutlineThickness * 2, graphics.barHeight + graphics.barOutlineThickness * 2)
		setColor(0.1, 0.1, 0.1)
		rectangle("fill", x, y, graphics.barWidth, graphics.barHeight)
		setColor(0.8, 0.4, 0.2)
		rectangle("fill", x, y, graphics.barWidth * metabolism.food / metabolism.capacity, graphics.barHeight)
		setColor(0.3, 0.3, 0.8)
		rectangle("fill", x + graphics.barWidth, y, -graphics.barWidth * metabolism.water / metabolism.capacity, graphics.barHeight)
		setColor(1, 1, 1)
		printf(math.round(metabolism.capacity), x, y - 2, graphics.barWidth, "center")
		if HUD.metabolismGraph and metabolism.dangerousExertionLevel then
			for i, v in ipairs(HUD.metabolismGraph) do
				local danger = v / metabolism.dangerousExertionLevel
				setColor(danger, 1 - danger, 0)
				line(x - graphics.barOutlineThickness + i, y - graphics.barOutlineThickness, x - graphics.barOutlineThickness + i, y - graphics.barOutlineThickness - 1 - math.min(danger * 5, 5))
			end
		end
	end
	
	love.graphics.setColor(1, 1, 1, 1)
end

return renderHUD
