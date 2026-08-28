-- MM2 Auto Farm (FIXED - CoinContainer Model + FLYING + FAST HIT)
local player = game:GetService("Players").LocalPlayer
local runService = game:GetService("RunService")
local userInput = game:GetService("UserInputService")

-- Variables
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local speed = 16
local isRunning = false
local isMinimized = false
local noclipEnabled = true

-- Physics Variables (для полета)
local linearVelocity = nil
local attachment = nil

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "AutoFarmGUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 280, 0, 230)
main.Position = UDim2.new(0.5, -140, 0.5, -115)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
main.BackgroundTransparency = 0.1
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.ClipsDescendants = true
main.Parent = gui

-- Blur
Instance.new("BlurEffect", main).Size = 6

-- Title Bar
local bar = Instance.new("Frame", main)
bar.Size = UDim2.new(1, 0, 0, 30)
bar.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
bar.BorderSizePixel = 0

-- Title
local title = Instance.new("TextLabel", bar)
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🪙 AUTO FARM"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left

-- Minimize Button
local minBtn = Instance.new("TextButton", bar)
minBtn.Size = UDim2.new(0, 24, 0, 24)
minBtn.Position = UDim2.new(1, -60, 0, 3)
minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
minBtn.BorderSizePixel = 0
minBtn.Text = "─"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.TextSize = 14
minBtn.Font = Enum.Font.GothamBold

-- Close Button
local closeBtn = Instance.new("TextButton", bar)
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -32, 0, 3)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 12
closeBtn.Font = Enum.Font.GothamBold

-- Content
local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, 0, 1, -30)
content.Position = UDim2.new(0, 0, 0, 30)
content.BackgroundTransparency = 1

-- Speed Control
local speedFrame = Instance.new("Frame", content)
speedFrame.Size = UDim2.new(0, 250, 0, 35)
speedFrame.Position = UDim2.new(0.5, -125, 0, 10)
speedFrame.BackgroundTransparency = 1

local speedLabel = Instance.new("TextLabel", speedFrame)
speedLabel.Size = UDim2.new(0, 100, 1, 0)
speedLabel.Position = UDim2.new(0, 0, 0, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: 16"
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
speedLabel.TextSize = 13
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextXAlignment = Enum.TextXAlignment.Left

local speedInput = Instance.new("TextBox", speedFrame)
speedInput.Size = UDim2.new(0, 70, 1, 0)
speedInput.Position = UDim2.new(1, -70, 0, 0)
speedInput.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
speedInput.BorderSizePixel = 0
speedInput.Text = "16"
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.TextSize = 13
speedInput.Font = Enum.Font.GothamBold
speedInput.ClearTextOnFocus = false

speedInput.FocusLost:Connect(function()
    local val = tonumber(speedInput.Text)
    if val then
        speed = math.clamp(val, 1, 50)
        speedInput.Text = tostring(speed)
        speedLabel.Text = "Speed: " .. speed
    else
        speedInput.Text = tostring(speed)
    end
end)

-- Noclip Toggle
local noclipBtn = Instance.new("TextButton", content)
noclipBtn.Size = UDim2.new(0, 120, 0, 30)
noclipBtn.Position = UDim2.new(0.5, -125, 0, 55)
noclipBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
noclipBtn.BorderSizePixel = 0
noclipBtn.Text = "🛡 NOCLIP ON"
noclipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
noclipBtn.TextSize = 13
noclipBtn.Font = Enum.Font.GothamBold

noclipBtn.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    noclipBtn.Text = noclipEnabled and "🛡 NOCLIP ON" or "🛡 NOCLIP OFF"
    noclipBtn.BackgroundColor3 = noclipEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

-- Start/Stop Button
local toggleBtn = Instance.new("TextButton", content)
toggleBtn.Size = UDim2.new(0, 120, 0, 35)
toggleBtn.Position = UDim2.new(0.5, 5, 0, 55)
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
toggleBtn.BorderSizePixel = 0
toggleBtn.Text = "▶ START"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.GothamBold

-- Status
local status = Instance.new("TextLabel", content)
status.Size = UDim2.new(1, 0, 0, 20)
status.Position = UDim2.new(0, 0, 0, 105)
status.BackgroundTransparency = 1
status.Text = "● IDLE"
status.TextColor3 = Color3.fromRGB(255, 100, 100)
status.TextSize = 12
status.Font = Enum.Font.GothamBold

-- Stats
local statsLabel = Instance.new("TextLabel", content)
statsLabel.Size = UDim2.new(1, 0, 0, 20)
statsLabel.Position = UDim2.new(0, 0, 0, 125)
statsLabel.BackgroundTransparency = 1
statsLabel.Text = "Coins: 0 | AFK: Off"
statsLabel.TextColor3 = Color3.fromRGB(150, 150, 200)
statsLabel.TextSize = 11
statsLabel.Font = Enum.Font.Gotham

-- Minimize function
minBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    main.Size = isMinimized and UDim2.new(0, 280, 0, 30) or UDim2.new(0, 280, 0, 230)
    content.Visible = not isMinimized
end)

