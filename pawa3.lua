local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

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

local function notify(title, content, duration)
	pcall(function()
		WindUI:Notify({
			Title = title or "Notice",
			Content = content or "",
			Duration = duration or 3,
		})
	end)
end

-- Shared safety / world helpers
local TwistedMonsterNames = {
	["CosmoMonster"] = true, ["BoxtenMonster"] = true, ["YattaMonster"] = true, ["ShrimpoMonster"] = true,
	["RudieMonster"] = true, ["RibeccaMonster"] = true, ["EggsonMonster"] = true, ["LooeyMonster"] = true,
	["PoppyMonster"] = true, ["BrushaMonster"] = true, ["TishaMonster"] = true, ["FinnMonster"] = true,
	["BrightneyMonster"] = true, ["FlyteMonster"] = true, ["GingerMonster"] = true, ["SoulvesterMonster"] = true,
	["ToodlesMonster"] = true, ["GlistenMonster"] = true, ["GigiMonster"] = true, ["GoobMonster"] = true,
	["ScrapsMonster"] = true, ["CoalMonster"] = true, ["EclipseMonster"] = true, ["CocoaMonster"] = true,
	["FlutterMonster"] = true, ["ShellyMonster"] = true, ["PebbleMonster"] = true, ["VeeMonster"] = true,
	["AstroMonster"] = true, ["SproutMonster"] = true, ["BobetteMonster"] = true, ["BassieMonster"] = true,
	["DyleMonster"] = true, ["DandyMonster"] = true, ["GourdyMonster"] = true, ["TeaganMonster"] = true,
	["RodgerMonster"] = true, ["RazzleDazzleMonster"] = true, ["ConnieMonster"] = true, ["WaxwellMonster"] = true,
}

local function getHRP()
	local char = LocalPlayer.Character
	return char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
end

local function isTwistedNearby(targetPos, maxDist)
	maxDist = maxDist or 30
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("Model") and TwistedMonsterNames[obj.Name] then
			local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
			if part and (part.Position - targetPos).Magnitude <= maxDist then
				return true
			end
		end
	end
	return false
end

local function isElevatorNearby(targetPos, maxDist)
	maxDist = maxDist or 30
	local elevatorsFolder = Workspace:FindFirstChild("Elevators")
	if elevatorsFolder then
		for _, obj in ipairs(elevatorsFolder:GetDescendants()) do
			if obj:IsA("BasePart") or obj:IsA("Model") then
				local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)) or obj
				if part and (part.Position - targetPos).Magnitude <= maxDist then
					return true
				end
			end
		end
	end
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj.Name == "Elevator" or obj.Name == "ElevatorDoor" then
			local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)) or (obj:IsA("BasePart") and obj)
			if part and (part.Position - targetPos).Magnitude <= maxDist then
				return true
			end
		end
	end
	return false
end

local function canInteractWithPosition(pos)
	if isElevatorNearby(pos, 30) then return false end
	if isTwistedNearby(pos, 30) then return false end
	return true
end

local function teleportTo(name, isExact)
	local hrp = getHRP()
	if not hrp then return false end
	for _, obj in ipairs(workspace:GetDescendants()) do
		local match = isExact and (obj.Name == name) or obj.Name:lower():find(name:lower())
		if match then
			local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)) or (obj:IsA("BasePart") and obj)
			if part then
				local targetPos = part:IsA("Model") and part:GetPivot().Position or part.Position
				if isElevatorNearby(targetPos, 30) then continue end
				if isTwistedNearby(targetPos, 30) then
					notify("Teleport", "Twisted Nearby.", 2)
					return false
				end
				hrp.CFrame = (part:IsA("Model") and part:GetPivot() or part.CFrame) + Vector3.new(0, 3, 0)
				return true
			end
		end
	end
	return false
end

local function isMachineCompleted(model)
	local stats = model:FindFirstChild("Stats") or (model.Parent and model.Parent:FindFirstChild("Stats"))
	if stats then
		local completed = stats:FindFirstChild("Completed")
		if completed and completed.Value == true then
			return true
		end
	end
	return false
end

