local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local ParryTesting = {}
local localPlayer = Players.LocalPlayer
local enabled = false
local beforeDelay = 0
local parrySendCount = 0
local lastParrySentAt = -math.huge

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

local function trackParryRemoteCalls()
    if type(hookmetamethod) ~= "function" or type(getnamecallmethod) ~= "function" then
        warn("[Project Ego] Parry Testing cannot detect existing parry remotes in this executor.")
        return false
    end

    local originalNamecall
    local hook = function(self, ...)
        if getnamecallmethod() == "FireServer"
            and self.Parent == RunService
            and self.Name == "ActionMain"
            and select(1, ...) == "parry" then
            parrySendCount += 1
            lastParrySentAt = os.clock()
        end

        return originalNamecall(self, ...)
    end

    local hooked, result = pcall(
        hookmetamethod,
        game,
        "__namecall",
        type(newcclosure) == "function" and newcclosure(hook) or hook
    )
    if not hooked then
        warn("[Project Ego] Parry Testing could not hook parry remotes: " .. tostring(result))
        return false
    end

    originalNamecall = result
    return true
end

local canDetectParryRemote = trackParryRemoteCalls()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not enabled or input.KeyCode ~= Enum.KeyCode.F then
        return
    end

    local character = localPlayer.Character
    local equippedTool = getEquippedTool()
    if not character or not equippedTool then
        return
    end

    local parrySendCountAtPress = parrySendCount
    local pressedAt = os.clock()
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

        local parryAlreadySent = parrySendCount ~= parrySendCountAtPress
            or lastParrySentAt >= pressedAt - 0.05
        if canDetectParryRemote and enabled and not cancelled and not parryAlreadySent
            and localPlayer.Character == character and equippedTool.Parent == character then
            fireParry()
        end
    end)
end)

return ParryTesting
