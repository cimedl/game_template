local config = {
	_dataPrefix = "TEST_",
	_dataVersion = "V1",

	_leaderboardVersion = "TEST_V2",

	studioMode = true
}

--[[
	CORRECT ONES

	_dataPrefix = "DATA_",
	_dataVersion = "V1",

	_leaderboardVersion = "DATA_V1",
]]

table.freeze(config)
return config
