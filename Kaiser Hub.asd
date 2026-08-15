if not game:IsLoaded() then game.Loaded:Wait() end
repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.PlayerGui

local function c() return getgenv() end
local Service = setmetatable({},{__index = function(self, name) return game:GetService(name) end})

if c().PIGHUB_LOADED then return end; c().PIGHUB_LOADED = true

local TweenService = Service.TweenService
local Players = Service.Players
local HttpService = Service.HttpService
local UserInputService = Service.UserInputService
local ReplicatedStorage = Service.ReplicatedStorage
local GuiService = Service.GuiService
local VirtualInputManager = Service.VirtualInputManager
local Lighting = Service.Lighting
local RunService = Service.RunService
local Debris = Service.Debris

-- Anticheat Bypass Section
if not c().ACBYPASS then
    task.spawn(xpcall, function()
		repeat task.wait(2)
			if Players.LocalPlayer.PlayerGui:FindFirstChild('SplashScreenGui') and not Players.LocalPlayer:GetAttribute('InMenuCharacterCreator') and not Players.LocalPlayer.PlayerGui:FindFirstChild('Slideshow'):FindFirstChild('SlideshowHolder').Visible then
				GuiService.SelectedObject = Players.LocalPlayer.PlayerGui:FindFirstChild('SplashScreenGui').Frame.PlayButton
				VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
				VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
			elseif not Players.LocalPlayer.PlayerGui:FindFirstChild('SplashScreenGui') and Players.LocalPlayer:GetAttribute('InMenuCharacterCreator') then
				GuiService.SelectedObject = Players.LocalPlayer.PlayerGui:FindFirstChild('CharacterCreator'):FindFirstChild('MenuFrame').AvatarMenuSkipButton
				VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
				VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
			elseif Players.LocalPlayer.PlayerGui:FindFirstChild('SplashScreenGui') and not Players.LocalPlayer:GetAttribute('InMenuCharacterCreator') and Players.LocalPlayer.PlayerGui:FindFirstChild('Slideshow'):FindFirstChild('SlideshowHolder').Visible then
				GuiService.SelectedObject = Players.LocalPlayer.PlayerGui:FindFirstChild('Slideshow'):FindFirstChild('SlideshowHolder'):FindFirstChild('SlideshowCloseButton')
				VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
				VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
			elseif not Players.LocalPlayer.PlayerGui:FindFirstChild('SplashScreenGui') and not Players.LocalPlayer:GetAttribute('InMenuCharacterCreator') and not Players.LocalPlayer.PlayerGui:FindFirstChild('Slideshow'):FindFirstChild('SlideshowHolder').Visible then
				local Net = require(ReplicatedStorage.Modules.Core.Net)

				local func = debug.getupvalue(Net.get,2)
				debug.setconstant(func,3,"___Bypass")
				debug.setconstant(func,4,"___Bypass")

				warn([[
					BYPASS SUCCESSFULLY 
					BY INPOW LUASYNC SERVICE
				]])

				identifyexecutor = nil 
				task.wait()
				GuiService.SelectedObject = nil
				c().ACBYPASS = true
			end
		until c().ACBYPASS
    end, warn)
end

repeat task.wait() until c().ACBYPASS

local Client = Players.LocalPlayer
local Character = Client.Character or Client.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local PlayerGui = Client:WaitForChild("PlayerGui")
local Backpack = Client:WaitForChild("Backpack")

Client.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
	Humanoid = Character:WaitForChild("Humanoid")
	RootPart = Character:WaitForChild("HumanoidRootPart")
	Backpack = Client:WaitForChild("Backpack")

	if RootPart:FindFirstChild("CharacterBillboardGui") then
		RootPart.CharacterBillboardGui.Enabled = not c().HideName
	end
end)

local RarityData = {
	Common = Color3.fromRGB(255, 255, 255),
	Uncommon = Color3.fromRGB(99, 255, 52),
	Rare = Color3.fromRGB(51, 170, 255),
	Epic = Color3.fromRGB(237, 44, 255),
	Legendary = Color3.fromRGB(255, 150, 0),
	Omega = Color3.fromRGB(255, 20, 51)
}

local RarityName = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Omega"}
local DrawingsData = { Players = {}, Item = {} }

local DroppedFolder = workspace:FindFirstChild('DroppedItems') or workspace
local Vehicles = workspace:FindFirstChild("Vehicles") or workspace
local CurrentCamera = workspace.CurrentCamera

