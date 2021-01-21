local module = {}
local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
local Constants = require(Sss.Source.Constants.Constants)

local PlayerStatManager = require(Sss.Source.AddRemoteObjects.PlayerStatManager)
local ConfigGame = require(Sss.Source.AddRemoteObjects.ConfigGame)
local BlockDash = require(Sss.Source.BlockDash.BlockDash)

local function addSector(sectorConfig)
    BlockDash.addBlockDash(sectorConfig)
    -- 
end

local function addRemoteObjects()
    local myStuff = workspace:FindFirstChild("MyStuff")

    local sector1Config = {
        -- words = {"CAT"},
        words = {
            "CAN", --
            "CAP" --
        },
        -- words = {
        --     "CAT", --
        --     "HAT", --
        --     "MAT", --
        --     "PAT", --
        --     -- 
        --     "SAT", --
        --     "RAT", --
        --     "VAT", --
        --     "AT" --
        --     -- 
        --     -- "FLAT", --
        --     -- "CHAT", --
        --     -- "SPLAT", --
        --     -- "THAT" --
        -- },
        -- gridSize = {numRow = 6, numCol = 6}
        gridSize = {numRow = 26, numCol = 26}
    }

    local sector2Config = {
        -- words = {"CAT"},
        words = {"CAT", "HAT", "MAT", "PAT", "SAT", "BOG", "ZIP"},
        gridSize = {numRow = 26, numCol = 26}
    }

    local blockDash = Utils.getFirstDescendantByName(myStuff, "BlockDash")
    local islandPositionerFolder = Utils.getFirstDescendantByName(blockDash,
                                                                  "IslandPositioners")

    local islandPositioners = islandPositionerFolder:GetChildren()

    local islandTemplate = Utils.getFromTemplates("IslandTemplate")
    local sectorConfigs = {
        sector1Config, --
        sector1Config, --
        sector1Config, --
        sector1Config, --
        sector1Config, --
        sector1Config --
    }

    Utils.sortListByObjectKey(islandPositioners, "Name")

    local myPositioners = Constants.gameConfig.singleIsland and
                              {islandPositioners[1]} or islandPositioners

    for islandIndex, islandPositioner in ipairs(myPositioners) do
        -- for islandIndex, islandPositioner in ipairs(islandPositioners) do
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

        local offsetX = 300
        local offsetY = (islandIndex - 1) * 50

        newIsland.Parent = myStuff
        newIsland.Name = "Sector-" .. islandPositioner.Name
        local newIslandPart = newIsland.PrimaryPart
        newIslandPart.Name = "newIsland"
        newIslandPart.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                                   {
                parent = islandPositioner,
                child = newIslandPart,
                offsetConfig = {
                    useParentNearEdge = Vector3.new(1, -1, 0),
                    useChildNearEdge = Vector3.new(-1, 1, 0),
                    offsetAdder = Vector3.new(offsetX, offsetY, 0)
                }
            })

        local sectorConfig = sectorConfigs[islandIndex]
        sectorConfig.sectorFolder = newIsland
        sectorConfig.islandPositioner = islandPositioner

        for _, child in pairs(anchoredParts) do
            child.Anchored = true
            -- 
        end

        addSector(sectorConfig)

    end
    -- Do this last after everything has been created/deleted
    ConfigGame.configGame()
    PlayerStatManager.init()

    islandTemplate:Destroy()
end

module.addRemoteObjects = addRemoteObjects
return module

