-- Delta Overlay for Car Crushers 2 (Delta iOS)
-- Load (cache bust if button stuck): loadstring(game:HttpGet("https://raw.githubusercontent.com/Dev-Vexor/cc2-scripts/main/CarCrushers.lua?v=" .. os.time()))()

-- Delta Overlay bundled build (generated)
-- Host this file and load with loader.lua / HttpGet

local MODULES = {
	["src/Platform.lua"] = [=[
local Platform = {}

function Platform.isMobile()
	return game:GetService("UserInputService").TouchEnabled
end

function Platform.isDelta()
	return typeof(getgenv) == "function" and (readfile ~= nil or game.HttpGet ~= nil or request ~= nil)
end

function Platform.httpGet(url)
	if typeof(game.HttpGet) == "function" then
		return game:HttpGet(url)
	end
	if typeof(game.HttpGetAsync) == "function" then
		return game:HttpGetAsync(url)
	end
	if syn and syn.request then
		local response = syn.request({ Url = url, Method = "GET" })
		return response.Body
	end
	if http_request then
		return http_request({ Url = url, Method = "GET" }).Body
	end
	if request then
		return request({ Url = url, Method = "GET" }).Body
	end
	error("HttpGet unavailable — update Delta Executor")
end

function Platform.waitReady()
	repeat
		task.wait()
	until game:IsLoaded()

	local Players = game:GetService("Players")
	local localPlayer = Players.LocalPlayer
	if not localPlayer then
		localPlayer = Players.PlayerAdded:Wait()
	end

	if not localPlayer.Character then
		localPlayer.CharacterAdded:Wait()
	end

	local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		repeat
			task.wait()
		until humanoid.SeatPart or humanoid.Health > 0
	end

	task.wait(Platform.isMobile() and 0.35 or 0.15)
	return localPlayer
end

function Platform.getGuiParent(_localPlayer)
	local function protect(gui)
		pcall(function()
			if syn and syn.protect_gui then
				syn.protect_gui(gui)
			end
		end)
		pcall(function()
			local g = getgenv and getgenv() or _G
			if typeof(g.protectgui) == "function" then
				g.protectgui(gui)
			end
		end)
	end

	if typeof(gethui) == "function" then
		local hui = gethui()
		protect(hui)
		return hui
	end
	if typeof(get_hidden_gui) == "function" then
		return get_hidden_gui()
	end

	local CoreGui = game:GetService("CoreGui")
	protect(CoreGui)
	return CoreGui
end

function Platform.notify(title, text)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = title,
			Text = text,
			Duration = 5,
		})
	end)
end

return Platform
]=],
	["src/Config.lua"] = [=[
local Config = {}

Config.VERSION = "2.1.0"
Config.UI_BUILD = "GUARD"

Config.DERBY = {
	MIN_POWER = 200,
	MAX_POWER = 900,
}
Config.LAYOUT_VERSION = 5

Config.FLY = {
	MIN_SPEED = 16,
	MAX_SPEED = 600,
	SPEED_STEP = 10,
}

Config.PLACE_IDS = {
	CC2 = 654732683,
}

Config.REMOTE = {
	BUNDLE_URL = "",
	VERSION_URL = "",
}

Config.DETECTION = {
	USE_BODY_MOVERS = false,
	SMOOTH_TELEPORT_DEFAULT = true,
	SMOOTH_TELEPORT_STEPS = 6,
	MAX_TELEPORT_STUDS_PER_STEP = 35,
}

Config.MOBILE = {
	AUTO_DRIVE_DEFAULT = true,
	FLY_SPEED_SCALE = 100,
}

Config.WORKSPACE_MARKERS = {
	spawn = {
		"Spawn",
		"Spawns",
		"SpawnLocation",
		"Dealership",
		"PlayerSpawn",
		"Destruction Facility",
	},
	arena = {
		"Derby",
		"Demolition",
		"Arena",
		"DemolitionDerby",
		"DerbyArena",
		"DerbyMode",
	},
}

return Config
]=],
	["src/Theme.lua"] = [=[
--[[ Design tokens — section 7 ]]

local Theme = {}

Theme.Colors = {
	bgPrimary = Color3.fromRGB(28, 28, 30),
	bgSecondary = Color3.fromRGB(44, 44, 46),
	accent = Color3.fromRGB(255, 59, 48),
	textPrimary = Color3.fromRGB(255, 255, 255),
	textSecondary = Color3.fromRGB(142, 142, 147),
	success = Color3.fromRGB(52, 199, 89),
	danger = Color3.fromRGB(255, 69, 58),
	buttonGlass = Color3.fromRGB(22, 22, 24),
}

Theme.Fonts = {
	header = Enum.Font.GothamSemibold,
	body = Enum.Font.Gotham,
	mono = Enum.Font.RobotoMono,
}

Theme.Sizes = {
	header = 15,
	body = 13,
	mono = 12,
	minTouch = 36,
	floatingButton = 46,
	cornerSheet = 18,
	cornerButton = 10,
	avatar = 32,
	grabberWidth = 32,
	grabberHeight = 4,
	panelHeight = 0.58,
	contentPadding = 10,
}

Theme.Transparency = {
	idleButton = 0.12,
	activeButton = 0,
	sheetMaterial = 0.08,
}

return Theme
]=],
	["src/Utils.lua"] = [=[
local Utils = {}

function Utils.hex(hex)
	local r = tonumber(hex:sub(2, 3), 16)
	local g = tonumber(hex:sub(4, 5), 16)
	local b = tonumber(hex:sub(6, 7), 16)
	return Color3.fromRGB(r, g, b)
end

function Utils.clamp(value, min, max)
	return math.max(min, math.min(max, value))
end

function Utils.debounce(delay, fn)
	local token = 0
	return function(...)
		local args = { ... }
		token += 1
		local current = token
		task.delay(delay, function()
			if current == token then
				fn(table.unpack(args))
			end
		end)
	end
end

function Utils.getSavedPoint(key, default)
	local g = getgenv and getgenv() or _G
	if g.DeltaOverlay and g.DeltaOverlay[key] then
		return g.DeltaOverlay[key]
	end
	if readfile and isfile and isfile("delta_overlay/settings.json") then
		local ok, data = pcall(function()
			return game:GetService("HttpService"):JSONDecode(readfile("delta_overlay/settings.json"))
		end)
		if ok and data and data[key] then
			g.DeltaOverlay = g.DeltaOverlay or {}
			g.DeltaOverlay[key] = data[key]
			return data[key]
		end
	end
	return default
end

function Utils.savePoint(key, point)
	local g = getgenv and getgenv() or _G
	g.DeltaOverlay = g.DeltaOverlay or {}
	g.DeltaOverlay[key] = point
	if writefile then
		pcall(function()
			local HttpService = game:GetService("HttpService")
			if makefolder then
				pcall(makefolder, "delta_overlay")
			end
			writefile("delta_overlay/settings.json", HttpService:JSONEncode(g.DeltaOverlay))
		end)
	end
end

function Utils.getGuiInset()
	local inset = Vector2.zero
	pcall(function()
		inset = game:GetService("GuiService"):GetGuiInset()
	end)
	return inset
end

function Utils.getScreenMetrics()
	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(390, 844)
	local inset = Utils.getGuiInset()
	local sidePad = 10
	local topPad = Utils.isMobile() and math.max(inset.Y + 52, 56) or math.max(inset.Y + 12, 12)
	local bottomPad = 16
	local width = math.max(viewport.X - sidePad * 2, 120)
	local usableHeight = math.max(viewport.Y - topPad - bottomPad, 160)

	return {
		viewport = viewport,
		inset = inset,
		left = sidePad,
		topY = topPad,
		width = width,
		usableHeight = usableHeight,
		maxPanelHeight = math.floor(usableHeight * 0.72),
		minPanelHeight = math.floor(math.min(usableHeight * 0.42, 280)),
	}
end

-- Roblox mobile UI zones (xMin, xMax, yMin, yMax) in screen scale
Utils.ROBLOX_UI_ZONES = {
	{ 0.0, 0.24, 0.0, 0.20 }, -- top-left: Roblox menu / logo
	{ 0.45, 1.01, 0.0, 1.01 }, -- entire right side on mobile
	{ 0.0, 0.30, 0.62, 1.01 }, -- bottom-left: move stick
}

function Utils.isMobile()
	return game:GetService("UserInputService").TouchEnabled
end

function Utils.getDefaultButtonPosition()
	if Utils.isMobile() then
		return { x = 0.10, y = 0.58 }
	end
	return { x = 0.94, y = 0.5 }
end

function Utils.getDefaultButtonOffset(radiusPx)
	local inset = Utils.getGuiInset()
	local viewport = workspace.CurrentCamera.ViewportSize
	radiusPx = radiusPx or 30

	if viewport.X <= 0 or viewport.Y <= 0 then
		return { mode = "offset", x = 56, y = 420 }
	end

	local cx = inset.X + radiusPx + 16
	local safeHeight = math.max(viewport.Y - inset.Y * 2, 1)
	local cy = inset.Y + safeHeight * 0.52

	return { mode = "offset", x = cx, y = cy }
end

function Utils.isRobloxUiZone(x, y)
	if not Utils.isMobile() then
		return false
	end
	for _, zone in ipairs(Utils.ROBLOX_UI_ZONES) do
		if x >= zone[1] and x <= zone[2] and y >= zone[3] and y <= zone[4] then
			return true
		end
	end
	return false
end

function Utils.sanitizeButtonPosition(point, radiusPx)
	if Utils.isMobile() then
		local defaultOffset = Utils.getDefaultButtonOffset(radiusPx)
		if typeof(point) ~= "table" or typeof(point.x) ~= "number" or typeof(point.y) ~= "number" then
			return defaultOffset
		end

		if point.mode == "offset" then
			local viewport = workspace.CurrentCamera.ViewportSize
			local inset = Utils.getGuiInset()
			if point.y < inset.Y + 72 then
				return defaultOffset
			end
			if point.x > viewport.X * 0.38 then
				return defaultOffset
			end
			if point.x < viewport.X * 0.30 and point.y > viewport.Y * 0.62 then
				return defaultOffset
			end
			return point
		end

		if point.x > 0.38 or point.y < 0.22 or Utils.isRobloxUiZone(point.x, point.y) then
			return defaultOffset
		end

		local viewport = workspace.CurrentCamera.ViewportSize
		local inset = Utils.getGuiInset()
		local safeWidth = math.max(viewport.X - inset.X, 1)
		local safeHeight = math.max(viewport.Y - inset.Y * 2, 1)
		return {
			mode = "offset",
			x = inset.X + point.x * safeWidth,
			y = inset.Y + point.y * safeHeight,
		}
	end

	local defaultPos = Utils.getDefaultButtonPosition()
	if typeof(point) ~= "table" or typeof(point.x) ~= "number" or typeof(point.y) ~= "number" then
		return defaultPos
	end
	if Utils.isRobloxUiZone(point.x, point.y) then
		return defaultPos
	end
	return point
end

function Utils.clampHudOffset(cx, cy, width, height)
	local viewport = workspace.CurrentCamera.ViewportSize
	local inset = Utils.getGuiInset()
	width = width or 172
	height = height or 112
	local minX = 6
	local maxX = math.max(minX, viewport.X - width - 6)
	local minY = math.max(inset.Y + 8, 8)
	local maxY = math.max(minY, viewport.Y - height - 8)
	return Utils.clamp(cx, minX, maxX), Utils.clamp(cy, minY, maxY)
end

function Utils.clampButtonOffset(cx, cy, radiusPx)
	local inset = Utils.getGuiInset()
	local viewport = workspace.CurrentCamera.ViewportSize
	local minX = inset.X + radiusPx + 8
	local maxX = viewport.X * 0.38
	local minY = inset.Y + 72
	local maxY = viewport.Y - inset.Y - radiusPx - 8

	cx = Utils.clamp(cx, minX, maxX)
	cy = Utils.clamp(cy, minY, maxY)
	return cx, cy
end

function Utils.clampButtonPosition(x, y, radiusPx)
	local inset = Utils.getGuiInset()
	local viewport = workspace.CurrentCamera.ViewportSize
	local padX = (inset.X + radiusPx) / viewport.X
	local padY = (inset.Y + radiusPx) / viewport.Y

	local minX = math.max(padX, 0.07)
	local maxX = Utils.isMobile() and 0.38 or (1 - math.max(padX, 0.07))
	local minY = math.max(padY, 0.12)
	local maxY = 1 - math.max(padY, 0.14)

	x = Utils.clamp(x, minX, maxX)
	y = Utils.clamp(y, minY, maxY)

	if Utils.isRobloxUiZone(x, y) then
		local def = Utils.getDefaultButtonPosition()
		return def.x, def.y
	end

	return x, y
end

function Utils.resetButtonLayout(layoutVersion)
	local g = getgenv and getgenv() or _G
	g.DeltaOverlay = g.DeltaOverlay or {}
	if g.DeltaOverlay.layoutVersion ~= layoutVersion then
		g.DeltaOverlay.buttonPosition = nil
		g.DeltaOverlay.buttonPositionV2 = nil
		g.DeltaOverlay.buttonPositionV3 = nil
		g.DeltaOverlay.layoutVersion = layoutVersion
		if writefile and isfile and isfile("delta_overlay/settings.json") then
			pcall(function()
				local HttpService = game:GetService("HttpService")
				writefile("delta_overlay/settings.json", HttpService:JSONEncode(g.DeltaOverlay))
			end)
		end
	end
end

function Utils.distanceBetween(a, b)
	return (a - b).Magnitude
end

function Utils.getCharacterRoot(player)
	local char = player and player.Character
	if not char then
		return nil
	end
	return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
end

function Utils.getLocalRoot()
	local lp = game:GetService("Players").LocalPlayer
	return Utils.getCharacterRoot(lp)
end

function Utils.tween(instance, tweenInfo, props)
	local TweenService = game:GetService("TweenService")
	local tween = TweenService:Create(instance, tweenInfo, props)
	tween:Play()
	return tween
end

function Utils.springScale(button, scale)
	local uiScale = button:FindFirstChildOfClass("UIScale")
	if not uiScale then
		uiScale = Instance.new("UIScale")
		uiScale.Parent = button
	end
	Utils.tween(uiScale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0), {
		Scale = scale,
	})
	task.delay(0.12, function()
		Utils.tween(uiScale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
	end)
end

function Utils.holdRepeat(guiObject, onTick, initialDelay, interval, onRelease)
	initialDelay = initialDelay or 0.35
	interval = interval or 0.06
	local active = false

	local function begin()
		active = true
		onTick()
		task.spawn(function()
			task.wait(initialDelay)
			while active and guiObject.Parent do
				onTick()
				task.wait(interval)
			end
		end)
	end

	local function stop()
		if not active then
			return
		end
		active = false
		if onRelease then
			onRelease()
		end
	end

	guiObject.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1
		then
			begin()
		end
	end)

	guiObject.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1
		then
			stop()
		end
	end)

	guiObject.InputChanged:Connect(function(input)
		if input.UserInputState == Enum.UserInputState.End then
			stop()
		end
	end)
