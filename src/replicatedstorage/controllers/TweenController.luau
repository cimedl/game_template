type TweenConfig = {
	duration: number,
	easing: (alpha: number) -> (),
	update: (eased: number) -> (),
	completed: () -> (),
}

local connection = nil

local tweenController = {}
tweenController.tweens = {}

tweenController.update = function(deltaTime)
	for i = #tweenController.tweens, 1, -1 do
		local tween = tweenController.tweens[i]
		if tween.cancelled then
			table.remove(tweenController.tweens, i)
			continue
		end

		tween.time += deltaTime

		local alpha = math.clamp(tween.time / tween.duration, 0, 1)
		local eased = tween.easing(alpha)

		tween.update(eased)

		if alpha >= 1 then
			if tween.completed then
				tween.completed()
			end

			table.remove(tweenController.tweens, i)
		end
	end
end

tweenController.stop = function()
	if connection then
		connection:Disconnect()
		connection = nil
	end

	table.clear(tweenController.tweens)
end

tweenController.start = function()
	if connection then
		return
	end

	connection = game:GetService("RunService").Heartbeat:Connect(tweenController.update)
end

tweenController.tween = function(tweenConfig: TweenConfig)
	tweenController.start()
	local tween = {
		time = 0,
		duration = tweenConfig.duration,
		easing = tweenConfig.easing,
		update = tweenConfig.update,
		completed = tweenConfig.completed,
		cancelled = false,
	}

	function tween:cancel()
		self.cancelled = true
	end

	table.insert(tweenController.tweens, tween)
	return tween
end

return tweenController
