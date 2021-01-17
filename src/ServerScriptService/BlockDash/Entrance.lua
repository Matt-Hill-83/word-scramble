local Sss = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Constants = require(Sss.Source.Constants.Constants)
local freezeCameraRE = RS:WaitForChild("BlockDashFreezeCameraRE")

local module = {entered = false, exited = false}
local fastWalkSpeed = 50
-- local fastWalkSpeed = 60

function module.initEntrance(miniGameState)
    local letterFallFolder = miniGameState.letterFallFolder

    --    TODO: conver to a closure, so it acts on a single player
    function onTouchEntrance(otherPart)
        print('onTouchEntrance' .. ' - start');

        local humanoid = otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            if not module.entered then
                module.entered = true
                module.exited = false

                local player = Utils.getPlayerFromHumanoid(humanoid)
                freezeCameraRE:FireClient(player, true)
                humanoid.JumpPower = 70
            end
        end
    end

    local entrances = Utils.getDescendantsByName(letterFallFolder, "Entrance")
    for _, item in ipairs(entrances) do item.Touched:Connect(onTouchEntrance) end

    function onTouchExit(otherPart)
        local humanoid = otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            if not module.exited then
                module.exited = true
                module.entered = false

                local player = Utils.getPlayerFromHumanoid(humanoid)
                freezeCameraRE:FireClient(player, false)
                humanoid.JumpPower = 50
            end
        end
    end

    local exits = Utils.getDescendantsByName(letterFallFolder, "Exit")
    for _, item in ipairs(exits) do item.Touched:Connect(onTouchExit) end

    function onTouchRunFast(otherPart)
        local humanoid = otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            if not module.runFast then
                module.runFast = true
                humanoid.WalkSpeed = fastWalkSpeed
            end
        end
    end

    local runFasts = Utils.getDescendantsByName(letterFallFolder, "RunFast")
    for _, item in ipairs(runFasts) do item.Touched:Connect(onTouchRunFast) end

    function onTouchRunNormal(otherPart)
        local humanoid = otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            if not module.runFast then
                module.runFast = true
                humanoid.WalkSpeed = Constants.gameConfig.walkSpeed
            end
        end
    end

    local runNormals = Utils.getDescendantsByName(letterFallFolder, "RunNormal")
    for _, item in ipairs(runFasts) do item.Touched:Connect(onTouchRunNormal) end
end

return module

