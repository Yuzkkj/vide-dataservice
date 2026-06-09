local RunService = game:GetService("RunService")

local DataService = require(script.Parent.Parent.DataService).client
local Vide = require(script.Parent.Parent.Vide)

--[=[
    @param path - The path to the data value
    @return source - The reactive source

    Returns a reactive Vide source that synchronizes with a value from the DataService 
    at the specified path. 
]=]
return function<T>(path: string | { string }, placeholder: T?): () -> T
	local source = Vide.source(placeholder)

	if RunService:IsRunning() then
		source(DataService:get(path))
		local connection = DataService:getChangedSignal(path):Connect(function(newValue)
			source(newValue)
		end)

		Vide.cleanup(function()
			connection:Destroy()
		end)
	end

	return source
end
