local BaseEntity = classes.baseEntity
local Animal = class("Animal", BaseEntity)
local wall = constants.wall
local null = love.graphics.newImage(love.image.newImageData(1, 1))
local tau = math.tau
local round = math.round
local w, h = 1024, 1024 -- tmp
local lightInfoCanvas = love.graphics.newCanvas(w, h)
local lightCanvas = love.graphics.newCanvas(w, h)

local textureShader = love.graphics.newShader("shaders/texture.glsl")
local lightShader = love.graphics.newShader("shaders/light.glsl")
 
local crosshairs = love.graphics.newImage("assets/images/misc/crosshairs.png")
local crosshairsWidth, crosshairsHeight = crosshairs:getDimensions()

function Animal:initialize(player, dimension, spatials, stats, status, spritesheet)
	stats = stats or {}
	status = status or {}
	BaseEntity.initialize(self, player, dimension, spatials)
	if not player then -- NOTE: If "player" status is removed, aiInfo must be created. Whenever a player number is given aiInfo must be removed.
		self.aiInfo = {} -- What it's chasing, where it wants to be et cetera. Longer-term goals than actions.
	end
	self.endurance, self.strength, self.speed, self.agility, self.immunity, self.fov, self.falloff = stats.endurance or 8, stats.strength or 8, stats.speed or 2, stats.agility or 8, stats.immunity or 8, stats.fov or tau / 3.4, stats.falloff or 576
	self.hunger, self.damage, self.tiredness, self.manna, self.confusion, self.poison, self.flying, self.sleep, self.dead, self.noClip = status.hunger or 0, status.damage or 0, status.tiredness or 0, status.manna or 0, status.confusion or 0, status.poison or 0, status.flying or false, status.sleep or 0, status.dead or false, status.noClip or false
	self:generateViewShapes()
end

local insert = table.insert
local cos, sin = math.cos, math.sin
function Animal:generateViewShapes()
	local x, y, theta = self:getSpatials()
	local collider = self.dimension.collider
	local viewSectorVertices = {}
	self.viewSectorVertices = viewSectorVertices
	
	if self.viewSector then
		collider:remove(self.viewSector)
	end
	
	local spriteRadius, falloff = self.spriteRadius, self.falloff
	local angle = self.fov
	insert(viewSectorVertices, 0)
	insert(viewSectorVertices, 0)
	for theta = -angle/2, angle/2, angle / 8 do -- TODO: Sort out this maths
		theta = -theta % tau - tau/2
		insert(viewSectorVertices, falloff * cos(theta + tau/4))
		insert(viewSectorVertices, falloff * sin(theta + tau/4))
	end
	
	local sector = collider:polygon(unpack(viewSectorVertices))
	sector:move(x, y)
	sector:setRotation(theta + tau / 2, x, y)
	self.viewSector = sector
	if not self.viewCircle then
		self.viewCircle = collider:circle(x, y, self.senseRadius)
	else
		self.viewCircle:moveTo(x, y)
	end
end

local sin, cos = math.sin, math.cos

function Animal:think(key, seed) -- The second argument is there to let the AI treat itself differently to other entities.
	local actions = {x = 0, y = 0, theta = 0, speedMultiplier = 0}
	self.actions = actions
	local info = self.aiInfo
	local following = info.following
	if following then
		local lastX, lastY
		if self:canSeeEntity(following) then
			info.followingTimeNotSeenFor = 0
			lastX, lastY = following:getSpatials()
			info.followingLastSeenX, info.followingLastSeenY = lastX, lastY
		else
			info.followingTimeNotSeenFor = info.followingTimeNotSeenFor + 1
			lastX, lastY = info.followingLastSeenX, info.followingLastSeenY
		end
		
		if info.followingTimeNotSeenFor < constants.speedOfPlay * 4 then
			local selfX, selfY, selfTheta = self:getSpatials()
			
			-- delta angle
			local relX, relY = lastX - selfX, lastY - selfY
			local relR, relTheta = math.cartesianToPolar(relX, relY)
			local relTheta = (relTheta - self.theta - tau / 4) % tau
			local turnBy = relTheta > tau / 2 and -(tau - relTheta) or relTheta
			self.actions.theta = math.max(math.min(turnBy, tau / 64), -tau / 64)
			
			local moveDistance = math.max(relR - self.aiInfo.followingDistance, 0)
			local speedMultiplier = math.min(2, moveDistance / self.speed)
			self.actions.speedMultiplier = speedMultiplier
			self.actions.x, self.actions.y = sin(turnBy) * self.speed * speedMultiplier, cos(turnBy) * self.speed * speedMultiplier
		end
	end
