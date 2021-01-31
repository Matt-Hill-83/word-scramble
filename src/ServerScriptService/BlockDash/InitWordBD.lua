local CS = game:GetService("CollectionService")
local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)

local LetterFallUtils = require(Sss.Source.LetterFall.LetterFallUtils)
local BlockDashUtils = require(Sss.Source.BlockDash.BlockDashUtils)

local module = {}
local function getRunTimeWordFolder(miniGameState)
    local sectorFolder = miniGameState.sectorFolder
    local runtimeFolder = Utils.getOrCreateFolder(
                              {name = "RunTimeFolder", parent = sectorFolder})

    return (Utils.getOrCreateFolder({
        name = "RunTimeWordFolder",
        parent = runtimeFolder
    }))
end

local function initWord(props)
    local miniGameState = props.miniGameState
    local wordIndex = props.wordIndex
    local word = props.word
    local colIndex = props.colIndex

    local sectorFolder = miniGameState.sectorFolder

    local runTimeWordFolder = getRunTimeWordFolder(miniGameState)
    miniGameState.runTimeWordFolder = runTimeWordFolder

    local wordBox = Utils.getFromTemplates("WordBoxTemplate")
    local letterBlockFolder = Utils.getFromTemplates("LetterBlockTemplates")

    local letterBlockTemplate = Utils.getFirstDescendantByName(
                                    letterBlockFolder, "BD_word_normal")

    local newWord = wordBox:Clone()
    local wordBench = Utils.getFirstDescendantByName(newWord, "WordBench")
    local letterPositioner = Utils.getFirstDescendantByName(newWord,
                                                            "WordLetterBlockPositioner")

    -- if not letterPositioner then return end

    local wordPositioner = Utils.getFirstDescendantByName(sectorFolder,
                                                          "WordPositioner")
    newWord.Parent = runTimeWordFolder

    local spacingFactorY = 1.1
    local spacingFactorX = 0.8
    local offsetY = miniGameState.wordLetterSize * spacingFactorY

    local totalLetterWidth = miniGameState.wordLetterSize * spacingFactorX
    local maxWordLength = 3
    local wordOffset = miniGameState.wordLetterSize * 1.1

    local colOffsetX = (colIndex - 1) *
                           (totalLetterWidth * maxWordLength + wordOffset)

    wordBench.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                           {
            parent = wordPositioner,
            child = wordBench,
            offsetConfig = {
                useParentNearEdge = Vector3.new(1, 1, 1),
                useChildNearEdge = Vector3.new(1, 1, 1),
                offsetAdder = Vector3.new(0, offsetY * (wordIndex - 1),
                                          colOffsetX)
            }
        })

    local wordNameStub = "-W" .. wordIndex
    newWord.Name = newWord.Name .. wordNameStub
    wordBench.Anchored = true

    local lettersInWord = {}
    for letterIndex = 1, #word do
        local letterNameStub = wordNameStub .. "-L" .. letterIndex
        local char = string.sub(word, letterIndex, letterIndex)

        local newLetter = letterBlockTemplate:Clone()
        newLetter.Name = "wordLetter-" .. letterNameStub
        newLetter.Size = Vector3.new(miniGameState.wordLetterSize,
                                     miniGameState.wordLetterSize,
                                     miniGameState.wordLetterSize)

        local offsetX =
            -(newLetter.Size.X * (letterIndex - 1) * spacingFactorX) - 0

        CS:AddTag(newLetter, LetterFallUtils.tagNames.WordLetter)

        LetterFallUtils.initLetterBlock({
            letterBlock = newLetter,
            char = char,
            templateName = "BD_word_normal",
            letterBlockType = "WordRackLetter"
        })

        newLetter.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                               {
                parent = letterPositioner,
                child = newLetter,
                offsetConfig = {
                    useParentNearEdge = Vector3.new(1, 1, 1),
                    useChildNearEdge = Vector3.new(1, 1, 1),
                    offsetAdder = Vector3.new(offsetX, 0, 0)
                }
            })

        -- Do this last to avoid tweening
        newLetter.Parent = newWord

        table.insert(lettersInWord,
                     {char = char, found = false, instance = newLetter})
    end

    wordBench.CanCollide = false

    local newWordObj = {
        uuid = Utils.getUuid(),
        word = newWord,
        letters = lettersInWord,
        wordChars = word,
        completed = false
    }

    return newWordObj
end

local function renderColumn(miniGameState, colIndex, words)
    for wordIndex, word in ipairs(words) do
        local wordProps = {
            miniGameState = miniGameState,
            wordIndex = wordIndex,
            word = word,
            colIndex = colIndex
        }

        local newWordObj = initWord(wordProps)
        table.insert(miniGameState.renderedWords, newWordObj)
    end
end

local function initWords(miniGameState)
    BlockDashUtils.clearWordRack(miniGameState)
    local wordsPerCol = miniGameState.wordsPerCol
    local numCol = math.ceil(#miniGameState.words / wordsPerCol)

    for colIndex = 1, numCol do
        local startIndex = ((colIndex - 1) * wordsPerCol) + 1
        local endIndex = startIndex + wordsPerCol - 1
        local words = {table.unpack(miniGameState.words, startIndex, endIndex)}
        renderColumn(miniGameState, colIndex, words)
    end
end

module.initWords = initWords
module.initWord = initWord

return module
