--===================================================================================--
--                             THEPAIN2012 🌿 PREMIUM FPS HUB                         --
--===================================================================================--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Tạo ScreenGui để dựng giao diện bo góc tùy biến theo yêu cầu
local CoreGui = game:GetService("CoreGui")
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "ThePain2012_FPSHub"
MainGui.Parent = CoreGui

-- Biến cấu hình trạng thái
local KeySystemActive = true
local PremiumUnlocked = false
local HitboxLocked = true  
local SpeedEnabled = false
local JumpEnabled = false
local NoclipEnabled = false
local InfJumpEnabled = false
local HitboxEnabled = false
local HitboxSize = 50
local ESPEnabled = false
local SpinAuraEnabled = false
local ThanhDieuCam = false
local AimMode = "aimBody"
local AimbotActive = false
local SuperWinEnabled = false
local GunRainbowEnabled = false
local GhostEnabled = false

-- Biến lưu trữ số lượng Player đã loại bỏ và mục tiêu khóa SuperWin cố định
local KillsCounter = 0
local CurrentSuperWinTarget = nil

-- Tạo nhãn hiển thị PlayerKiller ở trên cùng giữa màn hình
local PlayerKillerLabel = Instance.new("TextLabel")
PlayerKillerLabel.Size = UDim2.new(0, 300, 0, 40)
PlayerKillerLabel.Position = UDim2.new(0.5, -150, 0, 10)
PlayerKillerLabel.BackgroundTransparency = 1
PlayerKillerLabel.Text = "PlayerKiller: [" .. KillsCounter .. "]"
PlayerKillerLabel.TextColor3 = Color3.fromRGB(0, 191, 255)
PlayerKillerLabel.TextSize = 24
PlayerKillerLabel.Font = Enum.Font.SourceSansBold
PlayerKillerLabel.Parent = MainGui

local KillerStroke = Instance.new("UIStroke")
KillerStroke.Color = Color3.fromRGB(0, 0, 0)
KillerStroke.Thickness = 2
KillerStroke.Parent = PlayerKillerLabel

-- watermark góc phải
local Watermark = Instance.new("TextLabel")
Watermark.Size = UDim2.new(0, 200, 0, 30)
Watermark.Position = UDim2.new(1, -210, 0, 10)
Watermark.BackgroundTransparency = 1
Watermark.Text = "ThePain2012🌿"
Watermark.TextSize = 16
Watermark.Font = Enum.Font.SourceSansBold
Watermark.TextColor3 = Color3.fromRGB(255, 255, 255)
Watermark.Parent = MainGui

task.spawn(function()
    while task.wait(0.1) do
        for i = 0, 1, 0.05 do
            Watermark.TextColor3 = Color3.fromHSV(i, 1, 1)
            task.wait(0.05)
        end
    end
end)

-- Khung Menu Chính (Đã tăng chiều dọc từ 260 lên 340 để cân xứng giao diện diện rộng)
local MainWindow = Instance.new("Frame")
MainWindow.Size = UDim2.new(0, 680, 0, 340)
MainWindow.Position = UDim2.new(0.5, -340, 0.5, -170)
MainWindow.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainWindow.BorderSizePixel = 0
MainWindow.ClipsDescendants = false
MainWindow.Parent = MainGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainWindow

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(144, 238, 144)
MainStroke.Thickness = 2
MainStroke.Parent = MainWindow

-- Kéo thả Menu
local dragging, dragInput, dragStart, startPos
MainWindow.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainWindow.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
MainWindow.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- NÚT TOGGLE DI ĐỘNG CÓ ANIMATION MƯỢT
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Position = UDim2.new(0, 15, 0, 15)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ToggleBtn.Text = "🌿"
ToggleBtn.TextColor3 = Color3.fromRGB(144, 238, 144)
ToggleBtn.TextSize = 20
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.Parent = MainGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(144, 238, 144)
ToggleStroke.Thickness = 1.5
ToggleStroke.Parent = ToggleBtn

