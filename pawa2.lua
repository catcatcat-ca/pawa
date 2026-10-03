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

-- Noclip
local noclipEnabled = false
local NoclipConnection = nil

MainTab:Toggle({
    Title = "Noclip",
    Desc = "Grants access for you to noclip.",
    Value = false,
    Callback = function(state)
        noclipEnabled = state
        if state then
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
    end
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

-- Ability range
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

-- Streamer Mode
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

-- Fullbright
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

-- Auto-refresh list when players join/leave
Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    Dropdown:Refresh(getPlayerList())
end)

Players.PlayerRemoving:Connect(function()
    task.wait(0.5)
    Dropdown:Refresh(getPlayerList())
end)

local MainTab = Window:Tab({
    Title = "Visuals",
    Icon = "eye",
})

Tab:Toggle({
    Title = "Player ESP",
    Desc = "See every player.",
    Value = false,
    Callback = function(state)
        ESPEnabled = state
        
        local function createESP(player)
            if active[player] or player == LocalPlayer then return end
            local character = player.Character
            if not character then return end
            
            local highlight = Instance.new("Highlight")
            highlight.Adornee = character
            highlight.FillTransparency = 1
            highlight.OutlineTransparency = 0
            highlight.OutlineColor = Color3.fromRGB(255, 50, 50)
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = character
            
            local root = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
            if not root then return end
            
            local billboard = Instance.new("BillboardGui")
            billboard.Adornee = root
            billboard.Size = UDim2.new(0, 140, 0, 28)
            billboard.StudsOffset = Vector3.new(0, 3.2, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = character
            
            local text = Instance.new("TextLabel")
            text.Size = UDim2.new(1, 0, 1, 0)
            text.BackgroundTransparency = 1
            text.Text = player.DisplayName
            text.TextColor3 = Color3.fromRGB(0, 0, 255)
            text.TextStrokeTransparency = 0
            text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            text.Font = Enum.Font.FredokaOne
            text.TextScaled = true
            text.Parent = billboard
            
            active[player] = {highlight = highlight, billboard = billboard, character = character}
        end
        
        local function removeESP(player)
            if active[player] then
                if active[player].highlight then active[player].highlight:Destroy() end
                if active[player].billboard then active[player].billboard:Destroy() end
                active[player] = nil
            end
        end
        
        local function clearAll()
            for player in pairs(active) do
                removeESP(player)
            end
        end
        
        if state then
            task.spawn(function()
                while ESPEnabled do
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            if not active[player] or active[player].character ~= player.Character then
                                removeESP(player)
                                createESP(player)
                            end
                        end
                    end
                    
                    for player in pairs(active) do
                        if not player.Parent or not player.Character then
                            removeESP(player)
                        end
                    end
                    task.wait(0.5)
                end
            end)
        else
            clearAll()
        end
    end
})
