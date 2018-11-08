return function(constituents)
	local total = 0
	for _, quantity in pairs(constituents) do
		total = total + quantity
	end
	return total
end
