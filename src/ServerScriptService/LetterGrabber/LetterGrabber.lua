local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Constants = require(Sss.Source.Constants.Constants)

local module = {}

function module.initLetterGrabber(miniGameState)
    local letterFallFolder = miniGameState.letterFallFolder

    local positioners = Utils.getDescendantsByName(letterFallFolder,
                                                   "LetterGrabberPositioner")
    print('positioners' .. ' - start');
    print(positioners);

    local template = Utils.getFromTemplates("LetterGrabberTemplate")
    print('template' .. ' - start');
    print(template);

    local configs = {"cat", "dog"}

    for _, positioner in ipairs(positioners) do

        local newGrabber = template:Clone()
        newGrabber.Parent = letterFallFolder
        newGrabber.Handle.CFrame = positioner.CFrame

    end
end

return module

