local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "pawa",
    Icon = "rbxassetid://81169894862344", 
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

MainSection:Button({
    Title = "Noclip",
    Desc = "Grants access for you to noclip- click again to disable it.",
    Callback = function()
local NoclipConnection = nil

local function toggleNoclip(state)
    if state then
        local function applyNoclip()
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function()
                        for _, conn in ipairs(getconnections(part:GetPropertyChangedSignal("CanQuery"))) do conn:Disconnect() end
                        for _, conn in ipairs(getconnections(part:GetPropertyChangedSignal("CanCollide"))) do conn:Disconnect() end
                        for _, conn in ipairs(getconnections(part:GetPropertyChangedSignal("CanTouch"))) do conn:Disconnect() end
                        for _, conn in ipairs(getconnections(part.Changed)) do conn:Disconnect() end
                    end)
                    part.CanCollide = false
                end
            end
        end

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
end
})

MainSection:Toggle({
    Title = "Autofarm",
    Desc = "Enable autofarm by toggling this on.",
    Value = false, 
    Callback = function(state)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/seannstar/voidextractor/refs/heads/main/VoidExtractor.lua"))()
    end
})

MainSection:Button({
    Title = "Ability range",
    Desc = "Increases your ability range.",
    Callback = function()
local RunService = game:GetService("RunService")

local toons = {"Shelly", "Sprout", "Cosmo", "Scraps", "Glisten"}
local toonsTable = {}
for _, toon in pairs(toons) do
    toonsTable[toon] = true
end

local function patchRanges()
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

patchRanges()
})

MainSection:Button({
    Title = "Streamer Mode",
    Desc = "Useful for making videos!",
    Callback = function()
local p = workspace.Players[game.Players.LocalPlayer.Name].HumanoidRootPart.NameTag.Frame; p.UserName.Text, p.DisplayName.Text = "pawa", "pawa"
})

MainSection:Button({
    Title = "Fullbright",
    Desc = "Lights up your surroundings.",
    Callback = function()
local Lighting = game:GetService("Lighting")
local baseBrightness = Lighting.Brightness
local baseClockTime = Lighting.ClockTime
local baseShadows = Lighting.GlobalShadows
local baseAmbient = Lighting.Ambient

MainTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Flag = "FullbrightToggle",
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

MainTab:Select()
