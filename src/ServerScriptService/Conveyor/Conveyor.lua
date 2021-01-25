local Sss = game:GetService("ServerScriptService")
local CS = game:GetService("CollectionService")
local PlayerStatManager = require(Sss.Source.AddRemoteObjects.PlayerStatManager)

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)

local LetterFallUtils = require(Sss.Source.LetterFall.LetterFallUtils)

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
    -- if not letterPositioner then return end

    -- 
    -- 
    -- 
    local part = beltTemplate

    local function start(otherPart)
        if initComplete == false then
            local humanoid = otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
            if humanoid then
                initComplete = true
                beltWeld.Enabled = false
                -- local player = Utils.getPlayerFromHumanoid(humanoid)
                -- local gameState = PlayerStatManager.getGameState(player)

                local initialCFrame = part.CFrame

                local bv = part.BodyVelocity
                bv.Velocity = Vector3.new(28, 0, 0)

                local bargeWeld = part.Parent.MyWeld
                print('init complete');
                print('init complete');
                print('init complete');

                local db = true
                local function jumpBack(touched)
                    if db == true then
                        db = false

                        if CS:hasTag(touched, "stop") then
                            bargeWeld.Enabled = false

                            print("move")
                            print("move")
                            print("move")
                            print("move")
                            print("move")
                            print("move")
                            part.CFrame = initialCFrame
                            bargeWeld.Enabled = true
                        end
                        db = true
                    end

                end
                part.Touched:Connect(jumpBack)
            end
        end

        print("Hello world!")

    end

    glassTop.Touched:Connect(start)
    -- 
    -- 
end

module.initConveyor = initConveyor
return module
