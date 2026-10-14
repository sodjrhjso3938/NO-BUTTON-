-- // Fatal Floors Auto-Farm v60.0 //
-- Еда тоже выкидывается через Q
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- ========== НАСТРОЙКИ ==========
local config = {
    maxSearchDistance = 5000,
    fullInventoryThreshold = 2,
    teleportDelay = 0.35,
    collectDelay = 0.7,
    dropDelay = 0.6,
    baseReturnDelay = 0.8,
    equipDelay = 0.3,
    dropKeyDelay = 0.25,
    teleportHeight = 3,
    scanFolder = "ProcGenGenerated",
    searchFolders = {
        "CarrotPot2",
        "GreenhouseNoDoors",
        "ProcGenItems",
        "Room",
        "Suite",
        "FactoryForwardPit",
        "RoomPit",
    },
    currencyName = "shard",
    ignoreNames = {"door", "egg", "яйцо"},
    maxDropAttempts = 3,
    minTeleportY = -100,
    maxTeleportY = 2000,
    maxLogLines = 100,
    emptyCyclesBeforeBase = 3,
    
    -- ✅ ВЫЖИВАНИЕ
    hpDropThreshold = 20,
    hpDropInterval = 1.0,
    lowHpThreshold = 50,
    targetHp = 90,
    hpCheckInterval = 0.3,
    eatDelay = 0.5,
    maxEatAttempts = 15,
    eatKey = Enum.KeyCode.R,
    takeKey = Enum.KeyCode.E,
}

-- ========== ЕДА ==========
local foodItems = {
    ["carrot"] = 15,
    ["cooked carrot"] = 30,
    ["ham"] = 40,
    ["cooked ham"] = 80,
}

local function isFood(name)
    local n = name:lower()
    for foodName, hp in pairs(foodItems) do
        if n == foodName or n:find(foodName) then
            return true, foodItems[foodName] or 0
        end
    end
    return false, 0
end

-- ========== GUI РОДИТЕЛЬ ==========
local function getGuiParent()
    if gethui then
        local ok, res = pcall(gethui)
        if ok and res then return res end
    end
    return game:GetService("CoreGui")
end

local parentGui = getGuiParent()
pcall(function()
    local old = parentGui:FindFirstChild("FatalFarmV60")
    if old then old:Destroy() end
end)

-- ========== СПИСКИ ==========
local ignoredItems = {}
local collectedKeys = {}

local function addIgnored(item)
    if item and not table.find(ignoredItems, item) then
        table.insert(ignoredItems, item)
    end
end
local function isIgnored(item)
    return table.find(ignoredItems, item) ~= nil
end
local function markCollected(obj)
    if obj and not collectedKeys[obj] then
        collectedKeys[obj] = true
    end
end
local function isCollected(obj)
    return collectedKeys[obj] == true
end

local function isCurrencyName(name)
    return name:lower():find(config.currencyName) ~= nil
end

local function isEggName(name)
    local n = name:lower()
    return n:find("egg") or n:find("яйцо")
end

-- ========== GUI ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FatalFarmV60"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = parentGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 290, 0, 410)
main.Position = UDim2.new(0.5, -145, 0.5, -205)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(100, 100, 255)
stroke.Thickness = 2
stroke.Transparency = 0.4
stroke.Parent = main

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
header.BorderSizePixel = 0
header.Parent = main
local hCorner = Instance.new("UICorner")
hCorner.CornerRadius = UDim.new(0, 10)
hCorner.Parent = header
local hFix = Instance.new("Frame")
hFix.Size = UDim2.new(1, 0, 0.5, 0)
hFix.Position = UDim2.new(0, 0, 0.5, 0)
hFix.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
hFix.BorderSizePixel = 0
hFix.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 1, 0)
title.Position = UDim2.new(0, 8, 0, 0)
title.BackgroundTransparency = 1
title.Text = "FARM v60"
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 22, 0, 22)
minBtn.Position = UDim2.new(1, -52, 0, 4)
minBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 60)
minBtn.Text = "-"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 14
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.AutoButtonColor = false
minBtn.Parent = header
local mCorner = Instance.new("UICorner")
mCorner.CornerRadius = UDim.new(0, 5)
mCorner.Parent = minBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.Position = UDim2.new(1, -26, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.AutoButtonColor = false
closeBtn.Parent = header
local cCorner = Instance.new("UICorner")
cCorner.CornerRadius = UDim.new(0, 5)
cCorner.Parent = closeBtn

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -16, 0, 38)
toggleBtn.Position = UDim2.new(0, 8, 0, 38)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 60)
toggleBtn.Text = "START"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = main
local tCorner = Instance.new("UICorner")
tCorner.CornerRadius = UDim.new(0, 8)
tCorner.Parent = toggleBtn

