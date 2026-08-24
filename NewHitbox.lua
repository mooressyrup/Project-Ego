getgenv().HBE = true -- HBE Variable, use this to control whether the hitboxes are active or not.
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function GetCharParent()
	local charParent
	repeat
		wait()
	until LocalPlayer.Character
	for _, char in pairs(workspace:GetDescendants()) do
		if string.find(char.Name, LocalPlayer.Name) and char:FindFirstChild("Humanoid") then
			charParent = char.Parent
			break
		end
	end
	return charParent
end

-- pcall to avoid the script breaking on low level executors (e.g. Solara or any Xeno paste)
pcall(function()
	local mt = getrawmetatable(game)
	setreadonly(mt, false)
	local old = mt.__index
	mt.__index = function(Self, Key)
		if tostring(Self) == "HumanoidRootPart" and tostring(Key) == "Size" then
			return Vector3.new(2, 2, 1)
		end
		return old(Self, Key)
	end
	setreadonly(mt, true)
end)

local CHAR_PARENT = GetCharParent()
local HITBOX_SIZE = Vector3.new(15, 15, 15) -- Default size. You can let the user choose with a slider. e.g. HITBOX_SIZE = Vector3.new(Value, Value, Value)
local HITBOX_COLOUR = Color3.fromRGB(255, 0, 0) -- Default colour (RGB)

local function AssignHitboxes(player)
	if player == LocalPlayer then
		return
	end

	local hitbox_connection
	hitbox_connection = game:GetService("RunService").RenderStepped:Connect(function()
		local char = CHAR_PARENT:FindFirstChild(player.Name)
		if getgenv().HBE then
			if
				char
				and char:FindFirstChild("HumanoidRootPart")
				and (char.HumanoidRootPart.Size ~= HITBOX_SIZE or char.HumanoidRootPart.Color ~= HITBOX_COLOUR)
			then
				char.HumanoidRootPart.Size = HITBOX_SIZE
				char.HumanoidRootPart.Color = HITBOX_COLOUR
				char.HumanoidRootPart.CanCollide = false
				char.HumanoidRootPart.Transparency = 0.5
			end
		else
			hitbox_connection:Disconnect()
			char.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
			char.HumanoidRootPart.Transparency = 1
		end
	end)
end

for _, player in ipairs(Players:GetPlayers()) do
	AssignHitboxes(player)
end

Players.PlayerAdded:Connect(function(player)
	if getgenv().HBE then
		AssignHitboxes(player)
	end
end)
