-- Melony Scripts | Creator: Melony
-- ESP by Weapon Detection

local p, plr = game:GetService("Players"), game:GetService("Players").LocalPlayer
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local userInput = game:GetService("UserInputService")

local gui = nil
local espObjects = {}

-- Функция определения роли по оружию
local function getRoleByWeapon(player)
    if not player.Character then return "Innocent" end
    
    -- Ищем оружие в руках
    local tool = player.Character:FindFirstChildOfClass("Tool")
    if tool then
        local toolName = tool.Name:lower()
        -- Убийца: нож, knife, dagger
        if toolName:find("knife") or toolName:find("dagger") or toolName:find("blade") then
            return "Murderer"
        end
        -- Шериф: пистолет, gun, pistol
        if toolName:find("gun") or toolName:find("pistol") or toolName:find("revolver") then
            return "Sheriff"
        end
    end
    
    -- Дополнительная проверка: смотрим на аксессуары
    for _, v in ipairs(player.Character:GetChildren()) do
        if v:IsA("Accessory") or v:IsA("Tool") then
            local name = v.Name:lower()
            if name:find("knife") or name:find("blade") then
                return "Murderer"
            end
            if name:find("gun") or name:find("pistol") then
                return "Sheriff"
            end
        end
    end
    
    return "Innocent"
end

-- Цвета для ESP
local colors = {
    Murderer = Color3.fromRGB(255, 50, 50),
    Sheriff = Color3.fromRGB(50, 100, 255),
    Innocent = Color3.fromRGB(100, 255, 100)
}

-- Создание ESP для игрока
local function createESP(player)
    if not player.Character or player == plr then return end
    if espObjects[player] then return end
    
    local role = getRoleByWeapon(player)
    
    local highlight = Instance.new("Highlight")
    highlight.FillColor = colors[role]
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Adornee = player.Character
    highlight.Parent = player.Character
    
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 150, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = player.Character
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = player.Name .. " [" .. role .. "]"
    textLabel.TextColor3 = colors[role]
    textLabel.TextStrokeTransparency = 0.2
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = billboard
    
    -- Иконка оружия (эмодзи)
    local weaponIcon = Instance.new("TextLabel")
    weaponIcon.Size = UDim2.new(0, 25, 1, 0)
    weaponIcon.Position = UDim2.new(1, 5, 0, 0)
    weaponIcon.BackgroundTransparency = 1
    weaponIcon.Text = role == "Murderer" and "🔪" or (role == "Sheriff" and "🔫" or "🛡️")
    weaponIcon.TextColor3 = colors[role]
    weaponIcon.TextSize = 20
    weaponIcon.Font = Enum.Font.GothamBold
    weaponIcon.Parent = billboard
    
    espObjects[player] = {
        highlight = highlight,
        billboard = billboard,
        currentRole = role
    }
end

-- Обновление ESP (при смене оружия)
local function updateESP(player)
    if not espObjects[player] then return end
    local newRole = getRoleByWeapon(player)
    if espObjects[player].currentRole ~= newRole then
        espObjects[player].currentRole = newRole
        if espObjects[player].highlight then
            espObjects[player].highlight.FillColor = colors[newRole]
        end
        if espObjects[player].billboard then
            local textLabel = espObjects[player].billboard:FindFirstChildOfClass("TextLabel")
            if textLabel then
                textLabel.Text = player.Name .. " [" .. newRole .. "]"
                textLabel.TextColor3 = colors[newRole]
            end
            local icon = espObjects[player].billboard:FindFirstChildOfClass("TextLabel")
            if icon and icon ~= textLabel then
                icon.Text = newRole == "Murderer" and "🔪" or (newRole == "Sheriff" and "🔫" or "🛡️")
                icon.TextColor3 = colors[newRole]
            end
        end
    end
end

-- Удаление ESP
local function clearESP()
    for _, obj in pairs(espObjects) do
        if obj.highlight then obj.highlight:Destroy() end
        if obj.billboard then obj.billboard:Destroy() end
    end
    espObjects = {}
end