local tDragging, tDragInput, tDragStart, tStartPos
ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        tDragging = true
        tDragStart = input.Position
        tStartPos = ToggleBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then tDragging = false end
        end)
    end
end)
ToggleBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        tDragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == tDragInput and tDragging then
        local delta = input.Position - tDragStart
        ToggleBtn.Position = UDim2.new(tStartPos.X.Scale, tStartPos.X.Offset + delta.X, tStartPos.Y.Scale, tStartPos.Y.Offset + delta.Y)
    end
end)

local MenuVisible = true
local function ToggleMenuAnimation()
    MenuVisible = not MenuVisible
    local targetSize = MenuVisible and UDim2.new(0, 680, 0, 340) or UDim2.new(0, 680, 0, 0)
    
    if MenuVisible then 
        MainWindow.ClipsDescendants = true
        MainWindow.Visible = true
        Watermark.Visible = true
        PlayerKillerLabel.Visible = true
    else
        Watermark.Visible = false
        PlayerKillerLabel.Visible = false
    end
    
    local tween = TweenService:Create(MainWindow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize})
    tween:Play()
    
    tween.Completed:Connect(function()
        if not MenuVisible then 
            MainWindow.Visible = false 
        else
            MainWindow.ClipsDescendants = false
        end
    end)
end

ToggleBtn.MouseButton1Click:Connect(ToggleMenuAnimation)

local function CreateFloatingParticles(parent)
    for i = 1, 8 do
        local part = Instance.new("Frame")
        part.Size = UDim2.new(0, math.random(6, 12), 0, math.random(6, 12))
        part.BackgroundColor3 = Color3.fromRGB(144, 238, 144)
        part.BackgroundTransparency = 0.7
        part.BorderSizePixel = 0
        part.Parent = parent
        
        local pCorner = Instance.new("UICorner")
        pCorner.CornerRadius = UDim.new(0, math.random(0, 4))
        pCorner.Parent = part

        task.spawn(function()
            while task.wait() do
                if parent.Visible and parent.BackgroundTransparency < 1 then
                    part.Visible = true
                    part.Position = UDim2.new(math.random(0, 1), math.random(-10, 10), math.random(0, 1), math.random(-10, 10))
                    local tx = math.random(0, 100)/100
                    local ty = math.random(0, 100)/100
                    TweenService:Create(part, TweenInfo.new(5, Enum.EasingStyle.Linear), {Position = UDim2.new(tx, 0, ty, 0), Rotation = math.random(0, 360)}):Play()
                else
                    part.Visible = false
                end
                task.wait(5)
            end
        end)
    end
end
CreateFloatingParticles(MainWindow)

--===================================================================================--
--                                 GIAO DIỆN HỆ THỐNG KEY                            --
--===================================================================================--
local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.new(1, 0, 1, 0)
KeyFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
KeyFrame.Parent = MainWindow
KeyFrame.ZIndex = 10

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 12)
KeyCorner.Parent = KeyFrame

local HintLabel = Instance.new("TextLabel")
HintLabel.Size = UDim2.new(1, 0, 0, 30)
HintLabel.Position = UDim2.new(0, 0, 0.2, 0)
HintLabel.Text = "Gợi ý: 11 + 1 + 2000 = ?"
HintLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
HintLabel.TextSize = 16
HintLabel.Font = Enum.Font.SourceSans
HintLabel.BackgroundTransparency = 1
HintLabel.Parent = KeyFrame
HintLabel.ZIndex = 10

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(0, 200, 0, 35)
KeyInput.Position = UDim2.new(0.5, -100, 0.4, 0)
KeyInput.PlaceholderText = "Nhập Key tại đây..."
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
KeyInput.Parent = KeyFrame
KeyInput.ZIndex = 10

