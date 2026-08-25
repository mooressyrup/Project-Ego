local BASE_URL = "https://raw.githubusercontent.com/mooressyrup/Project-Ego/main/"
local SETTINGS_FOLDER = "ProjectEgo"
local SETTINGS_FILE = SETTINGS_FOLDER .. "/settings.json"
local HttpService = game:GetService("HttpService")

local function loadModule(path)
    local source = game:HttpGet(BASE_URL .. path)
    local chunk, compileError = loadstring(source, "ProjectEgo/" .. path)
    assert(chunk, compileError)

    local success, moduleOrError = pcall(chunk)
    assert(success, moduleOrError)

    return moduleOrError
end

local settings = {}
local loaded, savedSettings = pcall(function()
    if not isfile(SETTINGS_FILE) then
        return nil
    end

    return HttpService:JSONDecode(readfile(SETTINGS_FILE))
end)

if loaded and type(savedSettings) == "table" then
    settings = savedSettings
end

getgenv().ProjectEgoSettings = settings

local function saveSettings()
    local encoded, json = pcall(function()
        return HttpService:JSONEncode(settings)
    end)
    if not encoded then
        warn("[Project Ego] Could not encode settings: " .. tostring(json))
        return
    end

    local written, writeError = pcall(function()
        if not isfolder(SETTINGS_FOLDER) then
            makefolder(SETTINGS_FOLDER)
        end

        writefile(SETTINGS_FILE, json)
    end)
    if not written then
        warn("[Project Ego] Could not save settings: " .. tostring(writeError))
    end
end

local healingDelay = math.clamp(tonumber(settings.HealingCurrentDelay) or 50, 0, 2000)
local parryBeforeDelay = math.clamp(tonumber(settings.ParryBeforeDelay) or 0, 0, 2000)
local parryAfterDelay = math.clamp(tonumber(settings.ParryAfterDelay) or 500, 0, 2000)
local parryDodgeEnabled = settings.ParryDodgeEnabled == true
local parryDodgeDelay = math.clamp(tonumber(settings.ParryDodgeDelay) or 500, 0, 2000)
local passiveKarmaEnabled = settings.PassiveKarmaEnabled == true
local nametagsEnabled = settings.NametagsEnabled == true
local healingCurrentEnabled = settings.HealingCurrentEnabled == true
local parryExtenderEnabled = settings.ParryExtenderEnabled == true
local experimentsEnabled = settings.ExperimentsEnabled == true

if experimentsEnabled then
    passiveKarmaEnabled = false
    settings.PassiveKarmaEnabled = false
    saveSettings()
end

local ImGui = loadstring(game:HttpGet(
    "https://github.com/depthso/Roblox-ImGUI/raw/main/ImGui.lua"
), "ProjectEgo/ImGui")()
local UserInputService = game:GetService("UserInputService")
local PassiveKarma = loadModule("PassiveKarma.lua")
local HealingCurrent = loadModule("HealingCurrent.lua")
local ParryExtender = loadModule("ParryExtender.lua")
local Nametags = loadModule("Nametags.lua")
local Experiments = loadModule("Experiments.lua")

HealingCurrent:SetDelay(healingDelay / 1000)
HealingCurrent:SetEnabled(healingCurrentEnabled)
ParryExtender:SetBeforeDelay(parryBeforeDelay / 1000)
ParryExtender:SetAfterDelay(parryAfterDelay / 1000)
ParryExtender:SetEnabled(parryExtenderEnabled)
ParryExtender:SetDodgeEnabled(parryDodgeEnabled)
ParryExtender:SetDodgeDelay(parryDodgeDelay / 1000)
PassiveKarma:SetEnabled(passiveKarmaEnabled)
Nametags:SetEnabled(nametagsEnabled)
Experiments:SetEnabled(experimentsEnabled)

local savedBinding = settings.HealingCurrentBinding
local healingCurrentBinding = type(savedBinding) == "string"
    and (Enum.KeyCode[savedBinding] or Enum.UserInputType[savedBinding])
if healingCurrentBinding then
    HealingCurrent:SetBinding(healingCurrentBinding)
end

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

local experimentsTab = window:CreateTab({
    Name = "Experiments",
})

local miscellaneousTab = window:CreateTab({
    Name = "Miscellaneous",
})

mainTab:Label({
    Text = "Project Ego loaded.",
})

