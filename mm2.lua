-- Melony Scripts | MM2 Ultimate
-- Creator: Melony
-- Features: ESP + Role Memory + AimBot + TriggerBot + Floating Icon

local p, plr = game:GetService("Players"), game:GetService("Players").LocalPlayer
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local mouse = plr:GetMouse()
local userInput = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")

local gui = nil
local icon = nil
local espObjects = {}
local playerRoles = {}
local isMenuOpen = true

-- Настройки
local settings = {
    esp = true,
    aimbot = true,
    triggerbot = true,
    targetMode = "All",
    smoothness = 0.3,
    aimPart = "Head"
}

-- Функция определения роли с запоминанием
local function getRoleByWeapon(player)
    if not player.Character then 
        return playerRoles[player] or "Innocent"
    end
    
    local tool = player.Character:FindFirstChildOfClass("Tool")
    if tool then
        local toolName = tool.Name:lower()
        if toolName:find("knife") or toolName:find("dagger") or toolName:find("blade") or toolName:find("sword") then
            playerRoles[player] = "Murderer"
            return "Murderer"
        end
        if toolName:find("gun") or toolName:find("pistol") or toolName:find("revolver") then
            playerRoles[player] = "Sheriff"
            return "Sheriff"
        end
    end
    
    for _, v in ipairs(player.Character:GetChildren()) do
        if v:IsA("Accessory") or v:IsA("Tool") then
            local name = v.Name:lower()
            if name:find("knife") or name:find("blade") then
                playerRoles[player] = "Murderer"
                return "Murderer"
            end
            if name:find("gun") or name:find("pistol") then
                playerRoles[player] = "Sheriff"
                return "Sheriff"
            end
        end
    end
    
    if playerRoles[player] then
        return playerRoles[player]
    end
    return "Innocent"
end

local colors = {
    Murderer = Color3.fromRGB(255, 50, 50),
    Sheriff = Color3.fromRGB(50, 100, 255),
    Innocent = Color3.fromRGB(100, 255, 100)
}

-- ESP функции (как в предыдущей версии)
local function createESP(player)
    if not player.Character or player == plr then return end
    if espObjects[player] then return end
    local role = getRoleByWeapon(player)
    local highlight = Instance.new("Highlight")
    highlight.FillColor = colors[role]
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.Parent = player.Character
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 160, 0, 32)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = player.Character
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = player.Name .. " [" .. role .. "]"
    textLabel.TextColor3 = colors[role]
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = billboard
    local weaponIcon = Instance.new("TextLabel")
    weaponIcon.Size = UDim2.new(0, 25, 1, 0)
    weaponIcon.Position = UDim2.new(1, 5, 0, 0)
    weaponIcon.BackgroundTransparency = 1
    weaponIcon.Text = role == "Murderer" and "🔪" or (role == "Sheriff" and "🔫" or "🛡️")
    weaponIcon.TextColor3 = colors[role]
    weaponIcon.TextSize = 20
    weaponIcon.Parent = billboard
    espObjects[player] = {highlight = highlight, billboard = billboard, role = role}
end

local function updateESP(player)
    if not espObjects[player] then return end
    local newRole = getRoleByWeapon(player)
    if espObjects[player].role ~= newRole then
        espObjects[player].role = newRole
        espObjects[player].highlight.FillColor = colors[newRole]
        local text = espObjects[player].billboard:FindFirstChildOfClass("TextLabel")
        if text then text.Text = player.Name .. " [" .. newRole .. "]"; text.TextColor3 = colors[newRole] end
        local iconText = espObjects[player].billboard:FindFirstChildOfClass("TextLabel")
        if iconText and iconText ~= text then iconText.Text = newRole == "Murderer" and "🔪" or (newRole == "Sheriff" and "🔫" or "🛡️") end
    end
end

local function clearESP()
    for _, obj in pairs(espObjects) do
        if obj.highlight then obj.highlight:Destroy() end
        if obj.billboard then obj.billboard:Destroy() end
    end
    espObjects = {}
end

