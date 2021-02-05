local CS = game:GetService("CollectionService")
local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)

local module = {}

local function getActiveLetterGrabberBlock(tool)
    local function getSortedBlocks(tool2)
        local letterBlocks = Utils.getByTagInParent(
                                 {parent = tool2, tag = "WordPopLetter"})
        Utils.sortListByObjectKey(letterBlocks, "Name")
        return letterBlocks
    end

    local letterBlocks = getSortedBlocks(tool)
    local activeBlock = nil
    for _, block in ipairs(letterBlocks) do
        if block.IsFound.Value == false then
            activeBlock = block
            break
        end
    end
    return activeBlock
end

module.getActiveLetterGrabberBlock = getActiveLetterGrabberBlock
return module