-- Close function
closeBtn.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
end)

-- NOCLIP FUNCTION
local function enableNoclip()
    if not noclipEnabled then return end
    
    local char = player.Character
    if not char then return end
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

-- Keep character upright
local function keepUpright()
    local char = player.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, hrp.Orientation.Y / 57.3, 0)
    end
end

-- Anti-AFK
local function antiAFK()
    local vk = game:GetService("VirtualUser")
    if vk then
        pcall(function()
            vk:CaptureController()
            vk:ClickButton2(Vector2.new())
        end)
    end
end

-- FIND COINS (FIXED - CoinContainer is Model, Coin_Server are Parts)
local function findCoins()
    local coins = {}
    local container = workspace:FindFirstChild("CoinContainer")
    
    if container then
        for _, child in pairs(container:GetChildren()) do
            if child.Name == "Coin_Server" and child:IsA("BasePart") and child.Parent then
                if child:FindFirstChild("Handle") or child:IsA("Part") then
                    table.insert(coins, child)
                end
            end
        end
    else
        for _, child in pairs(workspace:GetDescendants()) do
            if child.Name == "Coin_Server" and child:IsA("BasePart") and child.Parent and child.Parent.Name == "CoinContainer" then
                table.insert(coins, child)
            end
        end
    end
    
    return coins
end

-- Создание объекта полета (LinearVelocity)
local function getLinearVelocity(hrp)
    if not linearVelocity or linearVelocity.Parent ~= hrp then
        if linearVelocity then linearVelocity:Destroy() end
        if attachment then attachment:Destroy() end
        
        attachment = Instance.new("Attachment")
        attachment.Name = "FlyAttachment"
        attachment.Parent = hrp
        
        linearVelocity = Instance.new("LinearVelocity")
        linearVelocity.Name = "FlyLinearVelocity"
        linearVelocity.MaxForce = math.huge
        linearVelocity.Attachment0 = attachment
        linearVelocity.Parent = hrp
    end
    return linearVelocity
end

-- Move to target (NO SLOWDOWN)
local function moveTo(target)
    if not target or not target.Parent then return false end
    
    local char = player.Character
    if not char then return false end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    enableNoclip()
    keepUpright()
    
    local distance = (hrp.Position - target.Position).Magnitude
    
    -- Дистанция остановки (0.5 - влетает прямо в монету)
    if distance > 0.5 then
        status.Text = "✈ Flying to coin..."
        
        local vel = getLinearVelocity(hrp)
        local startTime = os.clock()
        local timeout = 10

        while isRunning and target.Parent and (hrp.Position - target.Position).Magnitude > 0.5 and (os.clock() - startTime) < timeout do
            local direction = (target.Position - hrp.Position).Unit
            
            -- МАКСИМАЛЬНАЯ СКОРОСТЬ без замедления
            vel.VectorVelocity = direction * (speed * 2)
            
            runService.Heartbeat:Wait()
        end
        
        -- Останавливаемся сразу после касания
        if linearVelocity then
            linearVelocity.VectorVelocity = Vector3.zero
        end
        
        return true
    end
    
    return true
