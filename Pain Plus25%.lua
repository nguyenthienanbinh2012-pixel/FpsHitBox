-- Paint Plus v2.4 Deadrails
-- Author: SharkTeam Mobile
-- Mobile friendly

if getgenv().PaintPlus_Loaded then
    local ok, err = pcall(function()
        if getgenv().PaintPlus_Unload then
            getgenv().PaintPlus_Unload()
        end
    end)
    if not ok then
        warn("[PaintPlus] Loi unload cu: " .. tostring(err))
    end
    task.wait(0.1)
end

getgenv().PaintPlus_Loaded = true

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local function CleanOldGui()
    local ok, err = pcall(function()
        for _, gui in ipairs(CoreGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                local n = string.lower(gui.Name)
                if string.find(n, "rayfield") or string.find(n, "windui") or string.find(n, "paintplus") then
                    gui:Destroy()
                end
            end
        end
        if LocalPlayer:FindFirstChild("PlayerGui") then
            for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
                if gui:IsA("ScreenGui") then
                    local n = string.lower(gui.Name)
                    if string.find(n, "rayfield") or string.find(n, "windui") or string.find(n, "paintplus") then
                        gui:Destroy()
                    end
                end
            end
        end
    end)
    if not ok then
        warn("[PaintPlus] Loi xoa GUI cu: " .. tostring(err))
    end
end
CleanOldGui()

local Remotes = {
    Pickup = nil,
    Store = nil,
    Actionable = nil,
    DropTool = nil
}

local function WaitForChildSafe(parent, name, timeout)
    local ok, child = pcall(function()
        return parent:WaitForChild(name, timeout or 10)
    end)
    if not ok then
        warn("[PaintPlus] Loi WaitForChild " .. name .. ": " .. tostring(child))
        return nil
    end
    return child
end

local Shared = WaitForChildSafe(ReplicatedStorage, "Shared", 10)
if Shared then
    local Universe = WaitForChildSafe(Shared, "Universe", 10)
    if Universe then
        local Network = WaitForChildSafe(Universe, "Network", 10)
        if Network then
            local RemoteEvent = WaitForChildSafe(Network, "RemoteEvent", 10)
            if RemoteEvent then
                local function findRemote(name)
                    for _, child in ipairs(RemoteEvent:GetChildren()) do
                        if child.Name == name then
                            return child
                        end
                    end
                    return RemoteEvent:FindFirstChild(name)
                end
                Remotes.Pickup = findRemote("Pickup")
                Remotes.Store = findRemote("Store")
                Remotes.Actionable = findRemote("Actionable")
                Remotes.DropTool = findRemote("DropTool")
            end
        end
    end
end

local WindUI
do
    local ok, result = pcall(function()
        return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    end)
    if ok and result then
        WindUI = result
        getgenv().PaintPlus_WindUI = WindUI
        local ver = "unknown"
        pcall(function()
            ver = WindUI.Version or WindUI.version or "unknown"
        end)
        print("[PaintPlus] WindUI loaded: " .. tostring(ver))
    else
        warn("[PaintPlus] Loi tai WindUI: " .. tostring(result))
        return
    end
end

local FeatureStates = {
    PickupAll = false,
    ScanVampireKnife = false,
    SLX_Lite = false,
    SpeedPlus = false,
    ThirdPerson = false,
    BypassPromitixy = false,
    SpeedProximity = false,
    AutoTravelTrain = false,
    FlyTrain = false,
    HighJump = false,
    NoClip = false,
    EspHorseRim = false,
    EspHorseBox = false,
    EspNpc = false
}

local PickupAllThread = nil
local VampireKnifeThread = nil
local SpeedMonitorThread = nil
local FlyConnection = nil
local FlyVelocity = nil
local SLX_Lite_Loaded = false
local ThirdPersonConnection = nil
local BypassConnection = nil
local SpeedProximityThread = nil
local AutoTravelConnection = nil
local NoClipConnection = nil
local FlyTrainThread = nil
local FlyTrainSeat = nil
local EspHorseRimThread = nil
local EspHorseBoxThread = nil
local EspNpcThread = nil
local EspHorseFolder = nil
local EspBoxFolder = nil
local EspNpcFolder = nil
local EspBillboardFolder = nil

local OriginalCameraMaxZoom = nil
local OriginalCameraMinZoom = nil
local OriginalCameraMode = nil
local OriginalCameraType = nil
local OriginalCameraSubject = nil
local OriginalCameraFOV = nil
local OriginalJumpPower = nil
local OriginalJumpHeight = nil
local OriginalUseJumpPower = nil

local TrainTeleport = {
    SavedSeat = nil,
    SavedName = nil,
    IsTeleporting = false,
    HasSaved = false
}
local MAX_TELEPORT_DISTANCE = 3200
local MAX_FLY_TRAIN_DISTANCE = 8000

local PickupAllProgress = {
    CurrentId = 1000,
    StartId = 1000,
    EndId = 4000,
    Percent = 0,
    LastMilestone = 0
}

local FlySpeed = 60
local MaxFlySpeed = 1000
local FlyTrainSpeed = 500

local EspHorseColor = Color3.fromRGB(0, 191, 255)
local EspNpcColor = Color3.fromRGB(0, 255, 0)
local EspHorseRange = 5000
local EspHorseBoxRange = 7000
local EspNpcRange = 500

local IsUnloading = false
local ActiveConnections = {}

local function RegisterConnection(conn)
    if conn then
        table.insert(ActiveConnections, conn)
    end
    return conn
end

local function DisconnectAllConnections()
    for _, conn in ipairs(ActiveConnections) do
        local ok, err = pcall(function()
            if conn and conn.Disconnect then
                conn:Disconnect()
            end
        end)
        if not ok then
            warn("[PaintPlus] Loi disconnect: " .. tostring(err))
        end
    end
    ActiveConnections = {}
end

local Window
do
    local ok, err = pcall(function()
        Window = WindUI:CreateWindow({
            Title = "Paint Plus v2.4 Deadrails",
            Author = "by SharkTeam Mobile",
            Icon = "sword",
            Folder = "PaintPlus",
            Size = UDim2.fromOffset(580, 460),
            Resizable = true,
            Theme = "Dark",
            OpenButton = {
                Title = "Paint Plus Menu",
                Enabled = true,
                Draggable = true,
                Scale = 1,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromHex("00BFFF")),
                    ColorSequenceKeypoint.new(1, Color3.fromHex("87CEFA"))
                })
            }
        })
    end)
    if not ok or not Window then
        warn("[PaintPlus] Loi tao Window: " .. tostring(err))
        return
    end
end

pcall(function()
    if Window.SetToggleKey then
        Window:SetToggleKey(Enum.KeyCode.K)
    end
end)

pcall(function()
    if Window.EditTheme then
        Window:EditTheme({
            Accent = Color3.fromHex("00BFFF"),
            Dialog = Color3.fromHex("0A1929"),
            Button = Color3.fromHex("87CEFA")
        })
    end
end)

local function SafeCreateTab(title, icon)
    local tab
    local ok, err = pcall(function()
        if Window.Tab then
            tab = Window:Tab({ Title = title, Icon = icon })
        elseif Window.CreateTab then
            tab = Window:CreateTab(title, icon)
        end
    end)
    if not ok or not tab then
        warn("[PaintPlus] Loi tao Tab " .. title .. ": " .. tostring(err))
        return nil
    end
    return tab
end

local Tabs = {}
Tabs.Main = SafeCreateTab("Tính Năng Chính", "layout-grid")
Tabs.Train = SafeCreateTab("Tàu và Di Chuyển", "train")
Tabs.Scan = SafeCreateTab("Quét Vật Phẩm", "package")
Tabs.Features = SafeCreateTab("Chức Năng", "sparkles")
Tabs.Visual = SafeCreateTab("Visual", "eye")
Tabs.Stats = SafeCreateTab("Chỉ Số", "gauge")
Tabs.Info = SafeCreateTab("Thông Tin và Menu", "file-text")

if not Tabs.Main or not Tabs.Train or not Tabs.Scan or not Tabs.Features or not Tabs.Visual or not Tabs.Stats or not Tabs.Info then
    warn("[PaintPlus] Khong tao du 7 tab, dung script")
    return
end

