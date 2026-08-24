local BASE_URL = "https://raw.githubusercontent.com/mooressyrup/Project-Ego/main/"

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
local HealingCurrent = loadModule("HealingCurrent.lua")
local ParryExtender = loadModule("ParryExtender.lua")

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
    Label = "Healing Current Delay",
    MinValue = 0,
    MaxValue = 2,
    Value = 0.05,
    Format = "%.2fs",
    Callback = function(_, value)
        HealingCurrent:SetDelay(value)
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
    Label = "Parry Delay",
    MinValue = 0,
    MaxValue = 2,
    Value = 0.5,
    Format = "%.2fs",
    Callback = function(_, value)
        ParryExtender:SetDelay(value)
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
