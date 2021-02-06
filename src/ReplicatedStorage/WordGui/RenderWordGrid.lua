local RS = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

local Utils = require(RS.Source.Utils.RSU001GeneralUtils)

-- keep this
-- keep this
-- keep this
-- local LetterUtils = require(Sss.Source.Utils.U004LetterUtils)

local module = {}

local renderGrid = function(props)
    local levelConfig = props.levelConfig
    local sgui = props.sgui
    local targetWords = levelConfig.targetWords

    local mainGui = sgui:WaitForChild("MainGui")
    local mainFrame = Utils.getFirstDescendantByName(mainGui, "MainFrame")

    -- Size up the mainFrame temporarily to get the viewport size
    local viewPortSize = mainGui.AbsoluteSize
    print('viewPortSize' .. ' - start');
    print(viewPortSize);
    print('workspace.CurrentCamera.ViewportSize' .. ' - start');
    print(workspace.CurrentCamera.ViewportSize);

    local parentWidth = viewPortSize.X
    local parentHeight = viewPortSize.Y
    local rowHeight = parentHeight / 10

    mainFrame.Size = UDim2.new(0.5, 0, 1, 0)

    local rowGap = 10
    local paddingInPx = 5
    local fontHeight = 55
    fontHeight = math.floor(fontHeight)

    local scrollingFrame = Utils.getFirstDescendantByName(sgui, "WordScroller")
    local dialogScrollerPadding = Utils.getFirstDescendantByName(scrollingFrame,
                                                                 "DialogScrollerPadding")

    local scrollBarThickness = 30
    scrollingFrame.ScrollBarThickness = scrollBarThickness
    -- scrollingFrame.CanvasSize = UDim2.new(0, 0, 20, 0)
    scrollingFrame.Size = UDim2.new(1, 0, 3, 0)

    local padding = 24
    dialogScrollerPadding.PaddingBottom = UDim.new(0, padding)
    dialogScrollerPadding.PaddingTop = UDim.new(0, padding)
    dialogScrollerPadding.PaddingLeft = UDim.new(0, padding)
    dialogScrollerPadding.PaddingRight =
        UDim.new(0, scrollBarThickness + fontHeight)

    -- local children = scrollingFrame:GetChildren()
    -- for i, item in pairs(children) do
    --     if item:IsA('TextLabel') then item:Destroy() end
    -- end

    local rowTemplate = Utils.getFirstDescendantByName(sgui, "RowTemplate")

    for wordIndex, word in ipairs(targetWords) do
        print('wordIndex' .. ' - start');
        print(wordIndex);
        local newRow = rowTemplate:Clone()
        newRow.Parent = rowTemplate.Parent
        newRow.Name = rowTemplate.Name .. "--row--ooo--" .. wordIndex

        newRow.Size = UDim2.new(1, 0, 0, rowHeight)

        local rowOffsetY = (wordIndex - 1) * (rowHeight + 2 * paddingInPx)
        newRow.Position = UDim2.new(0, 0, 0, rowOffsetY)

        local imageLabelTemplate = Utils.getFirstDescendantByName(newRow,
                                                                  "BlockChar")
        local dummyBlock = Instance.new("Part")

        local width = 100
        for letterIndex = 1, #word do
            local letterNameStub = word .. "-L" .. letterIndex
            local char = string.sub(word, letterIndex, letterIndex)

            local newImageLabel = imageLabelTemplate:Clone()
            newImageLabel.Parent = dummyBlock

            newImageLabel.Name = "wordLetter-" .. letterNameStub
            newImageLabel.Size = UDim2.new(0.5, 0, 0.5, 0)
            -- newImageLabel.Size = UDim2.new(1, 0, 0, height + 2 * paddingInPx)
            -- local absoluteHeight = newImageLabel.AbsoluteSize.Y
            newImageLabel.Position = UDim2.new(0, (letterIndex - 1) * width, 0,
                                               0)

            -- local letterPositionZ = newLetter.Size.Z * (letterIndex - 2) *
            --                             spacingFactorZ

            -- keepp this
            -- keepp this
            -- keepp this
            -- LetterUtils.applyLetterText({letterBlock = dummyBlock, char = char})

            -- Do this last to avoid tweening
            newImageLabel.Parent = newRow

        end
        imageLabelTemplate:Destroy()
        dummyBlock:Destroy()

        -- if (dialogText ~= "blank") then

        -- local font = Enum.Font.Arial
        -- local innerLabelWidth = parentWidth - (2 * paddingInPx) -
        --                             scrollBarThickness

        -- local calcSize = TextService:GetTextSize(text, fontHeight, font,
        --                                          Vector2.new(
        --                                              innerLabelWidth,
        --                                              parentHeight))

        -- local height = calcSize.Y

        -- local outerLabel = Instance.new("TextLabel", scrollingFrame)
        -- local outerLabelProps = {
        --     Name = "Dialog-" .. i,
        --     Position = UDim2.new(0, 0, 0, dialogY),
        --     Size = UDim2.new(1, 0, 0, height + 2 * paddingInPx),

        --     Text = "",
        --     Font = font,
        --     TextSize = fontHeight,
        --     TextWrapped = true,
        --     -- TextScaled = true,
        --     TextXAlignment = Enum.TextXAlignment.Left,
        --     TextYAlignment = Enum.TextYAlignment.Top,
        --     BorderColor3 = Color3.fromRGB(99, 46, 99),
        --     BorderSizePixel = 2,
        --     BackgroundColor3 = backgroundColor,
        --     TextColor3 = Color3.new(0, 0, 0),
        --     ZIndex = 1
        -- }
        -- Utils.mergeTables(outerLabel, outerLabelProps)

        -- local absoluteHeight = newImageLabel.AbsoluteSize.Y
        -- dialogY = dialogY + (absoluteHeight + rowGap)
        -- end
    end
    rowTemplate:Destroy()
end

module.renderGrid = renderGrid
return module
