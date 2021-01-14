local regionEnter, regionExit
local module = {Players = {}, Regions = {}}

function module.refreshPlayers(region)
    local inRegion = {}
    for _, obj in pairs(region:GetDescendants()) do
        if obj:IsA("BasePart") then
            for _, part in pairs(obj:GetTouchingParts()) do
                local plr = game.Players:GetPlayerFromCharacter(part.Parent)
                if plr then
                    local plrRegion = module.getPlayerRegion(plr)
                    if not plrRegion or plrRegion == region then
                        inRegion[tostring(plr.UserId)] = true
                    end
                end
            end
        end
    end
    for userId, _ in pairs(inRegion) do
        if module.Players[tostring(userId)] ~= region then
            regionEnter(game.Players:GetPlayerByUserId(userId), region)
            module.Players[tostring(userId)] = region
        end
    end
    for userId, plrRegion in pairs(module.Players) do
        if plrRegion.Name == region.Name and not inRegion[tostring(userId)] then
            regionExit(game.Players:GetPlayerByUserId(userId), plrRegion)
            module.Players[tostring(userId)] = nil
        end
    end
    return inRegion
end

function module.getPlayerRegion(plr)
    for userId, region in pairs(module.Players) do
        if tonumber(userId) == plr.UserId then return region end
    end
    return nil
end

function module.isPlayerInRegion(plr, region)
    if typeof(region) == "string" then
        return module.Players[tostring(plr.UserId)].Name == region
    elseif typeof(region) == "Instance" then
        return module.Players[tostring(plr.UserId)] == region
    end
    return false
end

return function(regions, newRegionEnter, newRegionLeft)
    for _, region in pairs(regions) do
        module.Regions[region.Name] = region
        for _, obj in pairs(region:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Touched:Connect(function(hit)
                    module.refreshPlayers(region)
                end)
                obj.TouchEnded:Connect(function(hit)
                    module.refreshPlayers(region)
                end)
            end
        end
    end
    regionEnter = newRegionEnter
    regionExit = newRegionLeft
    return module
end
