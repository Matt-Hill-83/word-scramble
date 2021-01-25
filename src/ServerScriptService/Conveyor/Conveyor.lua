local Sss = game:GetService("ServerScriptService")
local CS = game:GetService("CollectionService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local module = {}

local function initConveyor(miniGameState)
    local sectorFolder = miniGameState.sectorFolder
    local initComplete = false

    local conveyor = Utils.getFirstDescendantByName(sectorFolder, "Conveyor")
    local beltTemplate =
        Utils.getFirstDescendantByName(conveyor, "BeltTemplate")
    local glassTop = Utils.getFirstDescendantByName(conveyor, "GlassTop")
    local beltWeld = Utils.getFirstDescendantByName(conveyor, "BeltWeld")

    print(beltTemplate);
    local part = beltTemplate

    local function start(otherPart)
        if initComplete == false then
            local humanoid = otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
            if humanoid then
                initComplete = true
                beltWeld.Enabled = false

                local initialCFrame = part.CFrame

                local bv = part.BodyVelocity
                bv.Velocity = Vector3.new(28, 0, 0)

                local bargeWeld = part.Parent.MyWeld
                print('init complete');

                local db = true
                local function jumpBack(touched)
                    if db == true then
                        db = false

                        if CS:hasTag(touched, "stop") then
                            print("move")
                            bargeWeld.Enabled = false
                            part.CFrame = initialCFrame
                            bargeWeld.Enabled = true
                        end
                        db = true
                    end

                end
                part.Touched:Connect(jumpBack)
            end
        end
    end

    glassTop.Touched:Connect(start)
end

module.initConveyor = initConveyor
return module
