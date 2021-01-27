local Sss = game:GetService("ServerScriptService")
local CS = game:GetService("CollectionService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)

local module = {}

local function initbeltPlate(props)
    local numBelts = props.numBelts
    local beltPlateIndex = props.beltPlateIndex
    local sectorFolder = props.sectorFolder
    local beltPlateTemplate = props.beltPlateTemplate

    local conveyor = Utils.getFirstDescendantByName(sectorFolder, "Conveyor")
    local stopPlate = Utils.getFirstDescendantByName(conveyor, "Stop")

    local newBeltPlate = beltPlateTemplate:Clone()
    newBeltPlate.Parent = conveyor
    newBeltPlate.Name = 'NewBeltPlate'

    local belt = newBeltPlate.Belt
    belt.BeltWeld.Enabled = false

    local positions = {
        Vector3.new(0, 0, 0), --
        Vector3.new(-belt.Size.X * beltPlateIndex * 1.05, 0, 0) --
    }

    belt.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                      {
            parent = stopPlate,
            child = belt,
            offsetConfig = {
                useParentNearEdge = Vector3.new(1, -1, 0),
                useChildNearEdge = Vector3.new(-1, 1, 0),
                offsetAdder = positions[beltPlateIndex]
            }
        })

    -- belt.CFrame = stopPlate.CFrame + positions[beltPlateIndex]
    belt.BeltWeld.Enabled = true

    local pc = belt.PrismaticConstraint
    pc.Enabled = true

    local db = true
    local function jumpBack(touched)
        if db == true then
            db = false

            -- In this function, I should reset the position of each belt plate, by assigning it a position index
            -- and then use modulus?
            if CS:hasTag(touched, "stop") then
                belt.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                                  {
                        parent = touched,
                        child = belt,
                        offsetConfig = {
                            useParentNearEdge = Vector3.new(1, 0, 0),
                            useChildNearEdge = Vector3.new(1, 0, 0),
                            offsetAdder = Vector3.new(
                                -belt.Size.X * numBelts * 1.05, 0, 0)
                        }
                    })
            end
            db = true
        end

    end
    belt.Touched:Connect(jumpBack)

end

local function initConveyors(miniGameState)
    local sectorFolder = miniGameState.sectorFolder
    local initComplete = false

    local conveyor = Utils.getFirstDescendantByName(sectorFolder, "Conveyor")

    local numBelts = 2
    -- local numBelts = #beltTemplates
    local glassTop = Utils.getFirstDescendantByName(conveyor, "GlassTop")

    local beltPlateTemplate = Utils.getFirstDescendantByName(conveyor,
                                                             "BeltPlateTemplate")

    local function config()
        for beltPlateIndex = 1, numBelts do
            local beltPlateProps = {
                numBelts = numBelts,
                beltPlateIndex = beltPlateIndex,
                sectorFolder = sectorFolder,
                beltPlateTemplate = beltPlateTemplate
            }
            module.initbeltPlate(beltPlateProps)
        end
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
                print('beltPlates' .. ' - start');
                print(beltPlates);
                -- Populate each belt plate with a complete grid with all words
                for plateIndex, beltPlate in ipairs(beltPlates) do

                    local belt = beltPlate.Belt
                    belt.BeltWeld.Enabled = false

                end
                beltPlateTemplate:Destroy()
            end
        end
    end

    glassTop.Touched:Connect(start)
end

module.initConveyors = initConveyors
module.initbeltPlate = initbeltPlate
return module
