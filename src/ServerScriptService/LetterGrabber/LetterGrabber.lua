local Sss = game:GetService("ServerScriptService")
local CS = game:GetService("CollectionService")
local LetterFallUtils = require(Sss.Source.LetterFall.LetterFallUtils)

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
local Constants = require(Sss.Source.Constants.Constants)

local module = {}

local function configWordLetters(props)
    local newWord = props.part
    local word = props.word
    local wordNameStub = props.wordNameStub

    local letterPositioner = Utils.getFirstDescendantByName(newWord,
                                                            "LetterPositioner")
    letterPositioner.Name = letterPositioner.Name .. 'aaaa'

    local letterBlockFolder = Utils.getFromTemplates("LetterBlockTemplates")
    local letterBlockTemplate = Utils.getFirstDescendantByName(
                                    letterBlockFolder, "LBPurpleLight")

    local wordBench = Utils.getFirstDescendantByName(newWord, "WordBench")
    wordBench.Name = wordBench.Name .. "yyyy"

    local spacingFactorX = 1.0

    local lettersInWord = {}
    for letterIndex = 1, #word do
        local letterNameStub = wordNameStub .. "-L" .. letterIndex

        local letter = string.sub(word, letterIndex, letterIndex)
        print('letter' .. ' - start');
        print(letter);

        local newLetter = letterBlockTemplate:Clone()

        local cd = Instance.new("ClickDetector", newLetter)
        cd.MouseClick:Connect(LetterFallUtils.playWordSound(word))

        newLetter.Name = "wordLetter-" .. letterNameStub .. "xxxx"
        newLetter.Anchored = false

        local letterPositionX = newLetter.Size.X * (letterIndex - 1) *
                                    spacingFactorX

        CS:AddTag(newLetter, LetterFallUtils.tagNames.WordLetter)
        LetterFallUtils.applyLetterText({letterBlock = newLetter, char = letter})

        local translateCFrameProps = {
            parent = letterPositioner,
            child = newLetter,
            offsetConfig = {
                useParentNearEdge = Vector3.new(-1, -1, -1),
                useChildNearEdge = Vector3.new(-1, -1, -1),
                offsetAdder = Vector3.new(0, 0, letterPositionX)
            }
        }

        newLetter.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                               translateCFrameProps)
        -- newLetter.Anchored = true

        local weld = Instance.new("WeldConstraint")
        weld.Name = "WeldConstraint" .. letterNameStub
        weld.Parent = wordBench
        weld.Part0 = wordBench
        weld.Part1 = newLetter

        -- Do this last to avoid tweening
        newLetter.Parent = newWord

        -- table.insert(wordLetters,
        --              {char = letter, found = false, instance = newLetter})
        table.insert(lettersInWord,
                     {char = letter, found = false, instance = newLetter})
    end

    -- wordBench.Anchored = true

    local wordBenchSizeX = #word * letterBlockTemplate.Size.X * spacingFactorX

    local wordBenchPosX = wordBench.Position.X
    wordBench.Size = Vector3.new(wordBenchSizeX, wordBench.Size.Y,
                                 wordBench.Size.Z)
    -- wordBench.Position = Vector3.new(wordBenchPosX, wordBench.Position.Y,
    --                                  wordBench.Position.Z)

    local newWordObj = {
        word = newWord,
        letters = lettersInWord,
        wordChars = word
    }

    -- letterPositioner:Destroy()
    return newWordObj
end

local function applyDecalsToCharacterFromWord(props)
    local part = props.part
    local word = props.word

    if Constants.wordConfigs[word] then
        local imageId = Constants.wordConfigs[word]['imageId']
        if imageId then
            local decalUri = 'rbxassetid://' .. imageId
            local decals = Utils.getDescendantsByName(part, "ImageLabel")

            for _, decal in ipairs(decals) do decal.Image = decalUri end
        end
    end
end

function onTouchGrabber(breaker)
    -- enclosed property
    local isReleasedFromBreaker = false

    local function closure(otherPart)
        local humanoid = otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            if not isReleasedFromBreaker then
                isReleasedFromBreaker = true
                breaker:Destroy()
            end
        end
    end
    return closure
end

local function initWord(miniGameState, wordIndex, config)
    local letterFallFolder = miniGameState.letterFallFolder

    local positioner = Utils.getFirstDescendantByName(letterFallFolder,
                                                      "LetterGrabberPositioner")
    local template = Utils.getFromTemplates("LetterGrabberTemplate")

    local newGrabber = template:Clone()
    newGrabber.Parent = letterFallFolder
    local grabberPart = newGrabber.Handle

    local wordNameStub = "-W" .. wordIndex

    applyDecalsToCharacterFromWord({part = newGrabber, word = config})
    configWordLetters({
        part = newGrabber,
        word = config,
        wordNameStub = wordNameStub
    })

    local breaker = Utils.getFirstDescendantByName(newGrabber, "Breaker")
    local offsetX = wordIndex * 10
    breaker.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                         {
            parent = positioner,
            child = breaker,
            offsetConfig = {
                useParentNearEdge = Vector3.new(-1, 1, -1),
                useChildNearEdge = Vector3.new(1, 1, 1),
                offsetAdder = Vector3.new(0, 0, offsetX)
            }
        })

    breaker.Anchored = true
    grabberPart.Touched:Connect(onTouchGrabber(breaker))
    -- 
end

function module.initLetterGrabber(miniGameState)
    local configs = {"DOG"}
    -- local configs = {"CAT", "DOG", "RAT", "BAT", "HAT", "MAT", "PAT", "VAT"}

    for wordIndex, config in ipairs(configs) do
        initWord(miniGameState, wordIndex, config)
        -- 
    end
end

return module