end

return Utils
]=],
	["src/Animation.lua"] = [=[
local Animation = {}

function Animation.easeOutCubic(t)
	return 1 - (1 - t) ^ 3
end

function Animation.easeInCubic(t)
	return t * t * t
end

function Animation.topPanelPresent(frame, openY, onComplete)
	local TweenService = game:GetService("TweenService")
	local hidden = UDim2.new(0.5, 0, 0, openY - frame.AbsoluteSize.Y - 40)
	frame.Position = hidden
	frame.Visible = true
	local tween = TweenService:Create(
		frame,
		TweenInfo.new(0.28, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
		{ Position = UDim2.new(0.5, 0, 0, openY) }
	)
	tween:Play()
	if onComplete then
		tween.Completed:Once(onComplete)
	end
	return tween
end

function Animation.topPanelDismiss(frame, openY, onComplete)
	local TweenService = game:GetService("TweenService")
	local hidden = UDim2.new(0.5, 0, 0, openY - frame.AbsoluteSize.Y - 40)
	local tween = TweenService:Create(
		frame,
		TweenInfo.new(0.22, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
		{ Position = hidden }
	)
	tween:Play()
	tween.Completed:Once(function()
		frame.Visible = false
		if onComplete then
			onComplete()
		end
	end)
	return tween
end

-- Legacy aliases (unused after 1.4.0)
function Animation.sheetPresent(frame, onComplete)
	return Animation.topPanelPresent(frame, frame.Position.Y.Offset, onComplete)
end

function Animation.sheetDismiss(frame, onComplete)
	return Animation.topPanelDismiss(frame, frame.Position.Y.Offset, onComplete)
end

function Animation.crossfade(hideFrame, showFrame, duration)
	duration = duration or 0.2
	if hideFrame then
		hideFrame.Visible = false
	end
	if showFrame then
		showFrame.Visible = true
	end
end

function Animation.staggerFade(children, interval)
	interval = interval or 0.05
	for index, child in ipairs(children) do
		if child:IsA("GuiObject") then
			child.BackgroundTransparency = 1
			if child:IsA("TextLabel") then
				child.TextTransparency = 1
			end
			task.delay((index - 1) * interval, function()
				game:GetService("TweenService"):Create(child, TweenInfo.new(0.2), {
					BackgroundTransparency = child:GetAttribute("TargetTransparency") or 0,
					TextTransparency = 0,
				}):Play()
			end)
		end
	end
end

return Animation
]=],
	["src/State.lua"] = [=[
local State = {
	menuOpen = false,
	activeTab = "Fly",
	minimalMode = false,
	flyEnabled = false,
	flyHudOpen = false,
	godMode = true,
	flySpeed = 80,
	flyReference = "Camera",
	flyVertical = 0,
	flyForward = 0,
	flyStrafe = 0,
	autoDrive = true,
	seatLock = true,
	flyMode = "Off",
	presenceGuard = false,
	searchQuery = "",
	players = {},
	statusText = "Ready",
	derbyAutoKnock = false,
	derbyPower = 420,
	derbyBusy = false,
	derbyTarget = nil,
}

return State
]=],
	["src/Haptic.lua"] = [=[
local Haptic = {}

function Haptic.lightImpact()
	pcall(function()
		local HapticService = game:GetService("HapticService")
		local motor = Enum.HapticEffectType.UIHover
		if HapticService:IsMotorSupported(motor) then
			HapticService:SetMotor(motor, 0.45)
			task.delay(0.06, function()
				HapticService:SetMotor(motor, 0)
			end)
		end
	end)
end

return Haptic
]=],
	["src/Components.lua"] = [=[
local Components = {}

function Components.createLabel(props)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Font = props.font or Enum.Font.GothamSemibold
	label.TextSize = props.size or 17
	label.TextColor3 = props.color or Color3.new(1, 1, 1)
	label.TextXAlignment = props.align or Enum.TextXAlignment.Left
	label.Text = props.text or ""
	label.Size = props.sizeDim or UDim2.fromScale(1, 0)
	label.AutomaticSize = props.auto or Enum.AutomaticSize.Y
	label.Parent = props.parent
	return label
end

function Components.createSwitch(props)
	local Theme = props.theme
	local container = Instance.new("Frame")
	container.Name = props.name or "SwitchRow"
	container.BackgroundTransparency = 1
	container.Size = UDim2.new(1, 0, 0, Theme.Sizes.minTouch)
	container.Parent = props.parent

	local label = Components.createLabel({
		parent = container,
		text = props.label,
		font = Theme.Fonts.body,
		size = Theme.Sizes.body,
		color = Theme.Colors.textPrimary,
		sizeDim = UDim2.new(1, -70, 1, 0),
		auto = Enum.AutomaticSize.None,
	})

	local track = Instance.new("TextButton")
	track.Name = "Track"
	track.AutoButtonColor = false
	track.Text = ""
	track.Size = UDim2.fromOffset(51, 31)
	track.Position = UDim2.new(1, -51, 0.5, 0)
	track.AnchorPoint = Vector2.new(0, 0.5)
	track.BackgroundColor3 = Theme.Colors.bgSecondary
	track.Parent = container

	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(1, 0)
	trackCorner.Parent = track

	local knob = Instance.new("Frame")
	knob.Name = "Knob"
	knob.Size = UDim2.fromOffset(27, 27)
	knob.Position = UDim2.fromOffset(2, 2)
	knob.BackgroundColor3 = Theme.Colors.textPrimary
	knob.Parent = track

	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(1, 0)
	knobCorner.Parent = knob

	local enabled = props.default or false

	local function render(value)
		enabled = value
		track.BackgroundColor3 = value and Theme.Colors.success or Theme.Colors.bgSecondary
		knob.Position = value and UDim2.new(1, -29, 0.5, 0) or UDim2.fromOffset(2, 2)
		knob.AnchorPoint = value and Vector2.new(0, 0.5) or Vector2.new(0, 0)
	end

	render(enabled)

	track.MouseButton1Click:Connect(function()
		render(not enabled)
		if props.onChange then
			props.onChange(enabled)
		end
	end)

	return container, {
		set = render,
		get = function()
			return enabled
		end,
	}
end

function Components.createSlider(props)
	local Theme = props.theme
	local Utils = props.utils
	local container = Instance.new("Frame")
	container.BackgroundTransparency = 1
	container.Size = UDim2.new(1, 0, 0, 58)
	container.Parent = props.parent

	Components.createLabel({
		parent = container,
		text = props.label,
		font = Theme.Fonts.body,
		size = Theme.Sizes.body,
		color = Theme.Colors.textPrimary,
		sizeDim = UDim2.new(1, -80, 0, 22),
		auto = Enum.AutomaticSize.None,
	})

	local valueLabel = Components.createLabel({
		parent = container,
		text = tostring(props.default or props.min),
		font = Theme.Fonts.mono,
		size = Theme.Sizes.mono,
		color = Theme.Colors.textSecondary,
		align = Enum.TextXAlignment.Right,
		sizeDim = UDim2.new(0, 80, 0, 22),
		auto = Enum.AutomaticSize.None,
	})
	valueLabel.Position = UDim2.new(1, -80, 0, 0)

	local track = Instance.new("Frame")
	track.Name = "Track"
	track.Size = UDim2.new(1, 0, 0, 4)
	track.Position = UDim2.new(0, 0, 0, 36)
	track.BackgroundColor3 = Theme.Colors.bgSecondary
	track.Parent = container

	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(1, 0)
	trackCorner.Parent = track

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.BackgroundColor3 = Theme.Colors.accent
	fill.Size = UDim2.fromScale(0.5, 1)
	fill.Parent = track

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = fill

	local knob = Instance.new("TextButton")
	knob.Name = "Knob"
	knob.AutoButtonColor = false
	knob.Text = ""
	knob.Size = UDim2.fromOffset(28, 28)
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = UDim2.fromScale(0.5, 0.5)
	knob.BackgroundColor3 = Theme.Colors.textPrimary
	knob.Parent = track

	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(1, 0)
	knobCorner.Parent = knob

	local min = props.min or 0
	local max = props.max or 100
	local value = props.default or min

	local function setValue(nextValue, silent)
		value = Utils.clamp(nextValue, min, max)
		local alpha = (value - min) / (max - min)
		fill.Size = UDim2.fromScale(alpha, 1)
		knob.Position = UDim2.fromScale(alpha, 0.5)
		valueLabel.Text = string.format("%d pt/s", math.floor(value + 0.5))
		if not silent and props.onChange then
			props.onChange(value)
		end
	end

	setValue(value, true)

	local dragging = false
	local function updateFromInput(input)
		local rel = track.AbsolutePosition
		local width = track.AbsoluteSize.X
		if width <= 0 then
			return
		end
		local alpha = Utils.clamp((input.Position.X - rel.X) / width, 0, 1)
		setValue(min + (max - min) * alpha)
	end

	knob.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1
		then
			dragging = true
		end
	end)

	game:GetService("UserInputService").InputChanged:Connect(function(input)
		if
			dragging
			and (
				input.UserInputType == Enum.UserInputType.Touch
				or input.UserInputType == Enum.UserInputType.MouseMovement
			)
		then
			updateFromInput(input)
		end
	end)

	game:GetService("UserInputService").InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1
		then
			dragging = false
		end
	end)

	return container, {
		set = setValue,
		get = function()
			return value
		end,
	}
end

function Components.createSegmented(props)
	local Theme = props.theme
	local container = Instance.new("Frame")
	container.BackgroundColor3 = Theme.Colors.bgSecondary
	container.Size = UDim2.new(1, 0, 0, Theme.Sizes.minTouch)
	container.Parent = props.parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = container

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.Padding = UDim.new(0, 4)
	layout.Parent = container

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 4)
	padding.PaddingRight = UDim.new(0, 4)
	padding.PaddingTop = UDim.new(0, 4)
	padding.PaddingBottom = UDim.new(0, 4)
	padding.Parent = container

	local selected = props.default or props.options[1]
	local buttons = {}

	local function select(option)
		selected = option
		for opt, button in pairs(buttons) do
			local active = opt == option
			button.BackgroundColor3 = active and Theme.Colors.accent or Theme.Colors.bgSecondary
			button.TextColor3 = active and Theme.Colors.textPrimary or Theme.Colors.textSecondary
		end
		if props.onChange then
			props.onChange(option)
		end
	end

	for _, option in ipairs(props.options) do
		local button = Instance.new("TextButton")
		button.AutoButtonColor = false
		button.Text = option
		button.Font = Theme.Fonts.body
		button.TextSize = Theme.Sizes.body
		button.Size = UDim2.new(1 / #props.options, -4, 1, 0)
		button.BackgroundColor3 = Theme.Colors.bgSecondary
		button.TextColor3 = Theme.Colors.textSecondary
		button.Parent = container

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 8)
		btnCorner.Parent = button

		button.MouseButton1Click:Connect(function()
			select(option)
		end)

		buttons[option] = button
	end

	selected = props.default or props.options[1]
	for opt, button in pairs(buttons) do
		local active = opt == selected
		button.BackgroundColor3 = active and Theme.Colors.accent or Theme.Colors.bgSecondary
		button.TextColor3 = active and Theme.Colors.textPrimary or Theme.Colors.textSecondary
	end

	return container, {
		set = select,
		get = function()
			return selected
		end,
	}
end

function Components.createActionButton(props)
	local Theme = props.theme
	local Utils = props.utils
	local button = Instance.new("TextButton")
	button.AutoButtonColor = false
	button.Text = props.text
	button.Font = Theme.Fonts.body
	button.TextSize = Theme.Sizes.body
	button.TextColor3 = Theme.Colors.textPrimary
	button.BackgroundColor3 = props.color or Theme.Colors.bgSecondary
	button.Size = props.size or UDim2.new(1, 0, 0, Theme.Sizes.minTouch)
	button.Parent = props.parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, Theme.Sizes.cornerButton)
	corner.Parent = button

	button.MouseButton1Click:Connect(function()
		Utils.springScale(button, 0.95)
		if props.onClick then
			props.onClick()
		end
	end)

	return button
end

function Components.createSearchField(props)
	local Theme = props.theme
	local container = Instance.new("Frame")
	container.BackgroundColor3 = Theme.Colors.bgSecondary
	container.Size = UDim2.new(1, 0, 0, Theme.Sizes.minTouch)
	container.Parent = props.parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = container

	local box = Instance.new("TextBox")
	box.BackgroundTransparency = 1
	box.ClearTextOnFocus = false
	box.PlaceholderText = props.placeholder or "Search"
	box.PlaceholderColor3 = Theme.Colors.textSecondary
	box.Text = ""
	box.Font = Theme.Fonts.body
	box.TextSize = Theme.Sizes.body
	box.TextColor3 = Theme.Colors.textPrimary
	box.Size = UDim2.new(1, -24, 1, 0)
	box.Position = UDim2.fromOffset(12, 0)
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.Parent = container

	box:GetPropertyChangedSignal("Text"):Connect(function()
		if props.onChange then
			props.onChange(box.Text)
		end
	end)

	return container
end

