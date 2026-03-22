local tableUtils = {}

tableUtils.sizeOf = function(tbl: { any })
	local count = 0
	for _, _ in pairs(tbl) do
		count += 1
	end
	return count
end

tableUtils.deepCopy = function(tbl: { [any]: any }): { [any]: any }
	local copy = {}
	for k, v in pairs(tbl) do
		copy[k] = type(v) == "table" and tableUtils.deepCopy(v) or v
	end
	return copy
end

tableUtils.safeClear = function(tbl: { [any]: any }, callback: ((obj: any) -> ())?)
	local keys: { any } = {}
	for key in pairs(tbl) do
		keys[#keys + 1] = key
	end
	for _, key in ipairs(keys) do
		if callback then
			callback(tbl[key])
		end
		tbl[key] = nil
	end
end

return tableUtils