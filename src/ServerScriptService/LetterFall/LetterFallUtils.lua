local CS = game:GetService("CollectionService")
local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Constants = require(Sss.Source.Constants.Constants)

local module = {
    tagNames = {
        WordLetter = "WordLetter",
        LetterBlock = "LetterBlock",
        RackLetter = "RackLetter",
        DeadLetter = "DeadLetter",
        AvailLetter = "AvailLetter",
        Found = "Found",
        NotDeadLetter = "NotDeadLetter"
    }
}

module.letterBlockStyleNames = {
    LBPinkPurple = "LBPinkPurple",
    LBPurpleOrange = "LBPurpleOrange",
    LBPurpleLight = "LBPurpleLight",
    LBPurpleLight2 = "LBPurpleLight2",
    LBDarkPurple = "LBDarkPurple",
    LBDeadLetter = "LBDeadLetter"
}

module.letterBlockStyleDefs = {
    rack = {
        Available = module.letterBlockStyleNames.LBPurpleLight2,
        NotAvailable = module.letterBlockStyleNames.LBPurpleLight,
        Found = module.letterBlockStyleNames.LBPurpleOrange,
        DeadLetter = module.letterBlockStyleNames.LBDeadLetter
    },
    word = {
        Placeholder = module.letterBlockStyleNames.LBPurpleLight,
        Found = module.letterBlockStyleNames.LBPurpleOrange
    }
}

local function playWordSound(word)
    local closure = function()
        if Constants.wordConfigs[word] then
            local soundId = Constants.wordConfigs[word]['soundId']

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

local function getLettersNotInWords(words)
    local allLetters = Constants.allLetters

    local uniqueLettersFromWords = {}

    for _, word in ipairs(words) do
        for letterIndex = 1, #word do
            local letter = string.sub(word, letterIndex, letterIndex)
            uniqueLettersFromWords[letter] = true
        end
    end

    local filteredLetters = {}
    for _, letter in ipairs(allLetters) do

        if not uniqueLettersFromWords[letter] then
            table.insert(filteredLetters, letter)
        end
    end

    return filteredLetters
end