local function SafeNotify(title, content, duration)
    if not Window then
        warn("[PaintPlus] Window chua ton tai, khong the notify")
        return
    end
    local ok, err = pcall(function()
        Window:Notify({
            Title = title,
            Content = content,
            Duration = duration or 3
        })
    end)
    if not ok then
        warn("[PaintPlus] Loi Window:Notify: " .. tostring(err))
        local ok2, err2 = pcall(function()
            WindUI:Notify({
                Title = title,
                Content = content,
                Duration = duration or 3
            })
        end)
        if not ok2 then
            warn("[PaintPlus] Loi WindUI:Notify du phong: " .. tostring(err2))
        end
    end
end

local function SafeSection(tab, title)
    if not tab then return nil end
    local section
    local ok, err = pcall(function()
        if tab.Section then
            section = tab:Section({ Title = title })
        elseif tab.CreateSection then
            section = tab:CreateSection(title)
        end
    end)
    if not ok then
        warn("[PaintPlus] Loi tao Section " .. title .. ": " .. tostring(err))
        return tab
    end
    return section or tab
end

local function SafeToggle(parent, config)
    if not parent then return nil end
    local toggle
    local ok, err = pcall(function()
        if parent.Toggle then
            toggle = parent:Toggle({
                Title = config.Title,
                Desc = config.Desc or "",
                Value = config.Value or false,
                Flag = config.Flag,
                Callback = config.Callback
            })
        end
    end)
    if not ok then
        warn("[PaintPlus] Loi tao Toggle " .. tostring(config.Title) .. ": " .. tostring(err))
    end
    return toggle
end

local function SafeButton(parent, config)
    if not parent then return end
    local ok, err = pcall(function()
        if parent.Button then
            parent:Button({
                Title = config.Title,
                Desc = config.Desc or "",
                Callback = config.Callback
            })
        end
    end)
    if not ok then
        warn("[PaintPlus] Loi tao Button " .. tostring(config.Title) .. ": " .. tostring(err))
    end
end

local function SafeInput(parent, config)
    if not parent then return end
    local ok, err = pcall(function()
        if parent.Input then
            parent:Input({
                Title = config.Title,
                Desc = config.Desc or "",
                Placeholder = config.Placeholder or "",
                Value = config.Value or "",
                Callback = config.Callback
            })
        end
    end)
    if not ok then
        warn("[PaintPlus] Loi tao Input " .. tostring(config.Title) .. ": " .. tostring(err))
    end
end

local function SafeParagraph(parent, config)
    if not parent then return end
    local ok, err = pcall(function()
        if parent.Paragraph then
            parent:Paragraph({
                Title = config.Title,
                Desc = config.Desc or ""
            })
        end
    end)
    if not ok then
        warn("[PaintPlus] Loi tao Paragraph " .. tostring(config.Title) .. ": " .. tostring(err))
    end
end

local function GetItemId(item)
    if not item then return nil end
    local attrNames = {"id", "itemid", "item_id", "uuid", "objectid"}
    for _, attrName in ipairs(attrNames) do
        for _, attr in ipairs(item:GetAttributes()) do
            if string.lower(attr) == attrName then
                local val = item:GetAttribute(attr)
                if val then return val end
            end
        end
    end
    for _, child in ipairs(item:GetChildren()) do
        if child:IsA("ValueBase") then
            local lower = string.lower(child.Name)
            for _, attrName in ipairs(attrNames) do
                if lower == attrName then
                    return child.Value
                end
            end
        end
    end
    local num = tonumber(item.Name)
    if num then return num end
    return nil
end

local function HasVampireKnife()
    local char = LocalPlayer.Character
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if string.find(string.lower(item.Name), "vampire") then
                return true
            end
        end
    end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if string.find(string.lower(item.Name), "vampire") then
                return true
            end
        end
    end
    return false
end

local function FindHorseRoot()
    local char = LocalPlayer.Character
    if not char then return nil end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end
    local seatPart = humanoid.SeatPart
    if not seatPart then return nil end
    local model = seatPart:FindFirstAncestorOfClass("Model")
    if not model then return nil end
    if model.PrimaryPart then return model.PrimaryPart end
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and part.Name == "RootPart" then
            return part
        end
    end
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and part.Name == "HumanoidRootPart" then
            return part
        end
    end
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            return part
        end
    end
    return nil
end

local function LoadSavedSeat()
    local ok, data = pcall(function()
        if readfile and isfile and isfile("PaintPlus_TrainSeat.json") then
            return HttpService:JSONDecode(readfile("PaintPlus_TrainSeat.json"))
        end
        return nil
    end)
    if not ok then
        warn("[PaintPlus] Loi doc file ghe: " .. tostring(data))
        return false
    end
    if not data or not data.Name then return false end
    local seat = Workspace:FindFirstChild(data.Name, true)
    if seat then
        TrainTeleport.SavedSeat = seat
        TrainTeleport.SavedName = data.Name
        TrainTeleport.HasSaved = true
        return true
    end
    return false
end

local function GetTargetSeat()
    if TrainTeleport.SavedSeat and TrainTeleport.SavedSeat.Parent then
        return TrainTeleport.SavedSeat
    end
    LoadSavedSeat()
    return TrainTeleport.SavedSeat
end

pcall(function()
    LoadSavedSeat()
end)

-- ===== TAB 1 =====
local MainSection = SafeSection(Tabs.Main, "Thu Thập Vật Phẩm")

local function StopPickupAll()
    if PickupAllThread then
        pcall(function()
            task.cancel(PickupAllThread)
        end)
        PickupAllThread = nil
    end
    FeatureStates.PickupAll = false
    PickupAllProgress.CurrentId = 1000
    PickupAllProgress.Percent = 0
    PickupAllProgress.LastMilestone = 0
end

local function StartPickupAll()
    PickupAllThread = task.spawn(function()
        while FeatureStates.PickupAll and not IsUnloading do
            for itemId = 1000, 4000 do
                if not FeatureStates.PickupAll or IsUnloading then break end
                local ok, err = pcall(function()
                    if Remotes.Store then
                        Remotes.Store:FireServer(nil)
                    end
                end)
                if not ok then
                    warn("[PaintPlus] Loi Store nil " .. tostring(itemId) .. ": " .. tostring(err))
                end
                task.wait(0.03)
                local ok2, err2 = pcall(function()
                    if Remotes.Pickup then
                        Remotes.Pickup:FireServer(itemId)
                    end
                end)
                if not ok2 then
                    warn("[PaintPlus] Loi Pickup " .. tostring(itemId) .. ": " .. tostring(err2))
                end
                task.wait(0.03)
                local ok3, err3 = pcall(function()
                    if Remotes.Store then
                        Remotes.Store:FireServer(itemId)
                    end
                end)
                if not ok3 then
                    warn("[PaintPlus] Loi Store " .. tostring(itemId) .. ": " .. tostring(err3))
                end
                PickupAllProgress.CurrentId = itemId
                PickupAllProgress.Percent = math.floor((itemId - 1000) / 3000 * 100)
                if itemId % 1000 == 0 and itemId > PickupAllProgress.LastMilestone then
                    PickupAllProgress.LastMilestone = itemId
                    SafeNotify("Tiến Độ Quét", "Đã quét tới ID " .. tostring(itemId) .. " (" .. tostring(PickupAllProgress.Percent) .. "%)", 3)
                end
                task.wait(0.01)
            end
            if FeatureStates.PickupAll and not IsUnloading then
                SafeNotify("Hoàn Thành", "Đã quét xong một vòng 1000-4000, bắt đầu lại", 3)
                PickupAllProgress.LastMilestone = 0
            end
            task.wait(0.5)
        end
    end)
end

SafeToggle(MainSection, {
    Title = "Quét Tất Cả Vật Phẩm",
    Desc = "Quét ID 1000 đến 4000",
    Value = false,
    Callback = function(state)
        if state then
            FeatureStates.PickupAll = true
            PickupAllProgress.CurrentId = 1000
            PickupAllProgress.Percent = 0
            PickupAllProgress.LastMilestone = 0
            StartPickupAll()
            SafeNotify("Quét Vật Phẩm", "Đã bật quét tất cả vật phẩm 1000-4000", 3)
        else
            StopPickupAll()
            SafeNotify("Quét Vật Phẩm", "Đã tắt quét tất cả vật phẩm", 3)
        end
    end
})

SafeButton(MainSection, {
    Title = "Xem Tiến Độ Quét",
    Desc = "Hiển thị tiến độ hiện tại",
    Callback = function()
        if FeatureStates.PickupAll then
            SafeNotify("Tiến Độ", "ID hiện tại: " .. tostring(PickupAllProgress.CurrentId) .. " - " .. tostring(PickupAllProgress.Percent) .. "%", 4)
        else
            SafeNotify("Tiến Độ", "Chưa bật tính năng quét", 3)
        end
    end
})

