local Players = game:GetService("Players")

local Nametags = {}
local enabled = false

local function enableRankTag(character)
    local head = character and character:FindFirstChild("Head")
    local rankTag = head and head:FindFirstChild("RankTag", true)
    if rankTag then
        pcall(function()
            rankTag.Enabled = true
        end)
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