local function setupESP()
    clearESP()
    for _, player in ipairs(p:GetPlayers()) do
        if player ~= plr and player.Character then createESP(player) end
        player.CharacterAdded:Connect(function() task.wait(0.3); createESP(player) end)
    end
end

-- Создание плавающей иконки Melony Cheats
local function createFloatingIcon()
    if icon then icon:Destroy() end
    icon = Instance.new("ScreenGui", plr:WaitForChild("PlayerGui"))
    icon.Name = "MelonyIcon"
    icon.DisplayOrder = 999
    icon.IgnoreGuiInset = true
    
    local iconButton = Instance.new("ImageButton", icon)
    iconButton.Size = UDim2.new(0, 50, 0, 50)
    iconButton.Position = UDim2.new(0.85, 0, 0.85, 0)
    iconButton.BackgroundColor3 = Color3.fromRGB(255, 100, 150)
    iconButton.BackgroundTransparency = 0
    iconButton.Image = "rbxassetid://0" -- пустая, используем фон
    iconButton.AutoButtonColor = true
    Instance.new("UICorner", iconButton).CornerRadius = UDim.new(1, 0) -- круглый
    
    -- Анимация свечения
    local glow = Instance.new("Frame", iconButton)
    glow.Size = UDim2.new(1.2, 0, 1.2, 0)
    glow.Position = UDim2.new(-0.1, 0, -0.1, 0)
    glow.BackgroundColor3 = Color3.fromRGB(255, 100, 150)
    glow.BackgroundTransparency = 0.7
    glow.BorderSizePixel = 0
    Instance.new("UICorner", glow).CornerRadius = UDim.new(1, 0)
    
    -- Текст "MC" внутри
    local text = Instance.new("TextLabel", iconButton)
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = "🍒"
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextSize = 28
    text.Font = Enum.Font.GothamBold
    
    -- Анимация пульсации
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    local tween = tweenService:Create(glow, tweenInfo, {BackgroundTransparency = 0.4})
    tween:Play()
    
    -- Перетаскивание иконки
    local dragging = false
    local dragStart, startPos
    iconButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = iconButton.Position
        end
    end)
    iconButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    userInput.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            iconButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Открытие меню по клику
    iconButton.MouseButton1Click:Connect(function()
        createMenu()
        icon:Destroy()
        icon = nil
        isMenuOpen = true
    end)
end

-- Создание основного меню
local function createMenu()
    if gui then gui:Destroy() end
    gui = Instance.new("ScreenGui", plr:WaitForChild("PlayerGui"))
    gui.Name = "Melony"
    
    local f = Instance.new("Frame", gui)
    f.Size = UDim2.new(0, 260, 0, 280)
    f.Position = UDim2.new(0.5, -130, 0.5, -140)
    f.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    f.Active = true
    f.Draggable = true
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
    
    -- Заголовок
    local title = Instance.new("Frame", f)
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)
    
    local titleText = Instance.new("TextLabel", title)
    titleText.Size = UDim2.new(1, 0, 1, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "🍒 Melony Cheats"
    titleText.TextColor3 = Color3.fromRGB(255, 100, 150)
    titleText.TextScaled = true
    titleText.Font = Enum.Font.GothamBold
    
    -- Кнопка закрытия (крестик)
    local closeBtn = Instance.new("TextButton", title)
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
        gui = nil
        isMenuOpen = false
        createFloatingIcon() -- Создаём плавающую иконку
    end)
    
    -- Кнопки настроек
    local buttons = {
        {name = "ESP", setting = "esp", y = 55},
        {name = "AimBot", setting = "aimbot", y = 100},
        {name = "TriggerBot", setting = "triggerbot", y = 145},
        {name = "Target: " .. settings.targetMode, setting = "target", y = 190, isTarget = true}
    }
    
    for _, btnData in ipairs(buttons) do
        local btn = Instance.new("TextButton", f)
        btn.Size = UDim2.new(0, 200, 0, 38)
        btn.Position = UDim2.new(0.5, -100, 0, btnData.y)
        btn.BackgroundColor3 = (not btnData.isTarget and settings[btnData.setting]) and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(60, 60, 70)
        btn.Text = btnData.isTarget and ("🎯 " .. settings.targetMode) or (btnData.name .. ": " .. (settings[btnData.setting] and "ON" or "OFF"))
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 16
        btn.Font = Enum.Font.GothamBold
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        
        btn.MouseButton1Click:Connect(function()
            if btnData.isTarget then
                local modes = {"All", "Murderer", "Sheriff"}
                local idx = table.find(modes, settings.targetMode) or 1
                idx = idx % #modes + 1
                settings.targetMode = modes[idx]
                btn.Text = "🎯 " .. settings.targetMode
            else
                settings[btnData.setting] = not settings[btnData.setting]
                btn.Text = btnData.name .. ": " .. (settings[btnData.setting] and "ON" or "OFF")
                btn.BackgroundColor3 = settings[btnData.setting] and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(60, 60, 70)
                if btnData.setting == "esp" then
                    if settings.esp then setupESP() else clearESP() end
                end
            end
        end)
    end
    
    -- Подпись
    local footer = Instance.new("TextLabel", f)
    footer.Size = UDim2.new(1, 0, 0, 25)
    footer.Position = UDim2.new(0, 0, 1, -30)
    footer.BackgroundTransparency = 1
    footer.Text = "Melony Scripts | by Melony"
    footer.TextColor3 = Color3.fromRGB(150, 150, 150)
    footer.TextSize = 12
    footer.Font = Enum.Font.Gotham
