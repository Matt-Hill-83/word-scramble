local Sss = game:GetService("ServerScriptService")
local Utils = require(Sss.Source.Utils.U001GeneralUtils)

local module = {}

local function init(chest)

    local chestHitBox = Utils.getFirstDescendantByName(chest, "HitBox")
    print('chestHitBox' .. ' - start');
    print(chestHitBox);

    -- chest = chest

    local reward
    if #chest.Reward:GetChildren() > 0 then
        local originalReward = chest.Reward:GetChildren()[1]
        reward = originalReward:Clone()
        local newModel = Instance.new("Model", chest.Reward)
        for _, child in pairs(originalReward:GetChildren()) do
            if not (child:IsA("Script") or child:IsA("LocalScript")) then
                if child:IsA("BasePart") then
                    child.Anchored = true
                end
                child.Parent = newModel
            else
                child:Destroy()
            end
        end
    end

    function onChestTouched(obj)
        local player = game.Players:GetPlayerFromCharacter(obj.Parent)
        if player then OnLidToggle(player) end
    end

    -- chestHitBox.Touched:connect(onChestTouched)

    function OnLidToggle(obj)
        local player = game.Players:GetPlayerFromCharacter(obj.Parent)
        if not player then return end
        -- function OnLidToggle(player)
        if not player.Backpack:FindFirstChild(reward.Name) and player.Character and
            not player.Character:FindFirstChild(reward.Name) then
            local toGive = reward:Clone()
            for _, child in pairs(toGive:GetChildren()) do
                if child:IsA("BasePart") then
                    child.Anchored = false
                end
            end

            if not game.StarterPack:FindFirstChild(reward.Name) then
                toGive:Clone().Parent = game.StarterPack
            end
            player.Character.Humanoid:UnequipTools()
            toGive.Parent = player.Backpack
            player.Character.Humanoid:EquipTool(toGive)
        end

    end

    chestHitBox.Touched:connect(OnLidToggle)

end

module.init = init
return module
