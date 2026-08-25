local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Experiments = {}
local localPlayer = Players.LocalPlayer
local enabled = false
local runId = 0
local connections = {}

local function disconnectAll()
    for _, connection in connections do
        connection:Disconnect()
    end

    table.clear(connections)
end

local function setCurrentArea(currentArea)
    if currentArea:IsA("StringValue") and currentArea.Value ~= "The Library" then
        currentArea.Value = "The Library"
    end
end

function Experiments:SetEnabled(value)
    if enabled == value then
        return
    end

    enabled = value
    runId += 1
    disconnectAll()

    if not enabled then
        return
    end

    local currentRunId = runId
    local scrollRemote = ReplicatedStorage:WaitForChild("Events2"):WaitForChild("Scroll")

    local function startScroll()
        if enabled and currentRunId == runId then
            scrollRemote:FireServer("Start")
        end
    end

    local function handleChildAdded(child)
        if child.Name == "CurrentArea" and child:IsA("StringValue") then
            setCurrentArea(child)
            table.insert(connections, child:GetPropertyChangedSignal("Value"):Connect(function()
                setCurrentArea(child)
            end))
        end
    end

    local currentArea = localPlayer:FindFirstChild("CurrentArea")
    if currentArea then
        handleChildAdded(currentArea)
    end

    table.insert(connections, localPlayer.ChildAdded:Connect(handleChildAdded))
    table.insert(connections, localPlayer.ChildRemoved:Connect(function(child)
        if not child:IsA("IntValue") or child.Name ~= "BookCD" then
            return
        end

        task.delay(2, function()
            if enabled and currentRunId == runId then
                scrollRemote:FireServer("Give", "Order")
                startScroll()
            end
        end)
    end))

    startScroll()
end

function Experiments:IsEnabled()
    return enabled
end

return Experiments
