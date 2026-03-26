-- Melony Scripts | MM2 Ultimate (Universal Edition)
-- Creator: Melony
-- Works on: XENO, Delta, SKIBX, Synapse, Krnl, ScriptWare, and more

local p, plr = game:GetService("Players"), game:GetService("Players").LocalPlayer
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local userInput = game:GetService("UserInputService")
local httpService = game:GetService("HttpService")

-- Автоопределение инжектора и платформы
local isMobile = userInput.TouchEnabled
local isPC = not isMobile

-- Безопасное создаление GUI (работает на всех инжекторах)
local function createScreenGui(name)
    local success, gui = pcall(function()
        local newGui = Instance.new("ScreenGui")
        newGui.Name = name
        newGui.Parent = plr:WaitForChild("PlayerGui")
        newGui.ResetOnSpawn = false
        if newGui.IgnoreGuiInset then newGui.IgnoreGuiInset = true end
        if newGui.DisplayOrder then newGui.DisplayOrder = 999 end
        return newGui
    end)
    if success then return gui end
    return nil
end

local gui = nil
local icon = nil
local espObjects = {}
local playerRoles = {}

-- Настройки
local settings = {
    esp = true,
    aimbot = true,
    triggerbot = true,
    targetMode = "All",
    smoothness = 0.3,
    aimPart = "Head"
}

-- Функция определения роли
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

-- ESP функции
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
        if player ~= plr and player.Character then createESP(player) end
        player.CharacterAdded:Connect(function() task.wait(0.3); if settings.esp then createESP(player) end end)
    end
end

-- Создание иконки (универсальная)
local function createFloatingIcon()
    pcall(function() if icon then icon:Destroy() end end)
    
    local success, newIcon = pcall(function()
        local i = Instance.new("ScreenGui")
        i.Name = "MelonyIcon"
        i.Parent = plr:WaitForChild("PlayerGui")
        i.ResetOnSpawn = false
        if i.IgnoreGuiInset then i.IgnoreGuiInset = true end
        if i.DisplayOrder then i.DisplayOrder = 999 end
        return i
    end)
    if not success then return end
    icon = newIcon
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 150, 0, 40)
    btn.Position = UDim2.new(0.8, 0, 0.85, 0)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    btn.BackgroundTransparency = 0.1
    btn.Text = "🍒 Melony Cheats"
    btn.TextColor3 = Color3.fromRGB(255, 120, 160)
    btn.TextSize = 16
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = true
    btn.Parent = icon
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 25)
    corner.Parent = btn
    
    -- Перетаскивание (для ПК и мобильных)
    local dragging = false
    local dragStart, startPos
    
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = btn.Position
        end
    end)
    
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    userInput.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    btn.MouseButton1Click:Connect(function()
        pcall(function()
            if icon then icon:Destroy(); icon = nil end
            createMenu()
        end)
    end)
    
    -- Для мобильных (touch)
    btn.TouchTap:Connect(function()
        pcall(function()
            if icon then icon:Destroy(); icon = nil end
            createMenu()
        end)
    end)
end

-- Создание меню
local function createMenu()
    pcall(function() if gui then gui:Destroy() end end)
    
    local success, newGui = pcall(function()
        local g = Instance.new("ScreenGui")
        g.Name = "Melony"
        g.Parent = plr:WaitForChild("PlayerGui")
        g.ResetOnSpawn = false
        if g.IgnoreGuiInset then g.IgnoreGuiInset = true end
        return g
    end)
    if not success then return end
    gui = newGui
    
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 280, 0, 320)
    f.Position = UDim2.new(0.5, -140, 0.5, -160)
    f.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    f.BackgroundTransparency = 0.05
    f.Active = true
    f.Draggable = true
    f.Parent = gui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = f
    
    -- Заголовок
    local title = Instance.new("Frame")
    title.Size = UDim2.new(1, 0, 0, 45)
    title.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    title.BackgroundTransparency = 0.2
    title.Parent = f
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = title
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -60, 1, 0)
    titleText.Position = UDim2.new(0, 15, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "🍒 Melony Cheats"
    titleText.TextColor3 = Color3.fromRGB(255, 120, 160)
    titleText.TextSize = 20
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
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        pcall(function() if gui then gui:Destroy(); gui = nil end end)
        createFloatingIcon()
    end)
    
    -- Кнопки настроек
    local buttons = {
        {name = "ESP", setting = "esp", y = 60},
        {name = "AimBot", setting = "aimbot", y = 110},
        {name = "TriggerBot", setting = "triggerbot", y = 160},
        {name = "Target: " .. settings.targetMode, setting = "target", y = 210, isTarget = true}
    }
    
    for _, btnData in ipairs(buttons) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 220, 0, 42)
        btn.Position = UDim2.new(0.5, -110, 0, btnData.y)
        btn.BackgroundColor3 = (not btnData.isTarget and settings[btnData.setting]) and Color3.fromRGB(80, 160, 80) or Color3.fromRGB(45, 45, 55)
        btn.Text = btnData.isTarget and ("🎯 " .. settings.targetMode) or (btnData.name .. ": " .. (settings[btnData.setting] and "ON" or "OFF"))
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 16
        btn.Font = Enum.Font.GothamBold
        btn.Parent = f
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 10)
        btnCorner.Parent = btn
        
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
                btn.BackgroundColor3 = settings[btnData.setting] and Color3.fromRGB(80, 160, 80) or Color3.fromRGB(45, 45, 55)
                if btnData.setting == "esp" then
                    if settings.esp then setupESP() else clearESP() end
                end
            end
        end)
    end
    
    local footer = Instance.new("TextLabel")
    footer.Size = UDim2.new(1, 0, 0, 28)
    footer.Position = UDim2.new(0, 0, 1, -32)
    footer.BackgroundTransparency = 1
    footer.Text = "Melony Scripts | by Melony"
    footer.TextColor3 = Color3.fromRGB(100, 100, 120)
    footer.TextSize = 11
    footer.Font = Enum.Font.Gotham
    footer.Parent = f
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
                local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                local dist = (screenCenter - Vector2.new(pos.X, pos.Y)).Magnitude
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
        if tool then pcall(function() tool:Activate() end) end
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

-- Отслеживание игроков
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

-- Горячая клавиша / жест
userInput.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift or (isMobile and input.KeyCode == Enum.KeyCode.LeftControl) then
        pcall(function()
            if icon then icon:Destroy(); icon = nil end
            if gui then gui:Destroy(); gui = nil end
            createMenu()
        end)
    end
end)

-- Запуск
createMenu()
if settings.esp then setupESP() end

print("✅ Melony Scripts Loaded | Universal Edition")
print("📱 Platform: " .. (isMobile and "Mobile (SKIBX/Delta)" or "PC (XENO/Synapse)"))
print("⌨️ Press Right Shift (PC) or hold on screen (Mobile) to open menu")
