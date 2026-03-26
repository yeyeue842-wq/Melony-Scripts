-- Melony Scripts | Steal a Brainrot Edition
-- Creator: Melony
-- Features: Super Jump, Speed, Fly, ESP (опционально)

local p, plr = game:GetService("Players"), game:GetService("Players").LocalPlayer
local userInput = game:GetService("UserInputService")
local runService = game:GetService("RunService")

local gui = nil
local espObjects = {}

-- Настройки
local settings = {
    superJump = true,
    speed = true,
    fly = false,
    esp = false,
    jumpPower = 80,      -- Сила прыжка (обычно 50)
    walkSpeed = 50       -- Скорость бега (обычно 16)
}

-- СУПЕР ПРЫЖОК
local function setupSuperJump()
    local humanoid = plr.Character and plr.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.JumpPower = settings.superJump and settings.jumpPower or 50
    end
end

-- СКОРОСТЬ
local function setupSpeed()
    local humanoid = plr.Character and plr.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = settings.speed and settings.walkSpeed or 16
    end
end

-- ПОЛЁТ (простой)
local flying = false
local flyBodyVelocity = nil

local function startFly()
    flying = true
    local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
    flyBodyVelocity.Parent = hrp
    
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(10000, 10000, 10000)
    bodyGyro.Parent = hrp
    
    local function updateFly()
        if not flying or not plr.Character then return end
        local moveDir = Vector3.new()
        if userInput:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Vector3.new(0, 0, -1) end
        if userInput:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir + Vector3.new(0, 0, 1) end
        if userInput:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir + Vector3.new(-1, 0, 0) end
        if userInput:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Vector3.new(1, 0, 0) end
        if userInput:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if userInput:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir + Vector3.new(0, -1, 0) end
        
        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit * 80
        end
        flyBodyVelocity.Velocity = moveDir
        
        local camCF = workspace.CurrentCamera.CFrame
        bodyGyro.CFrame = camCF
    end
    
    runService.RenderStepped:Connect(updateFly)
end

local function stopFly()
    flying = false
    if flyBodyVelocity then flyBodyVelocity:Destroy() end
    flyBodyVelocity = nil
end

-- ESP (простой, если нужен)
local function createESP(player)
    if not player.Character or player == plr or not settings.esp then return end
    if espObjects[player] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 100, 50)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.Parent = player.Character
    
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 120, 0, 25)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = player.Character
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = player.Name
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold
    text.Parent = billboard
    
    espObjects[player] = {highlight = highlight, billboard = billboard}
end

local function clearESP()
    for _, obj in pairs(espObjects) do
        pcall(function()
            if obj.highlight then obj.highlight:Destroy() end
            if obj.billboard then obj.billboard:Destroy() end
        end)
    end
    espObjects = {}
end

-- Обработка смены персонажа (для прыжка и скорости)
plr.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    setupSuperJump()
    setupSpeed()
    if settings.fly then startFly() else stopFly() end
    
    if settings.esp then
        for _, player in ipairs(p:GetPlayers()) do
            if player ~= plr and player.Character then
                createESP(player)
            end
        end
    end
end)

-- Отслеживание новых игроков для ESP
if settings.esp then
    p.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            if settings.esp and player ~= plr then
                createESP(player)
            end
        end)
    end)
end