local cellsLabel = Instance.new("TextLabel")
cellsLabel.Size = UDim2.new(0.5, -12, 0, 26)
cellsLabel.Position = UDim2.new(0, 8, 0, 84)
cellsLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
cellsLabel.Text = "Ячеек:"
cellsLabel.Font = Enum.Font.GothamBold
cellsLabel.TextSize = 11
cellsLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
cellsLabel.Parent = main
local clCorner = Instance.new("UICorner")
clCorner.CornerRadius = UDim.new(0, 6)
clCorner.Parent = cellsLabel

local cellsInput = Instance.new("TextBox")
cellsInput.Size = UDim2.new(0.5, -12, 0, 26)
cellsInput.Position = UDim2.new(0.5, 4, 0, 84)
cellsInput.BackgroundColor3 = Color3.fromRGB(35, 35, 60)
cellsInput.Text = tostring(config.fullInventoryThreshold)
cellsInput.PlaceholderText = "2"
cellsInput.Font = Enum.Font.GothamBold
cellsInput.TextSize = 12
cellsInput.TextColor3 = Color3.fromRGB(0, 255, 150)
cellsInput.ClearTextOnFocus = false
cellsInput.Parent = main
local ciCorner = Instance.new("UICorner")
ciCorner.CornerRadius = UDim.new(0, 6)
ciCorner.Parent = cellsInput

local hpLabel = Instance.new("TextLabel")
hpLabel.Size = UDim2.new(1, -16, 0, 22)
hpLabel.Position = UDim2.new(0, 8, 0, 116)
hpLabel.BackgroundColor3 = Color3.fromRGB(25, 45, 25)
hpLabel.Text = "HP: 100 / 100"
hpLabel.Font = Enum.Font.GothamBold
hpLabel.TextSize = 11
hpLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
hpLabel.Parent = main
local hpCorner = Instance.new("UICorner")
hpCorner.CornerRadius = UDim.new(0, 6)
hpCorner.Parent = hpLabel

local foodLabel = Instance.new("TextLabel")
foodLabel.Size = UDim2.new(1, -16, 0, 22)
foodLabel.Position = UDim2.new(0, 8, 0, 142)
foodLabel.BackgroundColor3 = Color3.fromRGB(45, 35, 25)
foodLabel.Text = "Еда: 0"
foodLabel.Font = Enum.Font.GothamBold
foodLabel.TextSize = 11
foodLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
foodLabel.Parent = main
local flCorner = Instance.new("UICorner")
flCorner.CornerRadius = UDim.new(0, 6)
flCorner.Parent = foodLabel

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -16, 0, 22)
statusLabel.Position = UDim2.new(0, 8, 0, 168)
statusLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
statusLabel.Text = "Рюкзак: 0 / " .. config.fullInventoryThreshold
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 11
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
statusLabel.Parent = main
local sCorner = Instance.new("UICorner")
sCorner.CornerRadius = UDim.new(0, 6)
sCorner.Parent = statusLabel

local logFrame = Instance.new("ScrollingFrame")
logFrame.Size = UDim2.new(1, -16, 0, 185)
logFrame.Position = UDim2.new(0, 8, 0, 198)
logFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
logFrame.BackgroundTransparency = 0.4
logFrame.BorderSizePixel = 0
logFrame.ScrollBarThickness = 4
logFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255)
logFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
logFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
logFrame.Parent = main

