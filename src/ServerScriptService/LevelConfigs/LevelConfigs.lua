local Sss = game:GetService("ServerScriptService")
local Level1 = require(Sss.Source.LevelConfigs.Level1)
local Level2 = require(Sss.Source.LevelConfigs.Level2)
local Level3 = require(Sss.Source.LevelConfigs.Level3)
local Level4 = require(Sss.Source.LevelConfigs.Level4)
local Level5 = require(Sss.Source.LevelConfigs.Level5)

local module = {}

module.levelConfigs = {
    Level1.config, -- 
    Level2.config, --
    Level3.config, --
    Level4.config, --
    Level5.config --
}

return module
