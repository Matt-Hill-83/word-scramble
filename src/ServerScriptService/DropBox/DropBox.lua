local Sss = game:GetService("ServerScriptService")
local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Constants = require(Sss.Source.Constants.Constants)

local module = {}
function module.configDropBox(props)
    local scene = props.scene
    local sceneIndex = props.sceneIndex
    local dropBox = props.dropBox
    local item = props.item
    local onCorrectItemDropped = props.onCorrectItemDropped

    local part = Utils.getFirstDescendantByName(scene, "DropBoxDetectionRegion")
    if (part) then
        local function onPartTouched(otherPart)
            local partParent = otherPart.Parent
            local match = partParent.Name == item.name
            if match then
                partParent.Parent = workspace
                onCorrectItemDropped()
            end
        end
        part.Touched:Connect(onPartTouched)

        local labels = Utils.getDescendantsByName(dropBox, "ItemLabel")
        for i, label in ipairs(labels) do label.Text = item.name end
        dropBox.Name = scene.Name .. "-local- " .. sceneIndex
    end
end

return module