local logCorner = Instance.new("UICorner")
logCorner.CornerRadius = UDim.new(0, 6)
logCorner.Parent = logFrame

local logLayout = Instance.new("UIListLayout")
logLayout.Padding = UDim.new(0, 2)
logLayout.SortOrder = Enum.SortOrder.LayoutOrder
logLayout.Parent = logFrame

local logPadding = Instance.new("UIPadding")
logPadding.PaddingTop = UDim.new(0, 4)
logPadding.PaddingBottom = UDim.new(0, 4)
logPadding.PaddingLeft = UDim.new(0, 6)
logPadding.PaddingRight = UDim.new(0, 6)
logPadding.Parent = logFrame

-- ========== ФУНКЦИИ ==========
local function getAllItems()
    local items = {}
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local char = LocalPlayer.Character
    local function checkItem(item)
        if item:IsA("Tool") then table.insert(items, item) end
    end
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do checkItem(item) end
    end
    if char then
        for _, item in pairs(char:GetChildren()) do checkItem(item) end
    end
    return items
end

local function getInventoryCount()
    local count = 0
    for _ in pairs(getAllItems()) do count = count + 1 end
    return count
end

local function updateStatus()
    statusLabel.Text = "Рюкзак: " .. getInventoryCount() .. " / " .. config.fullInventoryThreshold
end

local function getCurrentHp()
    local char = LocalPlayer.Character
    if not char then return 100, 100 end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return 100, 100 end
    return humanoid.Health, humanoid.MaxHealth
end

local function updateHpLabel()
    local hp, maxHp = getCurrentHp()
    hpLabel.Text = "HP: " .. math.floor(hp) .. " / " .. math.floor(maxHp)
    local percent = hp / maxHp
    if percent > 0.7 then
        hpLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        hpLabel.BackgroundColor3 = Color3.fromRGB(25, 45, 25)
    elseif percent > 0.4 then
        hpLabel.TextColor3 = Color3.fromRGB(255, 200, 60)
        hpLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 25)
    else
        hpLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        hpLabel.BackgroundColor3 = Color3.fromRGB(45, 25, 25)
    end
end

local function getAllFoodInInventory()
    local foods = {}
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local char = LocalPlayer.Character
    local function checkItem(item)
        if item:IsA("Tool") then
            local isF, hp = isFood(item.Name)
            if isF then
                table.insert(foods, {item = item, name = item.Name, hp = hp})
            end
        end
    end
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do checkItem(item) end
    end
    if char then
        for _, item in pairs(char:GetChildren()) do checkItem(item) end
    end
    return foods
end

local function getFoodCount()
    return #getAllFoodInInventory()
end

local function updateFoodLabel()
    foodLabel.Text = "Еда: " .. getFoodCount()
end

cellsInput.FocusLost:Connect(function()
    local num = tonumber(cellsInput.Text)
    if num and num >= 2 then
        config.fullInventoryThreshold = math.floor(num)
        cellsInput.Text = tostring(config.fullInventoryThreshold)
        updateStatus()
    else
        config.fullInventoryThreshold = 2
        cellsInput.Text = "2"
        updateStatus()
    end
end)

-- ========== ЗАЩИТА ОТ ПАДЕНИЯ ==========
local function disableFallingState(char)
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        pcall(function()
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        end)
    end
end

if LocalPlayer.Character then
    task.spawn(disableFallingState, LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    disableFallingState(char)
end)

-- ========== ТЕЛЕПОРТЫ ==========
local function teleportToBase(hrp, baseCFrame)
    if not hrp or not baseCFrame then return false end
    local ok, pos = pcall(function() return baseCFrame.Position end)
    if not ok or not pos then return false end
    if pos.X ~= pos.X or pos.Y ~= pos.Y or pos.Z ~= pos.Z then return false end
    
    local targetPos = pos + Vector3.new(0, 3, 0)
    local newCFrame = CFrame.new(targetPos, targetPos + baseCFrame.LookVector)
    pcall(function() hrp.CFrame = newCFrame end)
    pcall(function()
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end)
    return true
