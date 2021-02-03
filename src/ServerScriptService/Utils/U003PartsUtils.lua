local TweenService = game:GetService("TweenService")
local Sss = game:GetService("ServerScriptService")

local Constants = require(Sss.Source.Constants.Constants)
local module = {}

function tween(props)
    local part = props.part
    local time = props.time
    local repeatCount = props.repeatCount or 0
    local delayTime = props.delayTime or 0
    local endPosition = props.endPosition
    local reverses = props.reverses or false
    local easingStyle = props.easingStyle or Enum.EasingStyle.Linear
    local easingDirection = props.easingDirection or Enum.EasingDirection.Out
    local anchor = props.anchor or false

    local tweenInfo = TweenInfo.new(time, easingStyle, easingDirection,
                                    repeatCount, reverses, delayTime)

    local tween = TweenService:Create(part, tweenInfo, {Position = endPosition})

    tween:Play()
    part.Anchored = anchor
    part.CanCollide = false
    tween.Completed:Wait()
    return tween
end

-- function getPartFarEdge(props)
--     local part = props.part
--     return part.Position + (part.Size / 2) * props.alignToParentFarEdge
-- end

function setCFrameFromDesiredEdgeOffset(props)
    local parent = props.parent
    local child = props.child
    local offsetConfig = props.offsetConfig

    local defaultOffsetAdder = Vector3.new(0, 0, 0)

    local defaultOffsetConfig = {
        useParentNearEdge = Vector3.new(0, 1, -1),
        useChildNearEdge = Vector3.new(0, -1, 1),
        offsetAdder = defaultOffsetAdder
    }

    offsetConfig = offsetConfig or defaultOffsetConfig

    local offset = (offsetConfig.useParentNearEdge * parent.Size -
                       offsetConfig.useChildNearEdge * child.Size) / 2 +
                       (offsetConfig.offsetAdder or defaultOffsetAdder)

    local newCFrame = CFrame.new(offset)
    return parent.CFrame:ToWorldSpace(newCFrame)
end

-- module.getPartFarEdge = getPartFarEdge
module.setCFrameFromDesiredEdgeOffset = setCFrameFromDesiredEdgeOffset
module.tween = tween
return module
