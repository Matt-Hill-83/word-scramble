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

function onTouchBreaker(breaker)
    local function closure(otherPart)
        -- enclosed property
        local isReleasedFromBreaker = false

        local humanoid = otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            local player = Utils.getPlayerFromHumanoid(humanoid)
            if not isReleasedFromBreaker then
                isReleasedFromBreaker = true
                breaker:Destroy()
            end
        end
    end

    return closure
end

function module.initLetterGrabber(miniGameState)
    local letterFallFolder = miniGameState.letterFallFolder

    local positioners = Utils.getDescendantsByName(letterFallFolder,
                                                   "LetterGrabberPositioner")
    local template = Utils.getFromTemplates("LetterGrabberTemplate")
    local configs = {"CAT", "DOG", "RAT", "BAT", "HAT"}

    for configIndex, config in ipairs(configs) do
        local positioner = positioners[1]

        local newGrabber = template:Clone()
        newGrabber.Parent = letterFallFolder
        local breaker = Utils.getFirstDescendantByName(newGrabber, "Breaker")

        applyDecalsToCharacterFromWord({part = newGrabber, word = config})
        local grabberPart = newGrabber.Handle

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
        grabberPart.Touched:Connect(onTouchBreaker(breaker))

    end
end

return module

