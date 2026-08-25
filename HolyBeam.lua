local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local HolyBeam = {}
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
    if gameProcessed or not enabled or not matchesBinding(input) then
        return
    end

    local magic = ReplicatedStorage:FindFirstChild("Magic")
    local remotes = magic and magic:FindFirstChild("Remotes")
    local event = remotes and remotes:FindFirstChild("Holy Beam")
    if event and event:IsA("RemoteEvent") then
        event:FireServer("Activate", Vector3.new(-2109.4470214844, 379.41278076172, -1416.8198242188))
    end
end)

return HolyBeam
