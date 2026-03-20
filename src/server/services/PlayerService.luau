local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local playerService = game:GetService("Players")

local _debug = true

local Players = require(ServerScriptService.Game.Players)
local ProfileService = require(ServerScriptService.ServerPackages.ProfileService)
local ProfileTemplate = require(ServerScriptService.Templates.ProfileTemplate)
local VersionConfig = require(ServerScriptService.Templates.VersionConfig)
local Signal = require(ReplicatedStorage.packages.Signal)

local PlayerComponent = require(ServerStorage.components.PlayerComponent)
local ProfileStore = ProfileService.GetProfileStore(`{VersionConfig._dataPrefix}{VersionConfig._dataVersion}`, ProfileTemplate)
if VersionConfig.studioMode then
	ProfileStore = ProfileService.GetProfileStore(`{VersionConfig._dataPrefix}{VersionConfig._dataVersion}_MOCK`, ProfileTemplate).Mock
end

local registry = {}
local Profiles = { PlayerAdded = Signal.new(), PlayerReady = Signal.new(), PlayerRemoving = Signal.new() }

local function PlayerAdded(player: Player)
	local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)

	if profile ~= nil then
		profile:AddUserId(player.UserId)
		profile:Reconcile()

		profile:ListenToRelease(function()
			Profiles[player] = nil
			Players[player.UserId] = nil
			player:Kick()
		end)

		if player:IsDescendantOf(playerService) == true then
			Profiles[player] = profile

			Players[player.UserId] = PlayerComponent.new(player, profile.Data)
			Profiles.PlayerAdded:Fire(player)
			Profiles.PlayerReady:Fire(player)
		else
			profile:Release()
			Players[player.UserId] = nil
		end
	else
		player:Kick()
		Players[player.UserId] = nil
	end
end

local function PlayerRemoving(player: Player)
	local playerComponent = Players[player.UserId]
	if not playerComponent then
		return
	end

	for _, func in pairs(registry) do
		func(playerComponent)
	end

	if playerComponent ~= nil then
		print("[PlayerService]: Player Component Removed:", playerComponent)
		playerComponent:Destroy()
	end

	local profile = Profiles[player]

	if profile ~= nil then
		profile:Release()
		Players[player.UserId] = nil
	end

	Profiles.PlayerRemoving:Fire(player)
end

local function ReloadAllPlayers()
	for _, player in pairs(game.Players:GetPlayers()) do
		player:LoadCharacterAsync()
	end
end

local function RegisterPlayerLeaving(funcName: string, func: () -> any?)
	if not registry[funcName] then
		registry[funcName] = func
	end
end

for _, player in ipairs(playerService:GetPlayers()) do
	task.spawn(PlayerAdded, player)
end

playerService.PlayerAdded:Connect(PlayerAdded)
playerService.PlayerRemoving:Connect(PlayerRemoving)

return {
	Profiles = Profiles,
	ReloadAllPlayers = ReloadAllPlayers,
	RegisterPlayerLeaving = RegisterPlayerLeaving,
}