local function performTeleportToMachine()
	local hrp = getHRP()
	if not hrp then return end
	local ignoredNames = {
		["VendingMachine"] = true, ["Cooking_ExpressoMachine"] = true,
		["DanceMachine"] = true, ["Gachapon_Arcade_01"] = true,
		["Gachapon_Arcade_02"] = true, ["Gachapon_Arcade_03"] = true,
	}
	local generators = {}
	for _, obj in ipairs(workspace:GetDescendants()) do
		if not ignoredNames[obj.Name] and obj:IsA("Model") then
			local nameLower = obj.Name:lower()
			if nameLower == "generator" or nameLower == "generators" or nameLower:find("generator") or nameLower:find("dual_generator") or nameLower:find("dualgen") or nameLower:find("trickortreatgen") then
				if not isMachineCompleted(obj) then
					local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
					if part and not isTwistedNearby(part.Position, 30) and not isElevatorNearby(part.Position, 30) then
						table.insert(generators, part)
					end
				end
			end
		end
	end
	if #generators > 0 then
		local randomGen = generators[math.random(1, #generators)]
		hrp.CFrame = randomGen.CFrame + Vector3.new(0, 3, 0)
	else
		notify("Teleport", "Twisted Nearby or inside Elevator.", 2)
	end
end

-- ================= PLATFORM FLIGHT SYSTEM =================
local MOBILE_SETTINGS = {
	PLATFORM_SIZE = Vector3.new(9, 1, 9),
	TRANSPARENCY = 1,
	VERTICAL_OFFSET = 3.2,
	CLIMB_SPEED = 16,
	FOLLOW_SMOOTHNESS = 18,
	ENABLE_STICK_DESCENT = true,
	FORWARD_CLIMB_THRESHOLD = 0.35,
	BACKWARD_DESCEND_THRESHOLD = -0.55,
}

local PC_SETTINGS = {
	PLATFORM_SIZE = Vector3.new(8, 1, 8),
	TRANSPARENCY = 1,
	VERTICAL_OFFSET = 3.2,
	CLIMB_SPEED = 20,
	FOLLOW_SMOOTHNESS = 22,
	ENABLE_STICK_DESCENT = false,
	CLIMB_KEYS = { Enum.KeyCode.E, Enum.KeyCode.Up },
	DESCEND_KEYS = { Enum.KeyCode.Q, Enum.KeyCode.Down },
	TOGGLE_KEY = Enum.KeyCode.F,
}

local currentDevice = "PC"
local activeSettings = PC_SETTINGS

local flightFeatureEnabled = false
local flightPlatform = nil
local flightTargetY = nil
local isFlyingActive = false

local flightRenderConn = nil
local flightDiedConn = nil

local function detectFlightDevice(lastInputType)
	if lastInputType then
		if lastInputType == Enum.UserInputType.Touch then
			currentDevice = "Mobile"
			activeSettings = MOBILE_SETTINGS
			return
		elseif lastInputType == Enum.UserInputType.Keyboard or lastInputType == Enum.UserInputType.MouseButton1 then
			currentDevice = "PC"
			activeSettings = PC_SETTINGS
			return
		end
	end

	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		currentDevice = "Mobile"
		activeSettings = MOBILE_SETTINGS
	else
		currentDevice = "PC"
		activeSettings = PC_SETTINGS
	end
end

local function isAnyKeyDown(keyList)
	if not keyList then return false end
	for i = 1, #keyList do
		if UserInputService:IsKeyDown(keyList[i]) then
			return true
		end
	end
	return false
end

local function isKeyInList(keyCode, keyList)
	if not keyList then return false end
	for i = 1, #keyList do
		if keyList[i] == keyCode then
			return true
		end
	end
	return false
end

local function createFlightPlatform(spawnCFrame)
	if flightPlatform then
		flightPlatform:Destroy()
		flightPlatform = nil
	end

	local part = Instance.new("Part")
	part.Name = "FlightPlatform"
	part.Size = activeSettings.PLATFORM_SIZE
	part.Anchored = true
	part.CanCollide = true
	part.Material = Enum.Material.SmoothPlastic
	part.Transparency = activeSettings.TRANSPARENCY
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.CFrame = spawnCFrame
	part.Parent = workspace

	return part
end

local function cleanupFlightPlatform()
	if flightPlatform then
		flightPlatform:Destroy()
		flightPlatform = nil
	end
	flightTargetY = nil
	isFlyingActive = false
end

local function setPlatformFlight(state)
	flightFeatureEnabled = state
	if not flightFeatureEnabled then
		cleanupFlightPlatform()
	end
end

local function getFlightVerticalInput(humanoid, cam)
	local vertical = 0

	if currentDevice == "PC" then
		if not UserInputService:GetFocusedTextBox() then
			if isAnyKeyDown(activeSettings.CLIMB_KEYS) then
				vertical = vertical + 1
			end
			if isAnyKeyDown(activeSettings.DESCEND_KEYS) then
				vertical = vertical - 1
			end
		end
	else
		local moveDir = humanoid.MoveDirection
		if moveDir.Magnitude > 0.1 and cam then
			local camLookFlat = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
			if camLookFlat.Magnitude > 0.01 then
				camLookFlat = camLookFlat.Unit
				local forwardDot = moveDir.Unit:Dot(camLookFlat)

				if forwardDot > activeSettings.FORWARD_CLIMB_THRESHOLD then
					local denom = 1 - activeSettings.FORWARD_CLIMB_THRESHOLD
					vertical = math.clamp((forwardDot - activeSettings.FORWARD_CLIMB_THRESHOLD) / denom, 0, 1)
				elseif activeSettings.ENABLE_STICK_DESCENT and forwardDot < activeSettings.BACKWARD_DESCEND_THRESHOLD then
					local denom = math.abs(activeSettings.BACKWARD_DESCEND_THRESHOLD) - 0.1
					if denom <= 0 then
						denom = 0.45
					end
					vertical = -math.clamp((math.abs(forwardDot) - math.abs(activeSettings.BACKWARD_DESCEND_THRESHOLD)) / denom, 0, 1)
				end
			end
		end
	end

	return math.clamp(vertical, -1, 1)
end

local function disconnectFlightCharacterLoop()
	if flightRenderConn then
		flightRenderConn:Disconnect()
		flightRenderConn = nil
	end
	if flightDiedConn then
		flightDiedConn:Disconnect()
		flightDiedConn = nil
	end
end

local function onFlightCharacterAdded(character)
	disconnectFlightCharacterLoop()
	cleanupFlightPlatform()

	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = character:WaitForChild("HumanoidRootPart")

	flightDiedConn = humanoid.Died:Connect(cleanupFlightPlatform)

	flightRenderConn = RunService.RenderStepped:Connect(function(dt)
		if not flightFeatureEnabled then return end
		if not character.Parent or humanoid.Health <= 0 or not rootPart.Parent then return end

		Camera = workspace.CurrentCamera or Camera
		local verticalInput = getFlightVerticalInput(humanoid, Camera)

		if verticalInput > 0 then
			isFlyingActive = true
			if not flightPlatform then
				local startY = rootPart.Position.Y - activeSettings.VERTICAL_OFFSET
				flightTargetY = startY
				flightPlatform = createFlightPlatform(CFrame.new(rootPart.Position.X, startY, rootPart.Position.Z))
			end
		end

		if isFlyingActive and flightPlatform and flightTargetY then
			flightTargetY = flightTargetY + (verticalInput * activeSettings.CLIMB_SPEED * dt)

			local minAllowedY = rootPart.Position.Y - (activeSettings.VERTICAL_OFFSET + 2)
			if flightTargetY < minAllowedY then
				flightTargetY = minAllowedY
			end

			local currentPos = flightPlatform.Position
			local desiredPos = Vector3.new(rootPart.Position.X, flightTargetY, rootPart.Position.Z)
			local alpha = 1 - math.exp(-activeSettings.FOLLOW_SMOOTHNESS * dt)
			local nextPos = currentPos:Lerp(desiredPos, alpha)

			flightPlatform.CFrame = CFrame.new(nextPos)
		end
	end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	detectFlightDevice(input.UserInputType)

	if gameProcessed or currentDevice ~= "PC" or not flightFeatureEnabled then
		return
	end

	if isKeyInList(input.KeyCode, activeSettings.TOGGLE_KEY and { activeSettings.TOGGLE_KEY } or nil) then
		if flightPlatform then
			cleanupFlightPlatform()
		elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = LocalPlayer.Character.HumanoidRootPart
			local startY = hrp.Position.Y - activeSettings.VERTICAL_OFFSET
			flightTargetY = startY
			isFlyingActive = true
			flightPlatform = createFlightPlatform(CFrame.new(hrp.Position.X, startY, hrp.Position.Z))
		end
	end
end)

detectFlightDevice(nil)
if LocalPlayer.Character then
	onFlightCharacterAdded(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(onFlightCharacterAdded)

-- ================= MAIN TAB =================
local MainTab = Window:Tab({
	Title = "Main",
	Icon = "house",
})

MainTab:Toggle({
	Title = "Fly",
	Desc = "Flies you across the map. Kinda buggy... (pc: E/Up up, Q/Down down)",
	Value = false,
	Callback = function(state)
		setPlatformFlight(state)
	end,
})

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

local tpWalkEnabled = false
local tpWalkSpeed = 0.12

MainTab:Toggle({
	Title = "TPWalk",
	Desc = "Walk speed boost.",
	Default = false,
	Callback = function(state)
		tpWalkEnabled = state
	end,
})

MainTab:Slider({
	Title = "TPWalk Speed",
	Step = 0.02,
	Value = {
		Min = 0.04,
		Max = 0.4,
		Default = 0.12,
	},
	Callback = function(val)
		tpWalkSpeed = val
	end,
})

RunService.RenderStepped:Connect(function(delta)
	if tpWalkEnabled then
		local char = LocalPlayer.Character
		local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hrp and hum and hum.MoveDirection.Magnitude > 0 then
			hrp.CFrame = hrp.CFrame + (hum.MoveDirection * tpWalkSpeed * delta * 60)
		end
	end
end)

local noSlipperyEnabled = false
local defaultPhysicalProperties = {}
local brakeConnection = nil

MainTab:Toggle({
	Title = "No Slippery",
	Desc = "Stop sliding around.",
	Default = false,
	Callback = function(v)
		noSlipperyEnabled = v
		local char = LocalPlayer.Character

		if noSlipperyEnabled then
			local physicalProperties = PhysicalProperties.new(15.0, 3.0, 0.0, 1.0, 1.0)
			if char then
				for _, part in ipairs(char:GetDescendants()) do
					if part:IsA("BasePart") then
						if not defaultPhysicalProperties[part] then defaultPhysicalProperties[part] = part.CustomPhysicalProperties end
						part.CustomPhysicalProperties = physicalProperties
					end
				end
			end

			if not brakeConnection then
				brakeConnection = RunService.RenderStepped:Connect(function(dt)
					if not noSlipperyEnabled then return end
					local currentCharacter = LocalPlayer.Character
					if not currentCharacter then return end

					local humanoid = currentCharacter:FindFirstChildOfClass("Humanoid")
					local rootPart = currentCharacter:FindFirstChild("HumanoidRootPart")

					if humanoid and rootPart and humanoid.Health > 0 then
						local velocity = rootPart.AssemblyLinearVelocity
						local horizontalVelocity = Vector3.new(velocity.X, 0, velocity.Z)
						if humanoid.MoveDirection.Magnitude == 0 and horizontalVelocity.Magnitude > 0.5 then
							local brakeFactor = math.clamp(dt * 25, 0, 1)
							rootPart.AssemblyLinearVelocity = Vector3.new(velocity.X * (1 - brakeFactor), velocity.Y, velocity.Z * (1 - brakeFactor))
						end
					end
				end)
			end
		else
			if brakeConnection then brakeConnection:Disconnect(); brakeConnection = nil end
			if char then
				for _, part in ipairs(char:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CustomPhysicalProperties = defaultPhysicalProperties[part]
					end
				end
			end
			defaultPhysicalProperties = {}
		end
	end,
})

LocalPlayer.CharacterAdded:Connect(function(char)
	if noSlipperyEnabled then
		task.delay(1, function()
			if noSlipperyEnabled and char then
				local physicalProperties = PhysicalProperties.new(15.0, 3.0, 0.0, 1.0, 1.0)
				for _, part in ipairs(char:GetDescendants()) do
					if part:IsA("BasePart") then part.CustomPhysicalProperties = physicalProperties end
				end
			end
		end)
	end
end)

MainTab:Toggle({
	Title = "Instant Skillcheck",
	Desc = "Automatically does the skillcheck for you.",
	Value = false,
	Callback = function(state)
		getgenv().scinstant = state
		if state then
			local event = ReplicatedStorage.Events.SkillcheckUpdate
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

							local msg = LocalPlayer.PlayerGui.ScreenGui.Menu.SkillCheckMessage
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
	Desc = "Bigger ability range.",
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
	Desc = "Hide your real name",
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

MainTab:Button({
	Title = "Anti Lag",
	Desc = "Lower graphics for better FPS.",
	Callback = function()
		pcall(function()
			Lighting.GlobalShadows = false
			Lighting.FogEnd = 9e9

			for _, v in pairs(Lighting:GetChildren()) do
				if v:IsA("PostEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") then
					v.Enabled = false
				end
			end

			local function optimizeObject(object)
				if object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Smoke") or object:IsA("Fire") or object:IsA("Sparkles") or object:IsA("Light") then
					object.Enabled = false
				elseif object:IsA("BasePart") then
					object.Material = Enum.Material.SmoothPlastic
					object.Reflectance = 0
					object.CastShadow = false
				elseif object:IsA("Decal") or object:IsA("Texture") then
					object.Transparency = 1
				end
			end

			for _, descendant in pairs(Workspace:GetDescendants()) do
				optimizeObject(descendant)
			end
		end)
		notify("Anti Lag", "Done.", 2)
	end
})

local baseBrightness = Lighting.Brightness
local baseClockTime = Lighting.ClockTime
local baseShadows = Lighting.GlobalShadows
local baseAmbient = Lighting.Ambient
MainTab:Toggle({
	Title = "Fullbright",
	Desc = "Brighten the map.",
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

MainTab:Toggle({
	Title = "Instant Barnaby Minigame",
	Desc = "Instantly does the barnaby minigame for you.",
	Value = false,
	Callback = function(state)
		if state then
			loadstring(game:HttpGet("https://raw.githubusercontent.com/christmas-cookie/extensions/refs/heads/main/arcademachine", true))()
		end
	end
})

-- ================= NAME SPOOFER TAB =================
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
	Desc = "Pick a player to copy their username.",
	Values = getPlayerList(),
	Multi = false,
	AllowNone = true,
	Callback = function(Value)
		selectedPlayer = Value
	end
})

Tab:Button({
	Title = "Refresh Player List.",
	Callback = function()
		Dropdown:Refresh(getPlayerList())
		WindUI:Notify({
			Title = "Refreshed",
			Content = "Player list updated.",
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
				Content = "Please select a player first!!",
				Duration = 3
			})
			return
		end
		local target = Players:FindFirstChild(selectedPlayer)
		if not target then
			WindUI:Notify({
				Title = "Error",
				Content = "Player not found anymore...",
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

-- ================= VISUALS TAB =================
local VisualTab = Window:Tab({
	Title = "Visuals",
	Icon = "eye",
})

local playerActive = {}
local playerESPEnabled = false
local playerLoopRunning = false
local PlayerMaxDistance = 120

VisualTab:Toggle({
	Title = "Player ESP",
	Desc = "Show other players.",
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
	Desc = "Show twisteds.",
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
	Desc = "Show items, capsules, doors.",
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
			boxHighlight.OutlineColor = Color3.fromRGB(50, 255, 50)
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

local machineEspEnabled = false
local machineActive = {}
local machineLoopRunning = false

VisualTab:Toggle({
	Title = "Machine ESP",
	Desc = "Show machines.",
	Value = false,
	Callback = function(state)
		machineEspEnabled = state

		local ignoredNames = {
			["VendingMachine"] = true, ["Cooking_ExpressoMachine"] = true,
			["DanceMachine"] = true, ["Gachapon_Arcade_01"] = true,
			["Gachapon_Arcade_02"] = true, ["Gachapon_Arcade_03"] = true,
		}

		local function removeMachineESP(model)
			if machineActive[model] then
				pcall(function()
					machineActive[model].highlight:Destroy()
					machineActive[model].billboard:Destroy()
				end)
				machineActive[model] = nil
			end
		end

		local function clearAllMachines()
			for m in pairs(machineActive) do
				removeMachineESP(m)
			end
		end

		if state then
			if machineLoopRunning then return end
			machineLoopRunning = true

			task.spawn(function()
				while machineEspEnabled do
					for _, obj in ipairs(workspace:GetDescendants()) do
						if obj:IsA("Model") and not ignoredNames[obj.Name] and obj.Name ~= "BaseMachine" and obj.Name ~= "BaseMachine_Mirror" then
							local nameLower = obj.Name:lower()
							local isMachine = (nameLower == "generator" or nameLower == "generators" or nameLower:find("generator") or nameLower:find("dual_generator") or nameLower:find("dualgen") or nameLower:find("machine") or nameLower:find("trickortreatgen"))
							if isMachine and not isMachineCompleted(obj) then
								local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
								if part then
									if not machineActive[obj] then
										local hl = Instance.new("Highlight")
										hl.Adornee = obj
										hl.FillTransparency = 0.65
										hl.OutlineTransparency = 0
										hl.OutlineColor = Color3.fromRGB(255, 220, 80)
										hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
										hl.Parent = obj

										local bb = Instance.new("BillboardGui")
										bb.Adornee = part
										bb.Size = UDim2.new(0, 130, 0, 26)
										bb.StudsOffset = Vector3.new(0, 2.5, 0)
										bb.AlwaysOnTop = true
										bb.Parent = obj

										local lbl = Instance.new("TextLabel")
										lbl.Size = UDim2.new(1, 0, 1, 0)
										lbl.BackgroundTransparency = 1
										lbl.Font = Enum.Font.FredokaOne
										lbl.TextSize = 11
										lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
										lbl.TextStrokeTransparency = 0.2
										lbl.Parent = bb

										machineActive[obj] = { highlight = hl, billboard = bb, label = lbl }
									end

									local stats = obj:FindFirstChild("Stats")
									local reqValObj = (stats and stats:FindFirstChild("RequiredAmount")) or obj:FindFirstChild("RequiredAmount", true)
									local curValObj = (stats and stats:FindFirstChild("CurrentAmount")) or obj:FindFirstChild("CurrentAmount", true)
									local reqAmt = math.floor(tonumber(reqValObj and reqValObj.Value) or 0)
									local curAmt = math.floor(tonumber(curValObj and curValObj.Value) or 0)
									local connieVal = obj:FindFirstChild("Connie", true)

									if connieVal and connieVal.Value == true then
										machineActive[obj].label.Text = "Possessed Machine"
										machineActive[obj].label.TextColor3 = Color3.fromRGB(135, 206, 250)
									else
										machineActive[obj].label.Text = string.format("Machine (%d/%d)", curAmt, reqAmt)
										machineActive[obj].label.TextColor3 = Color3.fromRGB(255, 220, 80)
									end
								end
							else
								removeMachineESP(obj)
							end
						end
					end

					for m in pairs(machineActive) do
						if not m or not m.Parent or isMachineCompleted(m) then
							removeMachineESP(m)
						end
					end

					task.wait(0.4)
				end

				clearAllMachines()
				machineLoopRunning = false
			end)
		else
			machineEspEnabled = false
			clearAllMachines()
			machineLoopRunning = false
		end
	end
})

-- ================= TELEPORT TAB =================
local TeleportTab = Window:Tab({
	Title = "Teleport",
	Icon = "navigation",
})

TeleportTab:Button({
	Title = "Teleport To Elevator",
	Desc = "Teleport to Elevator.",
	Callback = function()
		local hrp = getHRP()
		if not hrp then return end
		local elevatorsFolder = Workspace:FindFirstChild("Elevators")
		local targetPos = nil
		if elevatorsFolder then
			local elevator = elevatorsFolder:FindFirstChild("Elevator") or elevatorsFolder:FindFirstChildOfClass("Model")
			if elevator then
				local part = elevator.PrimaryPart or elevator:FindFirstChildWhichIsA("BasePart", true)
				if part then targetPos = part.Position end
			end
		end
		if not targetPos then
			for _, obj in ipairs(Workspace:GetDescendants()) do
				if obj.Name == "Elevator" or obj.Name == "ElevatorDoor" then
					local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)) or (obj:IsA("BasePart") and obj)
					if part then targetPos = part.Position; break end
				end
			end
		end
		if targetPos then
			if isTwistedNearby(targetPos, 30) then
				notify("Teleport", "Twisted Nearby.", 2)
				return
			end
			hrp.CFrame = CFrame.new(targetPos) + Vector3.new(0, 3, 0)
		else
			teleportTo("elevator", false)
		end
	end,
})

TeleportTab:Button({
	Title = "Teleport To Machine",
	Desc = "TP to a safe machine",
	Callback = function()
		performTeleportToMachine()
	end,
})

local tpItemList = {
	"AirHorn", "SmokeBomb", "ResearchCapsule", "ProteinBar", "Jawbreaker", "EjectButton",
	"HealthKit", "Bandage", "Tape", "Instructions", "ExtractionSpeedCandy", "SkillCheckCandy",
	"StaminaCandy", "StealthCandy", "SpeedCandy", "Gumball", "BonBon", "Chocolate",
	"ChocolateBox", "Pop", "PopBottle", "JumperCable", "Stopwatch", "ChristmasCookie",
	"DandyEasterEggs", "Pumpkin", "FakeCapsule"
}
local selectedTpItem = tpItemList[1]

TeleportTab:Dropdown({
	Title = "Select Item",
	Values = tpItemList,
	Value = tpItemList[1],
	Callback = function(opt)
		selectedTpItem = type(opt) == "table" and opt[1] or opt
	end,
})

TeleportTab:Button({
	Title = "Teleport To Selected Item",
	Callback = function()
		teleportTo(selectedTpItem, true)
	end,
})

-- ================= AUTOMATION TAB =================
local AutomationTab = Window:Tab({
	Title = "Automation",
	Icon = "bot",
})

local autoSkillcheckEnabled = false
AutomationTab:Toggle({
	Title = "Auto Skillcheck",
	Desc = "Automatically does the skillcheck.",
	Value = false,
	Callback = function(state)
		autoSkillcheckEnabled = state
	end,
})

task.spawn(function()
	while true do
		if autoSkillcheckEnabled then
			pcall(function()
				local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
				if playerGui then
					for _, gui in ipairs(playerGui:GetDescendants()) do
						if gui:IsA("GuiObject") and gui.Visible then
							local n = gui.Name:lower()
							if n:find("skillcheck") or n:find("skill_check") then
								if gui:IsA("TextButton") or gui:IsA("ImageButton") then
									firesignal(gui.MouseButton1Click)
								else
									local cx = gui.AbsolutePosition.X + (gui.AbsoluteSize.X / 2)
									local cy = gui.AbsolutePosition.Y + (gui.AbsoluteSize.Y / 2)
									VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
									task.wait(0.03)
									VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
									VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
									task.wait(0.03)
									VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, false, game, 1)
								end
								break
							end
						end
					end
				end
			end)
		end
		task.wait(0.15)
	end
end)

local autoFarmMachinesEnabled = false
AutomationTab:Toggle({
	Title = "Auto Farm Machines",
	Desc = "Automatically teleports you to a machine.",
	Value = false,
	Callback = function(state)
		autoFarmMachinesEnabled = state
	end,
})

task.spawn(function()
	while true do
		if autoFarmMachinesEnabled then
			pcall(function()
				local hrp = getHRP()
				if hrp then
					if isTwistedNearby(hrp.Position, 28) then
						performTeleportToMachine()
						task.wait(2)
					else
						local foundPrompt = false
						for _, obj in ipairs(workspace:GetDescendants()) do
							if obj:IsA("ProximityPrompt") and obj.Enabled and obj.Parent then
								local pName = obj.Parent.Name:lower()
								local anc = obj.Parent
								local isGen = pName:find("generator") or pName:find("machine")
								while anc and anc ~= workspace and not isGen do
									local aName = anc.Name:lower()
									if aName:find("generator") or aName:find("dualgen") or aName:find("trickortreatgen") then
										isGen = true
										break
									end
									anc = anc.Parent
								end
								if isGen and anc and not isMachineCompleted(anc) then
									local pos = obj.Parent:IsA("BasePart") and obj.Parent.Position or (anc:IsA("Model") and anc:GetPivot().Position)
									if pos and canInteractWithPosition(pos) then
										if (pos - hrp.Position).Magnitude > 10 then
											hrp.CFrame = CFrame.new(pos) + Vector3.new(0, 3, 0)
											task.wait(0.4)
										end
										fireproximityprompt(obj)
										foundPrompt = true
										break
									end
								end
							end
						end
						if not foundPrompt then
							performTeleportToMachine()
							task.wait(2.5)
						end
					end
				end
			end)
			task.wait(1.2)
		else
			task.wait(0.4)
		end
	end
end)

local autoCollectItemsEnabled = false
AutomationTab:Toggle({
	Title = "Auto Collect Items",
	Desc = "Automatically collects items for you.",
	Value = false,
	Callback = function(state)
		autoCollectItemsEnabled = state
	end,
})

task.spawn(function()
	while true do
		if autoCollectItemsEnabled then
			pcall(function()
				local hrp = getHRP()
				if hrp then
					for _, obj in ipairs(workspace:GetDescendants()) do
						if obj:IsA("Model") and itemTargets[obj.Name] and obj.Name ~= "FakeCapsule" then
							local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
							if part and canInteractWithPosition(part.Position) then
								hrp.CFrame = part.CFrame + Vector3.new(0, 3, 0)
								task.wait(0.25)
								for _, desc in ipairs(obj:GetDescendants()) do
									if desc:IsA("ProximityPrompt") and desc.Enabled then
										fireproximityprompt(desc)
									end
								end
								task.wait(0.6)
								break
							end
						end
					end
				end
			end)
			task.wait(1)
		else
			task.wait(0.4)
		end
	end
end)

local autoUseItemsEnabled = false
AutomationTab:Toggle({
	Title = "Auto Use Items",
	Desc = "Auto-use inventory items.",
	Value = false,
	Callback = function(v)
		autoUseItemsEnabled = v
	end,
})

task.spawn(function()
	while true do
		if autoUseItemsEnabled then
			pcall(function()
				local char = LocalPlayer.Character
				if char and char:FindFirstChild("Inventory") then
					local inv = char.Inventory
					for i = 1, 3 do
						local slot = inv:FindFirstChild("Slot" .. tostring(i))
						if slot and ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("ItemEvent") then
							ReplicatedStorage.Events.ItemEvent:InvokeServer(char, slot)
						end
					end
				end
			end)
		end
		task.wait(1)
	end
end)

local autoAbilityEnabled = false
AutomationTab:Toggle({
	Title = "Auto Use Ability",
	Desc = "Auto-use ability.",
	Value = false,
	Callback = function(v)
		autoAbilityEnabled = v
	end,
})

task.spawn(function()
	while true do
		if autoAbilityEnabled then
			local hrp = getHRP()
			pcall(function()
				if LocalPlayer.Character and hrp and ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("AbilityEvent") then
					ReplicatedStorage.Events.AbilityEvent:InvokeServer(LocalPlayer.Character, hrp.CFrame, false)
				end
			end)
		end
		task.wait(1.5)
	end
end)

-- ================= OTHER SCRIPTS TAB =================
local OtherScriptsTab = Window:Tab({
	Title = "Other Scripts",
	Icon = "settings",
})

OtherScriptsTab:Button({
	Title = "Load VoidExtractor",
	Desc = "Autofarm script",
	Callback = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/seannstar/voidextractor/refs/heads/main/VoidExtractor.lua"))()
	end
})

OtherScriptsTab:Button({
	Title = "Load BSGUI",
	Desc = "Boxten Sex Gui",
	Color = Color3.fromHex("#805d8f"),
	Callback = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/Team-Noxious/Roblox/refs/heads/main/Loader.lua"))("Boxten Sex GUI")
	end
})

OtherScriptsTab:Button({
	Title = "Load Riddance Hub",
	Desc = "Riddance Hub",
	Color = Color3.fromHex("#19191a"),
	Callback = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/riddance-club/script/refs/heads/main/loader.lua"))()
	end
})

-- ================= PLAYER TAB =================
local PlayerTab = Window:Tab({
	Title = "Player",
	Icon = "user",
})

-- thanks abstractlite !!
PlayerTab:Button({
	Title = "Infinite Stamina",
	Desc = "Gives you infinite stamina.",
	Color = Color3.fromHex("#19191a"),
	Callback = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/abelsrighthand/AbstractLite/refs/heads/main/abstractlite(infstam).lua"))()
	end
})

local adPopupsBlockEnabled = false
local popUpEventConnection = nil

PlayerTab:Toggle({
	Title = "Anti Twisted Vee Popup",
	Desc = "Block Vee popups.",
	Default = false,
	Callback = function(v)
		adPopupsBlockEnabled = v
		if adPopupsBlockEnabled then
			pcall(function()
				local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
				if eventsFolder then
					local popUpEvent = eventsFolder:FindFirstChild("PopUpEvent")
					if popUpEvent and getconnections then
						for _, conn in ipairs(getconnections(popUpEvent.OnClientEvent)) do
							conn:Disable()
						end
					end
				end
			end)

			if not popUpEventConnection then
				popUpEventConnection = ReplicatedStorage.DescendantAdded:Connect(function(descendant)
					if adPopupsBlockEnabled and descendant.Name == "PopUpEvent" and descendant:IsA("RemoteEvent") then
						pcall(function()
							for _, conn in ipairs(getconnections(descendant.OnClientEvent)) do
								conn:Disable()
							end
						end)
					end
				end)
			end
		else
			if popUpEventConnection then
				popUpEventConnection:Disconnect()
				popUpEventConnection = nil
			end
			pcall(function()
				local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
				if eventsFolder then
					local popUpEvent = eventsFolder:FindFirstChild("PopUpEvent")
					if popUpEvent and getconnections then
						for _, conn in ipairs(getconnections(popUpEvent.OnClientEvent)) do
							conn:Enable()
						end
					end
				end
			end)
		end
	end,
})

local itemAuraEnabled = false
PlayerTab:Toggle({
	Title = "Item Aura",
	Desc = "Grab items around the map.",
	Default = false,
	Callback = function(v)
		itemAuraEnabled = v
	end,
})

task.spawn(function()
	while true do
		local hrp = getHRP()
		if itemAuraEnabled and hrp then
			pcall(function()
				for _, obj in ipairs(workspace:GetDescendants()) do
					if obj:IsA("ProximityPrompt") then
						local parentPart = obj.Parent
						if parentPart then
							local promptPos = parentPart:IsA("BasePart") and parentPart.Position or (parentPart:IsA("Model") and (parentPart.PrimaryPart and parentPart.PrimaryPart.Position or parentPart:GetPivot().Position))
							if promptPos then
								if (promptPos - hrp.Position).Magnitude <= (obj.MaxActivationDistance or 15) then
									local isForbidden = false
									local currentAncestor = parentPart
									while currentAncestor and currentAncestor ~= workspace do
										if currentAncestor.Name == "GourdyMonster" or currentAncestor.Name == "FakeCapsule" then
											isForbidden = true
											break
										end
										currentAncestor = currentAncestor.Parent
									end

									if not isForbidden and not isElevatorNearby(promptPos, 15) and canInteractWithPosition(promptPos) then
										fireproximityprompt(obj)
									end
								end
							end
						end
					end
				end
			end)
			task.wait(0.5)
		else
			task.wait(0.25)
		end
	end
end)
