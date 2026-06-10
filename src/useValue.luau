local RunService = game:GetService("RunService")

local DataService = require(script.Parent.Parent.DataService).client
local Vide = require(script.Parent.Parent.Vide)

--[=[
    @param path string { string } -- The path to the data value
	@param placeholder T -- A placeholder value for testing
    @return source () -> T -- The reactive source

    Returns a reactive Vide source that synchronizes with a value from the DataService 
    at the specified path. 
]=]
return function<T>(path: string | { string }, placeholder: T): () -> T
	if not RunService:IsRunning() then
		return Vide.source(placeholder)
	end

	local source = Vide.source(DataService:get(path))

	local connection = DataService:getChangedSignal(path):Connect(function(newValue)
		source(newValue)
	end)

	Vide.cleanup(function()
		connection:Destroy()
	end)

	return source
end
