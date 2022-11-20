local obj = game:GetObjects("rbxassetid://11610676634")[1]:Clone()
obj.Parent = game.CoreGui

local code = [[
local Frame = script.Parent
local UI = Frame:WaitForChild("ui")

local I1 = UI:WaitForChild("I1")
local I1_BUTTON = I1:WaitForChild("TextButton")

local I2 = UI:WaitForChild("I2")
local I2_BOX = I2:WaitForChild("FOV")

local I3 = UI:WaitForChild("I3")
local I3_BOOL = I3:WaitForChild("TOGGLE")

local error = script:WaitForChild("error")
local success = script:WaitForChild("success")

local zoomin = script:WaitForChild("in")
local zoomout = script:WaitForChild("out")

local click = script:WaitForChild("click")

local studio = game["Run Service"]:IsStudio()

local it
local DrgLib

if studio then
	DrgLib = require(game.ReplicatedStorage:WaitForChild("MainModule"))
else
	it = game:GetObjects("rbxassetid://11609014264")
	print(it)
	DrgLib = require(it.MainModule)
end

local draggable = DrgLib.draggable
--local dropdown = DrgLib.UI.dropdown

local draggableFrame = draggable.new(Frame)
draggableFrame:Ignore({UI}, true)
draggableFrame:SetTweenInfo(TweenInfo.new(0.2, Enum.EasingStyle.Quad))

local UIS = game:GetService("UserInputService")

local DefaultBindColor = I1_BUTTON.BackgroundColor3

local SettingBind = false

local InputCode = Enum.KeyCode.C
local InputName = InputCode.Name

I1_BUTTON.Text = InputName

local Camera = workspace.CurrentCamera
local InputFOV = 40
local StartFOV = Camera.FieldOfView
local HideGUI = false
local ZoomedIn = false

local function SetGUI(state)
	if studio then
		warn("Toggling GUI visibleness does not work in studio.")
	else
		local s, e = pcall(function()
			game.Players.LocalPlayer.PlayerGui.ShowDevelopmentGui = state
		end)
		if not s then
			warn("Error toggling GUI: '"..e.."'")
		end
	end
end

I3_BOOL.MouseButton1Down:Connect(function()
	game.SoundService:PlayLocalSound(click)
	
	HideGUI = not HideGUI
	I3_BOOL.ImageTransparency = HideGUI and 0 or 1
	if ZoomedIn then
		SetGUI(not HideGUI)
	end
end)

I2_BOX.FocusLost:Connect(function(enter, i)
	if enter then
		local newFOV = tonumber(I2_BOX.Text)
		if newFOV then
			InputFOV = math.clamp(newFOV, 5, 120)
			I2_BOX.Text = InputFOV
			game.SoundService:PlayLocalSound(success)
		else
			I2_BOX.Text = InputFOV
			game.SoundService:PlayLocalSound(error)
		end
	end
end)

I1_BUTTON.MouseButton1Down:Connect(function()
	if not SettingBind then
		SettingBind = true
		
		I1_BUTTON.BackgroundColor3 = Color3.new(0.2,0.8,0.5)
		
		local InputFind
		InputFind = UIS.InputBegan:Connect(function(i, gpe)
			if gpe then return end
			if i.KeyCode ~= Enum.KeyCode.Unknown then
				InputFind:Disconnect()
				
				InputCode = i.KeyCode
				InputName = InputCode.Name
				
				I1_BUTTON.Text = InputName
				
				I1_BUTTON.BackgroundColor3 = DefaultBindColor
				
				SettingBind = false
				
				game.SoundService:PlayLocalSound(success)
				
				return
			end
		end)
	end
end)

local TC:RBXScriptConnection?
local T:Tween?
local TD = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

InputFind = UIS.InputBegan:Connect(function(i, gpe)
	if gpe or SettingBind then return end
	if i.KeyCode == InputCode then
		game.SoundService:PlayLocalSound(zoomin)
		ZoomedIn = true
		
		if HideGUI then
			SetGUI(not HideGUI)
		end
		
		if T and TC then
			TC:Disconnect()
			TC = nil
			T:Cancel()
			T = nil
		else
			StartFOV = Camera.FieldOfView
		end
		T = game.TweenService:Create(Camera, TD, {FieldOfView = InputFOV})
		if T then
			TC = T.Completed:Connect(function()
				T = nil
				TC = nil
			end)
			T:Play()
		end
	end
end)

InputFind = UIS.InputEnded:Connect(function(i, gpe)
	if gpe or SettingBind then return end
	if i.KeyCode == InputCode then
		game.SoundService:PlayLocalSound(zoomout)
		ZoomedIn = false
		
		SetGUI(true)
		
		if T and TC then
			TC:Disconnect()
			TC = nil
			T:Cancel()
			T = nil
		end
		T = game.TweenService:Create(Camera, TD, {FieldOfView = StartFOV})
		if T then
			TC = T.Completed:Connect(function()
				T = nil
				TC = nil
			end)
			T:Play()
		end
	end
end)
]]

local mainFrame = obj:WaitForChild("main")
local sfx = mainFrame:WaitForChild("sfx")
local runCode = Instance.new("LocalScript")
for i,v in pairs(sfx:GetChildren()) do
    v.Parent = runCode
end
runCode.Source = code
runCode.Parent = mainFrame
