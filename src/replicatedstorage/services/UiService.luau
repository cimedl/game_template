local TweenService = game:GetService("TweenService")
local FrameService = require(script.Parent.FrameService)

local player = game.Players.LocalPlayer

local playerGui = player:WaitForChild("PlayerGui")
local soundsGui = playerGui:WaitForChild("Sounds")
local soundFolder = soundsGui:FindFirstChild("UiSounds")
local clickSound = soundFolder:FindFirstChild("Click")

local RATE = 0.05
local CONFIG = {
	Start = {
		TweenSpeed = 0.15,
		EasingStyle = Enum.EasingStyle.Quad,
		EasingDirection = Enum.EasingDirection.Out,
	},

	Stop = {
		TweenSpeed = 0.15,
		EasingStyle = Enum.EasingStyle.Quad,
		EasingDirection = Enum.EasingDirection.Out,
	},
}

local buttons = {}
buttons.__index = buttons

buttons.new = function(imageButton: ImageButton)
	local self = setmetatable({
		imageButton = imageButton,
		activated = function() end,
		hovered = function() end,
		unhovered = function() end,

        x = 0.03,
        y = 0.03,

        _state = "inactive" :: "active" | "inactive", 
        _time = os.clock(),
		_original = nil,
	}, buttons)

	self:signals()

	return self
end

buttons.state = function(self)
    if not self._state then
        warn("Missing state")
        return
    end

    self._state = (self._state == "active") and "inactive" or "active"
end

buttons.config = function(self, type: "x" | "y", value: number)
    if not self[type] then
        warn("Missing config axis type")
        return
    end

    if not value then
        warn("Missing value type")
        return
    end

    self[type] = value
end

buttons.set = function(self, type: "activated" | "hovered" | "unhovered", fn: () -> ())
    if not type then
        warn("Missing type of callback")
        return
    end

    if not fn then
        warn("Missing callback function")
        return
    end

    if not self[type] then
        warn("Callback type doesn't exist")
        return
    end

    self[type] = fn
end

buttons.signals = function(self)
    if not self._original then
        self._original = self.imageButton.Size
    end

	self.imageButton.Activated:Connect(function()
        local now = os.clock()
        if now - self._time < RATE then
            return
        end
        self._time = now

        clickSound:Play()

		FrameService.add(self.imageButton.Name, function()
            local target = UDim2.fromScale(self._original.X.Scale - self.x, self._original.Y.Scale - self.y)

			local tween = TweenService:Create(
				self.imageButton,
				TweenInfo.new(CONFIG.Start.TweenSpeed, CONFIG.Start.EasingStyle, CONFIG.Start.EasingDirection),
				{
                    Size = target
                }
			)

            tween:Play()

            local connection = nil
            connection = tween.Completed:Once(function()
                FrameService.remove(self.imageButton.Name)
                if connection then
                    connection:Disconnect()
                    connection = nil
                end
            end)
            
			return function()
                if tween.PlaybackState == Enum.PlaybackState.Playing then
                    tween:Cancel()
                    tween = nil
                end

                if connection then
                    connection:Disconnect()
                    connection = nil
                end

                local restore = TweenService:Create(
                    self.imageButton,
                    TweenInfo.new(CONFIG.Start.TweenSpeed, CONFIG.Stop.EasingStyle, CONFIG.Stop.EasingDirection),
                    {
                        Size = self._original
                    }
                )

                restore:Play()
            end
		end)

		if self.activated then
			self.activated()
		end
	end)

    self.imageButton.MouseEnter:Connect(function()
        FrameService.add(self.imageButton.Name .. "Enter", function()
            local target = UDim2.fromScale(self._original.X.Scale + self.x, self._original.Y.Scale + self.y)

			local tween = TweenService:Create(
				self.imageButton,
				TweenInfo.new(CONFIG.Start.TweenSpeed, CONFIG.Start.EasingStyle, CONFIG.Start.EasingDirection),
				{
                    Size = target
                }
			)

            tween:Play()
            
			return function()
                if tween.PlaybackState == Enum.PlaybackState.Playing then
                    tween:Cancel()
                end

                local restore = TweenService:Create(
                    self.imageButton,
                    TweenInfo.new(CONFIG.Start.TweenSpeed, CONFIG.Stop.EasingStyle, CONFIG.Stop.EasingDirection),
                    {
                        Size = self._original
                    }
                )

                restore:Play()
            end
		end)
    end)

    self.imageButton.MouseLeave:Connect(function()
        FrameService.remove(self.imageButton.Name .. "Enter")
    end)
end

local frames = {}
frames.actives = {}
frames.__index = frames

frames.clear = function()
    for obj, fn in pairs(frames.actives) do
        if obj.ignore then
            continue
        end
        
        if fn then
            fn(obj)
        end
    end
end

frames.new = function(frame: Frame, ignore: boolean)
    local self = setmetatable({
        frame = frame,
        ignore = ignore or false,
        _original = nil
    }, frames)

    return self
end

frames.close = function(self)
    frames.actives[self] = nil
    FrameService.remove(self.frame.Name .. "Frame")
end

frames.open = function(self)
    if not self._original then
        self._original = self.frame.Size
    end

    frames.clear()

    if self.frame.Visible then
        frames.actives[self] = frames.close
        return false
    end

    frames.actives[self] = frames.close

    FrameService.add(self.frame.Name .. "Frame", function()
        local original = UDim2.fromScale(0.429, 0.708)
		local target = UDim2.fromScale(0.429 / 2, 0.708 / 2)

		self.frame.Size = target
		self.frame.Visible = true

		local tween =
			TweenService:Create(self.frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = original,
			})
		tween:Play()

		return function()
			if tween.PlaybackState == Enum.PlaybackState.Playing then
				tween:Cancel()
			end

			local restore =
				TweenService:Create(self.frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
					Size = target,
				})
			restore:Play()

			restore.Completed:Once(function()
				self.frame.Visible = false
			end)
		end
    end)
    return true
end

return {buttons = buttons, frames = frames}
