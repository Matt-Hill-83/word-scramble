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
        DeadLetter = module.letterBlockStyleNames.LBDeadLetter,
        -- 
        FoundBD = module.letterBlockStyleNames.LBPurpleOrange,
        AvailableBD = "BD_available"
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

function getLettersNotInWords(words)
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

function getRandomLetter(letters)
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
        availWords = miniGameState.words
    end
    return availWords
end

local function initLetterBlock(props)
    local letterBlock = props.letterBlock
    local char = props.char
    local templateName = props.templateName

    CS:AddTag(letterBlock, "BlockDash")

    local dummyTextLabel = Instance.new("TextLabel", letterBlock)
    dummyTextLabel.Name = "CurrentStyle"
    dummyTextLabel.Text = "zzz"

    -- apply the letterText, so the letter block retains the char as a property
    -- TODO: This is obsolete, use StringValue to store the character instead.
    module.applyLetterText({letterBlock = letterBlock, char = char})
    module.applyLetterImage(letterBlock, char)
    module.hideBlockText(letterBlock)

    -- Use StringValue to store the character instead.
    local propChar = Instance.new("StringValue", letterBlock)
    propChar.Name = "Character"
    propChar.Value = char

    local propStyle = Instance.new("StringValue", letterBlock)
    propStyle.Name = "CurrentStyle"
    propStyle.Value = "zzz"

    local propUuid = Instance.new("StringValue", letterBlock)
    propUuid.Name = "Uuid"
    propUuid.Value = Utils.getUuid()

    if templateName then
        module.applyStyleFromTemplateBD({
            targetLetterBlock = letterBlock,
            templateName = templateName
        })
    end
end

function hideBlockImages(letterBlock)
    local labels = Utils.getDescendantsByName(letterBlock, "ImageLabel")
    for i, label in ipairs(labels) do label.Visible = false end
end

function hideBlockText(letterBlock)
    local labels = Utils.getDescendantsByName(letterBlock, "BlockChar")
    for i, label in ipairs(labels) do label.Visible = false end
end

function applyLetterImage(letterBlock, char)
    local imageId = Constants.alphabet[char]['decalId']
    local imageUri = 'rbxassetid://' .. imageId

    local labels = Utils.getDescendantsByName(letterBlock, "ImageLabel")
    for i, label in ipairs(labels) do
        label.BackgroundTransparency = 1
        -- label.Visible = true
        label.Image = imageUri
    end
end

function applyStyleFromTemplateBD(props)
    local targetLetterBlock = props.targetLetterBlock
    local templateName = props.templateName

    local letterBlockTemplateFolder = Utils.getFromTemplates(
                                          "LetterBlockTemplates")

    local template = Utils.getFirstDescendantByName(letterBlockTemplateFolder,
                                                    templateName)

    targetLetterBlock.Color = template.Color

    local label = Utils.getFirstDescendantByName(template, "BlockChar")

    local labelProps = {
        TextColor3 = label.TextColor3,
        BorderColor3 = label.BorderColor3,
        BackgroundColor3 = label.BackgroundColor3
    }
    styleLetterBlock(targetLetterBlock, labelProps)
end

function applyStyleFromTemplate(props)
    local targetLetterBlock = props.targetLetterBlock
    local templateName = props.templateName

    -- retrieve existing templateName from dummy TextLabel
    local currentStyle = Utils.getFirstDescendantByName(targetLetterBlock,
                                                        "CurrentStyle")

    if currentStyle then
        if currentStyle.Text == templateName then
            -- Do not apply a style that already exists
            return
        else
            currentStyle.Text = templateName
        end
    else
        -- TODO: move to Utils
        local dummyTextLabel = Instance.new("TextLabel", targetLetterBlock)
        dummyTextLabel.Name = "CurrentStyle"
        dummyTextLabel.Text = "templateName"
    end

    local letterBlockTemplateFolder = Utils.getFromTemplates(
                                          "LetterBlockTemplates")

    local template = Utils.getFirstDescendantByName(letterBlockTemplateFolder,
                                                    templateName)

    local isBlockDash = CS:HasTag(targetLetterBlock, "BlockDash")

    if isBlockDash then
        targetLetterBlock.Color = template.Color

        if templateName == "BD_available" then
            targetLetterBlock.CFrame = targetLetterBlock.CFrame *
                                           CFrame.new(0,
                                                      targetLetterBlock.Size.Y,
                                                      0)
            CS:AddTag(targetLetterBlock, "isLifted")
        end

        if templateName == "BD_not_available" then
            if CS:HasTag(targetLetterBlock, "isLifted") then
                targetLetterBlock.CFrame =
                    targetLetterBlock.CFrame *
                        CFrame.new(0, -targetLetterBlock.Size.Y, 0)
                CS:RemoveTag(targetLetterBlock, "isLifted")
            end
        end
    else
        local label = Utils.getFirstDescendantByName(template, "BlockChar")

        local labelProps = {
            TextColor3 = label.TextColor3,
            BorderColor3 = label.BorderColor3,
            BackgroundColor3 = label.BackgroundColor3
        }

        styleLetterBlock(targetLetterBlock, labelProps)
    end