local CheckKeyBtn = Instance.new("TextButton")
CheckKeyBtn.Size = UDim2.new(0, 120, 0, 35)
CheckKeyBtn.Position = UDim2.new(0.5, -60, 0.65, 0)
CheckKeyBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
CheckKeyBtn.Text = "Check Key"
CheckKeyBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
CheckKeyBtn.Font = Enum.Font.SourceSansBold
CheckKeyBtn.TextSize = 15
CheckKeyBtn.Parent = KeyFrame
CheckKeyBtn.ZIndex = 10

local function StartLoading()
    HintLabel.Visible = false
    KeyInput.Visible = false
    CheckKeyBtn.Visible = false
    
    local LeafPattern = Instance.new("TextLabel")
    LeafPattern.Size = UDim2.new(1, 0, 0, 40)
    LeafPattern.Position = UDim2.new(0, 0, 0.3, 0)
    LeafPattern.Text = "🌿 AimFpsPremium 🌿"
    LeafPattern.TextColor3 = Color3.fromRGB(144, 238, 144)
    LeafPattern.TextSize = 22
    LeafPattern.Font = Enum.Font.SourceSansBold
    LeafPattern.BackgroundTransparency = 1
    LeafPattern.Parent = KeyFrame
    
    local LoadLabel = Instance.new("TextLabel")
    LoadLabel.Size = UDim2.new(1, 0, 0, 30)
    LoadLabel.Position = UDim2.new(0, 0, 0.55, 0)
    LoadLabel.Text = "0%"
    LoadLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoadLabel.TextSize = 18
    LoadLabel.BackgroundTransparency = 1
    LoadLabel.Parent = KeyFrame

    for i = 1, 100 do
        LoadLabel.Text = "Loading: " .. i .. "%"
        task.wait(6 / 100)
    end
    
    KeyFrame.Visible = false
    KeySystemActive = false
end

CheckKeyBtn.MouseButton1Click:Connect(function()
    if KeyInput.Text == "2012" then
        CheckKeyBtn.Text = "ĐÚNG"
        task.wait(0.5)
        StartLoading()
    else
        CheckKeyBtn.Text = "SAI! Thử lại"
        task.wait(1)
        CheckKeyBtn.Text = "Check Key"
    end
end)

--===================================================================================--
--                                     BẢNG TABS CHỨC NĂNG                           --
--===================================================================================--
local LeftTab = Instance.new("Frame")
LeftTab.Size = UDim2.new(0, 320, 1, -40)
LeftTab.Position = UDim2.new(0, 10, 0, 30)
LeftTab.BackgroundTransparency = 1
LeftTab.Parent = MainWindow

local Separator = Instance.new("Frame")
Separator.Size = UDim2.new(0, 2, 1, -40)
Separator.Position = UDim2.new(0.5, -1, 0, 30)
Separator.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Separator.BorderSizePixel = 0
Separator.Parent = MainWindow

local RightTab = Instance.new("Frame")
RightTab.Size = UDim2.new(0, 320, 1, -40)
RightTab.Position = UDim2.new(0.5, 10, 0, 30)
RightTab.BackgroundTransparency = 1
RightTab.Parent = MainWindow

local TitleL = Instance.new("TextLabel")
TitleL.Size = UDim2.new(1, 0, 0, 20)
TitleL.Text = "⚡ TỐI ƯU DI CHUYỂN"
TitleL.TextColor3 = Color3.fromRGB(144, 238, 144)
TitleL.TextSize = 13
TitleL.Font = Enum.Font.SourceSansBold
TitleL.TextXAlignment = Enum.TextXAlignment.Left
TitleL.BackgroundTransparency = 1
TitleL.Parent = LeftTab

local TitleR = Instance.new("TextLabel")
TitleR.Size = UDim2.new(1, 0, 0, 20)
TitleR.Text = "🎯 CHIẾN ĐẤU & HITBOX"
TitleR.TextColor3 = Color3.fromRGB(144, 238, 144)
TitleR.TextSize = 13
TitleR.Font = Enum.Font.SourceSansBold
TitleR.TextXAlignment = Enum.TextXAlignment.Left
TitleR.BackgroundTransparency = 1
TitleR.Parent = RightTab

