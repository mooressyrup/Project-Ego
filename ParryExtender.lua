local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local ParryExtender = {}
local enabled = false
local beforeDelay = 0
local afterDelay = 0.5
local dodgeEnabled = false
local dodgeDelay = 0.5

function ParryExtender:SetEnabled(value)
    enabled = value
end

function ParryExtender:SetBeforeDelay(value)
    beforeDelay = math.max(value, 0)
end

function ParryExtender:SetAfterDelay(value)
    afterDelay = math.max(value, 0)
end

function ParryExtender:SetDodgeEnabled(value)
    dodgeEnabled = value
end

function ParryExtender:SetDodgeDelay(value)
    dodgeDelay = math.max(value, 0)
end

local function fireAction(action, ...)
    local actionRemote = RunService:FindFirstChild("ActionMain")
    if actionRemote and actionRemote:IsA("RemoteEvent") then
        actionRemote:FireServer(action, ...)
    end
end

local function fireParry()
    fireAction("parry", 72.30637452565134)
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

                if dodgeEnabled then
                    task.delay(dodgeDelay, function()
                        if enabled and dodgeEnabled then
                            fireAction("dodge")
                        end
                    end)
                end
            end
        end)
    end)
end)

return ParryExtender
