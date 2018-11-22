local quadreasonable = require("lib.quadreasonable")
local concord = require("lib.concord")
local components = require("components")
local core = require("const.core")
local directions = require("const.directions")
local graphics = require("const.graphics")
local see = concord.system({components.camera})
local updateReach = require("util.updateReach")
local assets = require("assets")
local getSeenShapes = require("util.getSeenShapes")
local terrainTextures = assets.images.arrangements
local null = assets.images.misc.null

local function lookAt(viewer, viewee)
	local viewerPos = viewer:get(components.position)
	local vieweePos = viewee:get(components.position)
	local angle = vieweePos.theta and math.round(directions.count * ((vieweePos.theta - viewerPos.theta) % math.tau) / math.tau) % directions.count
	local x = viewerPos.x - vieweePos.x
	local y = viewerPos.y - vieweePos.y 
	local r, theta = math.cartesianToPolar(x, y)
	local angleDifference = (viewerPos.theta - theta + math.tau * 1.25) % math.tau - math.tau / 2
	x, y = math.polarToCartesian(r, theta - viewerPos.theta)
	local spriteRadius = viewee:get(components.sprite).size
	return math.round(x - spriteRadius), math.round(y - spriteRadius), angle
end

local newImageData = love.image.newImageData
local newImage = love.graphics.newImage
local newCanvas = love.graphics.newCanvas
local translate = love.graphics.translate
local setCanvas = love.graphics.setCanvas
local clear = love.graphics.clear
local setShader = love.graphics.setShader
local setBlendMode = love.graphics.setBlendMode
local setColour = love.graphics.setColor
local draw = love.graphics.draw
local circle = love.graphics.circle
local rectangle = love.graphics.rectangle
local origin = love.graphics.origin
local rotate = love.graphics.rotate

local scale = core.terrainScale
local falloffStart, falloffEnd = core.falloffStart, core.falloffEnd

local bigWidth, bigHeight = 1024, 1024
local lightInfoCanvas = newCanvas(bigWidth, bigHeight)
local lightCanvas = newCanvas(bigWidth, bigHeight)
local viewCanvas = newCanvas(bigWidth, bigHeight)
local crosshairs = assets.images.misc.crosshairs

local vec = {}

local function getQuad(entity, angle, sprite)
	sprite = sprite or entity:get(components.sprite)
	local batch = 0
	local spritesX, spritesY = 1, entity:has(components.pose) and #entity:get(components.pose).list or 1
	spritesY = spritesY * directions.count
	local componentIDForEntity = 1
	for _, component in ipairs(graphics.batchComponents) do
		local c = entity:get(component)
		if c then
			batch = batch + componentIDForEntity * c.impact
			spritesX = spritesX * (c.maxImpact + 1)
			componentIDForEntity = componentIDForEntity + 1
		end
	end
	
	return quadreasonable.getQuad(batch, (entity:has(components.pose) and entity:get(components.pose).impact or 0) * directions.count + angle, sprite.size * 2, sprite.size * 2, spritesX, spritesY, 2)
end

-- TODO: Consider replacing use of vec with use of premade tables wherever possible

