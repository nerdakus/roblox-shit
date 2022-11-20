local function getIndex(layer: number)
	local s = ""
	for i = 1,layer do
		s = s .. "| "
	end
	return s
end

local function search(t: {[any]:any}, layer: number)
	for i,v in pairs(t) do
		local vT = typeof(v)
		if (vT == "table") then
			search(v, layer+1)
		else
			print(getIndex(layer)..v..": ["..vT.."]")
		end
	end
end

return function(t: {[any]:any})
	search(t, 1)
end
