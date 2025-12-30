--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                    YONAX.99 MOD MENU                         ║
    ║              99 Nights in the Forest - Roblox                ║
    ║                                                              ║
    ║  Version: 1.0                                                ║
    ║  Author: yonax                                               ║
    ║  Last Updated: December 30, 2025                             ║
    ║                                                              ║
    ║  Features:                                                   ║
    ║  • Auto Farm (Cultists, Rabbits, Wolves, Alpha Wolves)      ║
    ║  • Auto Collect Items (Hides, Wood, Loot)                   ║
    ║  • Auto Open Chests                                          ║
    ║  • Auto Chop Trees                                           ║
    ║  • Smart Teleports (Nearest Location)                        ║
    ║  • Draggable GUI with Minimize                               ║
    ║                                                              ║
    ║  Controls:                                                   ║
    ║  • RIGHT CTRL - Toggle menu visibility                       ║
    ║  • Drag title bar - Move menu                                ║
    ║  • - button - Minimize menu                                  ║
    ║  • X button - Close menu                                     ║
    ╚══════════════════════════════════════════════════════════════╝
]]

print("╔══════════════════════════════════════╗")
print("║     Loading yonax.99 Mod Menu...     ║")
print("╚══════════════════════════════════════╝")

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Settings
local Settings = {
    AutoFarmCultists = false,
    AutoFarmRabbits = false,
    AutoFarmWolves = false,
    AutoFarmAlphaWolves = false,
    AutoCollectItems = false,
    AutoOpenChests = false,
    AutoChopTrees = false,
}

local IsRunning = false
local CurrentTarget = nil
local ItemsCollected = 0

-- ════════════════════════════════════════════════════════════════
--                        UTILITY FUNCTIONS
-- ════════════════════════════════════════════════════════════════

local function GetChar() return LocalPlayer.Character end
local function GetRoot() local c = GetChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function GetHum() local c = GetChar() return c and c:FindFirstChild("Humanoid") end

local function TP(pos)
    local root = GetRoot()
    if root then root.CFrame = CFrame.new(pos) end
end

local function GetDist(p1, p2) return (p1 - p2).Magnitude end

local function PressKey(key)
    VirtualInputManager:SendKeyEvent(true, key, false, game)
    wait(0.1)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
end

local function HoldKey(key, dur)
    VirtualInputManager:SendKeyEvent(true, key, false, game)
    wait(dur)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
end

-- ════════════════════════════════════════════════════════════════
--                        FARMING FUNCTIONS
-- ════════════════════════════════════════════════════════════════

local function IsAlive(mob)
    if not mob or not mob.Parent then return false end
    local h = mob:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function GetMobType(mob)
    local n = mob.Name:lower()
    if n:match("alpha") and n:match("wolf") then return "AlphaWolf", 1 end
    if n:match("cultist") then return "Cultist", 2 end
    if n:match("wolf") then return "Wolf", 3 end
    if n:match("rabbit") or n:match("bunny") then return "Rabbit", 4 end
    return nil, 999
end

local function FindTarget()
    local root = GetRoot()
    if not root then return nil end
    
    local best, bestDist, bestPri = nil, math.huge, 999
    
    for _, mob in pairs(Workspace:GetDescendants()) do
        if mob:IsA("Model") and mob ~= GetChar() then
            local mType, pri = GetMobType(mob)
            if mType and IsAlive(mob) then
                local should = (mType == "AlphaWolf" and Settings.AutoFarmAlphaWolves) or
                               (mType == "Wolf" and Settings.AutoFarmWolves) or
                               (mType == "Cultist" and Settings.AutoFarmCultists) or
                               (mType == "Rabbit" and Settings.AutoFarmRabbits)
                
                if should then
                    local mRoot = mob:FindFirstChild("HumanoidRootPart")
                    if mRoot then
                        local dist = GetDist(root.Position, mRoot.Position)
                        if dist < 300 and (pri < bestPri or (pri == bestPri and dist < bestDist)) then
                            best, bestDist, bestPri = mob, dist, pri
                        end
                    end
                end
            end
        end
    end
    return best
end

local function AttackMob(mob)
    if not IsAlive(mob) then return false end
    local root = GetRoot()
    local mRoot = mob:FindFirstChild("HumanoidRootPart")
    if not root or not mRoot then return false end
    
    local dist = GetDist(root.Position, mRoot.Position)
    
    if dist > 20 then
        local targetPos = mRoot.Position + Vector3.new(0, 3, 0)
        TP(targetPos)
        wait(0.2)
    end
    
    local char = GetChar()
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then 
            tool:Activate()
        end
    end
    
    return true
