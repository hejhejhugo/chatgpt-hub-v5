-- Universal Autofarm GUI + AutoFarm Level (Blox Fruits) - Sea 1/2/3 quest DB included
-- Keeps previous features: NPC selector, skip target, minimizable GUI, iPhone autoclicker, respawn resume

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")

-- State
local selectedTool = nil
local autoFarmNPC = false
local autoFarmPlayer = false
local autoFarmLevel = false
local currentTarget = nil
local targetFilter = nil
local skippedTargets = {}
local canFarm = true

-- Helper: attempt to read player level (Blox Fruits typical location)
local function getPlayerLevel()
	local success, lvl = pcall(function()
		if LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Level") then
			return LocalPlayer.Data.Level.Value
		end
		-- fallback: sometimes stored elsewhere
		if LocalPlayer:FindFirstChild("PlayerGui") then
			-- no reliable fallback; return nil
			return nil
		end
	end)
	return success and lvl or nil
end

-- ===== Blox Fruits Quest Database (approximate / typical NPC model names) =====
-- For each quest entry: minLevel, maxLevel, questGiver (string to find in workspace), npcNames (list of model names to kill), questName (informational)
-- THIS DATABASE IS A best-effort mapping; if some names don't match your server, tell me and I will update.
local QuestDB = {
	-- Sea 1 (example ranges)
	{min=1,   max=9,   giver="PirateNPC",         npcs={"Bandit","Monkey"},            name="Starter Pirate (low)"},
	{min=10,  max=14,  giver="JungleMaster",       npcs={"Monkey","Gorilla"},           name="Jungle"},
	{min=15,  max=29,  giver="Bandit Leader",      npcs={"Bandit"},                     name="Bandit Camp"},
	{min=30,  max=59,  giver="Pirate Captain",     npcs={"Pirate","Brute"},             name="Pirate Village"},
	{min=60,  max=89,  giver="Desert Bandit NPC",  npcs={"DesertBandit","DesertOfficer"},name="Desert"},
	{min=90,  max=99,  giver="Snowman NPC",        npcs={"Snowman","Yeti"},             name="Frozen Village"},
	{min=100, max=124, giver="Marine Recruiter",   npcs={"Marine","Officer"},           name="Marine Fortress"},
	{min=125, max=199, giver="Colosseum Master",   npcs={"Gladiator","TogaWarrior"},    name="Colosseum / Arena"},
	-- Sea 2 (example)
	{min=700,  max=874, giver="Kingdom Guard",     npcs={"Raider","Mercenary"},         name="Kingdom of Rose"},
	{min=875,  max=999, giver="Graveyard NPC",     npcs={"Zombie","Vampire"},           name="Graveyard"},
	{min=1000, max=1249,giver="Snow Mountain NPC", npcs={"SnowTrooper","WinterWarrior"},name="Snow Mountain"},
	{min=1250, max=1499,giver="Cursed Ship NPC",   npcs={"CursedCrew","CursedCaptain"}, name="Cursed Ship"},
	-- Sea 3 (example)
	{min=1500, max=1599,giver="Port Town NPC",     npcs={"Millionaire","Billionaire"},  name="Port Town"},
	{min=1600, max=1799,giver="Hydra Commander",   npcs={"HydraCrew","EmpressGuard"},   name="Hydra Island"},
	{min=1800, max=9999,giver="Great Tree NPC",    npcs={"MarineCommodore","KiloWarrior"},name="Great Tree / Endgame"}
}
-- Note: the above NPC and quest giver names are generic/representative. If you see mismatches, give me the actual model names from your workspace.

-- ===== GUI BUILD =====
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "UniversalFarmHub"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 370, 0, 520)
main.Position = UDim2.new(0.05, 0, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

local minimizeButton = Instance.new("TextButton", main)
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -35, 0, 5)
minimizeButton.Text = "_"
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextColor3 = Color3.new(1, 1, 1)
minimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Instance.new("UICorner", minimizeButton)

local minimizedButton = Instance.new("TextButton", gui)
minimizedButton.Size = UDim2.new(0, 50, 0, 50)
minimizedButton.Position = UDim2.new(0.05, 0, 0.2, 0)
minimizedButton.Text = "+"
minimizedButton.Visible = false
minimizedButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
minimizedButton.TextColor3 = Color3.new(1, 1, 1)
minimizedButton.Font = Enum.Font.GothamBold
minimizedButton.TextSize = 22
Instance.new("UICorner", minimizedButton)

