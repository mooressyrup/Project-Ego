local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local ParryTesting = {}
local localPlayer = Players.LocalPlayer
local enabled = false
local beforeDelay = 0

function ParryTesting:SetEnabled(value)
    enabled = value
end

function ParryTesting:SetBeforeDelay(value)
    beforeDelay = math.max(value, 0)
end

local function getEquippedTool()
    local character = localPlayer.Character
    return character and character:FindFirstChildOfClass("Tool")
end

local function fireParry()
    local actionRemote = RunService:FindFirstChild("ActionMain")
    if actionRemote and actionRemote:IsA("RemoteEvent") then
        actionRemote:FireServer("parry", 72.30637452565134)
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not enabled or input.KeyCode ~= Enum.KeyCode.F then
        return
    end

    local character = localPlayer.Character
    local equippedTool = getEquippedTool()
    if not character or not equippedTool then
        return
    end

    local cancelled = false
    local cancellationConnection
    cancellationConnection = equippedTool:GetPropertyChangedSignal("Parent"):Connect(function()
        if equippedTool.Parent ~= character then
            cancelled = true
            cancellationConnection:Disconnect()
        end
    end)

    task.delay(beforeDelay, function()
        cancellationConnection:Disconnect()

        if enabled and not cancelled and localPlayer.Character == character and equippedTool.Parent == character then
            fireParry()
        end
    end)
end)

return ParryTesting
