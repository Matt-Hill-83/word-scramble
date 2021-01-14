local Sss = game:GetService("ServerScriptService")
local CS = game:GetService("CollectionService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Constants = require(Sss.Source.Constants.Constants)

local module = {}
function configPlayers()
    local Players = game:GetService("Players")
    Players.RespawnTime = 0

    local function onCharacterAdded(character)
        character:WaitForChild("Humanoid").WalkSpeed =
            Constants.gameConfig.walkSpeed
    end

    local function onPlayerAdded(player)
        player.CharacterAdded:Connect(onCharacterAdded)
    end

    Players.PlayerAdded:Connect(onPlayerAdded)
end

function setVisibility()
    local taggedPartsDestroy = CS:GetTagged("Destroy")
    for i, item in ipairs(taggedPartsDestroy) do item:Destroy() end

    local taggedPartsDestroy = CS:GetTagged("Disable")
    for i, item in ipairs(taggedPartsDestroy) do item.Enabled = false end

    local taggedPartsTransparent = CS:GetTagged("ArrowParts")
    for i, item in ipairs(taggedPartsTransparent) do item.Transparency = 0.6 end

    if Constants.gameConfig.transparency then
        local taggedPartsTransparent = CS:GetTagged("Transparent")
        for i, item in ipairs(taggedPartsTransparent) do
            item.Transparency = 1
        end
    end

    local canCollideOff = CS:GetTagged("CanCollideOff")
    for i, item in ipairs(canCollideOff) do item.CanCollide = false end

    local tagBaseWallTransparent = CS:GetTagged("BaseWallTransparent")
    for i, wall in ipairs(tagBaseWallTransparent) do
        Utils.setItemHeight({item = wall, height = 20})
        local newWallHeight = 2
        wall.Transparency = 1
        wall.CanCollide = true
        wall.Anchored = true
        wall.Color = Constants.colors.blue

        local newWall = wall:Clone()

        newWall.Parent = wall.Parent
        newWall.Size = newWall.Size +
                           Vector3.new(0, newWallHeight - newWall.Size.Y, 0)
        newWall.Position = newWall.Position +
                               Vector3.new(0,
                                           -(wall.Size.Y - newWall.Size.Y) / 2,
                                           0)
        newWall.Transparency = 0.7
        CS:RemoveTag(newWall, "BaseWallTransparent")
    end

    local hexTag = "HexWallTransparent"
    local taggedWalls = CS:GetTagged(hexTag)
    for i, wall in ipairs(taggedWalls) do
        Utils.setItemHeight({item = wall, height = 2})
        local newWallHeight = 4
        wall.Transparency = 0
    end

    for i, wall in ipairs(CS:GetTagged("BDExitWall")) do
        Utils.setItemHeight({item = wall, height = 8})
        wall.Transparency = 0.9
    end

    local skyBoxWalls = CS:GetTagged("SkyBoxWalls")
    Utils.setWallHeightByList({items = skyBoxWalls, height = 30})
    Utils.setPropsByTag({tag = "SkyBoxWalls", props = {Transparency = 0.9}})

end

function module.configGame()
    setVisibility()
    configPlayers()

    local spawns = Constants.gameConfig.disabledSpawns
    for _, spawn in ipairs(spawns) do
        local spawnPart = Utils.getFirstDescendantByName(workspace, spawn)
        spawnPart.Enabled = false
    end

end

return module
