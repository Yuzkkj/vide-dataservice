local DataService = require(script.Parent.Parent.DataService).client
local Sift = require(script.Parent.Parent.Sift)
local Vide = require(script.Parent.Parent.Vide)

--[=[
	Returns a reactive Vide source that synchronizes with an array from the DataService 
	at the specified path. 

	@param path - The path to the data array
	@return source - The reactive source
]=]
return function<T>(path: string | { string }): Vide.Source<T>
	local array = DataService:get(path)
	if array == nil or not Sift.Array.is(array) then
		error("Path must lead to an array.")
	end

	local source = Vide.source(array)
	local insertedSignal = DataService:getArrayInsertedSignal(path):Connect(function(index, value)
		source(Sift.Array.set(source(), index, value))
	end)

	local removedSignal = DataService:getArrayRemovedSignal(path):Connect(function(index)
		source(Sift.Array.removeIndex(source(), index))
	end)

	Vide.cleanup(function()
		insertedSignal:Destroy()
		removedSignal:Destroy()
	end)

	return source
end
