-- Blox Fruits - Collect ALL Chests in Server Instantly
local Players = game:GetService("Players")
local player = Players.LocalPlayer

if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
    player.CharacterAdded:Wait()
end
local hrp = player.Character:WaitForChild("HumanoidRootPart")

-- Find all chest parts in the server
local chests = {}
for _, v in pairs(workspace:GetDescendants()) do
    if v:IsA("BasePart") and v.Parent and v.Parent.Name:lower():find("chest") then
        table.insert(chests, v)
    end
end

-- Teleport to each chest extremely fast until it’s collected
for _, chest in ipairs(chests) do
    if chest and chest.Parent then
        local startTime = tick()
        while chest and chest.Parent and tick() - startTime < 0.5 do
            hrp.CFrame = chest.CFrame + Vector3.new(0, 3, 0)
            task.wait(0.005) -- 200 times per second
        end
    end
end

print("✅ All chests in server collected!")