end
function Animal:control(key, inputs, deltaInputs)
	self.actions = {x = 0, y = 0, theta = 0}
	local speed
	if inputs.run and not inputs.sneak then
		self.actions.speedMultiplier = 2 -- TODO: this isn't very smart is it
		speed = self.speed * 2
	elseif not inputs.run and inputs.sneak then
		self.actions.speedMultiplier = 0.5
		speed = self.speed * 0.5
	else
		self.actions.speedMultiplier = 1
		speed = self.speed
	end
	
	-- Are we moving on both axes?
	if ((inputs.strafeLeft and not inputs.strafeRight) or (not inputs.strafeLeft and inputs.strafeRight)) and ((inputs.forwards and not inputs.backwards) or (not inputs.forwards and inputs.backwards)) then
		speed = speed / 2 -- The speed is per-axis. Doing this if we're moving on both axes reduces the total speed to what it should be.
	end
	
	if inputs.turnLeft then self.actions.theta = self.actions.theta - tau / 128 * self.actions.speedMultiplier end
	if inputs.turnRight then self.actions.theta = self.actions.theta + tau / 128 * self.actions.speedMultiplier end
	
	if inputs.forwards and not inputs.backwards then self.actions.y = speed end
	if inputs.backwards and not inputs.forwards then self.actions.y = -speed end
	if inputs.strafeRight and not inputs.strafeLeft then self.actions.x = -speed end
	if inputs.strafeLeft and not inputs.strafeRight then self.actions.x = speed end
	
	if inputs.use then self.actions.dig = true end
	if deltaInputs.act then self.actions.toggleOutfit = true end
end

function Animal:getSeenShapes()
	local collider = self.dimension.collider
	local seenSector = collider:collisions(self.viewSector)
	local seenCircle = collider:collisions(self.viewCircle)
	local tiles, entities, underEntities, lights = {}, {}, {}, {}
	
	for k in pairs(seenSector) do
		if k.tile then
			tiles[k] = true
			seenCircle[k] = nil
		elseif k.entity then
			if k.entity.floor then
				underEntities[k] = true
			else
				entities[k] = true
			end
			seenCircle[k] = nil
		elseif k.light then
			lights[k] = true
			seenCircle[k] = nil
		end
	end
	
	for k in pairs(seenCircle) do
		if k.tile then
			tiles[k] = true
		elseif k.entity then
			if k.entity.floor then
				underEntities[k] = true
			else
				entities[k] = true
			end
		elseif k.light then
			lights[k] = true
		end
	end
	
	local occluders = {}
	for light in pairs(lights) do
		local newOccluders = collider:collisions(light)
		for occluder in pairs(newOccluders) do
			if occluder.tile and occluder.collisionType == wall then
				occluders[occluder] = true
			end
		end
	end
	
	return tiles, entities, underEntities, lights, occluders
end

function Animal:canSeeEntity(entity)
	local shape = entity.solidShape
	if self.viewCircle:collidesWith(shape) or self.viewSector:collidesWith(shape) then
		return true -- TODO
	end
end

local scale = constants.terrainScale
local materialIDs = constants.materialIDs
local abs, min, max, floor, cos, sin = math.abs, math.min, math.max, math.floor, math.cos, math.sin
function Animal:tick(random)
	local actions = self.actions
	
	-- Exert
	local exertion = 0.0001 + abs(actions.theta) / 16
	-- TODO: rest of exertion
	self.hunger = self.hunger + exertion
	self.tiredness = self.tiredness + exertion
	
	-- Turn
	local theta = (self.theta + actions.theta) % tau
	
	-- TODO: Do this in BaseEntity as well?
	-- Prepare for the move
	local s = sin(theta)
	local c = cos(theta)
	local actionsX, actionsY = actions.x, actions.y
	local yMove = (actionsX * s + actionsY * c)
	local xMove = (actionsX * c - actionsY * s)
	local reach = self.reach
	local reachXMove = (-reach * s)
	local reachYMove = (reach * c)
	local dimension = self.dimension
	local width = dimension.width
	local height = dimension.height
	
	local x, y = self.x + xMove, self.y + yMove
	
	local reachX, reachY = x + reachXMove, y + reachYMove
	
	if not (0 <= reachX and reachX <= width * scale and 0 <= reachY and reachY <= height * scale) then
		reachX, reachY = nil, nil
	end
	self.reachX, self.reachY = reachX, reachY
	self.x, self.y, self.theta = x, y, theta
	
	self.solidShape:moveTo(x, y)
	
	local xTile = floor(x / constants.terrainScale)
	local yTile = floor(y / constants.terrainScale)
	
	if actions.dig then
		dimension.tiles[floor(reachX / scale)][floor(reachY / scale)].collisionType = wall
	end
	if actions.toggleOutfit and self.toggleableOutfit then self.toggledOutfit = not self.toggledOutfit end
	self:generateViewShapes()
