-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Eventos = ReplicatedStorage:WaitForChild("Eventos", 5)

----------------------------------------------------
-- CẤU HÌNH TRẠNG THÁI (SETTINGS)
----------------------------------------------------
local Settings = {
    AutoKill = false,
    NoReload = false,
    FastParachute = false,
    ESP = false,
    AimFOV = false,
    SpeedHack = false,
    SpeedValue = 40,
    FOVRadius = 100
}

----------------------------------------------------
-- 1. TẠO GIAO DIỆN HIỆN ĐẠI (MODERN MOBILE UI)
----------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltraCheatHub_V2"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Màn hình đếm ESP & BOT (Top Center)
local CounterLabel = Instance.new("TextLabel")
CounterLabel.Size = UDim2.new(0, 280, 0, 35)
CounterLabel.Position = UDim2.new(0.5, -140, 0, 15)
CounterLabel.BackgroundTransparency = 1
CounterLabel.Font = Enum.Font.FredokaOne
CounterLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
CounterLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
CounterLabel.TextStrokeTransparency = 0
CounterLabel.TextSize = 20
CounterLabel.Text = "PLAYERS: 0 | BOTS: 0"
CounterLabel.Visible = false
CounterLabel.Parent = ScreenGui

-- Vòng tròn Aim FOV
local FOVCircle = Instance.new("Frame")
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.BackgroundTransparency = 1
FOVCircle.BorderColor3 = Color3.fromRGB(0, 255, 170)
FOVCircle.BorderSizePixel = 1.5
FOVCircle.Visible = false
FOVCircle.Parent = ScreenGui

local UICornerCircle = Instance.new("UICorner")
UICornerCircle.CornerRadius = UDim.new(1, 0)
UICornerCircle.Parent = FOVCircle

-- NÚT NỔI BẬT TẮT MENU (TOGGLE HUB BUTTON)
local ToggleMenuBtn = Instance.new("TextButton")
ToggleMenuBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleMenuBtn.Position = UDim2.new(0.02, 0, 0.2, 0)
ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
ToggleMenuBtn.Text = "HUB"
ToggleMenuBtn.TextColor3 = Color3.fromRGB(0, 255, 170)
ToggleMenuBtn.Font = Enum.Font.GothamBold
ToggleMenuBtn.TextSize = 14
ToggleMenuBtn.Parent = ScreenGui

local OpenBtnCorner = Instance.new("UICorner")
OpenBtnCorner.CornerRadius = UDim.new(0, 12)
OpenBtnCorner.Parent = ToggleMenuBtn

local OpenBtnStroke = Instance.new("UIStroke")
OpenBtnStroke.Color = Color3.fromRGB(0, 255, 170)
OpenBtnStroke.Thickness = 2
OpenBtnStroke.Parent = ToggleMenuBtn

-- Frame Chính (Wide Window)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 380) -- Rộng hơn để chứa vừa vặn các item
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(40, 40, 60)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Thanh Tiêu Đề
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 14)
TitleBarCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -50, 1, 0)
TitleText.Position = UDim2.new(0, 14, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "PREMIUM VIP HUB v2"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 14
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- Nút đóng menu (Close Button X)
local CloseMenuBtn = Instance.new("TextButton")
CloseMenuBtn.Size = UDim2.new(0, 30, 0, 30)
CloseMenuBtn.Position = UDim2.new(1, -36, 0, 6)
CloseMenuBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseMenuBtn.Text = "✕"
CloseMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseMenuBtn.Font = Enum.Font.GothamBold
CloseMenuBtn.TextSize = 14
CloseMenuBtn.Parent = TitleBar

local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(0, 8)
CloseBtnCorner.Parent = CloseMenuBtn

-- Scrolling Container
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Size = UDim2.new(1, -16, 1, -52)
ContentScroll.Position = UDim2.new(0, 8, 0, 48)
ContentScroll.BackgroundTransparency = 1
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 420)
ContentScroll.ScrollBarThickness = 3
ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 170)
ContentScroll.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = ContentScroll

----------------------------------------------------
-- LOGIC KÉO THẢ MƯỢT MÀ (DRAGGABLE)
----------------------------------------------------
local function MakeDraggable(guiObject)
    local dragging, dragInput, dragStart, startPos
    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

MakeDraggable(MainFrame)
MakeDraggable(ToggleMenuBtn)

ToggleMenuBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

CloseMenuBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