function Components.createPlayerRow(props)
	local Theme = props.theme
	local row = Instance.new("TextButton")
	row.Name = "PlayerRow"
	row.AutoButtonColor = false
	row.Text = ""
	row.BackgroundColor3 = Theme.Colors.bgSecondary
	row.BackgroundTransparency = 0.35
	row:SetAttribute("TargetTransparency", 0.35)
	row.Size = UDim2.new(1, 0, 0, Theme.Sizes.minTouch)
	row.Parent = props.parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = row

	local avatar = Instance.new("ImageLabel")
	avatar.Name = "Avatar"
	avatar.BackgroundColor3 = Theme.Colors.bgPrimary
	avatar.Size = UDim2.fromOffset(Theme.Sizes.avatar, Theme.Sizes.avatar)
	avatar.Position = UDim2.fromOffset(8, 4)
	avatar.Image = props.avatar or ""
	avatar.Parent = row

	local avatarCorner = Instance.new("UICorner")
	avatarCorner.CornerRadius = UDim.new(1, 0)
	avatarCorner.Parent = avatar

	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Theme.Fonts.body
	nameLabel.TextSize = Theme.Sizes.body
	nameLabel.TextColor3 = Theme.Colors.textPrimary
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Text = props.name or "Player"
	nameLabel.Size = UDim2.new(1, -160, 0, 20)
	nameLabel.Position = UDim2.fromOffset(52, 6)
	nameLabel.Parent = row

	local distanceLabel = Instance.new("TextLabel")
	distanceLabel.BackgroundTransparency = 1
	distanceLabel.Font = Theme.Fonts.mono
	distanceLabel.TextSize = Theme.Sizes.mono
	distanceLabel.TextColor3 = Theme.Colors.textSecondary
	distanceLabel.TextXAlignment = Enum.TextXAlignment.Left
	distanceLabel.Text = props.distance or "—"
	distanceLabel.Size = UDim2.new(1, -160, 0, 18)
	distanceLabel.Position = UDim2.fromOffset(52, 24)
	distanceLabel.Parent = row

	local dot = Instance.new("Frame")
	dot.Name = "StatusDot"
	dot.Size = UDim2.fromOffset(10, 10)
	dot.AnchorPoint = Vector2.new(1, 0.5)
	dot.Position = UDim2.new(1, -16, 0.5, 0)
	dot.BackgroundColor3 = props.statusColor or Theme.Colors.textSecondary
	dot.Parent = row

	local dotCorner = Instance.new("UICorner")
	dotCorner.CornerRadius = UDim.new(1, 0)
	dotCorner.Parent = dot

	row.MouseButton1Click:Connect(function()
		if props.onTap then
			props.onTap()
		end
	end)

	row.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1
		then
			row:SetAttribute("PressStart", tick())
		end
	end)

	row.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1
		then
			local start = row:GetAttribute("PressStart") or 0
			if tick() - start >= 0.45 and props.onLongPress then
				props.onLongPress()
			end
		end
	end)

	return row, {
		setDistance = function(text)
			distanceLabel.Text = text
		end,
		setStatusColor = function(color)
			dot.BackgroundColor3 = color
		end,
	}
end

return Components
]=],
	["src/FloatingButton.lua"] = [=[
local FloatingButton = {}
FloatingButton.__index = FloatingButton

local SAVE_KEY = "buttonPositionV3"

function FloatingButton.new(deps)
	local self = setmetatable({}, FloatingButton)
	self.theme = deps.theme
	self.utils = deps.utils
	self.haptic = deps.haptic
	self.onToggle = deps.onToggle
	self.onMove = deps.onMove
	self.screenGui = deps.screenGui
	self.state = deps.state

	self.button = self:_create()
	self:_ensurePosition(true)
	return self
end

function FloatingButton:_radiusPx()
	return self.theme.Sizes.floatingButton * 0.5
end

function FloatingButton:_applyScalePosition(point)
	self.button.AnchorPoint = Vector2.new(0.5, 0.5)
	self.button.Position = UDim2.new(point.x, 0, point.y, 0)
end

function FloatingButton:_applyOffsetPosition(point)
	self.button.AnchorPoint = Vector2.new(0.5, 0.5)
	self.button.Position = UDim2.fromOffset(point.x, point.y)
end

function FloatingButton:_applyPosition(point)
	if self.utils.isMobile() then
		self:_applyOffsetPosition(point)
	else
		self:_applyScalePosition(point)
	end
end

function FloatingButton:_defaultPosition()
	if self.utils.isMobile() then
		return self.utils.getDefaultButtonOffset(self:_radiusPx())
	end
	return self.utils.getDefaultButtonPosition()
end

function FloatingButton:_loadPosition()
	local saved = self.utils.getSavedPoint(SAVE_KEY, self:_defaultPosition())
	return self.utils.sanitizeButtonPosition(saved, self:_radiusPx())
end

function FloatingButton:_ensurePosition(forceSave)
	local point = self:_loadPosition()
	self:_applyPosition(point)
	if forceSave then
		self.utils.savePoint(SAVE_KEY, point)
	end
	self:_notifyMove()
end

function FloatingButton:_create()
	local Theme = self.theme
	local size = Theme.Sizes.floatingButton

	local button = Instance.new("TextButton")
	button.Name = "FloatingButton"
	button.AutoButtonColor = false
	button.Text = "20"
	button.Font = Theme.Fonts.header
	button.TextSize = 14
	button.TextColor3 = Theme.Colors.textPrimary
	button.BackgroundColor3 = Theme.Colors.accent
	button.BackgroundTransparency = Theme.Transparency.idleButton
	button.Size = UDim2.fromOffset(size, size)
	button.ZIndex = 999999
	button.Active = true
	button.Selectable = false
	button.Parent = self.screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.Colors.accent
	stroke.Thickness = 2
	stroke.Transparency = 0.15
	stroke.Parent = button

	self:_bindDrag(button)

	task.defer(function()
		for _ = 1, 12 do
			if workspace.CurrentCamera.ViewportSize.Y > 120 then
				break
			end
			task.wait(0.05)
		end
		local point = self:_loadPosition()
		self:_applyPosition(point)
		self.utils.savePoint(SAVE_KEY, point)
		self:_notifyMove()
	end)

	return button
end

function FloatingButton:_notifyMove()
	if self.onMove then
		self.onMove(self.button)
	end
end

function FloatingButton:_bindDrag(button)
	local UserInputService = game:GetService("UserInputService")
	local dragging = false
	local didDrag = false
	local activeInput
	local dragStart
	local startPoint

	local function saveCurrentPosition()
		if self.utils.isMobile() then
			local cx, cy = button.Position.X.Offset, button.Position.Y.Offset
			self.utils.savePoint(SAVE_KEY, { mode = "offset", x = cx, y = cy })
		else
			local x, y = button.Position.X.Scale, button.Position.Y.Scale
			self.utils.savePoint(SAVE_KEY, { x = x, y = y })
		end
	end

	local function finish()
		if activeInput then
			if dragging then
				saveCurrentPosition()
				self:_notifyMove()
			end
			activeInput = nil
			dragStart = nil
			dragging = false
		end
	end

	button.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1
		then
			activeInput = input
			dragging = false
			didDrag = false
			dragStart = input.Position
			if self.utils.isMobile() then
				startPoint = {
					x = button.Position.X.Offset,
					y = button.Position.Y.Offset,
				}
			else
				startPoint = {
					x = button.Position.X.Scale,
					y = button.Position.Y.Scale,
				}
			end
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not activeInput or input ~= activeInput then
			return
		end
		if
			input.UserInputType ~= Enum.UserInputType.Touch
			and input.UserInputType ~= Enum.UserInputType.MouseMovement
		then
			return
		end

		local delta = input.Position - dragStart
		if delta.Magnitude > 8 then
			dragging = true
			didDrag = true
		end
		if dragging then
			if self.utils.isMobile() then
				local cx = startPoint.x + delta.X
				local cy = startPoint.y + delta.Y
				cx, cy = self.utils.clampButtonOffset(cx, cy, button.AbsoluteSize.X * 0.5)
				button.Position = UDim2.fromOffset(cx, cy)
			else
				local viewport = workspace.CurrentCamera.ViewportSize
				local cx = startPoint.x + delta.X / viewport.X
				local cy = startPoint.y + delta.Y / viewport.Y
				cx, cy = self.utils.clampButtonPosition(cx, cy, button.AbsoluteSize.X * 0.5)
				button.Position = UDim2.new(cx, 0, cy, 0)
			end
			self:_notifyMove()
		end
	end)

	local function onInputEnded(input)
		if not activeInput or input ~= activeInput then
			return
		end
		if not didDrag then
			self.haptic.lightImpact()
			self.utils.springScale(button, 0.95)
			if self.onToggle then
				self.onToggle()
			end
		else
			didDrag = false
		end
		finish()
	end

	button.InputEnded:Connect(onInputEnded)
	UserInputService.InputEnded:Connect(onInputEnded)
end

function FloatingButton:setActive(active)
	self.button.BackgroundTransparency = active and self.theme.Transparency.activeButton
		or self.theme.Transparency.idleButton
	local stroke = self.button:FindFirstChildOfClass("UIStroke")
	if stroke then
		stroke.Color = active and self.theme.Colors.success or self.theme.Colors.accent
	end
end

function FloatingButton:setVisible(visible)
	self.button.Visible = visible
end

return FloatingButton
]=],
	["src/FlySpeedHud.lua"] = [=[
local FlySpeedHud = {}
FlySpeedHud.__index = FlySpeedHud

local SAVE_KEY = "flyHudPosition"

function FlySpeedHud.new(deps)
	local self = setmetatable({}, FlySpeedHud)
	self.theme = deps.theme
	self.utils = deps.utils
	self.state = deps.state
	self.flyService = deps.flyService
	self.godService = deps.godService
	self.screenGui = deps.screenGui
	self.setStatus = deps.setStatus
	self.config = deps.config
	self.root = self:_create()
	self:_bindDrag()
	self:_loadPosition()
	self:sync()
	return self
end

function FlySpeedHud:_makeBtn(parent, text, size, color)
	local Theme = self.theme
	local btn = Instance.new("TextButton")
	btn.AutoButtonColor = false
	btn.Text = text
	btn.Font = Theme.Fonts.header
	btn.TextSize = 11
	btn.TextColor3 = Theme.Colors.textPrimary
	btn.BackgroundColor3 = color or Theme.Colors.buttonGlass
	btn.BackgroundTransparency = 0
	btn.Size = size
	btn.Parent = parent
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	return btn
end

function FlySpeedHud:_defaultOffset()
	local viewport = workspace.CurrentCamera.ViewportSize
	local w, h = 176, 118
	return {
		mode = "offset",
		x = math.max((viewport.X - w) * 0.5, 8),
		y = math.max(viewport.Y - h - 16, 80),
	}
end

function FlySpeedHud:_applyOffset(x, y)
	x, y = self.utils.clampHudOffset(x, y, self.root.AbsoluteSize.X, self.root.AbsoluteSize.Y)
	self.root.AnchorPoint = Vector2.new(0, 0)
	self.root.Position = UDim2.fromOffset(x, y)
end

function FlySpeedHud:_loadPosition()
	local saved = self.utils.getSavedPoint(SAVE_KEY, self:_defaultOffset())
	if typeof(saved) == "table" and typeof(saved.x) == "number" and typeof(saved.y) == "number" then
		if saved.mode == "offset" then
			self:_applyOffset(saved.x, saved.y)
			return
		end
		local viewport = workspace.CurrentCamera.ViewportSize
		self:_applyOffset(saved.x * viewport.X, saved.y * viewport.Y)
		return
	end
	local def = self:_defaultOffset()
	self:_applyOffset(def.x, def.y)
end

function FlySpeedHud:_create()
	local Theme = self.theme
	local root = Instance.new("Frame")
	root.Name = "FlyControlHud"
	root.BackgroundColor3 = Theme.Colors.bgPrimary
	root.BackgroundTransparency = 0.04
	root.Size = UDim2.fromOffset(176, 118)
	root.Active = true
	root.Visible = false
	root.ZIndex = 50
	root.Parent = self.screenGui
	Instance.new("UICorner", root).CornerRadius = UDim.new(0, 10)

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 4)
	pad.PaddingBottom = UDim.new(0, 5)
	pad.PaddingLeft = UDim.new(0, 5)
	pad.PaddingRight = UDim.new(0, 5)
	pad.Parent = root

	self.grabber = Instance.new("TextButton")
	self.grabber.Name = "Grabber"
	self.grabber.AutoButtonColor = false
	self.grabber.Text = "v" .. ((self.config and self.config.VERSION) or "?") .. "  drag"
	self.grabber.Font = Theme.Fonts.header
	self.grabber.TextSize = 10
	self.grabber.TextColor3 = Theme.Colors.textSecondary
	self.grabber.BackgroundColor3 = Theme.Colors.bgSecondary
	self.grabber.Size = UDim2.new(1, 0, 0, 14)
	self.grabber.ZIndex = 51
	self.grabber.Parent = root
	Instance.new("UICorner", self.grabber).CornerRadius = UDim.new(0, 6)

	self.flyBtn = self:_makeBtn(root, "FLY", UDim2.new(0.48, -3, 0, 22), Theme.Colors.accent)
	self.flyBtn.Position = UDim2.fromOffset(0, 18)
	self.godBtn = self:_makeBtn(root, "GOD", UDim2.new(0.48, -3, 0, 22))
	self.godBtn.Position = UDim2.new(0.52, 3, 0, 18)

	local speedRow = Instance.new("Frame")
	speedRow.BackgroundTransparency = 1
	speedRow.Size = UDim2.new(1, 0, 0, 22)
	speedRow.Position = UDim2.fromOffset(0, 44)
	speedRow.Parent = root

	self.minusBtn = self:_makeBtn(speedRow, "-", UDim2.fromOffset(22, 22))
	self.valueLabel = Instance.new("TextLabel")
	self.valueLabel.BackgroundColor3 = Theme.Colors.bgSecondary
	self.valueLabel.Font = Theme.Fonts.mono
	self.valueLabel.TextSize = 11
	self.valueLabel.TextColor3 = Theme.Colors.textPrimary
	self.valueLabel.Size = UDim2.new(1, -52, 1, 0)
	self.valueLabel.Position = UDim2.fromOffset(26, 0)
	self.valueLabel.Parent = speedRow
	Instance.new("UICorner", self.valueLabel).CornerRadius = UDim.new(0, 6)
	self.plusBtn = self:_makeBtn(speedRow, "+", UDim2.fromOffset(22, 22))
	self.plusBtn.Position = UDim2.new(1, -22, 0, 0)

	local dirRow = Instance.new("Frame")
	dirRow.BackgroundTransparency = 1
	dirRow.Size = UDim2.new(1, 0, 0, 22)
	dirRow.Position = UDim2.fromOffset(0, 70)
	dirRow.Parent = root

	self.upBtn = self:_makeBtn(dirRow, "^", UDim2.new(0.25, -3, 1, 0))
	self.downBtn = self:_makeBtn(dirRow, "v", UDim2.new(0.25, -3, 1, 0))
	self.downBtn.Position = UDim2.new(0.25, 1, 0, 0)
	self.leftBtn = self:_makeBtn(dirRow, "<", UDim2.new(0.25, -3, 1, 0))
	self.leftBtn.Position = UDim2.new(0.5, 1, 0, 0)
	self.fwdBtn = self:_makeBtn(dirRow, "F", UDim2.new(0.25, -1, 1, 0), Theme.Colors.accent)
	self.fwdBtn.Position = UDim2.new(0.75, 1, 0, 0)

	self.autoBtn = self:_makeBtn(root, "Auto", UDim2.new(0.48, -3, 0, 22), Theme.Colors.success)
	self.autoBtn.Position = UDim2.new(0, 0, 1, -22)
	self.lockBtn = self:_makeBtn(root, "Lock", UDim2.new(0.48, -3, 0, 22))
	self.lockBtn.Position = UDim2.new(0.52, 3, 1, -22)

	local function bump(delta)
		local fly = self.config and self.config.FLY or { MIN_SPEED = 16, MAX_SPEED = 600 }
		local nextSpeed = self.utils.clamp(self.state.flySpeed + delta, fly.MIN_SPEED, fly.MAX_SPEED)
		self.flyService:setSpeed(nextSpeed)
		self:sync()
		self.setStatus(string.format("Speed: %d", nextSpeed))
	end

	self.minusBtn.MouseButton1Click:Connect(function()
		bump(-10)
	end)
	self.plusBtn.MouseButton1Click:Connect(function()
		bump(10)
	end)

	self.utils.holdRepeat(self.upBtn, function()
		self.flyService:setVertical(1)
	end, 0.15, 0.05, function()
		self.flyService:setVertical(0)
	end)
	self.utils.holdRepeat(self.downBtn, function()
		self.flyService:setVertical(-1)
	end, 0.15, 0.05, function()
		self.flyService:setVertical(0)
	end)
	self.utils.holdRepeat(self.leftBtn, function()
		self.flyService:setStrafe(-1)
	end, 0.15, 0.05, function()
		self.flyService:setStrafe(0)
	end)
	self.utils.holdRepeat(self.fwdBtn, function()
		self.flyService:setForward(-1)
	end, 0.15, 0.05, function()
		self.flyService:setForward(0)
	end)

	self.flyBtn.MouseButton1Click:Connect(function()
		local nextValue = not self.state.flyEnabled
		self.flyService:setEnabled(nextValue)
		self.state.flyHudOpen = nextValue
		self:sync()
		self.setStatus(nextValue and "Fly on" or "Fly off")
	end)

	self.godBtn.MouseButton1Click:Connect(function()
		if self.godService then
			self.godService:setEnabled(not self.state.godMode)
		else
			self.state.godMode = not self.state.godMode
		end
		self:sync()
		self.setStatus(self.state.godMode and "No damage on" or "No damage off")
	end)

	self.autoBtn.MouseButton1Click:Connect(function()
		self.flyService:setAutoDrive(true)
		self:sync()
		self.setStatus("Auto drive on")
	end)

	self.lockBtn.MouseButton1Click:Connect(function()
		self.flyService:setSeatLock(not self.state.seatLock)
		self:sync()
		self.setStatus(self.state.seatLock and "Seat lock on" or "Seat lock off")
	end)

	return root
end

function FlySpeedHud:_bindDrag()
	local UserInputService = game:GetService("UserInputService")
	local dragging = false
	local activeInput
	local dragStart
	local startX
	local startY

	self.grabber.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1
		then
			activeInput = input
			dragging = false
			dragStart = input.Position
			startX = self.root.Position.X.Offset
			startY = self.root.Position.Y.Offset
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not activeInput or input ~= activeInput then
			return
		end
		local delta = input.Position - dragStart
		if delta.Magnitude > 6 then
			dragging = true
		end
		if dragging then
			self:_applyOffset(startX + delta.X, startY + delta.Y)
		end
	end)

	local function finish(input)
		if not activeInput or input ~= activeInput then
			return
		end
		if dragging then
			self.utils.savePoint(SAVE_KEY, {
				mode = "offset",
				x = self.root.Position.X.Offset,
				y = self.root.Position.Y.Offset,
			})
		end
		activeInput = nil
		dragging = false
	end

	self.grabber.InputEnded:Connect(finish)
	UserInputService.InputEnded:Connect(finish)