local function CreateCheckBox(name, pos, parent, callback, customColor)
    local checkColor = customColor or Color3.fromRGB(0, 255, 0)
    local boxBtn = Instance.new("TextButton")
    boxBtn.Size = UDim2.new(0, 18, 0, 18)
    boxBtn.Position = pos
    boxBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    boxBtn.Text = ""
    boxBtn.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 250, 0, 18)
    label.Position = pos + UDim2.new(0, 25, 0, 0)
    label.Text = name
    label.TextColor3 = customColor or Color3.fromRGB(230, 230, 230)
    label.TextSize = 13
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = parent

    local active = false
    boxBtn.MouseButton1Click:Connect(function()
        active = not active
        boxBtn.BackgroundColor3 = active and checkColor or Color3.fromRGB(70, 70, 70)
        callback(active)
    end)
    return boxBtn, label
end

--===================================================================================--
--                               LOGIC CHỨC NĂNG LEFT TAB                            --
--===================================================================================--
CreateCheckBox("Boost Speed (Tốc độ 30)", UDim2.new(0, 5, 0, 30), LeftTab, function(val) SpeedEnabled = val end)
CreateCheckBox("Jump Boost (Nhảy cao 70)", UDim2.new(0, 5, 0, 55), LeftTab, function(val) JumpEnabled = val end)
CreateCheckBox("Bỏ qua vật cản (Đi xuyên vật thể)", UDim2.new(0, 5, 0, 80), LeftTab, function(val) NoclipEnabled = val end)
CreateCheckBox("Infinite Jump (Nhảy vô hạn)", UDim2.new(0, 5, 0, 105), LeftTab, function(val) InfJumpEnabled = val end)
CreateCheckBox("Spin 99 Aura (Xoay 120°)", UDim2.new(0, 5, 0, 130), LeftTab, function(val) SpinAuraEnabled = val end)

local HopServerBtn = Instance.new("TextButton")
HopServerBtn.Size = UDim2.new(0, 140, 0, 25)
HopServerBtn.Position = UDim2.new(0, 5, 0, 160)
HopServerBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
HopServerBtn.Text = "🔄 Hop Server"
HopServerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HopServerBtn.Font = Enum.Font.SourceSansBold
HopServerBtn.TextSize = 13
HopServerBtn.Parent = LeftTab

local HopCorner = Instance.new("UICorner")
HopCorner.CornerRadius = UDim.new(0, 6)
HopCorner.Parent = HopServerBtn

HopServerBtn.MouseButton1Click:Connect(function()
    HopServerBtn.Text = "Đang tìm Server..."
    pcall(function()
        local serverList = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        for _, server in pairs(serverList.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                break
            end
        end
    end)
    task.wait(2)
    HopServerBtn.Text = "Thử lại!"
    task.wait(1)
    HopServerBtn.Text = "🔄 Hop Server"
end)

RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        if SpeedEnabled then char.Humanoid.WalkSpeed = 30 end
        if JumpEnabled then char.Humanoid.JumpPower = 70 end
        if NoclipEnabled then
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
        if SpinAuraEnabled and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(120), 0)
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if InfJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

--===================================================================================--
--                               LOGIC CHỨC NĂNG RIGHT TAB                           --
--===================================================================================--
local HitboxLockBtn = Instance.new("TextButton")
HitboxLockBtn.Size = UDim2.new(0, 18, 0, 18)
HitboxLockBtn.Position = UDim2.new(0, 5, 0, 30)
HitboxLockBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
HitboxLockBtn.Text = "🔒"
HitboxLockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HitboxLockBtn.Parent = RightTab

