-- For Polytoria 1.x
-- Emulates the Polytoria 2.x Datastore API
-- When you call the functions, the green thread will block until complete
-- Meaning that you can do stuff like:
--[[
local datastore = BlockingDatastore.Open("mydatastore")
datastore:Set("key", 100)
print(datastore:Get("key"))
--]]
-- And it should reliably display 100
-- You can also use the 2.x names GetDatastore, GetAsync, SetAsync, RemoveAsync
local BlockingDatastore = {}

-- Open a datastore with a given name
-- Returns a BlockingDatastore object
function BlockingDatastore.Open(name)
    local datastore = Datastore:GetDatastore(name)
    while datastore.Loading do
        wait()
    end
    local o = {}
    setmetatable(o, BlockingDatastore)
    BlockingDatastore.__index = BlockingDatastore
    o.datastore = datastore
    return o
end
BlockingDatastore.GetDatastore = BlockingDatastore.Open

-- Retrieve a key from the datastore
-- If an error occurs, returns a table with an _error key containing the
-- error message
-- Otherwise, return the retrieved value
function BlockingDatastore:Get(key)
    local performed = false
    local return_value
    self.datastore:Get(key, function (value, success, error)
        if not success then
            return_value = {_error = error}
        else
            return_value = value
        end
        performed = true
    end)
    while not performed do
        wait()
    end
    return return_value
end
BlockingDatastore.GetAsync = BlockingDatastore.Get

-- Set a key in the datastore
-- If an error occurs, returns a table with an _error key containing the
-- error message
-- Otherwise, return true
function BlockingDatastore:Set(key, value)
    local performed = false
    local return_value
    self.datastore:Set(key, value, function (success, error)
        if not success then
            return_value = {_error = error}
        else
            return_value = true
        end
        performed = true
    end)
    while not performed do
        wait()
    end
    return return_value
end
BlockingDatastore.SetAsync = BlockingDatastore.Set

-- Remove a key from the datastore
-- If an error occurs, returns a table with an _error key containing the
-- error message
-- Otherwise, return true
function BlockingDatastore:Remove(key)
    local performed = false
    local return_value
    self.datastore:Remove(key, function (success, error)
        if not success then
            return_value = {_error = error}
        else
            return_value = true
        end
        performed = true
    end)
    while not performed do
        wait()
    end
    return return_value
end
BlockingDatastore.RemoveAsync = BlockingDatastore.Remove

-- Returns true if the passed in object is an error value returned by
-- another function
function BlockingDatastore.IsError(value)
    return type(value) == "table" and value._error ~= nil
end

-- If the object is an error value, return its error message
function BlockingDatastore.GetError(value)
    if BlockingDatastore.IsError(value) then
        return value._error
    end
end

return BlockingDatastore