minimizeButton.MouseButton1Click:Connect(function()
	main.Visible = false
	minimizedButton.Visible = true
end)
minimizedButton.MouseButton1Click:Connect(function()
	main.Visible = true
	minimizedButton.Visible = false
end)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -40, 0, 40)
title.Position = UDim2.new(0, 10, 0, 5)
title.Text = "⚔️ Universal Autofarm"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

-- Buttons
local npcFarmBtn = Instance.new("TextButton", main)
npcFarmBtn.Size = UDim2.new(0.8, 0, 0, 40)
npcFarmBtn.Position = UDim2.new(0.1, 0, 0, 60)
npcFarmBtn.Text = "AutoFarm NPCs: OFF"
npcFarmBtn.Font = Enum.Font.Gotham
npcFarmBtn.TextColor3 = Color3.new(1, 1, 1)
npcFarmBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Instance.new("UICorner", npcFarmBtn)

local playerFarmBtn = npcFarmBtn:Clone(); playerFarmBtn.Parent = main
playerFarmBtn.Position = UDim2.new(0.1, 0, 0, 110)
playerFarmBtn.Text = "AutoFarm Player: OFF"

local levelFarmBtn = npcFarmBtn:Clone(); levelFarmBtn.Parent = main
levelFarmBtn.Position = UDim2.new(0.1, 0, 0, 160)
levelFarmBtn.Text = "AutoFarm Level: OFF"

local toolBtn = npcFarmBtn:Clone(); toolBtn.Parent = main
toolBtn.Position = UDim2.new(0.1, 0, 0, 210)
toolBtn.Text = "Select Tool (Click)"

local skipTargetBtn = npcFarmBtn:Clone(); skipTargetBtn.Parent = main
skipTargetBtn.Position = UDim2.new(0.1, 0, 0, 260)
skipTargetBtn.Text = "⏭️ Skip Target"

local toolLabel = Instance.new("TextLabel", main)
toolLabel.Size = UDim2.new(0.8, 0, 0, 30)
toolLabel.Position = UDim2.new(0.1, 0, 0, 305)
toolLabel.Text = "Tool: None"
toolLabel.Font = Enum.Font.Gotham
toolLabel.TextSize = 14
toolLabel.TextColor3 = Color3.new(1, 1, 1)
toolLabel.BackgroundTransparency = 1

local statusLabel = Instance.new("TextLabel", main)
statusLabel.Size = UDim2.new(0.8, 0, 0, 30)
statusLabel.Position = UDim2.new(0.1, 0, 0, 335)
statusLabel.Text = "Status: Idle"
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 14
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.BackgroundTransparency = 1
statusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- NPC selector
local scrollFrame = Instance.new("ScrollingFrame", main)
scrollFrame.Size = UDim2.new(0.8, 0, 0, 140)
scrollFrame.Position = UDim2.new(0.1, 0, 0, 370)
scrollFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 6
Instance.new("UICorner", scrollFrame)

local npcListLayout = Instance.new("UIListLayout", scrollFrame)
npcListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- ===== Button logic =====
npcFarmBtn.MouseButton1Click:Connect(function()
	autoFarmNPC = not autoFarmNPC
	npcFarmBtn.Text = "AutoFarm NPCs: " .. (autoFarmNPC and "ON" or "OFF")
end)

playerFarmBtn.MouseButton1Click:Connect(function()
	autoFarmPlayer = not autoFarmPlayer
	playerFarmBtn.Text = "AutoFarm Player: " .. (autoFarmPlayer and "ON" or "OFF")
end)

levelFarmBtn.MouseButton1Click:Connect(function()
	autoFarmLevel = not autoFarmLevel
	levelFarmBtn.Text = "AutoFarm Level: " .. (autoFarmLevel and "ON" or "OFF")
	-- when enabling level farm, we prefer it over generic npc farm
	if autoFarmLevel then
		statusLabel.Text = "Status: AutoFarm Level enabled"
	end
end)

toolBtn.MouseButton1Click:Connect(function()
	for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
		if tool:IsA("Tool") then
			selectedTool = tool.Name
			toolLabel.Text = "Tool: " .. selectedTool
			break
		end
	end
end)

skipTargetBtn.MouseButton1Click:Connect(function()
	if currentTarget then
		table.insert(skippedTargets, currentTarget)
		currentTarget = nil
		statusLabel.Text = "Status: Skipped target"
	end
end)

-- Build NPC list
local npcNames = {}
for _, npc in pairs(workspace:GetDescendants()) do
	if npc:IsA("Model") and npc:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(npc) then
		if not table.find(npcNames, npc.Name) then
			table.insert(npcNames, npc.Name)
		end
	end