end

local function teleportToPart(hrp, targetPart)
    if not hrp then return false, "no hrp" end
    if not targetPart then return false, "no part" end
    local ok, parent = pcall(function() return targetPart.Parent end)
    if not ok or not parent then return false, "part removed" end
    local ok2, pos = pcall(function() return targetPart.Position end)
    if not ok2 or not pos then return false, "no position" end
    if pos.X ~= pos.X or pos.Y ~= pos.Y or pos.Z ~= pos.Z then return false, "NaN" end
    if pos.Y < config.minTeleportY then return false, "too low" end
    if pos.Y > config.maxTeleportY then return false, "too high" end
    
    local targetPos = pos + Vector3.new(0, config.teleportHeight, 0)
    local newCFrame = CFrame.new(targetPos)
    pcall(function() hrp.CFrame = newCFrame end)
    pcall(function()
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end)
    return true, "ok"
end

-- ========== ЛОГ ==========
local logCounter = 0
local logColors = {
    info = Color3.fromRGB(180, 180, 220),
    success = Color3.fromRGB(0, 255, 100),
    warn = Color3.fromRGB(255, 200, 60),
    error = Color3.fromRGB(255, 80, 80),
    shard = Color3.fromRGB(150, 200, 255),
    base = Color3.fromRGB(200, 150, 255),
    hp = Color3.fromRGB(255, 100, 100),
    food = Color3.fromRGB(255, 200, 100),
}

local function addLog(msg, logType)
    logCounter = logCounter + 1
    logType = logType or "info"
    local line = Instance.new("TextLabel")
    line.Name = "Log_" .. logCounter
    line.Size = UDim2.new(1, 0, 0, 14)
    line.BackgroundTransparency = 1
    line.Text = "[" .. os.date("%H:%M:%S") .. "] " .. msg
    line.Font = Enum.Font.Code
    line.TextSize = 10
    line.TextColor3 = logColors[logType] or logColors.info
    line.TextXAlignment = Enum.TextXAlignment.Left
    line.LayoutOrder = logCounter
    line.Parent = logFrame
    
    local lines = {}
    for _, child in pairs(logFrame:GetChildren()) do
        if child:IsA("TextLabel") and child.Name:find("Log_") then
            table.insert(lines, child)
        end
    end
    if #lines > config.maxLogLines then
        table.sort(lines, function(a, b) return a.LayoutOrder < b.LayoutOrder end)
        for i = 1, #lines - config.maxLogLines do lines[i]:Destroy() end
    end
    task.wait()
    logFrame.CanvasPosition = Vector2.new(0, logFrame.AbsoluteCanvasSize.Y)
end

local function log(msg, logType)
    addLog(msg, logType)
    print("[Fatal Farm] " .. msg)
end

local function clearLog()
    for _, child in pairs(logFrame:GetChildren()) do
        if child:IsA("TextLabel") and child.Name:find("Log_") then child:Destroy() end
    end
    logCounter = 0
end

local function findProximityPrompt(parent)
    return parent:FindFirstChildWhichIsA("ProximityPrompt", true)
end

local function activatePrompt(prompt)
    if not prompt then return false end
    if fireproximityprompt then
        pcall(function() fireproximityprompt(prompt) end)
    end
    pcall(function()
        prompt.MaxActivationDistance = 500
        prompt.RequiresLineOfSight = false
        prompt.HoldDuration = 0
        prompt:InputHoldBegin()
        task.wait(0.05)
        prompt:InputHoldEnd()
    end)
    return true
end

local function isIgnoredByName(name)
    local n = name:lower()
    for _, word in ipairs(config.ignoreNames) do
        if n:find(word) then return true end
    end
    return false
end

