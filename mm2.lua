-- Melony Scripts | MM2 Ultimate (FIXED ESP)
-- Creator: Melony

local p, plr = game:GetService("Players"), game:GetService("Players").LocalPlayer
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local userInput = game:GetService("UserInputService")

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
    smoothness = 0.3
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

-- Функция получения головы или торса
local function getAttachmentPoint(character)
    if character:FindFirstChild("Head") then
        return character.Head
    elseif character:FindFirstChild("UpperTorso") then
        return character.UpperTorso
    elseif character:FindFirstChild("Torso") then
        return character.Torso
    end
    return character:FindFirstChildWhichIsA("BasePart")
end

-- СОЗДАНИЕ ESP (исправленное)
local function createESP(player)
    if not player.Character or player == plr then return end
    if espObjects[player] then return end
    
    local role = getRoleByWeapon(player)
    local character = player.Character
    
    -- Highlight (подсветка)
    local highlight = Instance.new("Highlight")
    highlight.FillColor = colors[role]
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0.2
    highlight.Parent = character
    
    -- BillboardGui для имени (прикрепляем к голове)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "MelonyESP"
    billboard.Size = UDim2.new(0, 200, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 150
    billboard.Adornee = getAttachmentPoint(character) -- Прикрепляем к голове/торсу
    billboard.Parent = character
    
    -- Текст
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = player.Name .. " [" .. role .. "]"
    textLabel.TextColor3 = colors[role]
    textLabel.TextStrokeTransparency = 0.3
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = billboard
    
    espObjects[player] = {
        highlight = highlight,
        billboard = billboard,
        role = role
    }
end

-- Обновление ESP
local function updateESP(player)
    if not espObjects[player] then return end
    local newRole = getRoleByWeapon(player)
    if espObjects[player].role ~= newRole then
        espObjects[player].role = newRole
        if espObjects[player].highlight then
            espObjects[player].highlight.FillColor = colors[newRole]
        end
        if espObjects[player].billboard then
            local text = espObjects[player].billboard:FindFirstChildOfClass("TextLabel")
            if text then
                text.Text = player.Name .. " [" .. newRole .. "]"
                text.TextColor3 = colors[newRole]
            end
        end
    end
    -- Обновляем Adornee если персонаж изменился
    if espObjects[player].billboard and player.Character then
        local attach = getAttachmentPoint(player.Character)
        if attach then
            espObjects[player].billboard.Adornee = attach
        end
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
        if player ~= plr then
            if player.Character then
                createESP(player)
            end
            player.CharacterAdded:Connect(function(char)
                task.wait(0.5)
                if settings.esp then
                    createESP(player)
                end
            end)
        end
    end
end

-- AIMBOT + TRIGGERBOT
local function getTarget()
    if not settings.aimbot and not settings.triggerbot then return nil end
    local closest, closestDist = nil, math.huge
    for _, v in ipairs(p:GetPlayers()) do
        if v ~= plr and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local role = getRoleByWeapon(v)
            if settings.targetMode == "All" or (settings.targetMode == "Murderer" and role == "Murderer") or (settings.targetMode == "Sheriff" and role == "Sheriff") then
                local headPos = v.Character.Head.Position
                local screenPos, onScreen = camera:WorldToViewportPoint(headPos)
                local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                local dist = (screenCenter - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
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
    if target and target.Character and target.Character:FindFirstChild("Head") then
        local headPos = target.Character.Head.Position
        local cf = CFrame.new(camera.CFrame.Position, headPos)
        camera.CFrame = camera.CFrame:Lerp(cf, settings.smoothness)
    end
end

-- Создание меню
local function createMenu()
    pcall(function() if gui then gui:Destroy() end end)
    
    gui = Instance.new("ScreenGui")
    gui.Name = "Melony"
    gui.Parent = plr:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false
    if gui.IgnoreGuiInset then gui.IgnoreGuiInset = true end
    
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 280, 0, 280)
    f.Position = UDim2.new(0.5, -140, 0.5, -140)
    f.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    f.BackgroundTransparency = 0.1
    f.Active = true
    f.Draggable = true
    f.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = f
    
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
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    
    closeBtn.MouseButton1Click:Connect(function()
        pcall(function() if gui then gui:Destroy(); gui = nil end end)
    end)
    
    -- Кнопки
    local yPos = 60
    local function createButton(name, setting, y)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 220, 0, 40)
        btn.Position = UDim2.new(0.5, -110, 0, y)
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
            if setting == "esp" then
                if settings.esp then setupESP() else clearESP() end
            end
        end)
        return btn
    end
    
    createButton("ESP", "esp", yPos)
    createButton("AimBot", "aimbot", yPos + 50)
    createButton("TriggerBot", "triggerbot", yPos + 100)
    
    -- Выбор цели
    local targetBtn = Instance.new("TextButton")
    targetBtn.Size = UDim2.new(0, 220, 0, 40)
    targetBtn.Position = UDim2.new(0.5, -110, 0, yPos + 150)
    targetBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    targetBtn.Text = "🎯 Target: " .. settings.targetMode
    targetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetBtn.TextSize = 16
    targetBtn.Font = Enum.Font.GothamBold
    targetBtn.Parent = f
    Instance.new("UICorner", targetBtn).CornerRadius = UDim.new(0, 10)
    
    targetBtn.MouseButton1Click:Connect(function()
        local modes = {"All", "Murderer", "Sheriff"}
        local idx = table.find(modes, settings.targetMode) or 1
        idx = idx % #modes + 1
        settings.targetMode = modes[idx]
        targetBtn.Text = "🎯 Target: " .. settings.targetMode
    end)
    
    local footer = Instance.new("TextLabel")
    footer.Size = UDim2.new(1, 0, 0, 25)
    footer.Position = UDim2.new(0, 0, 1, -28)
    footer.BackgroundTransparency = 1
    footer.Text = "Melony Scripts | by Melony"
    footer.TextColor3 = Color3.fromRGB(100, 100, 120)
    footer.TextSize = 11
    footer.Font = Enum.Font.Gotham
    footer.Parent = f
end

-- Отслеживание смены оружия
for _, player in ipairs(p:GetPlayers()) do
    if player ~= plr then
        player.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            if espObjects[player] then updateESP(player) end
            local function onTool(child)
                if child:IsA("Tool") then
                    task.wait(0.2)
                    updateESP(player)
                end
            end
            char.ChildAdded:Connect(onTool)
            char.ChildRemoved:Connect(onTool)
        end)
    end
end

p.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if settings.esp then createESP(player) end
    end)
end)

-- Основной цикл
runService.RenderStepped:Connect(function()
    if settings.esp then
        for _, v in ipairs(p:GetPlayers()) do
            if v ~= plr and v.Character then
                if not espObjects[v] then
                    createESP(v)
                else
                    updateESP(v)
                end
            end
        end
    elseif not settings.esp and next(espObjects) then
        clearESP()
    end
    aimbot()
    triggerbot()
end)

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
setupESP()

print("✅ Melony Scripts Loaded | ESP Fixed")
print("⌨️ Press Right Shift to toggle menu")
print("🔪 Murderer = Red | 👮 Sheriff = Blue | 😇 Innocent = Green")
