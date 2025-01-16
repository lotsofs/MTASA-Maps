--
-- GUI and Settings stuff by driver2
--

-------------------------
-- Initialize Settings --
-------------------------

settingsObject = Settings:new(defaultSettings,"settings.xml")

local function s(setting,settingType)
	return settingsObject:get(setting,settingType)
end

----------------
-- Info Texts --
----------------

local keyInfo = InfoText:new()

----------
-- Work --
----------

function startTimer()
	if (g_updateTimer) then
		killTimer(g_updateTimer)
		g_updateTimer = nil
	end

	g_updateInterval = math.max(s("updateinterval") * 1000,0)

	g_updateTimer = setTimer(update,g_updateInterval,0)
end

function update() end
function plotMapPoints() end
function prepareDraw() end

------------------
-- Settings Gui --
------------------

local gui = {}
local radioButtons = {}

--[[
-- This will determine if the settings gui is currently visible.
--
-- @return   boolean   true if the gui exists and is visible, false otherwise
-- ]]
function isGuiVisible()
	if not isElement(gui.window) then
		return false
	end
	return guiGetVisible(gui.window)
end

local function handleEdit(element)
	if element == gui.helpMemo then
		return
	end

	for k,v in pairs(gui) do
		local _,_,radioName = string.find(k,"radio_(%w+)_%d+")
		if element == v and (settingsObject.settings.default[k] ~= nil or settingsObject.settings.default[radioName] ~= nil) then
			--outputChatBox(tostring(getElementType(element)))
			if type(settingsObject.settings.main[k]) == "boolean" then
				settingsObject:set(k,guiCheckBoxGetSelected(element))
			elseif getElementType(element) == "gui-radiobutton" then
				if guiRadioButtonGetSelected(element) then
					local data = radioButtons[radioName]
					local _,_,key = string.find(k,"radio_%w+_(%d+)")
					settingsObject:set(radioName,data[tonumber(key)].value)
				end
			else
				settingsObject:set(k,guiGetText(element))
			end
		end
	end
	startTimer()
	plotMapPoints()
	prepareDraw()
end

local function handleClick()

	handleEdit(source)

	if source == gui.buttonSave then
		settingsObject:saveToXml()
	end
	if source == gui.buttonClose then
		closeGui()
	end
end

local function addColor(color,name,top,help)
	local label = guiCreateLabel(24,top,140,20,name..":",false,gui.tabStyles)
	local defaultButton = {}
	gui[color.."Red"] = guiCreateEdit(160,top,50,20,tostring(s(color.."Red")),false,gui.tabStyles)
	table.insert(defaultButton,{mode="set",edit=gui[color.."Red"],value=s(color.."Red","default")})
	gui[color.."Green"] = guiCreateEdit(215,top,50,20,tostring(s(color.."Green")),false,gui.tabStyles)
	table.insert(defaultButton,{mode="set",edit=gui[color.."Green"],value=s(color.."Green","default")})
	gui[color.."Blue"] = guiCreateEdit(270,top,50,20,tostring(s(color.."Blue")),false,gui.tabStyles)
	table.insert(defaultButton,{mode="set",edit=gui[color.."Blue"],value=s(color.."Blue","default")})
	gui[color.."Alpha"] = guiCreateEdit(325,top,50,20,tostring(s(color.."Alpha")),false,gui.tabStyles)
	table.insert(defaultButton,{mode="set",edit=gui[color.."Alpha"],value=s(color.."Alpha","default")})
	addEditButton(390,top,50,20,"default",false,gui.tabStyles,unpack(defaultButton))
	if help ~= nil then
		addHelp(help,label,gui[color.."Red"],gui[color.."Green"],gui[color.."Blue"],gui[color.."Alpha"])
	end
end


--[[
-- This will add one or (usually) several radio-buttons, that can be used
-- to change a single setting.
--
-- @param   int     x: The x position of the buttons
-- @param   int     y: The y position of the first button (others will be placed below)
-- @param   string  name: The name of the radio-button-group with which it will be identified
-- 				and is also the name of the setting these radio-buttons represent
-- @param   table   data: A table of the options to be added, numeric indices, possible elements:
-- 				text: The text of the radio button
-- 				value: The value to be set if the radio button is activated
-- ]]
local function addRadioButtons(x,y,name,data,selected)
	local pos = y
	for k,v in pairs(data) do
		local radio = guiCreateRadioButton(x,pos,200,20,v.text,false,gui.tabGeneral)
		if v.help ~= nil then
			addHelp(v.help,radio)
		end
		gui["radio_"..name.."_"..k] = radio
		if selected == v.value then
			guiRadioButtonSetSelected(radio,true)
		end
		pos = pos + 20
	end
	radioButtons[name] = data
