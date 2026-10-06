--[[
	🌐 TELEPORT MENU — DEBUG VERSION
	Copy рядом с твоим Job ID (в инфо-блоке)
]]

if game:GetService("CoreGui"):FindFirstChild("TeleportUI") then
	game:GetService("CoreGui"):FindFirstChild("TeleportUI"):Destroy()
end

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

print("=== TELEPORT MENU START ===")
print("Place ID:", game.PlaceId)
print("Job ID:", game.JobId)
print("Игра:", game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)

local Lang = "RU"

local T = {
	RU = {
		title = "🌐 ТЕЛЕПОРТ",
		jobLabel = "JOB ID СЕРВЕРА",
		jobPlaceholder = "Введи Job ID",
		connectBtn = "🚀 ПОДКЛЮЧИТЬСЯ",
		loadingBtn = "⏳ ЗАГРУЗКА...",
		copyBtn = "📋 Copy",
		copiedBtn = "✓ Copied!",
		ready = "Готово ✓",
		enterId = "Введи Job ID!",
		badFormat = "Неверный формат!",
		sameServer = "Ты уже тут!",
		connecting = "Подключение...",
		error = "Ошибка: ",
		noClipboard = "❌ Нет доступа к буферу",
	},
	EN = {
		title = "🌐 TELEPORT",
		jobLabel = "SERVER JOB ID",
		jobPlaceholder = "Enter Job ID",
		connectBtn = "🚀 CONNECT",
		loadingBtn = "⏳ LOADING...",
		copyBtn = "📋 Copy",
		copiedBtn = "✓ Copied!",
		ready = "Ready ✓",
		enterId = "Enter Job ID!",
		badFormat = "Invalid format!",
		sameServer = "Already here!",
		connecting = "Connecting...",
		error = "Error: ",
		noClipboard = "❌ No clipboard access",
	},
}

local function L(key) return T[Lang][key] end

-- ============ GUI ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
if gethui then
	ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
	syn.protect_gui(ScreenGui)
	ScreenGui.Parent = game:GetService("CoreGui")
else
	ScreenGui.Parent = game:GetService("CoreGui")
end

local C = {
	Bg = Color3.fromRGB(18, 18, 22),
	Sec = Color3.fromRGB(28, 28, 36),
	Acc = Color3.fromRGB(0, 170, 255),
	AccH = Color3.fromRGB(40, 200, 255),
	Txt = Color3.fromRGB(240, 240, 245),
	Dim = Color3.fromRGB(140, 140, 155),
	Str = Color3.fromRGB(48, 48, 58),
	Ok = Color3.fromRGB(80, 220, 120),
	Err = Color3.fromRGB(240, 80, 90),
	Btn = Color3.fromRGB(38, 38, 48),
	BtnH = Color3.fromRGB(55, 55, 70),
	Warn = Color3.fromRGB(255, 180, 60),
}

local function corner(p, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 8)
	c.Parent = p
end

local function stroke(p)
	local s = Instance.new("UIStroke")
	s.Color = C.Str
	s.Thickness = 1
	s.Parent = p
end

-- ============ ОКНО ============
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 400, 0, 330)
Main.Position = UDim2.new(0.5, -200, 0.5, -165)
Main.BackgroundColor3 = C.Bg
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
corner(Main, 14)
stroke(Main)

local H = Instance.new("Frame")
H.Size = UDim2.new(1, 0, 0, 45)
H.BackgroundColor3 = C.Sec
H.BorderSizePixel = 0
H.Parent = Main
corner(H, 14)

local HFix = Instance.new("Frame")
HFix.Size = UDim2.new(1, 0, 0, 14)
HFix.Position = UDim2.new(0, 0, 1, -14)
HFix.BackgroundColor3 = C.Sec
HFix.BorderSizePixel = 0
HFix.Parent = H

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -170, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = L("title")
Title.TextColor3 = C.Txt
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = H

local RuBtn = Instance.new("TextButton")
RuBtn.Size = UDim2.new(0, 30, 0, 26)
RuBtn.Position = UDim2.new(1, -138, 0.5, -13)
RuBtn.BackgroundColor3 = C.Acc
RuBtn.Text = "RU"
RuBtn.TextColor3 = C.Txt
RuBtn.Font = Enum.Font.GothamBold
RuBtn.TextSize = 11
RuBtn.AutoButtonColor = false
RuBtn.Parent = H
corner(RuBtn, 6)

