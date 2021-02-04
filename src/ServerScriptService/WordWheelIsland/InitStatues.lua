local Sss = game:GetService("ServerScriptService")
local CS = game:GetService("CollectionService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local InitWord = require(Sss.Source.WordWheelIsland.InitWord)

local module = {}

local function initStatuesStatue()
    -- 
end

local function configStatue(props)
    -- 

end

local function initStatues(props)
    local statusDefs = props.statusDefs
    local myStuff = workspace:FindFirstChild("MyStuff")

    local wordWheelIsland = Utils.getFirstDescendantByName(myStuff,
                                                           "WordWheelIsland")
    local statuePositioners = CS:GetTagged("StatuePositioner")

    local statueTemplate = Utils.getFirstDescendantByName(wordWheelIsland,
                                                          "StatueTemplate")

    print('statuePositioners' .. ' - start');
    print(statuePositioners);

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
        print('sentence' .. ' - start');
        print(sentence);
        for wordIndex, word in ipairs(sentence) do
            local wordProps = {
                wordIndex = wordIndex,
                wordLetters = wordLetters,
                sentencePositioner = sentencePositioner,
                word = word
            }
            InitWord.initWord(wordProps)
        end

        sentencePositioner:Destroy()
    end
    statueTemplate:Destroy()
end

module.initStatues = initStatues

return module

