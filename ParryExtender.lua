local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local ParryExtender = {}
local enabled = false
local delay = 0.5

function ParryExtender:SetEnabled(value)
    enabled = value
end

function ParryExtender:SetDelay(value)
    delay = math.max(value, 0)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not enabled or input.KeyCode ~= Enum.KeyCode.F then
        return
    end

    task.delay(delay, function()
        local actionRemote = RunService:FindFirstChild("ActionMain")
        if actionRemote and actionRemote:IsA("RemoteEvent") then
            actionRemote:FireServer("parry", 72.30637452565134)
        end
    end)
end)

return ParryExtender