local ResetSection = SafeSection(Tabs.Main, "Reset Nhân Vật")

SafeButton(ResetSection, {
    Title = "Reset Player",
    Desc = "Đặt lại nhân vật",
    Callback = function()
        local char = LocalPlayer.Character
        if not char then
            SafeNotify("Reset Player", "Không tìm thấy nhân vật", 3)
            return
        end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            SafeNotify("Reset Player", "Không tìm thấy Humanoid", 3)
            return
        end
        local ok, err = pcall(function()
            humanoid.Health = 0
        end)
        if not ok then
            warn("[PaintPlus] Loi reset: " .. tostring(err))
            SafeNotify("Reset Player", "Lỗi: " .. tostring(err), 3)
            return
        end
        SafeNotify("Reset Player", "Đã đặt lại nhân vật", 3)
    end
})

-- ===== TAB 2 =====
local SaveSection = SafeSection(Tabs.Train, "Lưu Và Di Chuyển")

SafeButton(SaveSection, {
    Title = "Lưu Vị Trí Ghế",
    Desc = "Lưu ghế đang ngồi",
    Callback = function()
        local char = LocalPlayer.Character
        if not char then
            SafeNotify("Lưu Ghế", "Không tìm thấy nhân vật", 3)
            return
        end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            SafeNotify("Lưu Ghế", "Không tìm thấy Humanoid", 3)
            return
        end
        local seat = humanoid.SeatPart
        if not seat then
            SafeNotify("Lưu Ghế", "Chưa ngế", 3)
            return
        end
        TrainTeleport.SavedSeat = seat
        TrainTeleport.SavedName = seat.Name
        TrainTeleport.HasSaved = true
        local ok, err = pcall(function()
            if writefile then
                writefile("PaintPlus_TrainSeat.json", HttpService:JSONEncode({Name = seat.Name}))
            end
        end)
        if not ok then
            warn("[PaintPlus] Loi ghi file ghe: " .. tostring(err))
        end
        SafeNotify("Lưu Ghế", "Đã lưu vị trí ghế: " .. seat.Name, 3)
    end
})

SafeButton(SaveSection, {
    Title = "Di Chuyển Về Tàu",
    Desc = "Giới hạn 3200 studs",
    Callback = function()
        if not TrainTeleport.HasSaved then
            if not LoadSavedSeat() then
                SafeNotify("Di Chuyển", "Chưa lưu vị trí ghế", 3)
                return
            end
        end
        local seat = TrainTeleport.SavedSeat
        if not seat or not seat.Parent then
            if not LoadSavedSeat() then
                SafeNotify("Di Chuyển", "Ghế đã bị xóa hoặc chưa lưu", 3)
                return
            end
            seat = TrainTeleport.SavedSeat
        end
        local char = LocalPlayer.Character
        if not char then
            SafeNotify("Di Chuyển", "Không tìm thấy nhân vật", 3)
            return
        end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not humanoid or not root then
            SafeNotify("Di Chuyển", "Không tìm thấy nhân vật", 3)
            return
        end
        local dist = (root.Position - seat.Position).Magnitude
        if dist > MAX_TELEPORT_DISTANCE then
            SafeNotify("Di Chuyển", "Không tìm thấy tàu trong phạm vi 3200 studs", 3)
            return
        end
        if TrainTeleport.IsTeleporting then
            SafeNotify("Di Chuyển", "Đang di chuyển, vui lòng chờ", 3)
            return
        end
        TrainTeleport.IsTeleporting = true
        SafeNotify("Di Chuyển", "Đang di chuyển về ghế", 3)
        task.spawn(function()
            local ok, err = pcall(function()
                local oldHealth = humanoid.Health
                humanoid.Sit = false
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.AssemblyLinearVelocity = Vector3.zero
                    end
                end
                local okNet, errNet = pcall(function()
                    root:SetNetworkOwner(nil)
                end)
                if not okNet then
                    warn("[PaintPlus] Loi SetNetworkOwner server: " .. tostring(errNet))
                end
                local anchoredStates = {}
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        anchoredStates[part] = part.Anchored
                        part.Anchored = true
                    end
                end
                root.CFrame = CFrame.new(seat.Position + Vector3.new(0, 1.5, 0))
                seat:Sit(humanoid)
                task.wait(0.1)
                if not humanoid.Sit then
                    humanoid.Sit = true
                end
                for part, state in pairs(anchoredStates) do
                    if part and part.Parent then
                        part.Anchored = state
                    end
                end
                local okNet2, errNet2 = pcall(function()
                    root:SetNetworkOwner(LocalPlayer)
                end)
                if not okNet2 then
                    warn("[PaintPlus] Loi SetNetworkOwner player: " .. tostring(errNet2))
                end
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.AssemblyLinearVelocity = Vector3.zero
                    end
                end
                if humanoid.Health < oldHealth then
                    humanoid.Health = oldHealth
                end
            end)
            if not ok then
                warn("[PaintPlus] Loi teleport: " .. tostring(err))
            end
            TrainTeleport.IsTeleporting = false
            SafeNotify("Di Chuyển", "Đã di chuyển về tàu", 3)
        end)
    end
})

local AutoSection = SafeSection(Tabs.Train, "Tàu Tự Chạy")

local function StopAutoTravelTrain()
    if AutoTravelConnection then
        pcall(function()
            AutoTravelConnection:Disconnect()
        end)
        AutoTravelConnection = nil
    end
    FeatureStates.AutoTravelTrain = false
end

SafeToggle(AutoSection, {
    Title = "Auto Travel Train Seat",
    Desc = "Tàu tự chạy tối đa tốc độ",
    Value = false,
    Callback = function(state)
        if state then
            local char = LocalPlayer.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if not humanoid or not humanoid.SeatPart then
                SafeNotify("Auto Travel", "Bạn chưa ngồi trên ghế tàu", 3)
                FeatureStates.AutoTravelTrain = false
                return
            end
            FeatureStates.AutoTravelTrain = true
            local seat = humanoid.SeatPart
            AutoTravelConnection = RunService.Heartbeat:Connect(function()
                local ok, err = pcall(function()
                    if not FeatureStates.AutoTravelTrain then return end
                    local model = seat:FindFirstAncestorOfClass("Model")
                    if not model then return end
                    for _, d in ipairs(model:GetDescendants()) do
                        if d:IsA("VehicleSeat") then
                            d.ThrottleFloat = 1
                            d.SteerFloat = 0
                            d.MaxSpeed = 1000000
                            d.Torque = 1000000
                        elseif d:IsA("HingeConstraint") then
                            d.AngularVelocity = 1000000
                            d.MotorMaxTorque = 1000000
                        elseif d:IsA("Motor6D") then
                            d.MaxVelocity = 1
                        elseif d:IsA("BasePart") and string.find(string.lower(d.Name), "wheel") then
                            d.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5, 1, 1)
                        end
                    end
                end)
                if not ok then
                    warn("[PaintPlus] Loi AutoTravel: " .. tostring(err))
                end
            end)
            RegisterConnection(AutoTravelConnection)
            SafeNotify("Auto Travel", "Đã bật tàu tự chạy, tàu sẽ chạy tối đa tốc độ ngay", 3)
        else
            StopAutoTravelTrain()
            SafeNotify("Auto Travel", "Đã tắt tàu tự chạy", 3)
        end
    end
})

local FlyTrainSection = SafeSection(Tabs.Train, "Bay Về Tàu")

local function StopFlyTrain()
    FeatureStates.FlyTrain = false
    if FlyTrainThread then
        pcall(function()
            task.cancel(FlyTrainThread)
        end)
        FlyTrainThread = nil
    end
    if FlyTrainSeat then
        pcall(function()
            FlyTrainSeat:Destroy()
        end)
        FlyTrainSeat = nil
    end
end

