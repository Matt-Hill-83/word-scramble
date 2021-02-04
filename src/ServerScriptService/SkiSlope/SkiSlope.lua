local Sss = game:GetService("ServerScriptService")
local CS = game:GetService("CollectionService")
local LetterUtils = require(Sss.Source.Utils.U004LetterUtils)
local LetterGrabber = require(Sss.Source.LetterGrabber.LetterGrabber)
local StrayLetterBlocks =
    require(Sss.Source.StrayLetterBlocks.StrayLetterBlocks)
local LetterUtils = require(Sss.Source.Utils.U004LetterUtils)

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
-- local Constants = require(Sss.Source.Constants.Constants)
local Const4 = require(Sss.Source.Constants.Const_04_Characters)

local module = {}

function module.initSlopes(props)
    local parentFolder = props.parentFolder

    local skiSlopesFolder = Utils.getFirstDescendantByName(parentFolder,
                                                           "SkiSlopes")
    local slopes = Utils.getByTagInParent(
                       {parent = skiSlopesFolder, tag = "SkiSlopeFolder"})
    for _, slope in ipairs(slopes) do

        local strayLetterBlockObjs = {}

        local strayProps = {
            parentFolder = slope,
            numBlocks = 20,
            words = {"CAT", "DOG"},
            blocks = {},
            region = slope.StrayRegion,
            onTouchBlock = function()
                -- 
            end,
            strayLetterBlockObjs = strayLetterBlockObjs

        }
        local strays = StrayLetterBlocks.initStrays(strayProps)

        print('strayLetterBlockObjs' .. ' - start');
        print(strayLetterBlockObjs);
        -- local strays = Utils.getByTagInParent(
        --                    {parent = slope, tag = "StrayLetterBLock"})

        print('strays' .. ' - start');
        print(strays);

        -- for _, stray in ipairs(strays) do
        --     LetterUtils.createPropOnLetterBlock(
        --         {
        --             letterBlock = stray,
        --             propName = LetterUtils.letterBlockPropNames.Character,
        --             initialValue = "Z",
        --             propType = "StringValue"
        --         })

        --     local function checkStray(stray2)
        --         local db = true

        --         -- Enclose this so is acts on the correct stray
        --         local function closure(otherPart)
        --             if db == true then
        --                 db = false
        --                 local humanoid =
        --                     otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
        --                 if humanoid then
        --                     if humanoid then
        --                         local strayLetter = stray2.Character.Value
        --                         print('strayLetter' .. ' - start');
        --                         print(strayLetter);
        --                     end
        --                 end
        --                 db = true
        --             end
        --         end
        --         return closure
        --     end

        --     stray.Touched:Connect(checkStray(stray))
        -- end

        local positioners = Utils.getDescendantsByName(slope,
                                                       "LetterGrabberPositioner")

        for _, positioner in ipairs(positioners) do
            local grabbersConfig = {
                word = "CAT",
                parentFolder = slope,
                positioner = positioner
            }

            LetterGrabber.initLetterGrabber(grabbersConfig)
        end
    end
end

return module

