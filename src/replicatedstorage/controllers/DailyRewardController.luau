local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LoadController = require(script.Parent.LoadController)
local TopbarPlus = require(ReplicatedStorage.packages.TopbarPlus)
local UiService = require(ReplicatedStorage.services.UiService)
local Packets = require(ReplicatedStorage.utils.Packets)

local DAY_IN_SECONDS = 86400

local buttons = UiService.buttons
local frames = UiService.frames

local currentDaySelected = 1
local currentDaysData = nil
local currentDay = 1

local thread = nil

local icon = TopbarPlus.new()
icon:setName("DailyRewards")
icon:setLabel("Daily Rewards!")
icon.toggled:Connect(function()
    -- frameObj:open()
end)

-- local closeObj = buttons.new(closeButton)
-- closeObj:config("x", 0.01)
-- closeObj:config("y", 0.01)
-- closeObj:set("activated", function()
--     icon:deselect()
-- end)

local structure = {}

local validateResponseData = function(response)
    if not response then
        return false
    end

    if not response.daysData then
        return false
    end

    if not response.currentDay then
        return false
    end

    if not response.lastUpdate then
        return false
    end

    return true
end

local updateTimerText = function(lastUpdate: number)
    local remaingTime = math.max(0, DAY_IN_SECONDS - (os.time() - lastUpdate))

    while remaingTime > 0 do
        task.wait(1)
        -- local remainingTimeFormatted = Helpers.formatTime(remaingTime)
        -- remainingTimeLabel.Text = remainingTimeFormatted

        remaingTime = math.max(0, DAY_IN_SECONDS - (os.time() - lastUpdate))
    end
end

local setupUiData = function(response)
    currentDaySelected = response.currentDay
    currentDay = response.currentDay
    currentDaysData = response.daysData 
    
    if not response.daysData[currentDay].Claimed then
        icon:notify()
        icon:select()
    end

    -- claimLabel.Text = response.daysData[currentDaySelected].Claimed and "Already Claimed!" or "Claim!"
    -- thread = task.spawn(updateTimerText, response.lastUpdate)
end

local dailyRewardsController = {}

dailyRewardsController.requestDailyRewardsData = function()
    -- setupUiStructureOfDailyRewards()

    -- local claimedObj = buttons.new(claimButton)
    -- claimedObj:config("x", 0.01)
    -- claimedObj:config("y", 0.01)
    -- claimedObj:set("activated", function()
    --     if currentDaySelected <= 0 then
    --         return
    --     end

    --     if currentDaySelected > 7 then
    --         return
    --     end

    --     local response: {
    --         daysData: {
    --             { Reward: string | number | any, Claimed: boolean }
    --         },
    --         currentDay: number,
    --         lastUpdate: number
    --     } = Packets.DailyRewardClaim:Fire(currentDaySelected)

    --     if not validateResponseData(response) then
    --         return
    --     end

    --     currentDaysData = response.daysData
    --     currentDay = response.currentDay

    --     icon:clearNotices()
    --     updateUiStates()
    --     updateUiText()
    -- end)

    local response: {
        daysData: {
            { Reward: string | number | any, Claimed: boolean }
        },
        currentDay: number,
        lastUpdate: number
    } = Packets.DailyRewardEvent:Fire()
    
    if not validateResponseData(response) then
        return
    end

    if thread ~= nil then
        task.cancel(thread)
        thread = nil
    end

    -- setupUiData(response)
    -- dailyRewardsController.setupUiState()
end

Packets.DailyRewardUpdate.OnClientEvent:Connect(function(response)
    if not validateResponseData(response) then
        return
    end

    if thread ~= nil then
        task.cancel(thread)
        thread = nil
    end

    setupUiData(response)
end)
LoadController.loaded:Connect(dailyRewardsController.requestDailyRewardsData)

return dailyRewardsController