local Sss = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local starterGui = game:GetService("StarterGui")

local RenderWordGrid = script.Parent.RenderWordGrid
local Utils = require(RS.Source.Utils.RSU001GeneralUtils)

-- local RenderWordGrid = require(Sss.Source.WordGui.RenderWordGrid)
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

