local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local InitWord = require(Sss.Source.WordWheelIsland.InitWord)

local module = {}

local function initWWIStatue()
    -- 
end

local function configStatue(props)
    -- 

end

local function initWWI()
    local myStuff = workspace:FindFirstChild("MyStuff")

    local wordWheelIsland = Utils.getFirstDescendantByName(myStuff,
                                                           "WordWheelIsland")

    -- local statuePositioners = Utils.getDescendantsByName(myStuff,
    --                                                      "StatuePositioner")
    local statueTemplate = Utils.getFirstDescendantByName(wordWheelIsland,
                                                          "StatueTemplate")
    local statuePositionerFolder = Utils.getFirstDescendantByName(
                                       wordWheelIsland, "StatuePositioners")

    local statuePositioners = statuePositionerFolder:getChildren()
    print('statuePositioners' .. ' - start');
    print(statuePositioners);

    local statusDefs = {
        {sentence = {"YES", "MOM", "OK", "MOM"}, character = "raven"}, {
            sentence = {"NOT", "A", "CAT"},
            character = "katScared",
            songId = "6342102168"
        }, --
        {
            sentence = {"TROLL", "NEED", "GOLD"},
            character = "troll02",
            songId = "6338745550"
        }, --
        {sentence = {"I", "SEE", "A", "BEE"}, character = "lizHappy"}
    }

    for statueIndex, statuePositioner in ipairs(statuePositioners) do
        local statusDef = statusDefs[statueIndex]
        local sentence = statusDef.sentence
        local character = statusDef.character
        local songId = statusDef.songId

        -- local statuePositioner = statuePositioners[statueIndex]
        local newStatueScene = statueTemplate:Clone()
        newStatueScene.Parent = statuePositioner.Parent
        newStatueScene.PrimaryPart.CFrame = statuePositioner.CFrame
        newStatueScene.PrimaryPart.Anchored = true

        local sentencePositioner = Utils.getFirstDescendantByName(
                                       newStatueScene, "SentencePositioner")

        local wordGirl = Utils.getFirstDescendantByName(newStatueScene,
                                                        "WordGirl")
        local characterImage = Utils.getFirstDescendantByName(wordGirl,
                                                              "CharacterImage")

        Utils.applyDecalsToCharacterFromConfigName(
            {part = characterImage, configName = character})

        local wordLetters = {}

        if songId then
            local soundEmitter = Utils.getFirstDescendantByName(newStatueScene,
                                                                "StatueSong")
            soundEmitter.Sound.SoundId = "rbxassetid://" .. songId
            soundEmitter.Sound.Playing = true
            soundEmitter.Sound.Looped = true
        end

        configStatue()
        for wordIndex, word in ipairs(sentence) do
            local wordProps = {
                wordIndex = wordIndex,
                wordLetters = wordLetters,
                word = word
            }
            InitWord.initWord(wordProps)
        end

        sentencePositioner:Destroy()
    end
    statueTemplate:Destroy()
end

module.initWWI = initWWI

return module

