local PlayerService = require(script.Parent.PlayerService)

local RATE_LIMIT = 0.1
local SPAM_KICK_LIMIT = 20

local activeLimiterObjects = {}

local rateLimitService = {}
rateLimitService.__index = rateLimitService

rateLimitService.new = function(options: { perPlayerRateLimit: number, globalRateLimit: number })
    local self = setmetatable({
        activeRateLimiters = {},
        activeRateLimitSpams = {},

        globalRateLimit = (options and options.globalRateLimit) or RATE_LIMIT,
        perPlayerRateLimit = (options and options.perPlayerRateLimit) or RATE_LIMIT,

        previousUpdate = nil,
    }, rateLimitService)

    table.insert(activeLimiterObjects, self)
    return self
end

rateLimitService.isRateLimited = function(self, player: Player) : boolean
    if not self.activeRateLimiters[player.UserId] then
        self.activeRateLimiters[player.UserId] = 0
    end

    local now = os.clock()
    if now - self.activeRateLimiters[player.UserId] < self.perPlayerRateLimit then
        self.activeRateLimitSpams[player.UserId] = (self.activeRateLimitSpams[player.UserId] or 0) + 1
        if self.activeRateLimitSpams[player.UserId] > SPAM_KICK_LIMIT then
            warn(player.UserId, player.Name, "reached remote spam limit")
            player:Kick("Exceeded event call limit.")
        end
        return true
    end
    self.activeRateLimiters[player.UserId] = now
    self.activeRateLimitSpams[player.UserId] = nil

    return false
end

rateLimitService.isGlobalRateLimited = function(self) : boolean
    if not self.previousUpdate then
        self.previousUpdate = 0
    end

    local now = os.clock()
    if now - self.previousUpdate < self.globalRateLimit then
        return true
    end
    self.previousUpdate = now

    return false
end

rateLimitService.clearActiveLimiterForPlayer = function(player: Player)
    local rateLimitersOfPlayer = {}
    for _, rateLimiter in pairs(activeLimiterObjects) do
        if rateLimiter and (rateLimiter.activeRateLimiters[player.UserId] or rateLimiter.activeRateLimitSpams[player.UserId]) then
            table.insert(rateLimitersOfPlayer, rateLimiter)
        end
    end

    while #rateLimitersOfPlayer > 0 do
        local rateLimiter = table.remove(rateLimitersOfPlayer, 1)
        rateLimiter.activeRateLimitSpams[player.UserId] = nil
        rateLimiter.activeRateLimiters[player.UserId] = nil
    end
end

PlayerService.Profiles.PlayerRemoving:Connect(rateLimitService.clearActiveLimiterForPlayer)
return rateLimitService