local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)

local module = {}

function clearBlockRack(miniGameState)
    local rackLetterBlockObjs = miniGameState.rackLetterBlockObjs

    -- delete objects
    for i, letter in ipairs(rackLetterBlockObjs) do
        if letter.part then letter.part:Destroy() end
        rackLetterBlockObjs[i] = nil
    end
    -- clear table entries
    Utils.clearTable(miniGameState.rackLetterBlockObjs)
end

module.clearBlockRack = clearBlockRack
return module
