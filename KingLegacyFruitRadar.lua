-- King Legacy Fruit Radar + Auto-TP + Auto Collect + GUI + Logger + Exit
-- By: ITSH

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Debris = game:GetService("Debris")

-- بيانات الفواكه
local fruitArrows, fruitDots, fruitLog = {}, {}, {}
local autoCollect = false

-- GUI رئيسي
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

-- لوحة أوامر
local commandFrame = Instance.new("Frame", ScreenGui)
commandFrame.Size = UDim2.new(0, 220, 0, 200)
commandFrame.Position = UDim2.new(0, 10, 0, 10)
commandFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
commandFrame.BackgroundTransparency = 0.3
commandFrame.BorderSizePixel = 2

local function createButton(text, posY, callback)
    local btn = Instance.new("TextButton", commandFrame)
    btn.Size = UDim2.new(0, 200, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.Text = text
    btn.TextScaled = true
    btn.Font = Enum.Font.SourceSansBold
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- أزرار التحكم
createButton("Teleport Closest Fruit (T)", 10, function()
    local closest, dist = nil, math.huge
    for fruit,_ in pairs(fruitArrows) do
        if fruit and fruit.Parent then
            local d = (LocalPlayer.Character.HumanoidRootPart.Position - fruit.Position).magnitude
            if d < dist then
                closest = fruit
                dist = d
            end
        end
    end
    if closest then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(closest.Position + Vector3.new(0,5,0))
        StarterGui:SetCore("SendNotification", {
            Title = "Fruit TP 🍏",
            Text = "انتقلت إلى: "..closest.Parent.Name,
            Duration = 4
        })
    end
end)

createButton("Toggle Auto Collect (Y)", 60, function()
    autoCollect = not autoCollect
    StarterGui:SetCore("SendNotification", {
        Title = "Auto Collect",
        Text = autoCollect and "✅ مفعل" or "❌ متوقف",
        Duration = 4
    })
end)

createButton("Show Fruit List (L)", 110, function()
    print("📜 قائمة الفواكه:")
    for _, f in pairs(fruitLog) do
        print(f.Name.." | "..f.Time.." | TakenBy: "..f.TakenBy)
    end
end)

createButton("Exit Script", 160, function()
    ScreenGui:Destroy()
end)

-- Mini Map
local miniMapFrame = Instance.new("Frame", ScreenGui)
miniMapFrame.Size = UDim2.new(0, 200, 0, 200)
miniMapFrame.Position = UDim2.new(1, -210, 1, -210)
miniMapFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
miniMapFrame.BackgroundTransparency = 0.3
miniMapFrame.BorderSizePixel = 2

local playerDot = Instance.new("Frame", miniMapFrame)
playerDot.Size = UDim2.new(0, 8, 0, 8)
playerDot.Position = UDim2.new(0.5, -4, 0.5, -4)
playerDot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
playerDot.BorderSizePixel = 0

local function createArrow(fruit)
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 180, 0, 40)
    arrow.BackgroundTransparency = 1
    arrow.Text = "⬆ " .. fruit.Name
    arrow.TextScaled = true
    arrow.Font = Enum.Font.SourceSansBold
    arrow.TextColor3 = Color3.fromRGB(255, 255, 0)
    arrow.Visible = true
    arrow.Parent = ScreenGui
    return arrow
end

local function createDot(fruit)
    local dot = Instance.new("Frame", miniMapFrame)
    dot.Size = UDim2.new(0, 6, 0, 6)
    dot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    dot.BorderSizePixel = 0
    return dot
end

-- إشعار صوتي
local function playDing()
    local sound = Instance.new("Sound", Workspace)
    sound.SoundId = "rbxassetid://7149516995"
    sound.Volume = 3
    sound:Play()
    Debris:AddItem(sound, 3)
end

-- إيجاد الجزء الرئيسي للفاكهة
local function getFruitPart(fruitModel)
    return fruitModel:FindFirstChildWhichIsA("BasePart") or fruitModel.PrimaryPart
end

-- فحص الفواكه
local function scanFruits()
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and string.find(obj.Name,"Fruit") then
            local part = getFruitPart(obj)
            if part and not fruitArrows[part] then
                fruitArrows[part] = createArrow(part)
                fruitDots[part] = createDot(part)

                table.insert(fruitLog,{
                    Name = obj.Name,
                    Time = os.date("%X"),
                    TakenBy = "N/A"
                })

                playDing()
                StarterGui:SetCore("SendNotification",{
                    Title="Fruit Drop 🍏",
                    Text=obj.Name.." نزل بالسيرفر!",
                    Duration=5
                })
            end
        end
    end
end

-- تحديث MiniMap والنقاط وAuto Collect
local function updateUI()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrpPos = LocalPlayer.Character.HumanoidRootPart.Position

    for fruit, arrow in pairs(fruitArrows) do
        if fruit and fruit.Parent and fruit:IsA("BasePart") then
            local fruitPos, onScreen = Camera:WorldToViewportPoint(fruit.Position)
            local dist = (hrpPos - fruit.Position).magnitude

            arrow.Text = "⬆ "..fruit.Parent.Name.." ["..math.floor(dist).."m]"

            local x = math.clamp(0.5 + (fruit.Position.X - hrpPos.X)/200, 0, 1)
            local y = math.clamp(0.5 + (fruit.Position.Z - hrpPos.Z)/200, 0, 1)
            fruitDots[fruit].Position = UDim2.new(x,-3,y,-3)

            if autoCollect and dist>10 then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(fruit.Position + Vector3.new(0,5,0))
            end
        else
            arrow:Destroy()
            if fruitDots[fruit] then fruitDots[fruit]:Destroy() end
            fruitArrows[fruit]=nil
            fruitDots[fruit]=nil
        end
    end
end

-- كشف من أخذ الفاكهة
for _, plr in pairs(Players:GetPlayers()) do
    plr.CharacterAdded:Connect(function(char)
        char.ChildAdded:Connect(function(tool)
            if tool:IsA("Tool") and string.find(tool.Name,"Fruit") then
                for i,f in pairs(fruitLog) do
                    if f.Name==tool.Name and f.TakenBy=="N/A" then
                        f.TakenBy = plr.Name
                        StarterGui:SetCore("SendNotification",{
                            Title="Fruit Taken",
                            Text=plr.Name.." أخذ "..tool.Name,
                            Duration=5
                        })
                    end
                end
            end
        end)
    end)
end

RunService.RenderStepped:Connect(function()
    scanFruits()
    updateUI()
end)