-- Настройка ESP для всех игроков
local function setupESP()
    clearESP()
    for _, player in ipairs(p:GetPlayers()) do
        if player ~= plr then
            if player.Character then
                createESP(player)
            end
            player.CharacterAdded:Connect(function(char)
                task.wait(0.3)
                createESP(player)
            end)
        end
    end
end

-- Отслеживаем смену оружия через CharacterAdded и проверку инструментов
local function trackWeaponChanges(player)
    player.CharacterAdded:Connect(function(char)
        task.wait(0.3)
        if espObjects[player] then
            updateESP(player)
        end
        -- Отслеживаем добавление/удаление инструментов
        local function onChildAdded(child)
            if child:IsA("Tool") then
                updateESP(player)
            end
        end
        local function onChildRemoved(child)
            if child:IsA("Tool") then
                updateESP(player)
            end
        end
        char.ChildAdded:Connect(onChildAdded)
        char.ChildRemoved:Connect(onChildRemoved)
    end)
end

for _, player in ipairs(p:GetPlayers()) do
    if player ~= plr then
        trackWeaponChanges(player)
    end
end

p.PlayerAdded:Connect(function(player)
    trackWeaponChanges(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.3)
        createESP(player)
    end)
end)

-- GUI Menu (упрощённый)
local function createMenu()
    if gui then gui:Destroy() end
    gui = Instance.new("ScreenGui", plr:WaitForChild("PlayerGui"))
    gui.Name = "Melony"
    
    local f = Instance.new("Frame", gui)
    f.Size = UDim2.new(0, 200, 0, 100)
    f.Position = UDim2.new(0.5, -100, 0.5, -50)
    f.BackgroundColor3 = Color3.fromRGB(20,20,25)
    f.Active = true
    f.Draggable = true
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,8)
    
    local title = Instance.new("Frame", f)
    title.Size = UDim2.new(1,0,0,35)
    title.BackgroundColor3 = Color3.fromRGB(30,30,35)
    Instance.new("UICorner", title).CornerRadius = UDim.new(0,8)
    
    local titleText = Instance.new("TextLabel", title)
    titleText.Size = UDim2.new(1,0,1,0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "Melony Scripts"
    titleText.TextColor3 = Color3.fromRGB(255,100,150)
    titleText.TextScaled = true
    titleText.Font = Enum.Font.GothamBold
    
    local close = Instance.new("TextButton", title)
    close.Size = UDim2.new(0,25,0,25)
    close.Position = UDim2.new(1,-30,0,5)
    close.BackgroundColor3 = Color3.fromRGB(255,80,80)
    close.Text = "X"
    close.TextColor3 = Color3.fromRGB(255,255,255)
    close.TextSize = 14
    close.MouseButton1Click:Connect(function() 
        gui:Destroy()
        isMenuOpen = false
    end)
    Instance.new("UICorner", close).CornerRadius = UDim.new(0,4)
    
    local espBtn = Instance.new("TextButton", f)
    espBtn.Size = UDim2.new(0,100,0,35)
    espBtn.Position = UDim2.new(0.5, -50, 0, 50)
    espBtn.BackgroundColor3 = Color3.fromRGB(100,200,100)
    espBtn.Text = "ESP: ON"
    espBtn.TextColor3 = Color3.fromRGB(255,255,255)
    espBtn.TextSize = 16
    Instance.new("UICorner", espBtn).CornerRadius = UDim.new(0,6)
    
    local espEnabled = true
    espBtn.MouseButton1Click:Connect(function()
        espEnabled = not espEnabled
        if espEnabled then
            setupESP()
            espBtn.BackgroundColor3 = Color3.fromRGB(100,200,100)
            espBtn.Text = "ESP: ON"
        else
            clearESP()
            espBtn.BackgroundColor3 = Color3.fromRGB(200,100,100)
            espBtn.Text = "ESP: OFF"
        end
    end)
end

-- Right Shift открывает меню
userInput.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if not gui or not gui.Parent then
            createMenu()
        end
    end
end)

-- Запуск
createMenu()
setupESP()

print("Melony Scripts Loaded | ESP by Weapon Detection")
