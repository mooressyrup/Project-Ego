local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local HitboxExtender = {}
local localPlayer = Players.LocalPlayer
local environment = getgenv()
if environment.HBE == nil then
    environment.HBE = false
end

local enabled = environment.HBE == true
local viewEnabled = false
local debugEnabled = false
local chance = 100
local hitboxSize = 10
local whitelistedTeamName = nil
local originalStates = {}
local characterContainer

local function debugLog(message)
    if debugEnabled then
        print("[Project Ego Hitbox] " .. message)
    end
end

local function getCharacter(player)
    if characterContainer then
        local character = characterContainer:FindFirstChild(player.Name)
        if character then
            return character
        end
    end

    local character = player.Character
    if character and character:FindFirstChild("Humanoid") then
        characterContainer = character.Parent
        return character
    end

    for _, descendant in workspace:GetDescendants() do
        if descendant:IsA("Model")
            and string.find(descendant.Name, player.Name, 1, true)
            and descendant:FindFirstChild("Humanoid")
        then
            characterContainer = descendant.Parent
            return descendant
        end
    end
end

local function getState(part)
    local state = originalStates[part]
    if not state then
        state = {
            size = part.Size,
            color = part.Color,
            canCollide = part.CanCollide,
            transparency = part.Transparency,
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
    if not viewEnabled or not state.expanded then
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

    viewer.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
    viewer.Color3 = Color3.fromRGB(255, 0, 0)
end

local function resetHitbox(part, state)
    state.expanded = false
    part.Size = state.size
    part.Color = state.color
    part.CanCollide = state.canCollide
    part.Transparency = state.transparency

    if state.viewer then
        state.viewer:Destroy()
        state.viewer = nil
    end
end

local function restoreHitboxes()
    for part, state in pairs(originalStates) do
        if part.Parent then
            resetHitbox(part, state)
        elseif state.viewer then
            state.viewer:Destroy()
        end
    end

    table.clear(originalStates)
end

local nextCleanup = 0
RunService.Heartbeat:Connect(function()
    if os.clock() < nextCleanup then
        return
    end
    nextCleanup = os.clock() + 0.5

    for part, state in pairs(originalStates) do
        local character = part.Parent
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            if part.Parent then
                resetHitbox(part, state)
            elseif state.viewer then
                state.viewer:Destroy()
            end
            originalStates[part] = nil
        end
    end
end)

local function updateHitboxes(expanded)
    for _, player in Players:GetPlayers() do
        if player == localPlayer then
            continue
        end

        local character = getCharacter(player)
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart or not rootPart:IsA("BasePart") then
            debugLog(("%s: no HumanoidRootPart found"):format(player.Name))
            continue
        end

        local state = originalStates[rootPart]
        if isWhitelisted(player) or not expanded then
            if state then
                resetHitbox(rootPart, state)
            end
            continue
        end

        state = getState(rootPart)
        state.expanded = true
        rootPart.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
        rootPart.Color = Color3.fromRGB(255, 0, 0)
        rootPart.CanCollide = false
        rootPart.Transparency = state.transparency
        updateViewer(rootPart, state)
        debugLog(("%s: requested %s, local size is %s"):format(
            player.Name,
            tostring(Vector3.new(hitboxSize, hitboxSize, hitboxSize)),
            tostring(rootPart.Size)
        ))
    end
end

local function refreshHitboxes()
    if not enabled then
        return
    end

    for _, player in Players:GetPlayers() do
        if player == localPlayer then
            continue
        end

        local character = getCharacter(player)
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local state = rootPart and originalStates[rootPart]
        if rootPart and state and isWhitelisted(player) then
            resetHitbox(rootPart, state)
        elseif rootPart and state and state.expanded then
            rootPart.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
            rootPart.Color = Color3.fromRGB(255, 0, 0)
            rootPart.CanCollide = false
            rootPart.Transparency = state.transparency
            updateViewer(rootPart, state)
        end
    end
end

RunService.RenderStepped:Connect(function()
    if environment.HBE then
        enabled = true
        refreshHitboxes()
    elseif enabled then
        enabled = false
        restoreHitboxes()
    end
end)

function HitboxExtender:SetEnabled(value)
    enabled = value
    environment.HBE = value

    if not enabled then
        restoreHitboxes()
    end
end

function HitboxExtender:SetChance(value)
    chance = math.clamp(math.round(value), 0, 100)
end

function HitboxExtender:SetViewEnabled(value)
    viewEnabled = value

    if environment.HBE then
        refreshHitboxes()
    end
end

function HitboxExtender:SetDebugEnabled(value)
    debugEnabled = value
    debugLog("debug logging enabled")
end

function HitboxExtender:SetSize(value)
    hitboxSize = math.max(math.round(value), 1)

    if environment.HBE then
        refreshHitboxes()
    end
end

function HitboxExtender:SetWhitelistedTeam(teamName)
    whitelistedTeamName = teamName

    if environment.HBE then
        refreshHitboxes()
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not environment.HBE or input.UserInputType ~= Enum.UserInputType.MouseButton1 then
        return
    end

    local expanded = math.random(1, 100) <= chance
    debugLog(("M1: hit chance %d%%, expanding=%s"):format(chance, tostring(expanded)))
    updateHitboxes(expanded)
end)

return HitboxExtender
