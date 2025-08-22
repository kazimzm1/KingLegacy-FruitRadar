-- King Legacy Fruit Radar Safe Version
-- By: ITSH

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Debris = game:GetService("Debris")

local fruitArrows, fruitDots, fruitLog = {}, {}, {}

-- GUI رئيسي
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

-- لوحة أوامر بسيطة
local commandFrame = Instance.new("Frame", ScreenGui)
commandFrame.Size = UDim2.new(0, 220, 0, 120)
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

createButton("Show Fruit List (L)", 10, function()
    print("📜 قائمة الفواكه:")
    for _, f in pairs(fruitLog) do
        print(f.Name.." | "..f.Time.." | TakenBy: "..f.TakenBy)
    end
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

local function playDing()
    local sound = Instance.new("Sound", Workspace)
    sound.SoundId = "rbxassetid://7149516995"
    sound.Volume = 3
    sound:Play()
    Debris:AddItem(sound, 3)
end

local function updateUI()
    for fruit, arrow in pairs(fruitArrows) do
        if fruit and fruit.Parent and fruit:IsA("BasePart") then
            local fruitPos, onScreen = Camera:WorldToViewportPoint(fruit.Position)
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - fruit.Position).magnitude

            if onScreen then
                arrow.Visible = true
                arrow.Position = UDim2.new(0, fruitPos.X - 90, 0, fruitPos.Y - 20)
                arrow.Text = "⬆ "..fruit.Parent.Name.." ["..math.floor(dist).."m]"
                arrow.TextColor3 = Color3.fromRGB(0,255,0)
            else
                arrow.Visible = true
                arrow.Position = UDim2.new(0.5, -90, 0.05, 0)
                arrow.Text = "⬆ "..fruit.Parent.Name.." ("..math.floor(dist).."m)"
                arrow.TextColor3 = Color3.fromRGB(255,0,0)
            end

            local rel = (fruit.Position - LocalPlayer.Character.HumanoidRootPart.Position)/200
            local x = math.clamp(0.5 + rel.X,0,1)
            local y = math.clamp(0.5 + rel.Z,0,1)
            fruitDots[fruit].Position = UDim2.new(x,-3,y,-3)
        else
            arrow:Destroy()
            if fruitDots[fruit] then fruitDots[fruit]:Destroy() end
            fruitArrows[fruit]=nil
            fruitDots[fruit]=nil
        end
    end
end

local function scanFruits()
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and string.find(obj.Name,"Fruit") then
            local part = obj:FindFirstChildWhichIsA("BasePart")
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

RunService.RenderStepped:Connect(function()
    scanFruits()
    updateUI()
end)

-- كشف من أخذ الفاكهة بدون تحريكك
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
