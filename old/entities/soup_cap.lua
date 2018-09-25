local Pickable = classes.pickable
local SoupCap = class("SoupCap", Pickable)

SoupCap.growTime = constants.speedOfPlay * 60 * 30
SoupCap.spriteRadius = 4
SoupCap.solidRadius = 2
SoupCap.spritesheet = love.graphics.newImage("assets/images/entities/soup_cap.png")

return SoupCap