local _, HitboxLabel = CreateCheckBox("Kích hoạt Hitbox Khối vuông", UDim2.new(0, 30, 0, 30), RightTab, function(val)
    if not HitboxLocked then HitboxEnabled = val end
end)
HitboxLabel.TextColor3 = Color3.fromRGB(100, 100, 100)

HitboxLockBtn.MouseButton1Click:Connect(function()
    if HitboxLocked then
        HitboxLocked = false
        HitboxLockBtn.Text = "🔓"
        HitboxLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    end
end)

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Size = UDim2.new(0, 200, 0, 15)
SliderLabel.Position = UDim2.new(0, 5, 0, 55)
SliderLabel.Text = "Độ rộng khối: 50 studs"
SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SliderLabel.TextSize = 12
SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
SliderLabel.BackgroundTransparency = 1
SliderLabel.Parent = RightTab

local SliderBar = Instance.new("TextButton")
SliderBar.Size = UDim2.new(0, 180, 0, 8)
SliderBar.Position = UDim2.new(0, 5, 0, 75)
SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SliderBar.Text = ""
SliderBar.Parent = RightTab

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.41, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderBar

local sliding = false
local function UpdateSlider(input)
    if HitboxLocked then return end
    local relativeX = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
    HitboxSize = math.floor(10 + (relativeX * 110))
    SliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
    SliderLabel.Text = "Độ rộng khối: " .. HitboxSize .. " studs"
end
SliderBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
        sliding = true 
        UpdateSlider(input) 
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then 
        UpdateSlider(input) 
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
        sliding = false 
    end
end)

CreateCheckBox("ESP Player (Dây xanh, Khung trắng, Tên hồng)", UDim2.new(0, 5, 0, 90), RightTab, function(val) ESPEnabled = val end)

--===================================================================================--
--                        MỤC PREMIUM & HỆ THỐNG KEY PREMIUM MÀU TÍM                  --
---===================================================================================--
--                        MỤC PREMIUM & HỆ THỐNG KEY PREMIUM MÀU TÍM                  --
--===================================================================================--
local PremiumTriggerBtn = Instance.new("TextButton")
PremiumTriggerBtn.Size = UDim2.new(0, 180, 0, 25)
PremiumTriggerBtn.Position = UDim2.new(0, 5, 0, 115)
PremiumTriggerBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
PremiumTriggerBtn.Text = "⭐ Chức năng Premium ⭐"
PremiumTriggerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PremiumTriggerBtn.Font = Enum.Font.SourceSansBold
PremiumTriggerBtn.TextSize = 13
PremiumTriggerBtn.Parent = RightTab

local PremCorner = Instance.new("UICorner")
PremCorner.CornerRadius = UDim.new(0, 6)
PremCorner.Parent = PremiumTriggerBtn

local PremiumKeyFrame = Instance.new("Frame")
PremiumKeyFrame.Size = UDim2.new(1, 0, 1, 0)
PremiumKeyFrame.BackgroundColor3 = Color3.fromRGB(15, 10, 20)
PremiumKeyFrame.BorderSizePixel = 0
PremiumKeyFrame.Visible = false
PremiumKeyFrame.ZIndex = 11
PremiumKeyFrame.Parent = MainWindow

local PremKeyCorner = Instance.new("UICorner")
PremKeyCorner.CornerRadius = UDim.new(0, 12)
PremKeyCorner.Parent = PremiumKeyFrame

local PremKeyStroke = Instance.new("UIStroke")
PremKeyStroke.Color = Color3.fromRGB(147, 112, 219)
PremKeyStroke.Thickness = 2
PremKeyStroke.Parent = PremiumKeyFrame

local PremHintLabel = Instance.new("TextLabel")
PremHintLabel.Size = UDim2.new(1, 0, 0, 30)
PremHintLabel.Position = UDim2.new(0, 0, 0.15, 0)
PremHintLabel.Text = "HỆ THỐNG XÁC THỰC KEY PREMIUM"
PremHintLabel.TextColor3 = Color3.fromRGB(186, 85, 211)
PremHintLabel.TextSize = 16
PremHintLabel.Font = Enum.Font.SourceSansBold
PremHintLabel.BackgroundTransparency = 1
PremHintLabel.ZIndex = 11
PremHintLabel.Parent = PremiumKeyFrame