end

--[[
-- Creates all the settings gui elements and either adds them to a window
-- if the "gamecenter" resource is not running or adds them to the "gamecenter" gui.
--
-- If the gui already exists, calling this function will have no effect.
-- ]]
function createGui()
	-- Check if GUI already exists
	if gui.window ~= nil then
		return
	end

	-- Check if "gamecenter" is running and if so, get a srcollpane to add the elements to,
	-- otherwise create a window.
	gamecenterResource = getResourceFromName("gamecenter")

	if gamecenterResource then
		gui.window = call(gamecenterResource,"addWindow","Settings","Race Minimap",500,560)
	else
		gui.window = guiCreateWindow ( 320, 240, 500, 560, "Race Minimap settings", false )
	end
	
	-- Create the actual elements
	
	-- TABS
	gui.tabs = guiCreateTabPanel(0,24,500,400,false,gui.window)
	gui.tabGeneral = guiCreateTab("General",gui.tabs)
	addHelp("General settings for the minimap.",gui.tabGeneral)
	gui.tabStyles = guiCreateTab("Styles",gui.tabs)
	addHelp("Styling settings.",gui.tabStyles)
	gui.tabHelp = guiCreateTab("Help", gui.tabs)

	-----------------
	-- TAB GENERAL --
	-----------------
	gui.enabled = guiCreateCheckBox(24,20,100,20,"Enable",s("enabled"),false,gui.tabGeneral)
	addHelp("Show or hide the Minimap.",gui.enabled)

	gui.size = guiCreateEdit(100,50,80,20,tostring(s("size")),false,gui.tabGeneral)
	addHelp("The size (height) of the minimap (relative to screen resolution).",gui.size,
		guiCreateLabel(24,50,70,20,"Size:",false,gui.tabGeneral))
	addEditButton(190,50,60,20,"smaller",false,gui.tabGeneral,{mode="add",edit=gui.size,add=-0.01})
	addEditButton(260,50,60,20,"bigger",false,gui.tabGeneral,{mode="add",edit=gui.size,add=0.01})
	addEditButton(330,50,60,20,"default",false,gui.tabGeneral,{mode="set",edit=gui.size,value=s("size","default")})

	guiCreateLabel(24, 140, 60, 20, "Position:", false, gui.tabGeneral )

	gui.top = guiCreateEdit( 140, 140, 60, 20, tostring(s("top")), false, gui.tabGeneral )
	addHelp("The relative position of the upper left corner of the minimap, from the top border of the screen.",gui.top,
		guiCreateLabel(100, 140, 40, 20, "Top:", false, gui.tabGeneral ))

	addEditButton(258, 140, 40, 20, "up", false, gui.tabGeneral, {mode="add",edit=gui.top,add=-0.01})
	addEditButton(258, 166, 40, 20, "down", false, gui.tabGeneral, {mode="add",edit=gui.top,add=0.01})
	
	gui.left = guiCreateEdit( 140, 166, 60, 20, tostring(s("left")), false, gui.tabGeneral )
	addHelp("The relative position of the upper left corner of the minimap, from the left border of the screen.",gui.left,
		guiCreateLabel(100, 166, 40, 20, "Left:", false, gui.tabGeneral))
	addEditButton(210, 166, 40, 20, "left", false, gui.tabGeneral, {mode="add",edit=gui.left,add=-0.01})
	addEditButton( 306, 166, 40, 20, "right", false, gui.tabGeneral, {mode="add",edit=gui.left,add=0.01})
	
	addEditButton(360, 166, 50, 20, "default", false, gui.tabGeneral,
		{mode="set",edit=gui.top,value=s("top","default")},
		{mode="set",edit=gui.left,value=s("left","default")}
	)


	gui.updateinterval = guiCreateEdit(120,240,80,20,tostring(s("updateinterval")),false,gui.tabGeneral)
	addHelp("How often to refresh the position of each dot, in seconds.",gui.updateinterval,
		guiCreateLabel(24, 240, 100, 20, "Update Interval:", false, gui.tabGeneral))
	addEditButton(210,240,60,20,"smaller",false,gui.tabGeneral,{mode="add",edit=gui.updateinterval,add=-0.1})
	addEditButton(280,240,60,20,"bigger",false,gui.tabGeneral,{mode="add",edit=gui.updateinterval,add=0.1})
	addEditButton(350,240,60,20,"default",false,gui.tabGeneral,{mode="set",edit=gui.updateinterval,value=s("updateinterval","default")})

	-- gui.preferNear = guiCreateCheckBox(24,300,280,20,"Prefer players behind or in front of you",s("preferNear"),false,gui.tabGeneral)
	-- addHelp("Draws players directly before or in front of you on top of the other players, so you know who you race against. If you have this enabled, the shuffle or sorting functions have no effect for those players affected by this setting.",gui.preferNear)

	-- addRadioButtons(24,234,"sortMode",{
	-- 	{text="Sort playernames by length",value="length",help="This affects how playernames that are close to eachother overlap. If this option is selected, shorter playernames will be drawn ontop."},
	-- 	{text="Shuffle playernames",value="shuffle",help="This affects how playernames that are close to eachother overlap. If this option is selected, the order in which the playernames are drawn changes randomly."},
	-- 	{text="Sort playernames by rank",value="rank",help="This affects how playernames that are close to eachother overlap. If this option is selected, playernames of players who have a higher rank are preferred and drawn ontop."}
	-- },s("sortMode"))

	----------------
	-- TAB STYLES --
	----------------
	
	guiCreateLabel(165,40,40,20,"Red",false,gui.tabStyles)
	guiCreateLabel(220,40,40,20,"Green",false,gui.tabStyles)
	guiCreateLabel(275,40,40,20,"Blue",false,gui.tabStyles)
	guiCreateLabel(325,40,40,20,"Alpha",false,gui.tabStyles)

	addColor("lineColor","Line Color",60,"Color of the track line.")
	addColor("shadowColor","Shadow Color",84,"Colored of the track line's drop shadow.")
	-- addColor("barColor","Bar Color",60,"Background color of the progress bar.")
	-- addColor("progressColor","Progress",84,"Color of the bar the fills the background depending on your progress.")
	-- addColor("fontColor","Font",108,"The color of the text, except your own name and distance.")
	-- addColor("font2Color","Font (yours)",132,"The color of your own name and distance.")
	-- addColor("backgroundColor","Background",156,"The background color of the text, except your own name and distance.")
	-- addColor("background2Color","Background (yours)",180,"The background color of your own name and distance.")
	-- addColor("fontDelayColor","Font (delay)",204,"The font color of the delay times.")
	-- addColor("backgroundDelayColor","Background (delay)",228,"The background color of the delay times.")
	
	--------------
	-- TAB HELP --
	--------------
	
	local helpText = xmlNodeGetValue(getResourceConfig("help.xml"))
	gui.helpTextMemo = guiCreateMemo(.05, .05, .9, .9, helpText, true, gui.tabHelp)
	guiMemoSetReadOnly(gui.helpTextMemo, true)

	--------------------
	-- ALWAYS VISIBLE --
	--------------------
	gui.helpMemo = guiCreateMemo(0,440,500,80, "[Move over GUI to get help]", false, gui.window)
	guiHelpMemo = gui.helpMemo

	gui.buttonSave = guiCreateButton( 0, 530, 260, 20, "Save Settings To File", false, gui.window )
	addHelp("Saves current settings to file, so that they persist when you reconnect.",gui.buttonSave)
	gui.buttonClose = guiCreateButton( 280, 530, 235, 20, "Close", false, gui.window )

	-- Events and "gamecenter" stuff
	if gamecenterResource then
		guiSetEnabled(gui.buttonClose,false)
	else
		guiSetVisible(gui.window,false)
		g_showGuideLines = false
	end
	addEventHandler("onClientGUIClick",gui.window,handleClick)
	addEventHandler("onClientGUIChanged",gui.window,handleEdit)
	addEventHandler("onClientMouseEnter",gui.window,handleHelp)
