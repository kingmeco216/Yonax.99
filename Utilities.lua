--[[
    Utility Functions
    Support script for 99Night in Forest
]]

local Utilities = {}

-- ESP (Extra Sensory Perception) Functions
function Utilities.createESP(target)
    if not target or not target:IsA("Model") then
        return
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Parent = target
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    
    return highlight
end

-- Teleport function
function Utilities.teleportTo(position)
    local player = game:GetService("Players").LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(position)
        return true
    end
    return false
end

-- Speed modification
function Utilities.setWalkSpeed(speed)
    local player = game:GetService("Players").LocalPlayer
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = speed
        return true
    end
    return false
end

-- Jump power modification
function Utilities.setJumpPower(power)
    local player = game:GetService("Players").LocalPlayer
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.JumpPower = power
        return true
    end
    return false
end

-- Notification system
function Utilities.notify(title, text, duration)
    duration = duration or 5
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration
    })
end

-- Find nearest player
function Utilities.findNearestPlayer()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local nearestPlayer = nil
    local shortestDistance = math.huge
    
    for _, otherPlayer in pairs(game:GetService("Players"):GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (character.HumanoidRootPart.Position - otherPlayer.Character.HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                nearestPlayer = otherPlayer
            end
        end
    end
    
    return nearestPlayer, shortestDistance
end

return Utilities
