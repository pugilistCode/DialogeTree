local dialogue = {}
dialogue.__index = dialogue

local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")

local player = game.Players.LocalPlayer
local playerGui = player.PlayerGui
local camera = workspace.CurrentCamera

local conversating = false

function dialogue:create(model, module, cameraPart)
    local newNPC = {}
    setmetatable(newNPC, dialogue)

    newNPC.model = model
    newNPC.focusPart = cameraPart-- What part shuold the camera focus on?
    newNPC.tree = module -- Dialogue tree input

    return newNPC
end

function dialogue:createOptions(option)
    local tab = self.tree[option]
    local gui = self.gui
    local responses = tab.responses

    for _, child in pairs(gui.Dialogue.Options:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local debounce = false
    for i = 1, #responses do
        local option = responses[i]
        local button = game.ReplicatedStorage.ResponseButton:Clone()
        button.Text = option.text
        button.MouseButton1Down:Connect(function()
            if debounce then return end -- Avoid spam
            debounce = true
            
            -- To do
            -- Add 'nextQuestion' to all of them, but if there are no responses - end the dialogue, or play the NPC's text if there is any
            local nextQuestion = option.nextQuestion
            if nextQuestion then 
                self:createOptions(option.nextQuestion)
            else
                self:finish()
            end
        end)
        button.Parent = gui.Dialogue.Options
    end

    gui.Dialogue.NPC.Text = tab.text
end

function dialogue:cameraTween(delta)
    camera.CFrame = camera.CFrame:Lerp(self.focusPart.CFrame, 0.08)
end

function dialogue:initialize(prompt)
    if conversating then return end
    conversating = true

    if prompt then
        self.prompt = prompt
        self.prompt.Enabled = false
    end

    camera.CameraType = Enum.CameraType.Scriptable
    runService:BindToRenderStep("TweenToPart", Enum.RenderPriority.Camera.Value + 1, function(delta)
        self:cameraTween(delta)
    end)

    -- camera/UI setup
    local gui = game.ReplicatedStorage.DialogueGui:Clone()
    gui.Parent = playerGui
    
    self.gui = gui
    self:createOptions("Initialize") -- Starting prompt
end

function dialogue:finish()
    local ui = self.gui
    if ui then ui:Destroy() end

    if self.prompt then
        self.prompt.Enabled = true
    end

    runService:UnbindFromRenderStep("TweenToPart")
    camera.CameraType = Enum.CameraType.Custom
    conversating = false
end

return dialogue