end

--[[
-- As soon as the "gamecenter" resource is started, this will create the GUI
-- if it wasn't already (if it is created, it will also be added to the gamecenter gui).
-- ]]
addEventHandler("onClientResourceStart",getRootElement(),
	function(resource)
		if getResourceName(resource) == "gamecenter" then
			-- Create the GUI as soon as the gamecenter-resource starts (if it hasn't been created yet)
			createGui()
			--recreateGui()
		elseif resource == getThisResource() then
			if getResourceFromName("gamecenter") then
				createGui()
			end
		end
	end
)

-- TODO: check if this can somehow work
addEventHandler("onClientResourceStop",getRootElement(),
	function(resource)
		if getResourceName(resource) == "gamecenter" then
			--recreateGui()
		end
	end
)

--[[
-- Destroys all GUI elements of the settings GUI and creates them again.
-- TODO: not working nor used
-- ]]
function recreateGui()
	for k,v in pairs(gui) do
		if isElement(v) then
			outputConsole(getElementType(v).." "..guiGetText(v))
			destroyElement(v)
		end
	end
	gui = {}
	createGui()
end

--[[
-- Opens the GUI, as well as creates it first (if necessary). Will call
-- gamecenter to open the appropriate window if it is running.
-- ]]
function openGui()
	-- Create the GUI as soon as someone tries to open it (if it hasn't been created yet)
	createGui()
	checkKeyInfo(true) -- Also changes title
	
	if gamecenterResource then
		exports.gamecenter:open("Settings","Race Minimap")
	else
		guiSetVisible(gui.window,true)
		showCursor(true)
		g_showGuideLines = true
	end
end

--[[
-- Either hides the window or asks gamecenter to close its gui, if it is running.
-- ]]
function closeGui()
	if gamecenterResource then
		exports.gamecenter:close()
	else
		guiSetVisible(gui.window,false)
		showCursor(false)
		g_showGuideLines = false
	end
end

--------------
-- Commands --
--------------

--[[
-- Shows the gui if it is hidden and vice versa.
-- ]]
function toggleGui()
	if gui.window ~= nil and guiGetVisible(gui.window) then
		closeGui()
	else
		openGui()
	end
end
addCommandHandler("minimap",toggleGui)

function toggleBooleanSetting(element, name)
	settingsObject:set(name, not s(name))
	if element ~= nil then
		guiCheckBoxSetSelected(element, s(name))
	end
	startTimer()
	plotMapPoints()
	prepareDraw()
end

function toggleEnabled()
	toggleBooleanSetting(gui.enabled, "enabled")
end
addCommandHandler("minimap_toggle", toggleEnabled)

function toggleDebugEnabled()
	settingsObject:set("debug", not s("debug"))
	outputChatBox("[Minimap] Debug "..(s("debug") and "enabled" or "disabled"))
end
addCommandHandler("minimap_toggleDebug", toggleDebugEnabled)

------------------
-- Key Handling --
------------------

local keyDown = 0
local longPress = 300
local keyTimer = nil

--[[
-- Called when a key is pressed/released and checks how long it was pressed
-- as well as starts a timer that will open the gui if necessary.
--
-- @param   string   key: The key that was pressed
-- @param   string   keyState: The state of the key ("up", "down")
-- ]]
function keyHandler(key,keyState)
	-- if keyState == "down" then
	-- 	keyDown = getTickCount()
	-- 	keyTimer = setTimer(keyTimerHandler,longPress,1)
	-- else
	-- 	-- Key was released, kill timer if it is running
	-- 	-- to prevent the GUI from opening
	-- 	if isTimer(keyTimer) then
	-- 		killTimer(keyTimer)
	-- 	end
	-- 	-- Calculate the time passed, and if the timer wasn't yet executed,
	-- 	-- toggle the progress bar
	-- 	local timePassed = getTickCount() - keyDown
	-- 	keyDown = 0
	-- 	if timePassed < longPress then
	-- 		toggleEnabled()
	-- 	end
	-- end
-- end
-- function keyTimerHandler()
	toggleGui()
end
bindKey(toggleSettingsGuiKey,"down",keyHandler)

function checkKeyInfo(force)
	if not keyInfo:isAllowed() and not force then
		return
	end
	local key = getKeyBoundToFunction(keyHandler)
	if type(key) == "string" then
		toggleSettingsGuiKey = key
		keyInfo:showIfAllowed()
		if gui.window ~= nil then
			guiSetText(gui.window, "Race Minimap settings (hold "..toggleSettingsGuiKey.." to toggle)")
		end
	elseif gui.window ~= nil then
		guiSetText(gui.window, "Race Minimap settings")
	end
end

-- keyInfo.drawFunction = function(fade)
-- 	drawText(toggleSettingsGuiKey.." (press/hold)", g_left, g_top + g_size + 5, tocolor(255,255,255), tocolor(0,0,0,120), true)
-- end