local function setWidgetLabel(widget, text)
    local foundLabel, label = pcall(function()
        return widget:FindFirstChild("Label", true)
    end)
    if foundLabel and label then
        local updated = pcall(function()
            label.Text = text
        end)
        if updated then
            return
        end
    end

    pcall(function()
        widget.Text = text
    end)
end

local passiveKarmaCheckbox = mainTab:Checkbox({
    Label = "Passive Karma",
    Value = passiveKarmaEnabled,
    Callback = function(_, enabled)
        if enabled and Experiments:IsEnabled() then
            passiveKarmaCheckbox:SetTicked(false)
            return
        end

        PassiveKarma:SetEnabled(enabled)
        settings.PassiveKarmaEnabled = enabled
        saveSettings()
    end,
})

experimentsTab:Checkbox({
    Label = "BookCD Karma",
    Value = experimentsEnabled,
    Callback = function(_, enabled)
        if enabled then
            passiveKarmaCheckbox:SetTicked(false)
        end

        Experiments:SetEnabled(enabled)
        settings.ExperimentsEnabled = enabled
        saveSettings()
    end,
})

mainTab:Checkbox({
    Label = "Enable Nametags",
    Value = nametagsEnabled,
    Callback = function(_, enabled)
        Nametags:SetEnabled(enabled)
        settings.NametagsEnabled = enabled
        saveSettings()
    end,
})

local bindButton
local function updateBindButton()
    setWidgetLabel(bindButton, "Bind Healing Current (" .. HealingCurrent:GetBindingName() .. ")")
end

combatTab:Checkbox({
    Label = "Enable Healing Current",
    Value = healingCurrentEnabled,
    Callback = function(_, enabled)
        HealingCurrent:SetEnabled(enabled)
        settings.HealingCurrentEnabled = enabled
        saveSettings()
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
        saveSettings()
    end,
})

bindButton = combatTab:Button({
    Label = "",
    Callback = function()
        setWidgetLabel(bindButton, "Press a key or mouse button...")

        task.spawn(function()
            local input = UserInputService.InputBegan:Wait()
            local bindingName = HealingCurrent:SetBinding(input)
            if bindingName then
                settings.HealingCurrentBinding = bindingName
                saveSettings()
                updateBindButton()
            end
        end)
    end,
})
updateBindButton()

combatTab:Checkbox({
    Label = "Enable Parry Extender",
    Value = parryExtenderEnabled,
    Callback = function(_, enabled)
        ParryExtender:SetEnabled(enabled)
        settings.ParryExtenderEnabled = enabled
        saveSettings()
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
        saveSettings()
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
        saveSettings()
    end,
})

combatTab:Checkbox({
    Label = "Dodge After Parry",
    Value = parryDodgeEnabled,
    Callback = function(_, enabled)
        parryDodgeEnabled = enabled
        settings.ParryDodgeEnabled = enabled
        ParryExtender:SetDodgeEnabled(enabled)
        saveSettings()
    end,
})

combatTab:Slider({
    Label = "Dodge After Parry Delay (ms)",
    MinValue = 0,
    MaxValue = 2000,
    Value = parryDodgeDelay,
    Format = "%dms",
    Callback = function(_, value)
        parryDodgeDelay = math.clamp(math.round(value), 0, 2000)
        settings.ParryDodgeDelay = parryDodgeDelay
        ParryExtender:SetDodgeDelay(parryDodgeDelay / 1000)
        saveSettings()
    end,
})

local terminated = false
local visibilityConnection

miscellaneousTab:Button({
    Label = "Terminate",
    Callback = function()
        if terminated then
            return
        end

        terminated = true
        PassiveKarma:SetEnabled(false)
        HealingCurrent:SetEnabled(false)
        ParryExtender:SetEnabled(false)
        ParryExtender:SetDodgeEnabled(false)
        Nametags:SetEnabled(false)
        Experiments:SetEnabled(false)

        if visibilityConnection then
            visibilityConnection:Disconnect()
        end

        ImGui.ScreenGui:Destroy()
        ImGui.FullScreenGui:Destroy()
    end,
})

visibilityConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or input.KeyCode ~= Enum.KeyCode.F2 then
        return
    end

    local visible = not ImGui.ScreenGui.Enabled
    ImGui.ScreenGui.Enabled = visible
    ImGui.FullScreenGui.Enabled = visible
end)

return PassiveKarma
