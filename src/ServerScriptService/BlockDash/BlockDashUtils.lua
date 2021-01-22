local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)

local module = {}

local function clearBlockRack(miniGameState)
    local rackLetterBlockObjs = miniGameState.rackLetterBlockObjs

    -- delete objects
    for i, letter in ipairs(rackLetterBlockObjs) do
        if letter.part then letter.part:Destroy() end
        rackLetterBlockObjs[i] = nil
    end
    -- clear table entries
    Utils.clearTable(miniGameState.rackLetterBlockObjs)
end

local function clearWordRack(miniGameState)
    local renderedWords = miniGameState.renderedWords

    -- delete objects
    for i, obj in ipairs(renderedWords) do
        if obj.word then obj.word:Destroy() end
        renderedWords[i] = nil
    end
    -- clear table entries
    Utils.clearTable(miniGameState.renderedWords)
end

module.clearBlockRack = clearBlockRack
module.clearWordRack = clearWordRack
return module
