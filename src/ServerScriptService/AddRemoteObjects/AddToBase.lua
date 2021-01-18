local module = {}
local Sss = game:GetService("ServerScriptService")
local SP = game:GetService("StarterPlayer")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Constants = require(SP.Source.StarterPlayerScripts.RSConstants)

local PlayerStatManager = require(Sss.Source.AddRemoteObjects.PlayerStatManager)
local ConfigGame = require(Sss.Source.AddRemoteObjects.ConfigGame)
local BlockDash = require(Sss.Source.BlockDash.BlockDash)

function addRemoteObjects()
    local myStuff = workspace:FindFirstChild("MyStuff")

    local sector1Config = {
        words = {"CAT", "HAT", "MAT", "PAT", "SAT", "BOG", "RAT"},
        sectorFolder = "Sector1",
        gridSize = {numRow = 26, numCol = 26}
    }
    local sectors = {sector1Config}

    for sectorIndex, sectorConfig in ipairs(sectors) do
        -- 
        addWorld(sectorConfig)
    end

    -- Do this last after everything has been created/deleted
    ConfigGame.configGame()
    PlayerStatManager.init()
end

function addWorld(sectorConfig)
    BlockDash.addBlockDash(sectorConfig)
    -- 
end

module.addRemoteObjects = addRemoteObjects
return module

