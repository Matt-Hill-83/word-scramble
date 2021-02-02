local Sss = game:GetService("ServerScriptService")
local Sector1 = require(Sss.Source.SectorConfigs.Sector1)
local Sector2 = require(Sss.Source.SectorConfigs.Sector2)

local module = {}

module.sectorConfigs = {
    Sector1.config, -- 
    Sector2.config --
}

return module
