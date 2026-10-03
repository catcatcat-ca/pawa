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
})

local MainTab = Window:Tab({
    Title = "Main",
    Icon = "lucide:home",
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

-- Autofarm
MainTab:Toggle({
    Title = "Autofarm",
    Desc = "Enable autofarm by toggling this on.",
    Value = false, 
    Callback = function(state)
        if state then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/seannstar/voidextractor/refs/heads/main/VoidExtractor.lua"))()
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

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

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

})
