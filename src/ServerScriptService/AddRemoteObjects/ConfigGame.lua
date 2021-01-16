local Sss = game:GetService("ServerScriptService")
local CS = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Constants = require(Sss.Source.Constants.Constants)

local module = {}
function configPlayers()
    local Players = game:GetService("Players")
    Players.RespawnTime = 0

    local function onCharacterAdded(character)
        print('onCharacterAdded--------------------');
        character:WaitForChild("Humanoid").WalkSpeed =
            Constants.gameConfig.walkSpeed
        print(character.Humanoid);
        local player = Players:GetPlayerFromCharacter(character)
        print(player);
    end

    local function onPlayerAdded(player)
        print('onPlayerAdded');
        print(player.UserId);
        player.CharacterAdded:Connect(onCharacterAdded)
    end

    Players.PlayerAdded:Connect(onPlayerAdded)
end

function configGamePass()

    local gamePassID = 14078170

    local function onPlayerAdded(player)

        local hasPass = false

        -- Check if the player already owns the game pass
        local success, message = pcall(function()
            hasPass = MarketplaceService:UserOwnsGamePassAsync(player.UserId,
                                                               gamePassID)
        end)

        -- If there's an error, issue a warning and exit the function
        if not success then
            warn("Error while checking if player has pass: " ..
                     tostring(message))
            return
        end

        if hasPass == true then
            print(player.Name .. " owns the game pass with ID " .. gamePassID)
            -- Assign this player the ability or bonus related to the game pass
            --
        end
    end

    Players.PlayerAdded:Connect(onPlayerAdded)
end

function configBadges()
    game:GetService('Players').PlayerAdded:Connect(
        function(player)
            player.CharacterAdded:Connect(
                function(character)
                    character:WaitForChild("Humanoid").Died:Connect(
                        function()
                            print(player.Name .. " has died!")
                        end)
                end)
        end)
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
    Utils.setWallHeightByList({items = skyBoxWalls, height = 50})
    Utils.setPropsByTag({tag = "SkyBoxWalls", props = {Transparency = 0.9}})

end

function module.configGame()
    setVisibility()
    configPlayers()
    configGamePass()
    configBadges()

    local spawns = Constants.gameConfig.disabledSpawns
    for _, spawn in ipairs(spawns) do
        local spawnPart = Utils.getFirstDescendantByName(workspace, spawn)
        spawnPart.Enabled = false
    end

end

return module
