type Active = () -> nil

local self = {}
self.actives = {}

self.add = function(key: string, fn: () -> Active)
	if self.actives[key] then
		self.actives[key]()
	end

	self.actives[key] = fn()
end

self.remove = function(key: string)
	if not self.actives[key] then
		return
	end

	self.actives[key]()
    self.actives[key] = nil
end

self.clear = function()
	if next(self.actives) == nil then
		return
	end

	for key, active in pairs(self.actives) do
		if not active then
			continue
		end

		active()
        self.actives[key] = nil
	end
end

return self
