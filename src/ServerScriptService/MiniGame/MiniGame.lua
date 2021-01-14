local Sss = game:GetService("ServerScriptService")
local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
local InitLetterFall = require(Sss.Source.LetterFall.InitLetterFall)

local module = {}

function module.addMiniGame(props)
    local parent = props.parent
    local sceneIndex = props.sceneIndex
    local questIndex = props.questIndex
    local isStartScene = props.isStartScene
    local words = props.words
    local positionOffset = props.positionOffset or Vector3.new(0, 0, 0)

    local letterFallTemplate = Utils.getFromTemplates("LetterFallTemplate")

    local allLetters = {
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N',
        'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
    }

    local miniGameState = {
        activeWord = nil,
        activeWordIndex = 1,
        allLetters = allLetters,
        availLetters = {},
        availWords = {},
        currentLetterIndex = 1,
        foundLetters = {},
        foundWords = {},
        initCompleted = false,
        renderedWords = {},
        wordLetters = {},
        words = words,
        questIndex = questIndex
    }

    local miniGame = {}

    local clonedLetterFallModel = letterFallTemplate:Clone()
    clonedLetterFallModel.Name =
        clonedLetterFallModel.Name .. "Clone" .. "-Q" .. questIndex .. "-S" ..
            sceneIndex

    local letterFallFolder = Utils.getFirstDescendantByName(
                                 clonedLetterFallModel, "LetterFallFolder")
    miniGameState.letterFallFolder = letterFallFolder

    clonedLetterFallModel.Parent = parent
    local letterFallPart = clonedLetterFallModel.PrimaryPart

    local translateCFrameProps = {
        parent = parent,
        child = letterFallPart,
        offsetConfig = {
            useParentNearEdge = Vector3.new(0, 1, 1),
            useChildNearEdge = Vector3.new(0, 1, 1),
            -- slight added to prevent z-index fighting
            offsetAdder = Vector3.new(0, 2 + questIndex * 0.001, 0)
        }
    }

    local newCFrame =
        Utils3.setCFrameFromDesiredEdgeOffset(translateCFrameProps)

    letterFallPart.CFrame = newCFrame
    letterFallPart.Anchored = true

    InitLetterFall.initLetterFall(miniGameState)
    miniGame = clonedLetterFallModel

    return miniGame
end

return module
