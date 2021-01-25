local Sss = game:GetService("ServerScriptService")
local CS = game:GetService("CollectionService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)

local module = {}

local function initConveyor(beltTemplate)
    print('initConveyor');
    beltTemplate.BeltWeld.Enabled = false

    local pc = beltTemplate.PrismaticConstraint
    pc.Enabled = true

    print('init complete');

    local db = true
    local function jumpBack(touched)
        if db == true then
            db = false

            if CS:hasTag(touched, "stop") then
                print("move")
                beltTemplate.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                                          {
                        parent = touched,
                        child = beltTemplate,
                        offsetConfig = {
                            useParentNearEdge = Vector3.new(1, 0, 0),
                            useChildNearEdge = Vector3.new(1, 0, 0),
                            offsetAdder = Vector3.new(
                                -beltTemplate.Size.X * 2.1, 0, 0)
                        }
                    })
            end
            db = true
        end

    end
    beltTemplate.Touched:Connect(jumpBack)
end

local function initConveyors(miniGameState)
    local sectorFolder = miniGameState.sectorFolder
    local initComplete = false

    local conveyor = Utils.getFirstDescendantByName(sectorFolder, "Conveyor")
    local beltTemplates = Utils.getDescendantsByName(conveyor, "BeltTemplate")
    local glassTop = Utils.getFirstDescendantByName(conveyor, "GlassTop")

    local function start(otherPart)
        if initComplete == false then
            local humanoid = otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
            if humanoid then
                initComplete = true
                for beltIndex, beltTemplate in ipairs(beltTemplates) do
                    local propIndex = Instance.new("StringValue", beltTemplate)
                    propIndex.Value = beltIndex
                    propIndex.Name = "Index"
                end
                for _, beltTemplate in ipairs(beltTemplates) do
                    module.initConveyor(beltTemplate, conveyor)
                end
            end
        end
    end

    glassTop.Touched:Connect(start)
end

module.initConveyors = initConveyors
module.initConveyor = initConveyor
return module
