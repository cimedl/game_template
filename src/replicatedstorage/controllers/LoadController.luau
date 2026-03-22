local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.packages.Signal)
local Packets = require(ReplicatedStorage.utils.Packets)

local _debug = true

local loadController = {}
loadController.loaded = Signal.new()

shared.loaded:Connect(function()
	local result = Packets.LoadEvent:Fire()
	if result then
		loadController.loaded:Fire(result)
	end
end)

return loadController