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
    local newStatueScene = props.newStatueScene
    local word = props.word
    local sentencePositioner = props.sentencePositioner
    local offsetX = props.offsetX
    local totalLetterWidth = props.totalLetterWidth
    local wordSpacer = props.wordSpacer
    local currentWordPosition = props.currentWordPosition

    --    TODO: store this template in getFromTemplates
    --    TODO: store this template in getFromTemplates
    --    TODO: store this template in getFromTemplates
    local wordTemplate = Utils.getFirstDescendantByName(newStatueScene,
                                                        "WordTemplate")

    local newWord = wordTemplate:Clone()
    Utils.applyDecalsToCharacterFromWord({part = newWord, word = word})

    newWord.Parent = wordTemplate.Parent
    local totalWordWidth = totalLetterWidth * #word + wordSpacer

    local translateWordProps = {
        parent = sentencePositioner,
        child = newWord.PrimaryPart,
        offsetConfig = {
            useParentNearEdge = Vector3.new(1, -1, 1),
            useChildNearEdge = Vector3.new(1, -1, 1),
            offsetAdder = Vector3.new((offsetX - currentWordPosition.value), 0,
                                      0)
        }
    }
    currentWordPosition.value = currentWordPosition.value + totalWordWidth

    print('currentWordPosition.value' .. ' - start');
    print(currentWordPosition.value);

    newWord.PrimaryPart.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                                     translateWordProps)
    newWord.PrimaryPart.Anchored = true

    return newWord
end

local function initWord(props)
    local wordIndex = props.wordIndex
    local word = props.word
    local wordLetters = props.wordLetters
    local letterBlockTemplate = props.letterBlockTemplate
    local totalLetterWidth = props.totalLetterWidth

    local wordNameStub = "-W" .. wordIndex
    local newWord = configWord(props)
    newWord.Name = newWord.Name .. "zzz" .. wordNameStub
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

        local letterPositionX = -totalLetterWidth * (letterIndex - 1)

        CS:AddTag(newLetter, "WordPopLetter")
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

    local wordBenchSizeX = #word * totalLetterWidth

    -- local wordBenchPosX = wordBench.Position.X
    wordBench.Size = Vector3.new(wordBenchSizeX, wordBench.Size.Y,
                                 wordBench.Size.Z)
    -- wordBench.Position = Vector3.new(wordBenchPosX, wordBench.Position.Y,
    --                                  wordBench.Position.Z)

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
