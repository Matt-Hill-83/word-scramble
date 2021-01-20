local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)

local LetterFallUtils = require(Sss.Source.LetterFall.LetterFallUtils)
local InitLetterRack = require(Sss.Source.BlockDash.InitLetterRackBD)
local InitWord = require(Sss.Source.BlockDash.InitWordBD)
local Entrance = require(Sss.Source.BlockDash.Entrance)
local BlockDashUtils = require(Sss.Source.BlockDash.BlockDashUtils)
local HandleClick = require(Sss.Source.BlockDash.HandleClick)
local LetterGrabber = require(Sss.Source.LetterGrabber.LetterGrabber)
local DoorKey = require(Sss.Source.BlockDash.DoorKey)

local module = {}

local function initPowerUps(miniGameState)
    local sectorFolder = miniGameState.sectorFolder

    local function onTouchClearBlocks(otherPart)
        local humanoid = otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            if miniGameState.canResetBlocks then
                miniGameState.canResetBlocks = false
                BlockDashUtils.clearBlockRack(miniGameState)
                -- LetterFallUtils.unHideWordLetters(miniGameState)
            end
        end
    end

    local resets = Utils.getDescendantsByName(sectorFolder, "ClearBlocks")
    for _, reset in ipairs(resets) do
        reset.Touched:Connect(onTouchClearBlocks)
    end

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
    local words = sectorConfig.words
    local gridSize = sectorConfig.gridSize
    local sectorFolder = sectorConfig.sectorFolder

    local numRow = gridSize.numRow
    local numCol = gridSize.numCol

    local miniGameState = {
        activeWord = nil,
        sectorFolder = sectorFolder,
        activeWordIndex = 1,
        availLetters = {},
        availWords = {},
        currentLetterIndex = 1,
        foundLetters = {},
        foundWords = {},
        initCompleted = false,
        renderedWords = {},
        -- wordLetters = {},
        activeLetterPosition = {
            row = math.floor(numRow / 2),
            col = math.floor(numCol / 2)
        },
        rackLetterBlockObjs = {},
        numRow = numRow,
        numCol = numCol,
        activeStyle = "BD_normal",
        inActiveStyle = "BD_selected",
        canResetBlocks = true
    }
    miniGameState.words = words

    local myStuff = workspace:FindFirstChild("MyStuff")
    miniGameState.onSelectRackBlock = HandleClick.onSelectRackBlock
    local letterFallFolder =
        Utils.getFirstDescendantByName(myStuff, "BlockDash")
    miniGameState.letterFallFolder = letterFallFolder

    local function onWordLettersGone(miniGameState2)
        BlockDashUtils.clearBlockRack(miniGameState2)
        -- LetterFallUtils.unHideWordLetters(miniGameState2)
        InitWord.initWords(miniGameState)
        InitLetterRack.initLetterRack(miniGameState2)
    end

    miniGameState.onWordLettersGone = onWordLettersGone
    -- Do some acrobatics here because InitLetterRack needs to attach
    -- itself as an event to the blocks it creates.

    Entrance.initEntrance(miniGameState)
    InitLetterRack.initLetterRack(miniGameState)
    InitWord.initWords(miniGameState)

    LetterFallUtils.styleLetterBlocksBD({miniGameState = miniGameState})
    initPowerUps(miniGameState)
    DoorKey.init(miniGameState)
    LetterGrabber.initLetterGrabbers(miniGameState)
end

module.addBlockDash = addBlockDash
return module