SafeToggle(FlyTrainSection, {
    Title = "Fly Train",
    Desc = "Bay về tàu, giới hạn 8000 studs",
    Value = false,
    Callback = function(state)
        if state then
            local seat = GetTargetSeat()
            if not seat then
                SafeNotify("Fly Train", "Chưa lưu vị trí ghế", 3)
                FeatureStates.FlyTrain = false
                return
            end
            local char = LocalPlayer.Character
            if not char then
                SafeNotify("Fly Train", "Không tìm thấy nhân vật", 3)
                FeatureStates.FlyTrain = false
                return
            end
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            if not humanoid or not root then
                SafeNotify("Fly Train", "Không tìm thấy nhân vật", 3)
                FeatureStates.FlyTrain = false
                return
            end
            local dist = (root.Position - seat.Position).Magnitude
            if dist > MAX_FLY_TRAIN_DISTANCE then
                SafeNotify("Fly Train", "Tàu ở quá xa (trên 8000 studs)", 3)
                FeatureStates.FlyTrain = false
                return
            end
            FeatureStates.FlyTrain = true
            FlyTrainThread = task.spawn(function()
                local virtualSeat = Instance.new("Part")
                virtualSeat.Name = "PaintPlus_VirtualSeat"
                virtualSeat.Anchored = true
                virtualSeat.CanCollide = false
                virtualSeat.Transparency = 1
                virtualSeat.Size = Vector3.new(1, 1, 1)
                virtualSeat.CFrame = root.CFrame
                virtualSeat.Parent = Workspace
                FlyTrainSeat = virtualSeat
                while FeatureStates.FlyTrain and not IsUnloading do
                    if not char or not char.Parent then break end
                    if not root or not root.Parent then break end
                    if not seat or not seat.Parent then break end
                    local dir = (seat.Position - virtualSeat.Position)
                    local distNow = dir.Magnitude
                    if distNow <= 5 then break end
                    local step = dir.Unit * FlyTrainSpeed * task.wait()
                    virtualSeat.CFrame = CFrame.new(virtualSeat.Position + step)
                    local ok, err = pcall(function()
                        root.CFrame = virtualSeat.CFrame
                        for _, part in ipairs(char:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.AssemblyLinearVelocity = Vector3.zero
                                part.AssemblyAngularVelocity = Vector3.zero
                            end
                        end
                    end)
                    if not ok then
                        warn("[PaintPlus] Loi FlyTrain: " .. tostring(err))
                    end
                end
                if FeatureStates.FlyTrain and not IsUnloading then
                    pcall(function()
                        humanoid.Sit = false
                    end)
                    task.wait(0.1)
                    pcall(function()
                        seat:Sit(humanoid)
                        humanoid.Sit = true
                    end)
                    local lockEnd = tick() + 0.5
                    while tick() < lockEnd do
                        pcall(function()
                            root.CFrame = seat.CFrame
                        end)
                        RunService.Heartbeat:Wait()
                    end
                    pcall(function()
                        virtualSeat:Destroy()
                    end)
                    FlyTrainSeat = nil
                    SafeNotify("Fly Train", "Đã bay về tàu và ngồi vào ghế", 3)
                end
            end)
            SafeNotify("Fly Train", "Đã bật bay về tàu", 3)
        else
            StopFlyTrain()
            local char = LocalPlayer.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                pcall(function()
                    humanoid.Sit = false
                end)
            end
            SafeNotify("Fly Train", "Đã hủy bay về tàu", 3)
        end
    end
})

-- ===== TAB 3 =====
local ScanSection = SafeSection(Tabs.Scan, "Tìm Vật Phẩm Đặc Biệt")

local function StopAutoVampireKnife()
    if VampireKnifeThread then
        pcall(function()
            task.cancel(VampireKnifeThread)
        end)
        VampireKnifeThread = nil
    end
    FeatureStates.ScanVampireKnife = false
end

local VampireToggle
VampireToggle = SafeToggle(ScanSection, {
    Title = "Auto Pick Knife Vampire",
    Desc = "Tìm ID 800 đến 900",
    Value = false,
    Callback = function(state)
        if state then
            if HasVampireKnife() then
                SafeNotify("Auto Pick Knife", "Đã sở hữu vật phẩm đặc biệt", 3)
                FeatureStates.ScanVampireKnife = false
                if VampireToggle and VampireToggle.Set then
                    pcall(function()
                        VampireToggle:Set(false)
                    end)
                end
                return
            end
            FeatureStates.ScanVampireKnife = true
            SafeNotify("Auto Pick Knife", "Đang tìm trong khoảng 800 đến 900", 3)
            VampireKnifeThread = task.spawn(function()
                while FeatureStates.ScanVampireKnife and not IsUnloading do
                    for itemId = 800, 900 do
                        if not FeatureStates.ScanVampireKnife or IsUnloading then break end
                        if Remotes.Pickup then
                            local ok, err = pcall(function()
                                Remotes.Pickup:FireServer(itemId)
                            end)
                            if not ok then
                                warn("[PaintPlus] Loi Pickup Vamp " .. tostring(itemId) .. ": " .. tostring(err))
                            end
                        end
                        task.wait(0.03)
                        if Remotes.Store then
                            local ok, err = pcall(function()
                                Remotes.Store:FireServer(itemId)
                            end)
                            if not ok then
                                warn("[PaintPlus] Loi Store Vamp " .. tostring(itemId) .. ": " .. tostring(err))
                            end
                        end
                        task.wait(0.03)
                        if HasVampireKnife() then
                            SafeNotify("Auto Pick Knife", "Tìm thấy tại ID " .. tostring(itemId), 4)
                            FeatureStates.ScanVampireKnife = false
                            if VampireToggle and VampireToggle.Set then
                                pcall(function()
                                    VampireToggle:Set(false)
                                end)
                            end
                            break
                        end
                    end
                    task.wait(0.5)
                end
            end)
        else
            StopAutoVampireKnife()
            SafeNotify("Auto Pick Knife", "Đã tắt tìm kiếm", 3)
        end
    end
})

local DropSection = SafeSection(Tabs.Scan, "Thả Vật Phẩm")

SafeButton(DropSection, {
    Title = "Thả Toàn Bộ Vật Phẩm",
    Desc = "Thả tất cả tool",
    Callback = function()
        local char = LocalPlayer.Character
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        local count = 0
        local function dropTool(tool)
            if Remotes.DropTool then
                local ok, err = pcall(function()
                    Remotes.DropTool:FireServer(tool)
                end)
                if ok then
                    count = count + 1
                    task.wait(0.05)
                    return
                end
                warn("[PaintPlus] Loi DropTool: " .. tostring(err))
            end
            local itemId = GetItemId(tool)
            if itemId and Remotes.Actionable then
                local ok2, err2 = pcall(function()
                    Remotes.Actionable:FireServer(itemId)
                end)
                if ok2 then
                    count = count + 1
                else
                    warn("[PaintPlus] Loi Actionable Drop: " .. tostring(err2))
                end
            end
            task.wait(0.05)
        end
        if backpack then
            for _, item in ipairs(backpack:GetChildren()) do
                if item:IsA("Tool") then
                    dropTool(item)
                end
            end
        end
        if char then
            for _, item in ipairs(char:GetChildren()) do
                if item:IsA("Tool") then
                    dropTool(item)
                end
            end
        end
        if count == 0 then
            SafeNotify("Thả Vật Phẩm", "Không có vật phẩm nào để thả", 3)
        else
            SafeNotify("Thả Vật Phẩm", "Đã thả " .. tostring(count) .. " vật phẩm", 3)
        end
    end
})

-- ===== TAB 4 =====
local SlxSection = SafeSection(Tabs.Features, "Trình Tải Script Phụ")

local function StopSLX_Lite()
    pcall(function()
        if getgenv().SLX_Unload then
            getgenv().SLX_Unload()
        end
    end)
    local function cleanGui(parent)
        if parent then
            for _, gui in ipairs(parent:GetChildren()) do
                if gui:IsA("ScreenGui") then
                    local n = string.lower(gui.Name)
                    if string.find(n, "slx") or string.find(n, "lite") then
                        pcall(function()
                            gui:Destroy()
                        end)
                    end
                end
            end
        end
    end
    cleanGui(CoreGui)
    cleanGui(LocalPlayer:FindFirstChild("PlayerGui"))
    SLX_Lite_Loaded = false
end

local function LoadSLX_Lite()
    local ok, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/nguyenthienanbinh2012-pixel/SLX_PlusLite/main/slxDeadRailsLite.lua"))()
    end)
    if ok then
        SLX_Lite_Loaded = true
        return true
    end
    warn("[PaintPlus] Loi tai SLX Lite: " .. tostring(err))
    return false
end

