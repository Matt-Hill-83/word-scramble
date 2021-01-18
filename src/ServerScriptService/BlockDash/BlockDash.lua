local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)

local LetterFallUtils = require(Sss.Source.LetterFall.LetterFallUtils)
local InitLetterRack = require(Sss.Source.BlockDash.InitLetterRackBD)
local InitWord = require(Sss.Source.BlockDash.InitWordBD)
local Entrance = require(Sss.Source.BlockDash.Entrance)
local ArrowTool = require(Sss.Source.BlockDash.ArrowTool)
local BlockDashUtils = require(Sss.Source.BlockDash.BlockDashUtils)
local HandleClick = require(Sss.Source.BlockDash.HandleClick)
local LetterGrabber = require(Sss.Source.LetterGrabber.LetterGrabber)

local module = {}

local allLetters = {
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O',
    'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
}
local numRow = 26
local numCol = 26

-- local words = {"CAT", "HAT"}
local words = {"CAT", "HAT", "MAT", "PAT", "SAT", "BOG", "RAT"}
-- local words = {
--     "CAT", "HAT", "MAT", "PAT", "SAT", "BOG", "VAN", "RAN", "CAN", "AN", "PAN",
--     "DAN", "FAN", "BAN", "TAN"
-- }

local miniGameState = {
    activeWord = nil,
    activeWordIndex = 1,
    allLetters = allLetters,
    availLetters = {},
    availWords = {},
    currentLetterIndex = 1,
    foundLetters = {},
    foundWords = {},
    initCompleted = false,
    renderedWords = {},
    wordLetters = {},
    activeLetterPosition = {
        row = math.floor(numRow / 2),
        col = math.floor(numCol / 2)
    },
    words = words,
    rackLetterBlockObjs = {},
    numRow = numRow,
    numCol = numCol,
    activeStyle = "BD_normal",
    inActiveStyle = "BD_selected",
    canResetBlocks = true
}

local function initPowerUps(miniGameState)
    local function onTouchClearBlocks(otherPart)
        local humanoid = otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            if miniGameState.canResetBlocks then
                miniGameState.canResetBlocks = false
                BlockDashUtils.clearBlockRack(miniGameState)
                LetterFallUtils.unHideWordLetters(miniGameState)
            end
        end
    end

    local resets = Utils.getDescendantsByName(miniGameState.letterFallFolder,
                                              "ClearBlocks")
    for _, reset in ipairs(resets) do
        reset.Touched:Connect(onTouchClearBlocks)
    end

    function onTouchAddBlocks(otherPart)
        local humanoid = otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            if not miniGameState.canResetBlocks then
                miniGameState.canResetBlocks = true
                InitLetterRack.initLetterRack(miniGameState)
            end
        end
    end

    local addBlocks = Utils.getDescendantsByName(miniGameState.letterFallFolder,
                                                 "AddBlocks")
    for _, reset in ipairs(addBlocks) do
        reset.Touched:Connect(onTouchAddBlocks)
    end
end

function addBlockDash(props)
    local myStuff = workspace:FindFirstChild("MyStuff")
    miniGameState.onSelectRackBlock = HandleClick.onSelectRackBlock

    miniGameState.letterFallFolder = Utils.getFirstDescendantByName(myStuff,
                                                                    "BlockDash")

    local function onWordLettersGone(miniGameState2)
        BlockDashUtils.clearBlockRack(miniGameState2)
        LetterFallUtils.unHideWordLetters(miniGameState2)
        InitLetterRack.initLetterRack(miniGameState2)
    end

    miniGameState.onWordLettersGone = onWordLettersGone
    -- Do some acrobatics here because InitLetterRack needs to attach
    -- itself as an event to the blocks it creates.

    Entrance.initEntrance(miniGameState)
    ArrowTool.initArrowTool(miniGameState)
    InitLetterRack.initLetterRack(miniGameState)
    InitWord.initWords(miniGameState)

    LetterFallUtils.styleLetterBlocksBD({miniGameState = miniGameState})
    initPowerUps(miniGameState)
    LetterGrabber.initLetterGrabbers(miniGameState)

    -- local grabberReplicatorTemplate = Utils.getFirstDescendantByName(workspace,
    --                                                                  "GrabberReplicatorTemplate")
    -- local newReplicator = grabberReplicatorTemplate:Clone()
    -- newReplicator.Parent = grabberReplicatorTemplate.Parent
    -- newReplicator.Name = grabberReplicatorTemplate.Name .. "-clone"

    -- local replicatorPart = newReplicator.PrimaryPart

    -- replicatorPart.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
    --                             {
    --         parent = grabberReplicatorTemplate.PrimaryPart,
    --         child = replicatorPart,
    --         offsetConfig = {
    --             useParentNearEdge = Vector3.new(-1, -1, -1),
    --             useChildNearEdge = Vector3.new(-1, -1, -1),
    --             offsetAdder = Vector3.new(10, 0, 0)
    --         }
    --     })

    -- replicatorPart.Anchored = true

    -- ChestScript.init(newReplicator)
end

module.addBlockDash = addBlockDash
return module
