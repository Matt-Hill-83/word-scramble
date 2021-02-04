local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
-- local Constants = require(Sss.Source.Constants.Constants)

local LetterUtils = require(Sss.Source.Utils.U004LetterUtils)

local module = {}

local function initStrays(props)
    local strayLetterBlockObjs = props.strayLetterBlockObjs
    local parentFolder = props.parentFolder
    local numBlocks = props.numBlocks
    local region = props.region
    local words = props.words
    local rackLetterSize = props.rackLetterSize or 6

    local letterBlockFolder = Utils.getFromTemplates("LetterBlockTemplates")
    local letterBlockTemplate = Utils.getFirstDescendantByName(
                                    letterBlockFolder, "BD_normal")

    -- populate matrix with letters
    local totalLetterMatrix = {}

    -- combine all plates into a single matrix and populate matrix with random letters
    local lettersNotInWords = LetterUtils.getLettersNotInWords(words)

    local totalRows = numBlocks
    local numCol = 1
    local numRow = totalRows

    for _ = 1, totalRows do
        local row = {}
        for _ = 1, numCol do
            table.insert(row, LetterUtils.getRandomLetter(lettersNotInWords))
        end
        table.insert(totalLetterMatrix, row)
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
                randomRowIndex = Utils.genRandom(1, totalRows)
                randomColIndex = Utils.genRandom(1, numCol)
                locationCode = randomRowIndex .. "-" .. randomColIndex
                isDirtyLocation = usedLocations[locationCode]
            end

            usedLocations[locationCode] = true
            totalLetterMatrix[randomRowIndex][randomColIndex] = letter
        end
    end

    local letterMatrix = totalLetterMatrix
    print('letterMatrix' .. ' - start');
    print(letterMatrix);

    for colIndex = 1, numCol do
        for rowIndex = 1, numRow do
            local newLetterBlock = letterBlockTemplate:Clone()
            newLetterBlock.Size = Vector3.new(rackLetterSize, rackLetterSize,
                                              rackLetterSize)

            local letterId = "ID--R" .. rowIndex .. "C" .. colIndex
            local char = letterMatrix[rowIndex][colIndex]

            local name = "strayLetter-ppp" .. char .. "-" .. letterId
            newLetterBlock.Name = name

            LetterUtils.createPropOnLetterBlock(
                {
                    letterBlock = newLetterBlock,
                    propName = LetterUtils.letterBlockPropNames.IsLifted,
                    initialValue = false,
                    propType = "BoolValue"
                })

            LetterUtils.createPropOnLetterBlock(
                {
                    letterBlock = newLetterBlock,
                    propName = LetterUtils.letterBlockPropNames.IsFound,
                    initialValue = false,
                    propType = "BoolValue"
                })

            local letterPosX = 5
            local letterPosZ = 8

            newLetterBlock.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                                        {
                    parent = region,
                    child = newLetterBlock,
                    offsetConfig = {
                        useParentNearEdge = Vector3.new(0, 0, 0),
                        useChildNearEdge = Vector3.new(0, 0, 0),
                        offsetAdder = Vector3.new(letterPosX, 0, letterPosZ)
                    }
                })

            newLetterBlock.Parent = parentFolder
            newLetterBlock.Anchored = false
            newLetterBlock.CanCollide = true

            LetterUtils.initLetterBlock({
                letterBlock = newLetterBlock,
                char = char,
                templateName = props.activeStyle,
                letterBlockType = "RackLetter"
            })

            local function onTouchBlock(newLetterBlock2)
                local db = {value = false}
                local function closure(otherPart)
                    if not otherPart.Parent then return end
                    local humanoid = otherPart.Parent:FindFirstChildWhichIsA(
                                         "Humanoid")
                    if not humanoid then return end

                    if not db.value then
                        db.value = true
                        local player = Utils.getPlayerFromHumanoid(humanoid)
                        local strayLetter = newLetterBlock2.Character.Value

                        local tool =
                            Utils.getActiveTool(player, "LetterGrabber")
                        print('tool' .. ' - start');
                        print(tool);
                        props.onTouchBlock(newLetterBlock2, player)
                        db.value = false
                    end
                end
                return closure
            end

            newLetterBlock.Touched:Connect(onTouchBlock(newLetterBlock, props))

            table.insert(strayLetterBlockObjs, {
                part = newLetterBlock,
                char = char,
                coords = {row = rowIndex, col = colIndex}
            })
        end
    end

end

module.initStrays = initStrays

return module