local EnBtn = Instance.new("TextButton")
EnBtn.Size = UDim2.new(0, 30, 0, 26)
EnBtn.Position = UDim2.new(1, -104, 0.5, -13)
EnBtn.BackgroundColor3 = C.Btn
EnBtn.Text = "EN"
EnBtn.TextColor3 = C.Txt
EnBtn.Font = Enum.Font.GothamBold
EnBtn.TextSize = 11
EnBtn.AutoButtonColor = false
EnBtn.Parent = H
corner(EnBtn, 6)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 26, 0, 26)
MinBtn.Position = UDim2.new(1, -70, 0.5, -13)
MinBtn.BackgroundColor3 = C.Btn
MinBtn.Text = "—"
MinBtn.TextColor3 = C.Txt
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14
MinBtn.AutoButtonColor = false
MinBtn.Parent = H
corner(MinBtn, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -13)
CloseBtn.BackgroundColor3 = C.Btn
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = C.Txt
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = H
corner(CloseBtn, 6)

-- Мини-иконка
local MiniIcon = Instance.new("TextButton")
MiniIcon.Size = UDim2.new(0, 50, 0, 50)
MiniIcon.Position = UDim2.new(0, 20, 0.5, -25)
MiniIcon.BackgroundColor3 = C.Acc
MiniIcon.Text = "🌐"
MiniIcon.TextColor3 = C.Txt
MiniIcon.Font = Enum.Font.GothamBold
MiniIcon.TextSize = 22
MiniIcon.AutoButtonColor = false
MiniIcon.Visible = false
MiniIcon.Active = true
MiniIcon.Draggable = true
MiniIcon.Parent = ScreenGui
corner(MiniIcon, 25)
stroke(MiniIcon)

-- Контент
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -45)
Content.Position = UDim2.new(0, 0, 0, 45)
Content.BackgroundTransparency = 1
Content.Parent = Main

local InputLabel = Instance.new("TextLabel")
InputLabel.Size = UDim2.new(1, -40, 0, 16)
InputLabel.Position = UDim2.new(0, 20, 0, 14)
InputLabel.BackgroundTransparency = 1
InputLabel.Text = L("jobLabel")
InputLabel.TextColor3 = C.Dim
InputLabel.Font = Enum.Font.GothamBold
InputLabel.TextSize = 10
InputLabel.TextXAlignment = Enum.TextXAlignment.Left
InputLabel.Parent = Content

-- Поле ввода (без Copy)
local InputFrame = Instance.new("Frame")
InputFrame.Size = UDim2.new(1, -40, 0, 44)
InputFrame.Position = UDim2.new(0, 20, 0, 34)
InputFrame.BackgroundColor3 = C.Sec
InputFrame.BorderSizePixel = 0
InputFrame.Parent = Content
corner(InputFrame, 10)
stroke(InputFrame)

local Input = Instance.new("TextBox")
Input.Size = UDim2.new(1, -20, 1, 0)
Input.Position = UDim2.new(0, 10, 0, 0)
Input.BackgroundTransparency = 1
Input.PlaceholderText = L("jobPlaceholder")
Input.PlaceholderColor3 = C.Dim
Input.Text = ""
Input.TextColor3 = C.Txt
Input.Font = Enum.Font.Code
Input.TextSize = 13
Input.TextXAlignment = Enum.TextXAlignment.Left
Input.ClearTextOnFocus = false
Input.Parent = InputFrame

-- Кнопка подключения
local ConnectBtn = Instance.new("TextButton")
ConnectBtn.Size = UDim2.new(1, -40, 0, 50)
ConnectBtn.Position = UDim2.new(0, 20, 0, 90)
ConnectBtn.BackgroundColor3 = C.Acc
ConnectBtn.Text = L("connectBtn")
ConnectBtn.TextColor3 = C.Txt
ConnectBtn.Font = Enum.Font.GothamBold
ConnectBtn.TextSize = 14
ConnectBtn.AutoButtonColor = false
ConnectBtn.Parent = Content
corner(ConnectBtn, 10)

ConnectBtn.MouseEnter:Connect(function()
	TweenService:Create(ConnectBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.AccH}):Play()
end)
ConnectBtn.MouseLeave:Connect(function()
	TweenService:Create(ConnectBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.Acc}):Play()
end)