function see:draw(targetPlayer, canvas)
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
	local textureShader = assets.shaders.texture.value
	local fragmentFalloffShader = assets.shaders.falloff.value
	local lightShader = assets.shaders.light.value
	local instance = self:getInstance()
	local collider = instance.collider
	local seenShapes = e:get(components.seenShapes)
	if not seenShapes.updated then
		getSeenShapes(e, collider)
	end
	local width = instance.width
	local height = instance.height
	local epos = e:get(components.position)
	local bigAddX, bigAddY = bigWidth / 2, bigWidth / 2
	local extra = e:has(components.senseCircle) and e:get(components.senseCircle).radius or 0
	local viewportAddX, viewportAddY = core.width / 2, core.height - extra
	local tiles, mobs, lights, occluders = seenShapes.tiles, seenShapes.mobs, seenShapes.lights, seenShapes.occluders
	
	translate(bigAddX, bigAddY)
	setCanvas(lightInfoCanvas)
	clear(1, 1, 1, 1)
	for occluder in pairs(occluders) do
		local occluderInfo = occluder.bag.occluderInfo
		setColour(occluderInfo.r, occluderInfo.g, occluderInfo.b, 1)
		local opos = occluder.owner:get(components.position)
		local drawX, drawY = epos.x - opos.x * 2, epos.y - opos.y * 2
		love.graphics.push()
		love.graphics.translate(drawX, drawY)
		local texture = occluderInfo.texture.value
		if texture then
			love.graphics.draw(texture, opos.x - texture:getWidth() / 2, opos.y - texture:getHeight() / 2)
		else
			occluder:draw("fill")
		end
		love.graphics.pop()
	end
	setShader(lightShader)
	setBlendMode("add")
	lightShader:send("occluders", lightInfoCanvas)
	setCanvas(lightCanvas)
	local r, g, b = instance:getLightLevel()
	clear(r, g, b, 1)
	vec[1], vec[2] = bigAddX, bigAddY
	lightShader:send("eyeLocation", vec)
	vec[3], vec[4] = math.tau, 0
	lightShader:send("lamp", true)
	for light in pairs(lights) do
		local x, y = light:center()
		light = light.bag
		x, y = epos.x - x, epos.y - y
		setColour(light.r, light.g, light.b, 1)
		vec[1], vec[2] = x + bigAddX, y + bigAddY
		lightShader:send("info", vec)
		local energy = light.energy
		draw(null.value, x - energy, y - energy, 0, energy * 2, energy * 2)
	end
	setCanvas(viewCanvas)
	setColour(1, 1, 1, 1)
	clear(0, 0, 0, 1)
	lightShader:send("lamp", false)
	local viewSector = e:get(components.viewSector)
	if viewSector then
		vec[1], vec[2], vec[3], vec[4] = bigAddX, bigAddY, viewSector.fov, epos.theta
		lightShader:send("info", vec)
		local falloff = viewSector.falloff - scale / 2
		draw(null.value, -falloff, -falloff, 0, falloff * 2)
	end
	setShader()
	local senseCircle = e:get(components.senseCircle)
	if senseCircle then
		circle("fill", 0, 0, senseCircle.radius)
	end
	setBlendMode("alpha")
	origin()
	translate(viewportAddX, viewportAddY)
	rotate(-epos.theta)
	setShader()
	setCanvas(canvas)
	setShader(textureShader)
	clear(0, 0, 0, 1)
	local power = e:has(components.viewSector) and math.ndLog(falloffEnd / falloffStart) / math.ndLog(e:get(components.viewSector).falloff / falloffStart) or 1
	vec[1], vec[2], vec[3], vec[4] = viewportAddX, viewportAddY, falloffStart, power
	textureShader:send("info", vec)
	textureShader:send("useNoise", true)
	local bedrockR, bedrockG, bedrockB = instance.bedrockR, instance.bedrockG, instance.bedrockB
	for tile in pairs(tiles) do
		local owner = tile.owner
		local tpos = owner:get(components.position)
		local drawX, drawY = epos.x - tpos.x - scale / 2, epos.y - tpos.y - scale / 2
		vec[1], vec[2] = math.floor(tpos.x / core.terrainScale), math.floor(tpos.y / core.terrainScale)
		textureShader:send("tileLocation", vec)
		local topping = owner:get(components.tile).topping
		if not topping or topping.noiseInfo[4] ~= 1 or topping.a < 1 then -- you don't really get toppings with patches, though
			textureShader:send("noiseInfo", instance.bedrockNoiseInfo)
			setColour(bedrockR, bedrockG, bedrockB, 1)
			draw(terrainTextures.base.value, drawX, drawY)
		end
		if topping then
			local superTopping = topping.superTopping
			if not superTopping or superTopping.noiseInfo[4] ~= 1 or superTopping.a < 1 then
				textureShader:send("noiseInfo", topping.noiseInfo)
				setColour(topping.r, topping.g, topping.b, topping.a)
				draw(topping.texture.value, drawX, drawY)
			end
			if superTopping and superTopping.noiseInfo[4] > 0 then -- grass, snow et cetera
				textureShader:send("noiseInfo", superTopping.noiseInfo)
				setColour(superTopping.r, superTopping.g, superTopping.b, superTopping.a)
				draw(superTopping.texture.value, drawX, drawY)
			end
		end
	end
	textureShader:send("useNoise", false)
	setColour(1, 1, 1, 1)
	rotate(epos.theta)
	local over = {}
	for mob in pairs(mobs) do
		local entity = mob.owner
		if entity ~= e and entity:has(components.sprite) then
			local sprite = entity:get(components.sprite)
			if sprite.floor then
				local screenX, screenY, angle = lookAt(e, entity)
				local quad = getQuad(entity, angle)
				draw(sprite.image, quad, screenX, screenY)
			else
				over[entity] = true
			end
		end
	end
	for entity in pairs(over) do
		if entity ~= e and entity:has(components.sprite) then
			local sprite = entity:get(components.sprite)
			local screenX, screenY, angle = lookAt(e, entity)
			local quad = getQuad(entity, angle)
			draw(sprite.image.value, quad, screenX, screenY)
		end
	end
	if e:has(components.sprite) then
		local sprite = e:get(components.sprite)
		draw(sprite.image.value, getQuad(e, directions.up, sprite), -sprite.size, -sprite.size)
	end
	origin()
	setShader(fragmentFalloffShader)
	vec[1], vec[2], vec[3], vec[4] = bigAddX, bigAddY, falloffStart, power
	fragmentFalloffShader:send("info", vec)
	setColour(1, 1, 1, 1)
	setBlendMode("multiply", "premultiplied")
	draw(lightCanvas, viewportAddX, viewportAddY, -epos.theta, 1, 1, bigAddX, bigAddY)
	draw(viewCanvas, viewportAddX, viewportAddY, -epos.theta, 1, 1, bigAddX, bigAddY)
	setBlendMode("alpha", "alphamultiply")
	setShader()
	local reach = e:get(components.reach)
	if reach then
		if not reach.updated then
			updateReach(e)
		end
		local crosshairsWidth, crosshairsHeight = crosshairs.value:getDimensions()
		draw(crosshairs.value, reach.dx - crosshairsWidth / 2, reach.dy - crosshairsHeight / 2, 0, 1, 1, -viewportAddX, -viewportAddY)
	end
end

return see