end
for _, name in ipairs(npcNames) do
	local button = Instance.new("TextButton", scrollFrame)
	button.Size = UDim2.new(1, 0, 0, 25)
	button.Text = name
	button.TextColor3 = Color3.new(1, 1, 1)
	button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	button.Font = Enum.Font.Gotham
	button.TextSize = 14
	Instance.new("UICorner", button)
	button.MouseButton1Click:Connect(function()
		targetFilter = name
		statusLabel.Text = "Status: Filter set: "..name
	end)
end
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #npcNames * 30)

-- Utils
local function isDead(h) return not h or h.Health <= 0 end
local function isPlayerModel(m) return Players:GetPlayerFromCharacter(m) end

-- Respawn watcher -> resume farming after 10s
LocalPlayer.CharacterAdded:Connect(function()
	canFarm = false
	wait(10)
	canFarm = true
	statusLabel.Text = "Status: Respawned - resumed"
end)

-- Autoclicker (iPhone)
ContextActionService:BindAction("AutoClick", function(_, inputState)
	if inputState == Enum.UserInputState.Begin then
		local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
		if tool then
			pcall(function() tool:Activate() end)
		end
	end
end, false, Enum.UserInputType.MouseButton1)

-- ===== AutoFarm Level helpers =====

-- Find quest entry for level (highest matching)
local function findQuestForLevel(level)
	local best = nil
	for _, q in ipairs(QuestDB) do
		if level >= q.min and level <= q.max then
			best = q
			break
		end
	end
	return best
end

-- Attempt to find a model in workspace by simple name matching (case-insensitive)
local function findModelByName(name)
	if not name then return nil end
	name = name:lower()
	-- search descendants quickly
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj.Name and obj.Name:lower():find(name) then
			-- prefer one with HumanoidRootPart
			if obj:FindFirstChild("HumanoidRootPart") then
				return obj
			end
		end
	end
	return nil
end

-- Try to accept quest by moving to giver and interacting with proximity prompts (best-effort)
local function tryAcceptQuest(questGiverModel)
	if not questGiverModel then return false end
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	-- try to move close (teleport into position)
	pcall(function()
		local part = questGiverModel:FindFirstChild("HumanoidRootPart") or questGiverModel:FindFirstChildWhichIsA("BasePart")
		if part then
			hrp.CFrame = part.CFrame * CFrame.new(0, 2, 2) -- stand in front
		end
	end)

	-- attempt to trigger ProximityPrompts inside the giver (common for quests)
	local foundPrompt = false
	for _, obj in pairs(questGiverModel:GetDescendants()) do
		if obj:IsA("ProximityPrompt") then
			foundPrompt = true
			pcall(function()
				-- try to fire by simulating proximity by moving into prompt's parent
				local parentPart = obj.Parent
				if parentPart and parentPart:IsA("BasePart") then
					hrp.CFrame = parentPart.CFrame + Vector3.new(0,2,0)
					wait(0.3)
				end
				-- some games auto-accept when near the prompt; otherwise attempt to InputHoldBegin/End if available
				if obj.Trigger then
					-- some exploit APIs expose :Trigger; wrapped in pcall
					pcall(function() obj:Trigger() end)
				end
			end)
		end
	end

	-- if there was a prompt, wait small time and assume quest accepted
	if foundPrompt then
		wait(1.2)
		return true
	end

	-- fallback: maybe touching the NPC's head triggers acceptance
	wait(0.6)
	return false
end

-- Check whether current active quest matches quest entry (best-effort)
-- This is game-specific; we try to find Player's quest status in common locations
local function playerHasQuest(q)
	-- best-effort: check if LocalPlayer has a value under "Quest" or similar
	if not q then return false end
	-- Many private servers store quest progress under LocalPlayer.PlayerGui or LocalPlayer:FindFirstChild("Quests")
	-- We'll try a few plausible places:
	local function checkGui()
		local pg = LocalPlayer:FindFirstChild("PlayerGui")
		if pg then
			for _, g in pairs(pg:GetDescendants()) do
				if g.Name and type(g.Value)~="userdata" then
					-- ignore
				end
			end
		end
	end
	-- We can't reliably detect; return false to cause acceptance attempts
	return false
end

