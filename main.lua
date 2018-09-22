love.graphics.setDefaultFilter("nearest", "nearest", 0)
love.graphics.setLineStyle("rough")
math = require("lib/mathsies")
quadreasonable = require("lib/quadreasonable")
require("utilities")
class = require("lib/middleclass")
require("materials")
require("classes")
settings = getSettings()
ffi = require("ffi")
hc = require("lib/HC") -- references "math" which is now mathsies, making it deterministic.

local state
local canvas = love.graphics.newCanvas()
local gameX, gameY = renewScreen()
local paused = false
local player1 = {}
local shader = love.graphics.newShader("shaders/depth.glsl")
--[[Specials:
< = open quote
> = close quote
$ = interrobang
{ = en dash
} = em dash
^ = degrees
£ = currency
# = exclamation comma
@ = question comma
~ = interrobang comma

everything else is what it represents
]]

local font = love.graphics.newImageFont("assets/images/misc/font.png", " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz.!?$,#@~:;-{}|&()<>'[]^£%/\\*0123456789")

local time

local Dimension = classes.dimension
local dims, viewport, lastInputs, rng, rand
local cameraEntity
local slowness = constants.slownessOfPlay
local scale = constants.terrainScale
local function initialisePlay(seed, recordName, loadedFrom)
	rng = love.math.newRandomGenerator()
	rand = rng.random
	rng:setSeed(seed)
	lastInputs = {{}} -- One per player.
	viewport = {love.graphics.newCanvas(constants.viewportWidth, constants.viewportHeight), stencil = true}
	
	local width = 250 -- In tiles, not in pixels. If it were in pixels that value would be multiplied by constants.terrainScale.
	local height = 250
	
	dims = {}
	
	local overworld = Dimension(width, height, rng, "maacian overworld", 0, 1000000)
	cameraEntity = overworld:newPlayer(rng, "male", 1, width * scale / 2, height * scale / 2, 2)
	table.insert(dims, overworld)
end

local huge = math.huge
local window = constants.window
local sqrt = math.sqrt
local window, wall = constants.window, constants.wall
local relevantTiles = {} -- recycled
local takenDamage = constants.takenDamage -- tile change nature id
local function tickPlay(...)
	-- Get actions.
	for _, dimension in ipairs(dims) do
		-- AIs and players only differ in how they decide what they want to do.
		-- Players process inputs...
		-- AIs process the world around them...
		-- Both to create "actions," ready for use in pass 2.
		
		for entityKey, entity in ipairs(dimension.entities) do
			local inputter = entity.player
			if inputter then
				local inputs = select(inputter, ...)
				local control = entity.control
				if control then control(entity, entityKey, inputs, getDeltas(lastInputs[inputter], inputs)) end
			else
				local think = entity.think
				if think then
					think(entity, entityKey, rng)
				end
			end
		end
	end
	
	local dimensionChanges = {}
	-- Run actions.
	for dimensionID, dimension in ipairs(dims) do
		-- Add this dimension to the list of dimension changes.
		dimensionChanges[dimensionID] = {}
		
		for entityID, entity in ipairs(dimension.entities) do
			if entity.tick and not entity.new then
				local containedBy = entity.containedBy
				local result = containedBy and containedBy:tickContainedEntity(entity, rng) or entity:tick(rng)
				dimensionChanges[dimensionID][entityID] = result
			end
			if entity.new then entity.new = false
			elseif entity.new == false then entity.new = nil end -- No drawing until it's REALLY not new. TODO: wtf am i talking about
		end
	end
	
	-- Collide!!
	for _, dimension in ipairs(dims) do
		local collider = dimension.collider
		local collisionsFunction = collider.collisions
		
		-- tiles
		for _, entity in pairs(dimension.entities) do
			for shape in pairs(collisionsFunction(collider, entity.solidShape)) do
				if shape.tile then
					relevantTiles[shape] = true
				end
			end
		end
		
		local collisions = {}
		for shape in pairs(relevantTiles) do
			relevantTiles[shape] = nil -- recycling is good for the planet!
			local type = shape.collisionType
			if type == window or type == wall then
				for other, vector in pairs(dimension.collider:collisions(shape)) do
					local entity = other.entity
					if entity then
						other:move(-vector.x, -vector.y)
						local x, y = other:center()
						local _, _, theta = entity:getSpatials()
						entity:setSpatials(x, y, theta)
					end
				end
			end
		end
		
		-- entities
		local collisions = {}
		for entityID, entity in ipairs(dimension.entities) do
			collisions[entityID] = collisionsFunction(collider, entity.solidShape)
		end
		for entityID, entity in ipairs(dimension.entities) do
			for other, vector in pairs(collisions[entityID]) do
				local vectorX, vectorY = vector.x, vector.y
				if other.entity then
					if not (other.entity.nonBlocking or entity.nonBlocking) then
						local pusherFactor, pusheeFactor -- Factor is how much they are affected by the vector-- greater values mean more push
						-- Could also check to see if they're both math.huge, but this way incorporates *any* identical immovabilities quickly.
						local entityImmovability, otherEntityImmovability = entity.immovability, other.entity.immovability
						local pusheeImmovability, pusherImmovability = otherEntityImmovability / constants.pusheePenalty, entityImmovability
						if pusheeImmovability == pusherImmovability then
							pusherFactor = 0.5
						elseif pusheeImmovability == huge and pusherImmovability ~= huge then
							pusherFactor = 1
						elseif pusheeImmovability ~= huge and pusherImmovability == huge then
							pusherFactor = 0
						else
							pusherFactor = otherEntityImmovability / (entityImmovability + otherEntityImmovability)
						end
						pusheeFactor = (1 - pusherFactor)
						local entityX, entityY, entityTheta = entity:getSpatials()
						local otherEntityX, otherEntityY, otherEntityTheta = other.entity:getSpatials()
						if otherEntityX == entityX and otherEntityY == entityY then
							-- Randomise direction of vector
							local angle = rand(rng, math.tau)
							local distance = sqrt(vectorX ^ 2 + vectorY ^ 2)
							vectorX, vectorY = math.polarToCartesian(distance, angle)
						end
						entity:setSpatials(entityX + pusherFactor * vectorX, entityY + pusherFactor * vectorY, entityTheta)
						other.entity:setSpatials(otherEntityX + pusheeFactor * -vectorX, otherEntityY + pusheeFactor * -vectorY, otherEntityTheta)
					end
				end
			
			end
		end
	end
	
	-- Move any entities that changed dimensions.
	for fromID, changesList in ipairs(dimensionChanges) do
		local from = dims[fromID]
		local fromCollider = from.collider
		local fromRemove = fromCollider.remove
		local fromEntities = from.entities
		for entityToBeMovedID, toID in pairs(changesList) do
			local from, to = dims[fromID], dims[toID]
			local entityToBeMoved = from.entities[entityToBeMovedID]
			local solidShape, viewSector, viewCircle = entityToBeMoved.solidShape --, entityToBeMoved.viewSector, entityToBeMoved.viewCircle
			local toCollider = to.collider
			local entityToBeMoved = table.remove(fromEntities, entityToBeMovedID)
			fromRemove(fromCollider, solidShape)
			entityToBeMoved.dimension = to
			entityToBeMoved:reregisterSolidShape()
			--[[ remade every frame anyway
			local toRegister = toCollider.register
			fromRemove(fromCollider, viewSector)
			toRegister(toCollider, viewSector)
			fromRemove(fromCollider, viewCircle)
			toRegister(toCollider, viewCircle)
			]]
			table.insert(to.entities, entityToBeMoved)
		end
	end
	
	-- Kill any entities that should be dead, knock entities back, tick the dimension time, et cetera.
	for _, dimension in ipairs(dims) do
		for _, entity in ipairs(dimension.entities) do
			if entity.checkDie then entity:checkDie(rng) end
			entity.x = entity.x + entity.knockX
			entity.knockX = 0
			entity.y = entity.y + entity.knockY
			entity.knockY = 0
		end
		dimension.time = (dimension.time + 1) % dimension.dayLength
	end
	
	-- Tiles queue up their changes and then apply them at the end of each tick.
	-- changes can be found in tile.lua as a global. TODO: FIXME
	for change in pairs(changes) do
		changes[change] = nil
		local nature = change.nature
		local tile = change.tile
		if change.nature == takenDamage then
			local amount, dx, dy = change.amount, change.dx, change.dy
			-- TODO: fling wall constituents out in the dx, dy direction
		end
	end
	
	-- Save the inputs.
	for inputter, inputs in pairs({...}) do
		lastInputs[inputter] = copy(inputs)
	end
