local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local ParryExtender = {}
local enabled = false
local beforeDelay = 0
local afterDelay = 0.5

function ParryExtender:SetEnabled(value)
    enabled = value
end

function ParryExtender:SetBeforeDelay(value)
    beforeDelay = math.max(value, 0)
end

function ParryExtender:SetAfterDelay(value)
    afterDelay = math.max(value, 0)
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

    task.delay(beforeDelay, function()
        fireParry()

        task.delay(afterDelay, function()
            if enabled then
                fireParry()
            end
        end)
    end)
end)

return ParryExtender
