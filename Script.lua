local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- ⚙️ Settings (tweak these!)
local ORB_COUNT   = 12     -- number of orbs in the ring
local RADIUS      = 5      -- distance from the player (studs)
local SPEED       = 1.2    -- orbit speed (radians per second)
local BOB_HEIGHT  = 0.8    -- vertical wobble amount
local ORB_SIZE    = 0.7    -- size of each orb
local COLOR_SPEED = 0.15   -- how fast the rainbow cycles
local TRAIL_TIME  = 0.6    -- trail length in seconds

local function createOrb(parent)
	local orb = Instance.new("Part")
	orb.Shape = Enum.PartType.Ball
	orb.Size = Vector3.one * ORB_SIZE
	orb.Material = Enum.Material.Neon
	orb.Anchored = true
	orb.CanCollide = false
	orb.CanQuery = false
	orb.CanTouch = false
	orb.CastShadow = false
	orb.Parent = parent

	local light = Instance.new("PointLight")
	light.Range = 8
	light.Brightness = 1.5
	light.Parent = orb

	local a0 = Instance.new("Attachment")
	a0.Position = Vector3.new(0, ORB_SIZE / 2, 0)
	a0.Parent = orb

	local a1 = Instance.new("Attachment")
	a1.Position = Vector3.new(0, -ORB_SIZE / 2, 0)
	a1.Parent = orb

	local trail = Instance.new("Trail")
	trail.Attachment0 = a0
	trail.Attachment1 = a1
	trail.Lifetime = TRAIL_TIME
	trail.LightEmission = 1
	trail.FaceCamera = true
	trail.Transparency = NumberSequence.new(0, 1)
	trail.WidthScale = NumberSequence.new(1, 0)
	trail.Parent = orb

	return { part = orb, light = light, trail = trail }
end

local function startVisual(character)
	local root = character:WaitForChild("HumanoidRootPart")

	local folder = Instance.new("Folder")
	folder.Name = "OrbitVisual"
	folder.Parent = workspace

	local orbs = {}
	for i = 1, ORB_COUNT do
		orbs[i] = createOrb(folder)
	end

	local t = 0
	local connection
	connection = RunService.RenderStepped:Connect(function(dt)
		-- Clean up if the character is gone
		if not character:IsDescendantOf(workspace) then
			connection:Disconnect()
			folder:Destroy()
			return
		end

		t += dt
		local center = root.Position

		for i, orb in ipairs(orbs) do
			local angle = t * SPEED + (i / ORB_COUNT) * math.pi * 2
			local bob = math.sin(t * 2 + i) * BOB_HEIGHT

			orb.part.Position = center + Vector3.new(
				math.cos(angle) * RADIUS,
				bob,
				math.sin(angle) * RADIUS
			)

			local color = Color3.fromHSV((t * COLOR_SPEED + i / ORB_COUNT) % 1, 0.8, 1)
			orb.part.Color = color
			orb.light.Color = color
			orb.trail.Color = ColorSequence.new(color)
		end
	end)
end

if player.Character then
	task.spawn(startVisual, player.Character)
end
player.CharacterAdded:Connect(startVisual)
