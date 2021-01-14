local module = {}
local Sss = game:GetService("ServerScriptService")
local SceneConfig = require(Sss.Source.QuestConfigs.ScenesConfig)

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
local Constants = require(Sss.Source.Constants.Constants)

local Scenes = require(Sss.Source.Scenes.Scenes)
local QuestBlock = require(Sss.Source.AddRemoteObjects.QuestBlock)
local ConfigGame = require(Sss.Source.AddRemoteObjects.ConfigGame)
local Teleporters = require(Sss.Source.Teleporters.Teleporters)
local MiniGame = require(Sss.Source.MiniGame.MiniGame)
local BlockDash = require(Sss.Source.BlockDash.BlockDash)

function deleteTemplates()
    local questBlockTemplate = Utils.getFromTemplates("QuestBox")
    questBlockTemplate:Destroy()
    local letterFallTemplate = Utils.getFromTemplates("LetterFallTemplate")
    letterFallTemplate:Destroy()
    -- local teleporterTemplate = Utils.getFromTemplates("TeleporterTemplate")
    -- teleporterTemplate:Destroy()
    local hexStandTemplate = Utils.getFromTemplates("HexStandTemplate")
    hexStandTemplate:Destroy()
end

function addRemoteObjects()
    local questConfigs = SceneConfig.getScenesConfig()

    local myStuff = workspace:FindFirstChild("MyStuff")
    local worlds = {1}

    for worldIndex, questConfig in ipairs(worlds) do
        -- 
        addWorld(worldProps)
    end

    deleteTemplates()
    -- Do this last after everything has been created/deleted
    ConfigGame.configGame()
end

function cloneHexStand(worldIndex)
    local myStuff = workspace:FindFirstChild("MyStuff")
    local hexStandTemplate = Utils.getFromTemplates("HexStandTemplate")
    local hexStandPositioners = Utils.getDescendantsByName(myStuff,
                                                           "HexStandPositioner")
    -- local runtimeQuestsFolder = Utils.getOrCreateFolder(
    --                                 {name = "RunTimeQuests", parent = myStuff})

    local hexStandPositioner = hexStandPositioners[worldIndex]

    local hexStand = hexStandTemplate:Clone()
    hexStand.Parent = myStuff

    hexStand.Name = hexStand.Name .. "-Clone-W" .. worldIndex
    local hexMountPart = hexStand.PrimaryPart

    local translateCFrameProps = {
        parent = hexStandPositioner,
        child = hexMountPart,
        offsetConfig = {
            useParentNearEdge = Vector3.new(0, -1, 0),
            useChildNearEdge = Vector3.new(0, -1, 0)
        }
    }

    hexMountPart.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                              translateCFrameProps)
    hexMountPart.Anchored = true

    hexStandPositioner:Destroy()
    return hexStand
end

function addHexTeleporter(hexStand, worldIndex)
    local hexTeleporter = Teleporters.configTeleporter(
                              {
            worldIndex = worldIndex,
            label = "Island " .. worldIndex,
            parentFolder = hexStand,
            positionerName = "HexTeleporterPositioner"
        })
    return hexTeleporter
end

function addHexReturnTeleporter(hexStand, worldIndex)
    local hexTeleporter = Teleporters.configTeleporter(
                              {
            worldIndex = worldIndex,
            label = "Cloud Ship",
            parentFolder = hexStand,
            positionerName = "HexReturnTPPositioner"
        })
    return hexTeleporter
end

function addSkyBoxTeleporter(worldIndex)
    local myStuff = workspace:FindFirstChild("MyStuff")
    local tPOffsetX = 10
    local teleporter = Teleporters.configTeleporter(
                           {
            worldIndex = worldIndex,
            label = "Island " .. worldIndex,
            parentFolder = myStuff,
            positionerName = "SkyBoxTeleporterPositioner",
            positionOffset = Vector3.new(worldIndex * tPOffsetX, 0, 0)
        })

    return teleporter
end

function addWorld(props)

    local blockDashProps = {}
    BlockDash.addBlockDash(blockDashProps)
end

module.addRemoteObjects = addRemoteObjects
return module

