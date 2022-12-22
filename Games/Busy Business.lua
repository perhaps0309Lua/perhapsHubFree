local Repository = 'https://raw.githubusercontent.com/perhaps0309Lua/perhapsHubFree/main/'

local Library = loadstring(game:HttpGet(Repository..'Library/Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(Repository..'Library/Addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(Repository..'Library/Addons/SaveManager.lua'))()

local Window = Library:CreateWindow({Title = "Busy Business - perhapsHub Free", Center = true, AutoShow = true})

local mainTab = Window:AddTab("Main")
local uiSettings = Window:AddTab("UI Settings")

local mainGroup = mainTab:AddLeftGroupbox("Main")
local customersGroup = mainTab:AddRightGroupbox("Customers")

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Character = localPlayer.Character
local PlayerGui = localPlayer.PlayerGui

if not Character then repeat task.wait() until Character Character = localPlayer.Character end 
localPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
end)

local newShop = game:GetService("ReplicatedStorage").Communication.NewShop
local claimReward = game:GetService("ReplicatedStorage").Communication.ClaimPlaytimeReward
local upgradeMachine = game:GetService("ReplicatedStorage").Communication.UpgradeMachine
local buyUpgrade = game:GetService("ReplicatedStorage").Communication.BuyUpgrade

local getFunction = require(game:GetService("ReplicatedStorage").Modules.Client.LocalDataStore):Get()

-- // Main Tab

local currentPlot;
for i, v in pairs(workspace.Plots:GetChildren()) do -- // iterate through all plots
   if v:FindFirstChild("Owner") and v.Owner.Value == localPlayer then -- // check if the plot is our local player
       currentPlot = v -- // set the current plot to the plot we found
   end
end

local holdTime = 0.4
local function setDuration(Object)
    task.wait(1) -- wait for the object to be fully loaded, otherwise it won't work
    if Object:IsA("ProximityPrompt") then
        Object.HoldDuration = holdTime -- set the hold duration of the prompt
    end
end

local holdSlider = mainGroup:AddSlider("HoldTime", {Text = "Hold Time", Min = 0, Max = 5, Default = 0.4, Rounding = 1, Compact = false, Callback = function(Value) 
    holdTime = Value
    for i, Object in pairs(currentPlot:GetDescendants()) do -- // iterate through all descendants of the current plot
        task.spawn(setDuration, Object) -- // spawn a new thread to set the duration of the object
    end
end})

currentPlot.DescendantAdded:Connect(setDuration) -- // connect to the descendant added event to set the duration of the object

local maxCookTime = 2;
local cookSlider = mainGroup:AddSlider("CookTime", {Text = "Max Cook Time", Min = 0, Max = 5, Default = 2, Rounding = 1, Compact = false, Callback = function(Value) 
    maxCookTime = Value
end})

for i, v in pairs(getgc(true)) do 
    if typeof(v) == "table" and rawget(v, "Start") then 
        local Upvalues = #debug.getupvalues(rawget(v, "Start"))
        if Upvalues == 9 then 
            local providedFunction = rawget(v, "Start")
            local oldHook;
            oldHook = hookfunction(providedFunction, function(currentMax)
                currentMax = maxCookTime
                if maxCookTime == 0 then return true end 
                return oldHook(currentMax)
            end)
        end 
    end 

    if typeof(v) == "table" and rawget(v, "UseObject") then 
        local UseObject = rawget(v, "UseObject")
        getrawmetatable(debug.getupvalue(UseObject, 9)).Disable = function() end 
    end 
end

-- // Remove anti movement when making food

local movementInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad)
local fakeTable = {}
function fakeTable:Play() end

local oldNC;
oldNC = hookmetamethod(game, "__namecall", function(Self, ...)
    local Arguments = {...}
    if getnamecallmethod() == "Create" then 
        local primaryPart = Arguments[1]
        if primaryPart.Parent == Character and Arguments[2] == movementInfo then 
            return fakeTable
        end 
    end 

    return oldNC(Self, ...)
end)

-- // Auto claim

local autoClaimRewards = false
local autoClaimRewardsToggle = mainGroup:AddToggle("AutoClaim", {Text = "Auto Claim Rewards", Default = false, Callback = function(Value) 
    autoClaimRewards = Value
end})

task.spawn(function()
    while task.wait(15) do 
        if autoClaimRewards then 
            for i = 1, 11 do 
                claimReward:InvokeServer(i)
            end 
        end 
    end 
end)

-- // Auto upgrade machines

local autoUpgrade = false
local autoUpgradeToggle = mainGroup:AddToggle("AutoUpgrade", {Text = "Auto Upgrade Machines", Default = false, Callback = function(Value) 
    autoUpgrade = Value
end})

local autoBuyUpgrades = false
local autoBuyUpgradesToggle = mainGroup:AddToggle("AutoBuyUpgrades", {Text = "Auto Buy Upgrades", Default = false, Callback = function(Value) 
    autoBuyUpgrades = Value
end})

