local Sss = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local PlayerStatManager = require(Sss.Source.AddRemoteObjects.PlayerStatManager)

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Constants = require(Sss.Source.Constants.Constants)
local freezeCameraRE = RS:WaitForChild("BlockDashFreezeCameraRE")

local module = {}
local fastWalkSpeed = Constants.gameConfig.fastWalkSpeed

function module.initEntrance(miniGameState)
    local sectorFolder = miniGameState.sectorFolder

    local function onTouchEntrance(otherPart)
        print('onTouchEntrance' .. ' - start');
        local humanoid = otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            local player = Utils.getPlayerFromHumanoid(humanoid)
            local gameState = PlayerStatManager.getGameState(player)

            if not gameState.orbitalView then
                gameState.orbitalView = true
                freezeCameraRE:FireClient(player, true)
                humanoid.JumpPower = 70
            end
        end
    end

    local entrances = Utils.getDescendantsByName(sectorFolder, "Entrance")
    for _, item in ipairs(entrances) do item.Touched:Connect(onTouchEntrance) end

    local function onTouchExit(otherPart)
        local humanoid = otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            local player = Utils.getPlayerFromHumanoid(humanoid)
            local gameState = PlayerStatManager.getGameState(player)

            if gameState.orbitalView then
                gameState.orbitalView = false
                freezeCameraRE:FireClient(player, false)
                humanoid.JumpPower = 50
            end
        end
    end

    local exits = Utils.getDescendantsByName(sectorFolder, "Exit")
    for _, item in ipairs(exits) do item.Touched:Connect(onTouchExit) end

    -- 
    -- 
    -- 
    local function onTouchRun30(otherPart)
        print('onTouchRun30');
        local humanoid = otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            local player = Utils.getPlayerFromHumanoid(humanoid)
            local gameState = PlayerStatManager.getGameState(player)

            if gameState.runFast ~= 30 then
                gameState.runFast = 30
                humanoid.WalkSpeed = Constants.gameConfig.walkSpeed
            end
        end
    end

    local run30s = Utils.getDescendantsByName(sectorFolder, "Run30")
    for _, item in ipairs(run30s) do item.Touched:Connect(onTouchRun30) end

    local function onTouchRun50(otherPart)
        print('onTouchRun50----------------------------');
        local humanoid = otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            local player = Utils.getPlayerFromHumanoid(humanoid)
            local gameState = PlayerStatManager.getGameState(player)

            if gameState.runFast ~= 50 then
                gameState.runFast = 50
                humanoid.WalkSpeed = fastWalkSpeed
            end
        end
    end

    local run50s = Utils.getDescendantsByName(sectorFolder, "Run50")
    for _, item in ipairs(run50s) do item.Touched:Connect(onTouchRun50) end

    local function onTouchRun70(otherPart)
        print('onTouchRun70');
        local humanoid = otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            if humanoid.WalkSpeed == 70 then return end
            -- local player = Utils.getPlayerFromHumanoid(humanoid)
            -- local gameState = PlayerStatManager.getGameState(player)

            -- if gameState.runFast ~= 70 then
            -- gameState.runFast = 70
            humanoid.WalkSpeed = 70
            -- end
        end
    end

    local run70s = Utils.getDescendantsByName(sectorFolder, "Run70")
    for _, item in ipairs(run70s) do item.Touched:Connect(onTouchRun70) end

end

return module