end

-- ════════════════════════════════════════════════════════════════
--                      COLLECTION FUNCTIONS
-- ════════════════════════════════════════════════════════════════

local function CollectItems()
    if not Settings.AutoCollectItems then return end
    local root = GetRoot()
    if not root then return end
    
    for _, item in pairs(Workspace:GetDescendants()) do
        local n = item.Name:lower()
        if n:match("hide") or n:match("loot") or n:match("drop") or n:match("wood") or n:match("item") then
            local part = item:IsA("BasePart") and item or (item:IsA("Model") and item.PrimaryPart)
            if part and part:IsA("BasePart") and GetDist(root.Position, part.Position) < 30 then
                TP(part.Position)
                wait(0.2)
                PressKey(Enum.KeyCode.F)
                ItemsCollected = ItemsCollected + 1
                wait(0.1)
            end
        end
    end
end

local function OpenChests()
    if not Settings.AutoOpenChests then return end
    local root = GetRoot()
    if not root then return end
    
    local nearChest, nearDist = nil, math.huge
    for _, chest in pairs(Workspace:GetDescendants()) do
        local n = chest.Name:lower()
        if (n:match("chest") and not n:match("gift")) or n:match("supply") or n:match("loot") then
            local part = chest:IsA("BasePart") and chest or (chest:IsA("Model") and chest.PrimaryPart)
            if part and part:IsA("BasePart") then
                local dist = GetDist(root.Position, part.Position)
                if dist < 100 and dist < nearDist then
                    nearChest, nearDist = part, dist
                end
            end
        end
    end
    
    if nearChest then
        TP(nearChest.Position + Vector3.new(0, 3, 0))
        wait(0.3)
        HoldKey(Enum.KeyCode.E, 2.5)
        wait(1)
    end
end

local function ChopTrees()
    if not Settings.AutoChopTrees then return end
    local root = GetRoot()
    if not root then return end
    
    local nearTree, nearDist = nil, math.huge
    for _, obj in pairs(Workspace:GetDescendants()) do
        local n = obj.Name:lower()
        if (n:match("tree") or n:match("trunk") or n:match("log")) and obj:IsA("BasePart") and obj.Size.Y > 5 then
            local dist = GetDist(root.Position, obj.Position)
            if dist < 40 and dist < nearDist then
                nearTree, nearDist = obj, dist
            end
        end
    end
    
    if nearTree then
        local treePos = nearTree.Position
        local groundPos = Vector3.new(treePos.X, treePos.Y - (nearTree.Size.Y / 2) - 3, treePos.Z + 5)
        TP(groundPos)
        wait(0.4)
        
        local char = GetChar()
        if char then
            local axe = char:FindFirstChild("Axe") or LocalPlayer.Backpack:FindFirstChild("Axe")
            if axe and axe:IsA("Tool") then
                if axe.Parent == LocalPlayer.Backpack then
                    local hum = GetHum()
                    if hum then
                        hum:EquipTool(axe)
                        wait(0.3)
                    end
                end
            end
            
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                for i = 1, 6 do
                    tool:Activate()
                    wait(0.4)
                end
            end
        end
        wait(0.5)
    end
end

-- ════════════════════════════════════════════════════════════════
--                      TELEPORT FUNCTIONS
-- ════════════════════════════════════════════════════════════════

local function FindByName(terms)
    local root = GetRoot()
    if not root then return nil end
    
    local nearest, nearestDist = nil, math.huge
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local n = obj.Name:lower()
            for _, term in pairs(terms) do
                if n:match(term) then
                    local pos = nil
                    if obj:IsA("Model") then
                        local r = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
                        if r then pos = r.Position end
                    else
                        pos = obj.Position
                    end
                    
                    if pos then
                        local dist = GetDist(root.Position, pos)
                        if dist < nearestDist then
                            nearest = pos
                            nearestDist = dist
                        end
                    end
                    break
                end
            end
        end
    end
    return nearest
end

-- ════════════════════════════════════════════════════════════════
--                          MAIN LOOP
-- ════════════════════════════════════════════════════════════════

