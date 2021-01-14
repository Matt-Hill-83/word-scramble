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

    -- local myStuff = workspace:FindFirstChild("MyStuff")
    local worlds = {questConfigs}
    -- local worlds = questConfigs
    -- local worlds = {questConfigs, questConfigs}
    -- local worlds = {questConfigs, questConfigs, questConfigs}

    for worldIndex, questConfig in ipairs(worlds) do
        local worldProps = {
            questConfigs = questConfigs,
            worldIndex = worldIndex
        }

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

function sliceQuestConfigs(questConfigs)
    if (Constants.gameConfig.singleScene) then
        -- slice out a single quest
        questConfigs = {questConfigs[1]}
        local sceneConfigs = questConfigs[1].sceneConfigs
        questConfigs[1].sceneConfigs = {sceneConfigs[1]}
    else
        -- slice out the first 6 quests, for the hexagon
        questConfigs = {unpack(questConfigs, 1, 6)}
    end
    return questConfigs
end

function getWords(questConfig)
    local words = questConfig.words

    -- add comma to last word
    local newWords = {}
    if words then
        words = words .. ','
        for w in words:gmatch("(.-),") do table.insert(newWords, w) end
    end

    local defaultWords = {'CAT', 'HAT', 'MAT', 'PAT', 'RAT', 'SAT', "CHAT"}
    local output = defaultWords

    if #newWords > 0 then output = newWords end
    return output
end

function cloneQuestBlock(worldIndex, questIndex)
    local myStuff = workspace:FindFirstChild("MyStuff")
    local runtimeQuestsFolder = Utils.getOrCreateFolder(
                                    {name = "RunTimeQuests", parent = myStuff})

    return Utils.cloneModel({
        model = Utils.getFromTemplates("QuestBox"),
        suffix = "Clone-W" .. worldIndex .. "-Q" .. questIndex
    })
end

function getGridPadding()
    local desiredPadding = 12
    local wallWidth = 1
    return desiredPadding + wallWidth * 2
end

function renderQuestBlock(props)
    local dockMountPlate = props.dockMountPlate
    local worldIndex = props.worldIndex
    local questIndex = props.questIndex
    local gridSize = props.gridSize
    local questFolder = props.questFolder

    local questBlockClone = cloneQuestBlock(worldIndex, questIndex)

    local questBlockProps = {
        parent = dockMountPlate,
        questBlockTemplate = questBlockClone,
        worldIndex = worldIndex,
        questIndex = questIndex,
        gridSize = gridSize,
        gridPadding = getGridPadding()
    }
    local questBlockModel = QuestBlock.renderQuestBlock(questBlockProps)
    dockMountPlate:Destroy()
    return questBlockModel
end

function addScenes(props)
    local questBlockModel = props.questBlockModel
    local hexTeleporter = props.hexTeleporter
    local questIndex = props.questIndex
    local questConfig = props.questConfig
    local questFolder = props.questFolder

    local dockBase = Utils.getFirstDescendantByName(questBlockModel, "DockBase")
    local sceneMountPlate = Utils.getFirstDescendantByName(questBlockModel,
                                                           "SceneMountPlate")
    Utils.enableChildWelds({part = sceneMountPlate, enabled = false})

    local translateCFrameProps = {
        parent = dockBase,
        child = sceneMountPlate,
        offsetConfig = {
            useParentNearEdge = Vector3.new(-1, 1, -1),
            useChildNearEdge = Vector3.new(-1, -1, -1)
        }
    }

    -- Relocate the scene mountplate, after the dock has been resized.
    local sceneMountPlateCFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                                      translateCFrameProps)

    sceneMountPlate.CFrame = sceneMountPlateCFrame
    local rotatedCFrame = CFrame.Angles(0, math.rad(180), 0)
    sceneMountPlate.CFrame = sceneMountPlate.CFrame:ToWorldSpace(rotatedCFrame)

    local gridPadding = getGridPadding()
    local addScenesProps = {
        gridPadding = gridPadding,
        hexTeleporter = hexTeleporter,
        parent = sceneMountPlate,
        questConfig = questConfig,
        questFolder = questFolder,
        questIndex = questIndex,
        sceneConfigs = questConfig.sceneConfigs
    }
    Scenes.addScenes(addScenesProps)
    sceneMountPlate:Destroy()

end

function addWorld(props)
    local questConfigs = props.questConfigs
    local worldIndex = props.worldIndex

    local myStuff = workspace:FindFirstChild("MyStuff")
    local runtimeQuestsFolder = Utils.getOrCreateFolder(
                                    {name = "RunTimeQuests", parent = myStuff})

    questConfigs = sliceQuestConfigs(questConfigs)
    local hexStand = cloneHexStand(worldIndex)
    local mountPlates = Utils.getDescendantsByName(hexStand, "MountPlate")

    local hexTeleporter = addHexTeleporter(hexStand, worldIndex)
    local hexReturnTeleporter = addHexReturnTeleporter(hexStand, worldIndex)
    local skyTeleporter = addSkyBoxTeleporter(worldIndex)
    Teleporters.setLocalTPTargetToRemoteTP(skyTeleporter, hexTeleporter)
    Teleporters.setLocalTPTargetToRemoteTP(hexReturnTeleporter, skyTeleporter)

    -- add quests
    for questIndex, questConfig in ipairs(questConfigs) do
        local miniGameMountPlate = mountPlates[questIndex]
        local gridSize = questConfig.gridSize

        local questFolder = Utils.getOrCreateFolder(
                                {
                name = "QuestBloc-Clone-" .. questIndex,
                parent = runtimeQuestsFolder
            })

        local miniGame = MiniGame.addMiniGame(
                             {
                parent = miniGameMountPlate,
                words = getWords(questConfig),
                sceneIndex = 1,
                questIndex = questIndex,
                questTitle = questConfig.questTitle
            })
        miniGame.PrimaryPart.Anchored = true

        if questIndex == 1 then
            local blockDashProps = {
                words = getWords(questConfig),
                questIndex = questIndex,
                questTitle = questConfig.questTitle
            }
            BlockDash.addBlockDash(blockDashProps)
        end

        local questBlockModel = renderQuestBlock(
                                    {
                dockMountPlate = Utils.getFirstDescendantByName(miniGame,
                                                                "DockMountPlate"),
                worldIndex = worldIndex,
                questIndex = questIndex,
                gridSize = gridSize
            })
        questBlockModel.Parent = questFolder
        if Constants.gameConfig.showScenes then
            addScenes({
                gridPadding = getGridPadding(),
                hexTeleporter = hexTeleporter,
                questBlockModel = questBlockModel,
                questConfig = questConfig,
                questFolder = questFolder,
                questIndex = questIndex
            })
        end
    end
end

module.addRemoteObjects = addRemoteObjects
return module