end
-- 
-- 
-- 
-- 

function colorLetterBD(props)
    local color = props.color
    local letterBlock = props.letterBlock

    local textLabels = Utils.getDescendantsByName(letterBlock, "BlockChar")
    for i, label in ipairs(textLabels) do
        label.BackgroundColor3 = Color3.fromRGB(72, 90, 230)
    end
end

function applyLetterText(props)
    local char = props.char
    local letterBlock = props.letterBlock

    -- if not char then return end
    local textLabels = Utils.getDescendantsByName(letterBlock, "BlockChar")
    if textLabels then
        for i, label in ipairs(textLabels) do label.Text = char end
    end

end
-- 
-- 

function filterItemsByTag(props)
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

function getCoordsFromLetterName(name)
    local pattern = "ID%-%-R(%d+)C(%d+)"
    local row, col = string.match(name, pattern)
    return {row = tonumber(row), col = tonumber(col)}
end

function anchorColumn(props)
    local anchor = props.anchor
    local col = props.col
    local letters = props.letters

    for i, letter in ipairs(letters) do
        local coords = module.getCoordsFromLetterName(letter.Name)

        if tonumber(coords.col) == tonumber(col) then
            letter.Anchored = false
        end
    end
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

function styleLetterBlock(letterBlock, labelProps)
    local textLabels = Utils.getDescendantsByName(letterBlock, "BlockChar")
    for i, label in ipairs(textLabels) do
        Utils.mergeTables(label, labelProps)
    end
end

