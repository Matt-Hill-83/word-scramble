local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
-- local Constants = require(Sss.Source.Constants.Constants)

local LetterFallUtils = require(Sss.Source.LetterFall.LetterFallUtils)

local module = {}

local function initLetterRack(miniGameState)
    local rackLetterBlockObjs = miniGameState.rackLetterBlockObjs
    local sectorFolder = miniGameState.sectorFolder
    local numRow = miniGameState.numRow
    local numCol = miniGameState.numCol
    local words = miniGameState.words
    local letterSpacingFactor = miniGameState.letterSpacingFactor
    local rackLetterSize = miniGameState.rackLetterSize
    local numBelts = miniGameState.numBelts

    local runTimeLetterFolder = LetterFallUtils.getRunTimeLetterFolder(
                                    miniGameState)
    miniGameState.runTimeLetterFolder = runTimeLetterFolder

    local letterBlockFolder = Utils.getFromTemplates("LetterBlockTemplates")
    local letterBlockTemplate = Utils.getFirstDescendantByName(
                                    letterBlockFolder,
                                    miniGameState.inActiveStyle)

    local conveyor = Utils.getFirstDescendantByName(sectorFolder, "Conveyor")
    local beltPlates = Utils.getDescendantsByName(conveyor, "NewBeltPlate")

    -- populate matrix with letters
    local totalLetterMatrix = {}
    -- combine all plates into a single matrix and populate matrix with random letters
    print('words' .. ' - start');
    print(words);

    local lettersNotInWords = LetterFallUtils.getLettersNotInWords(words)
    print('lettersNotInWords' .. ' - start');
    print(lettersNotInWords);

    for _ = 1, numRow * numBelts do
        -- local totalCol = numBelts * numCol
        local row = {}
        for _ = 1, numCol do
            -- for _ = 1, totalCol do
            table.insert(row, LetterFallUtils.getRandomLetter(lettersNotInWords))
        end
        table.insert(totalLetterMatrix, row)
    end

    print('totalLetterMatrix' .. ' - start');
    print(totalLetterMatrix);

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
            end

            usedLocations[locationCode] = true
            totalLetterMatrix[randomRowIndex][randomColIndex] = letter
        end
    end

    -- Populate each belt plate with a complete grid with all words
    for beltPlateIndex, beltPlate in ipairs(beltPlates) do
        -- if i == 2 then return end
        local beltTemplate = Utils.getFirstDescendantByName(beltPlate, "Belt")
        local letterPositioner = Utils.getFirstDescendantByName(beltPlate,
                                                                "LetterPositioner")

        local spacingFactorX = letterSpacingFactor
        local spacingFactorZ = letterSpacingFactor

        -- local lettersNotInWords = LetterFallUtils.getLettersNotInWords(words)
        -- local letterMatrix = {}
        local startIndex = ((beltPlateIndex - 1) * numRow) + 1
        local endIndex = startIndex + numRow - 1
        local letterMatrix = {
            table.unpack(totalLetterMatrix, startIndex, endIndex)
        }

        -- populate matrix with random letters
        -- for _ = 1, numRow do
        --     local row = {}
        --     for _ = 1, numCol do
        --         table.insert(row,
        --                      LetterFallUtils.getRandomLetter(lettersNotInWords))
        --     end
        --     table.insert(letterMatrix, row)
        -- end

        -- local usedLocations = {}
        -- for _, word in ipairs(words) do
        --     for letterIndex = 1, #word do
        --         local letter = string.sub(word, letterIndex, letterIndex)

        --         local isDirtyLocation = true
        --         local randomRowIndex = nil
        --         local randomColIndex = nil
        --         local locationCode = nil

        --         -- make sure you do not put 2 letters in the same location
        --         while isDirtyLocation == true do
        --             randomRowIndex = Utils.genRandom(1, numRow)
        --             randomColIndex = Utils.genRandom(1, numCol)
        --             locationCode = randomRowIndex .. "-" .. randomColIndex
        --             isDirtyLocation = usedLocations[locationCode]
        --         end

        --         usedLocations[locationCode] = true
        --         letterMatrix[randomRowIndex][randomColIndex] = letter
        --     end
        -- end

        print('letterMatrix' .. ' - start');
        print('letterMatrix' .. ' - start');
        print('letterMatrix' .. ' - start');
        print('letterMatrix' .. ' - start');
        print('letterMatrix' .. ' - start');
        print(letterMatrix);

        for colIndex = 1, numCol do
            for rowIndex = 1, numRow do
                local newLetterBlock = letterBlockTemplate:Clone()
                newLetterBlock.Size = Vector3.new(rackLetterSize,
                                                  rackLetterSize, rackLetterSize)

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

                LetterFallUtils.createPropOnLetterBlock(
                    {
                        letterBlock = newLetterBlock,
                        propName = LetterFallUtils.letterBlockPropNames.IsFound,
                        initialValue = false,
                        propType = "BoolValue"
                    })

                local letterPosX = -newLetterBlock.Size.X * (colIndex - 1) *
                                       spacingFactorX
                local letterPosZ = -newLetterBlock.Size.Z * (rowIndex - 1) *
                                       spacingFactorZ

                newLetterBlock.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                                            {
                        parent = letterPositioner,
                        child = newLetterBlock,
                        offsetConfig = {
                            useParentNearEdge = Vector3.new(1, -1, 1),
                            useChildNearEdge = Vector3.new(1, -1, 1),
                            offsetAdder = Vector3.new(letterPosX, 0, letterPosZ)
                        }
                    })

                newLetterBlock.Parent = beltTemplate
                newLetterBlock.Anchored = false

                local weld = Instance.new("WeldConstraint")
                weld.Name = "WeldConstraintRackBlock"
                weld.Parent = newLetterBlock
                weld.Part0 = beltTemplate
                weld.Part1 = newLetterBlock

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
                        local humanoid =
                            otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
                        if not humanoid then return end

                        if not db.value then
                            db.value = true
                            local player = Utils.getPlayerFromHumanoid(humanoid)
                            miniGameState.onSelectRackBlock(newLetterBlock,
                                                            miniGameState,
                                                            player)
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

        letterPositioner:Destroy()
    end
end

module.initLetterRack = initLetterRack
module.createLetterPlate = createLetterPlate

return module
