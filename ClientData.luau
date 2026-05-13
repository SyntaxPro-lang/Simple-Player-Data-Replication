--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networking = require(ReplicatedStorage.Packages.Networking)
local Signal = require(ReplicatedStorage.Packages.Signal)

local module = {}
local KeySignals = {}
local ClientData = {}

local IsLoaded = Signal.new()
local alreadyLoaded = false

local function GetSignal(id)
	KeySignals[id] = KeySignals[id] or Signal.new()
	return KeySignals[id]
end

Networking.client:On("DataUpdate", function(data)
	if not alreadyLoaded then
		IsLoaded:Fire()
		alreadyLoaded = true
	end
	ClientData[data.id] = data.value
	local signal = KeySignals[data.id]
	if signal then
		signal:Fire(data.value)
	end
end)

function module.GetData()
	if alreadyLoaded then
		return ClientData
	end
	return IsLoaded:Wait()
end

function module.OnSet(id: string, callback: () -> ())
	return GetSignal(id):Connect(callback)
end

return module
