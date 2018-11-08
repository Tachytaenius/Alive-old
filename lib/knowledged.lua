-- all TODO

local knowledged = {}

function knowledged.warn(text)
	print(text)
end

function knowledged.error(text)
	error(text)
end

return knowledged

