local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
local Constants = require(Sss.Source.Constants.Constants)

local module = {}

renderQuestBlock = function(props)
    local parent = props.parent
    local questBlockTemplate = props.questBlockTemplate
    local gridSize = props.gridSize
    local gridPadding = props.gridPadding

    local x = gridSize.cols * Constants.totalIslandLength + gridPadding -
                  Constants.bridgeLength
    local z = gridSize.rows * Constants.totalIslandLength + gridPadding -
                  Constants.bridgeLength

    local size = Vector3.new(x, 2, z)

    local dockBase = Utils.getFirstDescendantByName(questBlockTemplate,
                                                    "DockBase")

    local dockPositioner = Instance.new("Part", parent)
    dockPositioner.Size = size

    local translateCFrameProps = {
        parent = parent,
        child = dockPositioner,
        offsetConfig = {
            useParentNearEdge = Vector3.new(1, -1, -1),
            useChildNearEdge = Vector3.new(-1, -1, -1),
            offsetAdder = Vector3.new(0, 0, -5)
        }
    }

    local newCFrame =
        Utils3.setCFrameFromDesiredEdgeOffset(translateCFrameProps)
    dockPositioner.CFrame = newCFrame

    dockBase.Size = dockPositioner.Size
    dockBase.CFrame = dockPositioner.CFrame

    dockPositioner:Destroy()
    return questBlockTemplate
end

module.renderQuestBlock = renderQuestBlock
return module
