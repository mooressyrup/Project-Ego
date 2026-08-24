local Players = game:GetService("Players")

local Nametags = {}
local enabled = false

local function enableRankTag(character)
    local head = character and character:FindFirstChild("Head")
    local rankTag = head and head:FindFirstChild("RankTag", true)
    local parent = rankTag and rankTag.Parent
    if not parent or parent:FindFirstChild("Username") then
        return
    end

    local success, usernameTag = pcall(function()
        return rankTag:Clone()
    end)
    if not success or not usernameTag then
        return
    end

    usernameTag.Name = "Username"
    usernameTag.Parent = parent

    pcall(function()
        usernameTag.Enabled = true
    end)
end

local function removeUsernameTag(character)
    local head = character and character:FindFirstChild("Head")
    local usernameTag = head and head:FindFirstChild("Username", true)
    if usernameTag then
        usernameTag:Destroy()
    end
end

local function watchCharacter(character)
    enableRankTag(character)
    character.DescendantAdded:Connect(function(instance)
        if enabled and instance.Name == "RankTag" then
            enableRankTag(character)
        end
    end)
end

function Nametags:SetEnabled(value)
    enabled = value
    if not enabled then
        for _, player in Players:GetPlayers() do
            removeUsernameTag(player.Character)
        end

        return
    end

    for _, player in Players:GetPlayers() do
        if player.Character then
            enableRankTag(player.Character)
        end
    end
end

for _, player in Players:GetPlayers() do
    player.CharacterAdded:Connect(watchCharacter)
    if player.Character then
        watchCharacter(player.Character)
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(watchCharacter)
end)

return Nametags
