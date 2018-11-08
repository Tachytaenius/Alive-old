local core = {}

core.title = "Alive"
core.identity = "alive"

-- move gfx constants to const/graphics.lua

core.speed = 24 -- How many ticks in a second.
core.slowness = 1 / core.speed -- How long a tick should be in seconds.
core.terrainScale = 12
core.ditchDepth = 4 -- How many layers (terrainScale ^ 2) of a tile make up free space for dirt et cetera, and how much is for bedrock? Free space volume = terrainScale ^ 2 * ditchDepth
core.tilePadding = 1.5
core.pusheePenalty = 3
core.falloffStart = 120
core.falloffEnd = 240
core.width = 384
core.height = 256

return core
