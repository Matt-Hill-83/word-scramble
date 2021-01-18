local Sss = game:GetService("ServerScriptService")
local CS = game:GetService("CollectionService")
local LetterFallUtils = require(Sss.Source.LetterFall.LetterFallUtils)

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
local Constants = require(Sss.Source.Constants.Constants)

local ChestScript = require(Sss.Source.BlockDash.ChestScript)

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
        local newLetter = letterBlockTemplate:Clone()

        local cd = Instance.new("ClickDetector", newLetter)
        cd.MouseClick:Connect(LetterFallUtils.playWordSound(word))

        newLetter.Name = "wordLetter-" .. letterNameStub .. "xxxx"
        newLetter.Anchored = false
        newLetter.CanCollide = false

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

        local weld = Instance.new("WeldConstraint")
        weld.Name = "WeldConstraint" .. letterNameStub
        weld.Parent = wordBench
        weld.Part0 = wordBench
        weld.Part1 = newLetter

        -- Do this last to avoid tweening
        newLetter.Parent = newWord

        table.insert(lettersInWord,
                     {char = letter, found = false, instance = newLetter})
    end

    local wordBenchSizeX = #word * letterBlockTemplate.Size.X * spacingFactorX

    wordBench.Size = Vector3.new(wordBenchSizeX, wordBench.Size.Y,
                                 wordBench.Size.Z)

    local newWordObj = {
        word = newWord,
        letters = lettersInWord,
        wordChars = word
    }

    letterPositioner:Destroy()
    letterPositioner.Transparency = 1
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

local function initWord(miniGameState, wordIndex, config)
    print('initWord' .. ' - start');
    print(initWord);
    local letterFallFolder = miniGameState.letterFallFolder

    local positioner = Utils.getFirstDescendantByName(letterFallFolder,
                                                      "LetterGrabberPositioner")
    local template = Utils.getFromTemplates("GrabberReplicatorTemplate")

    local newReplicator = template:Clone()
    local lettterGrabber = Utils.getFirstDescendantByName(newReplicator,
                                                          "LetterGrabber")

    newReplicator.Parent = letterFallFolder
    local newReplicatorPart = newReplicator.PrimaryPart
    local wordNameStub = "-W" .. wordIndex

    applyDecalsToCharacterFromWord({part = lettterGrabber, word = config})
    configWordLetters({
        part = lettterGrabber,
        word = config,
        wordNameStub = wordNameStub
    })

    local breaker = Utils.getFirstDescendantByName(lettterGrabber, "Breaker")
    local offsetX = wordIndex * 10
    newReplicatorPart.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                                   {
            parent = positioner,
            child = newReplicatorPart,
            offsetConfig = {
                useParentNearEdge = Vector3.new(-1, -1, -1),
                useChildNearEdge = Vector3.new(-1, -1, -1),
                offsetAdder = Vector3.new(offsetX, 0, 0)
            }
        })

    newReplicatorPart.Anchored = true

    local function destroyBreaker(breaker)
        return function() breaker:Destroy() end
    end

    -- only break if it is one I can take
    breaker.Touched:Connect(destroyBreaker(breaker))

    ChestScript.init(newReplicator)
end

function module.initLetterGrabbers(miniGameState)
    local configs = {
        "CAT", "DOG", "RAT", "BAT", "HAT", "MAT", "PAT", "VAT", "MOM", "DAD"
    }

    for wordIndex, config in ipairs(configs) do
        initWord(miniGameState, wordIndex, config)
    end
end

return module

