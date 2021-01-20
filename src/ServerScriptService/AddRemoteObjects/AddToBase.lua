local module = {}
local Sss = game:GetService("ServerScriptService")
local SP = game:GetService("StarterPlayer")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
local Constants = require(SP.Source.StarterPlayerScripts.RSConstants)

local PlayerStatManager = require(Sss.Source.AddRemoteObjects.PlayerStatManager)
local ConfigGame = require(Sss.Source.AddRemoteObjects.ConfigGame)
local BlockDash = require(Sss.Source.BlockDash.BlockDash)

local function addWorld(sectorConfig)
    BlockDash.addBlockDash(sectorConfig)
    -- 
end

function addRemoteObjects()
    local myStuff = workspace:FindFirstChild("MyStuff")

    local sector1Config = {
        -- words = {"VAT"},
        words = {"CAT", "HAT", "MAT", "PAT", "SAT", "BOG", "RAT", "VAT"},
        -- sectorFolder = "Sector1",
        gridSize = {numRow = 26, numCol = 26}
    }

    local sector2Config = {
        -- words = {"CAT"},
        words = {"CAT", "HAT", "MAT", "PAT", "SAT", "BOG", "ZIP"},
        -- sectorFolder = "Sector2",
        gridSize = {numRow = 26, numCol = 26}
    }

    local blockDash = Utils.getFirstDescendantByName(myStuff, "BlockDash")
    local islandPositionerFolder = Utils.getFirstDescendantByName(blockDash,
                                                                  "IslandPositioners")
    -- local islandPositioners = Utils.getDescendantsByName(blockDash,
    --                                                      "IslandPositioner")

    local islandPositioners = islandPositionerFolder:GetChildren()

    local islandTemplate = Utils.getFromTemplates("IslandTemplate")
    local sectorConfigs = {
        sector1Config, --
        sector2Config, --
        sector2Config, --
        sector2Config, --
        sector2Config, --
        sector2Config, sector2Config
    }

    local lines = {luaH_set = 10, luaH_get = 24, luaH_present = 48}

    function pairsByKeys(t, f)
        local a = {}
        for n in pairs(t) do table.insert(a, n) end
        table.sort(a, f)
        local i = 0 -- iterator variable
        local iter = function() -- iterator function
            i = i + 1
            if a[i] == nil then
                return nil
            else
                return a[i], t[a[i]]
            end
        end
        return iter
    end

    Utils.sortListByObjectKey(islandPositioners, "Name")

    for islandIndex, islandPositioner in ipairs(islandPositioners) do
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

        local offsetX = 250
        local offsetY = (islandIndex - 1) * 50
        -- local offsetX = 100 * islandIndex
        newIsland.Parent = myStuff
        newIsland.Name = "xxx"
        local newIslandPart = newIsland.PrimaryPart
        newIslandPart.Name = "newIsland-ddd"
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

        addWorld(sectorConfig)

        for _, child in pairs(anchoredParts) do
            child.Anchored = true
            -- 
        end

    end
    -- Do this last after everything has been created/deleted
    ConfigGame.configGame()
    PlayerStatManager.init()
    -- islandTemplate:Destroy()
end

module.addRemoteObjects = addRemoteObjects
return module