SafeToggle(SlxSection, {
    Title = "Menu SLX Lite",
    Desc = "Tải script phụ SLX Lite",
    Value = false,
    Callback = function(state)
        if state then
            if LoadSLX_Lite() then
                SafeNotify("SLX Lite", "Đã tải script phụ", 3)
            else
                SafeNotify("SLX Lite", "Tải script phụ thất bại", 3)
            end
        else
            StopSLX_Lite()
            SafeNotify("SLX Lite", "Đã tắt script phụ", 3)
        end
    end
})

local SpeedSection = SafeSection(Tabs.Features, "Tốc Độ")

local function CleanupFly()
    if FlyConnection then
        pcall(function()
            FlyConnection:Disconnect()
        end)
        FlyConnection = nil
    end
    if FlyVelocity then
        pcall(function()
            FlyVelocity:Destroy()
        end)
        FlyVelocity = nil
    end
end

local function StopVehicleFly()
    FeatureStates.SpeedPlus = false
    CleanupFly()
    if SpeedMonitorThread then
        pcall(function()
            task.cancel(SpeedMonitorThread)
        end)
        SpeedMonitorThread = nil
    end
end

local SpeedToggle
local function MonitorSpeedPlus()
    if SpeedMonitorThread then
        pcall(function()
            task.cancel(SpeedMonitorThread)
        end)
        SpeedMonitorThread = nil
    end
    SpeedMonitorThread = task.spawn(function()
        while FeatureStates.SpeedPlus and not IsUnloading do
            task.wait(0.5)
            local char = LocalPlayer.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if not humanoid or not humanoid.SeatPart then
                FeatureStates.SpeedPlus = false
                if SpeedToggle and SpeedToggle.Set then
                    pcall(function()
                        SpeedToggle:Set(false)
                    end)
                end
                CleanupFly()
                SafeNotify("Speed Plus", "Đã rời khỏi thú cưỡi, tính năng tự tắt", 3)
                break
            end
        end
    end)
end

local function StartVehicleFly()
    CleanupFly()
    local root = FindHorseRoot()
    if not root then return false end
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    local model = root:FindFirstAncestorOfClass("Model")
    if model then
        for _, d in ipairs(model:GetDescendants()) do
            if d:IsA("BodyVelocity") or d:IsA("BodyGyro") or d:IsA("AlignPosition") or d:IsA("AlignOrientation") or d:IsA("LinearVelocity") or d:IsA("AngularVelocity") then
                pcall(function()
                    d:Destroy()
                end)
            end
        end
    end
    pcall(function()
        root.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5, 1, 1)
        root.CanCollide = false
    end)
    local bv = Instance.new("BodyVelocity")
    bv.Name = "PaintPlus_FlyVelocity"
    bv.MaxForce = Vector3.new(100000, 100000, 100000)
    bv.Velocity = Vector3.zero
    bv.P = 1250
    bv.Parent = root
    FlyVelocity = bv
    FlyConnection = RunService.Heartbeat:Connect(function()
        local ok, err = pcall(function()
            if not FeatureStates.SpeedPlus then
                CleanupFly()
                return
            end
            if not root or not root.Parent then
                CleanupFly()
                return
            end
            local moveVec = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec = moveVec + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec = moveVec - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec = moveVec - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec = moveVec + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVec = moveVec + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveVec = moveVec - Vector3.new(0, 1, 0) end
            if moveVec.Magnitude == 0 then
                moveVec = humanoid.MoveDirection
            end
            if moveVec.Magnitude > 0 then
                moveVec = moveVec.Unit
            end
            if FlyVelocity and FlyVelocity.Parent then
                FlyVelocity.Velocity = moveVec * FlySpeed
            end
        end)
        if not ok then
            warn("[PaintPlus] Loi SpeedPlus loop: " .. tostring(err))
        end
    end)
    RegisterConnection(FlyConnection)
    return true
end

SpeedToggle = SafeToggle(SpeedSection, {
    Title = "Speed Plus",
    Desc = "Bay bằng WASD khi ngồi thú cưỡi",
    Value = false,
    Callback = function(state)
        if state then
            local char = LocalPlayer.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if not humanoid or not humanoid.SeatPart then
                SafeNotify("Speed Plus", "Bạn chưa ngồi lên ngựa", 3)
                FeatureStates.SpeedPlus = false
                if SpeedToggle and SpeedToggle.Set then
                    pcall(function()
                        SpeedToggle:Set(false)
                    end)
                end
                return
            end
            FeatureStates.SpeedPlus = true
            if StartVehicleFly() then
                MonitorSpeedPlus()
                SafeNotify("Speed Plus", "Đã bật di chuyển, dùng WASD để bay", 3)
            else
                FeatureStates.SpeedPlus = false
                if SpeedToggle and SpeedToggle.Set then
                    pcall(function()
                        SpeedToggle:Set(false)
                    end)
                end
                SafeNotify("Speed Plus", "Không tìm thấy thú cưỡi để bay", 3)
            end
        else
            CleanupFly()
            FeatureStates.SpeedPlus = false
            SafeNotify("Speed Plus", "Đã tắt di chuyển", 3)
        end
    end
})

SafeInput(SpeedSection, {
    Title = "Tốc Độ Đi Tối Đa",
    Desc = "Nhập tốc độ (tối thiểu 60)",
    Placeholder = "60",
    Value = "60",
    Callback = function(text)
        local num = tonumber(text)
        if not num then
            SafeNotify("Tốc Độ", "Giá trị không hợp lệ", 3)
            return
        end
        if num < 60 then
            SafeNotify("Tốc Độ", "Tốc độ không hợp lệ, tối thiểu 60", 3)
            return
        end
        if num > 1000 then
            FlySpeed = 1000
            SafeNotify("Tốc Độ", "Vượt giới hạn, đã đặt về 1000", 3)
        else
            FlySpeed = num
            SafeNotify("Tốc Độ", "Tốc độ đã đặt: " .. tostring(num), 3)
        end
    end
})

local ViewSection = SafeSection(Tabs.Features, "Góc Nhìn")

local function CleanupThirdPerson()
    if ThirdPersonConnection then
        pcall(function()
            ThirdPersonConnection:Disconnect()
        end)
        ThirdPersonConnection = nil
    end
end

local function ApplyThirdPerson()
    CleanupThirdPerson()
    pcall(function()
        OriginalCameraMaxZoom = LocalPlayer.CameraMaxZoomDistance
        OriginalCameraMinZoom = LocalPlayer.CameraMinZoomDistance
        OriginalCameraMode = LocalPlayer.CameraMode
        OriginalCameraType = Camera.CameraType
        OriginalCameraSubject = Camera.CameraSubject
        OriginalCameraFOV = Camera.FieldOfView
    end)
    pcall(function()
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
        LocalPlayer.CameraMaxZoomDistance = 20
        LocalPlayer.CameraMinZoomDistance = 8
        Camera.CameraType = Enum.CameraType.Custom
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                Camera.CameraSubject = humanoid
            end
        end
    end)
end

local function RemoveThirdPerson()
    CleanupThirdPerson()
    pcall(function()
        if OriginalCameraMaxZoom then
            LocalPlayer.CameraMaxZoomDistance = OriginalCameraMaxZoom
        end
        if OriginalCameraMinZoom then
            LocalPlayer.CameraMinZoomDistance = OriginalCameraMinZoom
        end
        if OriginalCameraMode then
            LocalPlayer.CameraMode = OriginalCameraMode
        end
        if OriginalCameraType then
            Camera.CameraType = OriginalCameraType
        end
        if OriginalCameraSubject then
            Camera.CameraSubject = OriginalCameraSubject
        end
        if OriginalCameraFOV then
            Camera.FieldOfView = OriginalCameraFOV
        end
    end)
end

SafeToggle(ViewSection, {
    Title = "Third Person",
    Desc = "Góc nhìn thứ ba",
    Value = false,
    Callback = function(state)
        if state then
            FeatureStates.ThirdPerson = true
            local ok, err = pcall(ApplyThirdPerson)
            if not ok then
                warn("[PaintPlus] Loi ThirdPerson: " .. tostring(err))
            end
            SafeNotify("Third Person", "Đã bật góc nhìn thứ ba", 3)
        else
            FeatureStates.ThirdPerson = false
            local ok, err = pcall(RemoveThirdPerson)
            if not ok then
                warn("[PaintPlus] Loi RemoveThirdPerson: " .. tostring(err))
            end
            SafeNotify("Third Person", "Đã tắt góc nhìn thứ ba", 3)
        end
    end
})

local UtilSection = SafeSection(Tabs.Features, "Tiện Ích")