-- МЕНЮ
local function createMenu()
    pcall(function() if gui then gui:Destroy() end end)
    
    gui = Instance.new("ScreenGui")
    gui.Name = "Melony"
    gui.Parent = plr:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false
    
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 260, 0, 240)
    f.Position = UDim2.new(0.5, -130, 0.5, -120)
    f.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    f.Active = true
    f.Draggable = true
    f.Parent = gui
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)
    
    -- Заголовок
    local title = Instance.new("Frame")
    title.Size = UDim2.new(1, 0, 0, 45)
    title.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    title.Parent = f
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -60, 1, 0)
    titleText.Position = UDim2.new(0, 15, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "🧠 Melony | Brainrot"
    titleText.TextColor3 = Color3.fromRGB(255, 150, 100)
    titleText.TextSize = 18
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Font = Enum.Font.GothamBold
    titleText.Parent = title
    
    -- Кнопка закрытия
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -40, 0, 6)
    closeBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = title
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    closeBtn.MouseButton1Click:Connect(function()
        pcall(function() if gui then gui:Destroy(); gui = nil end end)
    end)
    
    -- Кнопки
    local yPos = 55
    local function createButton(name, setting, y, onToggle)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 220, 0, 38)
        btn.Position = UDim2.new(0.5, -110, 0, y)
        btn.BackgroundColor3 = settings[setting] and Color3.fromRGB(80, 160, 80) or Color3.fromRGB(45, 45, 55)
        btn.Text = name .. ": " .. (settings[setting] and "ON" or "OFF")
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 15
        btn.Font = Enum.Font.GothamBold
        btn.Parent = f
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
        
        btn.MouseButton1Click:Connect(function()
            settings[setting] = not settings[setting]
            btn.Text = name .. ": " .. (settings[setting] and "ON" or "OFF")
            btn.BackgroundColor3 = settings[setting] and Color3.fromRGB(80, 160, 80) or Color3.fromRGB(45, 45, 55)
            if onToggle then onToggle() end
            if setting == "superJump" then setupSuperJump() end
            if setting == "speed" then setupSpeed() end
            if setting == "fly" then
                if settings.fly then startFly() else stopFly() end
            end
            if setting == "esp" then
                if settings.esp then
                    setupESP()
                else
                    clearESP()
                end
            end
        end)
    end
    
    createButton("🦘 Super Jump", "superJump", yPos)
    createButton("⚡ Speed", "speed", yPos + 48)
    createButton("✈️ Fly", "fly", yPos + 96)
    createButton("👁️ ESP", "esp", yPos + 144)
    
    -- Ползунок силы прыжка
    local jumpLabel = Instance.new("TextLabel")
    jumpLabel.Size = UDim2.new(0, 100, 0, 25)
    jumpLabel.Position = UDim2.new(0.5, -110, 0, yPos + 188)
    jumpLabel.BackgroundTransparency = 1
    jumpLabel.Text = "Jump Power: " .. settings.jumpPower
    jumpLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    jumpLabel.TextSize = 12
    jumpLabel.Font = Enum.Font.Gotham
    jumpLabel.Parent = f
    
    local jumpSlider = Instance.new("TextButton")
    jumpSlider.Size = UDim2.new(0, 100, 0, 20)
    jumpSlider.Position = UDim2.new(0.5, 0, 0, yPos + 188)
    jumpSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    jumpSlider.Text = ""
    jumpSlider.Parent = f
    Instance.new("UICorner", jumpSlider).CornerRadius = UDim.new(0, 10)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((settings.jumpPower - 40) / 60, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    fill.Parent = jumpSlider
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 10)
    
    jumpSlider.MouseButton1Click:Connect(function()
        settings.jumpPower = math.clamp(settings.jumpPower + 10, 40, 100)
        if settings.jumpPower > 100 then settings.jumpPower = 40 end
        jumpLabel.Text = "Jump Power: " .. settings.jumpPower
        fill.Size = UDim2.new((settings.jumpPower - 40) / 60, 0, 1, 0)
        setupSuperJump()
    end)
end

-- Настройка ESP
local function setupESP()
    clearESP()
    for _, player in ipairs(p:GetPlayers()) do
        if player ~= plr and player.Character then
            createESP(player)
        end
    end
end

-- Основной цикл для обновления ESP
runService.RenderStepped:Connect(function()
    if settings.esp then
        for _, v in ipairs(p:GetPlayers()) do
            if v ~= plr and v.Character then
                if not espObjects[v] then
                    createESP(v)
                end
            end
        end
    end
end)

-- Горячая клавиша (Right Shift)
userInput.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        if gui then
            pcall(function() gui:Destroy() end)
            gui = nil
        else
            createMenu()
        end
    end
end)

-- Запуск
createMenu()
setupSuperJump()
setupSpeed()

print("✅ Melony Scripts | Steal a Brainrot Edition")
print("🦘 Super Jump ON | ⚡ Speed ON")
print("⌨️ Press Right Shift to open menu")