-- ============ ИНФО-БЛОК С JOB ID + COPY ============
local InfoFrame = Instance.new("Frame")
InfoFrame.Size = UDim2.new(1, -40, 0, 80)
InfoFrame.Position = UDim2.new(0, 20, 0, 148)
InfoFrame.BackgroundColor3 = C.Sec
InfoFrame.BorderSizePixel = 0
InfoFrame.Parent = Content
corner(InfoFrame, 8)
stroke(InfoFrame)

-- Place ID (строка 1)
local PlaceIdLabel = Instance.new("TextLabel")
PlaceIdLabel.Size = UDim2.new(1, -20, 0, 20)
PlaceIdLabel.Position = UDim2.new(0, 10, 0, 6)
PlaceIdLabel.BackgroundTransparency = 1
PlaceIdLabel.Text = "Place ID: " .. tostring(game.PlaceId)
PlaceIdLabel.TextColor3 = C.Dim
PlaceIdLabel.Font = Enum.Font.Code
PlaceIdLabel.TextSize = 10
PlaceIdLabel.TextXAlignment = Enum.TextXAlignment.Left
PlaceIdLabel.Parent = InfoFrame

-- Job ID (строка 2) — слева текст, справа кнопка Copy
local JobIdLabel = Instance.new("TextLabel")
JobIdLabel.Size = UDim2.new(1, -100, 0, 20)
JobIdLabel.Position = UDim2.new(0, 10, 0, 26)
JobIdLabel.BackgroundTransparency = 1
JobIdLabel.Text = "Job ID: " .. game.JobId
JobIdLabel.TextColor3 = C.Dim
JobIdLabel.Font = Enum.Font.Code
JobIdLabel.TextSize = 10
JobIdLabel.TextXAlignment = Enum.TextXAlignment.Left
JobIdLabel.TextTruncate = Enum.TextTruncate.AtEnd
JobIdLabel.Parent = InfoFrame

-- ✅ КНОПКА COPY РЯДОМ С JOB ID
local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0, 76, 0, 22)
CopyBtn.Position = UDim2.new(1, -84, 0, 25)
CopyBtn.BackgroundColor3 = C.Acc
CopyBtn.Text = L("copyBtn")
CopyBtn.TextColor3 = C.Txt
CopyBtn.Font = Enum.Font.GothamBold
CopyBtn.TextSize = 10
CopyBtn.AutoButtonColor = false
CopyBtn.Parent = InfoFrame
corner(CopyBtn, 6)

CopyBtn.MouseEnter:Connect(function()
	if CopyBtn.Text ~= L("copiedBtn") then
		TweenService:Create(CopyBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.AccH}):Play()
	end
end)
CopyBtn.MouseLeave:Connect(function()
	if CopyBtn.Text ~= L("copiedBtn") then
		TweenService:Create(CopyBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.Acc}):Play()
	end
end)

-- Игра (строка 3)
local GameLabel = Instance.new("TextLabel")
GameLabel.Size = UDim2.new(1, -20, 0, 20)
GameLabel.Position = UDim2.new(0, 10, 0, 50)
GameLabel.BackgroundTransparency = 1
GameLabel.Text = "Игра: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
GameLabel.TextColor3 = C.Dim
GameLabel.Font = Enum.Font.Code
GameLabel.TextSize = 10
GameLabel.TextXAlignment = Enum.TextXAlignment.Left
GameLabel.TextTruncate = Enum.TextTruncate.AtEnd
GameLabel.Parent = InfoFrame

-- Статус
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -40, 0, 24)
Status.Position = UDim2.new(0, 20, 1, -32)
Status.BackgroundTransparency = 1
Status.Text = L("ready")
Status.TextColor3 = C.Ok
Status.Font = Enum.Font.Gotham
Status.TextSize = 11
Status.Parent = Content

local function setStatus(t, color)
	Status.Text = t
	Status.TextColor3 = color or C.Ok
	print("[STATUS]", t)
end

-- Язык
local function applyLanguage()
	Title.Text = L("title")
	InputLabel.Text = L("jobLabel")
	Input.PlaceholderText = L("jobPlaceholder")
	ConnectBtn.Text = L("connectBtn")
	if CopyBtn.Text ~= L("copiedBtn") then
		CopyBtn.Text = L("copyBtn")
	end
end