local function StopBypassPromitixy()
    if BypassConnection then
        pcall(function()
            task.cancel(BypassConnection)
        end)
        BypassConnection = nil
    end
    FeatureStates.BypassPromitixy = false
end

SafeToggle(UtilSection, {
    Title = "Bypass Promitixy",
    Desc = "Ẩn thông báo proximity",
    Value = false,
    Callback = function(state)
        if state then
            FeatureStates.BypassPromitixy = true
            SafeNotify("Bypass", "Đã bật", 3)
            BypassConnection = task.spawn(function()
                while FeatureStates.BypassPromitixy and not IsUnloading do
                    task.wait(1)
                    local pg = LocalPlayer:FindFirstChild("PlayerGui")
                    if pg then
                        for _, gui in ipairs(pg:GetDescendants()) do
                            if gui:IsA("TextLabel") or gui:IsA("TextButton") then
                                local txt = string.lower(gui.Text or "")
                                if string.find(txt, "proximity") or string.find(txt, "promitixy") or string.find(txt, "during") then
                                    pcall(function()
                                        gui.Visible = false
                                        gui.Enabled = false
                                    end)
                                end
                            end
                        end
                    end
                end
            end)
        else
            StopBypassPromitixy()
            SafeNotify("Bypass", "Đã tắt", 3)
        end
    end
})

local function StopSpeedProximity()
    if SpeedProximityThread then
        pcall(function()
            task.cancel(SpeedProximityThread)
        end)
        SpeedProximityThread = nil
    end
    FeatureStates.SpeedProximity = false
end

