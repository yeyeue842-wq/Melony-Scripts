-- Melony Scripts | TSB (Real Invisible - No Death)
-- Creator: Melony

local p, plr = game:GetService("Players"), game:GetService("Players").LocalPlayer
local runService = game:GetService("RunService")
local userInput = game:GetService("UserInputService")
local camera = workspace.CurrentCamera

local gui = nil
local espObjects = {}
local originalSizes = {}
local invisibleActive = false

-- Настройки
local settings = {
    invisible = false,
    speed = false,
    superJump = false,
    fly = false,
    esp = false,
    speedValue = 50,
    jumpPower = 80
}

-- РЕАЛЬНАЯ НЕВИДИМОСТЬ (уменьшаем размер, делаем прозрачным, отключаем столкновения)
local function setInvisible(enabled)
    local char = plr.Character
    if not char then return end
    
    if enabled then
        invisibleActive = true
        -- Сохраняем оригинальные размеры и делаем всё маленьким
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                originalSizes[part] = part.Size
                part.Size = Vector3.new(0.1, 0.1, 0.1)
                part.Transparency = 1
                part.CanCollide = false
            end
        end
        -- Отключаем человеческую модель (чтобы не было тени)
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.BlockOffset = Vector3.new(0, 0, 0)
        end
    else
        invisibleActive = false
        -- Восстанавливаем размеры
        for part, size in pairs(originalSizes) do
            if part and part.Parent then
                part.Size = size
                part.Transparency = 0
                part.CanCollide = true
            end
        end
        originalSizes = {}
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.BlockOffset = nil
        end
    end
end

-- СКОРОСТЬ
local function setSpeed(enabled)
    local char = plr.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = enabled and settings.speedValue or 16
    end
end

-- СУПЕР ПРЫЖОК
local function setSuperJump(enabled)
    local char = plr.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.JumpPower = enabled and settings.jumpPower or 50
    end
end

-- ПОЛЁТ
local flying = false
local flyBodyVelocity = nil
local flyBodyGyro = nil

local function startFly()
    flying = true
    local char = plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.PlatformStand = true
    end
    
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    flyBodyVelocity.Parent = hrp
    
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
    flyBodyGyro.Parent = hrp
    
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
            moveDir = moveDir.Unit * 100
        end
        flyBodyVelocity.Velocity = moveDir
        
        local camCF = camera.CFrame
        flyBodyGyro.CFrame = camCF
    end
    
    runService.RenderStepped:Connect(updateFly)
end

local function stopFly()
    flying = false
    if flyBodyVelocity then flyBodyVelocity:Destroy() end
    if flyBodyGyro then flyBodyGyro:Destroy() end
    flyBodyVelocity = nil
    flyBodyGyro = nil
    
    local char = plr.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
end

-- ESP для других игроков
local function createESP(player)
    if not player.Character or player == plr or not settings.esp then return end
    if espObjects[player] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 70, 70)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.4
    highlight.Parent = player.Character
    
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 120, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = player.Character
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = player.Name
    text.TextColor3 = Color3.fromRGB(255, 100, 100)
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

local function setupESP()
    clearESP()
    for _, player in ipairs(p:GetPlayers()) do
        if player ~= plr and player.Character then
            createESP(player)
        end
    end
end

-- Обработка смены персонажа
plr.CharacterAdded:Connect(function(char)
    task.wait(1)
    setSpeed(settings.speed)
    setSuperJump(settings.superJump)
    if settings.fly then startFly() else stopFly() end
    if settings.invisible then setInvisible(true) end
    
    if settings.esp then
        for _, player in ipairs(p:GetPlayers()) do
            if player ~= plr and player.Character then
                createESP(player)
            end
        end
    end
end)

-- Отслеживание новых игроков
p.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if settings.esp and player ~= plr then
            createESP(player)
        end
    end)
end)

-- Основной цикл для ESP
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