----------------------------------------------------
-- 2. CÁC HÀM TẠO WIDGET (TOGGLE / BUTTON / SLIDER)
----------------------------------------------------
local function CreateToggle(name, settingKey, callback)
    local ItemContainer = Instance.new("Frame")
    ItemContainer.Size = UDim2.new(1, 0, 0, 40)
    ItemContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    ItemContainer.Parent = ContentScroll

    local ItemCorner = Instance.new("UICorner")
    ItemCorner.CornerRadius = UDim.new(0, 8)
    ItemCorner.Parent = ItemContainer

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.68, 0, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(230, 230, 240)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ItemContainer

    local SwitchBg = Instance.new("TextButton")
    SwitchBg.Size = UDim2.new(0, 46, 0, 22)
    SwitchBg.Position = UDim2.new(1, -56, 0.5, -11)
    SwitchBg.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    SwitchBg.Text = ""
    SwitchBg.Parent = ItemContainer

    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = SwitchBg

    local SwitchDot = Instance.new("Frame")
    SwitchDot.Size = UDim2.new(0, 18, 0, 18)
    SwitchDot.Position = UDim2.new(0, 2, 0.5, -9)
    SwitchDot.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    SwitchDot.Parent = SwitchBg

    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = SwitchDot

    SwitchBg.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        local active = Settings[settingKey]
        
        SwitchBg.BackgroundColor3 = active and Color3.fromRGB(0, 200, 120) or Color3.fromRGB(45, 45, 60)
        SwitchDot.Position = active and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        SwitchDot.BackgroundColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
        
        if callback then callback(active) end
    end)
end

local function CreateButton(name, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 40)
    Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    Btn.Text = name
    Btn.TextColor3 = Color3.fromRGB(0, 255, 170)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 13
    Btn.Parent = ContentScroll

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Btn

    Btn.MouseButton1Click:Connect(callback)
end

-- Slider FOV
local SliderFrame = Instance.new("Frame")
SliderFrame.Size = UDim2.new(1, 0, 0, 50)
SliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
SliderFrame.Parent = ContentScroll

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(0, 8)
SliderCorner.Parent = SliderFrame

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Size = UDim2.new(1, -20, 0, 20)
SliderLabel.Position = UDim2.new(0, 12, 0, 4)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "FOV Radius: 100"
SliderLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
SliderLabel.Font = Enum.Font.GothamSemibold
SliderLabel.TextSize = 12
SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
SliderLabel.Parent = SliderFrame

local SliderTrack = Instance.new("TextButton")
SliderTrack.Size = UDim2.new(1, -24, 0, 8)
SliderTrack.Position = UDim2.new(0, 12, 0, 30)
SliderTrack.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
SliderTrack.Text = ""
SliderTrack.Parent = SliderFrame

local TrackCorner = Instance.new("UICorner")
TrackCorner.CornerRadius = UDim.new(1, 0)
TrackCorner.Parent = SliderTrack

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new((100 - 15)/(200 - 15), 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderTrack

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(1, 0)
FillCorner.Parent = SliderFill

-- Khởi tạo các Toggles & Buttons
CreateToggle("Auto Kill (All Map)", "AutoKill")
CreateToggle("Silent Aim (WallCheck)", "AimFOV", function(val) FOVCircle.Visible = val end)
CreateToggle("ESP Line & Info", "ESP", function(val) CounterLabel.Visible = val end)
CreateToggle("Speed Boost (Speed: 40)", "SpeedHack")
CreateToggle("No Reload Delay", "NoReload")
CreateToggle("Fast Parachute Drop", "FastParachute")

CreateButton("🌐 Hop Server (Đổi Server)", function()
    local placeId = game.PlaceId
    TeleportService:Teleport(placeId, LocalPlayer)
end)

-- Logic Slider FOV
local sliding = false
SliderTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local relative = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
        local value = math.floor(15 + relative * (200 - 15))
        Settings.FOVRadius = value
        SliderFill.Size = UDim2.new(relative, 0, 1, 0)
        SliderLabel.Text = "FOV Radius: " .. tostring(value)
        FOVCircle.Size = UDim2.new(0, value * 2, 0, value * 2)
    end
end)
FOVCircle.Size = UDim2.new(0, Settings.FOVRadius * 2, 0, Settings.FOVRadius * 2)

----------------------------------------------------
-- 3. SPEED HACK LOGIC (CỐ ĐỊNH SPEED 40)
----------------------------------------------------
RunService.Stepped:Connect(function()
    if Settings.SpeedHack and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Settings.SpeedValue
        end
    end
end)

