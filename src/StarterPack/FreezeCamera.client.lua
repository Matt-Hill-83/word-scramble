print("Freeze Camera - local script")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteEvent = ReplicatedStorage:WaitForChild("FreezeCameraRE")

-- TODO - get this from Utils3
function setCFrameFromDesiredEdgeOffset(props)
    local parent = props.parent
    local child = props.child
    local offsetConfig = props.offsetConfig

    local defaultOffsetAdder = Vector3.new(0, 0, 0)

    local defaultOffsetConfig = {
        useParentNearEdge = Vector3.new(0, 1, -1),
        useChildNearEdge = Vector3.new(0, -1, 1),
        offsetAdder = defaultOffsetAdder
    }

    offsetConfig = offsetConfig or defaultOffsetConfig

    local offset = (offsetConfig.useParentNearEdge * parent.Size -
                       offsetConfig.useChildNearEdge * child.Size) / 2 +
                       (offsetConfig.offsetAdder or defaultOffsetAdder)

    local newCFrame = CFrame.new(offset)
    return parent.CFrame:ToWorldSpace(newCFrame)
end

local function freezeCamera(cameraPath1, cameraPath2, freeze)
    local player = game:GetService("Players").LocalPlayer

    local camera = workspace.CurrentCamera
    if freeze then
        local cameraOffset = Vector3.new(0, 0, 0)
        print('cameraOffset' .. ' - start');
        print(cameraOffset);
        if camera.CameraType ~= Enum.CameraType.Scriptable then
            camera.CameraType = Enum.CameraType.Scriptable
        end

        local cameraPositioner = Instance.new("Part", cameraPath1)
        cameraPositioner.Size = Vector3.new(1, 1, 1)

        local translateCFrameProps = {
            parent = cameraPath1,
            child = cameraPositioner,
            offsetConfig = {
                useParentNearEdge = Vector3.new(0, 0, 1),
                useChildNearEdge = Vector3.new(0, 0, -1),
                offsetAdder = cameraOffset
            }
        }

        local newCFrame = setCFrameFromDesiredEdgeOffset(translateCFrameProps)

        cameraPositioner.CFrame = newCFrame
        cameraPositioner.Anchored = true

        camera.CFrame = newCFrame
        camera.CFrame = CFrame.new(camera.CFrame.Position, cameraPath2.Position)
    else
        camera.CameraType = Enum.CameraType.Custom

    end
end

remoteEvent.OnClientEvent:Connect(freezeCamera)
