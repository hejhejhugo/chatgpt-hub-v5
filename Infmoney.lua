-- Blox Fruits - 0.5s All Chest Collector + Auto Server Hop
-- ⚠️ Delta-friendly

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local placeId = game.PlaceId

-- Wait for character
if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
    player.CharacterAdded:Wait()
end
local hrp = player.Character:WaitForChild("HumanoidRootPart")

-- Function to collect all chests
local function collectAllChests()
    local chests = {}
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Parent and v.Parent.Name:lower():find("chest") then
            table.insert(chests, v)
        end
    end

    -- Teleport to each chest extremely fast (0.5 seconds total)
    local startTime = tick()
    for _, chest in ipairs(chests) do
        while chest and chest.Parent and (tick() - startTime) < 0.5 do
            hrp.CFrame = chest.CFrame + Vector3.new(0, 3, 0)
            task.wait(0.005) -- 200 tps
        end
    end
end

-- Function to server hop
local function serverHop()
    local servers = {}
    local req = game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100")
    local data = HttpService:JSONDecode(req)

    for _, server in pairs(data.data) do
        if server.playing < server.maxPlayers then
            table.insert(servers, server.id)
        end
    end

    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(1, #servers)], player)
    else
        print("No servers found to hop into.")
    end
end

-- Main loop
while true do
    collectAllChests()
    task.wait(0.1) -- short pause before hop
    serverHop()
end
