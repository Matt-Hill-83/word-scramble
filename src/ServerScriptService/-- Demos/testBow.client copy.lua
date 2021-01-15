function AwardBadge(player, badgeId)
    local success = false
    local badgeInfo = nil
    local attempts = 0
    repeat
        attempts = attempts + 1
        success, badgeInfo = pcall(function()
            return game:GetService("BadgeService"):GetBadgeInfoAsync(badgeId)
        end)
        if not success then wait(5) end
    until success or attempts >= 3
    if success then
        if badgeInfo.IsEnabled then
            local err = nil
            success = false
            attempts = 0
            local HasBadge = false
            repeat
                attempts = attempts + 1
                success, err = pcall(function()
                    HasBadge = game:GetService("BadgeService")
                                   :UserHasBadgeAsync(player.UserId, badgeId)
                end)
                if not success then wait(5) end
            until success or attempts >= 3
            if HasBadge then return end
            success = false
            attempts = 0
            err = nil
            repeat
                attempts = attempts + 1
                success, err = pcall(function()
                    game:GetService("BadgeService"):AwardBadge(player.UserId,
                                                               badgeId)
                end)
                if not success then wait(5) end
            until success or attempts >= 0
            if not success then
                warn("Error while awarding badge: ", err)
            end
        end
    else
        warn("Error while fetching badge info: " .. badgeInfo)
    end
end

Humanoid.Died:Connect(function()
    local creator = Humanoid:FindFirstChild("creator")
    if creator ~= nil then AwardBadge(creator.Value, 00000) end
end)
