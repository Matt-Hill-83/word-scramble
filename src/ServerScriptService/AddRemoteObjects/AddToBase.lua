local module = {}
local Sss = game:GetService("ServerScriptService")
local CS = game:GetService("CollectionService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
local Constants = require(Sss.Source.Constants.Constants)
local LevelConfigs = require(Sss.Source.LevelConfigs.LevelConfigs)

local PlayerStatManager = require(Sss.Source.AddRemoteObjects.PlayerStatManager)
local ConfigGame = require(Sss.Source.AddRemoteObjects.ConfigGame)
local BlockDash = require(Sss.Source.BlockDash.BlockDash)
local Entrance = require(Sss.Source.BlockDash.Entrance)

local function addRemoteObjects()
    local myStuff = workspace:FindFirstChild("MyStuff")

    local blockDash = Utils.getFirstDescendantByName(myStuff, "BlockDash")
    local levelsFolder = Utils.getFirstDescendantByName(myStuff, "Levels")
    local levels = levelsFolder:GetChildren()
    print('levels' .. ' - start');
    print('levels' .. ' - start');
    print('levels' .. ' - start');
    print(levels);
    Entrance.initEntrance(workspace)

    print('levels[1]' .. ' - start');
    print(levels[1]);

    Utils.sortListByObjectKey(levels, "Name")
    local islandPositioners = Utils.getByTagInParent(
                                  {parent = levels[1], tag = "IslandPositioner"})

    print('islandPositioners' .. ' - start');
    print(islandPositioners);

    -- local islandPositioners = CS:GetTagged("IslandPositioner")
    local islandTemplate = Utils.getFromTemplates("IslandTemplate")
    local sectorConfigs = LevelConfigs.levelConfigs[1]

    Utils.sortListByObjectKey(islandPositioners, "Name")

    local myPositioners = Constants.gameConfig.singleIsland and
                              {islandPositioners[1]} or islandPositioners

    for islandIndex, islandPositioner in ipairs(myPositioners) do

        -- if islandIndex == 3 then break end
        local newIsland = islandTemplate:Clone()

        local anchoredParts = {}
        for _, child in pairs(newIsland:GetDescendants()) do
            if child:IsA("BasePart") then
                if child.Anchored then
                    child.Anchored = false
                    table.insert(anchoredParts, child)
                end
            end
        end

        newIsland.Parent = myStuff
        newIsland.Name = "Sector-" .. islandPositioner.Name
        local newIslandPart = newIsland.PrimaryPart

        local sectorConfig = sectorConfigs[(islandIndex % #sectorConfigs) + 1]
        sectorConfig.sectorFolder = newIsland
        sectorConfig.islandPositioner = islandPositioner

        for _, child in pairs(anchoredParts) do
            child.Anchored = true
            -- 
        end
        BlockDash.addBlockDash(sectorConfig)
    end

    -- Do this last after everything has been created/deleted
    ConfigGame.configGame()
    PlayerStatManager.init()

    islandTemplate:Destroy()
end

module.addRemoteObjects = addRemoteObjects
return module