local PremKeyInput = Instance.new("TextBox")
PremKeyInput.Size = UDim2.new(0, 220, 0, 35)
PremKeyInput.Position = UDim2.new(0.5, -110, 0.38, 0)
PremKeyInput.PlaceholderText = "Nhập Key Premium tại đây..."
PremKeyInput.Text = ""
PremKeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
PremKeyInput.BackgroundColor3 = Color3.fromRGB(35, 25, 45)
PremKeyInput.ZIndex = 11
PremKeyInput.Parent = PremiumKeyFrame

local CheckPremBtn = Instance.new("TextButton")
CheckPremBtn.Size = UDim2.new(0, 130, 0, 35)
CheckPremBtn.Position = UDim2.new(0.5, -65, 0.65, 0)
CheckPremBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
CheckPremBtn.Text = "Kích Hoạt Premium"
CheckPremBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CheckPremBtn.Font = Enum.Font.SourceSansBold
CheckPremBtn.TextSize = 14
CheckPremBtn.ZIndex = 11
CheckPremBtn.Parent = CheckPremBtn.Parent or PremiumKeyFrame

local CheckPremCorner = Instance.new("UICorner")
CheckPremCorner.CornerRadius = UDim.new(0, 6)
CheckPremCorner.Parent = CheckPremBtn

local ClosePremBtn = Instance.new("TextButton")
ClosePremBtn.Size = UDim2.new(0, 25, 0, 25)
ClosePremBtn.Position = UDim2.new(1, -30, 0, 5)
ClosePremBtn.BackgroundTransparency = 1
ClosePremBtn.Text = "✕"
ClosePremBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
ClosePremBtn.TextSize = 18
ClosePremBtn.Font = Enum.Font.SourceSansBold
ClosePremBtn.ZIndex = 11
ClosePremBtn.Parent = PremiumKeyFrame

PremiumTriggerBtn.MouseButton1Click:Connect(function()
    if not PremiumUnlocked then PremiumKeyFrame.Visible = true end
end)

ClosePremBtn.MouseButton1Click:Connect(function() PremiumKeyFrame.Visible = false end)

local PremiumFeaturesFrame = Instance.new("Frame")
PremiumFeaturesFrame.Size = UDim2.new(0, 320, 0, 160)
PremiumFeaturesFrame.Position = UDim2.new(0, 5, 0, 140)
PremiumFeaturesFrame.BackgroundTransparency = 1
PremiumFeaturesFrame.Visible = false
PremiumFeaturesFrame.Parent = RightTab

local purpleColor = Color3.fromRGB(186, 85, 211)
CreateCheckBox("AimBody (Khóa thân mục tiêu)", UDim2.new(0, 0, 0, 0), PremiumFeaturesFrame, function(val)
    AimbotActive = val
    if val then AimMode = "aimBody" end
end, purpleColor)

CreateCheckBox("AimHead (Khóa đầu mục tiêu)", UDim2.new(0, 0, 0, 22), PremiumFeaturesFrame, function(val)
    AimbotActive = val
    if val then AimMode = "aimHead" end
end, purpleColor)

CreateCheckBox("SuperWin (Auto khóa cố định sau lưng)", UDim2.new(0, 0, 0, 44), PremiumFeaturesFrame, function(val)
    SuperWinEnabled = val
    if not val then CurrentSuperWinTarget = nil end
end, purpleColor)

CreateCheckBox("Thanh Diệu (Bá chủ tầm nhìn)", UDim2.new(0, 0, 0, 66), PremiumFeaturesFrame, function(val)
    ThanhDieuCam = val
end, purpleColor)

