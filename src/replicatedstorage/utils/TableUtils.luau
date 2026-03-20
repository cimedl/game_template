local tableUtils = {}

tableUtils.sizeOf = function(tbl: {any})
    local count = 0 
    for _, _ in pairs(tbl) do
        count += 1
    end
    return count
end

return tableUtils