local Char = require(ReplicatedStorage.Modules.Core.Char)
local Util = require(ReplicatedStorage.Modules.Core.Util)
local Data = require(ReplicatedStorage.Modules.Core.Data)
local SprintModule = require(ReplicatedStorage.Modules.Game.Sprint)
local Network = require(ReplicatedStorage.Modules.Core.Net)
local RagdollModule = require(ReplicatedStorage.Modules.Game.Ragdoll)
local VehicleSystem = require(ReplicatedStorage.Modules.Game.VehicleSystem.Vehicle)
local CrateController = require(ReplicatedStorage.Modules.Game.CrateSystem.Crate)

local Config_Manager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Yenixs/ToolScript/refs/heads/main/ConfigManager.luau"))()('Blockspin_PIGHUBEDITION', c())
Config_Manager.SC()

-- Helper Functions
local function GetDistanceRoot(Objective)
	if typeof(Objective) == "Instance" then
		if Objective:IsA("BasePart") then
			return (Objective.Position - RootPart.Position).Magnitude
        elseif Objective:IsA('Model') then 
            return (Objective:GetPivot().Position - RootPart.Position).Magnitude
		else
			return 0
		end
	elseif typeof(Objective) == "Vector3" then
		return (Objective - RootPart.Position).Magnitude
	elseif typeof(Objective) == "CFrame" then 
		return (Objective.Position - RootPart.Position).Magnitude
	end
	return 0
end

local function GetDistanceStart(Objective, Start)
	if typeof(Objective) == "Vector3" and typeof(Start) == "Vector3" then
		return (Objective - Start).Magnitude		
	elseif typeof(Objective) == "Vector2" and typeof(Start) == "Vector2" then
		return (Objective - Start).Magnitude
	else
		return math.huge
	end
end

local function IsAlive(model)
    if not model then return false end
    local Humanoids = model:FindFirstChildOfClass('Humanoid')
    if not Humanoids then return false end
    local RootParts = model:FindFirstChild('HumanoidRootPart')
    if not RootParts then return false end
    return Humanoids.Health > 0
end

local function Draw(type, props)
	local obj = Drawing.new(type)
	for k, v in pairs(props or {}) do obj[k] = v end
	return obj
end

local function SortAttribute(instance)
	local keys = {}
	for key in pairs(instance:GetAttributes()) do
		table.insert(keys, key)
	end
	table.sort(keys)
	return keys
end

local function WorldToViewPoint(position)
	return CurrentCamera:WorldToViewportPoint(typeof(position) == "Vector3" and position or position.Position)
end

-- FOV Circle setup
local Circle = Draw("Circle", {
	Thickness = 1,
	Color = Color3.fromRGB(255, 255, 255),
	Visible = false,
	NumSides = 60
})

-- Player Drawing Registration
local function AddPlayerDrawings(player)
	if not DrawingsData.Players[player] then
		DrawingsData.Players[player] = {
			BoxAround = Draw("Square", { Thickness = 1, Filled = false }),
			Name = Draw("Text", { Outline = true, Center = true, Size = 13, Color = Color3.fromRGB(255, 255, 255) }),
			Distance = Draw("Text", { Outline = true, Center = true, Size = 12, Color = Color3.fromRGB(200, 200, 200) }),
			HpBar = Draw("Line", { Thickness = 2 }),
			AimTracer = Draw("Line", { Thickness = 1 }),
			IsTargetAim = Draw("Square", { Thickness = 1, Filled = false })
		}
	end
end

for _, p in pairs(Players:GetPlayers()) do
	if p ~= Client then AddPlayerDrawings(p) end
end
Players.PlayerAdded:Connect(AddPlayerDrawings)
Players.PlayerRemoving:Connect(function(p)
	if DrawingsData.Players[p] then
		for _, v in pairs(DrawingsData.Players[p]) do v:Remove() end
		DrawingsData.Players[p] = nil
	end
end)

