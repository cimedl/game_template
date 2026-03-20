local _debug = true

local MarketplaceService = game:GetService("MarketplaceService")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = require(ServerScriptService.Game.Players)
local ProductsTemplate = require(ServerScriptService.Templates.ProductsTemplate)

local profiler = function(mode: boolean, message: string)
	mode = mode ~= nil and mode or false
	if not mode then
		return
	end
	local statement = "[PlayerComponent]: " .. message
	print(statement)
end

local self = {}
self.productRequests = {}

self.setProductRequestFor = function(type: string, player: Player, options: any?)
	if not self.productRequests[type] then
		self.productRequests[type] = {}
	end

	self.productRequests[type][player.UserId] = options
end

self.getProductRequestFor = function(type: string, userId: number)
	if not self.productRequests[type] then
		return
	end

	local request = self.productRequests[type][userId]
    if not request then
        return
    end

    self.productRequests[type][userId] = nil
    return request
end

self.setup = function(player: Player)
	local playerObj = Players[player.UserId]
	if not playerObj then
		return
	end

	local gamepasses = playerObj.playerData.Gamepasses
	if not gamepasses then
		return
	end

	local existingGamepasses = ProductsTemplate.Gamepasses
	if not existingGamepasses then
		return
	end

	for gamepassName, data in pairs(existingGamepasses) do
		local success, owns = pcall(
			MarketplaceService.UserOwnsGamePassAsync,
			MarketplaceService,
			player.UserId,
			data.id
		)

		player:SetAttribute(gamepassName, success and owns == true)
		if not success or not owns then
			gamepasses[gamepassName] = nil
			continue
		end

		gamepasses[gamepassName] = true

		local callback = data.callback
		if callback then
			callback(playerObj)
		end

		profiler(_debug, `Setup gamepass {gamepassName} for {player.Name}`)
	end
end

self.purchaseGamepass = function(player: Player, gamepassName: string)
	local data = ProductsTemplate.Gamepasses[gamepassName]
	if not data then
		return
	end

	local success, err = pcall(function()
		MarketplaceService:PromptGamePassPurchase(player, data.id)
	end)

	if not success then
		warn(err)
	end
end

self.purchaseProduct = function(player: Player, productName: string)
	local data = ProductsTemplate.Products[productName]
	if not data then
		return
	end

	local success, err = pcall(function()
		MarketplaceService:PromptProductPurchase(player, data.id)
	end)

	if not success then
		warn(err)
	end
end

MarketplaceService.ProcessReceipt = function(receiptInfo)
    local player = game.Players:GetPlayerByUserId(receiptInfo.PlayerId)
    if not player then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

	local playerObj = Players[player.UserId]
	if not playerObj then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

    local product
    for _, data in pairs(ProductsTemplate.Products) do
        if data.id == receiptInfo.ProductId then
            product = data
            break
        end
    end

    if not product or not product.callback then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    local options = self.getProductRequestFor(product.name, receiptInfo.PlayerId)
    product.callback(playerObj, options)

    return Enum.ProductPurchaseDecision.PurchaseGranted
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(
	function(player: Player, gamepassId: number, wasPurchased: boolean)
		local userId = player.UserId
		local playerObj = Players[userId]
		if not playerObj then
			return
		end

		local gamepass
		for _, data in pairs(ProductsTemplate.Gamepasses) do
			if data.id ~= gamepassId then
				continue
			end

			gamepass = data
			break
		end

		if not wasPurchased then
			return
		end

		if not gamepass then
			return
		end

		local callback = gamepass.callback
		if not callback then
			return
		end

		callback(playerObj)
        player:SetAttribute(gamepass.name, true)
	end
)

return self
