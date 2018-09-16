local Human = classes.human
local FemalePlayer = class("FemalePlayer", Human)

FemalePlayer.toggleableOutfit = true -- cloak hood and hands in or out
FemalePlayer.spritesheet = love.graphics.newImage("assets/images/entities/female_player.png")

function FemalePlayer:initialize(player, dimension, spatials, name)
	local status = {gender = "female"}
	local stats = {}
	Human.initialize(self, player, dimension, spatials, status, stats) -- TODO: Stats and status.
end

return FemalePlayer
