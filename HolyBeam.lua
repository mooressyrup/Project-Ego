local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local HolyBeam = {}
local binding
local enabled = true
local targetPosition = Vector3.new(-2109.4470214844, 379.41278076172, -1416.8198242188)
local bindingDown = false
local selectingTarget = false
local cursorTargetNext = false
local lastPressTime = 0
local pendingPressId = 0

local DOUBLE_PRESS_WINDOW = 0.3

local function getBinding(input)
    if input.KeyCode ~= Enum.KeyCode.Unknown then
        return input.KeyCode
    end

    if input.UserInputType.Name:match("^MouseButton") then
        return input.UserInputType
    end
end

local function matchesBinding(input)
    return binding and (input.KeyCode == binding or input.UserInputType == binding)
end

local function getCursorPosition()
    return Players.LocalPlayer:GetMouse().Hit.Position
end

local function fireHolyBeam(position)
    local magic = ReplicatedStorage:FindFirstChild("Magic")
    local remotes = magic and magic:FindFirstChild("Remotes")
    local event = remotes and remotes:FindFirstChild("Holy Beam")
    if event and event:IsA("RemoteEvent") then
        event:FireServer("Activate", position)
    end
end

function HolyBeam:SetBinding(input)
    local newBinding = typeof(input) == "EnumItem" and input or getBinding(input)
    if not newBinding then
        return nil
    end

    binding = newBinding
    return binding.Name
end

function HolyBeam:GetBindingName()
    return binding and binding.Name or "Not set"
end

function HolyBeam:SetEnabled(value)
    enabled = value
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not enabled then
        return
    end

    if selectingTarget and input.UserInputType == Enum.UserInputType.MouseButton1 then
        targetPosition = getCursorPosition()
        selectingTarget = false
        return
    end

    if not matchesBinding(input) then
        return
    end

    if cursorTargetNext then
        cursorTargetNext = false
        fireHolyBeam(getCursorPosition())
        return
    end

    local now = time()
    if now - lastPressTime <= DOUBLE_PRESS_WINDOW then
        pendingPressId += 1
        lastPressTime = 0
        cursorTargetNext = true
        return
    end

    lastPressTime = now
    bindingDown = true
    pendingPressId += 1
    local currentPressId = pendingPressId

    task.delay(DOUBLE_PRESS_WINDOW, function()
        if not enabled or currentPressId ~= pendingPressId then
            return
        end

        if bindingDown then
            selectingTarget = true
            return
        end

        fireHolyBeam(targetPosition)
    end)
end)

UserInputService.InputEnded:Connect(function(input)
    if matchesBinding(input) then
        bindingDown = false
        selectingTarget = false
    end
end)

return HolyBeam
