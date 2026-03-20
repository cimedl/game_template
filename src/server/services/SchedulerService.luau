local MAX_FRAME_TIME = 0.004

local activeConnection = nil

local schedulerService = {}
local internal = {
	scheduledTasks = {},
	index = 1,
}

schedulerService.addTask = function(_, task: () -> any?)
	local scheduledTaskSize = #internal.scheduledTasks
	internal.scheduledTasks[scheduledTaskSize + 1] = task
	return scheduledTaskSize + 1
end
 
schedulerService.removeTask = function(_, taskIndex)
	local tasks = internal.scheduledTasks
	local last = #tasks

	if not tasks[taskIndex] then
		warn("Task does not exist.")
		return
	end

	tasks[taskIndex] = tasks[last]
	tasks[last] = nil
end

schedulerService.step = function(deltaTime: number)
	local start = os.clock()
	local scheduledTaskSize = #internal.scheduledTasks
	if scheduledTaskSize == 0 then
		return
	end

	while internal.index <= scheduledTaskSize do
		if internal.scheduledTasks[internal.index] then
			local success, error = pcall(function()
				internal.scheduledTasks[internal.index](deltaTime)
			end)
			if not success then
				warn("Scheduled task failed: " .. tostring(error))
			end
		end
		internal.index += 1

		local now = os.clock()
		if now - start > MAX_FRAME_TIME then
			break
		end
	end

	if internal.index > scheduledTaskSize then
		internal.index = 1
	end
end

schedulerService.start = function(_)
	if activeConnection then
		return
	end

	activeConnection = game:GetService("RunService").Heartbeat:Connect(schedulerService.step)
end

schedulerService:start()

return setmetatable(schedulerService, {
	__index = function(_, key)
		return internal[key]
	end,

	__newindex = function(_, key, _)
		error("Scheduler service fields are read-only: " .. tostring(key))
	end,
})
