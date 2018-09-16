local Chair = classes.chair

local WoodenChair = class("WoodenChair", Chair)

WoodenChair.spriteRadius = 8
WoodenChair.spritesheetWidth, WoodenChair.spritesheetHeight = 36, 72
WoodenChair.solidRadius = 7
WoodenChair.immovability = 100
WoodenChair.spritesheet = love.graphics.newImage("assets/images/entities/wooden_chair.png")

function WoodenChair:initialize(dimension, spatials, integrity)
	Chair.initialize(self, dimension, spatials, integrity, 300)
end

return WoodenChair
