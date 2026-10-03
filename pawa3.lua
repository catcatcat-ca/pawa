local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

local Window = WindUI:CreateWindow({
    Title = "pawa",
    Icon = "rbxthumb://type=Asset&id=81169894862344&w=150&h=150", 
    Folder = "pawaui",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    User = {
        Enabled = true,
        Anonymous = false, 
        Callback = function()
            print("User profile clicked")
        end,
    },
    OpenButton = {
        Title = "Open Pawa",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 2,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 0.67,
        Color = ColorSequence.new(
            Color3.fromHex("#E1E6ED"),
            Color3.fromHex("#BCC0C4")
        ),
    },
    Topbar = {
        Height = 44,
        ButtonsType = "Mac",
    },    
})

local MainTab = Window:Tab({
    Title = "Main",
    Icon = "home",
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local NoclipConnection = nil

local function applyNoclip()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            for _, conn in ipairs(getconnections(part:GetPropertyChangedSignal("CanQuery"))) do conn:Disconnect() end
            for _, conn in ipairs(getconnections(part:GetPropertyChangedSignal("CanCollide"))) do conn:Disconnect() end
            for _, conn in ipairs(getconnections(part:GetPropertyChangedSignal("CanTouch"))) do conn:Disconnect() end
            for _, conn in ipairs(getconnections(part.Changed)) do conn:Disconnect() end
            part.CanCollide = false
        end
    end
end

-- Add the Toggle to the Tab
MainTab:Toggle({
    Title = "Noclip",
    Default = false,
    Callback = function(Value)
        if Value then
            applyNoclip()
            if not NoclipConnection then
                NoclipConnection = RunService.Stepped:Connect(function()
                    local character = LocalPlayer.Character
                    if character then
                        for _, part in ipairs(character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
            end
        else
            if NoclipConnection then
                NoclipConnection:Disconnect()
                NoclipConnection = nil
            end
            local character = LocalPlayer.Character
            if character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end,
})

MainTab:Toggle({
    Title = "Instant Skillcheck",
    Desc = "Enable instant skillcheck by toggling this on.",
    Value = false,
    Callback = function(state)
        getgenv().scinstant = state
        if state then
            local event = game:GetService("ReplicatedStorage").Events.SkillcheckUpdate
            local ogcb = getcallbackvalue(event, "OnClientInvoke")
            local ts = game:GetService("TweenService")
            local ti = TweenInfo.new(1.5, Enum.EasingStyle.Linear)
            if ogcb then
                local hook
                hook = hookfunction(ogcb, function(...)
                    if getgenv().scinstant then
                        task.spawn(function()
                            game:GetService("StarterGui").ScreenGui.Correct:Play()
                            game:GetService("StarterGui").ScreenGui.GoldAreaHit:Play()
                           
                            local msg = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Menu.SkillCheckMessage
                            msg.UIGradient.Enabled = false
                            msg.Text = "Great Job!"
                            msg.UIGradientWin.Enabled = true
                            msg.Visible = true
                           
                            task.wait(1.5)
                           
                            local tween = ts:Create(msg, ti, {TextTransparency = 1})
                            tween:Play()
                            tween.Completed:Wait()
                           
                            msg.Visible = false
                            msg.TextTransparency = 0
                        end)
                       
                        return "supercomplete"
                    end
                   
                    return hook(...)
                end)
                print("Instant Skillcheck hooked successfully")
            else
                warn("Failed to hook Skillcheck")
            end
        end
    end
})

MainTab:Button({
    Title = "Ability range",
    Desc = "Increases your ability range.",
    Callback = function()
        local toons = {"Shelly", "Sprout", "Cosmo", "Scraps", "Glisten"}
        local toonsTable = {}
        for _, toon in pairs(toons) do
            toonsTable[toon] = true
        end
        local connections = getconnections(RunService.RenderStepped)
        for _, conn in pairs(connections) do
            local func = conn.Function
            if func then
                local ok, upvals = pcall(getupvalues, func)
                if ok and upvals then
                    for _, val in pairs(upvals) do
                        if typeof(val) == "table" then
                            local ok2, name = pcall(function() return val.Name end)
                            local ok3, radius = pcall(function() return val.PlayerRadius end)
                            if ok2 and ok3 and toonsTable[name] and radius and radius ~= 500 then
                                val.PlayerRadius = 500
                            end
                        end
                    end
                end
            end
        end
    end
})

MainTab:Button({
    Title = "Streamer Mode",
    Desc = "Useful for making videos!",
    Callback = function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local nameTag = character.HumanoidRootPart:FindFirstChild("NameTag")
            if nameTag and nameTag:FindFirstChild("Frame") then
                local p = nameTag.Frame
                p.UserName.Text, p.DisplayName.Text = "pawa", "pawa"
            end
        end
    end
})

local baseBrightness = Lighting.Brightness
local baseClockTime = Lighting.ClockTime
local baseShadows = Lighting.GlobalShadows
local baseAmbient = Lighting.Ambient
MainTab:Toggle({
    Title = "Fullbright",
    Desc = "Lights up your surroundings.",
    Value = false,
    Callback = function(Value)
        if Value then
            Lighting.Brightness = 4
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        else
            Lighting.Brightness = baseBrightness
            Lighting.ClockTime = baseClockTime
            Lighting.GlobalShadows = baseShadows
            Lighting.Ambient = baseAmbient
        end
    end,
})

local Tab = Window:Tab({
    Title = "Name Spoofer",
    Icon = "pencil",
})

local function getPlayerList()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(list, plr.Name)
        end
    end
    return list
end

local selectedPlayer = nil
local Dropdown = Tab:Dropdown({
    Title = "Select Player",
    Desc = "Choose whose name you want to copy",
    Values = getPlayerList(),
    Multi = false,
    AllowNone = true,
    Callback = function(Value)
        selectedPlayer = Value
    end
})

Tab:Button({
    Title = "Refresh Player List",
    Callback = function()
        Dropdown:Refresh(getPlayerList())
        WindUI:Notify({
            Title = "Refreshed",
            Content = "Player list updated",
            Duration = 2
        })
    end
})

Tab:Button({
    Title = "Apply Name",
    Callback = function()
        if not selectedPlayer then
            WindUI:Notify({
                Title = "Error",
                Content = "Please select a player first!",
                Duration = 3
            })
            return
        end
        local target = Players:FindFirstChild(selectedPlayer)
        if not target then
            WindUI:Notify({
                Title = "Error",
                Content = "Player not found anymore",
                Duration = 3
            })
            return
        end
        local success, err = pcall(function()
            local p = workspace.Players[LocalPlayer.Name].HumanoidRootPart.NameTag.Frame
            p.UserName.Text = target.Name
            p.DisplayName.Text = target.DisplayName
        end)
        if success then
            WindUI:Notify({
                Title = "Success!",
                Content = "Now showing as " .. target.DisplayName .. " (@" .. target.Name .. ")",
                Duration = 4
            })
        else
            WindUI:Notify({
                Title = "Failed",
                Content = "Could not find NameTag. Make sure you're in the game.",
                Duration = 4
            })
        end
    end
})

Tab:Button({
    Title = "Reset to Real Name",
    Callback = function()
        pcall(function()
            local p = workspace.Players[LocalPlayer.Name].HumanoidRootPart.NameTag.Frame
            p.UserName.Text = LocalPlayer.Name
            p.DisplayName.Text = LocalPlayer.DisplayName
        end)
        WindUI:Notify({
            Title = "Reset",
            Content = "Name tag restored",
            Duration = 2
        })
    end
})

Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    Dropdown:Refresh(getPlayerList())
end)
Players.PlayerRemoving:Connect(function()
    task.wait(0.5)
    Dropdown:Refresh(getPlayerList())
end)

local VisualTab = Window:Tab({
    Title = "Visuals",
    Icon = "eye",
})

-- ==================== PLAYER ESP ====================
local playerActive = {}
local playerESPEnabled = false
local playerLoopRunning = false
local PlayerMaxDistance = 120

VisualTab:Toggle({
    Title = "Player ESP",
    Desc = "See other players, doesn't work in solo runs.",
    Value = false,
    Callback = function(state)
        playerESPEnabled = state
        
        local function createESP(player)
            if playerActive[player] or player == LocalPlayer then return end
            local character = player.Character
            if not character then return end
            
            local root = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
            if not root then return end
            
            local highlight = Instance.new("Highlight")
            highlight.Adornee = character
            highlight.FillTransparency = 1
            highlight.OutlineTransparency = 0
            highlight.OutlineColor = Color3.fromRGB(50, 50, 255)
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = character
            
            local billboard = Instance.new("BillboardGui")
            billboard.Adornee = root
            billboard.Size = UDim2.new(0, 100, 0, 20)
            billboard.StudsOffset = Vector3.new(0, 2.8, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = character
            
            local text = Instance.new("TextLabel")
            text.Size = UDim2.new(1, 0, 1, 0)
            text.BackgroundTransparency = 1
            text.Text = player.DisplayName
            text.TextColor3 = Color3.fromRGB(255, 255, 255)
            text.TextStrokeTransparency = 0.3
            text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            text.Font = Enum.Font.FredokaOne
            text.TextSize = 12
            text.TextScaled = false
            text.Parent = billboard
            
            playerActive[player] = {
                highlight = highlight,
                billboard = billboard,
                character = character,
                root = root
            }
        end
        
        local function removeESP(player)
            if playerActive[player] then
                pcall(function()
                    playerActive[player].highlight:Destroy()
                    playerActive[player].billboard:Destroy()
                end)
                playerActive[player] = nil
            end
        end
        
        local function clearAll()
            for player in pairs(playerActive) do
                removeESP(player)
            end
        end
        
        if state then
            if playerLoopRunning then return end
            playerLoopRunning = true
            
            task.spawn(function()
                while playerESPEnabled do
                    local myRoot = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character.PrimaryPart)
                    
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character.Parent then
                            local root = player.Character:FindFirstChild("HumanoidRootPart") or player.Character.PrimaryPart
                            
                            if root and myRoot then
                                local dist = (root.Position - myRoot.Position).Magnitude
                                
                                if dist <= PlayerMaxDistance then
                                    if not playerActive[player] or playerActive[player].character ~= player.Character then
                                        removeESP(player)
                                        createESP(player)
                                    end
                                else
                                    removeESP(player)
                                end
                            end
                        end
                    end
                    
                    for player in pairs(playerActive) do
                        if not player.Parent or not player.Character or not player.Character.Parent then
                            removeESP(player)
                        end
                    end
                    
                    task.wait(0.35)
                end
                
                clearAll()
                playerLoopRunning = false
            end)
        else
            playerESPEnabled = false
            clearAll()
            playerLoopRunning = false
        end
    end
})

-- ==================== TWISTED ESP ====================
local targets = {
	["YattaMonster"] = "Twisted Yatta",
	["BoxtenMonster"] = "Twisted Boxten",
	["ShellyMonster"] = "Twisted Shelly",
	["DandyMonster"] = "Twisted Dandy",
	["DyleMonster"] = "Twisted Dyle",
	["PoppyMonster"] = "Twisted Poppy",
	["SquirmMonster"] = "Twisted Squirm",
	["TishaMonster"] = "Twisted Tisha",
	["ShrimpoMonster"] = "Twisted Shrimpo",
	["ScrapsMonster"] = "Twisted Scraps",
	["GoobMonster"] = "Twisted Goob",
	["VeeMonster"] = "Twisted Vee",
	["SproutMonster"] = "Twisted Sprout",
	["CosmoMonster"] = "Twisted Cosmo",
	["AstroMonster"] = "Twisted Astro",
	["PebbleMonster"] = "Twisted Pebble",
	["BlotMonster"] = "Twisted Blot",
	["LooeyMonster"] = "Twisted Looey",
	["ToodlesMonster"] = "Twisted Toodles",
	["FlutterMonster"] = "Twisted Flutter",
	["GlistenMonster"] = "Twisted Glisten",
	["FinnMonster"] = "Twisted Finn",
	["ConnieMonster"] = "Twisted Connie",
	["RazzleAndDazzleMonster"] = "Twisted Razzle and Dazzle",
	["RodgerMonster"] = "Twisted Rodger",
	["TeaganMonster"] = "Twisted Teagan",
	["BrushaMonster"] = "Twisted Brusha",
	["BrightneyMonster"] = "Twisted Brightney",
	["EggsonMonster"] = "Twisted Eggson",
	["RudieMonster"] = "Twisted Rudie",
	["RibeccaMonster"] = "Twisted Ribecca",
	["GigiMonster"] = "Twisted Gigi",
	["GingerMonster"] = "Twisted Ginger",
	["FlyteMonster"] = "Twisted Flyte",
	["SoulvesterMonster"] = "Twisted Soulvester",
	["CoalMonster"] = "Twisted Coal",
	["CocoaMonster"] = "Twisted Cocoa",
	["BassieMonster"] = "Twisted Bassie",
	["BobetteMonster"] = "Twisted Bobette",
	["GourdyMonster"] = "Twisted Gourdy"
}

local twistedActive = {}
local twistedESPEnabled = false
local twistedLoopRunning = false
local TwistedMaxDistance = 150

VisualTab:Toggle({
    Title = "Twisted ESP",
    Desc = "See twisteds in your run.",
    Value = false,
    Callback = function(state)
        twistedESPEnabled = state
        
        local function createESP(model, displayName)
            if twistedActive[model] then return end
            
            local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
            if not root then return end
            
            local highlight = Instance.new("Highlight")
            highlight.Adornee = model
            highlight.FillTransparency = 1
            highlight.OutlineTransparency = 0
            highlight.OutlineColor = Color3.fromRGB(255, 50, 50)
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = model
            
            local billboard = Instance.new("BillboardGui")
            billboard.Adornee = root
            billboard.Size = UDim2.new(0, 100, 0, 20)
            billboard.StudsOffset = Vector3.new(0, 2.8, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = model
            
            local text = Instance.new("TextLabel")
            text.Size = UDim2.new(1, 0, 1, 0)
            text.BackgroundTransparency = 1
            text.Text = displayName
            text.TextColor3 = Color3.fromRGB(255, 255, 255)
            text.TextStrokeTransparency = 0.3
            text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            text.Font = Enum.Font.FredokaOne
            text.TextSize = 12
            text.TextScaled = false
            text.Parent = billboard
            
            twistedActive[model] = {
                highlight = highlight,
                billboard = billboard,
                root = root
            }
        end
        
        local function removeESP(model)
            if twistedActive[model] then
                pcall(function()
                    twistedActive[model].highlight:Destroy()
                    twistedActive[model].billboard:Destroy()
                end)
                twistedActive[model] = nil
            end
        end
        
        local function clearAll()
            for model in pairs(twistedActive) do
                removeESP(model)
            end
        end
        
        if state then
            if twistedLoopRunning then return end
            twistedLoopRunning = true
            
            task.spawn(function()
                while twistedESPEnabled do
                    local myRoot = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character.PrimaryPart)
                    
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("Model") and targets[obj.Name] then
                            local root = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                            
                            if root and myRoot then
                                local dist = (root.Position - myRoot.Position).Magnitude
                                
                                if dist <= TwistedMaxDistance then
                                    if not twistedActive[obj] then
                                        createESP(obj, targets[obj.Name])
                                    end
                                else
                                    removeESP(obj)
                                end
                            end
                        end
                    end
                    
                    for model in pairs(twistedActive) do
                        if not model or not model.Parent then
                            removeESP(model)
                        end
                    end
                    
                    task.wait(0.4)
                end
                
                clearAll()
                twistedLoopRunning = false
            end)
        else
            twistedESPEnabled = false
            clearAll()
            twistedLoopRunning = false
        end
    end
})

local itemTargets = {
    ["AirHorn"] = "Air Horn",
    ["SmokeBomb"] = "Smoke Bomb",
    ["ResearchCapsule"] = "Research Capsule",
    ["ProteinBar"] = "Protein Bar",
    ["Jawbreaker"] = "Jawbreaker",
    ["EjectButton"] = "Eject Button",
    ["HealthKit"] = "MedKit",
    ["Bandage"] = "Bandage",
    ["Tape"] = "Tape",
    ["Instructions"] = "Instructions",
    ["ExtractionSpeedCandy"] = "Extraction Candy",
    ["SkillCheckCandy"] = "SkillCheck Candy",
    ["StaminaCandy"] = "Stamina Candy",
    ["StealthCandy"] = "Stealth Candy",
    ["SpeedCandy"] = "Speed Candy",
    ["Gumball"] = "Gumball",
    ["BonBon"] = "BonBon",
    ["Chocolate"] = "Chocolate",
    ["ChocolateBox"] = "Chocolate Box",
    ["Pop"] = "Pop",
    ["PopBottle"] = "Pop Bottle",
    ["JumperCable"] = "Jumper Cable",
    ["Stopwatch"] = "Stopwatch",
    ["ChristmasCookie"] = "Christmas Cookie",
    ["DandyEasterEggs"] = "Dandy Easter Eggs",
    ["Pumpkin"] = "Pumpkins",
    ["FakeCapsule"] = "Fake Capsule",
    ["CollectablePiece"] = "Halloween Card",
    ["TrickOrTreatDoor_Origin"] = "Halloween Door"
}

local activeItems = {}
local itemEspEnabled = false
local isItemLoopActive = false
local maxItemDistance = 150

VisualTab:Toggle({
    Title = "Item + Other ESP",
    Desc = "See useful items and other stuff such as research capsules, Halloween doors, etc",
    Value = false,
    Callback = function(toggledState)
        itemEspEnabled = toggledState
        
        local function createItemESP(targetModel, labelText)
            if activeItems[targetModel] then return end
            local modelRoot = targetModel:FindFirstChild("HumanoidRootPart") or targetModel.PrimaryPart or targetModel:FindFirstChildWhichIsA("BasePart")
            if not modelRoot then return end
            
            local boxHighlight = Instance.new("Highlight")
            boxHighlight.Adornee = targetModel
            boxHighlight.FillTransparency = 1
            boxHighlight.OutlineTransparency = 0
            boxHighlight.OutlineColor = Color3.fromRGB(50, 255, 50) -- Neon Green outline for items
            boxHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            boxHighlight.Parent = targetModel
            
            local nameBillboard = Instance.new("BillboardGui")
            nameBillboard.Adornee = modelRoot
            nameBillboard.Size = UDim2.new(0, 100, 0, 20)
            nameBillboard.StudsOffset = Vector3.new(0, 2.8, 0)
            nameBillboard.AlwaysOnTop = true
            nameBillboard.Parent = targetModel
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, 0, 1, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = labelText
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.TextStrokeTransparency = 0.3
            nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            nameLabel.Font = Enum.Font.FredokaOne
            nameLabel.TextSize = 12
            nameLabel.TextScaled = false
            nameLabel.Parent = nameBillboard
            
            activeItems[targetModel] = {
                highlight = boxHighlight,
                billboard = nameBillboard,
                root = modelRoot
            }
        end
        
        local function removeItemESP(targetModel)
            if activeItems[targetModel] then
                pcall(function()
                    activeItems[targetModel].highlight:Destroy()
                    activeItems[targetModel].billboard:Destroy()
                end)
                activeItems[targetModel] = nil
            end
        end
        
        local function clearAllItems()
            for targetModel in pairs(activeItems) do
                removeItemESP(targetModel)
            end
        end
        
        if toggledState then
            if isItemLoopActive then return end
            isItemLoopActive = true
            task.spawn(function()
                while itemEspEnabled do
                    local playerRoot = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character.PrimaryPart)
                    for _, gameObj in pairs(workspace:GetDescendants()) do
                        if gameObj:IsA("Model") and itemTargets[gameObj.Name] then
                            local modelRoot = gameObj:FindFirstChild("HumanoidRootPart") or gameObj.PrimaryPart or gameObj:FindFirstChildWhichIsA("BasePart")
                            if modelRoot and playerRoot then
                                local distanceToItem = (modelRoot.Position - playerRoot.Position).Magnitude
                                if distanceToItem <= maxItemDistance then
                                    if not activeItems[gameObj] then
                                        createItemESP(gameObj, itemTargets[gameObj.Name])
                                    end
                                else
                                    removeItemESP(gameObj)
                                end
                            end
                        end
                    end
                    for targetModel in pairs(activeItems) do
                        if not targetModel or not targetModel.Parent then
                            removeItemESP(targetModel)
                        end
                    end
                    task.wait(0.4)
                end
                clearAllItems()
                isItemLoopActive = false
            end)
        else
            itemEspEnabled = false
            clearAllItems()
            isItemLoopActive = false
        end
    end
})
