local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService") 
local RunService = game:GetService("RunService") -- Добавлено для стабильного ноуклипа
local LocalPlayer = Players.LocalPlayer

-- Обход простых проверок на наличие чит-интерфейсов
local TargetParent = LocalPlayer:WaitForChild("PlayerGui")
pcall(function()
    if game:GetService("CoreGui") then
        TargetParent = game:GetService("CoreGui")
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "System_Localization_Pack" 
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = TargetParent

-- Главная панель
local MainPanel = Instance.new("Frame")
MainPanel.Size = UDim2.new(0, 250, 0, 180) 
MainPanel.Position = UDim2.new(0.05, 0, 0.4, 0)
MainPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainPanel.BorderSizePixel = 0
MainPanel.Active = true
MainPanel.ClipsDescendants = true 
MainPanel.Parent = ScreenGui

-- Скругление углов
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainPanel

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "Служебный Модуль" 
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.Parent = MainPanel

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- Кнопка Свернуть/Развернуть
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -35, 0, 0)
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.TextSize = 20
MinimizeButton.ZIndex = 5 
MinimizeButton.Parent = MainPanel

-- Контейнер для кнопок управления
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -30)
ContentFrame.Position = UDim2.new(0, 0, 0, 30)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainPanel

-- Кнопка Вкл/Выкл
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.9, 0, 0, 40)
ToggleButton.Position = UDim2.new(0.05, 0, 0.1, 0)
ToggleButton.Text = "Статус: ВЫКЛ"
ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSans
ToggleButton.TextSize = 16
ToggleButton.Parent = ContentFrame

-- Поле ввода скорости
local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(0.9, 0, 0, 40)
SpeedInput.Position = UDim2.new(0.05, 0, 0.45, 0)
SpeedInput.Text = "20" 
SpeedInput.PlaceholderText = "Безопасная скорость (10-30)"
SpeedInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.Font = Enum.Font.SourceSans
SpeedInput.TextSize = 14
SpeedInput.Parent = ContentFrame

-- Логика работы
local isFarming = false
local farmSpeed = 20
local isMinimized = false
local collectedCoins = 0
local coinsToReset = math.random(40, 50) -- Случайный лимит от 40 до 50 для беспалевности

-- Логика переключения размера (Свернуть/Развернуть)
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetHeight = isMinimized and 30 or 180
    local targetText = isMinimized and "+" or "-"
    MinimizeButton.Text = targetText
    ContentFrame.Visible = not isMinimized
    
    local sizeTween = TweenService:Create(MainPanel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 250, 0, targetHeight)
    })
    sizeTween:Play()
end)

-- Ваше мобильное перетаскивание пальцем (оставлено без изменений)
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainPanel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainPanel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local mousePos = UserInputService:GetMouseLocation()
        if input.Position.X > MinimizeButton.AbsolutePosition.X and input.Position.Y < (MinimizeButton.AbsolutePosition.Y + MinimizeButton.AbsoluteSize.Y) then
            return
        end
        dragging = true
        dragStart = input.Position
        startPos = MainPanel.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

MainPanel.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

SpeedInput.FocusLost:Connect(function()
    local value = tonumber(SpeedInput.Text)
    if value then
        farmSpeed = math.clamp(value, 5, 35) 
        SpeedInput.Text = tostring(farmSpeed)
    else
        SpeedInput.Text = tostring(farmSpeed)
    end
end)

ToggleButton.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    if isFarming then
        ToggleButton.Text = "Статус: АКТИВЕН"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
    else
        ToggleButton.Text = "Статус: ВЫКЛ"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    end
end)

-- Постоянный Ноуклип во время фарма (каждый кадр отключает коллизию)
RunService.Stepped:Connect(function()
    if isFarming and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- Умный цикл сбора: под землей и к ближайшей монете
task.spawn(function()
    while true do
        task.wait(0.2) 
        if isFarming and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            
            -- Проверка на авто-ресет
            if collectedCoins >= coinsToReset then
                isFarming = false
                ToggleButton.Text = "Ресет..."
                ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 130, 50)
                
                humanoid.Health = 0 -- Убиваем персонажа
                collectedCoins = 0
                coinsToReset = math.random(40, 50) -- Новый случайный лимит
                
                -- Ждем пока персонаж полностью возродится
                LocalPlayer.CharacterAdded:Wait()
                task.wait(2) -- Даем прогрузиться карте после спавна
                
                isFarming = true
                ToggleButton.Text = "Статус: АКТИВЕН"
                ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
            end

            local coinContainer = workspace:FindFirstChild("CoinContainer") or (workspace:FindFirstChild("PoliceStation") and workspace.PoliceStation:FindFirstChild("CoinContainer"))
            
            if coinContainer and isFarming then
                -- 1. Сбор всех доступных монет в таблицу
                local availableCoins = {}
                for _, coin in ipairs(coinContainer:GetChildren()) do
                    if coin:IsA("Part") or coin:IsA("MeshPart") or coin:FindFirstChild("TouchInterest") then
                        table.insert(availableCoins, coin)
                    end
                end
                
                -- 2. Поиск самой ближайшей монеты
                local closestCoin = nil
                local shortestDistance = math.huge
                
                for _, coin in ipairs(availableCoins) do
                    local distance = (hrp.Position - coin.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestCoin = coin
                    end
                end
                
                -- 3. Движение к монете со смещением под землю
                if closestCoin and isFarming then
                    -- Смещение по оси Y вниз на 6 студий (под землю относительно монеты)
                    local safeTargetCFrame = closestCoin.CFrame * CFrame.new(0, -6, 0)
                    
                    local distance = (hrp.Position - safeTargetCFrame.Position).Magnitude
                    local duration = distance / (farmSpeed * 5) 
                    if duration > 3 then duration = 0.5 end 

                    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
                    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = safeTargetCFrame})
                    
                    tween:Play()
                    tween.Completed:Wait() 
                    
                    -- Кратковременный прыжок вверх строго для касания монеты и обратно под землю
                    if isFarming then
                        hrp.CFrame = closestCoin.CFrame
                        task.wait(0.05) -- Мгновенно забираем
                        hrp.CFrame = safeTargetCFrame -- Падаем обратно под землю
                        collectedCoins = collectedCoins + 1 -- Засчитываем монету в счетчик ресета
                    end
                    
                    task.wait(0.1) 
                end
            end
        end
    end
