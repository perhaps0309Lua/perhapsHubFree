local Repository = 'https://raw.githubusercontent.com/perhaps0309Lua/perhapsHubFree/main/'

local Library = loadstring(game:HttpGet(Repository..'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(Repository..'Addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(Repository..'Addons/SaveManager.lua'))()

local Window = Library:CreateWindow({Title = "Busy Business - perhapsHub Free", Center = true, AutoShow = true})

local mainTab = Window:AddTab("Main")
local uiSettings = Window:AddTab("UI Settings")

local mainGroup = mainTab:AddLeftGroupbox("Main")

-- // Main Tab

local currentPlot;
for i, v in pairs(workspace.Plots:GetChildren()) do
   if v:FindFirstChild("Owner") and v.Owner.Value == game.Players.LocalPlayer then
       currentPlot = v
   end
end

local holdTime = 0.4
local function setDuration(Object)
    if Object:IsA("ProximityPrompt") then
        Object.HoldDuration = holdTime
    end
end

local holdSlider = mainTab:AddSlider("Hold Time", {Min = 0, Max = 5, Default = 0.4, Rounding = 1, Callback = function(Value) 
    for i, Object in pairs(currentPlot:GetDescendants()) do
        setDuration(Object)
    end
end})

currentPlot.DescendantAdded:Connect(setDuration)

-- // UI Settings

local MenuGroup = uiSettings:AddLeftGroupbox('Menu')

MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {Default = 'Minus', NoUI = true, Text = 'Menu keybind'}) 

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings() 
SaveManager:SetIgnoreIndexes({'MenuKeybind'}) 

ThemeManager:SetFolder('perhapsHubFree')
SaveManager:SetFolder('perhapsHubFree/BusyBusiness')

SaveManager:BuildConfigSection(uiSettings) 
ThemeManager:ApplyToTab(uiSettings)

SaveManager:LoadAutoloadConfig()
