local CS = game:GetService("CollectionService")
local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)

local LetterFallUtils = require(Sss.Source.LetterFall.LetterFallUtils)
local BlockDashUtils = require(Sss.Source.BlockDash.BlockDashUtils)

local module = {}

local function initLetterRack(miniGameState)
    local rackLetterBlockObjs = miniGameState.rackLetterBlockObjs
    local sectorFolder = miniGameState.sectorFolder
    local numRow = miniGameState.numRow
    local numCol = miniGameState.numCol
    local words = miniGameState.words

    BlockDashUtils.clearBlockRack(miniGameState)

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
    for _ = 1, numRow do
        local row = {}
        for _ = 1, numCol do
            table.insert(row, LetterFallUtils.getRandomLetter(lettersNotInWords))
        end
        table.insert(letterMatrix, row)
    end

    for _, word in ipairs(words) do
        for letterIndex = 1, #word do
            local letter = string.sub(word, letterIndex, letterIndex)
            local randomRowIndex = Utils.genRandom(1, numRow)
            local randomColIndex = Utils.genRandom(1, numCol)
            letterMatrix[randomRowIndex][randomColIndex] = letter
        end
    end

    for colIndex = 1, numCol do
        for rowIndex = 1, numRow do
            local newLetter = letterBlockTemplate:Clone()
            newLetter.Size = letterPositioner.Size

            local letterId = "ID--R" .. rowIndex .. "C" .. colIndex
            local char = letterMatrix[rowIndex][colIndex]

            local name = "rackLetter-" .. char .. "-" .. letterId .. "sss"
            newLetter.Name = name

            CS:AddTag(newLetter, LetterFallUtils.tagNames.RackLetter)
            CS:AddTag(newLetter, LetterFallUtils.tagNames.NotDeadLetter)

            local letterPosX = -newLetter.Size.X * (colIndex - 1) *
                                   spacingFactorX
            local letterPosZ = -newLetter.Size.Z * (rowIndex - 1) *
                                   spacingFactorZ

            newLetter.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                                   {
                    parent = letterPositioner,
                    child = newLetter,
                    offsetConfig = {
                        useParentNearEdge = Vector3.new(-1, -1, -1),
                        useChildNearEdge = Vector3.new(-1, -1, -1),
                        offsetAdder = Vector3.new(letterPosX, 0, letterPosZ)
                    }
                })

            newLetter.Parent = runTimeLetterFolder
            newLetter.Anchored = true

            LetterFallUtils.initLetterBlock(
                {
                    letterBlock = newLetter,
                    char = char,
                    templateName = miniGameState.activeStyle
                })

            local function onTouchBlock(newLetter, miniGameState)
                local db = {value = false}
                local function closure(otherPart)
                    local humanoid = otherPart.Parent:FindFirstChildWhichIsA(
                                         "Humanoid")
                    if not humanoid then return end

                    if not db.value then
                        db.value = true
                        local player = Utils.getPlayerFromHumanoid(humanoid)
                        miniGameState.onSelectRackBlock(newLetter,
                                                        miniGameState, player)
                        db.value = false
                    end
                end
                return closure
            end

            newLetter.Touched:Connect(onTouchBlock(newLetter, miniGameState))

            table.insert(rackLetterBlockObjs, {
                part = newLetter,
                char = char,
                coords = {row = rowIndex, col = colIndex}
            })

        end
    end

    LetterFallUtils.styleLetterBlocksBD({miniGameState = miniGameState})

end

module.initLetterRack = initLetterRack

return module
