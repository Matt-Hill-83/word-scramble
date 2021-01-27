local Sss = game:GetService("ServerScriptService")
local CS = game:GetService("CollectionService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)

local module = {}

local function initbeltPlate(props)

    local beltPlateIndex = props.beltPlateIndex
    local miniGameState = props.miniGameState

    local numRow = miniGameState.numRow
    local numCol = miniGameState.numCol
    local letterSpacingFactor = miniGameState.letterSpacingFactor
    local rackLetterSize = miniGameState.rackLetterSize
    local sectorFolder = miniGameState.sectorFolder

    local conveyor = Utils.getFirstDescendantByName(sectorFolder, "Conveyor")
    local stopPlate = Utils.getFirstDescendantByName(conveyor, "Stop")
    local beltPlateTemplate = Utils.getFirstDescendantByName(conveyor,
                                                             "BeltPlateTemplate")

    local newBeltPlate = beltPlateTemplate:Clone()
    newBeltPlate.Parent = conveyor
    newBeltPlate.Name = 'NewBeltPlate'
    local belt = newBeltPlate.Belt

    belt.BeltWeld.Enabled = false
    local sizeX = numCol * rackLetterSize * letterSpacingFactor
    local sizeZ = numRow * rackLetterSize * letterSpacingFactor
    belt.Size = Vector3.new(sizeX, 1, sizeZ)

    local position = Vector3.new(-belt.Size.X * beltPlateIndex * 1.05, 0, 0)

    belt.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                      {
            parent = stopPlate,
            child = belt,
            offsetConfig = {
                useParentNearEdge = Vector3.new(-1, -1, 0),
                useChildNearEdge = Vector3.new(1, -1, 0),
                offsetAdder = position
            }
        })

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
                    belt2.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                                       {
                            parent = touched,
                            child = belt2,
                            offsetConfig = {
                                useParentNearEdge = Vector3.new(-1, -1, 0),
                                useChildNearEdge = Vector3.new(1, -1, 0),
                                offsetAdder = Vector3.new(
                                    -belt2.Size.X * miniGameState.numBelts *
                                        1.05, 0, 0)
                            }
                        })
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
    local initComplete = false

    local conveyor = Utils.getFirstDescendantByName(sectorFolder, "Conveyor")
    local numBelts = miniGameState.numBelts
    local glassTop = Utils.getFirstDescendantByName(conveyor, "GlassTop")

    local function config()
        for beltPlateIndex = 1, numBelts do
            local beltPlateProps = {
                beltPlateIndex = beltPlateIndex,
                miniGameState = miniGameState
            }
            initbeltPlate(beltPlateProps)
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
