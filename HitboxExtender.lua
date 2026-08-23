local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local HitboxExtender = {}
local localPlayer = Players.LocalPlayer
local enabled = false
local viewEnabled = false
local chance = 100
local hitboxSize = 10
local whitelistedTeamName = nil
local originalStates = {}

local function getState(part)
    local state = originalStates[part]
    if not state then
        state = {
            size = part.Size,
            expanded = false,
        }
        originalStates[part] = state
    end

    return state
end

local function isWhitelisted(player)
    return whitelistedTeamName ~= nil
        and player.Team ~= nil
        and player.Team.Name == whitelistedTeamName
end

local function updateViewer(part, state)
    if not viewEnabled then
        if state.viewer then
            state.viewer:Destroy()
            state.viewer = nil
        end
        return
    end

    local viewer = state.viewer
    if not viewer then
        viewer = Instance.new("BoxHandleAdornment")
        viewer.Name = "ProjectEgoHitbox"
        viewer.Adornee = part
        viewer.AlwaysOnTop = true
        viewer.ZIndex = 10
        viewer.Transparency = 0.55
        viewer.Parent = CoreGui
        state.viewer = viewer
    end

    viewer.Size = state.expanded and Vector3.new(hitboxSize, hitboxSize, hitboxSize) or state.size
    viewer.Color3 = state.expanded and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 255, 255)
end

local function resetHitbox(part, state)
    state.expanded = false
    part.Size = state.size

    if state.viewer then
        state.viewer:Destroy()
        state.viewer = nil
    end
end

local function restoreHitboxes()
    for part, state in pairs(originalStates) do
        if part.Parent then
            part.Size = state.size
        end
        if state.viewer then
            state.viewer:Destroy()
        end
    end

    table.clear(originalStates)
end

local function updateHitboxes(expanded)
    for _, player in Players:GetPlayers() do
        if player == localPlayer then
            continue
        end

        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart or not rootPart:IsA("BasePart") then
            continue
        end

        if isWhitelisted(player) then
            local state = originalStates[rootPart]
            if state then
                resetHitbox(rootPart, state)
            end
            continue
        end

        local state = getState(rootPart)
        state.expanded = expanded
        rootPart.Size = expanded and Vector3.new(hitboxSize, hitboxSize, hitboxSize) or state.size
        updateViewer(rootPart, state)
    end
end

local function refreshHitboxes()
    for _, player in Players:GetPlayers() do
        if player == localPlayer then
            continue
        end

        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if rootPart and rootPart:IsA("BasePart") then
            if isWhitelisted(player) then
                local state = originalStates[rootPart]
                if state then
                    resetHitbox(rootPart, state)
                end
                continue
            end

            local state = getState(rootPart)
            rootPart.Size = state.expanded and Vector3.new(hitboxSize, hitboxSize, hitboxSize) or state.size
            updateViewer(rootPart, state)
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
    refreshHitboxes()
end

function HitboxExtender:SetSize(value)
    hitboxSize = math.max(math.round(value), 1)

    if enabled then
        refreshHitboxes()
    end
end

function HitboxExtender:SetWhitelistedTeam(teamName)
    whitelistedTeamName = teamName
    refreshHitboxes()
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not enabled or input.UserInputType ~= Enum.UserInputType.MouseButton1 then
        return
    end

    updateHitboxes(math.random(1, 100) <= chance)
end)

return HitboxExtender
