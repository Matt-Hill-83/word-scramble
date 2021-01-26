local module = {}
local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
local Constants = require(Sss.Source.Constants.Constants)

local PlayerStatManager = require(Sss.Source.AddRemoteObjects.PlayerStatManager)
local ConfigGame = require(Sss.Source.AddRemoteObjects.ConfigGame)
local BlockDash = require(Sss.Source.BlockDash.BlockDash)
local Entrance = require(Sss.Source.BlockDash.Entrance)

local function addRemoteObjects()
    local myStuff = workspace:FindFirstChild("MyStuff")

    local sector6Config = {
        -- words = {
        --     "CAT" --
        -- }
        words = {
            "CAT", --
            "HAT", --
            "MAT", --
            "PAT" --
        }
    }

    local sector1Config = {

        words = {
            "NAP", --
            "TAP", --
            "RAP", --
            "ZAP" --
        },
        gridSize = {numRow = 15, numCol = 25}
    }

    -- if Constants.gameConfig.isDev then
    --     sector1Config = {
    --         words = {
    --             "CAT" --
    --         },
    --         gridSize = {numRow = 14, numCol = 24}
    --     }
    -- end

    local sector2Config = {
        words = {
            "CAP", --
            "GAP", --
            "LAP", --
            "MAP" --
        }
    }

    local sector3Config = {
        words = {
            "VAN", --
            "RAN", --
            "CAN", --
            "AN" --
        }
    }

    local sector4Config = {
        words = {
            "PAN", --
            "DAN", --
            "FAN", --
            "TAN", --
            "JAN" --
        }
    }
    local sector5Config = {
        words = {
            "SAT", --
            "RAT", --
            "VAT", --
            "AT" --

        }
    }

    local blockDash = Utils.getFirstDescendantByName(myStuff, "BlockDash")
    local mainSpawn = Utils.getFirstDescendantByName(myStuff, "MainSpawn")
    Entrance.initEntrance(mainSpawn)

    local islandPositionerFolder = Utils.getFirstDescendantByName(blockDash,
                                                                  "IslandPositioners")

    local islandPositioners = islandPositionerFolder:GetChildren()

    local islandTemplate = Utils.getFromTemplates("IslandTemplate")
    local sectorConfigs = {
        sector1Config, --
        sector2Config, --
        sector3Config, --
        sector4Config, --
        sector5Config, --
        sector6Config --
    }

    Utils.sortListByObjectKey(islandPositioners, "Name")
    print('Constants.gameConfig.singleIsland' .. ' - start');
    print(Constants.gameConfig.singleIsland);

    local myPositioners = Constants.gameConfig.singleIsland and
                              {islandPositioners[1]} or islandPositioners

    for islandIndex, islandPositioner in ipairs(myPositioners) do

        if islandIndex == 4 then break end
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

        local offsetX = 100
        local offsetY = (islandIndex) * 50

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

        BlockDash.addBlockDash(sectorConfig)

    end

    -- Do this last after everything has been created/deleted
    ConfigGame.configGame()
    PlayerStatManager.init()

    islandTemplate:Destroy()
end

module.addRemoteObjects = addRemoteObjects
return module

