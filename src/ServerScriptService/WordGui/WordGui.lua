local Sss = game:GetService("ServerScriptService")
local CS = game:GetService("CollectionService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
local Const4 = require(Sss.Source.Constants.Const_04_Characters)

local RenderWordGrid = require(Sss.Source.WordGui.RenderWordGrid)

local starterGui = game:GetService("StarterGui")

print('starterGui' .. ' - start');
print(starterGui);
local module = {}

function module.initWordGui(props)
    local parentFolder = props.parentFolder
    local levelConfig = props.levelConfig
    local targetWords = levelConfig.targetWords

    local mainGui = Utils.getFirstDescendantByName(starterGui, "MainGui")
    local mainFrame = Utils.getFirstDescendantByName(mainGui, "MainFrame")

    print('levelConfig' .. ' - start');
    print(levelConfig.targetWords);

    RenderWordGrid.renderGrid({sgui = mainGui, levelConfig = levelConfig})
end

return module

