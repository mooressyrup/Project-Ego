local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local HealingCurrentSignal = {}
local binding
local enabled = true

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

function HealingCurrentSignal:SetBinding(input)
    local newBinding = typeof(input) == "EnumItem" and input or getBinding(input)
    if not newBinding then
        return nil
    end

    binding = newBinding
    return binding.Name
end

function HealingCurrentSignal:GetBindingName()
    return binding and binding.Name or "Not set"
end

function HealingCurrentSignal:SetEnabled(value)
    enabled = value
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not enabled or not matchesBinding(input) then
        return
    end

    local magic = ReplicatedStorage:FindFirstChild("Magic")
    local remotes = magic and magic:FindFirstChild("Remotes")
    local event = remotes and remotes:FindFirstChild("Healing Current")
    local character = Players.LocalPlayer.Character
    if event and event:IsA("RemoteEvent") and character then
        firesignal(event.OnClientEvent, Players.LocalPlayer, "Activate", character, character)
    end
end)

return HealingCurrentSignal
