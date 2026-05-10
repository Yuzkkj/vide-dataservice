local DataService = require(script.Parent.Parent.DataService).client
local Vide = require(script.Parent.Parent.Vide)

--[=[
    Returns a reactive Vide source that synchronizes with a value from the DataService 
    at the specified path. 

    @param path - The path to the data value
    @return source - The reactive source
]=]
return function<T>(path: string | { string }): Vide.Source<T>
	local source = Vide.source(DataService:get(path))

	local connection = DataService:getChangedSignal(path):Connect(function(newValue)
		source(newValue)
	end)

	Vide.cleanup(function()
		connection:Destroy()
	end)

	return source
end
