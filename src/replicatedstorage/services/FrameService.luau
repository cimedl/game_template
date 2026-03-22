type Active = () -> nil

local frameService = {}
frameService.actives = {}

frameService.add = function(key: string, fn: () -> Active)
	if frameService.actives[key] then
		frameService.actives[key]()
	end

	frameService.actives[key] = fn()
end

frameService.remove = function(key: string)
	if not frameService.actives[key] then
		return
	end

	frameService.actives[key]()
    frameService.actives[key] = nil
end

frameService.clear = function()
	if next(frameService.actives) == nil then
		return
	end

	for key, active in pairs(frameService.actives) do
		if not active then
			continue
		end

		active()
        frameService.actives[key] = nil
	end
end

return frameService
