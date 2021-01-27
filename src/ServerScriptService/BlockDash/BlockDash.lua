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
    local words = sectorConfig.words

    local defaultGridSize = {numRow = 5, numCol = 6}
    -- local defaultGridSize = {numRow = 15, numCol = 25}
    local gridSize = sectorConfig.gridSize or defaultGridSize
    local sectorFolder = sectorConfig.sectorFolder

    local numRow = gridSize.numRow
    local numCol = gridSize.numCol

    local miniGameState = {
        activeWord = nil,
        sectorFolder = sectorFolder,
        activeWordIndex = 1,
        availLetters = {},
        wordLetterSize = 16,
        letterSpacingFactor = 1.05,
        availWords = {},
        currentLetterIndex = 1,
        foundLetters = {},
        initCompleted = false,
        renderedWords = {},
        rackLetterBlockObjs = {},
        numRow = numRow,
        numCol = numCol,
        activeStyle = "BD_available",
        -- Rack starts with this one:
        inActiveStyle = "BD_normal",
        canResetBlocks = true
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

        local keyWalls = Utils.getDescendantsByName(sectorFolder, "KeyWall")
        for _, keyWall in ipairs(keyWalls) do
            if keyWall then
                keyWall.CanCollide = true
                keyWall.Transparency = 0
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

    function test()
        local letterBlockFolder = Utils.getFromTemplates("LetterBlockTemplates")
        local letterBlockTemplate = Utils.getFirstDescendantByName(
                                        letterBlockFolder, "BD_normal")

        -- 
        -- 
        -- 

        local numFaces = 5
        local rowWidth = 20
        local diameter = 300

        local degIncrement = 360 / numFaces

        local stickTemplate = Utils.getFirstDescendantByName(sectorFolder,
                                                             "Spinner-zzz")
        local tube = Utils.getFirstDescendantByName(sectorFolder, "Tube")

        stickTemplate.Size = Vector3.new(stickTemplate.Size.X,
                                         stickTemplate.Size.Y, diameter)
        tube.Anchored = true
        for index = 1, numFaces do
            local newStick = stickTemplate:Clone()
            newStick.Parent = tube

            newStick.CFrame = newStick.CFrame *
                                  CFrame.Angles(
                                      math.rad(degIncrement * (index - 1)), 0, 0)

            local weld = Instance.new("WeldConstraint")
            weld.Name = "WeldConstraint"
            weld.Parent = tube
            weld.Part0 = tube
            weld.Part1 = newStick

            newStick.Anchored = true

            -- create row of blocks at circumference position
            for letterIndex = 1, rowWidth do
                local newLetterBlock = letterBlockTemplate:Clone()
                newLetterBlock.Size = Vector3.new(8, 8, 8)

                newLetterBlock.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                                            {
                        parent = newStick,
                        child = newLetterBlock,
                        offsetConfig = {
                            useParentNearEdge = Vector3.new(-1, 0, -1),
                            useChildNearEdge = Vector3.new(-1, 0, -1),
                            offsetAdder = Vector3.new(
                                (letterIndex - 1) * 1.1 * newLetterBlock.Size.X,
                                0, 0)
                        }
                    })

                -- newLetterBlock.Anchored = true
                newLetterBlock.Parent = newStick
            end
        end

        tube.Anchored = false
    end
    -- test()
end

module.addBlockDash = addBlockDash
return module