end

function FlySpeedHud:sync()
	self.valueLabel.Text = tostring(math.floor(self.state.flySpeed + 0.5))
	self.root.Visible = self.state.flyHudOpen == true
	self.flyBtn.BackgroundColor3 = self.state.flyEnabled and self.theme.Colors.success or self.theme.Colors.accent
	self.flyBtn.Text = self.state.flyEnabled and "FLY ON" or "FLY"
	self.godBtn.BackgroundColor3 = self.state.godMode and self.theme.Colors.success or self.theme.Colors.buttonGlass
	self.godBtn.Text = self.state.godMode and "GOD ON" or "GOD"
	self.autoBtn.Visible = not self.state.autoDrive
	if self.state.autoDrive then
		self.lockBtn.Size = UDim2.new(1, 0, 0, 22)
		self.lockBtn.Position = UDim2.new(0, 0, 1, -22)
	else
		self.lockBtn.Size = UDim2.new(0.48, -3, 0, 22)
		self.lockBtn.Position = UDim2.new(0.52, 3, 1, -22)
	end
	self.lockBtn.BackgroundColor3 = self.state.seatLock and self.theme.Colors.success or self.theme.Colors.buttonGlass
	self.lockBtn.Text = self.state.seatLock and "Lock ON" or "Lock"
end

function FlySpeedHud:followButton(_button)
	self.root.ZIndex = 50
end

function FlySpeedHud:setVisible(visible)
	self.state.flyHudOpen = visible
	self.root.Visible = visible
end

return FlySpeedHud
]=],
	["src/MenuSheet.lua"] = [=[
local MenuSheet = {}
MenuSheet.__index = MenuSheet

local HEADER_H = 90
local STATUS_H = 22

function MenuSheet.new(deps)
	local self = setmetatable({}, MenuSheet)
	self.theme = deps.theme
	self.utils = deps.utils
	self.components = deps.components
	self.state = deps.state
	self.screenGui = deps.screenGui
	self.modules = deps.modules
	self.onClose = deps.onClose
	self.config = deps.config
	self.tabFrames = {}

	self.panel = self:_create()
	self:_buildTabs()
	self:_bindResize()
	self:_layout()
	return self
end

function MenuSheet:_create()
	local Theme = self.theme
	local version = (self.config and self.config.VERSION) or "?"

	local panel = Instance.new("Frame")
	panel.Name = "TopMenuPanel"
	panel.BackgroundColor3 = Theme.Colors.bgPrimary
	panel.BackgroundTransparency = 0
	panel.BorderSizePixel = 0
	panel.Visible = false
	panel.ClipsDescendants = true
	panel.ZIndex = 10
	panel.Parent = self.screenGui

	panel.Size = UDim2.fromScale(1, 1)
	panel.Position = UDim2.fromOffset(0, 0)

	local header = Instance.new("Frame")
	header.Name = "Header"
	header.BackgroundColor3 = Theme.Colors.bgSecondary
	header.BackgroundTransparency = 0
	header.BorderSizePixel = 0
	header.Size = UDim2.new(1, 0, 0, HEADER_H)
	header.ZIndex = 11
	header.Parent = panel

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Font = Theme.Fonts.header
	title.TextSize = 16
	title.TextColor3 = Theme.Colors.textPrimary
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = "CC2  LOADED v" .. version
	title.Size = UDim2.new(1, -56, 0, 28)
	title.Position = UDim2.fromOffset(12, 8)
	title.ZIndex = 12
	title.Parent = header

	local close = Instance.new("TextButton")
	close.Name = "CloseButton"
	close.AutoButtonColor = false
	close.Text = "X"
	close.Font = Theme.Fonts.header
	close.TextSize = 16
	close.TextColor3 = Color3.new(1, 1, 1)
	close.BackgroundColor3 = Theme.Colors.danger
	close.Size = UDim2.fromOffset(32, 32)
	close.Position = UDim2.new(1, -40, 0, 6)
	close.ZIndex = 12
	close.Parent = header
	Instance.new("UICorner", close).CornerRadius = UDim.new(1, 0)

	local tabHost = Instance.new("Frame")
	tabHost.BackgroundTransparency = 1
	tabHost.Size = UDim2.new(1, -16, 0, 36)
	tabHost.Position = UDim2.fromOffset(8, 42)
	tabHost.ZIndex = 12
	tabHost.Parent = header

	local content = Instance.new("Frame")
	content.Name = "ContentHost"
	content.BackgroundTransparency = 1
	content.ClipsDescendants = true
	content.Size = UDim2.new(1, -12, 1, -(HEADER_H + STATUS_H + 6))
	content.Position = UDim2.fromOffset(6, HEADER_H + 2)
	content.ZIndex = 11
	content.Parent = panel
	self.contentHost = content

	local status = Instance.new("TextLabel")
	status.Name = "StatusLabel"
	status.BackgroundTransparency = 1
	status.Font = Theme.Fonts.mono
	status.TextSize = 11
	status.TextColor3 = Theme.Colors.textSecondary
	status.TextXAlignment = Enum.TextXAlignment.Left
	status.Text = "Ready"
	status.Size = UDim2.new(1, -16, 0, STATUS_H)
	status.Position = UDim2.new(0, 10, 1, -STATUS_H)
	status.ZIndex = 12
	status.Parent = panel
	self.statusLabel = status

	close.MouseButton1Click:Connect(function()
		self:hide()
	end)

	self.components.createSegmented({
		parent = tabHost,
		theme = Theme,
		options = { "Fly", "Nav", "Arena", "Derby" },
		default = self.state.activeTab,
		onChange = function(tab)
			self:switchTab(tab)
		end,
	})

	return panel
end

function MenuSheet:_layout()
	self.panel.Position = UDim2.fromOffset(0, 0)
	self.panel.Size = UDim2.fromScale(1, 1)
end

function MenuSheet:_bindResize()
	self.screenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_layout()
	end)
end

function MenuSheet:_buildTabs()
	for name, builder in pairs(self.modules) do
		local frame = Instance.new("ScrollingFrame")
		frame.Name = name .. "Tab"
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.Size = UDim2.fromScale(1, 1)
		frame.ScrollBarThickness = 5
		frame.ScrollingEnabled = true
		frame.Active = true
		frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
		frame.CanvasSize = UDim2.new()
		frame.Visible = name == self.state.activeTab
		frame.ZIndex = 11
		frame.Parent = self.contentHost

		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 8)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = frame

		local padding = Instance.new("UIPadding")
		padding.PaddingTop = UDim.new(0, 4)
		padding.PaddingBottom = UDim.new(0, 16)
		padding.PaddingLeft = UDim.new(0, 4)
		padding.PaddingRight = UDim.new(0, 8)
		padding.Parent = frame

		builder(frame)
		self.tabFrames[name] = frame
	end
end

function MenuSheet:switchTab(tab)
	if self.state.activeTab == tab and self.tabFrames[tab] and self.tabFrames[tab].Visible then
		return
	end
	self.state.activeTab = tab
	for name, frame in pairs(self.tabFrames) do
		frame.Visible = name == tab
		if name == tab then
			frame.CanvasPosition = Vector2.zero
		end
	end
	self:updateStatus("Tab: " .. tab)
end

function MenuSheet:show()
	self:_layout()
	self.panel.Visible = true
	self.state.menuOpen = true
	self:updateStatus("Menu open")
end

function MenuSheet:hide()
	self.panel.Visible = false
	self.state.menuOpen = false
	if self.onClose then
		self.onClose()
	end
end

function MenuSheet:toggle()
	if self.panel.Visible then
		self:hide()
	else
		self:show()
	end
end

function MenuSheet:updateStatus(text)
	self.state.statusText = text
	if self.statusLabel then
		self.statusLabel.Text = text
	end
end

function MenuSheet:setVisible(visible)
	if visible then
		self:show()
	else
		self:hide()
	end
end