-- Main Render Loop
RunService.RenderStepped:Connect(function()
	Circle.Radius = c().PovSize or 250
	Circle.Visible = c().AimAssiant or false
	Circle.Color = c().RainbowPov and Color3.fromHSV((tick() % 5) / 5, 1, 1) or Color3.fromRGB(255, 255, 255)
	Circle.Position = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)

	for _, DrawObject in pairs(DrawingsData.Players) do
		DrawObject.AimTracer.Visible = false
		DrawObject.IsTargetAim.Visible = false
	end

	local ClosestTarget, ClosestDistance = nil, math.huge

	for _, TargetChar in pairs(Char.get_all()) do
		if TargetChar ~= Character and IsAlive(TargetChar) then
			local GetTargetPlayer = Players:GetPlayerFromCharacter(TargetChar)
			if GetTargetPlayer and not GetTargetPlayer:GetAttribute("InMenuCharacterCreator") and not GetTargetPlayer:GetAttribute("InSplashScreen") and not GetTargetPlayer:GetAttribute('IsSafeZoneProtected') and not TargetChar:GetAttribute('IsSpawnProtected') then
				local Root = TargetChar:FindFirstChild("HumanoidRootPart")
				if Root then
					if not (c().FriendIngore and GetTargetPlayer:IsFriendsWith(Client.UserId)) then
						local ScreenPos, OnScreen = WorldToViewPoint(Root)
						if OnScreen then
							local Vector2ScreenPos = Vector2.new(ScreenPos.X, ScreenPos.Y)
							local DistanceStart = GetDistanceStart(Vector2ScreenPos, Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2))
							if DistanceStart <= Circle.Radius and DistanceStart < ClosestDistance then
								ClosestTarget = TargetChar
								ClosestDistance = DistanceStart
							end
						end
					end
				end
			end
		end
	end

	c().AimAssiantTarget = ClosestTarget

	if ClosestTarget then  
		local GetTargetPlayer = Players:GetPlayerFromCharacter(ClosestTarget)
		if GetTargetPlayer then  
			local DrawObject = DrawingsData.Players[GetTargetPlayer]
			if DrawObject then  
				local SelectPart = ClosestTarget:FindFirstChild((c().PartTargetSelected or "Head"))
				if SelectPart then  
					local PositionScreen, OnScreen = WorldToViewPoint(SelectPart)

					DrawObject.AimTracer.Color = Color3.fromRGB(125, 21, 19)
					DrawObject.AimTracer.Visible = (c().AimAssiant and OnScreen) or false
					DrawObject.AimTracer.From = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
					DrawObject.AimTracer.To = Vector2.new(PositionScreen.X, PositionScreen.Y)

					DrawObject.IsTargetAim.Size = Vector2.new(1000 / PositionScreen.Z, 1000 / PositionScreen.Z)
					DrawObject.IsTargetAim.Position = Vector2.new(PositionScreen.X - Vector2.new(1000 / PositionScreen.Z, 1000 / PositionScreen.Z).X / 2, PositionScreen.Y - Vector2.new(1000 / PositionScreen.Z, 1000 / PositionScreen.Z).Y / 2)
					DrawObject.IsTargetAim.Color = Color3.fromRGB(180, 0, 0)
					DrawObject.IsTargetAim.Visible = (c().AimAssiant and OnScreen) or false
				end
			end
		end
	end
	
	for PlayerObject, DrawObject in pairs(DrawingsData.Players) do  
		if PlayerObject and IsAlive(PlayerObject.Character) then  
			local CharP = PlayerObject.Character
			local Root = CharP:FindFirstChild('HumanoidRootPart')
			local Head = CharP:FindFirstChild('Head')
			local ControllerNpc = CharP:FindFirstChildOfClass("Humanoid")
			if Root and Head and ControllerNpc then 
				local PositionRoot, OnScreen = WorldToViewPoint(Root)
				if OnScreen then  
					local PositionHead,_ = WorldToViewPoint(Head.Position + Vector3.new(0, 0.5, 0))
					local PositionLeg,_ = WorldToViewPoint(Root.Position - Vector3.new(0, 3, 0))
					local ScaleRoot = 1000 / PositionRoot.Z

					DrawObject.BoxAround.Size = Vector2.new(ScaleRoot, PositionHead.Y - PositionLeg.Y)
					DrawObject.BoxAround.Position = Vector2.new(PositionRoot.X - DrawObject.BoxAround.Size.X / 2, PositionRoot.Y - DrawObject.BoxAround.Size.Y / 2)
					DrawObject.BoxAround.Visible = c().BoxPlayerVisual or false
					DrawObject.BoxAround.Color = (c().FriendIngore and PlayerObject:IsFriendsWith(Client.UserId)) and Color3.fromRGB(4, 43, 150) or PlayerObject:GetAttribute('IsSafeZoneProtected') == true and Color3.fromRGB(7, 255, 44) or CharP:GetAttribute('IsSpawnProtected') == true and Color3.fromRGB(3, 41, 255) or Color3.fromRGB(201, 12, 204)

					DrawObject.Name.Position = Vector2.new(PositionHead.X, PositionHead.Y - 20)
					DrawObject.Name.Text = PlayerObject.Name
					DrawObject.Name.Visible = c().NamePlayerVisual or false 

					DrawObject.Distance.Text = "[" .. math.floor(GetDistanceRoot(Root)) .. "m]"
					DrawObject.Distance.Position = Vector2.new(PositionHead.X, PositionLeg.Y + 5)
					DrawObject.Distance.Visible = c().DistancePlayerVisual or false

					local HealthNpc = ControllerNpc.Health / ControllerNpc.MaxHealth
					DrawObject.HpBar.From = Vector2.new(DrawObject.BoxAround.Position.X + DrawObject.BoxAround.Size.X + 5, DrawObject.BoxAround.Position.Y + DrawObject.BoxAround.Size.Y * (1 - HealthNpc))
					DrawObject.HpBar.To = Vector2.new(DrawObject.BoxAround.Position.X + DrawObject.BoxAround.Size.X + 5, DrawObject.BoxAround.Position.Y + DrawObject.BoxAround.Size.Y)
					DrawObject.HpBar.Color = Color3.new(1 - HealthNpc, HealthNpc, 0)
					DrawObject.HpBar.Visible = c().HealthPlayerVisual or false
				else  
					for _, DrawingObjectData in pairs(DrawObject) do DrawingObjectData.Visible = false end
				end
			else  
				for _, DrawingObjectData in pairs(DrawObject) do DrawingObjectData.Visible = false end
			end
		else  
			for _, DrawingObjectData in pairs(DrawObject) do DrawingObjectData.Visible = false end
		end
	end
			
	for DropItem, DrawObject in pairs(DrawingsData.Item) do
		if not DropItem or not DropItem.Parent then
			if DrawObject.BoxAround then DrawObject.BoxAround:Remove() end
			if DrawObject.NameItem then DrawObject.NameItem:Remove() end
			if DrawObject.Distance then DrawObject.Distance:Remove() end
			DrawingsData.Item[DropItem] = nil
		end
	end
	
	for _, DropItemObject in pairs(DroppedFolder:GetChildren()) do
		if DropItemObject:IsA("Model") and DropItemObject:FindFirstChild("PickUpZone") and not DropItemObject:GetAttribute("Locked") then 
			if not DrawingsData.Item[DropItemObject] then 
				DrawingsData.Item[DropItemObject] = {
					BoxAround = Draw("Square", { Color = Color3.fromRGB(255, 0, 0), Thickness = 1, Filled = false }),
					NameItem = Draw("Text", { Color = Color3.fromRGB(255, 255, 255), Outline = true, Center = true }),
					Distance = Draw("Text", { Color = Color3.fromRGB(255, 255, 255), Outline = true, Center = true })
				}
			end
		end
	end
	
	for ItemObject, DrawObject in pairs(DrawingsData.Item) do   
		local PickUpZone = ItemObject.PickUpZone
		local Position2D, OnScreen = WorldToViewPoint(PickUpZone)

		if OnScreen then 
			local ItemTypeAttr = ItemObject:GetAttribute("item_type")
			local TargetItemFolder = ItemTypeAttr and ReplicatedStorage:FindFirstChild("Items"):FindFirstChild(ItemTypeAttr)
			local TargetItem = TargetItemFolder and TargetItemFolder:FindFirstChild(ItemObject.Name)
			local RarityNameVal = TargetItem and TargetItem:GetAttribute("RarityName") or "Common"
			local Blacklist = c().BlacklistRarityDropVisual or {}
			
			local StateVisibleDrop = ((ItemObject.Name == "Money" and (c().ItemDropVisual or false)) or (#Blacklist == 0 and (c().ItemDropVisual or false)) or (#Blacklist > 0 and not table.find(Blacklist, RarityNameVal) and (c().ItemDropVisual or false))) or false
			
			DrawObject.BoxAround.Size = Vector2.new(15, 15)
			DrawObject.BoxAround.Position = Vector2.new(Position2D.X - 15 / 2, Position2D.Y - 15 / 2)
			DrawObject.BoxAround.Color = RarityData[RarityNameVal] or Color3.fromRGB(255, 255, 255)
			DrawObject.BoxAround.Visible = StateVisibleDrop
			
			DrawObject.NameItem.Text = ItemObject.Name
			DrawObject.NameItem.Position = Vector2.new(Position2D.X, Position2D.Y - 15 / 2 - 10)
			DrawObject.NameItem.Visible = StateVisibleDrop
			
			DrawObject.Distance.Text = "(x" .. (tostring(ItemObject:GetAttribute(SortAttribute(ItemObject)[5] or "")) or "?") .. ")"
			DrawObject.Distance.Position = Vector2.new(Position2D.X, Position2D.Y + 15 / 2 + 4)
			DrawObject.Distance.Visible = StateVisibleDrop
		else  
			for _, ObjectDraw in pairs(DrawObject) do ObjectDraw.Visible = false end
		end
	end

	for _, v in pairs(Char.get_all()) do  
		if v ~= Character and IsAlive(v) then 
			local Root = v:FindFirstChild('HumanoidRootPart')
			local GetPlayer = Players:GetPlayerFromCharacter(v)
			if GetPlayer and Root then
				if not Root:FindFirstChild('ItemInventoryViewer') then  
					local InventoryViewer = Instance.new('BillboardGui')
					InventoryViewer.Name = "ItemInventoryViewer"
					InventoryViewer.AlwaysOnTop = true
					InventoryViewer.Adornee = Root
					InventoryViewer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
					InventoryViewer.Size = UDim2.new(0, 200, 0, 30)
					InventoryViewer.StudsOffset = Vector3.new(0, 4, 0)
					InventoryViewer.ExtentsOffset = Vector3.new(0, 1, 0)
					InventoryViewer.Parent = Root

					local Background = Instance.new('Frame')
					Background.Name = "BackgroundFrame"
					Background.BackgroundTransparency = 1
					Background.Size = UDim2.new(1, 0, 1, 0)
					Background.AnchorPoint = Vector2.new(0.5, 0.5)
					Background.Position = UDim2.new(0.5, 0, 0.5, 0)
					Background.Parent = InventoryViewer

					local ListLayout = Instance.new('UIListLayout')
					ListLayout.FillDirection = Enum.FillDirection.Horizontal
					ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
					ListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
					ListLayout.Padding = UDim.new(0, 5)
					ListLayout.Parent = Background
				end

				local ItemInventory = {}
				local ItemInventoryViewer = Root:FindFirstChild('ItemInventoryViewer')
				local BackgroundFrame = ItemInventoryViewer and ItemInventoryViewer:FindFirstChild('BackgroundFrame')

				if BackgroundFrame then
					for _, Container in pairs({GetPlayer.Backpack, v}) do
						if Container then
							for _, tool in pairs(Container:GetChildren()) do
								if tool:IsA("Tool") and not tool:GetAttribute("JobTool") and not tool:GetAttribute("Locked") then 
									local ItemFolder = (function()
										local attrs = tool:GetAttributes()
										for k, val in pairs(attrs) do
											if type(val) == "string" and val:lower():find("melee") then
												return ReplicatedStorage.Items.melee:GetChildren()
											end
										end
										if attrs.AmmoType and attrs.Recoil then
											return ReplicatedStorage.Items.gun:GetChildren()
										end
										return ReplicatedStorage.Items.throwable:GetChildren()
									end)()

									for _, ItemInReplicatedStorage in pairs(ItemFolder) do
										if tool:GetAttribute("RarityName") == ItemInReplicatedStorage:GetAttribute("RarityName") and tool:GetAttribute("RarityPrice") == ItemInReplicatedStorage:GetAttribute("RarityPrice") then
											local ImageId = ItemInReplicatedStorage:GetAttribute("ImageId")
											if ImageId then
												ItemInventory[ItemInReplicatedStorage.Name] = true
												if not BackgroundFrame:FindFirstChild(ItemInReplicatedStorage.Name) then
													local Icon2 = Instance.new('ImageLabel')
													Icon2.Name = ItemInReplicatedStorage.Name
													Icon2.Image = 'rbxassetid://137066731814190'
													Icon2.BackgroundTransparency = 1
													Icon2.BorderSizePixel = 0
													Icon2.ImageColor3 = RarityData[tool:GetAttribute("RarityName")] or Color3.fromRGB(255,255,255)
													Icon2.Size = UDim2.new(0,25,0,25)
													Icon2.Parent = BackgroundFrame

													local IconBase = Instance.new('ImageLabel')
													IconBase.Name = "IconBase"
													IconBase.Image = ImageId
													IconBase.BackgroundTransparency = 1
													IconBase.BorderSizePixel = 0
													IconBase.Size = UDim2.new(0.9,0,0.9,0)      
													IconBase.AnchorPoint = Vector2.new(0.5, 0.5)
													IconBase.Position = UDim2.new(0.5,0,0.5,0)   
													IconBase.Parent = Icon2
												end
											end
										end
									end
								end
							end
						end
					end

					ItemInventoryViewer.Enabled = (c().InventoryPlayerVisual and v:FindFirstChild('Humanoid').Health > 0) or false

					for _, IconImageObject in pairs(BackgroundFrame:GetChildren()) do
						if IconImageObject:IsA("ImageLabel") and not ItemInventory[IconImageObject.Name] then
							IconImageObject:Destroy()
						end
					end
				end
			end
		end
	end

	if Character and IsAlive(Character) then 
		Humanoid.JumpHeight = (c().JumpPowerCustom and (c().JumpPowerValue or 4)) or 3.89

		local dir = Humanoid.MoveDirection
		if dir.Magnitude > 0 then
			Network.send("set_sprinting_1", true)
			if c().WalkSpeedCustom then   
				if Humanoid:GetAttribute("TargetWalkSpeed") ~= 30 and Humanoid.WalkSpeed ~= 30 then  
					Humanoid:SetAttribute("TargetWalkSpeed", 30)
					Humanoid.WalkSpeed = 30
				end
			 	RootPart.CFrame = RootPart.CFrame + (dir.Unit * ((c().WalkSpeedValue or 3) / 145.5))
			end
		end
	end
end)

-- Lock Backpack Tools
do
	for _, ToolInBackPack in pairs(Backpack:GetChildren()) do
		if ToolInBackPack and ToolInBackPack:IsA("Tool") and not ToolInBackPack:GetAttribute('Locked') then
			ToolInBackPack:SetAttribute("Locked", true)
		end
	end 

	Backpack.ChildAdded:Connect(function(ToolInBackPack)
		if ToolInBackPack and ToolInBackPack:IsA("Tool") and not ToolInBackPack:GetAttribute('Locked') then
			ToolInBackPack:SetAttribute("Locked", true)
		end
	end)
end 

-- Override Util Tween
do 
	local OldTween = Util.tween
	Util.tween = function(instance, tweenInfo, properties)
		if instance and instance:IsA("NumberValue") and properties and properties.Value ~= nil then
			instance.Value = properties.Value
			return {Cancel = function() end}
		end
		return OldTween(instance, tweenInfo, properties)
	end
end

-- Background Loops
task.spawn(function()
	while task.wait() do 
		if c().ItemDroppedGraber then  
			xpcall(function()
				if #DroppedFolder:GetChildren() > 0 then
					for i, v in pairs(DroppedFolder:GetChildren()) do 
						if v:IsA('Model') and v:FindFirstChild("PickUpZone") then  
							if GetDistanceRoot(v) < 15 then  
								Network.get('pickup_dropped_item', v)
							end
						end
					end
				end
			end, warn)
		end
	end
end)

task.spawn(function()
	while task.wait() do  
		if c().SpeedBostVehicle then  
			xpcall(function()
				if VehicleSystem.get_car_player_is_in() then  
					local Chassic = VehicleSystem.get_car_player_is_in().PrimaryPart
					if not Chassic then return end
					local vel = Chassic.AssemblyLinearVelocity
					local dir = Chassic.CFrame.LookVector
					local speed = vel.Magnitude
					if speed > 0 then
						local newVel = dir * c().SpeedBostVehicle
						Chassic.AssemblyLinearVelocity = Vector3.new(newVel.X, vel.Y, newVel.Z)
					end
				end
			end, warn)
		end
	end
end)

--------------------------------------------------------------------------------
-- WIND UI INTEGRATION (Kaiser Hub | Blockspin)
--------------------------------------------------------------------------------
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
	Title = "Kaiser Hub | Blockspin",
	Icon = "rbxassetid://108952141737523",
	Author = "",
	Folder = "boss",
	Size = UDim2.fromOffset(400, 400),
	Theme = "Dark",
	Transparent = true,
	Resizable = true,
})

