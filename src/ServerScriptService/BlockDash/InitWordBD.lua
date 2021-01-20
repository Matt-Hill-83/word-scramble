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
    local wordPositioner = Utils.getFirstDescendantByName(sectorFolder,
                                                          "WordPositioner")
    newWord.Parent = runTimeWordFolder

    local spacingFactorY = 1.1
    local spacingFactorX = 1.1
    local wordSpacingY = letterBlockTemplate.Size.Y * spacingFactorY

    wordBench.CFrame = wordPositioner.CFrame +
                           Vector3.new(0, wordSpacingY * (wordIndex - 1), 0)

    local wordNameStub = "-W" .. wordIndex
    newWord.Name = newWord.Name .. wordNameStub
    wordBench.Anchored = true

    local lettersInWord = {}
    for letterIndex = 1, #word do
        local letterNameStub = wordNameStub .. "-L" .. letterIndex
        local char = string.sub(word, letterIndex, letterIndex)

        local newLetter = letterBlockTemplate:Clone()
        newLetter.Name = "wordLetter-" .. letterNameStub

        local offsetX = -newLetter.Size.X * (letterIndex - 1) * spacingFactorX

        CS:AddTag(newLetter, LetterFallUtils.tagNames.WordLetter)

        LetterFallUtils.initLetterBlock({
            letterBlock = newLetter,
            char = char,
            templateName = "BD_word_normal"
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

        local weld = Instance.new("WeldConstraint")
        weld.Name = "WeldConstraint" .. letterNameStub
        weld.Parent = wordBench.Parent
        weld.Part0 = wordBench
        weld.Part1 = newLetter

        -- Do this last to avoid tweening
        newLetter.Parent = newWord

        table.insert(lettersInWord,
                     {char = char, found = false, instance = newLetter})
    end

    local wordBenchPosX = wordBench.Position.X

    wordBench.CanCollide = false
    wordBench.Position = Vector3.new(wordBenchPosX, wordBench.Position.Y,
                                     wordBench.Position.Z)

    local newWordObj = {
        word = newWord,
        letters = lettersInWord,
        wordChars = word
    }

    return newWordObj
end

local function renderColumn(miniGameState)
    for wordIndex, word in ipairs(miniGameState.words) do
        local wordProps = {
            miniGameState = miniGameState,
            wordIndex = wordIndex,
            word = word
        }

        local newWordObj = initWord(wordProps)
        table.insert(miniGameState.renderedWords, newWordObj)
    end
end

local function initWords(miniGameState)
    BlockDashUtils.clearWordRack(miniGameState)
    renderColumn(miniGameState)
end

module.initWords = initWords
module.initWord = initWord

return module