end

local function drawPlay()
	if cameraEntity then
		local original = love.graphics.getCanvas()
		if cameraEntity.new == nil and cameraEntity.see then
			cameraEntity:see(viewport)
		end
		love.graphics.setCanvas(original)
		love.graphics.draw(viewport[1], constants.viewportX, constants.viewportY)
	else
		love.graphics.clear(0, 0, 0, 1)
	end
end

-- callbacks

function love.update()
	if not paused then
		if not state then
			state = "play"
			initialisePlay(0)
		end -- TODO: splash first
		time = love.timer.getTime()
		if state == "play" then
			tickPlay(player1)
		elseif state == "splash" then
			-- tickSplash(player1)
		end
	end
end

local colour = love.graphics.setColor
function love.draw()
	love.graphics.setFont(font)
	if not paused then
		love.graphics.setCanvas(canvas)
		if state == "play" then
			drawPlay()
		elseif state == "splash" then
			-- drawSplash()
		end
		love.graphics.setCanvas()
	end
	love.graphics.setShader(shader)
	love.graphics.draw(canvas, gameX, gameY, 0, settings.graphics.scale)
	local wait = slowness - (love.timer.getTime() - time)
	love.graphics.setShader()
	if paused then
		love.graphics.print("PAUSED", 0, 0, 0, settings.graphics.scale)
	elseif settings.info.showPerformance then
		local performance = wait / slowness
		colour(1 - performance, performance, 0, 1)
		love.graphics.print(math.round(performance * 100) .. "%", 0, 0, 0, settings.graphics.scale)
		colour(1, 1, 1, 1)
	end
	love.timer.sleep(math.max(wait, 0))
end

-- Scancodes, not KeyConstants.
function love.keypressed(_, key)
	local action = settings.controls[key]
	if action then
		player1[action] = true -- not the same as entity.actions
	end
end

function love.keyreleased(_, key)
	local action = settings.controls[key]
	if action == "pause" then
		paused = not paused
	elseif action == "screenshot" then
		takeScreenshot(canvas)
	elseif action == "scaleDown" then
		if settings.graphics.scale > 1 then
			settings.graphics.scale = settings.graphics.scale - 1
			gameX, gameY = renewScreen()
			setSettings()
		end
	elseif action == "scaleUp" then
		settings.graphics.scale = settings.graphics.scale + 1
		gameX, gameY = renewScreen()
		setSettings()
	elseif action == "toggleFullscreen" then
		settings.graphics.fullscreen = not settings.graphics.fullscreen
		gameX, gameY = renewScreen()
		setSettings()
	elseif action == "toggleInfo" then
		settings.info.showPerformance = not settings.info.showPerformance
		setSettings()
	elseif action then
		player1[action] = nil
	end
end

-- splash

-- put splash.lua here after processing
