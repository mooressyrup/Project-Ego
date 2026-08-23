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
local Teams = game:GetService("Teams")
local PassiveKarma = loadModule("PassiveKarma.lua")
local HitboxExtender = loadModule("HitboxExtender.lua")
local Keybinds = loadModule("Keybinds.lua")

local teamNames = { "None" }
for _, team in Teams:GetTeams() do
    table.insert(teamNames, team.Name)
end
table.sort(teamNames)

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

local keybindsTab = window:CreateTab({
    Name = "Keybinds",
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

combatTab:Checkbox({
    Label = "M1 Hitbox",
    Value = false,
    Callback = function(_, enabled)
        HitboxExtender:SetEnabled(enabled)
    end,
})

combatTab:Checkbox({
    Label = "View Hitboxes",
    Value = false,
    Callback = function(_, enabled)
        HitboxExtender:SetViewEnabled(enabled)
    end,
})

combatTab:Slider({
    Label = "Hit Chance",
    MinValue = 0,
    MaxValue = 100,
    Value = 100,
    Format = "%d%%",
    Callback = function(_, value)
        HitboxExtender:SetChance(value)
    end,
})

combatTab:Slider({
    Label = "Hitbox Size",
    MinValue = 1,
    MaxValue = 50,
    Value = 10,
    Format = "%d",
    Callback = function(_, value)
        HitboxExtender:SetSize(value)
    end,
})

combatTab:Combo({
    Label = "Hitbox Whitelist",
    Items = teamNames,
    Selected = "None",
    Callback = function(_, teamName)
        HitboxExtender:SetWhitelistedTeam(teamName == "None" and nil or teamName)
    end,
})

local selectedSlot = 1
local bindButton
local function setBindButtonText(text)
    local label = bindButton:FindFirstChild("Label", true)
    if label and (label:IsA("TextLabel") or label:IsA("TextButton")) then
        label.Text = text
    else
        bindButton.Text = text
    end
end

local function updateBindButton()
    if not bindButton then
        return
    end

    setBindButtonText(("Bind Slot %d (%s)"):format(
        selectedSlot,
        Keybinds:GetBindingName(selectedSlot)
    ))
end

keybindsTab:Slider({
    Label = "Hotbar Slot",
    MinValue = 1,
    MaxValue = 10,
    Value = selectedSlot,
    Format = "%d",
    Callback = function(_, value)
        selectedSlot = math.round(value)
        updateBindButton()
    end,
})

bindButton = keybindsTab:Button({
    Label = "Bind Slot 1 (Unbound)",
    Callback = function()
        setBindButtonText("Press a keyboard key or side mouse button...")

        task.spawn(function()
            local input = UserInputService.InputBegan:Wait()
            Keybinds:SetBinding(selectedSlot, input)
            updateBindButton()
        end)
    end,
})
updateBindButton()

keybindsTab:Button({
    Label = "Clear Selected Binding",
    Callback = function()
        Keybinds:ClearBinding(selectedSlot)
        updateBindButton()
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
