local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
local Constants = require(Sss.Source.Constants.Constants)

local module = {}

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

local function initWord(miniGameState, configIndex, config)
    local letterFallFolder = miniGameState.letterFallFolder

    local positioner = Utils.getFirstDescendantByName(letterFallFolder,
                                                      "LetterGrabberPositioner")
    local template = Utils.getFromTemplates("LetterGrabberTemplate")

    local newGrabber = template:Clone()
    newGrabber.Parent = letterFallFolder
    local grabberPart = newGrabber.Handle

    applyDecalsToCharacterFromWord({part = newGrabber, word = config})

    local breaker = Utils.getFirstDescendantByName(newGrabber, "Breaker")
    local offsetX = configIndex * 10
    breaker.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                         {
            parent = positioner,
            child = breaker,
            offsetConfig = {
                useParentNearEdge = Vector3.new(-1, 1, -1),
                useChildNearEdge = Vector3.new(1, 1, 1),
                offsetAdder = Vector3.new(offsetX, 0, 0)
            }
        })

    breaker.Anchored = true
    grabberPart.Touched:Connect(onTouchGrabber(breaker))
    -- 
end

function module.initLetterGrabber(miniGameState)
    local configs = {"CAT", "DOG", "RAT", "BAT", "HAT", "MAT", "PAT", "VAT"}

    for configIndex, config in ipairs(configs) do
        initWord(miniGameState, configIndex, config)
        -- 
    end
end

return module

