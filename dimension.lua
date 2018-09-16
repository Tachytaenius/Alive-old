local Dimension = class("Dimension")

local round = math.round
local ground = constants.ground
local grass, gravel, rock = classes.grass, classes.gravel, classes.rock
local tbs = constants.tileBorderSize
local scale = constants.terrainScale

local initTile = require("tile")

local insert = table.insert
local sin, cos, tau = math.sin, math.cos, math.tau
function Dimension:placePatch(rng, class, x, y, radius, quantity)
	local entities = self.entities
	for i = 1, quantity do
		local radius, angle = radius * rng:random(), rng:random() * tau
		local x, y = x + cos(angle) * radius, y + sin(angle) * radius
		insert(entities, class:generate(rng, self, x, y))
	end
end

function Dimension:initialize(width, height, rng, theme, time, length)
	length = length or constants.speedOfPlay * 60 * 60 -- an hour
	time = time or length / 2 -- midday
	self.width = width
	self.height = height
	self.entities = {}
	self.collider = hc.new(terrainScale)
	self.dayLength = length
	self.time = time
	self.tiles = {}
	
	local collider = self.collider
	local tiles = self.tiles
	for x = 0, self.width - 1 do
		local column = {}
		tiles[x] = column
		for y = 0, self.height - 1 do
			local newTile = collider:rectangle(x * scale - tbs, y * scale - tbs, scale + tbs * 2, scale + tbs * 2)
			initTile(newTile, self, rng, x, y)
			collider:register(newTile)
			column[y] = newTile
		end
	end
end

local twilightEtc = constants.twilightEtc
local tri, tau = math.tri, math.tau
function Dimension:getLightLevel()
	local sunLight = (tri(self.time / self.dayLength * tau - tau/4)+1)/2
	if twilightEtc then sunLight = sunLight * 0.75 + 0.125 end
	return sunLight, sunLight, sunLight
end

function Dimension:newPlayer(rng, gender, who, x, y, theta, relativeTo)
	local player
	if gender == "female" then
		player = classes.femalePlayer(who, self, {x, y, theta, relativeTo}, nil)
	elseif gender == "male" then
		player = classes.malePlayer(who, self, {x, y, theta, relativeTo}, nil)
	end
	table.insert(self.entities, player)
	table.insert(self.entities, classes.ghostMaiden(nil, self, {x, y, theta, relativeTo}))
	return player
end

local distance, floor = math.distance, math.floor
local distanceScale = constants.lightDistanceScale

return Dimension
