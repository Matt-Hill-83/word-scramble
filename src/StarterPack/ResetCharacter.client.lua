print("Reset Character------------------------------------------->>>>")
local Players = game:GetService("Players")
local SP = game:GetService("StarterPlayer")
local Constants = require(SP.Source.StarterPlayerScripts.RSConstants)

local player = Players.LocalPlayer
local character = player.CharacterAdded:wait()
local humanoid = character:WaitForChild("Humanoid")

print("Reset Camera----------------------------------->")
-- Reset camera
local camera = workspace.CurrentCamera
camera.CameraType = Enum.CameraType.Custom
camera.CameraSubject = humanoid

-- TODO: this line throws an error, Head is not a valid member of model "Workspace.KletusVanDamme"
camera.CFrame = character.Head.CFrame

humanoid.JumpPower = 50
humanoid.WalkSpeed = Constants.gameConfig.walkSpeed

-- You need to set the min first, since the max can't be set to 
-- lower than the existing min
player.CameraMinZoomDistance = 0.5
-- Then set the desired zoom to force this to be the current zoom
player.CameraMaxZoomDistance = 10
-- Then set the max zoom
player.CameraMaxZoomDistance = 400

