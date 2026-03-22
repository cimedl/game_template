local HttpService = game:GetService("HttpService")

local helperUtils = {}

helperUtils.generateNewId = function()
	local id = HttpService:GenerateGUID(false)
	local dashIndex = string.find(id, "-", 1, true)
	if dashIndex then
		return string.sub(id, 1, dashIndex - 1)
	end
	return id
end

helperUtils.setupLeaderboardStatsOfPlayer = function(
	player: Player,
	options: { name: string, type: "String" | "Number", value: string | number }
)
	if not player then
		return
	end
	if not options or not options.type or not options.value then
		return
	end
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	local leaderboardStat = Instance.new(options.type .. "Value")
	if not leaderboardStat then
		return
	end

	leaderboardStat.Name = options.name
	leaderboardStat.Value = options.value
	leaderboardStat.Parent = leaderstats
end

helperUtils.getLeaderStatsOfPlayer = function(player: Player, leaderStat: string)
	assert(type(leaderStat) == "string", "Leaderstat arg parsed is not a string")
	if not player then
		return
	end

	if not leaderStat then
		return
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return
	end

	local statInstance = leaderstats:FindFirstChild(leaderStat)
	if not statInstance then
		return
	end

	return statInstance
end

return helperUtils