local function MainLoop()
    while IsRunning do
        wait(0.3)
        pcall(function()
            local h = GetHum()
            if h and h.Health < 20 then wait(3) return end
            
            CollectItems()
            OpenChests()
            ChopTrees()
            
            if CurrentTarget then
                if not IsAlive(CurrentTarget) then
                    print("✓ Target eliminated, searching for next...")
                    CurrentTarget = nil
                    wait(0.5)
                end
            end
            
            if Settings.AutoFarmCultists or Settings.AutoFarmRabbits or Settings.AutoFarmWolves or Settings.AutoFarmAlphaWolves then
                if not CurrentTarget then
                    CurrentTarget = FindTarget()
                    if CurrentTarget then
                        print("→ New target: " .. tostring(GetMobType(CurrentTarget)))
                    else
                        wait(1)
                    end
                end
                
                if CurrentTarget and IsAlive(CurrentTarget) then
                    local success = AttackMob(CurrentTarget)
                    if not success then
                        CurrentTarget = nil
                    end
                else
                    CurrentTarget = nil
                end
            else
                CurrentTarget = nil
            end
        end)
    end
end

-- ════════════════════════════════════════════════════════════════
--                          GUI CREATION
-- ════════════════════════════════════════════════════════════════

local function CreateGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "ModMenu"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 420, 0, 580)
    main.Position = UDim2.new(0.5, -210, 0.5, -290)
    main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    main.BorderSizePixel = 2
    main.BorderColor3 = Color3.fromRGB(0, 255, 0)
    main.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = main
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -80, 0, 35)
    title.Position = UDim2.new(0, 10, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "YONAX.99 MOD MENU"
    title.TextColor3 = Color3.fromRGB(0, 255, 0)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = main
    
    local minimize = Instance.new("TextButton")
    minimize.Size = UDim2.new(0, 30, 0, 30)
    minimize.Position = UDim2.new(1, -70, 0, 5)
    minimize.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    minimize.Text = "-"
    minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimize.TextSize = 20
    minimize.Font = Enum.Font.GothamBold
    minimize.Parent = main
    
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 5)
    minCorner.Parent = minimize
    
    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 30, 0, 30)
    close.Position = UDim2.new(1, -35, 0, 5)
    close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    close.Text = "X"
    close.TextColor3 = Color3.fromRGB(255, 255, 255)
    close.TextSize = 16
    close.Font = Enum.Font.GothamBold
    close.Parent = main
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 5)
    closeCorner.Parent = close
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -20, 1, -50)
    scroll.Position = UDim2.new(0, 10, 0, 45)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 6
    scroll.CanvasSize = UDim2.new(0, 0, 0, 900)
    scroll.Parent = main
    
    local yPos = 5
    
    local function CreateSection(text)
        local sec = Instance.new("TextLabel")
        sec.Size = UDim2.new(1, -20, 0, 25)
        sec.Position = UDim2.new(0, 10, 0, yPos)
        sec.BackgroundTransparency = 1
        sec.Text = text
        sec.TextColor3 = Color3.fromRGB(0, 255, 0)
        sec.TextSize = 15
        sec.Font = Enum.Font.GothamBold
        sec.Parent = scroll
        yPos = yPos + 30
    end
    
    local function CreateToggle(text, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 30)
        frame.Position = UDim2.new(0, 10, 0, yPos)
        frame.BackgroundTransparency = 1
        frame.Parent = scroll
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.65, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 13
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 55, 0, 25)
        btn.Position = UDim2.new(1, -60, 0, 2.5)
        btn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        btn.Text = "OFF"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 12
        btn.Font = Enum.Font.GothamBold
        btn.Parent = frame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 5)
        btnCorner.Parent = btn
        
        local on = false
        btn.MouseButton1Click:Connect(function()
            on = not on
            btn.BackgroundColor3 = on and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(180, 50, 50)
            btn.Text = on and "ON" or "OFF"
            callback(on)
        end)
        
        yPos = yPos + 35
    end
    
    local function CreateButton(text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 32)
        btn.Position = UDim2.new(0, 10, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 13
        btn.Font = Enum.Font.GothamBold
        btn.Parent = scroll
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 5)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(callback)
        yPos = yPos + 37
    end
    
    -- Build Menu
    CreateSection("═══ AUTO FARM ═══")
    CreateToggle("Farm Cultists", function(s) Settings.AutoFarmCultists = s end)
    CreateToggle("Farm Rabbits", function(s) Settings.AutoFarmRabbits = s end)
    CreateToggle("Farm Wolves", function(s) Settings.AutoFarmWolves = s end)
    CreateToggle("Farm Alpha Wolves", function(s) Settings.AutoFarmAlphaWolves = s end)
    
    CreateSection("═══ AUTO COLLECT ═══")
    CreateToggle("Collect Items (F)", function(s) Settings.AutoCollectItems = s end)
    CreateToggle("Open Chests (E)", function(s) Settings.AutoOpenChests = s end)
    CreateToggle("Chop Trees", function(s) Settings.AutoChopTrees = s end)
    
    CreateSection("═══ FARM TELEPORTS ═══")
    CreateButton("TP: Cultist Farm", function()
        local p = FindByName({"cultist"})
        if p then TP(p + Vector3.new(0, 5, 0)) else print("Not found!") end
    end)
    CreateButton("TP: Wolf Farm", function()
        local p = FindByName({"wolf"})
        if p then TP(p + Vector3.new(0, 5, 0)) else print("Not found!") end
    end)
    CreateButton("TP: Bunny Farm", function()
        local p = FindByName({"rabbit", "bunny"})
        if p then TP(p + Vector3.new(0, 5, 0)) else print("Not found!") end
    end)
    CreateButton("TP: Tree Farm", function()
        local p = FindByName({"tree", "trunk"})
        if p then TP(p + Vector3.new(0, 3, 0)) else print("Not found!") end
    end)
    CreateButton("TP: Chest Area", function()
        local p = FindByName({"chest"})
        if p then TP(p + Vector3.new(0, 3, 0)) else print("Not found!") end
    end)
    CreateButton("TP: Trader", function()
        local p = FindByName({"trader", "merchant"})
        if p then TP(p + Vector3.new(0, 3, 0)) else print("Not found!") end
    end)
    CreateButton("TP: Spawn", function() TP(Vector3.new(0, 10, 0)) end)
    
    CreateSection("═══ CONTROLS ═══")
    local startBtn = Instance.new("TextButton")
    startBtn.Size = UDim2.new(1, -20, 0, 45)
    startBtn.Position = UDim2.new(0, 10, 0, yPos)
    startBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
    startBtn.Text = "▶ START GRINDING"
    startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    startBtn.TextSize = 16
    startBtn.Font = Enum.Font.GothamBold
    startBtn.Parent = scroll
    
    local startCorner = Instance.new("UICorner")
    startCorner.CornerRadius = UDim.new(0, 8)
    startCorner.Parent = startBtn
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 25)
    status.Position = UDim2.new(0, 10, 0, yPos + 50)
    status.BackgroundTransparency = 1
    status.Text = "Status: Idle | Items: 0"
    status.TextColor3 = Color3.fromRGB(200, 200, 200)
    status.TextSize = 12
    status.Font = Enum.Font.Gotham
    status.TextXAlignment = Enum.TextXAlignment.Center
    status.Parent = scroll
    
    -- Button Events
    local isMinimized = false
    minimize.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            main:TweenSize(UDim2.new(0, 420, 0, 40), "Out", "Quad", 0.3, true)
            minimize.Text = "+"
        else
            main:TweenSize(UDim2.new(0, 420, 0, 580), "Out", "Quad", 0.3, true)
            minimize.Text = "-"
        end
    end)
    
    close.MouseButton1Click:Connect(function()
        gui.Enabled = false
    end)
    
    startBtn.MouseButton1Click:Connect(function()
        IsRunning = not IsRunning
        if IsRunning then
            startBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
            startBtn.Text = "■ STOP GRINDING"
            spawn(MainLoop)
        else
            startBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
            startBtn.Text = "▶ START GRINDING"
        end
    end)
    
    -- Status Updates
    spawn(function()
        while gui.Parent do
            wait(0.5)
            local st = IsRunning and "Running" or "Idle"
            local tg = CurrentTarget and GetMobType(CurrentTarget) or "None"
            status.Text = string.format("Status: %s | Items: %d | Target: %s", st, ItemsCollected, tg)
        end
    end)
    
    -- Dragging System
    local dragging, dragInput, mousePos, framePos
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = main.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - mousePos
            main.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
    
    title.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    return gui
end

-- ════════════════════════════════════════════════════════════════
--                         INITIALIZATION
-- ════════════════════════════════════════════════════════════════

wait(1)
local MenuGui = CreateGUI()

print("╔══════════════════════════════════════╗")
print("║  ✓ yonax.99 Mod Menu Loaded!         ║")
print("║  → Press RIGHT CTRL to toggle menu   ║")
print("╚══════════════════════════════════════╝")

-- Toggle Menu Visibility
UserInputService.InputBegan:Connect(function(input, gp)
    if input.KeyCode == Enum.KeyCode.RightControl and not gp then
        if MenuGui then
            MenuGui.Enabled = not MenuGui.Enabled
        end
    end
end)
