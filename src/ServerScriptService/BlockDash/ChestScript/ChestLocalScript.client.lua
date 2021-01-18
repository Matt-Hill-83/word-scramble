local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

mouse.Button1Down:connect(function() -- if the player clicks then ...

    print('mouse click');
    print('mouse click');
    print('mouse click');
    print('mouse click');
    print('mouse click');
    if mouse.Target and mouse.Target.Name == "Lock" and
        -- if script.Chest.Value and mouse.Target and mouse.Target.Name == "Lock" and
        mouse.Target:IsDescendantOf(script.Chest.Value) then -- if they click the chests lock
        script.Parent.Parent.LidToggle:FireServer() -- fire an event that the script will use
        -- script.Chest.Value.LidToggle:FireServer() -- fire an event that the script will use
    end
end)
