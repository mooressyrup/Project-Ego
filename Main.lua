-- Change this after the project is pushed to GitHub.
local BASE_URL = "https://raw.githubusercontent.com/OWNER/REPOSITORY/main/"

local function loadModule(path)
    local source = game:HttpGet(BASE_URL .. path)
    local chunk, compileError = loadstring(source, "ProjectEgo/" .. path)
    assert(chunk, compileError)

    local success, moduleOrError = pcall(chunk)
    assert(success, moduleOrError)

    return moduleOrError
end

local ImGui = loadstring(game:HttpGet(
    "https://github.com/depthso/Roblox-ImGUI/raw/main/ImGui.lua"
), "ProjectEgo/ImGui")()
local UserInputService = game:GetService("UserInputService")
local PassiveKarma = loadModule("PassiveKarma.lua")
local HitboxExtender = loadModule("HitboxExtender.lua")

local window = ImGui:CreateWindow({
    Title = "Project Ego",
    Size = Vector2.new(500, 350),
})

local mainTab = window:CreateTab({
    Name = "Main",
    Visible = true,
})

mainTab:Label({
    Text = "Project Ego loaded.",
})

mainTab:Checkbox({
    Label = "Passive Karma",
    Value = false,
    Callback = function(_, enabled)
        PassiveKarma:SetEnabled(enabled)
    end,
})

mainTab:Checkbox({
    Label = "M1 Hitbox",
    Value = false,
    Callback = function(_, enabled)
        HitboxExtender:SetEnabled(enabled)
    end,
})

mainTab:Slider({
    Label = "Hit Chance",
    MinValue = 0,
    MaxValue = 100,
    Value = 100,
    Format = "%d%%",
    Callback = function(_, value)
        HitboxExtender:SetChance(value)
    end,
})

mainTab:Slider({
    Label = "Hitbox Size",
    MinValue = 1,
    MaxValue = 50,
    Value = 10,
    Format = "%d",
    Callback = function(_, value)
        HitboxExtender:SetSize(value)
    end,
})

mainTab:Button({
    Text = "Test",
    Callback = function()
        print("Project Ego test button clicked")
    end,
})

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or input.KeyCode ~= Enum.KeyCode.F2 then
        return
    end

    local visible = not ImGui.ScreenGui.Enabled
    ImGui.ScreenGui.Enabled = visible
    ImGui.FullScreenGui.Enabled = visible
end)

return PassiveKarma
