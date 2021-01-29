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

    local speed = 10

    local conveyor = Utils.getFirstDescendantByName(sectorFolder, "Conveyor")
    local beltPlateTemplate = Utils.getFirstDescendantByName(conveyor,
                                                             "BeltPlateTemplate")

    local newBeltPlate = beltPlateTemplate:Clone()
    newBeltPlate.Parent = conveyor
    newBeltPlate.Name = 'NewBeltPlate'
    table.insert(beltPlates, newBeltPlate)
    local belt = newBeltPlate.Belt
    local glassPlate = newBeltPlate.GlassPlate

    -- Create a property in which to store the home position of each beltplate
    -- This will be incremented whenever a beltPlate hits the stop wall
    local propIndex = Instance.new("IntValue", newBeltPlate)
    propIndex.Name = "PositionIndex"
    propIndex.Value = beltPlateIndex

    belt.BeltWeld.Enabled = false
    local sizeX = numCol * rackLetterSize * letterSpacingFactor
    local sizeZ = numRow * rackLetterSize * letterSpacingFactor

    -- make belt think as a platform to stand on
    belt.Size = Vector3.new(sizeX, 1, sizeZ)
    glassPlate.Size = Vector3.new(sizeX, rackLetterSize - 1, sizeZ)
    glassPlate.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                            {
            parent = belt,
            child = glassPlate,
            offsetConfig = {
                useParentNearEdge = Vector3.new(0, -1, 0),
                useChildNearEdge = Vector3.new(0, -1, 0)
            }
        })
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
                useParentNearEdge = Vector3.new(1, -1, 1),
                useChildNearEdge = Vector3.new(1, -1, 1)
            }
        })
    letterPositioner.LPWeld.Enabled = true

    local pc = belt.PrismaticConstraint
    pc.Enabled = true
    pc.Speed = speed

    local function jumpBack(beltPlates2)
        local db = true

        -- Enclose this so is acts on the correct belt
        -- closure no longer needed
        local function closure(touched)
            if db == true then
                db = false
                if CS:hasTag(touched, "stop") then

                    --  destroy existing PlateWelds
                    for _, beltPlate in ipairs(beltPlates2) do
                        local plateWelds =
                            Utils.getDescendantsByName(beltPlate, "PlateWeld")
                        for _, weld in ipairs(plateWelds) do
                            weld:Destroy()
                        end
                    end

                    for _, beltPlate in ipairs(beltPlates2) do
                        local positionIndex = beltPlate.PositionIndex.Value
                        local incrementedPosition = positionIndex - 1
                        if incrementedPosition == #beltPlates2 + 1 then
                            incrementedPosition = 1
                        end
                        if incrementedPosition == 0 then
                            incrementedPosition = #beltPlates2
                        end

                        beltPlate.PositionIndex.Value = incrementedPosition
                        local newCFrame = beltPlateCFrames[incrementedPosition]

                        -- add adjuster, because you averrun a bit because of the 1/30 sec timestep.
                        local adjuster = 0
                        beltPlate.Belt.CFrame =
                            newCFrame + Vector3.new(0, 0, adjuster)
                    end

                    -- Weld each plate to the one after it
                    for i = 1, #beltPlates2 - 1 do
                        local weld = Instance.new("WeldConstraint")
                        weld.Name = "PlateWeld"
                        weld.Parent = beltPlates2[i].Belt
                        weld.Part0 = beltPlates2[i].Belt
                        weld.Part1 = beltPlates2[i + 1].Belt
                    end
                end
                db = true
            end
        end
        return closure
    end
    belt.Touched:Connect(jumpBack(beltPlates))

end