local autoBuyShop = false;
local autoBuyShopToggle = mainGroup:AddToggle("AutoBuyShop", {Text = "Auto Buy Shop", Default = false, Callback = function(Value) 
    autoBuyShop = Value
end})

task.spawn(function()
    while task.wait(1) do 
        if autoUpgrade then 
            local machineLevels = getFunction:Get("machinelevels")
            for i, v in pairs(machineLevels) do 
                upgradeMachine:FireServer(i)
            end 
        end 
    end 
end)

task.spawn(function() -- // run another loop, need to upgrade once to get the upgrades
    while task.wait(5) do 
        if autoUpgrade then 
            local machineLevels = getFunction:Get("machinelevels")
            for i, v in pairs(currentPlot.Objects:GetChildren()) do 
                local objectItem = v:FindFirstChild("Item")
                if objectItem and objectItem.Value then 
                    local objectItemValue = objectItem.Value
                    if not machineLevels[objectItemValue] then 
                        upgradeMachine:FireServer(objectItemValue)
                    end
                end
            end
        end 
    end 
end)

local setSold = function() end;
for i, v in pairs(getgc(true)) do 
    if typeof(v) == "function" and islclosure(v) and not issynapsefunction(v) and debug.getinfo(v).name == "SetSold" then 
        setSold = v
    end 
end 

task.spawn(function()
    while task.wait(5) do 
        if autoBuyUpgrades then 
            local Main = PlayerGui:FindFirstChild("Main")
            local upgradesHold = Main and Main:FindFirstChild("Menus") and Main.Menus:FindFirstChild("Upgrades") and Main.Menus.Upgrades:FindFirstChild("Inner") and Main.Menus.Upgrades.Inner:FindFirstChild("Upgrades") and Main.Menus.Upgrades.Inner.Upgrades:FindFirstChild("Hold")
            
            local upgradesChildren = upgradesHold:GetChildren()
            local maxUpgrades = #upgradesChildren
            local currentUpgraded = getFunction:Get("upgraded")

            local currentCount = 0;
            for i = 1, maxUpgrades do 
                local currentMoney = getFunction:Get("money")

                if not currentUpgraded[tostring(i)] and upgradesHold:FindFirstChild(i) and upgradesHold:FindFirstChild(i):GetAttribute("Cost") <= currentMoney then 
                    task.spawn(buyUpgrade.FireServer, buyUpgrade, i)
                    setSold(upgradesHold:FindFirstChild(i))
                else 
                    currentCount = currentCount + 1
                end 
            end 

            if autoBuyShop and maxUpgrades == currentCount then 
                newShop:InvokeServer()
            end
        end 

        if not autoBuyUpgrades and autoBuyShop then 
            newShop:InvokeServer()
        end 
    end
end)

-- // Customers Tab

local autoOrder = false
local autoServe = false

local autoOrderToggle = customersGroup:AddToggle("AutoOrder", {Text = "Auto Order", Default = false, Callback = function(Value) 
    autoOrder = Value
end})

local autoServeToggle = customersGroup:AddToggle("AutoServe", {Text = "Auto Serve", Default = false, Callback = function(Value) 
    autoServe = Value
end})

local otherPlots = false;
local otherPlotsToggle = customersGroup:AddToggle("OtherPlots", {Text = "Other Plots", Default = false, Callback = function(Value) 
    otherPlots = Value
end})

local useMachine = game:GetService("ReplicatedStorage").Communication.UseMachine
local orderCustomer = game:GetService("ReplicatedStorage").Communication.CustomerOrder
local serveCustomer = game:GetService("ReplicatedStorage").Communication.ServeCustomer
local ServerScriptService = game:GetService("ServerScriptService")

function getItem(Item)
    local vStation;
    for i, v in pairs(currentPlot.Objects:GetChildren()) do
        if v:FindFirstChild("Item") and v.Item.Value == Item then  
            vStation = v
        end
    end

    useMachine:FireServer(vStation, true)
end

function orderCustomerF(Customer)
    if not autoOrder then return end
    local orderTaken = Customer:GetAttribute("OrderTaken")

    orderCustomer:FireServer(Customer)
end

function serveCustomerF(Customer)
    if not autoServe then return end
    task.wait(5)
    
    local countAttribute = Customer:GetAttribute("Count")
    local orderTaken = Customer:GetAttribute("OrderTaken")
    if not orderTaken or not countAttribute or countAttribute == 0 or tonumber(countAttribute) < 1 then return end

    local customerItem = Customer:GetAttribute("Item")
    if not customerItem then return end

    for i = 1, countAttribute do
        getItem(customerItem)
        serveCustomer:FireServer(Customer)
    end
end

currentPlot.ChildAdded:Connect(orderCustomerF)
currentPlot.ChildAdded:Connect(serveCustomerF)

task.spawn(function()
    while task.wait(1) do
        for i, v in pairs(currentPlot.Customers:GetChildren()) do  
            task.spawn(orderCustomerF, v)
            task.spawn(serveCustomerF, v)
        end 
    end 
end)

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