end

-- Main farm loop
local collected = 0
local afkTimer = 0

local function farmLoop()
    while isRunning do
        enableNoclip()
        keepUpright()
        
        local coins = findCoins()
        
        if #coins > 0 then
            status.Text = "🔍 Found " .. #coins .. " coins"
            status.TextColor3 = Color3.fromRGB(255, 200, 0)
            
            -- Sort by distance
            local char = player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    table.sort(coins, function(a, b)
                        return (hrp.Position - a.Position).Magnitude < (hrp.Position - b.Position).Magnitude
                    end)
                end
            end
            
            -- Go to each coin
            for _, coin in ipairs(coins) do
                if not isRunning then break end
                if not coin.Parent then continue end
                
                status.Text = "🎯 Moving to coin..."
                status.TextColor3 = Color3.fromRGB(100, 200, 255)
                
                local success = moveTo(coin)
                
                if success and coin.Parent then
                    status.Text = "✅ Collecting..."
                    status.TextColor3 = Color3.fromRGB(50, 255, 50)
                    
                    if not coin.Parent then
                        collected = collected + 1
                        statsLabel.Text = "Coins: " .. collected .. " | AFK: On"
                        status.Text = "💰 +1 (" .. collected .. " total)"
                        status.TextColor3 = Color3.fromRGB(0, 255, 0)
                    end
                end
                
                -- Anti-AFK every 20 seconds
                afkTimer = afkTimer + 1
                if afkTimer >= 20 then
                    antiAFK()
                    afkTimer = 0
                end
                
                task.wait()
            end
        else
            status.Text = "⏳ No coins found..."
            status.TextColor3 = Color3.fromRGB(255, 100, 100)
            task.wait(0.5)
            
            afkTimer = afkTimer + 1
            if afkTimer >= 10 then
                antiAFK()
                afkTimer = 0
            end
        end
        
        task.wait()
    end
end

-- Toggle farm
toggleBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    
    if isRunning then
        toggleBtn.Text = "⏹ STOP"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        status.Text = "▶ RUNNING..."
        status.TextColor3 = Color3.fromRGB(50, 255, 50)
        statsLabel.Text = "Coins: " .. collected .. " | AFK: On"
        afkTimer = 0
        
        enableNoclip()
        task.spawn(farmLoop)
    else
        toggleBtn.Text = "▶ START"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        status.Text = "● STOPPED"
        status.TextColor3 = Color3.fromRGB(255, 100, 100)
        statsLabel.Text = "Coins: " .. collected .. " | AFK: Off"
        
        -- Очистка физики полета при остановке
        if linearVelocity then
            linearVelocity:Destroy()
            linearVelocity = nil
        end
        if attachment then
            attachment:Destroy()
            attachment = nil
        end
    end
end)

-- Hotkey (RightShift)
userInput.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightShift then
        main.Visible = not main.Visible
    end
end)

-- Character respawn
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    task.wait(0.5)
    
    -- Сбрасываем переменные полета при респавне
    linearVelocity = nil
    attachment = nil
    
    if noclipEnabled then
        enableNoclip()
    end
    
    if isRunning then
        status.Text = "🔄 Respawned..."
        status.TextColor3 = Color3.fromRGB(255, 200, 0)
    end
end)

-- Keep noclip active
runService.Heartbeat:Connect(function()
    if isRunning or noclipEnabled then
        enableNoclip()
        keepUpright()
    end
end)

print("✅ AUTO FARM LOADED!")
print("📁 CoinContainer: " .. tostring(workspace:FindFirstChild("CoinContainer") ~= nil))
print("🪙 Coin_Server parts found: " .. #findCoins())
print("✈ Flying Mode: Enabled (NO SLOWDOWN)")
print("⬆ Press RightShift to toggle GUI")
