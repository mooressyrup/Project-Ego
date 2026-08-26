local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local HolySlashes = {}
local localPlayer = Players.LocalPlayer
local enabled = false
local binding
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
    return binding and (input.KeyCode == binding or input.UserInputType == binding)
end

local function getHolySlashesTool()
    local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
    local interface = playerGui and playerGui:FindFirstChild("Interface")
    local backpackUI = interface and interface:FindFirstChild("BackpackUI")
    if not backpackUI then
        return nil
    end

    for slotNumber = 0, 9 do
        local slot = backpackUI:FindFirstChild(tostring(slotNumber))
        local noIcon = slot and slot:FindFirstChild("Tool")
            and slot.Tool:FindFirstChild("ToolIcon")
            and slot.Tool.ToolIcon:FindFirstChild("NoIcon")
        local toolName = noIcon and noIcon:IsA("TextLabel") and noIcon.Text

        if toolName and toolName:lower() == "holy slashes" then
            local character = localPlayer.Character
            local backpack = localPlayer:FindFirstChildOfClass("Backpack")
            return (character and character:FindFirstChild(toolName))
                or (backpack and backpack:FindFirstChild(toolName))
        end
    end
end

local function activate()
    if not enabled or activating then
        return
    end

    local character = localPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local holySlashesTool = getHolySlashesTool()
    if not humanoid or not holySlashesTool or not holySlashesTool:IsA("Tool") then
        return
    end

    local magic = ReplicatedStorage:FindFirstChild("Magic")
    local remotes = magic and magic:FindFirstChild("Remotes")
    local event = remotes and remotes:FindFirstChild("Holy Slashes")
    if not event or not event:IsA("RemoteEvent") then
        warn("[Project Ego] Holy Slashes remote was not found.")
        return
    end

    activating = true
    local equippedTool = character:FindFirstChildOfClass("Tool")
    humanoid:EquipTool(holySlashesTool)
    task.wait(0.05)
    event:FireServer("Activate")
    task.wait(0.05)

    if equippedTool and equippedTool ~= holySlashesTool and equippedTool:IsDescendantOf(localPlayer:WaitForChild("Backpack")) then
        humanoid:EquipTool(equippedTool)
    elseif equippedTool ~= holySlashesTool then
        humanoid:UnequipTools()
    end

    activating = false
end

function HolySlashes:SetEnabled(value)
    enabled = value
end

function HolySlashes:SetBinding(input)
    local newBinding = typeof(input) == "EnumItem" and input or getBinding(input)
    if not newBinding then
        return nil
    end

    binding = newBinding
    return binding.Name
end

function HolySlashes:GetBindingName()
    return binding and binding.Name or "Not set"
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and enabled and matchesBinding(input) then
        task.spawn(activate)
    end
end)

return HolySlashes
