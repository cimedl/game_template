local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networker = require(ReplicatedStorage.utils.networker.Networker)

return {
    LoadEvent = Networker("LoadEvent", Networker.Any),
    DailyRewardEvent = Networker("DailyRewardEvent"):Response(Networker.Any),
	DailyRewardClaim = Networker("DailyRewardClaim", Networker.NumberU8):Response(Networker.Any),
	DailyRewardUpdate = Networker("DailyRewardUpdate", Networker.Any),
}