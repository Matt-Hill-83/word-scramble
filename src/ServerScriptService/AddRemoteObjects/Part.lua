local module = {}

function createPartWithVectors(props)
    local parent = props.parent
    local size = props.size
    local name = props.name
    local position = props.position
    local decalId = props.decalId

    local newPart = Instance.new("Part", parent)

    newPart.Size = size
    newPart.Position = position
    newPart.BrickColor = props.color or BrickColor.new("Light blue")
    newPart.Name = name

    return newPart

end

module.createPartWithVectors = createPartWithVectors
return module
