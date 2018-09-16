local Human = classes.human
local FoxSpirit = class("FoxSpirit", Human)

function FoxSpirit:initialize(player, dimension, spatials, name)
	local status = {gender = "female"}
	local stats = {}
	self.spritesheet = love.graphics.newImage("assets/images/entities/fox_spirit.png")
	Human.initialize(self, player, dimension, spatials, status, stats) -- TODO: Stats and status.
end

return FoxSpirit
