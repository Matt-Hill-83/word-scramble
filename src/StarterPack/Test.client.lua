print('client script');
print('client script');
print('client script');
print('client script');
print('client script');
print('client script');
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Const_Client = require(RS.Source.Constants.Constants_Client)

-- local WordGui = require(RS.Source.WordGui.WordGui)

-- print('WordGui' .. ' - start');
-- print(WordGui);
local player = Players.LocalPlayer
local newPlayerEvent = RS:WaitForChild(Const_Client.RemoteEvents.NewPlayerEvent)
local playerGui = player:WaitForChild("PlayerGui")

local welcomeScreen = Instance.new("ScreenGui")
welcomeScreen.Parent = playerGui
local newPlayerMessage = Instance.new("TextLabel")
newPlayerMessage.Size = UDim2.new(0, 200, 0, 50)
newPlayerMessage.Parent = welcomeScreen
newPlayerMessage.Visible = false
newPlayerMessage.Text = "A new player has joined the game!"

local function onNewPlayerFired()
    print('onNewPlayerFired');
    print('onNewPlayerFired');
    print('onNewPlayerFired');
    print('onNewPlayerFired');
    newPlayerMessage.Visible = true
    wait(3)
    newPlayerMessage.Visible = false
end

newPlayerEvent.OnClientEvent:Connect(onNewPlayerFired)
