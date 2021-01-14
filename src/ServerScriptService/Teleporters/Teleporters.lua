local Sss = game:GetService("ServerScriptService")
local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local TS = game:GetService("TweenService")

local module = {}

local function setLocalTPTargetToRemoteTP(localTP, remoteTP)
    localTP.PrimaryPart.Touched:Connect(function(touchPart)

        local character = touchPart.Parent
        if not character then return end

        local humanoid = character:FindFirstChildWhichIsA("Humanoid")

        if humanoid and character.currentlyTeleporting.Value == false then
            local Character = character
            local questTeleporterReceiver =
                Utils.getFirstDescendantByName(remoteTP,
                                               "QuestTeleporterReceiver")
            local teleportLocation = questTeleporterReceiver.Position +
                                         Vector3.new(0, 20, 0)

            wait(0.5)
            Character.PrimaryPart.Position = teleportLocation

            local teleportingValue = Character.currentlyTeleporting
            teleportingValue.Value = true
            wait(3)
            teleportingValue.Value = false
        end
    end)
end

function module.configTeleporter(props)
    local worldIndex = props.worldIndex
    local label = props.label
    local parentFolder = props.parentFolder
    local positionerName = props.positionerName
    local positionOffset = props.positionOffset or Vector3.new(0, 0, 0)

    local teleporterTemplate = Utils.getFromTemplates("TeleporterTemplate")
    local teleporter = teleporterTemplate:Clone()
    teleporter.Parent = parentFolder

    local labels = Utils.getDescendantsByName(teleporter, "TeleporterLabel")
    for i, lab in ipairs(labels) do lab.Text = label end

    local positioner = Utils.getFirstDescendantByName(parentFolder,
                                                      positionerName)

    teleporter.PrimaryPart.CFrame = positioner.CFrame + positionOffset

    teleporter.Name = "teleporter" .. "-hex-W" .. worldIndex

    teleporter.PrimaryPart.Anchored = true
    positioner.CanCollide = false
    positioner.Transparency = 1
    return teleporter
end

function module.configLocalTeleporter(props)
    local questIndex = props.questIndex
    local questTitle = props.questTitle
    local sceneIndex = props.sceneIndex
    local parent = props.parent
    local localTPPositioner = props.localTPPositioner

    local teleporterTemplate = Utils.getFromTemplates("TeleporterTemplate")
    local localTeleporter = teleporterTemplate:Clone()
    localTeleporter.Parent = parent

    localTeleporter.PrimaryPart.CFrame = localTPPositioner.CFrame

    local labels =
        Utils.getDescendantsByName(localTeleporter, "TeleporterLabel")
    for i, label in ipairs(labels) do label.Text = questTitle end

    localTeleporter.Name = "teleporter" .. "-local-Q" .. questIndex .. "-S" ..
                               sceneIndex
    return localTeleporter
end

function module.addTeleporters(props)
    local parent = props.parent
    local sceneIndex = props.sceneIndex
    local questIndex = props.questIndex
    local questTitle = props.questTitle
    local isStartScene = props.isStartScene
    local isEndScene = props.isEndScene
    local hexTeleporter = props.hexTeleporter
    local localTPPositioner = props.localTPPositioner

    if (not isStartScene and not isEndScene) then return end

    local props = {
        parent = parent,
        questTitle = questTitle,
        sceneIndex = sceneIndex,
        questIndex = questIndex,
        localTPPositioner = localTPPositioner
    }
    local localTeleporter = module.configLocalTeleporter(props)

    if isEndScene then
        -- setLocalTPTargetToRemoteTP(hexTeleporter, localTeleporter)
        setLocalTPTargetToRemoteTP(localTeleporter, hexTeleporter)
    end

    localTeleporter.PrimaryPart.Anchored = true
    -- localTPPositioner:Destroy()
end
module.setLocalTPTargetToRemoteTP = setLocalTPTargetToRemoteTP
return module
