local PRECISION = 1000 

local numberUtils = {}

numberUtils.encodeValue = function(value: number): number
    if value <= 0 then return 0 end
    local log = math.log10(value)
    return math.floor(log * PRECISION)
end

numberUtils.decodeValue = function(encoded: number): number
    return math.pow(10, encoded / PRECISION)
end

numberUtils.formatNumber = function(number: number) : string
	local units = {
		{ 1e48, "QiDc" },
		{ 1e45, "QDc" },
		{ 1e42, "TDc" },
		{ 1e39, "DDc" },
		{ 1e36, "UDc" },
		{ 1e33, "Dc" },
		{ 1e30, "No" },
		{ 1e27, "Oc" },
		{ 1e24, "Sp" },
		{ 1e21, "Sx" },
		{ 1e18, "Qi" },
		{ 1e15, "Qd" },
		{ 1e12, "T" },
		{ 1e9, "B" },
		{ 1e6, "M" },
		{ 1e3, "K" },
	}

	for _, unit in ipairs(units) do
		if number >= unit[1] then
			return string.format("%.2f%s", number / unit[1], unit[2])
		end
	end

	return tostring(math.floor(number))
end

return numberUtils