local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)

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
                                    letterBlockFolder, "LB_4_blank")

    -- populate matrix with letters
    local totalLetterMatrix = {}

    -- combine all plates into a single matrix and populate matrix with random letters
    local lettersNotInWords = LetterUtils.getLettersNotInWords(words)

    -- This is a 2d array bc I recycled some other code, but it it just a 1d array
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

            local offsetX = Utils.genRandom(0, region.Size.X) - region.Size.X /
                                2
            local offsetZ = Utils.genRandom(0, region.Size.Z) - region.Size.Z /
                                2
            local letterPosX = offsetX
            local letterPosZ = offsetZ

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
                templateName = "Stray_normal",
                isTextLetter = true,
                letterBlockType = "StrayLetter"
            })

            local function styleActiveBlock(letterBlock)

                -- 
            end

            local function getActiveBlock(letterBlocks)
                local activeBlock = nil
                for _, block in ipairs(letterBlocks) do
                    if block.IsFound.Value == false then
                        activeBlock = block
                        break
                    end
                end
                return activeBlock
            end

            local function getSortedBlocks(tool)
                local letterBlocks = Utils.getByTagInParent(
                                         {parent = tool, tag = "WordPopLetter"})

                Utils.sortListByObjectKey(letterBlocks, "Name")
                return letterBlocks
            end

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

                        local tool =
                            Utils.getActiveTool(player, "LetterGrabber")

                        if tool then
                            local letterBlocks = getSortedBlocks(tool)
                            local activeBlock = getActiveBlock(letterBlocks)

                            local strayLetterChar =
                                newLetterBlock2.Character.Value
                            local activeLetterChar = activeBlock.Character.Value

                            if strayLetterChar == activeLetterChar then
                                LetterUtils.applyStyleFromTemplate(
                                    {
                                        targetLetterBlock = activeBlock,
                                        templateName = "Grabber_found"
                                    })
                            end

                        end

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
