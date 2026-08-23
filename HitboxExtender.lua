local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local HitboxExtender = {}
local localPlayer = Players.LocalPlayer
local enabled = false
local viewEnabled = false
local chance = 100
local hitboxSize = 10
local originalStates = {}

local function showHitbox(part)
    part.Color = Color3.fromRGB(255, 0, 0)
    part.Material = Enum.Material.ForceField
    part.Transparency = 0.5
end

local function restoreAppearance(part, state)
    part.Color = state.color
    part.Material = state.material
    part.Transparency = state.transparency
end

local function restoreHitboxes()
    for part, state in pairs(originalStates) do
        if part.Parent then
            part.Size = state.size
            restoreAppearance(part, state)
        end
    end

    table.clear(originalStates)
end

local function setHitboxView(value)
    for part, state in pairs(originalStates) do
        if part.Parent then
            if value then
                showHitbox(part)
            else
                restoreAppearance(part, state)
            end
        end
    end
end

local function expandHitboxes()
    for _, player in Players:GetPlayers() do
        if player == localPlayer then
            continue
        end

        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if rootPart and rootPart:IsA("BasePart") then
            if not originalStates[rootPart] then
                originalStates[rootPart] = {
                    size = rootPart.Size,
                    color = rootPart.Color,
                    material = rootPart.Material,
                    transparency = rootPart.Transparency,
                }
            end

            rootPart.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
            if viewEnabled then
                showHitbox(rootPart)
            end
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

function HitboxExtender:SetViewEnabled(value)
    viewEnabled = value
    setHitboxView(viewEnabled)
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
