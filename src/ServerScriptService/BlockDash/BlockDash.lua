local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)

local LetterFallUtils = require(Sss.Source.LetterFall.LetterFallUtils)
local InitLetterRack = require(Sss.Source.BlockDash.InitLetterRackBD)
local InitWord = require(Sss.Source.BlockDash.InitWordBD)
local Entrance = require(Sss.Source.BlockDash.Entrance)
local HandleClick = require(Sss.Source.BlockDash.HandleClick)
local LetterGrabber = require(Sss.Source.LetterGrabber.LetterGrabber)
local DoorKey = require(Sss.Source.BlockDash.DoorKey)
local Conveyor = require(Sss.Source.Conveyor.Conveyor)

local module = {}

local function initPowerUps(miniGameState)
    local sectorFolder = miniGameState.sectorFolder

    local function onTouchAddBlocks(otherPart)
        local humanoid = otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            if not miniGameState.canResetBlocks then
                miniGameState.canResetBlocks = true
                InitLetterRack.initLetterRack(miniGameState)
            end
        end
    end

    local addBlocks = Utils.getDescendantsByName(sectorFolder, "AddBlocks")
    for _, reset in ipairs(addBlocks) do
        reset.Touched:Connect(onTouchAddBlocks)
    end
end

local function addBlockDash(sectorConfig)
    -- local words = {sectorConfig.words[1]}
    local words = sectorConfig.words

    local numBelts = 6
    local defaultGridSize = {numRow = 12, numCol = 4}
    local gridSize = defaultGridSize
    -- local gridSize = sectorConfig.gridSize or defaultGridSize
    local sectorFolder = sectorConfig.sectorFolder
    local islandPositioner = sectorConfig.islandPositioner
    print('islandPositioner' .. ' - start');
    print(islandPositioner);

    local numRow = gridSize.numRow
    local numCol = gridSize.numCol
    local rackLetterSize = 8

    local miniGameState = {
        activeStyle = "BD_available",
        activeWord = nil,
        activeWordIndex = 1,
        availLetters = {},
        availWords = {},
        beltPlateCFrames = {},
        beltPlates = {},
        beltPlateSpacing = rackLetterSize / 8,
        canResetBlocks = true,
        currentLetterIndex = 1,
        foundLetters = {},
        inActiveStyle = "BD_normal", -- Rack starts with this one:
        initCompleted = false,
        islandPositioner = islandPositioner,
        letterSpacingFactor = 1.05,
        numBelts = numBelts,
        numCol = numCol,
        numRow = numRow,
        rackLetterBlockObjs = {},
        rackLetterSize = rackLetterSize,
        renderedWords = {},
        sectorFolder = sectorFolder,
        wordLetterSize = 16,
        wordsPerCol = 3
    }
    miniGameState.words = words

    local myStuff = workspace:FindFirstChild("MyStuff")
    miniGameState.onSelectRackBlock = HandleClick.onSelectRackBlock
    local letterFallFolder =
        Utils.getFirstDescendantByName(myStuff, "BlockDash")
    miniGameState.letterFallFolder = letterFallFolder

    local function onWordLettersGone(miniGameState2)
        LetterFallUtils.revertRackLetterBlocksToInit(miniGameState2)
        LetterFallUtils.styleLetterBlocksBD({miniGameState = miniGameState2})

        -- TODO: put this in DoorKey
        -- TODO: put this in DoorKey
        -- TODO: put this in DoorKey
        -- TODO: put this in DoorKey

        local keyWalls = Utils.getDescendantsByName(sectorFolder, "KeyWall")

        for _, keyWall in ipairs(keyWalls) do
            if keyWall then
                LetterFallUtils.styleImageLabelsInBlock(keyWall,
                                                        {Visible = true})
                keyWall.CanCollide = true
                keyWall.Transparency = 0.7
            end
        end
    end

    miniGameState.onWordLettersGone = onWordLettersGone
    -- Do some acrobatics here because InitLetterRack needs to attach
    -- itself as an event to the blocks it creates.

    Entrance.initEntrance(sectorFolder)
    Conveyor.initConveyors(miniGameState)
    InitLetterRack.initLetterRack(miniGameState)
    InitWord.initWords(miniGameState)

    LetterFallUtils.styleLetterBlocksBD({miniGameState = miniGameState})
    initPowerUps(miniGameState)
    DoorKey.init(miniGameState)
    LetterGrabber.initLetterGrabbers(miniGameState)
end

module.addBlockDash = addBlockDash
return module