SafeToggle(UtilSection, {
    Title = "Speed Proximity",
    Desc = "Tăng tốc độ vật thể gần",
    Value = false,
    Callback = function(state)
        if state then
            FeatureStates.SpeedProximity = true
            SafeNotify("Speed Proximity", "Đã bật", 3)
            SpeedProximityThread = task.spawn(function()
                while FeatureStates.SpeedProximity and not IsUnloading do
                    local descendants = Workspace:GetDescendants()
                    local batch = {}
                    for i, d in ipairs(descendants) do
                        table.insert(batch, d)
                        if #batch >= 100 then
                            for _, item in ipairs(batch) do
                                local ok, err = pcall(function()
                                    if item:IsA("HingeConstraint") then
                                        if item.AngularVelocity < 5000 then
                                            item.AngularVelocity = item.AngularVelocity * 3
                                        end
                                    elseif item:IsA("Motor6D") then
                                        item.C0 = item.C0 * CFrame.Angles(0, math.rad(3), 0)
                                    elseif item:IsA("BasePart") then
                                        local n = string.lower(item.Name)
                                        if string.find(n, "gear") or string.find(n, "wheel") then
                                            if item.AssemblyAngularVelocity.Magnitude < 500 then
                                                item.AssemblyAngularVelocity = item.AssemblyAngularVelocity * 3
                                            end
                                        end
                                    end
                                end)
                                if not ok then
                                    warn("[PaintPlus] Loi SpeedProximity: " .. tostring(err))
                                end
                            end
                            batch = {}
                            task.wait(0.02)
                        end
                    end
                    if #batch > 0 then
                        for _, item in ipairs(batch) do
                            local ok, err = pcall(function()
                                if item:IsA("HingeConstraint") then
                                    if item.AngularVelocity < 5000 then
                                        item.AngularVelocity = item.AngularVelocity * 3
                                    end
                                elseif item:IsA("Motor6D") then
                                    item.C0 = item.C0 * CFrame.Angles(0, math.rad(3), 0)
                                elseif item:IsA("BasePart") then
                                    local n = string.lower(item.Name)
                                    if string.find(n, "gear") or string.find(n, "wheel") then
                                        if item.AssemblyAngularVelocity.Magnitude < 500 then
                                            item.AssemblyAngularVelocity = item.AssemblyAngularVelocity * 3
                                        end
                                    end
                                end
                            end)
                            if not ok then
                                warn("[PaintPlus] Loi SpeedProximity: " .. tostring(err))
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        else
            StopSpeedProximity()
            SafeNotify("Speed Proximity", "Đã tắt", 3)
        end
    end
})

-- ===== TAB 5 VISUAL =====
local VisualSection = SafeSection(Tabs.Visual, "ESP Horse")

local function CleanupEspHorseRim()
    FeatureStates.EspHorseRim = false
    if EspHorseRimThread then
        pcall(function()
            task.cancel(EspHorseRimThread)
        end)
        EspHorseRimThread = nil
    end
    if EspHorseFolder then
        pcall(function()
            EspHorseFolder:Destroy()
        end)
        EspHorseFolder = nil
    end
end

local function CreateEspHorseRim(target)
    if not EspHorseFolder then
        EspHorseFolder = Instance.new("Folder")
        EspHorseFolder.Name = "PaintPlus_EspHorse"
        EspHorseFolder.Parent = CoreGui
    end
    local highlight = Instance.new("Highlight")
    highlight.Name = "PaintPlus_RimHorse"
    highlight.Adornee = target
    highlight.FillTransparency = 1
    highlight.OutlineColor = EspHorseColor
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = EspHorseFolder
    return highlight
end

local function StartEspHorseRim()
    CleanupEspHorseRim()
    FeatureStates.EspHorseRim = true
    EspHorseRimThread = task.spawn(function()
        local trackedTargets = {}
        while FeatureStates.EspHorseRim and not IsUnloading do
            pcall(function()
                local char = LocalPlayer.Character
                local myRoot = char and char:FindFirstChild("HumanoidRootPart")
                if not myRoot then
                    task.wait(0.5)
                    return
                end
                local myPos = myRoot.Position
                local currentTargets = {}
                local descendants = Workspace:GetDescendants()
                local batch = {}
                for i, obj in ipairs(descendants) do
                    table.insert(batch, obj)
                    if #batch >= 100 then
                        for _, item in ipairs(batch) do
                            local isTarget = false
                            local targetObj = item
                            if item:IsA("Model") then
                                local n = string.lower(item.Name)
                                if string.find(n, "horse") then
                                    isTarget = true
                                end
                            elseif item:IsA("Humanoid") then
                                local n = string.lower(item.Name)
                                local parent = item.Parent
                                if string.find(n, "horse") or (parent and string.find(string.lower(parent.Name), "horse")) then
                                    isTarget = true
                                    targetObj = parent
                                end
                            end
                            if isTarget and targetObj and targetObj.Parent then
                                local targetRoot = targetObj:FindFirstChild("HumanoidRootPart") or targetObj:FindFirstChild("RootPart") or targetObj.PrimaryPart
                                if targetRoot and targetRoot:IsA("BasePart") then
                                    local d = (targetRoot.Position - myPos).Magnitude
                                    if d <= EspHorseRange then
                                        currentTargets[targetObj] = true
                                        if not trackedTargets[targetObj] then
                                            trackedTargets[targetObj] = CreateEspHorseRim(targetObj)
                                        end
                                    end
                                end
                            end
                        end
                        batch = {}
                        task.wait(0.01)
                    end
                end
                for target, hl in pairs(trackedTargets) do
                    if not currentTargets[target] or not target.Parent then
                        pcall(function()
                            hl:Destroy()
                        end)
                        trackedTargets[target] = nil
                    end
                end
            end)
            task.wait(0.3)
        end
    end)
end

SafeToggle(VisualSection, {
    Title = "Esp Horse [Rim]",
    Desc = "Vẽ viền xanh lam lên ngựa trong 5000 studs",
    Value = false,
    Callback = function(state)
        if state then
            StartEspHorseRim()
            SafeNotify("Esp Horse", "Đã bật viền ngựa trong 5000 studs", 3)
        else
            CleanupEspHorseRim()
            SafeNotify("Esp Horse", "Đã tắt viền ngựa", 3)
        end
    end
})

SafeButton(VisualSection, {
    Title = "Chọn Rim Blue",
    Desc = "Đổi màu viền ngựa thành xanh lam",
    Callback = function()
        EspHorseColor = Color3.fromHex("00BFFF")
        SafeNotify("Esp Horse", "Đã chọn màu viền xanh lam", 3)
    end
})

local function CleanupEspHorseBox()
    FeatureStates.EspHorseBox = false
    if EspHorseBoxThread then
        pcall(function()
            task.cancel(EspHorseBoxThread)
        end)
        EspHorseBoxThread = nil
    end
    if EspBoxFolder then
        pcall(function()
            EspBoxFolder:Destroy()
        end)
        EspBoxFolder = nil
    end
    if EspBillboardFolder then
        pcall(function()
            EspBillboardFolder:Destroy()
        end)
        EspBillboardFolder = nil
    end
end

local function CreateBox(target)
    if not EspBoxFolder then
        EspBoxFolder = Instance.new("Folder")
        EspBoxFolder.Name = "PaintPlus_EspBox"
        EspBoxFolder.Parent = CoreGui
    end
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "PaintPlus_BoxHorse"
    box.Adornee = target
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Size = target:GetExtentsSize()
    box.Color3 = EspHorseColor
    box.Transparency = 0.5
    box.Parent = EspBoxFolder
    return box
end

local function CreateNameTag(target)
    if not EspBillboardFolder then
        EspBillboardFolder = Instance.new("Folder")
        EspBillboardFolder.Name = "PaintPlus_EspName"
        EspBillboardFolder.Parent = CoreGui
    end
    local head = target:FindFirstChild("Head") or target:FindFirstChildWhichIsA("BasePart")
    if not head then return nil end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PaintPlus_NameHorse"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = EspBillboardFolder
    local label = Instance.new("TextLabel")
    label.Name = "LabelName"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = target.Name
    label.TextColor3 = EspHorseColor
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard
    return billboard
end

local function StartEspHorseBox()
    CleanupEspHorseBox()
    FeatureStates.EspHorseBox = true
    EspHorseBoxThread = task.spawn(function()
        local trackedBoxes = {}
        local trackedNames = {}
        while FeatureStates.EspHorseBox and not IsUnloading do
            pcall(function()
                local char = LocalPlayer.Character
                local myRoot = char and char:FindFirstChild("HumanoidRootPart")
                if not myRoot then
                    task.wait(0.5)
                    return
                end
                local myPos = myRoot.Position
                local currentTargets = {}
                local descendants = Workspace:GetDescendants()
                local batch = {}
                for i, obj in ipairs(descendants) do
                    table.insert(batch, obj)
                    if #batch >= 100 then
                        for _, item in ipairs(batch) do
                            local isTarget = false
                            local targetObj = item
                            if item:IsA("Model") then
                                local n = string.lower(item.Name)
                                if string.find(n, "horse") then
                                    isTarget = true
                                end
                            elseif item:IsA("Humanoid") then
                                local n = string.lower(item.Name)
                                local parent = item.Parent
                                if string.find(n, "horse") or (parent and string.find(string.lower(parent.Name), "horse")) then
                                    isTarget = true
                                    targetObj = parent
                                end
                            end
                            if isTarget and targetObj and targetObj.Parent then
                                local targetRoot = targetObj:FindFirstChild("HumanoidRootPart") or targetObj:FindFirstChild("RootPart") or targetObj.PrimaryPart
                                if targetRoot and targetRoot:IsA("BasePart") then
                                    local d = (targetRoot.Position - myPos).Magnitude
                                    if d <= EspHorseBoxRange then
                                        currentTargets[targetObj] = true
                                        if not trackedBoxes[targetObj] or not trackedBoxes[targetObj].Parent then
                                            trackedBoxes[targetObj] = CreateBox(targetObj)
                                        else
                                            pcall(function()
                                                trackedBoxes[targetObj].Size = targetObj:GetExtentsSize()
                                                trackedBoxes[targetObj].Color3 = EspHorseColor
                                            end)
                                        end
                                        if not trackedNames[targetObj] or not trackedNames[targetObj].Parent then
                                            trackedNames[targetObj] = CreateNameTag(targetObj)
                                        end
                                    end
                                end
                            end
                        end
                        batch = {}
                        task.wait(0.01)
                    end
                end
                for target, box in pairs(trackedBoxes) do
                    if not currentTargets[target] or not target.Parent then
                        pcall(function()
                            box:Destroy()
                        end)
                        trackedBoxes[target] = nil
                    end
                end
                for target, nameGui in pairs(trackedNames) do
                    if not currentTargets[target] or not target.Parent then
                        pcall(function()
                            if nameGui then
                                nameGui:Destroy()
                            end
                        end)
                        trackedNames[target] = nil
                    end
                end
            end)
            task.wait(0.3)
        end
    end)
end

SafeToggle(VisualSection, {
    Title = "Esp Horse [Box + Name]",
    Desc = "Vẽ hộp 3D và tên lên ngựa trong 7000 studs",
    Value = false,
    Callback = function(state)
        if state then
            StartEspHorseBox()
            SafeNotify("Esp Horse", "Đã bật hộp và tên ngựa trong 7000 studs", 3)
        else
            CleanupEspHorseBox()
            SafeNotify("Esp Horse", "Đã tắt hộp và tên ngựa", 3)
        end
    end
})

local EspNpcSection = SafeSection(Tabs.Visual, "ESP NPC")

local function CleanupEspNpc()
    FeatureStates.EspNpc = false
    if EspNpcThread then
        pcall(function()
            task.cancel(EspNpcThread)
        end)
        EspNpcThread = nil
    end
    if EspNpcFolder then
        pcall(function()
            EspNpcFolder:Destroy()
        end)
        EspNpcFolder = nil
    end
end

local function IsNpcCandidate(obj)
    if not obj or not obj.Parent then return false end
    if not obj:IsA("Model") then return false end
    if obj == LocalPlayer.Character then return false end
    local humanoid = obj:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    local owner = Players:GetPlayerFromCharacter(obj)
    if owner then return false end
    local root = obj:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    return true
end

local function CreateEspNpcRim(target)
    if not EspNpcFolder then
        EspNpcFolder = Instance.new("Folder")
        EspNpcFolder.Name = "PaintPlus_EspNpc"
        EspNpcFolder.Parent = CoreGui
    end
    local highlight = Instance.new("Highlight")
    highlight.Name = "PaintPlus_RimNpc"
    highlight.Adornee = target
    highlight.FillTransparency = 1
    highlight.OutlineColor = EspNpcColor
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = EspNpcFolder
    return highlight
end

local function StartEspNpc()
    CleanupEspNpc()
    FeatureStates.EspNpc = true
    EspNpcThread = task.spawn(function()
        local trackedTargets = {}
        while FeatureStates.EspNpc and not IsUnloading do
            pcall(function()
                local char = LocalPlayer.Character
                local myRoot = char and char:FindFirstChild("HumanoidRootPart")
                if not myRoot then
                    task.wait(0.5)
                    return
                end
                local myPos = myRoot.Position
                local currentTargets = {}
                local descendants = Workspace:GetDescendants()
                local batch = {}
                for i, obj in ipairs(descendants) do
                    table.insert(batch, obj)
                    if #batch >= 80 then
                        for _, item in ipairs(batch) do
                            if IsNpcCandidate(item) then
                                local root = item:FindFirstChild("HumanoidRootPart")
                                if root then
                                    local d = (root.Position - myPos).Magnitude
                                    if d <= EspNpcRange then
                                        currentTargets[item] = true
                                        if not trackedTargets[item] then
                                            trackedTargets[item] = CreateEspNpcRim(item)
                                        end
                                    end
                                end
                            end
                        end
                        batch = {}
                        task.wait(0.01)
                    end
                end
                for target, hl in pairs(trackedTargets) do
                    if not currentTargets[target] or not target.Parent then
                        pcall(function()
                            hl:Destroy()
                        end)
                        trackedTargets[target] = nil
                    end
                end
            end)
            task.wait(0.4)
        end
    end)
end

SafeToggle(EspNpcSection, {
    Title = "Esp Npc",
    Desc = "Vẽ viền xanh lá lên NPC xung quanh 500 studs",
    Value = false,
    Callback = function(state)
        if state then
            StartEspNpc()
            SafeNotify("Esp Npc", "Đã bật viền NPC xanh lá trong 500 studs", 3)
        else
            CleanupEspNpc()
            SafeNotify("Esp Npc", "Đã tắt viền NPC", 3)
        end
    end
})

-- ===== TAB 6 =====
local StatsSection = SafeSection(Tabs.Stats, "Chỉ Số Nhân Vật")

local function ApplyHighJump()
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        SafeNotify("Nhảy Cao", "Không tìm thấy nhân vật", 3)
        return false
    end
    if not OriginalJumpPower then
        OriginalJumpPower = humanoid.JumpPower
        OriginalJumpHeight = humanoid.JumpHeight
        OriginalUseJumpPower = humanoid.UseJumpPower
    end
    humanoid.UseJumpPower = true
    humanoid.JumpPower = 100
    humanoid.JumpHeight = 14
    return true
end

local function RemoveHighJump()
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if OriginalJumpPower then
            humanoid.JumpPower = OriginalJumpPower
        end
        if OriginalJumpHeight then
            humanoid.JumpHeight = OriginalJumpHeight
        end
        if OriginalUseJumpPower ~= nil then
            humanoid.UseJumpPower = OriginalUseJumpPower
        end
    end
end

local HighJumpToggle
HighJumpToggle = SafeToggle(StatsSection, {
    Title = "Nhảy Cao Hơn",
    Desc = "Tăng lực nhảy",
    Value = false,
    Callback = function(state)
        if state then
            FeatureStates.HighJump = true
            if not ApplyHighJump() then
                FeatureStates.HighJump = false
                if HighJumpToggle and HighJumpToggle.Set then
                    pcall(function()
                        HighJumpToggle:Set(false)
                    end)
                end
                return
            end
            SafeNotify("Nhảy Cao", "Đã bật nhảy cao hơn", 3)
        else
            FeatureStates.HighJump = false
            RemoveHighJump()
            SafeNotify("Nhảy Cao", "Đã tắt nhảy cao hơn", 3)
        end
    end
})

local function ApplyNoClip()
    if NoClipConnection then return end
    NoClipConnection = task.spawn(function()
        while FeatureStates.NoClip and not IsUnloading do
            task.wait(0.1)
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        pcall(function()
                            part.CanCollide = false
                        end)
                    end
                end
            end
        end
    end)
end

local function RemoveNoClip()
    if NoClipConnection then
        pcall(function()
            task.cancel(NoClipConnection)
        end)
        NoClipConnection = nil
    end
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function()
                    part.CanCollide = true
                end)
            end
        end
    end
