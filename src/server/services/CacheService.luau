export type Cache = typeof(
    setmetatable({}:: { 
        ttl: number,
        cache: {[string]: any?},
        _timers: {[string]: thread}
    },
    {}))

local clearActiveThread = function(tbl: {[string]: thread}, key: string)
    if not tbl[key] then
        return
    end

    task.cancel(tbl[key])
    tbl[key] = nil
    return
end

local cacheService = {}
cacheService.__index = {}

cacheService.new = function(options: { ttl: number }?) : Cache
    return setmetatable({
        ttl = options and options.ttl,
        cache = {},
        _timers = {}
    }, cacheService)
end

cacheService.get = function(self: Cache, key: string)
    return self.cache[key]
end

cacheService.remove = function(self: Cache, key: string) : (boolean | any)?
    local exists = cacheService.get(self, key)
    if exists == nil then
        return false
    end

    self.cache[key] = nil
    clearActiveThread(self._timers, key)
    return exists
end

cacheService.put = function(self: Cache, key: string, data: any?) : (boolean | any)?
    local overwrite = false
    local overwrittenData = nil

    if self.cache[key] ~= nil then
        overwrite = true
        overwrittenData = self.cache[key]
    end

    self.cache[key] = data
    if self.ttl ~= nil then
        clearActiveThread(self._timers, key)
        self._timers[key] = task.delay(self.ttl, cacheService.remove, self, key)
    end
    return overwrite and overwrittenData
end

return cacheService