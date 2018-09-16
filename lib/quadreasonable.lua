-- Quadreasonable. Useful quads library.
-- By Tachytaenius.
-- MIT license.

local quadreasonable = {} -- Quadtastic was already taken ;-)

local quads = {}
local newQuad = love.graphics.newQuad

function quadreasonable.getQuad(spriteX, spriteY, spriteWidth, spriteHeight, spriteCountX, spriteCountY, padding)
	padding = padding or 2
	local current
	
	if not quads[spriteX] then
		quads[spriteX] = {}
	end
	current = quads[spriteX]
	
	if not current[spriteY] then
		current[spriteY] = {}
	end
	current = current[spriteY]
	
	if not current[spriteWidth] then
		current[spriteWidth] = {}
	end
	current = current[spriteWidth]
	
	if not current[spriteHeight] then
		current[spriteHeight] = {}
	end
	current = current[spriteHeight]
	
	if not current[spriteCountX] then
		current[spriteCountX] = {}
	end
	current = current[spriteCountX]
	
	if not current[spriteCountY] then
		current[spriteCountY] = {}
	end
	current = current[spriteCountY]
	
	if not current[padding] then
		local x = spriteX * spriteWidth + (spriteX + 1) * padding
		local y = spriteY * spriteHeight + (spriteY + 1) * padding
		local sheetWidth = spriteCountX * spriteWidth + (spriteCountX + 1) * padding
		local sheetHeight = spriteCountY * spriteWidth + (spriteCountY + 1) * padding
		current[padding] = newQuad(x, y, spriteWidth, spriteHeight, sheetWidth, sheetHeight)
		print(x, y, spriteWidth, spriteHeight, sheetWidth, sheetHeight)
	end
	return current[padding]
end

function quadreasonable.pregenerate()
	
end

quadreasonable.quads = quads

return quadreasonable

-- My dog used to chase people on bikes a lot.
-- Eventually I had to confiscate his collection.
