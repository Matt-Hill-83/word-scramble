local Sss = game:GetService("ServerScriptService")
local CS = game:GetService("CollectionService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)

local module = {}

local function initBeltPlate(props)
    local beltPlateIndex = props.beltPlateIndex
    local miniGameState = props.miniGameState

    local numRow = miniGameState.numRow
    local numCol = miniGameState.numCol
    local letterSpacingFactor = miniGameState.letterSpacingFactor
    local rackLetterSize = miniGameState.rackLetterSize
    local sectorFolder = miniGameState.sectorFolder
    local beltPlateCFrames = miniGameState.beltPlateCFrames
    local beltPlates = miniGameState.beltPlates

    local conveyor = Utils.getFirstDescendantByName(sectorFolder, "Conveyor")
    -- local stopPlate = Utils.getFirstDescendantByName(conveyor, "Stop")
    local beltPlateTemplate = Utils.getFirstDescendantByName(conveyor,
                                                             "BeltPlateTemplate")

    local newBeltPlate = beltPlateTemplate:Clone()
    newBeltPlate.Parent = conveyor
    newBeltPlate.Name = 'NewBeltPlate'
    table.insert(beltPlates, newBeltPlate)
    local belt = newBeltPlate.Belt

    -- Create a property in which to store the home position of each beltplate
    -- This will be incremented whenever a beltPlate hits the stop wall
    local propIndex = Instance.new("IntValue", newBeltPlate)
    propIndex.Name = "PositionIndex"
    propIndex.Value = beltPlateIndex

    belt.BeltWeld.Enabled = false
    local sizeX = numCol * rackLetterSize * letterSpacingFactor
    local sizeZ = numRow * rackLetterSize * letterSpacingFactor
    belt.Size = Vector3.new(sizeX, 1, sizeZ)
    belt.CFrame = beltPlateCFrames[beltPlateIndex]

    belt.BeltWeld.Enabled = true

    local letterPositioner = Utils.getFirstDescendantByName(newBeltPlate,
                                                            "LetterPositioner")
    letterPositioner.LPWeld.Enabled = false
    letterPositioner.Size = Vector3.new(rackLetterSize, rackLetterSize,
                                        rackLetterSize)

    letterPositioner.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                                  {
            parent = belt,
            child = letterPositioner,
            offsetConfig = {
                useParentNearEdge = Vector3.new(1, 1, 1),
                useChildNearEdge = Vector3.new(1, -1, 1)
            }
        })
    letterPositioner.LPWeld.Enabled = true

    local pc = belt.PrismaticConstraint
    pc.Enabled = true
    pc.Speed = 30

    local function jumpBack(belt2)
        local db = true

        -- Enclose this so is acts on the correct belt
        local function closure(touched)
            if db == true then
                db = false

                -- In this function, I should reset the position of each belt2 plate, by assigning it a position index
                -- and then use modulus?
                if CS:hasTag(touched, "stop") then

                    local beltPlateCFrames2 = miniGameState.beltPlateCFrames
                    local beltPlates2 = miniGameState.beltPlates

                    for _, beltPlate in ipairs(beltPlates2) do
                        local positionIndex = beltPlate.PositionIndex.Value
                        local incrementedPosition = positionIndex - 1
                        local index = positionIndex

                        if incrementedPosition == #beltPlates2 + 1 then
                            incrementedPosition = 1
                        end

                        if incrementedPosition == 0 then
                            incrementedPosition = #beltPlates2
                        end

                        print('index' .. ' - start');
                        print(index);
                        beltPlate.PositionIndex.Value = incrementedPosition
                        print('positionIndex' .. ' - start');
                        print(positionIndex);

                        local newCFrame = beltPlateCFrames2[incrementedPosition]

                        beltPlate.Belt.CFrame = newCFrame
                    end
                end
                db = true
            end

        end
        return closure
    end
    belt.Touched:Connect(jumpBack(belt))

end

local function initConveyors(miniGameState)
    local sectorFolder = miniGameState.sectorFolder
    local beltPlateCFrames = miniGameState.beltPlateCFrames
    local rackLetterSize = miniGameState.rackLetterSize
    local letterSpacingFactor = miniGameState.letterSpacingFactor
    local initComplete = false

    local conveyor = Utils.getFirstDescendantByName(sectorFolder, "Conveyor")
    local numBelts = miniGameState.numBelts
    local glassTop = Utils.getFirstDescendantByName(conveyor, "GlassTop")

    local stopPlate = Utils.getFirstDescendantByName(conveyor, "Stop")

    local function config()
        for beltPlateIndex = 1, numBelts do
            local numRow = miniGameState.numRow
            local numCol = miniGameState.numCol
            local sizeX = numCol * rackLetterSize * letterSpacingFactor
            local sizeZ = numRow * rackLetterSize * letterSpacingFactor

            local dummy = Instance.new("Part")
            dummy.Size = Vector3.new(sizeX, 1, sizeZ)
            local position = Vector3.new(-dummy.Size.X * beltPlateIndex * 1.05,
                                         0, 0)

            local beltPlateCframe = Utils3.setCFrameFromDesiredEdgeOffset(
                                        {
                    parent = stopPlate,
                    child = dummy,
                    offsetConfig = {
                        useParentNearEdge = Vector3.new(-1, -1, 0),
                        useChildNearEdge = Vector3.new(1, -1, 0),
                        offsetAdder = position
                    }
                })
            table.insert(beltPlateCFrames, beltPlateCframe)
        end

        for beltPlateIndex = 1, numBelts do
            local beltPlateProps = {
                beltPlateIndex = beltPlateIndex,
                miniGameState = miniGameState
            }
            initBeltPlate(beltPlateProps)
        end

        local beltPlateTemplate = Utils.getFirstDescendantByName(conveyor,
                                                                 "BeltPlateTemplate")
        beltPlateTemplate:Destroy()
    end
    config()

    local function start(otherPart)
        if initComplete == false then
            local humanoid = otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
            if humanoid then
                initComplete = true
                -- for beltIndex, belt in ipairs(beltTemplates) do
                --     local propIndex = Instance.new("StringValue", belt)
                --     propIndex.Value = beltIndex
                --     propIndex.Name = "Index"
                -- end
                local beltPlates = Utils.getDescendantsByName(conveyor,
                                                              "NewBeltPlate")

                -- Populate each belt plate with a complete grid with all words

                for _, beltPlate in ipairs(beltPlates) do
                    local belt = beltPlate.Belt
                    belt.BeltWeld.Enabled = false
                end
            end
        end
    end

    glassTop.Touched:Connect(start)
end

module.initConveyors = initConveyors
return module
