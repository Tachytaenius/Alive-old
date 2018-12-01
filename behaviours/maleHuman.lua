local components = require("components")
local core = require("const.core")
local assets = require("assets")

return function(e, x, y, theta, instance)
	return e
		:give(components.position, x, y, theta)
		:give(components.solidShape, 4, true, e, instance.collider:circle(x, y, 4))
		:give(components.integrity, 10)
		:give(components.tiredness, 9.5)
		:give(components.life)
		:give(components.actor)
		:give(components.mob, 2)
		:give(components.seenShapes)
		:give(components.senseCircle, 12, instance.collider, x, y)
		:give(components.viewSector, math.tau / 3.5, 512)
		:give(components.sprite, assets.images.mobs.malePlayer, 8)
		:give(components.beard, core.speed * 60 * 60 * 24)
		:give(components.puncher, 1.5, 2)
		:give(components.blink, 150, 4)
		:give(components.pose, {"stand", "walk1", "walk2", "walk3", "walk4"}, "stand", {all = {"stand"}}, 4, 8)
		:give(components.reach, 16)
		:give(components.HUD, true)
		:give(components.metabolism, 50, nil, nil, nil, 0.002)
end
