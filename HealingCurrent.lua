local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local HealingCurrent = {}
local localPlayer = Players.LocalPlayer
local enabled = false
local binding = Enum.KeyCode.Q
local activating = false

local function getBinding(input)
    if input.KeyCode ~= Enum.KeyCode.Unknown then
        return input.KeyCode
    end

    if input.UserInputType.Name:match("^MouseButton") then
        return input.UserInputType
    end
end

local function matchesBinding(input)
    return input.KeyCode == binding or input.UserInputType == binding
end

local function activate()
    if not enabled or activating then
        return
    end

    local character = localPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local equippedTool = character and character:FindFirstChildOfClass("Tool")
    if not humanoid or not equippedTool then
        return
    end

    local magic = ReplicatedStorage:FindFirstChild("Magic")
    local remotes = magic and magic:FindFirstChild("Remotes")
    local remote = remotes and remotes:FindFirstChild("Healing Current")
    if not remote or not remote:IsA("RemoteEvent") then
        warn("[Project Ego] Healing Current remote was not found.")
        return
    end

    activating = true
    humanoid:UnequipTools()
    task.wait()

    remote:FireServer("Activate", { localPlayer, localPlayer, localPlayer })
    task.wait(0.05)

    if equippedTool.Parent and equippedTool:IsDescendantOf(localPlayer:WaitForChild("Backpack")) then
        humanoid:EquipTool(equippedTool)
    end

    activating = false
end

function HealingCurrent:SetEnabled(value)
    enabled = value
end

function HealingCurrent:SetBinding(input)
    local newBinding = getBinding(input)
    if not newBinding then
        return nil
    end

    binding = newBinding
    return binding.Name
end

function HealingCurrent:GetBindingName()
    return binding.Name
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and enabled and matchesBinding(input) then
        task.spawn(activate)
    end
end)

return HealingCurrent
