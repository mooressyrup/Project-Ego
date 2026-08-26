local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local Experiments = {}
local localPlayer = Players.LocalPlayer
local enabled = false
local runId = 0
local bookCDRemovedConnection
local globalShadowsDisabled = false
local originalGlobalShadows = Lighting.GlobalShadows

function Experiments:SetEnabled(value)
	if enabled == value then
		return
	end

	enabled = value
	runId += 1

	if bookCDRemovedConnection then
		bookCDRemovedConnection:Disconnect()
		bookCDRemovedConnection = nil
	end

	if not enabled then
		return
	end

	local currentRunId = runId
	local scrollRemote

	task.spawn(function()
		scrollRemote = ReplicatedStorage:WaitForChild("Events2"):WaitForChild("Scroll")
		if enabled and currentRunId == runId then
			scrollRemote:FireServer("Start")
		end
	end)

	bookCDRemovedConnection = localPlayer.ChildRemoved:Connect(function(child)
		if not child:IsA("IntValue") or child.Name ~= "BookCD" then
			return
		end

		task.delay(0, function()
			if enabled and currentRunId == runId and scrollRemote then
				scrollRemote:FireServer("Give", "Order")
				scrollRemote:FireServer("Start")
			end
		end)
	end)
end

function Experiments:IsEnabled()
	return enabled
end

function Experiments:SetGlobalShadowsDisabled(value)
	globalShadowsDisabled = value
	Lighting.GlobalShadows = not globalShadowsDisabled and originalGlobalShadows
end

return Experiments