local function isItemInInventory(item)
    if not item or not item.Parent then return false end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local char = LocalPlayer.Character
    return (backpack and item.Parent == backpack) 
        or (char and item.Parent == char)
end

local function checkObject(obj, myPos, closest, minDist)
    if not obj then return closest, minDist end
    if isIgnored(obj) or isCollected(obj) then return closest, minDist end
    if isIgnoredByName(obj.Name) then return closest, minDist end
    if isEggName(obj.Name) then return closest, minDist end
    if not obj.Parent then return closest, minDist end
    
    local prompt = findProximityPrompt(obj)
    if not prompt then return closest, minDist end
    local part = obj:FindFirstChildWhichIsA("BasePart") or (obj:IsA("BasePart") and obj)
    if not part or not part.Parent then return closest, minDist end
    if part.Position.Y < config.minTeleportY then return closest, minDist end
    if part.Position.Y > config.maxTeleportY then return closest, minDist end
    
    local dist = (part.Position - myPos).Magnitude
    if dist < minDist then
        minDist = dist
        closest = {part = part, prompt = prompt, name = obj.Name, model = obj}
    end
    return closest, minDist
end

local function findNearestTarget()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local scanFolder = workspace:FindFirstChild(config.scanFolder)
    if not scanFolder then return nil end
    local myPos = char.HumanoidRootPart.Position
    local closest, minDist = nil, config.maxSearchDistance
    for _, folderName in ipairs(config.searchFolders) do
        local folder = scanFolder:FindFirstChild(folderName)
        if folder then
            for _, obj in pairs(folder:GetDescendants()) do
                if not isCurrencyName(obj.Name) then
                    closest, minDist = checkObject(obj, myPos, closest, minDist)
                end
            end
        end
    end
    return closest
end

local function findNearestFood()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local scanFolder = workspace:FindFirstChild(config.scanFolder)
    if not scanFolder then return nil end
    local myPos = char.HumanoidRootPart.Position
    local closest, minDist = nil, config.maxSearchDistance
    for _, folderName in ipairs(config.searchFolders) do
        local folder = scanFolder:FindFirstChild(folderName)
        if folder then
            for _, obj in pairs(folder:GetDescendants()) do
                local isF = isFood(obj.Name)
                if isF and not isIgnored(obj) and not isCollected(obj) then
                    closest, minDist = checkObject(obj, myPos, closest, minDist)
                end
            end
        end
    end
    return closest
end

local function findNearestShard()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = char.HumanoidRootPart.Position
    local closest, minDist = nil, config.maxSearchDistance
    for _, obj in pairs(workspace:GetDescendants()) do
        if isCurrencyName(obj.Name) then
            if obj.Parent ~= workspace then
                closest, minDist = checkObject(obj, myPos, closest, minDist)
            end
        end
    end
    return closest
end

local function resetCollectedKeys()
    collectedKeys = {}
    log("Сброс собранного", "warn")
end

-- ✅ ТЕПЕРЬ ЕДА ТОЖЕ ВЫКИДЫВАЕТСЯ
local function dropAllItems()
    local char = LocalPlayer.Character
    if not char then return 0 end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return 0 end
    local items = getAllItems()
    if #items == 0 then return 0 end
    local dropped = 0
    for _, item in pairs(items) do
        -- ✅ НЕТ исключения для еды — всё выкидываем!
        local itemName = item.Name
        local success = false
        for attempt = 1, config.maxDropAttempts do
            if not isItemInInventory(item) then success = true break end
            pcall(function() humanoid:EquipTool(item) end)
            task.wait(config.equipDelay)
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
                task.wait(0.08)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
            end)
            task.wait(config.dropKeyDelay)
            if not isItemInInventory(item) then success = true break end
        end
        if success then
            addIgnored(item)
            dropped = dropped + 1
        else
            log("Не удалось выбросить: " .. itemName, "error")
        end
        task.wait(0.15)
    end
    if dropped > 0 then log("Выброшено: " .. dropped, "success") end
    updateStatus()
    return dropped
