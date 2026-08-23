local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PassiveKarma = {}
local enabled = false
local runId = 0

function PassiveKarma:SetEnabled(value)
	if enabled == value then
		return
	end

	enabled = value
	runId += 1

	if not enabled then
		return
	end

	local currentRunId = runId
	task.spawn(function()
		local scrollRemote = ReplicatedStorage:WaitForChild("Events2"):WaitForChild("Scroll")

		while enabled and currentRunId == runId do
			scrollRemote:FireServer("Start")
			task.wait(10)

			if enabled and currentRunId == runId then
				scrollRemote:FireServer("Give", "Order")
			end
		end
	end)
end

function PassiveKarma:IsEnabled()
	return enabled
end

return PassiveKarma
