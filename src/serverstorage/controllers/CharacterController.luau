local ServerScriptService = game:GetService("ServerScriptService")
local Players = require(ServerScriptService.Game.Players)

local _debug = false

local registry = {}

local function register_character_added(funcName: string, func: () -> any?)
	if not registry[funcName] then
		registry[funcName] = func
	end
end

local function OnCharacterAdded(character: Model?)
	task.wait()
	local player = game.Players:GetPlayerFromCharacter(character)

	local user_id = player.UserId
	local playerObj = Players[user_id]

	local data = {
		player = player,
		playerObj = playerObj,
		character = character,
	}

	for k, func in pairs(registry) do
		task.spawn(func, data)

		if _debug then
			print(`[CharacterController]: Loaded {k}.`)
		end
	end
end

return {
	register_character_added = register_character_added,
	OnCharacterAdded = OnCharacterAdded,
}
