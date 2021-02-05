local TextService = game:GetService("TextService")
local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Const2 = require(Sss.Source.Constants.Const_02_Colors)
local Const4 = require(Sss.Source.Constants.Const_04_Characters)

local dialogColors = Const2.dialogColors

local module = {}

local renderGrid = function(props)
    local sgui = props.sgui

    local levelConfig = props.levelConfig
    local targetWords = levelConfig.targetWords
    local charName = "test"

    print('targetWords' .. ' - start');
    print('targetWords' .. ' - start');
    print('targetWords' .. ' - start');
    print('targetWords' .. ' - start');
    print('targetWords' .. ' - start');
    print('targetWords' .. ' - start');
    print('targetWords' .. ' - start');
    print(targetWords);

    local viewPortSize = sgui.AbsoluteSize

    local rowGap = 10
    local paddingInPx = 5
    local fontHeight = 55
    fontHeight = math.floor(fontHeight)

    local scrollingFrame = Utils.getFirstDescendantByName(sgui, "WordScroller")
    local dialogScrollerPadding = Utils.getFirstDescendantByName(scrollingFrame,
                                                                 "DialogScrollerPadding")

    local scrollBarThickness = 2 * fontHeight
    scrollingFrame.ScrollBarThickness = scrollBarThickness
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 20, 0)

    local padding = fontHeight / 2
    dialogScrollerPadding.PaddingBottom = UDim.new(0, padding)
    dialogScrollerPadding.PaddingTop = UDim.new(0, padding)
    dialogScrollerPadding.PaddingLeft = UDim.new(0, padding)
    dialogScrollerPadding.PaddingRight =
        UDim.new(0, scrollBarThickness + fontHeight)

    local children = scrollingFrame:GetChildren()
    for i, item in pairs(children) do
        if item:IsA('TextLabel') then item:Destroy() end
    end

    local parentWidth = viewPortSize.X * 0.4 - (2 * paddingInPx)
    -- parentHeight is only used for the initial calc to determine the box size
    local parentHeight = viewPortSize.Y / 2

    local dialogY = 0
    for i, dialog in ipairs(targetWords) do

        -- local charName = line['char']
        local dialogText = dialog

        local backgroundColor = dialogColors[4]
        local charConfig = Const4.characters[charName]
        local displayName = Utils.getDisplayNameFromName({name = charName})

        if charConfig then
            backgroundColor = dialogColors[charConfig.backgroundColorIdx]
        end

        if (dialogText ~= "blank") then
            local text = "<b>" .. displayName .. ": " .. "</b>" .. dialogText

            local font = Enum.Font.Arial
            local innerLabelWidth = parentWidth - (2 * paddingInPx) -
                                        scrollBarThickness

            local calcSize = TextService:GetTextSize(text, fontHeight, font,
                                                     Vector2.new(
                                                         innerLabelWidth,
                                                         parentHeight))

            local height = calcSize.Y

            local outerLabel = Instance.new("TextLabel", scrollingFrame)
            local outerLabelProps = {
                Name = "Dialog-" .. i .. "dddd",
                Position = UDim2.new(0, 0, 0, dialogY),
                Size = UDim2.new(1, 0, 0, height + 2 * paddingInPx),

                Text = "",
                Font = font,
                TextSize = fontHeight,
                TextWrapped = true,
                -- TextScaled = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                BorderColor3 = Color3.fromRGB(99, 46, 99),
                BorderSizePixel = 2,
                BackgroundColor3 = backgroundColor,
                TextColor3 = Color3.new(0, 0, 0),
                ZIndex = 1
            }
            Utils.mergeTables(outerLabel, outerLabelProps)

            local absoluteHeight = outerLabel.AbsoluteSize.Y
            dialogY = dialogY + (absoluteHeight + rowGap)
        end
    end
end

module.renderGrid = renderGrid
return module
