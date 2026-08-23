local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local HitboxExtender = {}
local localPlayer = Players.LocalPlayer
local enabled = false
local chance = 100
local hitboxSize = 10
local originalSizes = {}

local function restoreHitboxes()
    for part, originalSize in pairs(originalSizes) do
        if part.Parent then
            part.Size = originalSize
        end
    end

    table.clear(originalSizes)
end

local function expandHitboxes()
    for _, player in Players:GetPlayers() do
        if player == localPlayer then
            continue
        end

        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if rootPart and rootPart:IsA("BasePart") then
            if not originalSizes[rootPart] then
                originalSizes[rootPart] = rootPart.Size
            end

            rootPart.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
        end
    end
end

function HitboxExtender:SetEnabled(value)
    enabled = value

    if not enabled then
        restoreHitboxes()
    end
end

function HitboxExtender:SetChance(value)
    chance = math.clamp(math.round(value), 0, 100)
end

function HitboxExtender:SetSize(value)
    hitboxSize = math.max(math.round(value), 1)

    if enabled then
        expandHitboxes()
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not enabled or input.UserInputType ~= Enum.UserInputType.MouseButton1 then
        return
    end

    if math.random(1, 100) <= chance then
        expandHitboxes()
    end
end)

return HitboxExtender
