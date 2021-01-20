local Sss = game:GetService("ServerScriptService")
local CS = game:GetService("CollectionService")
local LetterFallUtils = require(Sss.Source.LetterFall.LetterFallUtils)

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
local Constants = require(Sss.Source.Constants.Constants)

local Replicator = require(Sss.Source.BlockDash.Replicator)

local module = {}

local function initWord(miniGameState)
    local sectorFolder = miniGameState.sectorFolder

    local positioner = Utils.getFirstDescendantByName(sectorFolder,
                                                      "KeyReplicatorPositioner")
    local template = Utils.getFromTemplates("KeyReplicatorTemplate")

    local newReplicator = template:Clone()
    local key = Utils.getFirstDescendantByName(newReplicator, "Key")
    key.Name = "key--fff" .. sectorFolder.Name
    -- key.Handle.Anchored = false

    newReplicator.Parent = sectorFolder
    local newReplicatorPart = newReplicator.PrimaryPart

    newReplicatorPart.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                                   {
            parent = positioner,
            child = newReplicatorPart,
            offsetConfig = {
                useParentNearEdge = Vector3.new(-1, 1, -1),
                useChildNearEdge = Vector3.new(-1, -1, -1),
                offsetAdder = Vector3.new(0, 0, 0)
            }
        })

    newReplicatorPart.Anchored = true

    Replicator.init(newReplicator)
end

function module.init(miniGameState) initWord(miniGameState) end

return module

