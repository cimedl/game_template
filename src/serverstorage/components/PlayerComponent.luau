local PlayerComponent = {}
PlayerComponent.__index = PlayerComponent

function PlayerComponent.new(player, playerData)
	local self = setmetatable({}, PlayerComponent)
	
	self.player = player
	self.userId = player.UserId
	
	self.playerData = playerData

	self:Setup()
	self._debug = false

	return self
end

function PlayerComponent:Setup()
end

function PlayerComponent:Destroy()
	for k, _ in pairs(self) do
		self[k] = nil
	end
end

return PlayerComponent
