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

    for _, positioner in ipairs(positioners) do

        -- 

    end
end

return module

