local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Keybinds = {}
local localPlayer = Players.LocalPlayer
local bindings = {}
local activating = false

local function getBinding(input)
    if input.KeyCode ~= Enum.KeyCode.Unknown then
        return input.KeyCode
    end

    if input.UserInputType == Enum.UserInputType.MouseButton4
        or input.UserInputType == Enum.UserInputType.MouseButton5 then
        return input.UserInputType
    end
end

local function matchesBinding(input, binding)
    return input.KeyCode == binding or input.UserInputType == binding
end

local function getToolAtSlot(slot)
    local backpack = localPlayer:FindFirstChildOfClass("Backpack")
    if not backpack then
        return nil
    end

    local tools = {}
    for _, child in backpack:GetChildren() do
        if child:IsA("Tool") then
            table.insert(tools, child)
        end
    end

    return tools[slot]
end

local function activateSlot(slot)
    if activating then
        return
    end
    activating = true

    local character = localPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local targetTool = getToolAtSlot(slot)
    local originalTool = character and character:FindFirstChildOfClass("Tool")

    if humanoid and targetTool then
        humanoid:EquipTool(targetTool)
        for _ = 1, 5 do
            targetTool:Activate()
            task.wait(0.1)
        end

        if originalTool and originalTool.Parent then
            humanoid:EquipTool(originalTool)
        else
            humanoid:UnequipTools()
        end
    end

    activating = false
end

function Keybinds:SetBinding(slot, input)
    local binding = getBinding(input)
    if not binding then
        return nil
    end

    bindings[slot] = binding
    return binding.Name
end

function Keybinds:ClearBinding(slot)
    bindings[slot] = nil
end

function Keybinds:GetBindingName(slot)
    local binding = bindings[slot]
    return binding and binding.Name or "Unbound"
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or activating then
        return
    end

    for slot, binding in pairs(bindings) do
        if matchesBinding(input, binding) then
            task.spawn(activateSlot, slot)
            break
        end
    end
end)

return Keybinds
