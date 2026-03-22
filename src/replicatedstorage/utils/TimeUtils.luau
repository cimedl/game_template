local timeUtils = {}

timeUtils.formatTimeHours = function(seconds: number) : string
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    return string.format("%02d:%02d:%02d", h, m, s)
end

timeUtils.formatTimeMinutes = function(seconds: number) : string
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    return string.format("%02d:%02d", m, s)
end

return timeUtils