CreateCheckBox("RainbowGun (Súng cầu vồng Full Mesh)", UDim2.new(0, 0, 0, 88), PremiumFeaturesFrame, function(val)
    GunRainbowEnabled = val
end, purpleColor)

CreateCheckBox("Ghost Mode (Tàng hình linh hồn)", UDim2.new(0, 0, 0, 110), PremiumFeaturesFrame, function(val)
    GhostEnabled = val
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = val and 0.9 or 0
            elseif part:IsA("Decal") then
                part.Transparency = val and 1 or 0
            elseif part:IsA("Accessory") or part:IsA("Tool") then
                for _, p in pairs(part:GetDescendants()) do
                    if p:IsA("BasePart") then p.Transparency = val and 0.9 or 0 end
                end
            end
        end
    end
end, purpleColor)

CheckPremBtn.MouseButton1Click:Connect(function()
    if PremKeyInput.Text == "HaiDon2012" then
        CheckPremBtn.Text = "THÀNH CÔNG!"
        PremiumUnlocked = true
        task.wait(0.5)
        PremiumKeyFrame.Visible = false
        PremiumTriggerBtn.Visible = false
        PremiumFeaturesFrame.Visible = true
    else
        CheckPremBtn.Text = "SAI KEY PREMIUM!"
        task.wait(1)
        CheckPremBtn.Text = "Kích Hoạt Premium"
    end
end)

--===================================================================================--
--                            HỆ THỐNG PLAYERKILLER LOGIC                             --
--===================================================================================--
local function TrackPlayerKills(targetPlayer)
    targetPlayer.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then
            hum.Died:Connect(function()
                if CurrentSuperWinTarget == targetPlayer then CurrentSuperWinTarget = nil end
                local creator = hum:FindFirstChild("creator")
                if creator and creator.Value == LocalPlayer then
                    KillsCounter = KillsCounter + 1
                    PlayerKillerLabel.Text = "PlayerKiller: [" .. KillsCounter .. "]"
                else
                    if PremiumUnlocked and SuperWinEnabled then
                        local distance = (char.PrimaryPart and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart) and (char.PrimaryPart.Position - LocalPlayer.Character.PrimaryPart.Position).Magnitude or math.huge
                        if distance < 15 then
                            KillsCounter = KillsCounter + 1
                            PlayerKillerLabel.Text = "PlayerKiller: [" .. KillsCounter .. "]"
                        end
                    end
                end
            end)
        end
    end)
end

for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then TrackPlayerKills(p) end
end
Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then TrackPlayerKills(p) end
end)
Players.PlayerRemoving:Connect(function(p)
    if CurrentSuperWinTarget == p then CurrentSuperWinTarget = nil end
end)

--===================================================================================--
--                               VÒNG LẶP CHÍNH & XỬ LÝ GAME                         --
--===================================================================================--
local esp_lines, esp_boxes = {}, {}

local function GetClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if distance < shortestDistance then
                        closestPlayer = p
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    return closestPlayer
end

