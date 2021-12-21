local dialogue = {}
dialogue.__index = dialogue

local tweenService = game:GetService("TweenService")
local debris = game:GetService("Debris")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local contextActionService = game:GetService("ContextActionService")

local player = game.Players.LocalPlayer
local playerGui = player.PlayerGui
local camera = workspace.CurrentCamera

local conversating = false
local tapEvent

function dialogue:create(model, module, cameraPart)
    local newNPC = {}
    setmetatable(newNPC, dialogue)

    newNPC.model = model
    newNPC.focusPart = cameraPart-- What part shuold the camera focus on?
    newNPC.tree = module -- Dialogue tree input

    return newNPC
end

function dialogue:playSound(sound)
    local findSound = game.ReplicatedStorage:FindFirstChild(sound)
    if findSound then
        local copy = findSound:Clone()
        copy.Parent = workspace
        copy:Play()
        debris:AddItem(copy, copy.TimeLength)
    end
end

function dialogue:typeWrite(text, delayBetweenChars)
    local textLabel = self.gui.Dialogue.NPC
    local displayText = text
   -- local delayBetweenChars = 0.0040625*#text

    displayText = displayText:gsub("<br%s*/>", "\n")
	displayText:gsub("<[^<>]->", "")

	-- Set translated/modified text on parent
	textLabel.Text = displayText

	local index = 0
	for first, last in utf8.graphemes(displayText) do
        if self.skip then
            textLabel.MaxVisibleGraphemes = #text
            self.skip = false
            break
        end
        self:playSound("KeyPress")
		index = index + 1
		textLabel.MaxVisibleGraphemes = index
		wait(delayBetweenChars)
	end
end

function dialogue:startQuest(self)
    print("yo!")
end

function dialogue:createOptions(option, skip)
    local tab = self.tree[option]
    local gui = self.gui
    local responses = tab.responses

    if not skip then
        gui.SkipHint.Visible = true
        self:typeWrite(tab.text, 0.065)
        gui.SkipHint.Visible = false
    else
        gui.Dialogue.NPC.Text = tab.text
    end

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
        button.MouseEnter:Connect(function()
            self:playSound("Hover")
            tweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(245, 191, 43)}):Play()
        end)
        button.MouseLeave:Connect(function()
            tweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        end)
        button.MouseButton1Down:Connect(function()
            if debounce then return end -- Avoid spam
            debounce = true

            local nextQuestion = option.nextQuestion

            local func = option.func
            if func then
                dialogue[func](self)
            end

            self:playSound("Click")
            tweenService:Create(gui.Dialogue.Options, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(0, 0, 1, 0)}):Play()

            if nextQuestion then 
                self:createOptions(option.nextQuestion, option.skip)
            else
                self:finish()
            end
        end)
        button.Parent = gui.Dialogue.Options
    end
    tweenService:Create(gui.Dialogue.Options, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0.5, 0)}):Play()
end

function dialogue:cameraTween(delta)
    camera.CFrame = camera.CFrame:Lerp(self.focusPart.CFrame, 0.1)
end

function dialogue:tapToSkip(input, gp)
    if not gp then
        self.skip = true
    end
end

function dialogue:initialize(prompt)
    if conversating then return end
    conversating = true

    if prompt then
        self.prompt = prompt
        self.prompt.Enabled = false
    end

    self:playSound("Swoosh") -- playing around with this
    camera.CameraType = Enum.CameraType.Scriptable

    runService:BindToRenderStep("TweenToPart", Enum.RenderPriority.Camera.Value + 1, function(delta)
        self:cameraTween(delta)
    end)

    tapEvent = userInputService.InputBegan:Connect(function(...)
        self:tapToSkip(...)
    end)

    wait(1)

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

    if tapEvent then
        tapEvent:Disconnect()
    end

    runService:UnbindFromRenderStep("TweenToPart")
    camera.CameraType = Enum.CameraType.Custom
    conversating = false
end

return dialogue