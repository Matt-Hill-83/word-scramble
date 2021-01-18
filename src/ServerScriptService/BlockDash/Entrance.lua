local Sss = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local PlayerStatManager = require(Sss.Source.AddRemoteObjects.PlayerStatManager)

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Constants = require(Sss.Source.Constants.Constants)
local freezeCameraRE = RS:WaitForChild("BlockDashFreezeCameraRE")

local module = {entered = false, exited = false, runFast = false}
local fastWalkSpeed = 50

function module.initEntrance(miniGameState)
    local sectorFolder = miniGameState.sectorFolder

    --    TODO: conver to a closure, so it acts on a single player
    function onTouchEntrance(otherPart)
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

    function onTouchExit(otherPart)
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

    local function onTouchRunFast(otherPart)
        print('onTouchRunFast----------------------------');
        local humanoid = otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            local player = Utils.getPlayerFromHumanoid(humanoid)
            local gameState = PlayerStatManager.getGameState(player)

            if not gameState.runFast then
                gameState.runFast = true
                humanoid.WalkSpeed = fastWalkSpeed
            end
        end
    end

    local runFasts = Utils.getDescendantsByName(sectorFolder, "RunFast")
    for _, item in ipairs(runFasts) do item.Touched:Connect(onTouchRunFast) end

    function onTouchRunNormal(otherPart)
        print('onTouchRunNormal');
        local humanoid = otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            local player = Utils.getPlayerFromHumanoid(humanoid)
            local gameState = PlayerStatManager.getGameState(player)

            if gameState.runFast then
                gameState.runFast = false
                humanoid.WalkSpeed = Constants.gameConfig.walkSpeed
            end
        end
    end

    local runNormals = Utils.getDescendantsByName(sectorFolder, "RunNormal")
    for _, item in ipairs(runNormals) do
        item.Touched:Connect(onTouchRunNormal)
    end
end

return module

