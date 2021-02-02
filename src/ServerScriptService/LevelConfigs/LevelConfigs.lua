local Sss = game:GetService("ServerScriptService")
local Level1 = require(Sss.Source.LevelConfigs.Level1)
local Level2 = require(Sss.Source.LevelConfigs.Level2)

local module = {}

module.levelConfigs = {
    Level1.config, -- 
    Level2.config --
}

return module