local function initConveyors(miniGameState)
    local sectorFolder = miniGameState.sectorFolder
    local beltPlateCFrames = miniGameState.beltPlateCFrames
    local rackLetterSize = miniGameState.rackLetterSize
    local letterSpacingFactor = miniGameState.letterSpacingFactor
    local beltPlateSpacing = miniGameState.beltPlateSpacing
    local numRow = miniGameState.numRow
    local numCol = miniGameState.numCol

    local initComplete = false

    local conveyor = Utils.getFirstDescendantByName(sectorFolder, "Conveyor")
    local floor = Utils.getFirstDescendantByName(conveyor, "Floor")
    local numBelts = miniGameState.numBelts
    local glassTop = Utils.getFirstDescendantByName(conveyor, "GlassTop")
    local stopPlate = Utils.getFirstDescendantByName(conveyor, "Stop")
    local topFront = Utils.getFirstDescendantByName(conveyor, "TopFront")
    local topBack = Utils.getFirstDescendantByName(conveyor, "TopBack")
    local sidePanel = Utils.getFirstDescendantByName(conveyor, "SidePanel")

    local boxHeight = rackLetterSize + 1
    local boxPaddingx2 = 2

    local function createDummy()
        local sizeX = numCol * rackLetterSize * letterSpacingFactor
        local sizeZ = numRow * rackLetterSize * letterSpacingFactor

        local dummy = Instance.new("Part", sectorFolder)
        dummy.Size = Vector3.new(sizeX, 1, sizeZ)
        dummy.Anchored = false
        return dummy
    end

    local function setFloor(dummy)
        local paddedDummyLength = (dummy.Size.X + beltPlateSpacing)
        local adders = paddedDummyLength * 1 + boxPaddingx2
        local totalLength = paddedDummyLength * numBelts + adders
        floor.Size = Vector3.new(totalLength, 1, dummy.Size.Z + boxPaddingx2)
        return floor
    end

    local function setStop(stopPlate2, dummy, floor2)
        stopPlate2.Size = Vector3.new(stopPlate2.Size.X, stopPlate2.Size.Y,
                                      dummy.Size.Z)

        local stopPlateWelds = Utils.disableEnabledWelds(stopPlate2)
        local floorWelds = Utils.disableEnabledWelds(floor2)
        stopPlate2.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                                {
                parent = floor2,
                child = stopPlate2,
                offsetConfig = {
                    useParentNearEdge = Vector3.new(1, 1, 0),
                    useChildNearEdge = Vector3.new(1, -1, 0),
                    offsetAdder = Vector3.new(0, 0, 0)
                }
            })
        for _, weld in ipairs(stopPlateWelds) do weld.Enabled = true end
        for _, weld in ipairs(floorWelds) do weld.Enabled = true end
        return stopPlate2
    end

    local function setTopFront(topFront2, dummy, floor2)
        topFront2.Size = Vector3.new(dummy.Size.X + 6, 1, floor2.Size.Z)

        local childWelds = Utils.disableEnabledWelds(topFront2)
        local parentWelds = Utils.disableEnabledWelds(floor2)
        topFront2.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                               {
                parent = floor2,
                child = topFront2,
                offsetConfig = {
                    useParentNearEdge = Vector3.new(1, 1, 0),
                    useChildNearEdge = Vector3.new(1, -1, 0),
                    offsetAdder = Vector3.new(0, boxHeight, 0)
                }
            })
        for _, weld in ipairs(childWelds) do weld.Enabled = true end
        for _, weld in ipairs(parentWelds) do weld.Enabled = true end
        return topFront2
    end

    local function setTopBack(child, dummy, floor2)
        child.Size = Vector3.new(dummy.Size.X + 6, 1, floor2.Size.Z)

        local childWelds = Utils.disableEnabledWelds(child)
        local parentWelds = Utils.disableEnabledWelds(floor2)
        child.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                           {
                parent = floor2,
                child = child,
                offsetConfig = {
                    useParentNearEdge = Vector3.new(-1, 1, 0),
                    useChildNearEdge = Vector3.new(-1, -1, 0),
                    offsetAdder = Vector3.new(0, boxHeight, 0)
                }
            })
        for _, weld in ipairs(childWelds) do weld.Enabled = true end
        for _, weld in ipairs(parentWelds) do weld.Enabled = true end
        return child
    end

    local function setSidePanels(child, dummy, floor2)
        child.Size = Vector3.new(dummy.Size.X + 6, boxHeight, floor2.Size.Z)

        local childWelds = Utils.disableEnabledWelds(child)
        local parentWelds = Utils.disableEnabledWelds(floor2)
        child.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                           {
                parent = floor2,
                child = child,
                offsetConfig = {
                    useParentNearEdge = Vector3.new(-1, 1, 1),
                    useChildNearEdge = Vector3.new(-1, -1, 1),
                    offsetAdder = Vector3.new(0, 0, 0)
                }
            })
        for _, weld in ipairs(childWelds) do weld.Enabled = true end
        for _, weld in ipairs(parentWelds) do weld.Enabled = true end
        return child
    end

    local function config()
        local dummy = createDummy()
        local floor2 = setFloor(dummy)
        local stopPlate2 = setStop(stopPlate, dummy, floor2)
        setTopFront(topFront, dummy, floor2)
        setTopBack(topBack, dummy, floor2)
        setSidePanels(sidePanel, dummy, floor2)

        for beltPlateIndex = 1, numBelts do
            local offset = Vector3.new(-(dummy.Size.X + beltPlateSpacing) *
                                           (beltPlateIndex - 0), 0, 0)

            local beltPlateCframe = Utils3.setCFrameFromDesiredEdgeOffset(
                                        {
                    parent = stopPlate2,
                    child = dummy,
                    offsetConfig = {
                        useParentNearEdge = Vector3.new(-1, 0, 0),
                        useChildNearEdge = Vector3.new(1, 0, 0),
                        offsetAdder = offset
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
        dummy:Destroy()

    end
    config()

    local function start(otherPart)
        if initComplete == false then
            local humanoid = otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
            if humanoid then
                initComplete = true
                local beltPlates = Utils.getDescendantsByName(conveyor,
                                                              "NewBeltPlate")
                for _, beltPlate in ipairs(beltPlates) do
                    local belt = beltPlate.Belt
                    belt.BeltWeld.Enabled = false
                end

                local player = Utils.getPlayerFromHumanoid(humanoid)
                Utils.destroyTools(player, "key%-%-")
            end
        end
    end
    glassTop.Touched:Connect(start)
end

module.initConveyors = initConveyors
return module
