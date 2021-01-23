local CS = game:GetService("CollectionService")
local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
-- local Constants = require(Sss.Source.Constants.Constants)

local LetterFallUtils = require(Sss.Source.LetterFall.LetterFallUtils)
-- local BlockDashUtils = require(Sss.Source.BlockDash.BlockDashUtils)

local module = {}

local function createBlockMatrix(miniGameState)
    -- 
end

local function configBlocks(miniGameState)
    -- 
end

local function initLetterRack(miniGameState)

    -- local blockMatrix = createBlockMatrix(miniGameState)

    local rackLetterBlockObjs = miniGameState.rackLetterBlockObjs
    local sectorFolder = miniGameState.sectorFolder
    local numRow = miniGameState.numRow
    local numCol = miniGameState.numCol
    local words = miniGameState.words

    -- BlockDashUtils.clearBlockRack(miniGameState)

    local runTimeLetterFolder = LetterFallUtils.getRunTimeLetterFolder(
                                    miniGameState)
    miniGameState.runTimeLetterFolder = runTimeLetterFolder

    local letterBlockFolder = Utils.getFromTemplates("LetterBlockTemplates")
    local letterBlockTemplate = Utils.getFirstDescendantByName(
                                    letterBlockFolder, "BD_normal")
    local letterPositioner = Utils.getFirstDescendantByName(sectorFolder,
                                                            "LetterPositioner")

    local spacingFactorX = 1.05
    local spacingFactorZ = 1.05

    local lettersNotInWords = LetterFallUtils.getLettersNotInWords(words)
    local letterMatrix = {}

    -- populate matrix with random letters
    for _ = 1, numRow do
        local row = {}
        for _ = 1, numCol do
            table.insert(row, LetterFallUtils.getRandomLetter(lettersNotInWords))
        end
        table.insert(letterMatrix, row)
    end

    local usedLocations = {}
    for _, word in ipairs(words) do
        for letterIndex = 1, #word do
            local letter = string.sub(word, letterIndex, letterIndex)

            local isDirtyLocation = true
            local randomRowIndex = nil
            local randomColIndex = nil
            local locationCode = nil

            -- make sure you do not put 2 letters in the same location
            while isDirtyLocation == true do
                randomRowIndex = Utils.genRandom(1, numRow)
                randomColIndex = Utils.genRandom(1, numCol)
                locationCode = randomRowIndex .. "-" .. randomColIndex
                isDirtyLocation = usedLocations[locationCode]

                if isDirtyLocation then print("dirty") end
            end
            usedLocations[locationCode] = true
            letterMatrix[randomRowIndex][randomColIndex] = letter
        end
    end

    for colIndex = 1, numCol do
        for rowIndex = 1, numRow do
            local newLetterBlock = letterBlockTemplate:Clone()
            newLetterBlock.Size = letterPositioner.Size

            local letterId = "ID--R" .. rowIndex .. "C" .. colIndex
            local char = letterMatrix[rowIndex][colIndex]

            local name = "rackLetter-" .. char .. "-" .. letterId .. "sss"
            newLetterBlock.Name = name

            LetterFallUtils.createPropOnLetterBlock(
                {
                    letterBlock = newLetterBlock,
                    propName = LetterFallUtils.letterBlockPropNames.IsLifted,
                    initialValue = false,
                    propType = "BoolValue"
                })

            -- TODO: replace this:
            -- TODO: replace this:
            -- TODO: replace this:
            -- TODO: replace this:
            -- CS:AddTag(newLetterBlock, LetterFallUtils.tagNames.RackLetter)

            local letterPosX = -newLetterBlock.Size.X * (colIndex - 1) *
                                   spacingFactorX
            local letterPosZ = -newLetterBlock.Size.Z * (rowIndex - 1) *
                                   spacingFactorZ

            newLetterBlock.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                                        {
                    parent = letterPositioner,
                    child = newLetterBlock,
                    offsetConfig = {
                        useParentNearEdge = Vector3.new(-1, -1, -1),
                        useChildNearEdge = Vector3.new(-1, -1, -1),
                        offsetAdder = Vector3.new(letterPosX, 0, letterPosZ)
                    }
                })

            newLetterBlock.Parent = runTimeLetterFolder
            newLetterBlock.Anchored = true

            LetterFallUtils.initLetterBlock(
                {
                    letterBlock = newLetterBlock,
                    char = char,
                    templateName = miniGameState.activeStyle,
                    letterBlockType = "RackLetter"
                })

            local function onTouchBlock(newLetterBlock, miniGameState)
                local db = {value = false}
                local function closure(otherPart)
                    local humanoid = otherPart.Parent:FindFirstChildWhichIsA(
                                         "Humanoid")
                    if not humanoid then return end

                    if not db.value then
                        db.value = true
                        local player = Utils.getPlayerFromHumanoid(humanoid)
                        miniGameState.onSelectRackBlock(newLetterBlock,
                                                        miniGameState, player)
                        db.value = false
                    end
                end
                return closure
            end

            newLetterBlock.Touched:Connect(
                onTouchBlock(newLetterBlock, miniGameState))

            table.insert(rackLetterBlockObjs, {
                part = newLetterBlock,
                char = char,
                coords = {row = rowIndex, col = colIndex}
            })

        end
    end

    LetterFallUtils.styleLetterBlocksBD({miniGameState = miniGameState})

end

module.initLetterRack = initLetterRack

return module
