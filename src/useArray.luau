local RunService = game:GetService("RunService")

local DataService = require(script.Parent.Parent.DataService).client
local Sift = require(script.Parent.Parent.Sift)
local Vide = require(script.Parent.Parent.Vide)

--[=[
	@param path string { string } -- The path to the data array
	@param placeholder T -- A placeholder array for testing
	@return source () -> T - The reactive source

	Returns a reactive Vide source that synchronizes with an array from the DataService at the specified path. 
]=]
return function<T>(path: string | { string }, placeholder: T): () -> T
	if not RunService:IsRunning() then
		return Vide.source(placeholder)
	end

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
