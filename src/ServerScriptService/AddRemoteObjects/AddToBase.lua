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
    local worlds = {1}

    for worldIndex, questConfig in ipairs(worlds) do
        -- 
        addWorld(worldProps)
    end

    -- Do this last after everything has been created/deleted
    ConfigGame.configGame()
    PlayerStatManager.init()
end

function addWorld(props)
    local blockDashProps = {}
    BlockDash.addBlockDash(blockDashProps)
end

module.addRemoteObjects = addRemoteObjects
return module