Window:Tag({
    Title = "Kaiser Hub",
    Icon = "github",
    Color = Color3.fromHex("#00aaff"),
    Radius = 10, 
})

Window:Tag({
    Title = "Blockspin",
    Icon = "crown",
    Color = Color3.fromHex("#ff0000"),
    Radius = 10, 
})

-- Tabs Configuration
local Tabs = {
	Pvp = Window:Tab({ Title = "PvP", Icon = "crosshair" }),
	Visual = Window:Tab({ Title = "Visuals", Icon = "eye" }),
	Vehicle = Window:Tab({ Title = "Vehicle", Icon = "car" }),
	Miscellaneous = Window:Tab({ Title = "Misc", Icon = "sliders" }),
}

-- PvP Section
do
	local General = Tabs.Pvp:Section({ Title = "ทั่วไป" })
	
	General:Toggle({
		Title = "ล็อคหัว",
		Desc = "ตัวช่วยในการล็อคหัว ด้วย Pov",
		Value = c().AimAssiant or false,
		Callback = function(val) c().AimAssiant = val end
	})
	
	General:Toggle({
		Title = "ยิงทะลุ",
		Desc = "ยิงทะลุกําแพง",
		Value = c().WallBang or false,
		Callback = function(val) c().WallBang = val end
	})
	
	General:Toggle({
		Title = "ยิง x2",
		Desc = "ยิงรอบเดียวจะแถมยิงอีก 1 รอบการเป็น 2 รอบ",
		Value = c().MultiShoot or false,
		Callback = function(val) c().MultiShoot = val end
	})
	
	General:Toggle({
		Title = "ไม่ล็อคเพื่อน",
		Desc = "ถ้าเพื่อนเป็นเป้าหมาย ระบบจะไม่สนใจละข้ามทันที",
		Value = c().FriendIngore or false,
		Callback = function(val) c().FriendIngore = val end
	})
	
	General:Toggle({
		Title = "วงกลมสีรุ้ง",
		Desc = "Pov สีจะกลายเป็นสีรุ้ง",
		Value = c().RainbowPov or false,
		Callback = function(val) c().RainbowPov = val end
	})
	
	General:Dropdown({
		Title = "เลือกส่วนที่ต้องการยิง",
		Values = {"Head", "HumanoidRootPart"},
		Value = c().PartTargetSelected or "Head",
		Callback = function(val) c().PartTargetSelected = val end
	})
	
	General:Slider({
		Title = "ขนาด Pov",
		Min = 1,
		Max = 800,
		Default = c().PovSize or 250,
		Callback = function(val) c().PovSize = val end
	})

	local GunModifies = Tabs.Pvp:Section({ Title = "ปรับแต่งปืน" })

	GunModifies:Button({
		Title = "ปรับแต่ง",
		Desc = "ปรับแต่งปืนที่คุณกําลังถือโดยทันที",
		Callback = function()
			if not Character:FindFirstChildWhichIsA('Tool') then return end  
			for _, GunExampleObject in pairs(ReplicatedStorage.Items.gun:GetChildren()) do  
				if Character:FindFirstChildWhichIsA('Tool').Name == GunExampleObject.Name then  
					Character:FindFirstChildWhichIsA('Tool'):SetAttribute("fire_rate", (c().FireRateGun or Character:FindFirstChildWhichIsA('Tool'):GetAttribute("fire_rate")))
					Character:FindFirstChildWhichIsA('Tool'):SetAttribute("accuracy", (c().AccuracyGun or Character:FindFirstChildWhichIsA('Tool'):GetAttribute("accuracy")))
					Character:FindFirstChildWhichIsA('Tool'):SetAttribute("Recoil", (c().RecoilGun or Character:FindFirstChildWhichIsA('Tool'):GetAttribute("Recoil")))
					Character:FindFirstChildWhichIsA('Tool'):SetAttribute("Durability", (c().DurabilityGun or Character:FindFirstChildWhichIsA('Tool'):GetAttribute("Durability")))
					Character:FindFirstChildWhichIsA('Tool'):SetAttribute("automatic", (c().AutomaticGun or Character:FindFirstChildWhichIsA('Tool'):GetAttribute("automatic")))
				end
			end
		end
	})

	GunModifies:Toggle({
		Title = "โหมดออโต้",
		Desc = "โหมดปืนออโต้ ยิงรัว",
		Value = c().AutomaticGun or false,
		Callback = function(val) c().AutomaticGun = val end
	})

	GunModifies:Slider({
		Title = "อัตราการยิง",
		Min = 1,
		Max = 3000,
		Default = c().FireRateGun or 1000,
		Callback = function(val) c().FireRateGun = val end
	})

	GunModifies:Slider({
		Title = "แรงดีด",
		Min = 0,
		Max = 10,
		Default = c().RecoilGun or 0,
		Callback = function(val) c().RecoilGun = val end
	})

	GunModifies:Slider({
		Title = "ความแม่น",
		Min = 0,
		Max = 1,
		Default = c().AccuracyGun or 1,
		Callback = function(val) c().AccuracyGun = val end
	})

	GunModifies:Slider({
		Title = "ความทนทาน",
		Min = 1,
		Max = 3000,
		Default = c().DurabilityGun or 1000,
		Callback = function(val) c().DurabilityGun = val end
	})
