local profilingUtils = {}

profilingUtils.profile = function(mode, prefix, message)
    mode = mode ~= nil and mode or false
    if not mode then
        return
    end
	local statement = `[{prefix}]: ` .. message
	print(statement)
end

return profilingUtils