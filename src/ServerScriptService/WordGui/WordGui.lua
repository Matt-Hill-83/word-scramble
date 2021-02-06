local Sss = game:GetService("ServerScriptService")
local starterGui = game:GetService("StarterGui")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local RenderWordGrid = require(Sss.Source.WordGui.RenderWordGrid)
local module = {}

function module.initWordGui(props)
    print('initWordGui' .. ' - start');
    print('initWordGui' .. ' - start');
    print('initWordGui' .. ' - start');
    local levelConfig = props.levelConfig
    local mainGui = Utils.getFirstDescendantByName(starterGui, "MainGui")
    RenderWordGrid.renderGrid({sgui = mainGui, levelConfig = levelConfig})
end

return module