end

-- Visual Section
do
	local GeneralVisual = Tabs.Visual:Section({ Title = "ทั่วไป" })
	
	GeneralVisual:Toggle({
		Title = "ชื่อ",
		Desc = "เปิดใช้งานเพื่อดูชื่อเล่นทั้งหมด",
		Value = c().NamePlayerVisual or false,
		Callback = function(val) c().NamePlayerVisual = val end
	})
	
	GeneralVisual:Toggle({
		Title = "กล่อง",
		Desc = "เปิดใช้งานเพื่อดูกล่องที่ตัวผู้เล่นทั้งหมด",
		Value = c().BoxPlayerVisual or false,
		Callback = function(val) c().BoxPlayerVisual = val end
	})
	
	GeneralVisual:Toggle({
		Title = "เลือด",
		Desc = "เปิดใช้งานเพื่อดูเลือดผู้เล่นทั้งหมด",
		Value = c().HealthPlayerVisual or false,
		Callback = function(val) c().HealthPlayerVisual = val end
	})
	
	GeneralVisual:Toggle({
		Title = "ระยะห่าง",
		Desc = "เปิดใช้งานเพื่อดูระยะห่างผู้เล่นทั้งหมด",
		Value = c().DistancePlayerVisual or false,
		Callback = function(val) c().DistancePlayerVisual = val end
	})
	
	GeneralVisual:Toggle({
		Title = "ของในตัว",
		Desc = "เปิดใช้งานเพื่อดูของในตัวผู้เล่นทั้งหมด",
		Value = c().InventoryPlayerVisual or false,
		Callback = function(val) c().InventoryPlayerVisual = val end
	})

	local ItemDropVisual = Tabs.Visual:Section({ Title = "ดูของตก" })
	
	ItemDropVisual:Toggle({
		Title = "เปิดใช้งานดูของตก",
		Desc = "เปิดใช้งานละจะเห็นของที่ตกทั้งหมด",
		Value = c().ItemDropVisual or false,
		Callback = function(val) c().ItemDropVisual = val end
	})
	
	ItemDropVisual:Dropdown({
		Title = "เลือกชนิดที่ต้องการจะปิด",
		Values = RarityName,
		Multi = true,
		Value = c().BlacklistRarityDropVisual or {},
		Callback = function(val) c().BlacklistRarityDropVisual = val end
	})

	local LagReduce = Tabs.Visual:Section({ Title = "ลดอาการแล็ค" })
	
	LagReduce:Button({
		Title = "ลดอาการแล็ค",
		Desc = "กดปุ่มเพื่อเปิดใช้งานโหมดคุณภาพตํ่า",
		Callback = function()
			Lighting.FogEnd = 1e10
			Lighting.FogStart = 1e10
			Lighting.Brightness = 1.2
			Lighting.GlobalShadows = false
			Lighting.EnvironmentDiffuseScale = 0.5
			Lighting.EnvironmentSpecularScale = 0.3
			Lighting.ShadowSoftness = 0

			for _, effect in ipairs(Lighting:GetChildren()) do
				if effect:IsA("BloomEffect") then effect.Intensity = 0.2 end
				if effect:IsA("BlurEffect") then effect.Size = 0 end
				if effect:IsA("SunRaysEffect") then effect.Intensity = 0.1 end
				if effect:IsA("ColorCorrectionEffect") then effect.Saturation = 0.7 end
			end

			for _, v in ipairs(workspace:GetDescendants()) do
				if v:IsA("BasePart") then
					v.Material = Enum.Material.SmoothPlastic
					v.CastShadow = false
					v.Reflectance = 0
				elseif v:IsA("Decal") then
					v.Transparency = 1
				end
			end

			if setfpscap then setfpscap(240) end
		end
	})