-- Find nearest NPC model whose name matches any in npcNames (case-insensitive)
local function findNearestQuestNPC(npcNames, fromPos)
	local nearest, dist = nil, math.huge
	for _, npc in pairs(workspace:GetDescendants()) do
		if npc:IsA("Model") and not isPlayerModel(npc) then
			local hum = npc:FindFirstChildOfClass("Humanoid")
			local hrpNpc = npc:FindFirstChild("HumanoidRootPart")
			if hum and hrpNpc and hum.Health > 0 then
				for _, nm in ipairs(npcNames) do
					if npc.Name:lower():find(nm:lower()) then
						local d = (hrpNpc.Position - fromPos).Magnitude
						if d < dist and not table.find(skippedTargets, hrpNpc) then
							dist = d
							nearest = hrpNpc
						end
					end
				end
			end
		end
	end
	return nearest
end

-- ===== Main loop =====
RunService.Heartbeat:Connect(function()
	-- if no farming toggles enabled, skip
	if not autoFarmNPC and not autoFarmPlayer and not autoFarmLevel then return end
	if not canFarm then return end

	-- Prevent conflicting automatic NPC farming when level farm is on: level farm takes priority
	if autoFarmLevel then
		autoFarmNPC = false
		autoFarmPlayer = false
	end

	local character = LocalPlayer.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end
	local hrp = character.HumanoidRootPart

	-- equip tool if specified
	if selectedTool and not character:FindFirstChild(selectedTool) and LocalPlayer.Backpack:FindFirstChild(selectedTool) then
		pcall(function() character.Humanoid:EquipTool(LocalPlayer.Backpack[selectedTool]) end)
	end

	-- Reset dead or invalid current target
	if currentTarget then
		local model = currentTarget:FindFirstAncestorOfClass("Model")
		if not model or not model:FindFirstChildOfClass("Humanoid") or isDead(model:FindFirstChildOfClass("Humanoid")) then
			currentTarget = nil
		end
	end

	-- ---------- AutoFarm Level logic ----------
	if autoFarmLevel then
		local lvl = getPlayerLevel()
		if not lvl then
			statusLabel.Text = "Status: Could not read level"
			-- still try generic fallback: pick nearest
		else
			-- find quest entry
			local q = findQuestForLevel(lvl)
			if q then
				statusLabel.Text = "Status: Farming level ("..lvl..") -> "..(q.name or "quest")
				-- try accept quest if we don't already have it (best-effort)
				-- find quest giver model
				local giverModel = findModelByName(q.giver)
				if giverModel then
					-- attempt acceptance (best-effort) every loop until it registers
					tryAcceptQuest(giverModel)
				end

				-- Now find nearest quest NPC from q.npcs
				if not currentTarget then
					currentTarget = findNearestQuestNPC(q.npcs, hrp.Position)
				end
			else
				statusLabel.Text = "Status: No quest entry for level "..tostring(lvl)
			end
		end
	end

	-- ---------- AutoFarm NPC logic (if not level farming) ----------
	if not currentTarget and autoFarmNPC then
		for _, npc in pairs(workspace:GetDescendants()) do
			if npc:IsA("Model") and npc:FindFirstChildOfClass("Humanoid") and not isPlayerModel(npc) then
				local hum = npc:FindFirstChildOfClass("Humanoid")
				local hrpNpc = npc:FindFirstChild("HumanoidRootPart")
				if hum and hrpNpc and hum.Health > 0 and not table.find(skippedTargets, hrpNpc) then
					if (not targetFilter or npc.Name == targetFilter) then
						currentTarget = hrpNpc
						statusLabel.Text = "Status: AutoFarm NPC target: "..npc.Name
						break
					end
				end
			end
		end
	end

	-- ---------- AutoFarm Player logic ----------
	if not currentTarget and autoFarmPlayer then
		local nearest, dist = nil, math.huge
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and not player.Character:FindFirstChild("ForceField") then
				local hum = player.Character:FindFirstChildOfClass("Humanoid")
				if hum and not isDead(hum) then
					local d = (player.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
					if d < dist then
						dist = d
						nearest = player.Character.HumanoidRootPart
					end
				end
			end
		end
		currentTarget = nearest
	end

	-- ---------- Move to and attack ----------
	if currentTarget then
		-- stay a safe distance behind target
		local distanceBehind = 8
		local targetPos = currentTarget.Position - currentTarget.CFrame.LookVector * distanceBehind + Vector3.new(0, 3, 0)
		pcall(function() hrp.CFrame = CFrame.new(targetPos, currentTarget.Position) end)
		-- trigger autoclick
		pcall(function() ContextActionService:CallFunction("AutoClick", Enum.UserInputState.Begin) end)
	end
end)
