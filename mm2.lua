-- Melony Scripts | MM2 Ultimate (Dropped Gun ESP)
-- Creator: Melony

local p, plr = game:GetService("Players"), game:GetService("Players").LocalPlayer
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local userInput = game:GetService("UserInputService")
local mouse = plr:GetMouse()

local gui = nil
local espObjects = {}
local gunEspObjects = {}
local playerRoles = {}

-- Настройки
local settings = {
    esp = true,
    gunEsp = true,      -- ESP на выпавший пистолет
    aimbot = true,
    triggerbot = true,
    targetMode = "All",
    smoothness = 0.3,
    aimPart = "Head",
    fov = 150
}

-- ОПРЕДЕЛЕНИЕ РОЛИ
local function detectRoleByWeapon(player)
    if not player.Character then return nil end
    local tool = player.Character:FindFirstChildOfClass("Tool")
    if tool then
        local toolName = tool.Name:lower()
        if toolName:find("knife") or toolName:find("dagger") or toolName:find("blade") or toolName:find("sword") then
            return "Murderer"
        end
        if toolName:find("gun") or toolName:find("pistol") or toolName:find("revolver") then
            return "Sheriff"
        end
    end
    return nil
end

local function getRole(player)
    if playerRoles[player] then return playerRoles[player] end
    local detected = detectRoleByWeapon(player)
    if detected then playerRoles[player] = detected return detected end
    return "Innocent"
end

-- Сброс ролей при новом раунде
local function resetRoles()
    playerRoles = {}
    for _, obj in pairs(espObjects) do
        pcall(function()
            if obj.highlight then obj.highlight:Destroy() end
            if obj.billboard then obj.billboard:Destroy() end
        end)
    end
    espObjects = {}
    for _, player in ipairs(p:GetPlayers()) do
        if player ~= plr and player.Character then createESP(player) end
    end
end

plr.CharacterAdded:Connect(function() task.wait(1); resetRoles(); clearDroppedGuns() end)
for _, player in ipairs(p:GetPlayers()) do
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if player ~= plr then
            playerRoles[player] = nil
            if espObjects[player] then updateESP(player) end
        end
    end)
end

-- Цвета ESP
local colors = {
    Murderer = Color3.fromRGB(255, 50, 50),
    Sheriff = Color3.fromRGB(50, 100, 255),
    Innocent = Color3.fromRGB(100, 255, 100),
    DroppedGun = Color3.fromRGB(255, 200, 50)  -- Золотой
}

-- ESP на игроков
local function getAttachmentPoint(character)
    if character:FindFirstChild("Head") then return character.Head end
    if character:FindFirstChild("UpperTorso") then return character.UpperTorso end
    return character:FindFirstChildWhichIsA("BasePart")
end