end

-- AIMBOT + TRIGGERBOT
local function getTarget()
    if not settings.aimbot and not settings.triggerbot then return nil end
    local closest, closestDist = nil, math.huge
    for _, v in ipairs(p:GetPlayers()) do
        if v ~= plr and v.Character and v.Character:FindFirstChild(settings.aimPart) and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local role = getRoleByWeapon(v)
            if settings.targetMode == "All" or (settings.targetMode == "Murderer" and role == "Murderer") or (settings.targetMode == "Sheriff" and role == "Sheriff") then
                local pos, onScreen = camera:WorldToViewportPoint(v.Character[settings.aimPart].Position)
                local dist = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                if onScreen and dist < closestDist then
                    closestDist, closest = dist, v
                end
            end
        end
    end
    return closest
end

local function triggerbot()
    if not settings.triggerbot then return end
    local target = getTarget()
    if target then
        local tool = plr.Character:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end
end

local function aimbot()
    if not settings.aimbot then return end
    local target = getTarget()
    if target and target.Character and target.Character:FindFirstChild(settings.aimPart) then
        local targetPos = target.Character[settings.aimPart].Position
        local cf = CFrame.new(camera.CFrame.Position, targetPos)
        camera.CFrame = camera.CFrame:Lerp(cf, settings.smoothness)
    end
end

-- Отслеживание смены оружия
for _, player in ipairs(p:GetPlayers()) do
    if player ~= plr then
        player.CharacterAdded:Connect(function(char)
            task.wait(0.3)
            if espObjects[player] then updateESP(player) end
            local function onTool(child) if child:IsA("Tool") then updateESP(player) end end
            char.ChildAdded:Connect(onTool)
            char.ChildRemoved:Connect(onTool)
        end)
    end
end

p.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function() task.wait(0.3); if settings.esp then createESP(player) end end)
end)

-- Основной цикл
runService.RenderStepped:Connect(function()
    if settings.esp then
        for _, v in ipairs(p:GetPlayers()) do
            if v ~= plr and v.Character then
                if not espObjects[v] then createESP(v) else updateESP(v) end
            end
        end
    elseif not settings.esp and next(espObjects) then
        clearESP()
    end
    aimbot()
    triggerbot()
end)

-- Right Shift также открывает меню
userInput.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if not gui or not gui.Parent then
            if icon then icon:Destroy(); icon = nil end
            createMenu()
            isMenuOpen = true
        end
    end
end)

-- Запуск
createMenu()
if settings.esp then setupESP() end
print("🍒 Melony Scripts Ultimate Loaded | ESP + AimBot + TriggerBot | Click X to see floating icon")
