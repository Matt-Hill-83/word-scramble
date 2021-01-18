local Sss = game:GetService("ServerScriptService")
local Utils = require(Sss.Source.Utils.U001GeneralUtils)

local module = {}

local function init(chest)
    print('init');

    local chestHitBox = Utils.getFirstDescendantByName(chest, "HitBox")

    local reward
    if #chest.Reward:GetChildren() > 0 then
        local originalReward = chest.Reward:GetChildren()[1]
        reward = originalReward:Clone()
        -- Take everything out of the Tool and put it in a model that looks like the tool, for display
        -- But it can't be picked up.  Keep this is the chest for display, and Anchor it.
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

    function onItemTouched(obj)
        local player = game.Players:GetPlayerFromCharacter(obj.Parent)
        if not player then return end

        -- If it's not in the backpack and if you are not holding it, clone it
        if not player.Backpack:FindFirstChild(reward.Name) and player.Character and
            not player.Character:FindFirstChild(reward.Name) then

            -- Clone the tool, unanchor it, so it can be taken
            local toGive = reward:Clone()
            for _, child in pairs(toGive:GetChildren()) do
                if child:IsA("BasePart") then
                    child.Anchored = false
                end
            end

            -- Player have have touched the clone or the original, so unequip all.
            -- Then put the correct one in the backpack and equip it, so the other is not grabbed.
            player.Character.Humanoid:UnequipTools()
            toGive.Parent = player.Backpack
            player.Character.Humanoid:EquipTool(toGive)
        end

    end

    chestHitBox.Touched:connect(onItemTouched)

end

module.init = init
return module
