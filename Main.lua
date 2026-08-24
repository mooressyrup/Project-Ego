local BASE_URL = "https://raw.githubusercontent.com/mooressyrup/Project-Ego/main/"

local function loadModule(path)
    local source = game:HttpGet(BASE_URL .. path)
    local chunk, compileError = loadstring(source, "ProjectEgo/" .. path)
    assert(chunk, compileError)

    local success, moduleOrError = pcall(chunk)
    assert(success, moduleOrError)

    return moduleOrError
end

local settings = getgenv().ProjectEgoSettings
if type(settings) ~= "table" then
    settings = {}
    getgenv().ProjectEgoSettings = settings
end

local healingDelay = math.clamp(tonumber(settings.HealingCurrentDelay) or 50, 0, 2000)
local parryBeforeDelay = math.clamp(tonumber(settings.ParryBeforeDelay) or 0, 0, 2000)
local parryAfterDelay = math.clamp(tonumber(settings.ParryAfterDelay) or 500, 0, 2000)

local ImGui = loadstring(game:HttpGet(
    "https://github.com/depthso/Roblox-ImGUI/raw/main/ImGui.lua"
), "ProjectEgo/ImGui")()
local UserInputService = game:GetService("UserInputService")
local PassiveKarma = loadModule("PassiveKarma.lua")
local HealingCurrent = loadModule("HealingCurrent.lua")
local ParryExtender = loadModule("ParryExtender.lua")
local Nametags = loadModule("Nametags.lua")

HealingCurrent:SetDelay(healingDelay / 1000)
ParryExtender:SetBeforeDelay(parryBeforeDelay / 1000)
ParryExtender:SetAfterDelay(parryAfterDelay / 1000)

local window = ImGui:CreateWindow({
    Title = "Project Ego",
    Size = UDim2.fromOffset(500, 350),
})

local mainTab = window:CreateTab({
    Name = "Main",
    Visible = true,
})

local combatTab = window:CreateTab({
    Name = "Combat",
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
    Label = "Enable Nametags",
    Value = false,
    Callback = function(_, enabled)
        Nametags:SetEnabled(enabled)
    end,
})

local function setWidgetLabel(widget, text)
    widget.Text = text
end

local bindButton
local function updateBindButton()
    setWidgetLabel(bindButton, "Bind Healing Current (" .. HealingCurrent:GetBindingName() .. ")")
end

combatTab:Checkbox({
    Label = "Enable Healing Current",
    Value = false,
    Callback = function(_, enabled)
        HealingCurrent:SetEnabled(enabled)
    end,
})

combatTab:Slider({
    Label = "Healing Current Delay (ms)",
    MinValue = 0,
    MaxValue = 2000,
    Value = healingDelay,
    Format = "%dms",
    Callback = function(_, value)
        healingDelay = math.clamp(math.round(value), 0, 2000)
        settings.HealingCurrentDelay = healingDelay
        HealingCurrent:SetDelay(healingDelay / 1000)
    end,
})

bindButton = combatTab:Button({
    Label = "",
    Callback = function()
        setWidgetLabel(bindButton, "Press a key or mouse button...")

        task.spawn(function()
            local input = UserInputService.InputBegan:Wait()
            HealingCurrent:SetBinding(input)
            updateBindButton()
        end)
    end,
})
updateBindButton()

combatTab:Checkbox({
    Label = "Enable Parry Extender",
    Value = false,
    Callback = function(_, enabled)
        ParryExtender:SetEnabled(enabled)
    end,
})

combatTab:Slider({
    Label = "Parry Before Delay (ms)",
    MinValue = 0,
    MaxValue = 2000,
    Value = parryBeforeDelay,
    Format = "%dms",
    Callback = function(_, value)
        parryBeforeDelay = math.clamp(math.round(value), 0, 2000)
        settings.ParryBeforeDelay = parryBeforeDelay
        ParryExtender:SetBeforeDelay(parryBeforeDelay / 1000)
    end,
})

combatTab:Slider({
    Label = "Parry After Delay (ms)",
    MinValue = 0,
    MaxValue = 2000,
    Value = parryAfterDelay,
    Format = "%dms",
    Callback = function(_, value)
        parryAfterDelay = math.clamp(math.round(value), 0, 2000)
        settings.ParryAfterDelay = parryAfterDelay
        ParryExtender:SetAfterDelay(parryAfterDelay / 1000)
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
