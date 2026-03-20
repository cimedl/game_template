local LoadController = require(script.Parent.LoadController)
local player = game.Players.LocalPlayer

local _debug = false

local registry = {}

local function register_character_added(funcName: string, func: () -> any?)
	if not registry[funcName] then
		registry[funcName] = { func = func, success = false}
	end
end

local function OnCharacterAdded(character: Model)
	character:WaitForChild("HumanoidRootPart")
	for _, funcData in pairs(registry) do
		funcData.success = false
	end

	local data = {
		character = character,
	}
	
	for k, funcData in pairs(registry) do
		if funcData.success then
			continue
		end
		task.spawn(funcData.func, data)
		funcData.success = true
		
		print(`[CharacterController]: Loaded {k}.`)
	end
end

player.CharacterAdded:Connect(OnCharacterAdded)

LoadController.loaded:Connect(function()
	if player.Character then
		local data = {
			character = player.Character
		}

		for k, funcData in pairs(registry) do
			if funcData.success then
				continue
			end

			task.spawn(funcData.func, data)
			funcData.success = true
			
			print(`[CharacterController]: Loaded {k}.`)
		end
	end
end)

return {
	register_character_added = register_character_added,
	OnCharacterAdded = OnCharacterAdded
}