end

SafeToggle(StatsSection, {
    Title = "No Clips",
    Desc = "Đi xuyên vật thể",
    Value = false,
    Callback = function(state)
        if state then
            FeatureStates.NoClip = true
            ApplyNoClip()
            SafeNotify("No Clips", "Đã bật đi xuyên vật thể", 3)
        else
            FeatureStates.NoClip = false
            RemoveNoClip()
            SafeNotify("No Clips", "Đã tắt đi xuyên vật thể", 3)
        end
    end
})

-- ===== TAB 7 =====
local InfoSection = SafeSection(Tabs.Info, "Thông Tin Script")

local executorName = "Unknown"
pcall(function()
    if identifyexecutor then
        executorName = identifyexecutor()
    end
end)

SafeParagraph(InfoSection, {
    Title = "Paint Plus v2.4",
    Desc = "Tác giả: by SharkTeam Mobile\nTrình thực thi: " .. tostring(executorName) .. "\nKết nối: Shared.Universe.Network.RemoteEvent"
})

local ManageSection = SafeSection(Tabs.Info, "Quản Lý")

local function FullUnload()
    IsUnloading = true
    pcall(function()
        StopPickupAll()
    end)
    pcall(function()
        StopAutoVampireKnife()
    end)
    pcall(function()
        StopVehicleFly()
    end)
    pcall(function()
        StopFlyTrain()
    end)
    pcall(function()
        RemoveThirdPerson()
    end)
    pcall(function()
        StopBypassPromitixy()
    end)
    pcall(function()
        StopSpeedProximity()
    end)
    pcall(function()
        StopAutoTravelTrain()
    end)
    pcall(function()
        RemoveNoClip()
    end)
    pcall(function()
        CleanupEspHorseRim()
    end)
    pcall(function()
        CleanupEspHorseBox()
    end)
    pcall(function()
        CleanupEspNpc()
    end)
    TrainTeleport.IsTeleporting = false
    DisconnectAllConnections()
    getgenv().PaintPlus_Loaded = nil
    getgenv().PaintPlus_Unload = nil
    SafeNotify("Paint Plus", "Đã xóa menu", 3)
    pcall(function()
        Window:Destroy()
    end)
    local function clean(parent, keywords)
        if parent then
            for _, gui in ipairs(parent:GetChildren()) do
                if gui:IsA("ScreenGui") then
                    local n = string.lower(gui.Name)
                    for _, k in ipairs(keywords) do
                        if string.find(n, k) then
                            pcall(function()
                                gui:Destroy()
                            end)
                            break
                        end
                    end
                end
            end
        end
    end
    clean(CoreGui, {"windui", "rayfield", "paintplus"})
    clean(LocalPlayer:FindFirstChild("PlayerGui"), {"windui", "rayfield"})
end

SafeButton(ManageSection, {
    Title = "Xóa Menu",
    Desc = "Tắt và xóa toàn bộ menu",
    Callback = function()
        FullUnload()
    end
})

getgenv().PaintPlus_Unload = function()
    IsUnloading = true
    DisconnectAllConnections()
    StopVehicleFly()
    StopFlyTrain()
    RemoveThirdPerson()
    StopBypassPromitixy()
    StopSpeedProximity()
    StopAutoTravelTrain()
    RemoveNoClip()
    CleanupEspHorseRim()
    CleanupEspHorseBox()
    CleanupEspNpc()
    TrainTeleport.IsTeleporting = false
end

local function SetupDeathCleanup(character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    if not humanoid then return end
    local conn = humanoid.Died:Connect(function()
        FeatureStates.PickupAll = false
        FeatureStates.ScanVampireKnife = false
        FeatureStates.SpeedPlus = false
        FeatureStates.ThirdPerson = false
        FeatureStates.BypassPromitixy = false
        FeatureStates.SpeedProximity = false
        FeatureStates.AutoTravelTrain = false
        FeatureStates.FlyTrain = false
        FeatureStates.HighJump = false
        FeatureStates.NoClip = false
        StopFlyTrain()
        StopVehicleFly()
        StopBypassPromitixy()
        StopSpeedProximity()
        StopAutoTravelTrain()
        RemoveNoClip()
        RemoveThirdPerson()
        TrainTeleport.IsTeleporting = false
    end)
    RegisterConnection(conn)
end

if LocalPlayer.Character then
    SetupDeathCleanup(LocalPlayer.Character)
end

local charAddedConn = LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(1)
    SetupDeathCleanup(character)
    if FeatureStates.ThirdPerson then
        pcall(function()
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
            LocalPlayer.CameraMaxZoomDistance = 20
            LocalPlayer.CameraMinZoomDistance = 8
            Camera.CameraType = Enum.CameraType.Custom
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                Camera.CameraSubject = humanoid
            end
        end)
    end
    if FeatureStates.HighJump then
        pcall(ApplyHighJump)
    end
    if FeatureStates.NoClip then
        pcall(ApplyNoClip)
    end
    if FeatureStates.SpeedPlus then
        FeatureStates.SpeedPlus = false
        if SpeedToggle and SpeedToggle.Set then
            pcall(function()
                SpeedToggle:Set(false)
            end)
        end
    end
end)
RegisterConnection(charAddedConn)

task.spawn(function()
    task.wait(1)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local center = root.Position
    local descendants = Workspace:GetDescendants()
    local batch = {}
    for i, part in ipairs(descendants) do
        table.insert(batch, part)
        if #batch >= 200 then
            for _, p in ipairs(batch) do
                local ok, err = pcall(function()
                    if p:IsA("BasePart") then
                        if (p.Position - center).Magnitude <= 20000 and p.Transparency ~= 1 then
                            p.LocalTransparencyModifier = 0
                        end
                    end
                end)
                if not ok then
                    warn("[PaintPlus] Loi load area: " .. tostring(err))
                end
            end
            batch = {}
            task.wait(0.01)
        end
    end
    if #batch > 0 then
        for _, p in ipairs(batch) do
            local ok, err = pcall(function()
                if p:IsA("BasePart") then
                    if (p.Position - center).Magnitude <= 20000 and p.Transparency ~= 1 then
                        p.LocalTransparencyModifier = 0
                    end
                end
            end)
            if not ok then
                warn("[PaintPlus] Loi load area: " .. tostring(err))
            end
        end
    end
end)

task.spawn(function()
    task.wait(0.5)
    local count = 0
    if Remotes.Pickup then count = count + 1 end
    if Remotes.Store then count = count + 1 end
    if Remotes.Actionable then count = count + 1 end
    if Remotes.DropTool then count = count + 1 end
    SafeNotify("Paint Plus v2.4", "Đã tải " .. tostring(count) .. "/4 kết nối", 5)
    print("[PaintPlus] Đã tải " .. tostring(count) .. "/4 kết nối")
end)