local function getRandomLetter(letters)
    local defaultLetters = Constants.allLetters

    if not letters then letters = defaultLetters end
    local rand = Utils.genRandom(1, #letters)
    return letters[rand]
end

local function getAvailWords(miniGameState)
    local availWords = {}
    local activeWord = miniGameState.activeWord

    if activeWord then
        availWords = {activeWord.wordChars}
    else
        for _, wordObj in ipairs(miniGameState.renderedWords) do
            if wordObj.completed == false then
                table.insert(availWords, wordObj)
            end
        end
    end
    return availWords
end

local function initLetterBlock(props)
    local letterBlock = props.letterBlock
    local char = props.char
    local templateName = props.templateName
    local letterBlockType = props.letterBlockType

    CS:AddTag(letterBlock, "BlockDash")

    module.applyLetterImage(letterBlock, char)

    local propChar = Instance.new("StringValue", letterBlock)
    propChar.Name = "Character"
    propChar.Value = char

    local propStyle = Instance.new("StringValue", letterBlock)
    propStyle.Name = "CurrentStyle"
    propStyle.Value = "zzz"

    local propUuid = Instance.new("StringValue", letterBlock)
    propUuid.Name = "Uuid"
    propUuid.Value = Utils.getUuid()

    local propType = Instance.new("StringValue", letterBlock)
    propType.Name = "Type"
    propUuid.Value = letterBlockType

    if templateName then
        module.applyStyleFromTemplateBD({
            targetLetterBlock = letterBlock,
            templateName = templateName
        })
    end
end

local function applyLetterImage(letterBlock, char)
    local imageId = Constants.alphabet[char]['decalId']
    local imageUri = 'rbxassetid://' .. imageId

    local labels = Utils.getDescendantsByName(letterBlock, "ImageLabel")
    for _, label in ipairs(labels) do
        -- label.BackgroundTransparency = 1
        label.Image = imageUri
    end
end

local function applyStyleFromTemplateBD(props)
    local targetLetterBlock = props.targetLetterBlock
    local templateName = props.templateName

    local letterBlockTemplateFolder = Utils.getFromTemplates(
                                          "LetterBlockTemplates")

    local template = Utils.getFirstDescendantByName(letterBlockTemplateFolder,
                                                    templateName)
    targetLetterBlock.Color = template.Color

    -- TODO: this is hacky, fix
    -- TODO: this is hacky, fix
    -- TODO: this is hacky, fix
    if templateName == "BD_available" then
        targetLetterBlock.CFrame = targetLetterBlock.CFrame *
                                       CFrame.new(0, targetLetterBlock.Size.Y, 0)
        CS:AddTag(targetLetterBlock, "isLifted")
    end

    if templateName == "BD_not_available" then
        if CS:HasTag(targetLetterBlock, "isLifted") then
            targetLetterBlock.CFrame = targetLetterBlock.CFrame *
                                           CFrame.new(0,
                                                      -targetLetterBlock.Size.Y,
                                                      0)
            CS:RemoveTag(targetLetterBlock, "isLifted")
        end
    end

end

local function applyStyleFromTemplate(props)
    local targetLetterBlock = props.targetLetterBlock
    local templateName = props.templateName

    local currentStyle = targetLetterBlock.CurrentStyle.Value

    if currentStyle then
        if currentStyle == templateName then
            -- Do not apply a style that already exists
            return
        else
            targetLetterBlock.CurrentStyle.Value = templateName
        end
    end

    local letterBlockTemplateFolder = Utils.getFromTemplates(
                                          "LetterBlockTemplates")
    local template = Utils.getFirstDescendantByName(letterBlockTemplateFolder,
                                                    templateName)

    local label = Utils.getFirstDescendantByName(template, "BlockChar")

    local labelProps = {
        TextColor3 = label.TextColor3,
        BorderColor3 = label.BorderColor3,
        BackgroundColor3 = label.BackgroundColor3
    }

    styleLetterBlock(targetLetterBlock, labelProps)
end

local function applyLetterText(props)
    local char = props.char
    local letterBlock = props.letterBlock

    -- if not char then return end
    local textLabels = Utils.getDescendantsByName(letterBlock, "BlockChar")
    if textLabels then
        for i, label in ipairs(textLabels) do label.Text = char end
    end

end

local function filterItemsByTag(props)
    local items = props.items
    local tag = props.tag
    local include = props.include

    local output = {}
    for i, item in ipairs(items) do

        if include then
            if CS:hasTag(item, tag) then table.insert(output, item) end
        end

        if not include then
            if not CS:hasTag(item, tag) then
                table.insert(output, item)
            end
        end
    end
    return output
end

local function getCoordsFromLetterName(name)
    local pattern = "ID%-%-R(%d+)C(%d+)"
    local row, col = string.match(name, pattern)
    return {row = tonumber(row), col = tonumber(col)}
end

local function getRunTimeLetterFolder(miniGameState)
    local sectorFolder = miniGameState.sectorFolder
    local runtimeFolder = Utils.getOrCreateFolder(
                              {name = "RunTimeFolder", parent = sectorFolder})

    return Utils.getOrCreateFolder({
        name = "RunTimeLetterRackFolder",
        parent = runtimeFolder
    })
end

local function styleLetterBlock(letterBlock, labelProps)
    local textLabels = Utils.getDescendantsByName(letterBlock, "BlockChar")
    for i, label in ipairs(textLabels) do
        Utils.mergeTables(label, labelProps)
    end
end

local function styleLetterBlocksBD(props)
    local miniGameState = props.miniGameState
    local runTimeLetterFolder = miniGameState.runTimeLetterFolder
    local currentLetterIndex = miniGameState.currentLetterIndex

    local activeWord = miniGameState.activeWord

    local availWords = {}

    if activeWord then
        availWords = {activeWord.wordChars}
    else
        for _, wordObj in ipairs(miniGameState.renderedWords) do
            if wordObj.completed == false then
                table.insert(availWords, wordObj.wordChars)
            end
        end
    end

    local availLetters = module.getAvailLettersDict(
                             {
            words = availWords,
            currentLetterIndex = currentLetterIndex
        })

    local allLetters = module.getAllLettersInRack(
                           {runTimeLetterFolder = runTimeLetterFolder})

    for _, letterBlock in ipairs(allLetters) do
        if CS:HasTag(letterBlock, module.tagNames.Found) then
            module.applyStyleFromTemplateBD(
                {targetLetterBlock = letterBlock, templateName = "BD_found"})
        else
            local char = module.getCharFromLetterBlock2(letterBlock)
            if availLetters[char] then

                -- letterBlock.CanCollide = false
                module.applyStyleFromTemplateBD(
                    {
                        targetLetterBlock = letterBlock,
                        templateName = "BD_available"
                    })
            else
                module.applyStyleFromTemplateBD(
                    {
                        targetLetterBlock = letterBlock,
                        templateName = "BD_not_available"
                    })
            end
        end
    end

end

local function getNumAvailLetterBlocks(miniGameState)
    local runTimeLetterFolder = miniGameState.runTimeLetterFolder

    local availWords = module.getAvailWords(miniGameState)
    local availLetters = module.getAvailLettersDict(
                             {
            words = availWords,
            currentLetterIndex = miniGameState.currentLetterIndex
        })

    local allLetters = module.getAllLettersInRack(
                           {runTimeLetterFolder = runTimeLetterFolder})

    local numAvailableBlocks = 0
    for _, letterBlock in ipairs(allLetters) do
        if not CS:HasTag(letterBlock, module.tagNames.Found) then
            local char = module.getCharFromLetterBlock2(letterBlock)
            if availLetters[char] then
                numAvailableBlocks = numAvailableBlocks + 1
            end
        end
    end
    return numAvailableBlocks
end

local function colorLetterText(props)
    local color = props.color
    local letterBlock = props.letterBlock

    local textLabels = Utils.getDescendantsByName(letterBlock, "BlockChar")
    for i, label in ipairs(textLabels) do label.TextColor3 = color end
end

local function colorLetterBorder(props)
    local color = props.color
    local letterBlock = props.letterBlock

    local textLabels = Utils.getDescendantsByName(letterBlock, "BlockChar")
    for i, label in ipairs(textLabels) do
        label.BorderColor3 = color or Color3.new(255, 0, 191)
    end
end

local function getCharFromLetterBlock2(letterBlock)
    if not letterBlock then return end
    local char = letterBlock.Character.Value
    return char
end

local function isDesiredLetter(letter, clickedLetter)
    local textLabel = Utils.getFirstDescendantByName(clickedLetter, "BlockChar")
                          .Text
    return letter.found ~= true and letter.char == textLabel
end

local function isWordComplete(wordLetters)
    for i, word in ipairs(wordLetters) do
        if not word.found then return false end
    end
    return true
end

local function getAvailLettersDict2(miniGameState)
    local availableWords = {}
    for _, wordObj in ipairs(miniGameState.renderedWords) do
        if wordObj.completed == false then
            table.insert(availableWords, wordObj)
        end
    end

    local availLettersDict = {}
    for i, word in ipairs(availableWords) do
        local letter = string.sub(word.wordChars, 1, 1)
        availLettersDict[letter] = true
    end
    return availLettersDict
end

local function getAvailLettersDict(props)
    local words = props.words
    local currentLetterIndex = props.currentLetterIndex

    local availLettersDict = {}
    for i, word in ipairs(words) do
        local letter = string.sub(word, currentLetterIndex, currentLetterIndex)
        availLettersDict[letter] = true
    end
    return availLettersDict
end

local function getAllLettersInRack(props)
    local runTimeLetterFolder = props.runTimeLetterFolder
    local letters = Utils.getByTagInParent(
                        {
            parent = runTimeLetterFolder,
            tag = module.tagNames.NotDeadLetter
        })
    return letters
end

local function getAllLettersInWords(props)
    local runTimeWordFolder = props.runTimeWordFolder
    local letters = Utils.getByTagInParent(
                        {
            parent = runTimeWordFolder,
            tag = module.tagNames.WordLetter
        })
    return letters
end

module.applyLetterText = applyLetterText
module.colorLetterText = colorLetterText
module.getAllLettersInRack = getAllLettersInRack
module.isDesiredLetter = isDesiredLetter
module.isWordComplete = isWordComplete
module.getAvailLettersDict = getAvailLettersDict
module.colorLetterBorder = colorLetterBorder
module.applyStyleFromTemplate = applyStyleFromTemplate
module.getCoordsFromLetterName = getCoordsFromLetterName
module.filterItemsByTag = filterItemsByTag
module.getRunTimeLetterFolder = getRunTimeLetterFolder
module.applyStyleFromTemplateBD = applyStyleFromTemplateBD
module.applyLetterImage = applyLetterImage
module.getAvailLettersDict2 = getAvailLettersDict2
module.initLetterBlock = initLetterBlock
module.styleLetterBlocksBD = styleLetterBlocksBD
module.getAvailWords = getAvailWords
module.getRandomLetter = getRandomLetter
module.getCharFromLetterBlock2 = getCharFromLetterBlock2
module.getLettersNotInWords = getLettersNotInWords
module.getAllLettersInWords = getAllLettersInWords
-- module.unHideWordLetters = unHideWordLetters
module.getNumAvailLetterBlocks = getNumAvailLetterBlocks
module.playWordSound = playWordSound
return module