return MenuSheet
]=],
	["src/Services/GameContext.lua"] = [=[
local GameContext = {}
GameContext.__index = GameContext

function GameContext.new(config, utils)
	local self = setmetatable({}, GameContext)
	self.config = config
	self.utils = utils
	self.placeId = game.PlaceId
	self.isCC2 = self.placeId == config.PLACE_IDS.CC2
	self.player = game:GetService("Players").LocalPlayer
	self.points = {}
	self:_resolvePoints()
	return self
end

function GameContext:getSummary()
	if self.isCC2 then
		return "Car Crushers 2"
	end
	return "Place " .. tostring(self.placeId)
end

function GameContext:getVehicleFromDescendant(descendant)
	if not descendant then
		return nil
	end

	local playerName = self.player.Name
	local candidates = {
		descendant:FindFirstAncestor(playerName .. "'s Car"),
		descendant:FindFirstAncestor(playerName .. "'sCar"),
		descendant:FindFirstAncestor(playerName .. "s Car"),
		descendant:FindFirstAncestor(playerName .. "sCar"),
	}

	for _, candidate in ipairs(candidates) do
		if candidate and candidate:IsA("Model") then
			return candidate
		end
	end

	local body = descendant:FindFirstAncestor("Body")
	if body and body.Parent and body.Parent:IsA("Model") then
		return body.Parent
	end

	local misc = descendant:FindFirstAncestor("Misc")
	if misc and misc.Parent and misc.Parent:IsA("Model") then
		return misc.Parent
	end

	return descendant:FindFirstAncestorWhichIsA("Model")
end

function GameContext:_findMarker(names)
	for _, name in ipairs(names) do
		local inst = workspace:FindFirstChild(name, true)
		if inst then
			if inst:IsA("BasePart") then
				return inst.Position
			end
			if inst:IsA("SpawnLocation") then
				return inst.Position
			end
			if inst:IsA("Model") then
				if inst.PrimaryPart then
					return inst.PrimaryPart.Position
				end
				local part = inst:FindFirstChildWhichIsA("BasePart", true)
				if part then
					return part.Position
				end
			end
			if inst:IsA("Folder") then
				local part = inst:FindFirstChildWhichIsA("BasePart", true)
				if part then
					return part.Position
				end
			end
		end
	end
	return nil
end

function GameContext:_resolvePoints()
	local g = getgenv and getgenv() or _G
	if g.DeltaOverlay and g.DeltaOverlay.arenaPoints then
		self.points = g.DeltaOverlay.arenaPoints
		return
	end

	local spawn = self:_findMarker(self.config.WORKSPACE_MARKERS.spawn)
	local arena = self:_findMarker(self.config.WORKSPACE_MARKERS.arena)

	if self.isCC2 and not spawn then
		local facility = workspace:FindFirstChild("Facility", true)
			or workspace:FindFirstChild("Map", true)
		if facility then
			local part = facility:FindFirstChildWhichIsA("BasePart", true)
			if part then
				spawn = part.Position
			end
		end
	end

	if not spawn then
		local root = self.utils.getCharacterRoot(self.player)
		if root then
			spawn = root.Position
		end
	end

	self.points = {
		spawnPoint = spawn or Vector3.new(0, 10, 0),
		arenaCenter = arena or spawn or Vector3.new(0, 10, 0),
	}
end

function GameContext:getVehicleFromSeat(seat)
	if not seat then
		return nil
	end
	return self:getVehicleFromDescendant(seat)
end

function GameContext:getActiveVehicle()
	local char = self.player.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	local seat = humanoid and humanoid.SeatPart
	if seat and seat:IsA("VehicleSeat") then
		return self:getVehicleFromSeat(seat), seat
	end
	return nil, nil
end

function GameContext:getLocalCar()
	local vehicle = self:getActiveVehicle()
	if vehicle then
		return vehicle
	end
	local playerName = self.player.Name
	local names = {
		playerName .. "'s Car",
		playerName .. "'sCar",
		playerName .. "s Car",
	}
	for _, name in ipairs(names) do
		local inst = workspace:FindFirstChild(name, true)
		if inst and inst:IsA("Model") then
			return inst
		end
	end
	return nil
end

function GameContext:getPlayerVehicle(player)
	if not player then
		return nil, nil
	end
	local char = player.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	local seat = humanoid and humanoid.SeatPart
	if seat then
		return self:getVehicleFromDescendant(seat), seat
	end
	local root = self.utils.getCharacterRoot(player)
	if root then
		return self:getVehicleFromDescendant(root), nil
	end
	return nil, nil
end

function GameContext:prepareVehicle(vehicle, seat)
	if not vehicle or not vehicle:IsA("Model") then
		return false
	end

	if not vehicle.PrimaryPart then
		if seat and seat:IsDescendantOf(vehicle) then
			vehicle.PrimaryPart = seat
		else
			vehicle.PrimaryPart = vehicle:FindFirstChildWhichIsA("BasePart", true)
		end
	end

	for _, part in ipairs(vehicle:GetDescendants()) do
		if part:IsA("BasePart") and part.Anchored then
			part.Anchored = false
		end
	end

	return vehicle.PrimaryPart ~= nil
end

function GameContext:getVehicleCFrame(vehicle)
	if not vehicle or not vehicle:IsA("Model") then
		return nil
	end
	if vehicle.PrimaryPart then
		local ok, cf = pcall(function()
			return vehicle:GetPrimaryPartCFrame()
		end)
		if ok then
			return cf
		end
	end
	local ok, pivot = pcall(function()
		return vehicle:GetPivot()
	end)
	if ok then
		return pivot
	end
	return nil
end

function GameContext:setVehicleCFrame(vehicle, cf)
	if not vehicle or not cf then
		return false
	end

	self:prepareVehicle(vehicle)

	local ok = pcall(function()
		vehicle:SetPrimaryPartCFrame(cf)
	end)
	if ok then
		return true
	end

	ok = pcall(function()
		vehicle:PivotTo(cf)
	end)
	if ok then
		return true
	end

	ok = pcall(function()
		vehicle:MoveTo(cf.Position)
	end)
	return ok
end

function GameContext:teleportVehicle(cf)
	local char = self.player.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	local seat = humanoid and humanoid.SeatPart
	if not seat or not seat:IsA("VehicleSeat") then
		return false
	end

	local vehicle = self:getVehicleFromDescendant(seat)
	if not vehicle then
		return false
	end

	return self:setVehicleCFrame(vehicle, cf)
end

function GameContext:teleportCharacter(root, cf)
	if not root then
		return false
	end
	root.CFrame = cf
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	return true
end

function GameContext:teleportToCFrame(cf)
	local vehicle, seat = self:getActiveVehicle()
	if vehicle and seat then
		return self:teleportVehicle(cf)
	end
	return self:teleportCharacter(self.utils.getLocalRoot(), cf)
end

return GameContext
]=],
	["src/Services/FlyService.lua"] = [=[
local FlyService = {}
FlyService.__index = FlyService

function FlyService.new(state, utils, gameContext, config, platform)
	local self = setmetatable({}, FlyService)
	self.state = state
	self.utils = utils
	self.gameContext = gameContext
	self.config = config
	self.platform = platform
	self.connection = nil
	self.lockConn = nil
	self.jumpConn = nil
	self.lastSeat = nil
	self.savedJumpPower = nil
	self.savedJumpHeight = nil
	self.defaultCharacterParent = nil
	self.state.autoDrive = config.MOBILE.AUTO_DRIVE_DEFAULT and platform.isMobile()
	self:_bindJumpBlock()
	self:_startLockLoop()
	return self
end

function FlyService:setEnabled(enabled)
	self.state.flyEnabled = enabled
	if enabled then
		self.state.seatLock = true
		self:_start()
	else
		self:_stop()
	end
end

function FlyService:setSpeed(speed)
	local fly = self.config.FLY or { MIN_SPEED = 16, MAX_SPEED = 600 }
	self.state.flySpeed = self.utils.clamp(speed, fly.MIN_SPEED, fly.MAX_SPEED)
end

function FlyService:setReference(reference)
	self.state.flyReference = reference
end

function FlyService:setVertical(direction)
	self.state.flyVertical = direction
end

function FlyService:setForward(direction)
	self.state.flyForward = direction
end

function FlyService:setStrafe(direction)
	self.state.flyStrafe = direction
end

function FlyService:setAutoDrive(enabled)
	self.state.autoDrive = enabled
end

function FlyService:setSeatLock(enabled)
	self.state.seatLock = enabled
	if not enabled then
		self:_restoreJump()
	end
end

function FlyService:getMode()
	local vehicle = self.gameContext:getActiveVehicle()
	return vehicle and "Vehicle" or "Character"
end

function FlyService:_flightUnits()
	return self.state.flySpeed / self.config.MOBILE.FLY_SPEED_SCALE
end

function FlyService:_buildVehicleOffset()
	local units = self:_flightUnits()
	local forward = self.state.flyForward or 0
	local strafe = self.state.flyStrafe or 0
	local vertical = (self.state.flyVertical or 0) * (units / 2)

	if self.state.autoDrive and forward == 0 and strafe == 0 and vertical == 0 then
		forward = -units
	end

	return CFrame.new(strafe, vertical, forward)
end

function FlyService:_worldMoveVector(lookVector, offset)
	local basis = CFrame.new(Vector3.zero, lookVector)
	return basis:VectorToWorldSpace(offset.Position)
end

function FlyService:_applyImpactVelocity(vehicle, worldMove)
	local speed = self.state.flySpeed
	local vel = Vector3.zero
	if worldMove.Magnitude > 0.05 then
		vel = worldMove.Unit * speed
	elseif self.state.autoDrive then
		local camera = workspace.CurrentCamera
		vel = camera.CFrame.LookVector * speed
	end

	local character = game:GetService("Players").LocalPlayer.Character
	for _, part in ipairs(vehicle:GetDescendants()) do
		if part:IsA("BasePart") then
			if character and part:IsDescendantOf(character) then
				continue
			end
			part.AssemblyLinearVelocity = vel
			part.AssemblyAngularVelocity = Vector3.zero
			pcall(function()
				part.Velocity = vel
			end)
		end
	end
end

function FlyService:_flyVehicle(vehicle, seat, character)
	if not self.gameContext:prepareVehicle(vehicle, seat) then
		return
	end

	self:_lockToSeat(character, seat)

	local camera = workspace.CurrentCamera
	local current = self.gameContext:getVehicleCFrame(vehicle)
	if not current then
		return
	end

	local lookVector = camera.CFrame.LookVector
	if self.state.flyReference == "Character" and vehicle.PrimaryPart then
		lookVector = vehicle.PrimaryPart.CFrame.LookVector
	end

	local offset = self:_buildVehicleOffset()
	if game:GetService("UserInputService"):GetFocusedTextBox() then
		offset = CFrame.new(0, 0, 0)
	end

	local nextCFrame = CFrame.new(current.Position, current.Position + lookVector) * offset
	self.gameContext:setVehicleCFrame(vehicle, nextCFrame)
	self:_applyImpactVelocity(vehicle, self:_worldMoveVector(lookVector, offset))

	self.state.flyMode = "Vehicle"
end

function FlyService:_flyCharacter(root, humanoid)
	humanoid.PlatformStand = true

	local camera = workspace.CurrentCamera
	local ref = self.state.flyReference == "Camera" and camera.CFrame or root.CFrame
	local look = ref.LookVector
	local flatLook = Vector3.new(look.X, 0, look.Z)
	local units = self:_flightUnits()
	local move = Vector3.zero

	if flatLook.Magnitude > 0.01 then
		flatLook = flatLook.Unit
		local forward = self.state.flyForward or 0
		if forward == -1 then
			forward = 1
		end
		if self.state.autoDrive and forward == 0 then
			forward = 1
		end
		move += flatLook * (units * forward)
	end

	move += Vector3.new(0, (self.state.flyVertical or 0) * units, 0)
	move += ref.RightVector * ((self.state.flyStrafe or 0) * units)

	if move.Magnitude > 0.01 then
		root.AssemblyLinearVelocity = move.Unit * self.state.flySpeed
	else
		root.AssemblyLinearVelocity = Vector3.zero
	end
	root.AssemblyAngularVelocity = Vector3.zero
	self.state.flyMode = "Character"
end

function FlyService:_humanoid()
	local player = game:GetService("Players").LocalPlayer
	local character = player and player.Character
	return character and character:FindFirstChildOfClass("Humanoid"), character
end

function FlyService:_lockToSeat(character, seat)
	if not character or not seat then
		return
	end
	local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
	if not root then
		return
	end
	if character.Parent ~= workspace then
		character.Parent = workspace
	end
	local weld = root:FindFirstChild("LockSeatWeld")
	if not weld then
		weld = Instance.new("WeldConstraint")
		weld.Name = "LockSeatWeld"
		weld.Parent = root
	end
	weld.Part0 = seat
	weld.Part1 = root
	root.AssemblyLinearVelocity = seat.AssemblyLinearVelocity
	root.AssemblyAngularVelocity = Vector3.zero
end

function FlyService:_keepSeated()
	if not self.state.seatLock then
		return
	end

	local humanoid, character = self:_humanoid()
	if not humanoid or not character then
		return
	end

	if character.Parent ~= workspace then
		character.Parent = workspace
	end

	humanoid.Jump = false
	humanoid.Sit = true
	pcall(function()
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
		humanoid.JumpPower = 0
		humanoid.JumpHeight = 0
	end)

	local vehicle, seat = self.gameContext:getActiveVehicle()
	if seat then
		self.lastSeat = seat
	elseif self.lastSeat and self.lastSeat.Parent then
		seat = self.lastSeat
		pcall(function()
			seat:Sit(humanoid)
		end)
	end

	if seat then
		pcall(function()
			seat:Sit(humanoid)
		end)
		self:_lockToSeat(character, seat)
	end
end

function FlyService:_bindJumpBlock()
	if self.jumpConn then
		return
	end
	self.jumpConn = game:GetService("UserInputService").JumpRequest:Connect(function()
		if not self.state.seatLock then
			return
		end
		local humanoid = self:_humanoid()
		if humanoid then
			humanoid.Jump = false
		end
	end)
end

function FlyService:_restoreJump()
	local humanoid = self:_humanoid()
	if not humanoid then
		return
	end
	pcall(function()
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
		if self.savedJumpPower then
			humanoid.JumpPower = self.savedJumpPower
		end
		if self.savedJumpHeight then
			humanoid.JumpHeight = self.savedJumpHeight
		end
	end)
end

function FlyService:_startLockLoop()
	if self.lockConn then
		return
	end
	local function lockTick()
		self:_keepSeated()
	end
	self.lockConn = game:GetService("RunService").Heartbeat:Connect(lockTick)
	game:GetService("RunService").Stepped:Connect(lockTick)
end

function FlyService:_start()
	self:_stop(true)

	local humanoid = self:_humanoid()
	if humanoid and self.savedJumpPower == nil then
		self.savedJumpPower = humanoid.JumpPower
		self.savedJumpHeight = humanoid.JumpHeight
	end

	self.connection = game:GetService("RunService").Stepped:Connect(function()
		if not self.state.flyEnabled then
			return
		end

		local player = game:GetService("Players").LocalPlayer
		local character = player and player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local root = self.utils.getLocalRoot()

		if not character or not humanoid or not root then
			return
		end

		local vehicle, seat = self.gameContext:getActiveVehicle()
		if vehicle and seat then
			if not self.defaultCharacterParent then
				self.defaultCharacterParent = character.Parent
			end
			if self.state.derbyBusy then
				self:_lockToSeat(character, seat)
				return
			end
			self:_flyVehicle(vehicle, seat, character)
		else
			if self.state.seatLock and self.lastSeat and self.lastSeat.Parent then
				pcall(function()
					self.lastSeat:Sit(humanoid)
				end)
				self:_lockToSeat(character, self.lastSeat)
				return
			end
			self:_flyCharacter(root, humanoid)
		end
	end)
end

function FlyService:_stop(keepLockLoop)
	if self.connection then
		self.connection:Disconnect()
		self.connection = nil
	end

	local player = game:GetService("Players").LocalPlayer
	local character = player and player.Character
	local root = character and self.utils.getLocalRoot()
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if root and not self.state.flyEnabled then
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
	end

	if humanoid then
		humanoid.PlatformStand = false
	end

	if character and character.Parent ~= workspace then
		character.Parent = workspace
	end

	if not keepLockLoop then
		self:_restoreJump()
	end

	self.state.flyMode = "Off"
end

return FlyService
]=],
	["src/Services/NavService.lua"] = [=[
local NavService = {}
NavService.__index = NavService

function NavService.new(state, utils, theme, gameContext, config)
	local self = setmetatable({}, NavService)
	self.state = state
	self.utils = utils
	self.theme = theme
	self.gameContext = gameContext
	self.config = config
	self.Players = game:GetService("Players")
	self.teleportToken = 0
	return self
end

function NavService:getPlayerStatus(player)
	local localPlayer = self.Players.LocalPlayer
	if player == localPlayer then
		return self.theme.Colors.textSecondary, "neutral"
	end

	local ok, isFriend = pcall(function()
		return localPlayer:IsFriendsWith(player.UserId)
	end)
	if ok and isFriend then
		return self.theme.Colors.success, "friend"
	end

	if localPlayer.Team and player.Team and localPlayer.Team ~= player.Team then
		return self.theme.Colors.danger, "enemy"
	end

	return self.theme.Colors.textSecondary, "neutral"
end

function NavService:collectPlayers(query)
	query = string.lower(query or "")
	local localRoot = self.utils.getLocalRoot()
	local rows = {}

	for _, player in ipairs(self.Players:GetPlayers()) do
		if player ~= self.Players.LocalPlayer then
			local name = player.Name
			local display = player.DisplayName
			local haystack = string.lower(name .. " " .. display)
			if query == "" or string.find(haystack, query, 1, true) then
				local distance = "—"
				local targetRoot = self.utils.getCharacterRoot(player)
				if localRoot and targetRoot then
					local studs = self.utils.distanceBetween(localRoot.Position, targetRoot.Position)
					distance = string.format("%.0f m", studs)
				end
				local color, status = self:getPlayerStatus(player)
				table.insert(rows, {
					player = player,
					name = display ~= name and (display .. " @" .. name) or name,
					distance = distance,
					statusColor = color,
					status = status,
				})
			end
		end
	end

	table.sort(rows, function(a, b)
		return a.name < b.name
	end)

	self.state.players = rows
	return rows
end

function NavService:getAvatar(userId)
	local content, _ = self.Players:GetUserThumbnailAsync(
		userId,
		Enum.ThumbnailType.HeadShot,
		Enum.ThumbnailSize.Size48x48
	)
	return content
end

function NavService:_teleportInstant(cf)
	return self.gameContext:teleportToCFrame(cf)
end

function NavService:_teleportSmooth(cf)
	self.teleportToken += 1
	local token = self.teleportToken

	local vehicle = self.gameContext:getActiveVehicle()
	local startCF
	if vehicle then
		startCF = self.gameContext:getVehicleCFrame(vehicle)
	else
		local root = self.utils.getLocalRoot()
		startCF = root and root.CFrame
	end
	if not startCF then
		return false
	end

	local steps = self.config.DETECTION.SMOOTH_TELEPORT_STEPS
	local maxStep = self.config.DETECTION.MAX_TELEPORT_STUDS_PER_STEP
	local distance = (cf.Position - startCF.Position).Magnitude
	local stepCount = math.max(steps, math.ceil(distance / maxStep))

	for step = 1, stepCount do
		if token ~= self.teleportToken then
			return false
		end
		local alpha = step / stepCount
		local pos = startCF.Position:Lerp(cf.Position, alpha)
		local nextCF = CFrame.new(pos, pos + cf.LookVector)
		self.gameContext:teleportToCFrame(nextCF)
		task.wait(0.04)
	end

	return true
end

function NavService:teleportToCFrame(cf)
	if self.config.DETECTION.SMOOTH_TELEPORT_DEFAULT then
		return self:_teleportSmooth(cf)
	end
	return self:_teleportInstant(cf)
end

function NavService:teleportTo(player)
	local targetRoot = self.utils.getCharacterRoot(player)
	if not targetRoot then
		return false
	end
	return self:teleportToCFrame(targetRoot.CFrame + Vector3.new(0, 4, 0))
end

function NavService:pickRandom(filtered)
	if #filtered == 0 then
		return nil
	end
	return filtered[math.random(1, #filtered)]
end

return NavService
]=],
	["src/Services/ArenaService.lua"] = [=[
local ArenaService = {}
ArenaService.__index = ArenaService

function ArenaService.new(state, utils, gameContext, navService)
	local self = setmetatable({}, ArenaService)
	self.state = state
	self.utils = utils
	self.gameContext = gameContext
	self.navService = navService
	self.guardThread = nil
	self.points = gameContext.points
	return self
end

function ArenaService:refreshPoints()
	self.gameContext:_resolvePoints()
	self.points = self.gameContext.points
end

function ArenaService:teleportTo(pointName)
	self:refreshPoints()
	local point = self.points[pointName]
	if not point then
		return false
	end
	return self.navService:teleportToCFrame(CFrame.new(point + Vector3.new(0, 4, 0)))
end

function ArenaService:setPresenceGuard(enabled)
	self.state.presenceGuard = enabled
	if self.guardThread then
		task.cancel(self.guardThread)
		self.guardThread = nil
	end
	if enabled then
		self.guardThread = task.spawn(function()
			while self.state.presenceGuard do
				self:_guardPulse()
				task.wait(240)
			end
		end)
	end
end

function ArenaService:_guardPulse()
	local ok = pcall(function()
		local VirtualUser = game:GetService("VirtualUser")
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new(0, 0))
	end)
	if ok then
		return
	end

	pcall(function()
		local humanoid = game:GetService("Players").LocalPlayer.Character
			and game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end)
end

return ArenaService
]=],
	["src/Services/DerbyService.lua"] = [=[
local DerbyService = {}
DerbyService.__index = DerbyService

function DerbyService.new(state, utils, gameContext, config)
	local self = setmetatable({}, DerbyService)
	self.state = state
	self.utils = utils
	self.gameContext = gameContext
	self.config = config
	self.Players = game:GetService("Players")
	self.connection = nil
	self.lastSlam = 0
	return self
end

function DerbyService:setPower(value)
	local derby = self.config.DERBY or { MIN_POWER = 200, MAX_POWER = 900 }
	self.state.derbyPower = self.utils.clamp(value, derby.MIN_POWER, derby.MAX_POWER)
end

function DerbyService:getTargetRoot(player)
	local vehicle = self.gameContext:getPlayerVehicle(player)
	if vehicle then
		local cf = self.gameContext:getVehicleCFrame(vehicle)
		if cf then
			return cf.Position, vehicle
		end
	end
	local root = self.utils.getCharacterRoot(player)
	if root then
		return root.Position, nil
	end
	return nil, nil
end

function DerbyService:collectTargets()
	local localRoot = self.utils.getLocalRoot()
	local rows = {}
	for _, player in ipairs(self.Players:GetPlayers()) do
		if player ~= self.Players.LocalPlayer then
			local pos = self:getTargetRoot(player)
			local distance = 1e9
			if localRoot and pos then
				distance = (localRoot.Position - pos).Magnitude
			end
			table.insert(rows, {
				player = player,
				name = player.DisplayName ~= player.Name and (player.DisplayName .. " @" .. player.Name)
					or player.Name,
				distance = distance,
				inCar = self.gameContext:getPlayerVehicle(player) ~= nil,
			})
		end
	end
	table.sort(rows, function(a, b)
		return a.distance < b.distance
	end)
	return rows
end

function DerbyService:getNearest()
	local rows = self:collectTargets()
	return rows[1]
end

function DerbyService:_applyHit(vehicle, dir, power)
	local vel = dir * power
	for _, part in ipairs(vehicle:GetDescendants()) do
		if part:IsA("BasePart") then
			part.AssemblyLinearVelocity = vel
			part.AssemblyAngularVelocity = Vector3.zero
			pcall(function()
				part.Velocity = vel
			end)
		end
	end
end

function DerbyService:slam(player)
	if not player or not player.Parent then
		return false, "no player"
	end

	local myVehicle, mySeat = self.gameContext:getActiveVehicle()
	if not myVehicle or not mySeat then
		return false, "sit in a car"
	end
	if not self.gameContext:prepareVehicle(myVehicle, mySeat) then
		return false, "car not ready"
	end

	local targetPos = self:getTargetRoot(player)
	if not targetPos then
		return false, "no target"
	end

	local myCF = self.gameContext:getVehicleCFrame(myVehicle)
	if not myCF then
		return false, "no car cframe"
	end

	local dir = targetPos - myCF.Position
	if dir.Magnitude < 1 then
		dir = myCF.LookVector
	else
		dir = dir.Unit
	end

	local hitPos = targetPos - dir * 6
	local slamCF = CFrame.new(hitPos, targetPos)
	self.state.derbyBusy = true
	self.gameContext:setVehicleCFrame(myVehicle, slamCF)
	self:_applyHit(myVehicle, dir, self.state.derbyPower or 420)

	task.delay(0.35, function()
		self.state.derbyBusy = self.state.derbyAutoKnock == true
	end)

	return true
end

function DerbyService:setAutoKnock(enabled)
	self.state.derbyAutoKnock = enabled
	self.state.derbyBusy = enabled
	if enabled then
		self:_start()
	else
		self:_stop()
	end
end

function DerbyService:_start()
	self:_stop()
	self.connection = game:GetService("RunService").Heartbeat:Connect(function()
		if not self.state.derbyAutoKnock then
			return
		end
		local now = os.clock()
		if now - self.lastSlam < 0.22 then
			return
		end
		self.lastSlam = now
		local nearest = self:getNearest()
		if nearest and nearest.distance < 400 then
			self.state.derbyTarget = nearest.player
			self:slam(nearest.player)
		end
	end)
end

function DerbyService:_stop()
	if self.connection then
		self.connection:Disconnect()
		self.connection = nil
	end
	self.state.derbyBusy = false
	self.state.derbyTarget = nil
end

return DerbyService
]=],
	["src/Services/GodService.lua"] = [=[
local GodService = {}
GodService.__index = GodService

local HEALTH_KEYS = {
	health = true,
	hp = true,
	durability = true,
	carhealth = true,
	currenthealth = true,
	maxhealth = true,
	integrity = true,
	parthealth = true,
}

local DAMAGE_KEYS = {
	damage = true,
	dmg = true,
	broken = true,
	destroyed = true,
	crushed = true,
}

local function nameKey(name)
	return string.lower((name or ""):gsub("[%s_%-]", ""))
end

local function isWheelPart(part)
	local key = nameKey(part.Name)
	if string.find(key, "wheel", 1, true) or string.find(key, "tire", 1, true) or string.find(key, "rim", 1, true) then
		return true
	end
	return part:FindFirstChildWhichIsA("HingeConstraint") ~= nil
		or part:FindFirstChildWhichIsA("CylindricalConstraint") ~= nil
end

function GodService.new(state, gameContext)
	local self = setmetatable({}, GodService)
	self.state = state
	self.gameContext = gameContext
	self.connection = nil
	self.stepConn = nil
	self.healthConn = nil
	self.snapshot = {}
	self.snapshotCar = nil
	self:_start()
	return self
end

function GodService:setEnabled(enabled)
	self.state.godMode = enabled
	if enabled then
		self.snapshot = {}
		self.snapshotCar = nil
		self:_protectHumanoid()
		self:_protectLocalCar()
	end
end

function GodService:_isLocalVehicle(vehicle)
	if not vehicle then
		return false
	end
	local mine = self.gameContext:getLocalCar()
	return mine ~= nil and vehicle == mine
end

function GodService:_protectHumanoid()
	local player = game:GetService("Players").LocalPlayer
	local character = player and player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	pcall(function()
		humanoid.BreakJointsOnDeath = false
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
		if humanoid.MaxHealth < 100 then
			humanoid.MaxHealth = 100
		end
		humanoid.Health = humanoid.MaxHealth
	end)

	if self.healthConn then
		self.healthConn:Disconnect()
		self.healthConn = nil
	end
	self.healthConn = humanoid.HealthChanged:Connect(function()
		if self.state.godMode then
			humanoid.Health = humanoid.MaxHealth
		end
	end)
end

function GodService:_restoreValues(root)
	for _, inst in ipairs(root:GetDescendants()) do
		local key = nameKey(inst.Name)
		if inst:IsA("BoolValue") and (DAMAGE_KEYS[key] or string.find(key, "broken", 1, true)) then
			inst.Value = false
		elseif inst:IsA("NumberValue") or inst:IsA("IntValue") or inst:IsA("DoubleConstrainedValue") then
			if HEALTH_KEYS[key] or string.find(key, "health", 1, true) or string.find(key, "hp", 1, true) then
				local maxV = inst.MaxValue or inst:GetAttribute("Max") or inst:GetAttribute("MaxValue") or 999999
				pcall(function()
					inst.Value = maxV
				end)
			elseif DAMAGE_KEYS[key] or string.find(key, "damage", 1, true) then
				pcall(function()
					inst.Value = 0
				end)
			end
		end
	end
	pcall(function()
		root:SetAttribute("Broken", false)
		root:SetAttribute("Destroyed", false)
		root:SetAttribute("Invincible", true)
	end)
end

function GodService:_captureSnapshot(vehicle)
	local primary = vehicle.PrimaryPart or vehicle:FindFirstChildWhichIsA("BasePart", true)
	if not primary then
		return
	end
	self.snapshot = {}
	self.snapshotCar = vehicle
	for _, part in ipairs(vehicle:GetDescendants()) do
		if part:IsA("BasePart") and not isWheelPart(part) then
			self.snapshot[part] = primary.CFrame:ToObjectSpace(part.CFrame)
		end
	end
end

function GodService:_restoreSnapshot(vehicle)
	local primary = vehicle.PrimaryPart or vehicle:FindFirstChildWhichIsA("BasePart", true)
	if not primary or self.snapshotCar ~= vehicle then
		self:_captureSnapshot(vehicle)
		return
	end
	for part, rel in pairs(self.snapshot) do
		if part.Parent then
			local target = primary.CFrame * rel
			if (part.Position - target.Position).Magnitude > 1.2 then
				part.CFrame = target
			end
		end
	end
end

function GodService:_reweldLocal(vehicle)
	local primary = vehicle.PrimaryPart or vehicle:FindFirstChildWhichIsA("BasePart", true)
	if not primary then
		return
	end
	for _, part in ipairs(vehicle:GetDescendants()) do
		if part:IsA("BasePart") and part ~= primary and not isWheelPart(part) then
			if part.Transparency > 0.8 then
				part.Transparency = 0
			end
			pcall(function()
				if #part:GetJoints() == 0 then
					local weld = part:FindFirstChild("GodWeld")
					if not weld then
						weld = Instance.new("WeldConstraint")
						weld.Name = "GodWeld"
						weld.Parent = part
					end
					weld.Part0 = primary
					weld.Part1 = part
				end
			end)
		end
	end
end

function GodService:_protectLocalCar()
	local vehicle = self.gameContext:getLocalCar()
	if not vehicle or not self:_isLocalVehicle(vehicle) then
		return
	end
	if self.snapshotCar ~= vehicle or next(self.snapshot) == nil then
		self:_captureSnapshot(vehicle)
	end
	self:_restoreValues(vehicle)
	self:_restoreSnapshot(vehicle)
	self:_reweldLocal(vehicle)
	local body = vehicle:FindFirstChild("Body")
	if body then
		self:_restoreValues(body)
	end
end

function GodService:_start()
	if self.connection then
		return
	end

	local player = game:GetService("Players").LocalPlayer
	player.CharacterAdded:Connect(function()
		task.wait(0.3)
		if self.state.godMode then
			self:_protectHumanoid()
		end
	end)

	local function tick()
		if not self.state.godMode then
			return
		end
		self:_protectHumanoid()
		self:_protectLocalCar()
	end

	self.connection = game:GetService("RunService").Heartbeat:Connect(tick)
	self.stepConn = game:GetService("RunService").Stepped:Connect(tick)
end

return GodService
]=],
	["src/Services/LifeGuard.lua"] = [=[
local LifeGuard = {}
LifeGuard.__index = LifeGuard

function LifeGuard.new(state, utils, gameContext, flyService)
	local self = setmetatable({}, LifeGuard)
	self.state = state
	self.utils = utils
	self.gameContext = gameContext
	self.flyService = flyService
	self.lastSafe = CFrame.new(0, 20, 0)
	self.lastSeat = nil
	self.recovering = false
	self:_start()
	return self
end

function LifeGuard:_badVector(v)
	if typeof(v) ~= "Vector3" then
		return true
	end
	if v.X ~= v.X or v.Y ~= v.Y or v.Z ~= v.Z then
		return true
	end
	if math.abs(v.X) > 50000 or math.abs(v.Z) > 50000 then
		return true
	end
	if v.Y < -150 or v.Y > 3500 then
		return true
	end
	return false
end

function LifeGuard:_workspaceParent()
	return workspace
end

function LifeGuard:_restoreCharacterParent(character)
	if not character then
		return
	end
	if character.Parent ~= workspace and character.Parent ~= game:GetService("Players") then
		character.Parent = workspace
	end
end

function LifeGuard:_sitBack(humanoid)
	local seat = self.lastSeat
	if self.flyService and self.flyService.lastSeat then
		seat = self.flyService.lastSeat
	end
	if seat and seat.Parent and humanoid then
		pcall(function()
			humanoid.Sit = true
			humanoid.Jump = false
			seat:Sit(humanoid)
		end)
	end
end

function LifeGuard:_recover(reason)
	if self.recovering then
		return
	end
	self.recovering = true

	local player = game:GetService("Players").LocalPlayer
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = self.utils.getLocalRoot()

	if character then
		self:_restoreCharacterParent(character)
	end

	if humanoid then
		pcall(function()
			humanoid.Health = math.max(humanoid.Health, humanoid.MaxHealth)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
			humanoid.PlatformStand = false
		end)
		self:_sitBack(humanoid)
	end

	local vehicle = self.gameContext:getLocalCar()
	if vehicle then
		self.gameContext:setVehicleCFrame(vehicle, self.lastSafe)
	elseif root then
		root.CFrame = self.lastSafe + Vector3.new(0, 4, 0)
		root.AssemblyLinearVelocity = Vector3.zero
	end

	self.state.statusText = "Recover: " .. tostring(reason)
	task.delay(0.4, function()
		self.recovering = false
	end)
end

function LifeGuard:_tick()
	local player = game:GetService("Players").LocalPlayer
	local character = player.Character
	if not character then
		return
	end

	self:_restoreCharacterParent(character)

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = self.utils.getLocalRoot()
	local vehicle, seat = self.gameContext:getActiveVehicle()
	if seat then
		self.lastSeat = seat
	end

	if humanoid then
		pcall(function()
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
			humanoid.BreakJointsOnDeath = false
			if humanoid.Health < humanoid.MaxHealth * 0.35 then
				humanoid.Health = humanoid.MaxHealth
			end
		end)
		if humanoid:GetState() == Enum.HumanoidStateType.Dead then
			humanoid.Health = humanoid.MaxHealth
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			self:_recover("dead")
			return
		end
	end

	if root then
		if self:_badVector(root.Position) then
			self:_recover("bad pos")
			return
		end
		if root.Position.Y > 10 and root.Position.Y < 800 then
			local veh = vehicle or self.gameContext:getLocalCar()
			if veh then
				local cf = self.gameContext:getVehicleCFrame(veh)
				if cf and not self:_badVector(cf.Position) then
					self.lastSafe = cf
				end
			else
				self.lastSafe = root.CFrame
			end
		end
	elseif humanoid then
		self:_recover("no root")
	end
end

function LifeGuard:_start()
	local player = game:GetService("Players").LocalPlayer

	player.CharacterAdded:Connect(function(character)
		task.wait(0.25)
		self:_restoreCharacterParent(character)
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			pcall(function()
				humanoid.BreakJointsOnDeath = false
				humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
				humanoid.Health = humanoid.MaxHealth
			end)
			self:_sitBack(humanoid)
			humanoid.Died:Connect(function()
				self:_recover("died")
			end)
		end
		local root = self.utils.getLocalRoot()
		if root and not self:_badVector(self.lastSafe.Position) then
			root.CFrame = self.lastSafe + Vector3.new(0, 3, 0)
		end
	end)

	if player.Character then
		local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.Died:Connect(function()
				self:_recover("died")
			end)
		end
	end

	game:GetService("RunService").Heartbeat:Connect(function()
		self:_tick()
	end)
end

return LifeGuard
]=],
	["src/Modules/FlyModule.lua"] = [=[
local function buildFlyModule(deps)
	local Theme = deps.theme
	local Components = deps.components
	local Utils = deps.utils
	local State = deps.state
	local FlyService = deps.flyService
	local setStatus = deps.setStatus
	local onSpeedHudSync = deps.onSpeedHudSync
	local onFlyChange = deps.onFlyChange
	local GodService = deps.godService
	local Config = deps.config

	return function(parent)
		Components.createSwitch({
			parent = parent,
			theme = Theme,
			label = "Fly",
			default = State.flyEnabled,
			onChange = function(value)
				FlyService:setEnabled(value)
				if onSpeedHudSync then
					onSpeedHudSync()
				end
				if onFlyChange then
					onFlyChange(value)
				end
				if value then
					setStatus(string.format("Fly %s • %d", FlyService:getMode(), State.flySpeed))
				else
					setStatus("Fly off")
				end
			end,
		})

		Components.createSwitch({
			parent = parent,
			theme = Theme,
			label = "Auto drive",
			default = State.autoDrive,
			onChange = function(value)
				FlyService:setAutoDrive(value)
				if onSpeedHudSync then
					onSpeedHudSync()
				end
			end,
		})

		Components.createSwitch({
			parent = parent,
			theme = Theme,
			label = "No damage",
			default = State.godMode,
			onChange = function(value)
				if GodService then
					GodService:setEnabled(value)
				else
					State.godMode = value
				end
				if onSpeedHudSync then
					onSpeedHudSync()
				end
				setStatus(value and "No damage on" or "No damage off")
			end,
		})

		Components.createSwitch({
			parent = parent,
			theme = Theme,
			label = "Lock seat",
			default = State.seatLock,
			onChange = function(value)
				FlyService:setSeatLock(value)
				if onSpeedHudSync then
					onSpeedHudSync()
				end
				setStatus(value and "Seat lock on" or "Seat lock off")
			end,
		})

		Components.createSlider({
			parent = parent,
			theme = Theme,
			utils = Utils,
			label = "Speed",
			min = 16,
			max = (Config and Config.FLY and Config.FLY.MAX_SPEED) or 600,
			default = State.flySpeed,
			onChange = function(value)
				FlyService:setSpeed(value)
				State.flySpeed = value
				if onSpeedHudSync then
					onSpeedHudSync()
				end
				setStatus(string.format("Speed %d", math.floor(value)))
			end,
		})

		local verticalRow = Instance.new("Frame")
		verticalRow.BackgroundTransparency = 1
		verticalRow.Size = UDim2.new(1, 0, 0, 34)
		verticalRow.Parent = parent

		local verticalLayout = Instance.new("UIListLayout")
		verticalLayout.FillDirection = Enum.FillDirection.Horizontal
		verticalLayout.Padding = UDim.new(0, 8)
		verticalLayout.Parent = verticalRow

		local up = Components.createActionButton({
			parent = verticalRow,
			theme = Theme,
			utils = Utils,
			text = "▲",
			size = UDim2.new(0.25, -6, 1, 0),
			onClick = function() end,
		})
		local down = Components.createActionButton({
			parent = verticalRow,
			theme = Theme,
			utils = Utils,
			text = "▼",
			size = UDim2.new(0.25, -6, 1, 0),
			onClick = function() end,
		})
		local left = Components.createActionButton({
			parent = verticalRow,
			theme = Theme,
			utils = Utils,
			text = "◀",
			size = UDim2.new(0.25, -6, 1, 0),
			onClick = function() end,
		})
		local forward = Components.createActionButton({
			parent = verticalRow,
			theme = Theme,
			utils = Utils,
			text = "Fwd",
			color = Theme.Colors.accent,
			size = UDim2.new(0.25, -6, 1, 0),
			onClick = function() end,
		})

		Utils.holdRepeat(up, function() FlyService:setVertical(1) end, 0.2, 0.05, function() FlyService:setVertical(0) end)
		Utils.holdRepeat(down, function() FlyService:setVertical(-1) end, 0.2, 0.05, function() FlyService:setVertical(0) end)
		Utils.holdRepeat(left, function() FlyService:setStrafe(-1) end, 0.2, 0.05, function() FlyService:setStrafe(0) end)
		Utils.holdRepeat(forward, function() FlyService:setForward(-1) end, 0.2, 0.05, function() FlyService:setForward(0) end)

		Components.createSegmented({
			parent = parent,
			theme = Theme,
			options = { "Camera", "Character" },
			default = State.flyReference == "Camera" and "Camera" or "Character",
			onChange = function(value)
				FlyService:setReference(value == "Camera" and "Camera" or "Character")
			end,
		})
	end
end

return buildFlyModule
]=],
	["src/Modules/NavModule.lua"] = [=[
local function buildNavModule(deps)
	local Theme = deps.theme
	local Components = deps.components
	local Utils = deps.utils
	local State = deps.state
	local NavService = deps.navService
	local Animation = deps.animation
	local setStatus = deps.setStatus

	return function(parent)
		local row = Instance.new("Frame")
		row.BackgroundTransparency = 1
		row.Size = UDim2.new(1, 0, 0, Theme.Sizes.minTouch)
		row.Parent = parent

		local rowLayout = Instance.new("UIListLayout")
		rowLayout.FillDirection = Enum.FillDirection.Horizontal
		rowLayout.Padding = UDim.new(0, 8)
		rowLayout.Parent = row

		local searchContainer = Components.createSearchField({
			parent = row,
			theme = Theme,
			placeholder = "Search players",
			onChange = Utils.debounce(0.3, function(text)
				State.searchQuery = text
				refreshList()
			end),
		})
		searchContainer.Size = UDim2.new(1, -220, 1, 0)

		Components.createActionButton({
			parent = row,
			theme = Theme,
			utils = Utils,
			text = "↻",
			size = UDim2.fromOffset(44, Theme.Sizes.minTouch),
			onClick = function()
				refreshList(true)
			end,
		})

		Components.createActionButton({
			parent = row,
			theme = Theme,
			utils = Utils,
			text = "Random",
			color = Theme.Colors.accent,
			size = UDim2.fromOffset(104, Theme.Sizes.minTouch),
			onClick = function()
				local pick = NavService:pickRandom(currentRows)
				if pick then
					if NavService:teleportTo(pick.player) then
						setStatus("Random: " .. pick.name)
					else
						setStatus("Teleport failed")
					end
				else
					setStatus("No players")
				end
			end,
		})

		local listHost = Instance.new("Frame")
		listHost.Name = "PlayerList"
		listHost.BackgroundTransparency = 1
		listHost.Size = UDim2.new(1, 0, 0, 0)
		listHost.AutomaticSize = Enum.AutomaticSize.Y
		listHost.Parent = parent

		local listLayout = Instance.new("UIListLayout")
		listLayout.Padding = UDim.new(0, 8)
		listLayout.SortOrder = Enum.SortOrder.LayoutOrder
		listLayout.Parent = listHost

		local currentRows = {}
		local refreshing = false

		function refreshList(showAnim)
			if refreshing then
				return
			end
			refreshing = true
			setStatus("Refreshing players…")

			for _, child in ipairs(listHost:GetChildren()) do
				if child:IsA("GuiObject") then
					child:Destroy()
				end
			end

			currentRows = NavService:collectPlayers(State.searchQuery)
			local rowInstances = {}

			for _, data in ipairs(currentRows) do
				local avatar = ""
				pcall(function()
					avatar = NavService:getAvatar(data.player.UserId)
				end)

				local rowButton = Components.createPlayerRow({
					parent = listHost,
					theme = Theme,
					name = data.name,
					distance = data.distance,
					avatar = avatar,
					statusColor = data.statusColor,
					onTap = function()
						if NavService:teleportTo(data.player) then
							setStatus("Nav → " .. data.name)
						else
							setStatus("Teleport failed")
						end
					end,
					onLongPress = function()
						setStatus(data.status .. ": " .. data.name)
					end,
				})
				table.insert(rowInstances, rowButton)
			end

			if showAnim then
				Animation.staggerFade(rowInstances, 0.05)
			end

			setStatus(string.format("%d players", #currentRows))
			refreshing = false
		end

		refreshList(true)
	end
end

return buildNavModule
]=],
	["src/Modules/ArenaModule.lua"] = [=[
local function buildArenaModule(deps)
	local Theme = deps.theme
	local Components = deps.components
	local Utils = deps.utils
	local State = deps.state
	local ArenaService = deps.arenaService
	local setStatus = deps.setStatus
	local onMinimalChange = deps.onMinimalChange

	return function(parent)
		Components.createLabel({
			parent = parent,
			text = "Quick Points",
			font = Theme.Fonts.header,
			size = Theme.Sizes.header,
			color = Theme.Colors.textPrimary,
			sizeDim = UDim2.new(1, 0, 0, 24),
			auto = Enum.AutomaticSize.None,
		})

		local pointsLabel = Components.createLabel({
			parent = parent,
			text = "",
			font = Theme.Fonts.mono,
			size = Theme.Sizes.mono,
			color = Theme.Colors.textSecondary,
			sizeDim = UDim2.new(1, 0, 0, 40),
			auto = Enum.AutomaticSize.Y,
		})

		local function refreshPointLabel()
			ArenaService:refreshPoints()
			local points = ArenaService.points
			pointsLabel.Text = string.format(
				"Spawn: %s\nArena: %s",
				tostring(points.spawnPoint),
				tostring(points.arenaCenter)
			)
		end
		refreshPointLabel()

		local quickRow = Instance.new("Frame")
		quickRow.BackgroundTransparency = 1
		quickRow.Size = UDim2.new(1, 0, 0, Theme.Sizes.minTouch)
		quickRow.Parent = parent

		local quickLayout = Instance.new("UIListLayout")
		quickLayout.FillDirection = Enum.FillDirection.Horizontal
		quickLayout.Padding = UDim.new(0, 12)
		quickLayout.Parent = quickRow

		Components.createActionButton({
			parent = quickRow,
			theme = Theme,
			utils = Utils,
			text = "Arena Center",
			size = UDim2.new(0.5, -6, 1, 0),
			onClick = function()
				if ArenaService:teleportTo("arenaCenter") then
					setStatus("Arena center")
				else
					setStatus("Point unavailable")
				end
			end,
		})

		Components.createActionButton({
			parent = quickRow,
			theme = Theme,
			utils = Utils,
			text = "Spawn Point",
			size = UDim2.new(0.5, -6, 1, 0),
			onClick = function()
				if ArenaService:teleportTo("spawnPoint") then
					setStatus("Spawn point")
				else
					setStatus("Point unavailable")
				end
			end,
		})

		Components.createSwitch({
			parent = parent,
			theme = Theme,
			label = "Presence Guard (4 min)",
			default = State.presenceGuard,
			onChange = function(value)
				ArenaService:setPresenceGuard(value)
				setStatus(value and "Guard active" or "Guard off")
			end,
		})

		Components.createSwitch({
			parent = parent,
			theme = Theme,
			label = "Minimal Mode",
			default = State.minimalMode,
			onChange = function(value)
				State.minimalMode = value
				if onMinimalChange then
					onMinimalChange(value)
				end
				setStatus(value and "Minimal mode" or "Full UI")
			end,
		})

		Components.createLabel({
			parent = parent,
			text = "CC2 может банить за exploit (leaderboard/full ban). Используй alt-аккаунт.",
			font = Theme.Fonts.body,
			size = 13,
			color = Theme.Colors.danger,
			sizeDim = UDim2.new(1, 0, 0, 36),
			auto = Enum.AutomaticSize.Y,
		})
	end
end

return buildArenaModule
]=],
	["src/Modules/DerbyModule.lua"] = [=[
local function buildDerbyModule(deps)
	local Theme = deps.theme
	local Components = deps.components
	local Utils = deps.utils
	local State = deps.state
	local DerbyService = deps.derbyService
	local Config = deps.config
	local setStatus = deps.setStatus

	return function(parent)
		Components.createLabel({
			parent = parent,
			text = "Derby KO",
			font = Theme.Fonts.header,
			size = Theme.Sizes.header,
			color = Theme.Colors.textPrimary,
			sizeDim = UDim2.new(1, 0, 0, 22),
			auto = Enum.AutomaticSize.None,
		})

		Components.createSwitch({
			parent = parent,
			theme = Theme,
			label = "Auto KO nearest",
			default = State.derbyAutoKnock,
			onChange = function(value)
				DerbyService:setAutoKnock(value)
				setStatus(value and "Auto KO on" or "Auto KO off")
			end,
		})

		Components.createSlider({
			parent = parent,
			theme = Theme,
			utils = Utils,
			label = "Knock power",
			min = (Config and Config.DERBY and Config.DERBY.MIN_POWER) or 200,
			max = (Config and Config.DERBY and Config.DERBY.MAX_POWER) or 900,
			default = State.derbyPower,
			onChange = function(value)
				DerbyService:setPower(value)
				setStatus(string.format("Knock %d", math.floor(value)))
			end,
		})

		local btnRow = Instance.new("Frame")
		btnRow.BackgroundTransparency = 1
		btnRow.Size = UDim2.new(1, 0, 0, 36)
		btnRow.Parent = parent

		local btnLayout = Instance.new("UIListLayout")
		btnLayout.FillDirection = Enum.FillDirection.Horizontal
		btnLayout.Padding = UDim.new(0, 8)
		btnLayout.Parent = btnRow

		Components.createActionButton({
			parent = btnRow,
			theme = Theme,
			utils = Utils,
			text = "KO nearest",
			color = Theme.Colors.accent,
			size = UDim2.new(0.5, -4, 1, 0),
			onClick = function()
				local nearest = DerbyService:getNearest()
				if not nearest then
					setStatus("No players")
					return
				end
				local ok, err = DerbyService:slam(nearest.player)
				setStatus(ok and ("KO → " .. nearest.name) or (err or "KO failed"))
			end,
		})

		Components.createActionButton({
			parent = btnRow,
			theme = Theme,
			utils = Utils,
			text = "Refresh",
			size = UDim2.new(0.5, -4, 1, 0),
			onClick = function()
				refreshList()
			end,
		})

		local listHost = Instance.new("Frame")
		listHost.BackgroundTransparency = 1
		listHost.Size = UDim2.new(1, 0, 0, 0)
		listHost.AutomaticSize = Enum.AutomaticSize.Y
		listHost.Parent = parent

		local listLayout = Instance.new("UIListLayout")
		listLayout.Padding = UDim.new(0, 6)
		listLayout.SortOrder = Enum.SortOrder.LayoutOrder
		listLayout.Parent = listHost

		function refreshList()
			for _, child in ipairs(listHost:GetChildren()) do
				if child:IsA("GuiObject") then
					child:Destroy()
				end
			end

			local rows = DerbyService:collectTargets()
			for _, data in ipairs(rows) do
				Components.createActionButton({
					parent = listHost,
					theme = Theme,
					utils = Utils,
					text = string.format(
						"KO %s  %.0f%s",
						data.name,
						data.distance == 1e9 and 0 or data.distance,
						data.inCar and " car" or ""
					),
					color = data.inCar and Theme.Colors.danger or Theme.Colors.bgSecondary,
					size = UDim2.new(1, 0, 0, 36),
					onClick = function()
						local ok, err = DerbyService:slam(data.player)
						setStatus(ok and ("KO → " .. data.name) or (err or "KO failed"))
					end,
				})
			end
			setStatus(string.format("%d targets", #rows))
		end

		refreshList()
	end
end

return buildDerbyModule
]=],
}

local function embeddedLoadModule(path)
	local source = MODULES[path]
	if not source then
		error("Missing bundled module: " .. tostring(path))
	end
	local chunk, err = loadstring(source, "@" .. path)
	if not chunk then
		error("Bundled compile error in " .. path .. ": " .. tostring(err))
	end
	return chunk()
end

local bootstrapSource = [=[
--[[
	Delta iOS Overlay — bootstrap
	Local bundle: loadstring(readfile("car/dist/bundle.lua"))()
	Remote: getgenv().DeltaOverlay.remoteUrl = "https://..."
]]

local ROOT = "car"

local function defaultLoadModule(path)
	local full = ROOT .. "/" .. path
	if readfile and isfile and isfile(full) then
		local source = readfile(full)
		local chunk, err = loadstring(source, "@" .. full)
		if not chunk then
			error("Compile error in " .. full .. ": " .. tostring(err))
		end
		return chunk()
	end
	error("Missing module: " .. full)
end

local function bootstrap(loadModule)
	loadModule = loadModule or defaultLoadModule

	local Platform = loadModule("src/Platform.lua")
	local Config = loadModule("src/Config.lua")
	local Theme = loadModule("src/Theme.lua")
	local Utils = loadModule("src/Utils.lua")
	local Animation = loadModule("src/Animation.lua")
	local State = loadModule("src/State.lua")
	local Haptic = loadModule("src/Haptic.lua")
	local Components = loadModule("src/Components.lua")
	local FloatingButton = loadModule("src/FloatingButton.lua")
	local FlySpeedHud = loadModule("src/FlySpeedHud.lua")
	local MenuSheet = loadModule("src/MenuSheet.lua")
	local GameContext = loadModule("src/Services/GameContext.lua")
	local FlyService = loadModule("src/Services/FlyService.lua")
	local NavService = loadModule("src/Services/NavService.lua")
	local ArenaService = loadModule("src/Services/ArenaService.lua")
	local DerbyService = loadModule("src/Services/DerbyService.lua")
	local GodService = loadModule("src/Services/GodService.lua")
	local LifeGuard = loadModule("src/Services/LifeGuard.lua")
	local buildFlyModule = loadModule("src/Modules/FlyModule.lua")
	local buildNavModule = loadModule("src/Modules/NavModule.lua")
	local buildArenaModule = loadModule("src/Modules/ArenaModule.lua")
	local buildDerbyModule = loadModule("src/Modules/DerbyModule.lua")

	local g = getgenv and getgenv() or _G
	g.DeltaOverlay = g.DeltaOverlay or {}
	if g.DeltaOverlay.remoteUrl and g.DeltaOverlay.remoteUrl ~= "" then
		Config.REMOTE.BUNDLE_URL = g.DeltaOverlay.remoteUrl
	end
	Utils.resetButtonLayout(Config.LAYOUT_VERSION)

	local LocalPlayer = Platform.waitReady()

	local function destroyOverlayGuis(parent)
		if not parent then
			return
		end
		for _, child in parent:GetChildren() do
			if not child:IsA("ScreenGui") then
				continue
			end
			if string.sub(child.Name, 1, 12) == "DeltaOverlay" then
				child:Destroy()
				continue
			end
			if
				child:FindFirstChild("TopMenuPanel", true)
				or child:FindFirstChild("MenuSheet", true)
				or child:FindFirstChild("SheetBackdrop", true)
			then
				child:Destroy()
			end
		end
	end

	destroyOverlayGuis(game:GetService("CoreGui"))
	if typeof(gethui) == "function" then
		pcall(function()
			destroyOverlayGuis(gethui())
		end)
	end
	local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
	destroyOverlayGuis(playerGui)

	local gameContext = GameContext.new(Config, Utils)

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "DeltaOverlay_v210"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = 999999
	screenGui.Enabled = true
	screenGui.Parent = Platform.getGuiParent(LocalPlayer)

	local flyService = FlyService.new(State, Utils, gameContext, Config, Platform)
	local navService = NavService.new(State, Utils, Theme, gameContext, Config)
	local arenaService = ArenaService.new(State, Utils, gameContext, navService)
	local derbyService = DerbyService.new(State, Utils, gameContext, Config)
	local godService = GodService.new(State, gameContext)
	godService:setEnabled(true)
	local lifeGuard = LifeGuard.new(State, Utils, gameContext, flyService)

	local overlay = {
		version = Config.VERSION,
		game = gameContext:getSummary(),
		mobile = Platform.isMobile(),
	}

	function overlay.setStatus(text)
		State.statusText = text
		if overlay.menu and overlay.menu.statusLabel then
			overlay.menu.statusLabel.Text = text
		end
	end

	local function onMinimalChange(enabled)
		if overlay.menu then
			if enabled then
				overlay.menu:hide()
			else
				overlay.menu:show()
				if overlay.button then
					overlay.button:setActive(true)
				end
			end
		end
		if overlay.button then
			overlay.button:setVisible(true)
		end
	end

	local moduleBuilders = {
		Fly = buildFlyModule({
			theme = Theme,
			components = Components,
			utils = Utils,
			state = State,
			config = Config,
			flyService = flyService,
			godService = godService,
			setStatus = overlay.setStatus,
			onSpeedHudSync = function()
				if overlay.speedHud then
					overlay.speedHud:sync()
				end
			end,
			onFlyChange = function(enabled)
				State.flyHudOpen = enabled
				if overlay.speedHud then
					overlay.speedHud:sync()
				end
				if enabled and overlay.menu then
					overlay.menu:hide()
					if overlay.button then
						overlay.button:setActive(false)
					end
				end
			end,
		}),
		Nav = buildNavModule({
			theme = Theme,
			components = Components,
			utils = Utils,
			state = State,
			navService = navService,
			animation = Animation,
			setStatus = overlay.setStatus,
		}),
		Arena = buildArenaModule({
			theme = Theme,
			components = Components,
			utils = Utils,
			state = State,
			arenaService = arenaService,
			setStatus = overlay.setStatus,
			onMinimalChange = onMinimalChange,
		}),
		Derby = buildDerbyModule({
			theme = Theme,
			components = Components,
			utils = Utils,
			state = State,
			config = Config,
			derbyService = derbyService,
			setStatus = overlay.setStatus,
		}),
	}

	overlay.menu = MenuSheet.new({
		theme = Theme,
		utils = Utils,
		animation = Animation,
		components = Components,
		state = State,
		screenGui = screenGui,
		modules = moduleBuilders,
		config = Config,
		setStatus = overlay.setStatus,
		onClose = function()
			if overlay.button then
				overlay.button:setActive(false)
			end
		end,
	})

	overlay.button = FloatingButton.new({
		theme = Theme,
		utils = Utils,
		haptic = Haptic,
		state = State,
		screenGui = screenGui,
		onToggle = function()
			overlay.menu:toggle()
			overlay.button:setActive(overlay.menu.panel.Visible)
		end,
		onMove = function()
		end,
	})

	overlay.speedHud = FlySpeedHud.new({
		theme = Theme,
		utils = Utils,
		state = State,
		flyService = flyService,
		godService = godService,
		screenGui = screenGui,
		config = Config,
		setStatus = overlay.setStatus,
	})

	overlay.menu:show()
	overlay.button:setActive(true)
	overlay.setStatus(string.format("LOADED v%s • Fly HUD only from Fly switch", Config.VERSION))
	Platform.notify("LOADED v" .. Config.VERSION, "Fly HUD only from menu Fly")
	print("[CC2 Overlay] LOADED v" .. Config.VERSION)

	LocalPlayer.CharacterAdded:Connect(function()
		task.wait(0.6)
		if State.flyEnabled then
			flyService:setEnabled(true)
			overlay.setStatus("Fly: " .. flyService:getMode())
		end
	end)

	g.DeltaOverlayUI = overlay
	return overlay
end

if getgenv and getgenv().DeltaOverlayBundleLoader then
	return bootstrap
end

return bootstrap()

]=]

local bootstrapChunk, bootstrapErr = loadstring(bootstrapSource, "@main.lua")
if not bootstrapChunk then
	error("Failed to compile bootstrap: " .. tostring(bootstrapErr))
end

if getgenv then
	getgenv().DeltaOverlayBundleLoader = true
end

local bootstrap = bootstrapChunk()
return bootstrap(embeddedLoadModule)