end

-- ✅ Едим из рюкзака ПЕРЕД выбросом (пока еда есть)
local function eatBeforeDrop()
    local hp, maxHp = getCurrentHp()
    if hp >= config.targetHp then return false end
    
    local foods = getAllFoodInInventory()
    if #foods == 0 then return false end
    
    log("HP: " .. math.floor(hp) .. " — ем перед выбросом", "food")
    
    local attempts = 0
    while hp < config.targetHp and attempts < config.maxEatAttempts do
        local foodsNow = getAllFoodInInventory()
        if #foodsNow == 0 then break end
        
        table.sort(foodsNow, function(a, b) return a.hp > b.hp end)
        local best = foodsNow[1]
        
        local char = LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if not humanoid then break end
        
        pcall(function() humanoid:EquipTool(best.item) end)
        task.wait(0.3)
        
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, config.eatKey, false, game)
            task.wait(0.08)
            VirtualInputManager:SendKeyEvent(false, config.eatKey, false, game)
        end)
        task.wait(config.eatDelay)
        
        local newHp = getCurrentHp()
        if newHp <= hp then
            -- еда не сработала — прекращаем
            break
        end
        hp = newHp
        log("Съел: " .. best.name .. " (+" .. best.hp .. " HP) → " .. math.floor(hp), "food")
        attempts = attempts + 1
    end
    
    return true
end

-- ========== ОСНОВНОЙ ЦИКЛ ==========
local isRunning = false
local basePosition = nil
local lastHp = 100
local lastHpTime = tick()
local hpEmergency = false

local function checkHpEmergency()
    local hp, maxHp = getCurrentHp()
    local now = tick()
    local timeDiff = now - lastHpTime
    
    if hp < config.lowHpThreshold and not hpEmergency then
        hpEmergency = true
        log("HP < " .. config.lowHpThreshold .. " (" .. math.floor(hp) .. ") → база!", "hp")
    end
    
    if timeDiff >= config.hpDropInterval then
        local drop = lastHp - hp
        if drop >= config.hpDropThreshold and not hpEmergency then
            hpEmergency = true
            log("HP упал: -" .. math.floor(drop) .. " → база!", "hp")
        end
        lastHp = hp
        lastHpTime = now
    end
end