----------------------------------------------------
-- 4. HÀM RAYCAST WALLCHECK
----------------------------------------------------
local function IsVisible(targetPart)
    local origin = Camera.CFrame.Position
    local destination = targetPart.Position
    local direction = (destination - origin)
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    raycastParams.IgnoreWater = true

    local result = Workspace:Raycast(origin, direction, raycastParams)
    return result == nil
end

----------------------------------------------------
-- 5. LẤY TARGET TRONG VÒNG FOV
----------------------------------------------------
local function GetClosestTargetInFOV()
    local closestTarget = nil
    local shortestDistance = Settings.FOVRadius
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetChar = player.Character
            local targetHitbox = targetChar:FindFirstChild("Head") or targetChar:FindFirstChild("HumanoidRootPart")
            local humanoid = targetChar:FindFirstChildOfClass("Humanoid")

            if targetHitbox and humanoid and humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetHitbox.Position)
                if onScreen then
                    local targetPos2D = Vector2.new(screenPos.X, screenPos.Y)
                    local distance = (targetPos2D - screenCenter).Magnitude

                    if distance <= shortestDistance and IsVisible(targetHitbox) then
                        shortestDistance = distance
                        closestTarget = targetHitbox
                    end
                end
            end
        end
    end
    return closestTarget
end

----------------------------------------------------
-- 6. HỆ THỐNG ESP SỬA LỖI DÂY & ĐẾM BOT/NPC
----------------------------------------------------
local ESPCache = {}

local function GetESPObjects(key)
    if ESPCache[key] then return ESPCache[key] end
    
    local line = Instance.new("Frame")
    line.BorderSizePixel = 0
    line.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    line.Parent = ScreenGui

    local box = Instance.new("Frame")
    box.BackgroundTransparency = 1
    box.BorderColor3 = Color3.fromRGB(0, 255, 170)
    box.BorderSizePixel = 1.5
    box.Parent = ScreenGui

    local nameText = Instance.new("TextLabel")
    nameText.BackgroundTransparency = 1
    nameText.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameText.Font = Enum.Font.GothamBold
    nameText.TextSize = 10
    nameText.Parent = box

    local healthBg = Instance.new("Frame")
    healthBg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    healthBg.BorderSizePixel = 0
    healthBg.Parent = box

    local healthFill = Instance.new("Frame")
    healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
    healthFill.BorderSizePixel = 0
    healthFill.Parent = healthBg

    local objects = {Line = line, Box = box, Name = nameText, HealthBg = healthBg, HealthFill = healthFill}
    ESPCache[key] = objects
    return objects
end

local function HideESP(key)
    if ESPCache[key] then
        ESPCache[key].Line.Visible = false
        ESPCache[key].Box.Visible = false
    end
end