RuBtn.MouseButton1Click:Connect(function()
	Lang = "RU"
	RuBtn.BackgroundColor3 = C.Acc
	EnBtn.BackgroundColor3 = C.Btn
	applyLanguage()
end)

EnBtn.MouseButton1Click:Connect(function()
	Lang = "EN"
	RuBtn.BackgroundColor3 = C.Btn
	EnBtn.BackgroundColor3 = C.Acc
	applyLanguage()
end)

-- Свернуть
local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
	if isMinimized then return end
	isMinimized = true
	Main.Visible = false
	MiniIcon.Visible = true
end)

MiniIcon.MouseButton1Click:Connect(function()
	if not isMinimized then return end
	isMinimized = false
	MiniIcon.Visible = false
	Main.Visible = true
end)

CloseBtn.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

-- ============ КОПИРОВАНИЕ JOB ID ============
local function copyToClipboard(text)
	if setclipboard then
		local ok = pcall(setclipboard, text)
		if ok then return true end
	end
	if toclipboard then
		local ok = pcall(toclipboard, text)
		if ok then return true end
	end
	if syn and syn.setclipboard then
		local ok = pcall(syn.setclipboard, text)
		if ok then return true end
	end
	return false
end

CopyBtn.MouseButton1Click:Connect(function()
	print("=== КОПИРОВАНИЕ JOB ID ===")
	
	local myJobId = game.JobId
	print("Текущий Job ID:", myJobId)
	
	if not myJobId or myJobId == "" then
		setStatus("❌ Job ID недоступен", C.Err)
		return
	end
	
	local success = copyToClipboard(myJobId)
	
	if success then
		print("✅ Скопировано в буфер")
		
		CopyBtn.Text = L("copiedBtn")
		CopyBtn.BackgroundColor3 = C.Ok
		
		setStatus("✓ ID скопирован!", C.Ok)
		
		task.wait(1.5)
		
		CopyBtn.Text = L("copyBtn")
		CopyBtn.BackgroundColor3 = C.Acc
	else
		print("❌ Не удалось скопировать")
		setStatus(L("noClipboard"), C.Err)
	end
end)

-- ============ ПРОВЕРКА ФОРМАТА ============
local function validateJobId(id)
	if not id or id == "" then return false end
	local pattern = "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$"
	return id:match(pattern) ~= nil
end

-- ============ ПОДКЛЮЧЕНИЕ ============
ConnectBtn.MouseButton1Click:Connect(function()
	print("=== НАЖАТА КНОПКА ПОДКЛЮЧЕНИЯ ===")
	
	local jobId = Input.Text:gsub("%s+", "")
	print("Введено:", jobId)
	
	if jobId == "" then
		setStatus(L("enterId"), C.Err)
		return
	end
	
	print("Проверка формата...")
	if not validateJobId(jobId) then
		print("❌ ФОРМАТ НЕВЕРНЫЙ")
		setStatus(L("badFormat"), C.Err)
		return
	end
	print("✅ Формат правильный")
	
	if jobId == game.JobId then
		setStatus(L("sameServer"), C.Warn)
		return
	end
	
	setStatus(L("connecting"), C.Warn)
	ConnectBtn.Text = L("loadingBtn")
	
	print("Телепорт в Place:", game.PlaceId, "Job:", jobId)
	
	local ok, err = pcall(function()
		TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, LocalPlayer)
	end)
	
	if not ok then
		print("❌ ОШИБКА ТЕЛЕПОРТА:", err)
		setStatus(L("error") .. tostring(err), C.Err)
		ConnectBtn.Text = L("connectBtn")
	else
		print("✅ Телепорт запущен успешно")
	end
end)

-- Enter
Input.FocusLost:Connect(function(enter)
	if enter and Input.Text ~= "" then
		ConnectBtn.MouseButton1Click:Fire()
	end
end)

-- RightShift
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		if isMinimized then
			MiniIcon.Visible = false
			Main.Visible = true
			isMinimized = false
		else
			Main.Visible = not Main.Visible
		end
	end
end)

-- Анимация появления
Main.Size = UDim2.new(0, 0, 0, 0)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
TweenService:Create(Main, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
	Size = UDim2.new(0, 400, 0, 330),
	Position = UDim2.new(0.5, -200, 0.5, -165)
}):Play()

setStatus(L("ready"), C.Ok)
print("=== МЕНЮ ЗАГРУЖЕНО ===")
