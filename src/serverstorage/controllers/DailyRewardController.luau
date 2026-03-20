local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Helpers = require(ReplicatedStorage.utils.Helpers)
local DailyRewardTemplate = require(ServerScriptService.Templates.DailyRewardTemplate)

local Packets = require(ReplicatedStorage.utils.Packets)
local Players = require(ServerScriptService.Game.Players)
local PlayerService = require(ServerScriptService.Services.PlayerService)

local DAY_IN_SECONDS = 86400
local MAX_DAY = 7

local activePlayerThreads = {}

local rewardFunctions = {
   --[[
        RewardType = function(playerObj, reward)
        end 
   ]]
}

local resetDailyRewardOptions = function(dayRewards: {
    Reward: string | number | any,
    Claimed: boolean
})
    for dayNumber in pairs(dayRewards) do
        dayRewards[dayNumber] = {Reward = "none", Claimed = false}
    end
end

local setupDailyRewardOptions = function(dayRewards: {
    Reward: string | number | any,
    Claimed: boolean
})
    for dayNumber, rewardInfo in pairs(dayRewards) do
        if rewardInfo.Reward ~= "none" then
            continue
        end

        local rewardData = DailyRewardTemplate[dayNumber]
        if not rewardData then
            continue
        end

        if rewardData.Type ~= "Brainrot" then
            dayRewards[dayNumber].Reward = rewardData.Reward
            continue
        end

        local randomReward = true
        if not randomReward then
            warn("Could not select a random reward for", dayNumber)
            continue
        end

        dayRewards[dayNumber].Reward = randomReward
    end

    return dayRewards
end

local updateDailyData = function(dailyRewards: {
    Time: number,
    CurrentDay: number,
    Days: {
        { Reward: string | number | any, Claimed: boolean }
    }
})
    dailyRewards.Time = os.time()
    dailyRewards.CurrentDay += 1

    if dailyRewards.CurrentDay > MAX_DAY then
        resetDailyRewardOptions(dailyRewards.Days)
        setupDailyRewardOptions(dailyRewards.Days)
        dailyRewards.CurrentDay = 1
    end
end

local dailyRewardController = {}

dailyRewardController.updateDailyRewardsOnClaimed = function(player: Player, dayNumber: number)
    assert( type(dayNumber) == "number", "Parsed incorrect day type" )
    assert( 0 < dayNumber and dayNumber <= 7, "Parsed day isn't in range")

    local playerObj = Players[player.UserId]
    if not playerObj then
        return
    end

    if not playerObj.playerData then
        return
    end

    local dailyRewards = playerObj.playerData.DailyRewards
    if not dailyRewards then
        return
    end

    if not dailyRewards.Days then
        return
    end

    local dayData = dailyRewards.Days[dayNumber]
    if not dayData then
        warn(`Missing data for day {dayNumber}`)
        return
    end

    if dayNumber ~= dailyRewards.CurrentDay then
        return
    end

    if dayData.Claimed then
        return
    end

    local template = DailyRewardTemplate[dayNumber]
    if not template then
        warn("Missing template for day", dayNumber)
        return
    end

    local rewardFunction = template.Type
    if not rewardFunction then
        return
    end

    local rewardHandler = rewardFunctions[rewardFunction]
    if not rewardHandler then
        warn("Missing reward handler for type:", rewardFunction)
        return
    end
    
    rewardHandler(playerObj, dayData.Reward)
    dayData.Claimed = true

    return {
        daysData = dailyRewards.Days,
        currentDay = dailyRewards.CurrentDay,
        lastUpdate = dailyRewards.Time
    }
end

dailyRewardController.setupOnPlayerReady = function(player: Player)
    if not player then
        return
    end

    local playerObj = Players[player.UserId]
    if not playerObj then
        return
    end

    if not playerObj.playerData then
        return
    end

    local dailyRewards = playerObj.playerData.DailyRewards
    if not dailyRewards then
        return
    end

    if not dailyRewards.Days then
        return
    end

    setupDailyRewardOptions(dailyRewards.Days)

    local now = os.time()
    local lastUpdate = dailyRewards.Time
    local dayData = dailyRewards.Days[dailyRewards.CurrentDay]
    if not dayData then
        return
    end

    if (now - lastUpdate) < DAY_IN_SECONDS then
        if activePlayerThreads[player.UserId] then
            task.cancel(activePlayerThreads[player.UserId])
            activePlayerThreads[player.UserId] = nil
        end

        local timeToDelay = DAY_IN_SECONDS - (now - lastUpdate)
        activePlayerThreads[player.UserId] = task.delay(timeToDelay + 1, function()
            local response = dailyRewardController.setupOnPlayerReady(player)
            if not response then
                return
            end

            Packets.DailyRewardUpdate:FireClient(player, response)
        end)

         return {
            daysData = dailyRewards.Days,
            currentDay = dailyRewards.CurrentDay,
            lastUpdate = dailyRewards.Time,
        }
    end

    updateDailyData(dailyRewards)
    return {
        daysData = dailyRewards.Days,
        currentDay = dailyRewards.CurrentDay,
        lastUpdate = dailyRewards.Time,
    }
end

Packets.DailyRewardClaim.OnServerInvoke = dailyRewardController.updateDailyRewardsOnClaimed
Packets.DailyRewardEvent.OnServerInvoke = dailyRewardController.setupOnPlayerReady

PlayerService.Profiles.PlayerRemoving:Connect(function(player: Player)
    if not activePlayerThreads[player.UserId] then
        return
    end

    activePlayerThreads[player.UserId] = nil
end)

return dailyRewardController