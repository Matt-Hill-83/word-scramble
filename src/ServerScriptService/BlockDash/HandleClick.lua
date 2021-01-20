local CS = game:GetService("CollectionService")
local Sss = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local PlayerStatManager = require(Sss.Source.AddRemoteObjects.PlayerStatManager)

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
local Constants = require(Sss.Source.Constants.Constants)
local LetterFallUtils = require(Sss.Source.LetterFall.LetterFallUtils)
local Leaderboard = require(Sss.Source.AddRemoteObjects.Leaderboard)

local module = {processing = false, initComplete = false}

function isDesiredLetter(availLetters, clickedLetter)
    local textLabel = Utils.getFirstDescendantByName(clickedLetter, "BlockChar")
                          .Text
    local char = LetterFallUtils.getCharFromLetterBlock(clickedLetter)
    return availLetters[char]
end

function isDeadLetter(clickedLetter)
    local tag = LetterFallUtils.tagNames.DeadLetter
    return CS:HasTag(clickedLetter, tag)
end

function findFirstMatchingLetterBlock(foundChar, miniGameState)
    local matchingLetter = nil

    for wordIndex, word in ipairs(miniGameState.renderedWords) do
        local letter = word.letters[miniGameState.currentLetterIndex]
        if foundChar == letter.char then
            miniGameState.activeWord = word
            matchingLetter = letter.instance
            break
        end
    end
    return matchingLetter
end

local function onSelectRackBlock(clickedLetter, miniGameState, player)
    if module.processing == true then return end
    module.processing = true

    local sectorFolder = miniGameState.sectorFolder

    if not module.initComplete then
        module.initComplete = true
        -- 
    end

    local isChild = clickedLetter:IsDescendantOf(sectorFolder)

    if not isChild then
        module.processing = false
        return
    end

    if isDeadLetter(clickedLetter) then
        module.processing = false
        return
    end

    local isFound = CS:HasTag(clickedLetter, LetterFallUtils.tagNames.Found)
    if isFound then
        module.processing = false
        return
    end

    local activeWord = miniGameState.activeWord
    local currentLetterIndex = miniGameState.currentLetterIndex
    local words = miniGameState.words

    local foundChar = LetterFallUtils.getCharFromLetterBlock(clickedLetter)

    local targetLetterBlock = nil

    if activeWord then
        local nextLetterInWord = activeWord.letters[currentLetterIndex]

        -- I'm not sure why I get this condition
        if not nextLetterInWord then
            module.processing = false
            return
        end
        local nextCharInWord = nextLetterInWord.char
        local found = foundChar == nextCharInWord
        if found then
            targetLetterBlock = activeWord.letters[currentLetterIndex].instance
        end
    else
        local availLetters = LetterFallUtils.getAvailLettersDict(
                                 {
                words = words,
                currentLetterIndex = currentLetterIndex
            })

        local numAvailLetters = Utils.tablelength(availLetters)
        if isDesiredLetter(availLetters, clickedLetter) then
            targetLetterBlock = findFirstMatchingLetterBlock(foundChar,
                                                             miniGameState)
        end
    end

    if targetLetterBlock then
        CS:AddTag(clickedLetter, LetterFallUtils.tagNames.Found)
        CS:AddTag(targetLetterBlock, "FoundInWord")
        CS:RemoveTag(clickedLetter, LetterFallUtils.tagNames.RackLetter)

        local letterBlockCFrame = clickedLetter.CFrame

        Utils3.tween({
            part = clickedLetter,
            endPosition = targetLetterBlock.Position,
            time = 0.6,
            anchor = true
        })

        clickedLetter.CFrame = targetLetterBlock.CFrame
        -- hide the letter in rack where this letter is going
        -- CS:AddTag(targetLetterBlock, "Hide")

        LetterFallUtils.applyStyleFromTemplateBD(
            {
                targetLetterBlock = targetLetterBlock,
                templateName = "LBPurpleLight"
            })

        local clickedChar =
            LetterFallUtils.getCharFromLetterBlock(clickedLetter)

        if clickedChar then
            table.insert(miniGameState.foundLetters,
                         LetterFallUtils.getCharFromLetterBlock(clickedLetter))
        end
        clickedLetter:Destroy()

        local currentWord = table.concat(miniGameState.foundLetters, "")
        local wordComplete = table.find(words, currentWord)

        miniGameState.currentLetterIndex = miniGameState.currentLetterIndex + 1
        if (wordComplete) then
            local currentWord2 = Constants.wordConfigs[currentWord]
            if currentWord2 then
                local soundId = currentWord2['soundId']
                if (soundId) then
                    local sound = Instance.new("Sound", workspace)
                    sound.SoundId = "rbxassetid://" .. soundId
                    sound.EmitterSize = 5
                    sound.Looped = false
                    if not sound.IsPlaying then sound:Play() end
                end
            end

            local gemTemplate = Utils.getFromTemplates("GemTemplate")
            local newGem = gemTemplate:Clone()
            newGem.Parent = sectorFolder
            newGem.Handle.CFrame = letterBlockCFrame + Vector3.new(0, 30, 0)
            newGem.Handle.Anchored = false

            local rand = Utils.genRandom(1, #Constants.gemColors)
            newGem.Handle.Color = Constants.gemColors[rand]

            table.insert(miniGameState.foundWords, currentWord)

            local activeWord2 = miniGameState.activeWord
            activeWord2.Name = "wwww"
            activeWord2.word:Destroy()

            for _, letter in ipairs(activeWord2.letters) do
                local myLetter = letter.instance
                myLetter:Destroy()
            end
            miniGameState.activeWord = nil

            miniGameState.foundLetters = {}
            miniGameState.currentLetterIndex = 1

            local wins = player.leaderstats.Wins
            wins.Value = wins.Value + 1

            PlayerStatManager:ChangeStat(player, "Gems", 1)
            Leaderboard.updateLB()

            print('miniGameState.renderedWords' .. ' - start');
            print(miniGameState.renderedWords);
        end

        LetterFallUtils.styleLetterBlocksBD({miniGameState = miniGameState})

        local numAvailableBlocks = LetterFallUtils.getNumAvailLetterBlocks(
                                       miniGameState)

        if numAvailableBlocks == 0 then
            miniGameState.onWordLettersGone(miniGameState)
        end
    end
    module.processing = false
end

module.onSelectRackBlock = onSelectRackBlock
return module