local function startFarming()
    isRunning = true
    toggleBtn.Text = "STOP"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    clearLog()
    log("=== Запуск FARM v60 ===", "success")
    
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        basePosition = char.HumanoidRootPart.CFrame
        disableFallingState(char)
        log("База сохранена", "base")
        
        local hp, _ = getCurrentHp()
        lastHp = hp
        lastHpTime = tick()
    end
    
    local scanFolder = workspace:FindFirstChild(config.scanFolder)
    if scanFolder then
        for _, folderName in ipairs(config.searchFolders) do
            local folder = scanFolder:FindFirstChild(folderName)
            if folder then log("[OK] " .. folderName, "success")
            else log("[NO] " .. folderName, "warn") end
        end
    end
    
    local emptyCycles = 0
    
    task.spawn(function()
        while isRunning do
            checkHpEmergency()
            updateHpLabel()
            updateFoodLabel()
            task.wait(config.hpCheckInterval)
        end
    end)
    
    task.spawn(function()
        while isRunning do
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then
                task.wait(0.5)
                continue
            end
            local hrp = char.HumanoidRootPart
            local invCount = getInventoryCount()
            updateStatus()
            updateFoodLabel()
            
            -- Экстренный телепорт
            if hpEmergency then
                hpEmergency = false
                log("ЭКСТРЕННЫЙ ТЕЛЕПОРТ НА БАЗУ!", "hp")
                if basePosition then
                    teleportToBase(hrp, basePosition)
                    task.wait(config.baseReturnDelay)
                    
                    -- ✅ Сначала ЕДИМ (пока еда есть)
                    eatBeforeDrop()
                    task.wait(0.3)
                    
                    -- ✅ Потом ВЫБРАСЫВАЕМ ВСЁ (включая еду)
                    dropAllItems()
                    task.wait(config.dropDelay)
                end
                task.wait(0.5)
                continue
            end
            
            if invCount >= config.fullInventoryThreshold then
                log("Рюкзак полон (" .. invCount .. "). На базу...", "warn")
                if basePosition then
                    teleportToBase(hrp, basePosition)
                    task.wait(config.baseReturnDelay)
                    
                    -- ✅ Сначала ЕДИМ
                    eatBeforeDrop()
                    task.wait(0.3)
                    
                    -- ✅ Потом ВЫБРАСЫВАЕМ
                    dropAllItems()
                    task.wait(config.dropDelay)
                end
                emptyCycles = 0
                task.wait(0.5)
                continue
            end
            
            -- Если еды < 1 и HP не полный — идём за едой
            local hp, maxHp = getCurrentHp()
            local foodCount = getFoodCount()
            if foodCount < 1 and hp < maxHp then
                local foodTarget = findNearestFood()
                if foodTarget then
                    local ok = teleportToPart(hrp, foodTarget.part)
                    if ok then
                        task.wait(config.teleportDelay)
                        markCollected(foodTarget.model)
                        activatePrompt(foodTarget.prompt)
                        task.wait(config.collectDelay)
                        log("Взял еду: " .. foodTarget.name, "food")
                        task.wait(config.collectDelay)
                        continue
                    end
                end
            end
            
            -- Обычный сбор
            local target = findNearestShard()
            local isShard = false
            if target then isShard = true
            else target = findNearestTarget() end
            
            if target then
                local ok, reason = teleportToPart(hrp, target.part)
                if ok then
                    emptyCycles = 0
                    task.wait(config.teleportDelay)
                    markCollected(target.model)
                    activatePrompt(target.prompt)
                    task.wait(config.collectDelay)
                    
                    local newCount = getInventoryCount()
                    if newCount > invCount then
                        if isShard then log("Shard: " .. target.name, "shard")
                        else log("Взял: " .. target.name, "success") end
                    else
                        log("Не взял: " .. target.name, "warn")
                    end
                    task.wait(config.collectDelay)
                else
                    log("Пропуск: " .. target.name, "warn")
                    task.wait(0.3)
                end
            else
                emptyCycles = emptyCycles + 1
                if emptyCycles >= config.emptyCyclesBeforeBase then
                    log("Много пустых → на базу", "warn")
                    if basePosition then
                        teleportToBase(hrp, basePosition)
                        task.wait(config.baseReturnDelay)
                        eatBeforeDrop()
                        task.wait(0.3)
                        dropAllItems()
                        task.wait(config.dropDelay)
                    end
                    resetCollectedKeys()
                    emptyCycles = 0
                end
                task.wait(1.0)
            end
            task.wait(0.3)
        end
    end)
end

local function stopFarming()
    isRunning = false
    toggleBtn.Text = "START"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 60)
    log("=== Остановлено ===", "warn")
end

toggleBtn.MouseButton1Click:Connect(function()
    if not isRunning then startFarming() else stopFarming() end
end)

local isMinimized = false
minBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        toggleBtn.Visible = false
        statusLabel.Visible = false
        hpLabel.Visible = false
        foodLabel.Visible = false
        cellsLabel.Visible = false
        cellsInput.Visible = false
        logFrame.Visible = false
        minBtn.Text = "+"
        main.Size = UDim2.new(0, 290, 0, 30)
    else
        main.Size = UDim2.new(0, 290, 0, 410)
        task.wait(0.05)
        toggleBtn.Visible = true
        statusLabel.Visible = true
        hpLabel.Visible = true
        foodLabel.Visible = true
        cellsLabel.Visible = true
        cellsInput.Visible = true
        logFrame.Visible = true
        minBtn.Text = "-"
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    stopFarming()
    screenGui:Destroy()
end)

addLog("v60 готов. Еда тоже выкидывается", "success")
