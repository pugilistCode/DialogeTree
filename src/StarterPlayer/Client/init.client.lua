local collectionService = game:GetService("CollectionService")

local plr = game.Players.LocalPlayer

local dialogueTree = require(script.DialogueTree)
local dialogueModules = {}
local prompts = {} -- There could be different ways to initiate dialogue

function prompts.proximityPrompt(self)
    local model = self.model

    local attachment = Instance.new("Attachment")

    local proximityPrompt = Instance.new("ProximityPrompt")
    proximityPrompt.ActionText = "Talk"
    proximityPrompt.ObjectText = model.Name
    proximityPrompt.RequiresLineOfSight = false
    proximityPrompt.MaxActivationDistance = 20

    proximityPrompt.Triggered:Connect(function(playerWhoTriggered)
        if plr ~= playerWhoTriggered then return end -- This is client sided, so I'm not sure if this is even needed..
        self:initialize(proximityPrompt)
    end)

    attachment.Parent = model.Torso
    proximityPrompt.Parent = attachment
end

-- Sort dialogue modules into table
for _, v in pairs(script.DialogueModules:GetChildren()) do
    dialogueModules[v.Name] = require(v)
end

-- Create all NPC classes
for _, NPC in pairs(collectionService:GetTagged("Dialogue")) do
    local module = dialogueModules[NPC.Name]
    if module then
        local config = module.Config
        local result = dialogueTree:create(NPC, module, NPC.CameraPart)
        if result then
            prompts[config.prompt](result)
        end 
    end
end