end

function Animal:kill() -- TODO: Ways to die affect look of corpse.
	self.dead = true
end

function Animal:checkDie(seed)
	-- TODO: Weigh up endurance, damage, randomness, tiredness et cetera.
	-- self:kill() return true
	return false
end

function Animal:lookAt(entity) -- TODO: Better name
	-- Return whether the entity could be seen.
	-- Return X and Y screen coordinates if it can, used in rendering.
	local vieweeX, vieweeY, vieweeTheta  = entity:getSpatials()
	local viewerX, viewerY, viewerTheta = self:getSpatials()
	local angle = round(constants.angles * ((vieweeTheta - viewerTheta) % tau) / tau) % constants.angles
	local x = viewerX - vieweeX
	local y = viewerY - vieweeY
	local r, theta = math.cartesianToPolar(x, y)
	local angleDifference = (viewerTheta - theta + tau * 1.25) % tau - tau / 2
	local inFOV = angleDifference <= self.fov / 2 and angleDifference >= -self.fov / 2
	local inRange = r - entity.spriteRadius <= self.falloff -- R won't be negative.
	local angle = round(constants.angles * ((vieweeTheta - viewerTheta) % tau) / tau) % constants.angles
	x, y = math.polarToCartesian(r, theta - viewerTheta)
	return round(x - entity.spriteRadius), round(y - entity.spriteRadius), angle
end
local colour, rect, circle, canvas, getCanvas = love.graphics.setColor, love.graphics.rectangle, love.graphics.circle, love.graphics.setCanvas, love.graphics.getCanvas
local getShader = love.graphics.getShader
local vec = {} -- recycled
local tileLocation = {}
local gfxLog = math.gfxLog
function Animal:see(viewportCanvasSetter)
	local width = self.dimension.width
	local height = self.dimension.height
	local selfX = self.x
	local selfY = self.y
	local selfTheta = self.theta
	local LaddX, LaddY = w / 2, h / 2
	local VPaddX = constants.viewportWidth / 2
	local VPaddY = constants.viewportHeight - self.spriteRadius * 2
	local falloff = self.falloff
	local tiles, entities, underEntities, lights, occludingTiles = self:getSeenShapes()
	
	love.graphics.translate(LaddX, LaddY)
	love.graphics.setCanvas(lightInfoCanvas)
	love.graphics.clear(1, 1, 1, 1)
	for tile in pairs(occludingTiles) do
		colour(0, 0, 0, 1)
		local drawX, drawY = self.x - tile.x * scale - scale, self.y - tile.y * scale - scale
		love.graphics.rectangle("fill", drawX, drawY, scale, scale)
	end
	
	love.graphics.setShader(lightShader)
	love.graphics.setBlendMode("add")
	lightShader:send("occluders", lightInfoCanvas)
	love.graphics.setCanvas(lightCanvas)
	local r, g, b = self.dimension:getLightLevel()
	love.graphics.clear(r, g, b, 1)
	for light in pairs(lights) do
		local x, y = light:center()
		x, y = selfX - x, selfY - y
		colour(light.r, light.g, light.b, 1)
		vec[1], vec[2] = x, y
		lightShader:send("drawpos", vec)
		local energy = light.energy
		love.graphics.draw(null, x - energy, y - energy, 0, energy * 2, energy * 2)
	end
	love.graphics.setColor(1, 1, 1, 1)
	
	love.graphics.setShader()
	love.graphics.origin()
	love.graphics.translate(VPaddX, VPaddY)
	love.graphics.rotate(-selfTheta)
	love.graphics.setShader(textureShader)	
	textureShader:send("use_noise", true)
	love.graphics.setCanvas(viewportCanvasSetter)
	love.graphics.clear(0, 0, 0, 1)
	for tile in pairs(tiles) do
		tile:draw(textureShader, selfX, selfY)
	end
	love.graphics.setBlendMode("multiply", "premultiplied")
	love.graphics.origin()
	love.graphics.setShader()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(lightCanvas, VPaddX, VPaddY, -selfTheta, 1, 1, LaddX, LaddY)
	love.graphics.setBlendMode("alpha", "alphamultiply")
	love.graphics.setCanvas()
end

return Animal