-- МЕНЮ
local function createMenu()
    pcall(function() if gui then gui:Destroy() end end)
    
    gui = Instance.new("ScreenGui")
    gui.Name = "Melony"
    gui.Parent = plr:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false
    
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 280, 0, 320)
    f.Position = UDim2.new(0.5, -140, 0.5, -160)
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
    titleText.Text = "👻 Melony | TSB"
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
    
    local yPos = 50
    local function createButton(name, setting, y, onToggle)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 240, 0, 40)
        btn.Position = UDim2.new(0.5, -120, 0, y)
        btn.BackgroundColor3 = settings[setting] and Color3.fromRGB(80, 160, 80) or Color3.fromRGB(45, 45, 55)
        btn.Text = name .. ": " .. (settings[setting] and "ON" or "OFF")
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 16
        btn.Font = Enum.Font.GothamBold
        btn.Parent = f
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
        
        btn.MouseButton1Click:Connect(function()
            settings[setting] = not settings[setting]
            btn.Text = name .. ": " .. (settings[setting] and "ON" or "OFF")
            btn.BackgroundColor3 = settings[setting] and Color3.fromRGB(80, 160, 80) or Color3.fromRGB(45, 45, 55)
            if setting == "invisible" then setInvisible(settings.invisible) end
            if setting == "speed" then setSpeed(settings.speed) end
            if setting == "superJump" then setSuperJump(settings.superJump) end
            if setting == "fly" then
                if settings.fly then startFly() else stopFly() end
            end
            if setting == "esp" then
                if settings.esp then setupESP() else clearESP() end
            end
        end)
    end
    
    createButton("👻 Invisible (Real)", "invisible", yPos)
    createButton("⚡ Speed", "speed", yPos + 48)
    createButton("🦘 Super Jump", "superJump", yPos + 96)
    createButton("✈️ Fly", "fly", yPos + 144)
    createButton("👁️ ESP", "esp", yPos + 192)
    
    -- Ползунок скорости
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(0, 100, 0, 25)
    speedLabel.Position = UDim2.new(0.5, -120, 0, yPos + 248)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Speed: " .. settings.speedValue
    speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    speedLabel.TextSize = 12
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.Parent = f
    
    local speedSlider = Instance.new("TextButton")
    speedSlider.Size = UDim2.new(0, 100, 0, 20)
    speedSlider.Position = UDim2.new(0.5, 0, 0, yPos + 248)
    speedSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    speedSlider.Text = ""
    speedSlider.Parent = f
    Instance.new("UICorner", speedSlider).CornerRadius = UDim.new(0, 10)
    
    local speedFill = Instance.new("Frame")
    speedFill.Size = UDim2.new((settings.speedValue - 16) / 84, 0, 1, 0)
    speedFill.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    speedFill.Parent = speedSlider
    Instance.new("UICorner", speedFill).CornerRadius = UDim.new(0, 10)
    
    speedSlider.MouseButton1Click:Connect(function()
        settings.speedValue = math.clamp(settings.speedValue + 10, 16, 100)
        if settings.speedValue > 100 then settings.speedValue = 16 end
        speedLabel.Text = "Speed: " .. settings.speedValue
        speedFill.Size = UDim2.new((settings.speedValue - 16) / 84, 0, 1, 0)
        setSpeed(settings.speed)
    end)
    
    -- Ползунок силы прыжка
    local jumpLabel = Instance.new("TextLabel")
    jumpLabel.Size = UDim2.new(0, 100, 0, 25)
    jumpLabel.Position = UDim2.new(0.5, 10, 0, yPos + 248)
    jumpLabel.BackgroundTransparency = 1
    jumpLabel.Text = "Jump: " .. settings.jumpPower
    jumpLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    jumpLabel.TextSize = 12
    jumpLabel.Font = Enum.Font.Gotham
    jumpLabel.Parent = f
    
    local jumpSlider = Instance.new("TextButton")
    jumpSlider.Size = UDim2.new(0, 100, 0, 20)
    jumpSlider.Position = UDim2.new(0.5, 130, 0, yPos + 248)
    jumpSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    jumpSlider.Text = ""
    jumpSlider.Parent = f
    Instance.new("UICorner", jumpSlider).CornerRadius = UDim.new(0, 10)
    
    local jumpFill = Instance.new("Frame")
    jumpFill.Size = UDim2.new((settings.jumpPower - 40) / 60, 0, 1, 0)
    jumpFill.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    jumpFill.Parent = jumpSlider
    Instance.new("UICorner", jumpFill).CornerRadius = UDim.new(0, 10)
    
    jumpSlider.MouseButton1Click:Connect(function()
        settings.jumpPower = math.clamp(settings.jumpPower + 10, 40, 100)
        if settings.jumpPower > 100 then settings.jumpPower = 40 end
        jumpLabel.Text = "Jump: " .. settings.jumpPower
        jumpFill.Size = UDim2.new((settings.jumpPower - 40) / 60, 0, 1, 0)
        setSuperJump(settings.superJump)
    end)
end

-- Горячая клавиша
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
setSpeed(settings.speed)
setSuperJump(settings.superJump)

print("✅ Melony Scripts | TSB Real Invisible (No Death)")
print("👻 Invisible: your character becomes tiny and transparent")
print("⚡ Speed | 🦘 Super Jump | ✈️ Fly")
print("⌨️ Press Right Shift to open menu")
