local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.packages.Signal)

shared.Components = {}
shared.Controllers = {}
shared.loaded = Signal.new()

local priorityControllers = { "CharacterController", "LoadController" }

local _debug = false

for _, key in pairs(priorityControllers) do
	local controller = ReplicatedStorage.controllers:FindFirstChild(key)
	if controller then
		shared.Controllers[key] = require(controller)

		if _debug then
			print("[ModuleLoader]: Controller loaded:", key)
		end
	end
end

for _, controller in pairs(ReplicatedStorage.controllers:GetChildren()) do
	if shared.Controllers[controller.Name] ~= nil then
		continue
	end
	shared.Controllers[controller.Name] = require(controller)

	if _debug then
		print("[ModuleLoader]: Controller loaded:", controller.Name)
	end
end

shared.loaded:Fire()