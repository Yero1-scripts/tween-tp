local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local TweenTP = {}
TweenTP.__index = TweenTP

-- Configuration
local CONFIG = {
	TWEEN_DURATION = 1, -- Duration in seconds
	EASING_STYLE = Enum.EasingStyle.Quad,
	EASING_DIRECTION = Enum.EasingDirection.InOut,
	HOLD_OBJECT = true, -- Hold flying carpet while tweening
}

-- Create a new TweenTP instance
function TweenTP.new(character)
	local self = setmetatable({}, TweenTP)
	self.character = character
	self.humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	self.isActive = false
	return self
end

-- Tween to a target position
function TweenTP:TweenTo(targetPosition, duration, holdObject)
	if self.isActive then
		warn("Tween already in progress")
		return
	end
	
	self.isActive = true
	duration = duration or CONFIG.TWEEN_DURATION
	holdObject = holdObject ~= nil and holdObject or CONFIG.HOLD_OBJECT
	
	-- Create tween info
	local tweenInfo = TweenInfo.new(
		duration,
		CONFIG.EASING_STYLE,
		CONFIG.EASING_DIRECTION
	)
	
	-- Create the tween
	local tween = TweenService:Create(self.humanoidRootPart, tweenInfo, {
		CFrame = CFrame.new(targetPosition + Vector3.new(0, 3, 0)) -- Offset to avoid clipping
	})
	
	-- Handle object holding (e.g., flying carpet)
	if holdObject then
		self:HoldObject()
	end
	
	-- Connect events
	tween.Completed:Connect(function()
		self.isActive = false
		if holdObject then
			self:ReleaseObject()
		end
	end)
	
	-- Start the tween
	tween:Play()
	return tween
end

-- Hold an object while tweening (e.g., flying carpet)
function TweenTP:HoldObject()
	local humanoid = self.character:WaitForChild("Humanoid")
	
	-- Look for a carpet or object to hold
	for _, part in pairs(self.character:GetChildren()) do
		if part:IsA("Model") or part:IsA("BasePart") then
			if part.Name:lower():find("carpet") or part.Name:lower():find("broom") then
				-- Position object in front/below character
				if part:IsA("BasePart") then
					part.CFrame = self.humanoidRootPart.CFrame * CFrame.new(0, -3, 5)
				end
			end
		end
	end
end

-- Release the held object
function TweenTP:ReleaseObject()
	-- Object releases naturally, or you can add custom logic here
end

-- Quick teleport function
function TweenTP:QuickTP(targetPosition, duration)
	self:TweenTo(targetPosition, duration or CONFIG.TWEEN_DURATION, true)
end

-- Static function to tween any player
function TweenTP.TweenPlayer(player, targetPosition, duration, holdObject)
	if not player.Character then
		warn("Player has no character")
		return
	end
	
	local tweenTP = TweenTP.new(player.Character)
	return tweenTP:TweenTo(targetPosition, duration, holdObject)
end

return TweenTP
-- TweenTP Module for Roblox
