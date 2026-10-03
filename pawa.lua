local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

local Window = WindUI:CreateWindow({
    Title = "pawa",
    Icon = "rbxthumb://type=Asset&id=81169894862344&w=150&h=150", 
    Author = "",
    Folder = "pawaui",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
})

local MainTab = Window:Tab({
    Title = "Main",
    Icon = "lucide:home",
})

local MainSection = MainTab:Section({
    Title = "Controls",
})

local noclipEnabled = false
local NoclipConnection = nil

MainSection:Toggle({
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

MainSection:Toggle({
    Title = "Autofarm",
    Desc = "Enable autofarm by toggling this on.",
    Value = false, 
    Callback = function(state)
        if state then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/seannstar/voidextractor/refs/heads/main/VoidExtractor.lua"))()
        end
    end
})

MainSection:Button({
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

MainSection:Button({
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

MainSection:Toggle({
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