local function createESP(player)
    if not player.Character or player == plr then return end
    if espObjects[player] then return end
    local role = getRole(player)
    local character = player.Character
    local color = colors[role]
    local highlight = Instance.new("Highlight")
    highlight.FillColor = color
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.Parent = character
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 180, 0, 35)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = getAttachmentPoint(character)
    billboard.Parent = character
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = player.Name .. " [" .. role .. "]"
    text.TextColor3 = color
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold
    text.Parent = billboard
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 30, 1, 0)
    icon.Position = UDim2.new(1, 5, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = role == "Murderer" and "🔪" or (role == "Sheriff" and "🔫" or "🛡️")
    icon.TextColor3 = color
    icon.TextSize = 20
    icon.Parent = billboard
    espObjects[player] = {highlight = highlight, billboard = billboard, role = role}
end

local function updateESP(player)
    if not espObjects[player] then return end
    local newRole = getRole(player)
    local color = colors[newRole]
    if espObjects[player].role ~= newRole then
        espObjects[player].role = newRole
        espObjects[player].highlight.FillColor = color
        local text = espObjects[player].billboard:FindFirstChildOfClass("TextLabel")
        if text then
            text.Text = player.Name .. " [" .. newRole .. "]"
            text.TextColor3 = color
        end
        for _, child in ipairs(espObjects[player].billboard:GetChildren()) do
            if child:IsA("TextLabel") and child ~= text then
                child.Text = newRole == "Murderer" and "🔪" or (newRole == "Sheriff" and "🔫" or "🛡️")
                child.TextColor3 = color
            end
        end
    end
    if espObjects[player].billboard and player.Character then
        local attach = getAttachmentPoint(player.Character)
        if attach then espObjects[player].billboard.Adornee = attach end
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

-- ========== ОТСЛЕЖИВАНИЕ ВЫПАВШЕГО ПИСТОЛЕТА ==========
-- Проверка, является ли объект активным инструментом (в руках)
local function isActiveTool(obj)
    if not obj or not obj.Parent then return false end
    -- Проверяем, что объект находится в персонаже игрока
    for _, player in ipairs(p:GetPlayers()) do
        if player.Character and obj:IsDescendantOf(player.Character) then
            return true
        end
    end
    return false
end

-- Поиск выпавшего пистолета (не в руках игрока)
local function findDroppedGun()
    for _, v in ipairs(workspace:GetDescendants()) do
        -- Ищем объекты, похожие на пистолет
        if v:IsA("BasePart") or v:IsA("Tool") or v:IsA("Model") then
            local name = v.Name:lower()
            if name:find("gun") or name:find("pistol") or name:find("revolver") then
                -- НЕ показываем, если пистолет в руках игрока
                if not isActiveTool(v) then
                    -- Дополнительно проверяем, что это не часть модели персонажа (пояс)
                    local isOnBelt = false
                    for _, player in ipairs(p:GetPlayers()) do
                        if player.Character and v:IsDescendantOf(player.Character) then
                            -- Если пистолет является частью персонажа (на поясе) и не в руках
                            -- Ищем, есть ли у этого игрока активный инструмент (пистолет в руках)
                            local hasActiveGun = false
                            if player.Character:FindFirstChildOfClass("Tool") then
                                hasActiveGun = true
                            end
                            -- Если у игрока нет активного пистолета в руках, значит это выпавший
                            if not hasActiveGun then
                                isOnBelt = false
                            else
                                isOnBelt = true
                            end
                            break
                        end
                    end
                    if not isOnBelt then
                        return v
                    end
                end
            end
        end
    end
    return nil
end

-- Создание ESP для выпавшего пистолета
local function createDroppedGunESP(gun)
    if gunEspObjects[gun] then return end
    if not gun or not gun.Parent then return end
    
    local highlight = Instance.new("Highlight")
    highlight.FillColor = colors.DroppedGun
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.3
    highlight.Parent = gun
    
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 140, 0, 32)
    billboard.StudsOffset = Vector3.new(0, 1, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = gun
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = "🔫 SHERIFF GUN (DROPPED)"
    text.TextColor3 = colors.DroppedGun
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold
    text.Parent = billboard
    
    gunEspObjects[gun] = {highlight = highlight, billboard = billboard}
end

local function clearDroppedGuns()
    for _, obj in pairs(gunEspObjects) do
        pcall(function()
            if obj.highlight then obj.highlight:Destroy() end
            if obj.billboard then obj.billboard:Destroy() end
        end)
    end
    gunEspObjects = {}
end

local function updateDroppedGunESP()
    if not settings.gunEsp then 
        clearDroppedGuns()
        return 
    end
    
    local gun = findDroppedGun()
    
    -- Удаляем ESP если пистолет исчез или был подобран
    for g, obj in pairs(gunEspObjects) do
        if g ~= gun or not g.Parent then
            pcall(function()
                if obj.highlight then obj.highlight:Destroy() end
                if obj.billboard then obj.billboard:Destroy() end
            end)
            gunEspObjects[g] = nil
        end
    end
    
    -- Создаём ESP для найденного пистолета
    if gun and gun.Parent then
        if not gunEspObjects[gun] then
            createDroppedGunESP(gun)
        end
    end
end

-- ========== AIMBOT + TRIGGERBOT ==========
local function isVisible(targetPart)
    local origin = camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit
    local ray = Ray.new(origin, direction * (targetPart.Position - origin).Magnitude)
    local hit = workspace:FindPartOnRay(ray, plr.Character)
    if hit and hit:IsDescendantOf(targetPart.Parent) then
        return true
    end
    return false
end

local function getTarget()
    local bestTarget = nil
    local bestDist = math.huge
    
    for _, v in ipairs(p:GetPlayers()) do
        if v ~= plr and v.Character and v.Character:FindFirstChild(settings.aimPart) then
            local role = getRole(v)
            if settings.targetMode == "All" or 
               (settings.targetMode == "Murderer" and role == "Murderer") or 
               (settings.targetMode == "Sheriff" and role == "Sheriff") then
                
                local part = v.Character[settings.aimPart]
                local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                
                if onScreen then
                    local dist = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if dist < bestDist and dist < settings.fov then
                        bestDist = dist
                        bestTarget = {player = v, part = part, screenDist = dist}
                    end
                end
            end
        end
    end
    
    return bestTarget
end

local function aimbot()
    if not settings.aimbot then return end
    local target = getTarget()
    if target and target.part and isVisible(target.part) then
        local targetPos = target.part.Position
        local cf = CFrame.new(camera.CFrame.Position, targetPos)
        camera.CFrame = camera.CFrame:Lerp(cf, settings.smoothness)
    end
end

local function triggerbot()
    if not settings.triggerbot then return end
    local target = getTarget()
    if target and target.part and target.screenDist < 30 and isVisible(target.part) then
        local tool = plr.Character:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end
end

-- ========== МЕНЮ ==========
local function createMenu()
    pcall(function() if gui then gui:Destroy() end end)
    
    gui = Instance.new("ScreenGui")
    gui.Name = "Melony"
    gui.Parent = plr:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false
    if gui.IgnoreGuiInset then gui.IgnoreGuiInset = true end
    
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 300, 0, 420)
    f.Position = UDim2.new(0.5, -150, 0.5, -210)
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
    titleText.Text = "Melony Cheats | MM2"
    titleText.TextColor3 = Color3.fromRGB(255, 100, 100)
    titleText.TextSize = 18
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Font = Enum.Font.GothamBold
    titleText.Parent = title
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -40, 0, 6)
    closeBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = title
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    closeBtn.MouseButton1Click:Connect(function()
        pcall(function() if gui then gui:Destroy(); gui = nil end end)
    end)
    
    local y = 55
    local function createButton(name, setting, yPos)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 260, 0, 36)
        btn.Position = UDim2.new(0.5, -130, 0, yPos)
        btn.BackgroundColor3 = settings[setting] and Color3.fromRGB(80, 160, 80) or Color3.fromRGB(45, 45, 55)
        btn.Text = name .. ": " .. (settings[setting] and "ON" or "OFF")
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 14
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
    
    createButton("👁️ ESP Players", "esp", y)
    createButton("🔫 Dropped Gun ESP", "gunEsp", y + 42)
    createButton("🎯 AimBot", "aimbot", y + 84)
    createButton("🔫 TriggerBot", "triggerbot", y + 126)
    
    -- Выбор цели
    local targetBtn = Instance.new("TextButton")
    targetBtn.Size = UDim2.new(0, 260, 0, 36)
    targetBtn.Position = UDim2.new(0.5, -130, 0, y + 168)
    targetBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    targetBtn.Text = "🎯 Target: " .. settings.targetMode
    targetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetBtn.TextSize = 14
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
    
    -- Ползунок FOV
    local fovLabel = Instance.new("TextLabel")
    fovLabel.Size = UDim2.new(0, 80, 0, 25)
    fovLabel.Position = UDim2.new(0.5, -130, 0, y + 212)
    fovLabel.BackgroundTransparency = 1
    fovLabel.Text = "FOV: " .. settings.fov
    fovLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    fovLabel.TextSize = 11
    fovLabel.Font = Enum.Font.Gotham
    fovLabel.Parent = f
    
    local fovSlider = Instance.new("TextButton")
    fovSlider.Size = UDim2.new(0, 120, 0, 18)
    fovSlider.Position = UDim2.new(0.5, -20, 0, y + 213)
    fovSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    fovSlider.Text = ""
    fovSlider.Parent = f
    Instance.new("UICorner", fovSlider).CornerRadius = UDim.new(0, 9)
    local fovFill = Instance.new("Frame")
    fovFill.Size = UDim2.new(settings.fov / 250, 0, 1, 0)
    fovFill.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    fovFill.Parent = fovSlider
    Instance.new("UICorner", fovFill).CornerRadius = UDim.new(0, 9)
    fovSlider.MouseButton1Click:Connect(function()
        settings.fov = math.clamp(settings.fov + 10, 50, 250)
        if settings.fov > 250 then settings.fov = 50 end
        fovLabel.Text = "FOV: " .. settings.fov
        fovFill.Size = UDim2.new(settings.fov / 250, 0, 1, 0)
    end)
    
    -- Ползунок плавности
    local smoothLabel = Instance.new("TextLabel")
    smoothLabel.Size = UDim2.new(0, 80, 0, 25)
    smoothLabel.Position = UDim2.new(0.5, -130, 0, y + 250)
    smoothLabel.BackgroundTransparency = 1
    smoothLabel.Text = "Smooth: " .. math.floor(settings.smoothness * 100)
    smoothLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    smoothLabel.TextSize = 11
    smoothLabel.Font = Enum.Font.Gotham
    smoothLabel.Parent = f
    
    local smoothSlider = Instance.new("TextButton")
    smoothSlider.Size = UDim2.new(0, 120, 0, 18)
    smoothSlider.Position = UDim2.new(0.5, -20, 0, y + 251)
    smoothSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    smoothSlider.Text = ""
    smoothSlider.Parent = f
    Instance.new("UICorner", smoothSlider).CornerRadius = UDim.new(0, 9)
    local smoothFill = Instance.new("Frame")
    smoothFill.Size = UDim2.new(settings.smoothness, 0, 1, 0)
    smoothFill.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    smoothFill.Parent = smoothSlider
    Instance.new("UICorner", smoothFill).CornerRadius = UDim.new(0, 9)
    smoothSlider.MouseButton1Click:Connect(function()
        settings.smoothness = math.clamp(settings.smoothness + 0.05, 0.1, 1)
        if settings.smoothness > 1 then settings.smoothness = 0.1 end
        smoothLabel.Text = "Smooth: " .. math.floor(settings.smoothness * 100)
        smoothFill.Size = UDim2.new(settings.smoothness, 0, 1, 0)
    end)
    
    local footer = Instance.new("TextLabel")
    footer.Size = UDim2.new(1, 0, 0, 28)
    footer.Position = UDim2.new(0, 0, 1, -30)
    footer.BackgroundTransparency = 1
    footer.Text = "Melony Scripts | by Melony"
    footer.TextColor3 = Color3.fromRGB(100, 100, 120)
    footer.TextSize = 11
    footer.Font = Enum.Font.Gotham
    footer.Parent = f
end

local function setupESP()
    clearESP()
    for _, player in ipairs(p:GetPlayers()) do
        if player ~= plr and player.Character then createESP(player) end
    end
end

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
    
    updateDroppedGunESP()
    aimbot()
    triggerbot()
end)

-- Горячая клавиша
userInput.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        if gui then pcall(function() gui:Destroy() end); gui = nil else createMenu() end
    end
end)

-- Запуск
createMenu()
setupESP()

print("✅ Melony Scripts | MM2 Ultimate")
print("🔫 Dropped Gun ESP - показывает ТОЛЬКО выпавший пистолет шерифа")
print("🎯 AimBot + TriggerBot с настройками")
print("⌨️ Right Shift - открыть меню")