local function createStyledLetterBlock(props)
    local miniGameState = props.miniGameState
    local templateName = props.templateName
    local allLetters = miniGameState.allLetters
    local sectorFolder = miniGameState.sectorFolder

    local letterBlockFolder = Utils.getFromTemplates("LetterBlockTemplates")
    local letterBlockTemplate = Utils.getFirstDescendantByName(
                                    letterBlockFolder, templateName)

    local newLetter = letterBlockTemplate:Clone()
    local rand = Utils.genRandom(1, #allLetters)

    local char = allLetters[rand]
    module.applyLetterText({letterBlock = newLetter, char = char})
    newLetter.Parent = sectorFolder.Parent
    newLetter.Anchored = false

    local letterId = "none"
    local name = "randomLetter-" .. char .. "-" .. letterId
    newLetter.Name = name
    return newLetter
end

function setStyleToAvailable(letterBlock, miniGameState)
    module.applyStyleFromTemplate({
        targetLetterBlock = letterBlock,
        templateName = module.letterBlockStyleDefs.rack.Available,
        miniGameState = miniGameState
    })
end

function setStyleToNotAvailable(letterBlock, miniGameState)
    module.applyStyleFromTemplate({
        targetLetterBlock = letterBlock,
        templateName = module.letterBlockStyleDefs.rack.NotAvailable,
        miniGameState = miniGameState
    })
end

function setStyleToDeadLetter(letterBlock, miniGameState)
    module.applyStyleFromTemplate({
        targetLetterBlock = letterBlock,
        templateName = module.letterBlockStyleDefs.rack.DeadLetter,
        miniGameState = miniGameState
    })
end

function styleLetterBlocks(props)
    local miniGameState = props.miniGameState
    local availWords = props.availWords

    local availLetters = module.getAvailLettersDict(
                             {
            words = availWords,
            currentLetterIndex = miniGameState.currentLetterIndex
        })

    local allLetters = module.getAllLettersInRack(
                           {
            runTimeLetterFolder = miniGameState.runTimeLetterFolder
        })
    for i, letterBlock in ipairs(allLetters) do
        if CS:HasTag(letterBlock, module.tagNames.Found) then
            module.applyStyleFromTemplate(
                {
                    targetLetterBlock = letterBlock,
                    templateName = module.letterBlockStyleDefs.rack.Found,
                    miniGameState = miniGameState
                })
        else
            local char = module.getCharFromLetterBlock(letterBlock)
            if availLetters[char] then
                setStyleToAvailable(letterBlock, miniGameState)
            else
                setStyleToNotAvailable(letterBlock, miniGameState)
            end
        end

    end
end

local function styleLetterBlocksBD(props)
    local miniGameState = props.miniGameState
    local runTimeLetterFolder = miniGameState.runTimeLetterFolder
    local runTimeWordFolder = miniGameState.runTimeWordFolder

    local availWords = {}
    for _, wordObj in ipairs(miniGameState.renderedWords) do
        if wordObj.completed == false then
            table.insert(availWords, wordObj.wordChars)
        end
    end

    local availLetters = module.getAvailLettersDict(
                             {
            words = availWords,
            currentLetterIndex = miniGameState.currentLetterIndex
        })

    local allLetters = module.getAllLettersInRack(
                           {runTimeLetterFolder = runTimeLetterFolder})

    local numAvailableBlocks = 0
    for i, letterBlock in ipairs(allLetters) do
        if CS:HasTag(letterBlock, module.tagNames.Found) then
            module.applyStyleFromTemplate(
                {
                    targetLetterBlock = letterBlock,
                    templateName = "BD_found",
                    miniGameState = miniGameState
                })
        else
            local char = module.getCharFromLetterBlock(letterBlock)
            if availLetters[char] then
                numAvailableBlocks = numAvailableBlocks + 1

                -- letterBlock.CanCollide = false
                module.applyStyleFromTemplate(
                    {
                        targetLetterBlock = letterBlock,
                        templateName = "BD_available"
                    })
            else
                module.applyStyleFromTemplate(
                    {
                        targetLetterBlock = letterBlock,
                        templateName = "BD_not_available"
                    })
            end
        end
    end

    local wordLetters = module.getAllLettersInWords(
                            {runTimeWordFolder = runTimeWordFolder})
    for _, letterBlock in ipairs(wordLetters) do
        if CS:HasTag(letterBlock, "Hide") then
            Utils.hideItemAndChildren({item = letterBlock, hide = true})
        end
        if CS:HasTag(letterBlock, "UnHide") then
            Utils.hideItemAndChildren({item = letterBlock, hide = false})
        end
    end

end
function getNumAvailLetterBlocks(miniGameState)
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
            local char = module.getCharFromLetterBlock(letterBlock)
            if availLetters[char] then
                numAvailableBlocks = numAvailableBlocks + 1
            end
        end
    end
    return numAvailableBlocks
end

-- function unHideWordLetters(miniGameState)
--     local runTimeWordFolder = miniGameState.runTimeWordFolder
--     local wordLetters = module.getAllLettersInWords(
--                             {runTimeWordFolder = runTimeWordFolder})
--     for _, letterBlock in ipairs(wordLetters) do
--         if CS:HasTag(letterBlock, "Hide") then
--             Utils.hideItemAndChildren({item = letterBlock, hide = false})
--             CS:RemoveTag(letterBlock, "Hide")
--         end
--     end
-- end

function colorLetterText(props)
    local color = props.color
    local letterBlock = props.letterBlock

    local textLabels = Utils.getDescendantsByName(letterBlock, "BlockChar")
    for i, label in ipairs(textLabels) do label.TextColor3 = color end
end

function colorLetterBorder(props)
    local color = props.color
    local letterBlock = props.letterBlock

    local textLabels = Utils.getDescendantsByName(letterBlock, "BlockChar")
    for i, label in ipairs(textLabels) do
        label.BorderColor3 = color or Color3.new(255, 0, 191)
    end
end

function getCharFromLetterBlock(letterBlock)
    if not letterBlock then return end
    local label = Utils.getFirstDescendantByName(letterBlock, "BlockChar")
    if not label then return end
    return label.Text
end

function isDesiredLetter(letter, clickedLetter)
    local textLabel = Utils.getFirstDescendantByName(clickedLetter, "BlockChar")
                          .Text
    return letter.found ~= true and letter.char == textLabel
end

function isWordComplete(wordLetters)
    for i, word in ipairs(wordLetters) do
        if not word.found then return false end
    end
    return true
end

function createBalls(miniGameState)
    local letterFallFolder = miniGameState.letterFallFolder
    local questIndex = miniGameState.questIndex

    local ball = Utils.getFirstDescendantByName(letterFallFolder, "GemTemplate")
    local gemColor = Constants.gemColors[questIndex]

    local targetGemName = "Gem-Q-zzzz" .. questIndex

    local balls = {}
    for count = 1, 8 do
        local newBall = ball:Clone()
        local ballPart = newBall.Handle

        newBall.Name = targetGemName
        newBall.Parent = ball.Parent
        ballPart.CFrame = ballPart.CFrame + Vector3.new(0, 0, 0)
        ballPart.Color = gemColor
        Utils.enableChildWelds({part = newBall, enabled = false})
        table.insert(balls, newBall)
    end

    ball:Destroy()
end

function configDeadLetters(props)
    local parentFolder = props.parentFolder
    local miniGameState = props.miniGameState

    local deadLetters = Utils.getByTagInParent(
                            {
            parent = parentFolder,
            tag = module.tagNames.DeadLetter
        })

    for i, item in ipairs(deadLetters) do
        item.Anchored = true

        module.applyStyleFromTemplate({
            targetLetterBlock = item,
            templateName = module.letterBlockStyleDefs.rack.DeadLetter,
            miniGameState = miniGameState
        })
        module.applyLetterText({letterBlock = item, char = ""})
    end
end

local function getAvailLetters(props)
    local words = props.words
    local currentLetterIndex = props.currentLetterIndex

    local availLettersDict = {}
    for i, word in ipairs(words) do
        local letter = string.sub(word, currentLetterIndex, currentLetterIndex)
        availLettersDict[letter] = true
    end
    return Utils.getKeysFromDict(availLettersDict)
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

function anchorLetters(props)
    local parentFolder = props.parentFolder
    local anchor = props.anchor

    local letters = Utils.getByTagInParent(
                        {
            parent = parentFolder,
            tag = module.tagNames.NotDeadLetter
        })

    for i, item in ipairs(letters) do
        item.Anchored = anchor
        -- 
    end
end

function getAllLettersInRack(props)
    local runTimeLetterFolder = props.runTimeLetterFolder
    local letters = Utils.getByTagInParent(
                        {
            parent = runTimeLetterFolder,
            tag = module.tagNames.NotDeadLetter
        })
    return letters
end

function getAllLettersInWords(props)
    local runTimeWordFolder = props.runTimeWordFolder
    local letters = Utils.getByTagInParent(
                        {
            parent = runTimeWordFolder,
            tag = module.tagNames.WordLetter
        })
    return letters
end

module.anchorLetters = anchorLetters
module.applyLetterText = applyLetterText
module.colorLetterBD = colorLetterBD
module.colorLetterText = colorLetterText
module.configDeadLetters = configDeadLetters
module.createBalls = createBalls
module.getAllLettersInRack = getAllLettersInRack
module.getAvailLetters = getAvailLetters
module.getCharFromLetterBlock = getCharFromLetterBlock
module.isDesiredLetter = isDesiredLetter
module.isWordComplete = isWordComplete
module.getAvailLettersDict = getAvailLettersDict
module.colorLetterBorder = colorLetterBorder
module.styleLetterBlocks = styleLetterBlocks
module.applyStyleFromTemplate = applyStyleFromTemplate
module.anchorColumn = anchorColumn
module.getCoordsFromLetterName = getCoordsFromLetterName
module.filterItemsByTag = filterItemsByTag
module.createStyledLetterBlock = createStyledLetterBlock
module.getRunTimeLetterFolder = getRunTimeLetterFolder
module.applyStyleFromTemplateBD = applyStyleFromTemplateBD
module.hideBlockImages = hideBlockImages
module.applyLetterImage = applyLetterImage
module.getAvailLettersDict2 = getAvailLettersDict2
module.hideBlockText = hideBlockText
module.initLetterBlock = initLetterBlock
module.styleLetterBlocksBD = styleLetterBlocksBD
module.getAvailWords = getAvailWords
module.getRandomLetter = getRandomLetter
module.getLettersNotInWords = getLettersNotInWords
module.getAllLettersInWords = getAllLettersInWords
-- module.unHideWordLetters = unHideWordLetters
module.getNumAvailLetterBlocks = getNumAvailLetterBlocks
module.playWordSound = playWordSound
return module
