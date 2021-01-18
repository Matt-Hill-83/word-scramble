local Sss = game:GetService("ServerScriptService")
local Utils = require(Sss.Source.Utils.U001GeneralUtils)

local module = {}

local function init(chest)

    local chestHitBox = Utils.getFirstDescendantByName(chest, "HitBox")

    local reward = chest.Reward:GetChildren()[1]
    -- local reward
    -- if #chest.Reward:GetChildren() > 0 then
    --     local originalReward = chest.Reward:GetChildren()[1]
    --     reward = originalReward:Clone()
    --     local newModel = Instance.new("Model", chest.Reward)
    --     for _, child in pairs(originalReward:GetChildren()) do
    --         if not (child:IsA("Script") or child:IsA("LocalScript")) then
    --             if child:IsA("BasePart") then
    --                 child.Anchored = true
    --             end
    --             child.Parent = newModel
    --         else
    --             child:Destroy()
    --         end
    --     end
    -- end

    function onItemTouched(obj)
        local player = game.Players:GetPlayerFromCharacter(obj.Parent)
        if not player then return end
        if not player.Backpack:FindFirstChild(reward.Name) and player.Character and
            not player.Character:FindFirstChild(reward.Name) then

            -- Clone the tool
            local toGive = reward:Clone()
            for _, child in pairs(toGive:GetChildren()) do
                if child:IsA("BasePart") then
                    child.Anchored = false
                end
            end

            -- Make sure item is not in starter pack
            if not game.StarterPack:FindFirstChild(reward.Name) then
                toGive:Clone().Parent = game.StarterPack
            end
            -- unequip it, (because you touched it probably), stick it in the backpack, then equip it.
            player.Character.Humanoid:UnequipTools()
            toGive.Parent = player.Backpack
            player.Character.Humanoid:EquipTool(toGive)
        end

    end

    chestHitBox.Touched:connect(onItemTouched)

end

module.init = init
return module
