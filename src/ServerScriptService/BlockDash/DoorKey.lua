local Sss = game:GetService("ServerScriptService")
-- local CS = game:GetService("CollectionService")
-- local Players = game:GetService("Players")
local PlayerStatManager = require(Sss.Source.AddRemoteObjects.PlayerStatManager)
-- local LetterFallUtils = require(Sss.Source.LetterFall.LetterFallUtils)

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
-- local Constants = require(Sss.Source.Constants.Constants)

local Replicator = require(Sss.Source.BlockDash.Replicator)

local module = {}

local function initKey(miniGameState)
    print('miniGameState' .. ' - start');
    print(miniGameState);
    local sectorFolder = miniGameState.sectorFolder

    local positioner = Utils.getFirstDescendantByName(sectorFolder,
                                                      "KeyReplicatorPositioner")
    local template = Utils.getFromTemplates("KeyReplicatorTemplate")

    local newReplicator = template:Clone()
    local key = Utils.getFirstDescendantByName(newReplicator, "Key")
    local keyName = "key--" .. sectorFolder.Name
    key.Name = keyName
    local handle = key.Handle
    print('sectorFolder' .. ' - start');
    print(sectorFolder);
    print('key.Name' .. ' - start');
    print(key.Name);

    local propChar = Instance.new("StringValue", handle)
    propChar.Name = "DoorMatch"
    propChar.Value = sectorFolder.Name

    newReplicator.Parent = sectorFolder
    local newReplicatorPart = newReplicator.PrimaryPart

    newReplicatorPart.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                                   {
            parent = positioner,
            child = newReplicatorPart,
            offsetConfig = {
                useParentNearEdge = Vector3.new(-1, 1, -1),
                useChildNearEdge = Vector3.new(-1, -1, -1),
                offsetAdder = Vector3.new(0, 0, 0)
            }
        })

    newReplicatorPart.Anchored = true

    Replicator.init(newReplicator)

    local door = Utils.getFirstDescendantByName(sectorFolder, "LockedDoor")
                     .PrimaryPart

    print('door' .. ' - start');
    print(door);
    -- local function onTouched(obj)
    --     local player = game.Players:GetPlayerFromCharacter(obj.Parent)
    --     if obj.Parent:findFirstChild("Humanoid") ~= nil then
    --         if Players:findFirstChild(obj.Parent.Name) ~= nil then
    --             if obj.Parent:findFirstChild(script.Parent.Parent.Key.Value) ~=
    --                 nil then
    --                 if script.Parent.Parent.KeyRemove.Value == true then
    --                     obj.Parent:findFirstChild(script.Parent.Parent.Key.Value)
    --                         :remove()
    --                 end
    --                 script.Parent.Transparency = 0.8
    --                 script.Parent.CanCollide = false
    --                 wait(3)
    --                 script.Parent.Transparency = 0
    --                 script.Parent.CanCollide = true
    --             end
    --         end
    --     end
    -- end

    local function onTouchDoor(otherPart)
        print('onTouchEntrance' .. ' - start');
        local humanoid = otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            local player = Utils.getPlayerFromHumanoid(humanoid)
            local gameState = PlayerStatManager.getGameState(player)

            if not gameState.touchingDoor then
                gameState.touchingDoor = true
                local key2 = Utils.getDescendantsByName(player, keyName)
                print('door' .. ' - start');
                print(door);
                if key2 then
                    door.Transparency = 0.8
                    door.CanCollide = false
                    wait(3)
                    door.Transparency = 0
                    door.CanCollide = true
                end

                -- 
                gameState.touchingDoor = false
            end
        end
    end

    -- door.Touched:Connect(onTouched)
    door.Touched:Connect(onTouchDoor)
end

function module.init(miniGameState) initKey(miniGameState) end
return module

