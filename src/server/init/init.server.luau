local Services = {}
local _debug = false

for _, service in pairs(game.ServerScriptService.Services:GetChildren()) do
	if service then
		Services[service.Name] = require(service)

		if _debug then
			print(`[ServiceLoader]: {service.Name} loaded.`)
		end
	end
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local Packets = require(ReplicatedStorage.utils.Packets)
local Players = require(ServerScriptService.Game.Players)
local VersionConfig = require(ServerScriptService.Templates.VersionConfig)
local CharacterController = require(ServerStorage.controllers.CharacterController)

if VersionConfig.studioMode then
	warn("\n\n\n -- << RUNNING IN STUDIO MODE >> -- \n\n\n")
end

Packets.LoadEvent.OnServerInvoke = function(player: Player)
	while not Players[player.UserId] do
		task.wait()
	end
	
    local data = {}
	return data
end

Services.PlayerService.Profiles.PlayerReady:Connect(function(player)
	if player.Character then
		task.defer(CharacterController.OnCharacterAdded, player.Character)
	end

	player.CharacterAdded:Connect(CharacterController.OnCharacterAdded)
end)