RunService.RenderStepped:Connect(function()
    if not Settings.ESP then 
        CounterLabel.Visible = false
        for key, _ in pairs(ESPCache) do HideESP(key) end
        return 
    end

    local playerCount = 0
    local botCount = 0
    local screenCenterBottom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)

    -- Thu thập danh sách Character (bao gồm Người chơi và Bot/NPC)
    local targets = {}
    
    for _, model in ipairs(Workspace:GetDescendants()) do
        if model:IsA("Model") and model ~= LocalPlayer.Character then
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            local hrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head")
            
            if humanoid and hrp and humanoid.Health > 0 then
                local player = Players:GetPlayerFromCharacter(model)
                local isBot = (player == nil)
                
                table.insert(targets, {
                    Model = model,
                    HRP = hrp,
                    Head = model:FindFirstChild("Head") or hrp,
                    Humanoid = humanoid,
                    Name = isBot and ("[BOT] " .. model.Name) or player.Name,
                    IsBot = isBot,
                    Key = model
                })
            end
        end
    end

    for _, target in ipairs(targets) do
        local hrpPos, onScreen = Camera:WorldToViewportPoint(target.HRP.Position)

        if onScreen then
            if target.IsBot then botCount = botCount + 1 else playerCount = playerCount + 1 end
            local esp = GetESPObjects(target.Key)

            -- 1. SỬA LỖI DÂY NỐI (Vẽ chính xác từ chính giữa phía dưới màn hình lên Target)
            local target2D = Vector2.new(hrpPos.X, hrpPos.Y)
            local dist = (target2D - screenCenterBottom).Magnitude
            local angle = math.deg(math.atan2(target2D.Y - screenCenterBottom.Y, target2D.X - screenCenterBottom.X))

            esp.Line.Size = UDim2.new(0, dist, 0, 1)
            esp.Line.Position = UDim2.new(0, screenCenterBottom.X, 0, screenCenterBottom.Y)
            esp.Line.AnchorPoint = Vector2.new(0, 0.5)
            esp.Line.Rotation = angle
            esp.Line.BackgroundColor3 = target.IsBot and Color3.fromRGB(255, 170, 0) or Color3.fromRGB(255, 50, 50)
            esp.Line.Visible = true

            -- 2. Box Bounding Tỷ lệ
            local headPos = Camera:WorldToViewportPoint(target.Head.Position + Vector3.new(0, 0.5, 0))
            local legPos = Camera:WorldToViewportPoint(target.HRP.Position - Vector3.new(0, 3, 0))
            local height = math.abs(headPos.Y - legPos.Y)
            local width = height * 0.65

            esp.Box.Size = UDim2.new(0, width, 0, height)
            esp.Box.Position = UDim2.new(0, hrpPos.X - (width / 2), 0, headPos.Y)
            esp.Box.BorderColor3 = target.IsBot and Color3.fromRGB(255, 170, 0) or Color3.fromRGB(0, 255, 170)
            esp.Box.Visible = true

            -- 3. Name & Health
            esp.Name.Size = UDim2.new(1, 0, 0, 14)
            esp.Name.Position = UDim2.new(0, 0, 0, -16)
            esp.Name.Text = target.Name

            esp.HealthBg.Size = UDim2.new(0, 3, 1, 0)
            esp.HealthBg.Position = UDim2.new(0, -6, 0, 0)

            local hpPercent = math.clamp(target.Humanoid.Health / target.Humanoid.MaxHealth, 0, 1)
            esp.HealthFill.Size = UDim2.new(1, 0, hpPercent, 0)
                        esp.HealthFill.Position = UDim2.new(0, 0, 1 - hpPercent, 0)
            esp.HealthFill.BackgroundColor3 = Color3.fromHSV(hpPercent * 0.3, 1, 1)
        else
            HideESP(target.Key)
        end
    end

    -- Cập nhật bảng đếm số lượng Player và Bot trên màn hình
    CounterLabel.Text = string.format("PLAYERS: %d | BOTS: %d", playerCount, botCount)
end)

----------------------------------------------------
-- 7. AUTO KILL LOGIC (VÒNG LẶP QUÉT VÀ XỬ LÝ TARGET)
----------------------------------------------------
task.spawn(function()
    while task.wait(0.1) do
        if Settings.AutoKill then
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end

                local currentWeapon = character:FindFirstChildOfClass("Tool")
                if not currentWeapon then return end

                -- Tìm đối thủ gần nhất trong Workspace
                for _, model in ipairs(Workspace:GetDescendants()) do
                    if model:IsA("Model") and model ~= character then
                        local humanoid = model:FindFirstChildOfClass("Humanoid")
                        local targetHead = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")

                        if humanoid and targetHead and humanoid.Health > 0 then
                            -- Gửi Signal/Event bắn nếu game hỗ trợ RemoteEvent
                            if Eventos and Eventos:FindFirstChild("Shoot") then
                                Eventos.Shoot:FireServer(targetHead.Position, currentWeapon)
                            elseif Eventos and Eventos:FindFirstChild("Hit") then
                                Eventos.Hit:FireServer(humanoid, targetHead)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

----------------------------------------------------
-- 8. NO RELOAD & FAST PARACHUTE LOGIC
----------------------------------------------------
-- Xử lý Fast Parachute (Tăng tốc độ rơi khi nhảy dù)
RunService.Heartbeat:Connect(function()
    if Settings.FastParachute and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.Velocity.Y < -5 then
            -- Áp dụng lực kéo xuống để tiếp đất nhanh hơn
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -120, hrp.AssemblyLinearVelocity.Z)
        end
    end
end)

-- Xử lý No Reload Delay (Xóa bỏ delay nạp đạn của vũ khí)
LocalPlayer.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and Settings.NoReload then
            local config = child:FindFirstChild("Configuration") or child:FindFirstChild("Settings")
            if config then
                local reloadTime = config:FindFirstChild("ReloadTime") or config:FindFirstChild("ReloadDelay")
                if reloadTime and reloadTime:IsA("NumberValue") then
                    reloadTime.Value = 0
                end
            end
        end
    end)
end)

----------------------------------------------------
-- 9. KHỞI TẠO VÀ DỌN DẸP KHI THOÁT
----------------------------------------------------
print("UltraCheatHub V2 Loaded Successfully!")