end

-- Vehicle Section
do
	local MiscellaneousVehicle = Tabs.Vehicle:Section({ Title = "อื่นๆ" })
	
	MiscellaneousVehicle:Button({
		Title = "ดึงรถของคุณเอง",
		Desc = "กดเพื่อดึงรถของคุณ",
		Callback = function()
			for _, vehicle in pairs(Vehicles:GetChildren()) do
				if vehicle:IsA("Model") then
					local ownerId = vehicle:GetAttribute("OwnerUserId")
					if ownerId and ownerId == Client.UserId then
						vehicle:PivotTo(RootPart.CFrame * CFrame.new(0, 5, -5))
						return
					end
				end
			end
		end
	})

	MiscellaneousVehicle:Button({
		Title = "พังรถที่นั่งอยู่ (ต้องเป็นคนขับ)",
		Desc = "ระเบิดรถที่นั่งอยู่แบบชิวๆ",
		Callback = function()
			for _ = 1, 15 do
				Network.send("crashed_car", VehicleSystem.get_car_player_is_in(), 150)
			end
		end
	})
end

-- Miscellaneous Section
do
	local Miscellaneous = Tabs.Miscellaneous:Section({ Title = "อื่นๆ" })

	Miscellaneous:Button({
		Title = "ข้ามสุ่มกล่อง",
		Desc = "ข้ามกล่องที่กําลังสุ่มทันที",
		Callback = function()
			if CrateController.spinning.get() then return end 
			CrateController.skip_spin()
		end
	})
	
	Miscellaneous:Button({
		Title = "รับเควสทั้งหมด",
		Desc = "เคลียร์เควสทั้งหมดในปุ่มเดียวทันที",
		Callback = function()
			local QuestHolder = PlayerGui:FindFirstChild('Quests') and PlayerGui:FindFirstChild('Quests'):FindFirstChild('QuestsHolder')
			if QuestHolder and QuestHolder:FindFirstChild('QuestsScrollingFrame') then
				for _, QuestName in pairs(QuestHolder.QuestsScrollingFrame:GetChildren()) do 
					if QuestName:IsA("Frame") or QuestName:IsA("TextButton") or QuestName:IsA("ImageButton") then
						Network.get("claim_quest", QuestName.Name)
					end
				end
			end
		end
	})
end