task.spawn(function()
    while task.wait(0.03) do
        if PremiumUnlocked and GunRainbowEnabled then
            local char = LocalPlayer.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool") or (LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChildOfClass("Tool"))
                if tool then
                    local hue = (tick() % 3) / 3
                    local rainbowColor = Color3.fromHSV(hue, 1, 1)
                    for _, part in pairs(tool:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Color = rainbowColor
                            part.Material = Enum.Material.Neon
                        elseif part:IsA("Texture") or part:IsA("SpecialMesh") or part:IsA("MeshPart") then
                            pcall(function() part.VertexColor = Vector3.new(rainbowColor.R, rainbowColor.G, rainbowColor.B) end)
                            pcall(function() part.TextureID = "" end)
                        end
                    end
                end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if PremiumUnlocked and ThanhDieuCam then Camera.FieldOfView = 120 else Camera.FieldOfView = 70 end
    
    if PremiumUnlocked and AimbotActive then
        local target = GetClosestPlayerToCursor()
        if target and target.Character then
            local partToAim = AimMode == "aimHead" and target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
            if partToAim then Camera.CFrame = CFrame.new(Camera.CFrame.Position, partToAim.Position) end
        end
    end
    
    if PremiumUnlocked and SuperWinEnabled then
        if not CurrentSuperWinTarget or not CurrentSuperWinTarget.Character or not CurrentSuperWinTarget.Character:FindFirstChild("HumanoidRootPart") or not CurrentSuperWinTarget.Character:FindFirstChildOfClass("Humanoid") or CurrentSuperWinTarget.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
            CurrentSuperWinTarget = GetClosestPlayerToCursor()
        end
        
        if CurrentSuperWinTarget and CurrentSuperWinTarget.Character and CurrentSuperWinTarget.Character:FindFirstChild("HumanoidRootPart") then
            local localChar = LocalPlayer.Character
            if localChar and localChar:FindFirstChild("HumanoidRootPart") then
                localChar.HumanoidRootPart.CFrame = CurrentSuperWinTarget.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.02) do
        if PremiumUnlocked and GhostEnabled then
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Transparency ~= 0.9 then
                        part.Transparency = 0.9
                    end
                end
            end
        end

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if HitboxEnabled and not HitboxLocked and hum and hum.Health > 0 then
                    hrp.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                    hrp.Color = Color3.fromRGB(0, 255, 0)
                    hrp.Transparency = 0.6
                    hrp.Material = Enum.Material.Neon
                    hrp.CanCollide = false
                else
                    if hrp.Size ~= Vector3.new(2, 2, 1) then
                        hrp.Size = Vector3.new(2, 2, 1)
                        hrp.Transparency = 1
                    end
                end
                if ESPEnabled and hum and hum.Health > 0 then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        if not esp_lines[p] then
                            local line = Drawing.new("Line")
                            line.Color = Color3.fromRGB(0, 255, 0)
                            line.Thickness = 1.5
                            esp_lines[p] = line
                        end
                        esp_lines[p].From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        esp_lines[p].To = Vector2.new(screenPos.X, screenPos.Y)
                        esp_lines[p].Visible = true
                        if not esp_boxes[p] then
                            local b = Instance.new("Frame")
                            b.Size = UDim2.new(0, 50, 0, 70)
                            b.BackgroundTransparency = 1
                            b.BorderSizePixel = 0
                            local stroke = Instance.new("UIStroke")
                            stroke.Color = Color3.fromRGB(255, 255, 255)
                            stroke.Thickness = 1.5
                            stroke.Parent = b
                            local nameTag = Instance.new("TextLabel")
                            nameTag.Size = UDim2.new(1, 40, 0, 20)
                            nameTag.Position = UDim2.new(0, -20, 0, -25)
                            nameTag.Text = p.Name
                            nameTag.TextColor3 = Color3.fromRGB(255, 105, 180)
                            nameTag.BackgroundTransparency = 1
                            nameTag.Font = Enum.Font.SourceSansBold
                            nameTag.TextSize = 12
                            nameTag.Parent = b
                            b.Parent = MainGui
                            esp_boxes[p] = b
                        end
                        esp_boxes[p].Position = UDim2.new(0, screenPos.X - 25, 0, screenPos.Y - 35)
                        esp_boxes[p].Visible = true
                    else
                        if esp_lines[p] then esp_lines[p].Visible = false end
                        if esp_boxes[p] then esp_boxes[p].Visible = false end
                    end
                else
                    if esp_lines[p] then esp_lines[p].Visible = false end
                    if esp_boxes[p] then esp_boxes[p].Visible = false end
                end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if esp_lines[p] then esp_lines[p]:Remove() esp_lines[p] = nil end
    if esp_boxes[p] then esp_boxes[p]:Destroy() esp_boxes[p] = nil end
end)
