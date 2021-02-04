local CS = game:GetService("CollectionService")
local Sss = game:GetService("ServerScriptService")
local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
-- local Constants = require(Sss.Source.Constants.Constants)
-- local Const3 = require(Sss.Source.Constants.Const_03_Letters)
local Const4 = require(Sss.Source.Constants.Const_04_Characters)

local LetterFallUtils = require(Sss.Source.LetterFall.LetterFallUtils)

local module = {}

local function playWordSound(word)
    local closure = function()
        if Const4.wordConfigs[word] then
            local soundId = Const4.wordConfigs[word]['soundId']

            if (soundId) then
                local sound = Instance.new("Sound", workspace)
                sound.SoundId = "rbxassetid://" .. soundId
                sound.EmitterSize = 5
                sound.Looped = false
                if not sound.IsPlaying then sound:Play() end
            end
        end
    end
    return closure
end

local function configWord(props)
    local letterBlockTemplate = props.letterBlockTemplate
    local word = props.word
    local wordIndex = props.wordIndex
    local wordTemplate = props.wordTemplate
    local wordNameStub = props.wordNameStub
    local sentencePositioner = props.sentencePositioner

    local newWord = wordTemplate:Clone()
    Utils.applyDecalsToCharacterFromWord({part = newWord, word = word})

    newWord.Parent = wordTemplate.Parent

    -- local spacingFactorY = 1.25
    local wordSpacingX = -letterBlockTemplate.Size.X * 4

    local translateWordProps = {
        parent = sentencePositioner,
        child = newWord.PrimaryPart,
        offsetConfig = {
            useParentNearEdge = Vector3.new(1, -1, 1),
            useChildNearEdge = Vector3.new(1, -1, 1),
            offsetAdder = Vector3.new(wordSpacingX * wordIndex, 0, 0)
        }
    }

    newWord.PrimaryPart.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                                     translateWordProps)
    -- newWord.PrimaryPart.Anchored = true

    newWord.Name = newWord.Name .. "zzz" .. wordNameStub

    return newWord
end

local function initWord(props)
    local wordIndex = props.wordIndex
    local word = props.word
    local wordLetters = props.wordLetters
    local sentencePositioner = props.sentencePositioner

    local spacingFactorX = 1.0
    local myStuff = workspace:FindFirstChild("MyStuff")
    local wordWheelIsland = Utils.getFirstDescendantByName(myStuff,
                                                           "WordWheelIsland")
    local letterBlockFolder = Utils.getFromTemplates("LetterBlockTemplates")
    local letterBlockTemplate = Utils.getFirstDescendantByName(
                                    letterBlockFolder, "LBPurpleLight")
    local wordTemplate = Utils.getFirstDescendantByName(wordWheelIsland,
                                                        "WordTemplate")
    local wordNameStub = "-W" .. wordIndex

    local newWordProps = {
        wordTemplate = wordTemplate,
        word = word,
        letterBlockTemplate = letterBlockTemplate,
        wordIndex = wordIndex,
        sentencePositioner = sentencePositioner,
        wordNameStub = wordNameStub
    }

    local newWord = configWord(newWordProps)

    -- 
    local letterPositioner = Utils.getFirstDescendantByName(newWord,
                                                            "LetterPositioner")

    local lettersInWord = {}
    for letterIndex = 1, #word do
        local letterNameStub = wordNameStub .. "-L" .. letterIndex
        local letter = string.sub(word, letterIndex, letterIndex)

        local newLetter = letterBlockTemplate:Clone()

        local cd = Instance.new("ClickDetector", newLetter)
        cd.MouseClick:Connect(playWordSound(word))

        newLetter.Name = "wordLetter-" .. letterNameStub .. "xxxx"

        local letterPositionX = -newLetter.Size.X * (letterIndex - 1) *
                                    spacingFactorX

        CS:AddTag(newLetter, LetterFallUtils.tagNames.WordLetter)
        LetterFallUtils.applyLetterText({letterBlock = newLetter, char = letter})

        local translateCFrameProps = {
            parent = letterPositioner,
            child = newLetter,
            offsetConfig = {
                useParentNearEdge = Vector3.new(-1, -1, -1),
                useChildNearEdge = Vector3.new(-1, -1, -1),
                offsetAdder = Vector3.new(letterPositionX, 0, 0)
            }
        }

        newLetter.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                               translateCFrameProps)
        newLetter.Anchored = true

        -- Do this last to avoid tweening
        newLetter.Parent = newWord

        table.insert(wordLetters,
                     {char = letter, found = false, instance = newLetter})
        table.insert(lettersInWord,
                     {char = letter, found = false, instance = newLetter})
    end

    local wordBench = Utils.getFirstDescendantByName(newWord, "WordBench")
    wordBench.Anchored = true

    local wordBenchSizeX = #word * letterBlockTemplate.Size.X * spacingFactorX

    local wordBenchPosX = wordBench.Position.X
    wordBench.Size = Vector3.new(wordBenchSizeX, wordBench.Size.Y,
                                 wordBench.Size.Z)
    wordBench.Position = Vector3.new(wordBenchPosX, wordBench.Position.Y,
                                     wordBench.Position.Z)

    local newWordObj = {
        word = newWord,
        letters = lettersInWord,
        wordChars = word
    }

    letterPositioner:Destroy()
    return newWordObj
end

module.initWord = initWord

return module
