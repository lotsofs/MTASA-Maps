

local toggleGuiKey = "F4"


--### Development Mode ###

function enableDevMode(resource)
	setDevelopmentMode(true)
	outputChatBox("Enabled Development Mode (use 'showcol' command to make colshapes visible)")
	bindKey(toggleGuiKey,"down",toggleGui)
	outputChatBox("Toggle SCM Helper GUI with "..toggleGuiKey)
end
addEventHandler("onClientResourceStart", getResourceRootElement(), enableDevMode)

function disableDevMode(resource)
	setDevelopmentMode(false)
	outputChatBox("Disabled Development Mode")
	closeGui()
end
addEventHandler("onClientResourceStop", getResourceRootElement(), disableDevMode)

local originalWeather

function setClearWeather()
	originalWeather = getWeather()
	setWeather(0)
	setFogDistance(300)
end

function resetClearWeather()
	resetFogDistance()
	setWeather(originalWeather)
end

local opcodesDef = {"00A4:","00FE:","0395:","00FF:","01A6:","8100:","81AC:","80FE:","00B0:","03BA:"}
local gui = {}
local markers = {}
local blips = {}
local linePosition = {}
local previewMarker = nil
local previewRow = -1
local currentFocus
local lastTeleportTo
local wasFreecamEnabled = false

function openGui()
	createGui()
	guiSetVisible(gui.window, true)
	guiSetInputEnabled(true)
	wasFreecamEnabled = exports.freecam:isFreecamEnabled()
	exports.freecam:setFreecamDisabled()
	showCursor(true)
end

function closeGui()
	guiSetVisible(gui.window, false)
	guiSetInputEnabled(false)
	if wasFreecamEnabled then
		exports.freecam:setFreecamEnabled()
	end
	showCursor(false)
end

function isGuiOpen()
	return gui.window ~= nil and guiGetVisible(gui.window)
end

function toggleGui()
	if isGuiOpen() then
		closeGui()
	else
		openGui()
	end
end

function table.contains(table, element)
	for _,value in pairs(table) do
		if value == element then
			return true
		end
	end
	return false
end

local function setRowState(row, state)
	guiGridListSetItemText(gui.list, row, gui.stateColumn, state, false, false)
end

local function clearElements(elements)
	for _,element in pairs(elements) do
		destroyElement(element)
	end
end

local function clearMarkers()
	clearElements(markers)
	markers = {}
	if previewMarker ~= nil then
		destroyElement(previewMarker)
		previewRow = -1
		previewMarker = nil
	end
end

local function clearBlips()
	clearElements(blips)
	blips = {}
end

local function getSelectedMarker()
	local row,_ = guiGridListGetSelectedItem(gui.list)
	local marker = markers[row]
	if marker == nil then
		if previewMarker ~= nil then
			return previewMarker
		else
			return false
		end
	end
	return marker
end

local function cameraToSelected()
	local marker = getSelectedMarker()
	if not marker then
		return
	end
	local x,y,z = getElementPosition(marker)
	local freecamEnabled = false
	if exports.freecam:isFreecamEnabled() then
		exports.freecam:setFreecamDisabled()
		freecamEnabled = true
	end
	setCameraMatrix(x+30,y+30,z+20,x,y,z)
	if freecamEnabled then
		exports.freecam:setFreecamEnabled(x+20,y+20,z+20,x,y,z)
	end
end

local function clearPreview()
	local row,_ = guiGridListGetSelectedItem(gui.list)
	if previewMarker ~= nil then
		destroyElement(previewMarker)
		previewMarker = nil
		if previewRow ~= -1 then
			setRowState(previewRow, "")
			previewRow = -1
		end
	end
end

local function toggleMarkerForSelected()
	clearPreview()
	local row,_ = guiGridListGetSelectedItem(gui.list)
	local newState
	if markers[row] ~= nil then
		destroyElement(markers[row])
		destroyElement(blips[row])
		newState = ""
		markers[row] = nil
		blips[row] = nil
	else
		local code = guiGridListGetItemText(gui.list, row, gui.codeColumn)
		local result = createMarkerForCode(code)
		
		if result == false then
			newState = "Error"
		else
			markers[row] = result
			newState = "Showing"
			blips[row] = createBlipAttachedTo(result)
		end
	end
	guiGridListSetItemText(gui.list, row, gui.stateColumn, newState, false, false)
end



local function updateList()
	clearMarkers()
	clearBlips()
	guiGridListClear(gui.list)
	local text = guiGetText(gui.code)
	local lines = text:split("\n")

	local section
	local coordinates = {}
	local textPos = 0
	for i,line in ipairs(lines) do
		local split = line:split(" ")
		local checkForCoordinates = string.match(line, "^%d+@%s+=%s+(-?%d+%.%d+)%s*$")
		if split[1] ~= nil and split[1]:starts(":") then
			section = line
		elseif split[1] ~= nil and table.contains(opcodesDef, split[1]) then
			local row = guiGridListAddRow(gui.list)
			guiGridListSetItemText(gui.list, row, gui.lineColumn, tostring(i), false, true)
			guiGridListSetItemText(gui.list, row, gui.codeColumn, line, false, false)
		end
		if checkForCoordinates ~= nil then
			outputChatBox(checkForCoordinates)
			coordinates[#coordinates+1] = tonumber(checkForCoordinates)
			if #coordinates == 3 then
				local row = guiGridListAddRow(gui.list)
				line = section.." COORDINATES:"..coordinates[1].." "..coordinates[2].." "..coordinates[3]
				guiGridListSetItemText(gui.list, row, gui.lineColumn, tostring(i), false, true)
				guiGridListSetItemText(gui.list, row, gui.codeColumn, line, false, false)
			end
		else
			coordinates = {}
		end
		linePosition[i] = textPos
		textPos = textPos + line:len() + 1 -- Add 1 to adjust for linebreaks
	end
end


--### GUI Events ###

local function listItemChanged()
	local row,_ = guiGridListGetSelectedItem(gui.list)
	
	clearPreview()
	if row == -1 then
		return
	end
	
	-- Jump to selected line
	local codeLine = tonumber(guiGridListGetItemText(gui.list, row, gui.lineColumn))
	guiMemoSetCaretIndex(gui.code, guiGetText(gui.code):len()) -- Jump to end first, so selected line is always at the top
	guiMemoSetCaretIndex(gui.code, linePosition[codeLine])

	if guiCheckBoxGetSelected(gui.previewEnabled) and markers[row] == nil then
		local code = guiGridListGetItemText(gui.list, row, gui.codeColumn)
		local result = createMarkerForCode(code)
		if result then
			previewMarker = result
			previewRow = row
			setRowState(row, "Preview")
			if guiCheckBoxGetSelected(gui.previewCameraEnabled) then
				cameraToSelected()
			end
		else
			setRowState(row, "Error")
		end
	end
end

local function handleClick()
	if source == gui.closeButton then
		closeGui()
	elseif source == gui.parseButton then
		updateList()
	elseif source == gui.list then
		listItemChanged()
	elseif source == gui.clearWeatherButton then
		if guiCheckBoxGetSelected(gui.clearWeatherButton) then
			setClearWeather()
		else
			resetClearWeather()
		end
	elseif source == gui.morningTime then
		setTime(6,20)
	elseif source == gui.dayTime then
		setTime(12,00)
	elseif source == gui.fixedTime then
		if guiCheckBoxGetSelected(gui.fixedTime) then
			setMinuteDuration(2147483647)
		else
			setMinuteDuration(1000)
		end
	end
end

local function handleDoubleClick()
	if source == gui.list then
		toggleMarkerForSelected()
	end
end


local function isFocusOnEdit()
	if currentFocus == nil then
		return false
	end
	local elementType = getElementType(currentFocus)
	if elementType == "gui-memo" or elementType == "gui-edit" then
		return true
	end
	return false
end

local function handleKeyEvent(button, pressed)
	if not pressed then
		return
	end
	if isFocusOnEdit() then
		return
	end
	if button == "q" then
		toggleGui()
	end
	if not isGuiOpen() then
		return
	end
	if currentFocus == gui.list then
		local row,_ = guiGridListGetSelectedItem(gui.list)
		
		if button == "w" then
			if row == -1 then
				-- Start from the bottom when nothing is selected
				row = guiGridListGetRowCount(gui.list)
			end
			guiGridListSetSelectedItem(gui.list, row-1, 1)
			listItemChanged()
		elseif button == "s" then
			-- If nothing is selected, the row is -1, so it starts at the top
			guiGridListSetSelectedItem(gui.list, row+1, 1)
			listItemChanged()
		elseif button == "e" then
			toggleMarkerForSelected()
		elseif button == "t" then
			local marker = getSelectedMarker()
			local x,y,z = getElementPosition(marker)
			if lastTeleportTo == marker then
				z = z+20
			end
			lastTeleportTo = marker
			triggerServerEvent("teleportToMarker", getRootElement(), x, y, z)
		elseif button == "g" then
			cameraToSelected()
		end
	end
end

local function handleFocusEvent()
	currentFocus = source
end

--### Create GUI ###

function createGui()
	if gui.window ~= nil then
		return
	end

	gui.window = guiCreateWindow(320, 240, 1000, 560, "Stuff", false)
	gui.tabs = guiCreateTabPanel(0,20,1000,500,false,gui.window)
	gui.tabCode = guiCreateTab("Code",gui.tabs)
	gui.tabList = guiCreateTab("List",gui.tabs)
	gui.tabSettings = guiCreateTab("Settings/Help",gui.tabs)

	-- Code
	gui.code = guiCreateMemo(0, 0, 1000, 450, "00FE:   actor $PLAYER_ACTOR sphere 0 in_sphere 812.4495 -1343.488 12.532 radius 80.0 80.0 20.0 // Must be in this area to spawn taxi\n00A4:   actor $PLAYER_ACTOR sphere 0 in_cube_cornerA 685.9716 -1433.523 11.0857 cornerB 965.9512 -1379.386 14.9731 // If in this area, then the taxi spawns in the north", false, gui.tabCode)
	gui.parseButton = guiCreateButton(0, 450, 1000, 30, "Parse", false, gui.tabCode)

	-- List
	gui.list = guiCreateGridList(0,0,1000,450,false,gui.tabList)
	gui.lineColumn = guiGridListAddColumn(gui.list, "Line", 0.05)
	gui.codeColumn = guiGridListAddColumn(gui.list, "Code", 0.85)
	gui.stateColumn = guiGridListAddColumn(gui.list, "State", 0.1)

	gui.previewEnabled = guiCreateCheckBox(10,450,100,30,"Preview",false,false,gui.tabList)
	gui.previewCameraEnabled = guiCreateCheckBox(100,450,100,30,"Preview Camera",false,false,gui.tabList)

	-- Settings
	gui.clearWeatherButton = guiCreateCheckBox(12, 14, 200, 25, "Clear weather", false, false, gui.tabSettings)
	gui.morningTime = guiCreateButton(300, 14, 100, 25, "Set to morning", false, gui.tabSettings)
	gui.dayTime = guiCreateButton(420, 14, 100, 25, "Set to day", false, gui.tabSettings)
	gui.fixedTime = guiCreateCheckBox(540, 14, 200, 30, "Fixed Time", false, false, gui.tabSettings)
	gui.help = guiCreateMemo(10, 50, 800, 300, "You must enter 'showcol' into the console to show the wireframes\n\nShorcuts in List:\nW/S to go up/down the list\nG to move the camera to the selected entry (only if wireframe is showing)\nE to show wireframe for selected entry\nT to teleport to selected entry and give jetpack (only if wireframe is showing)", false, gui.tabSettings)

	gui.closeButton = guiCreateButton(0, 520, 1000, 30, "Close", false, gui.window)

	addEventHandler("onClientGUIClick", gui.window, handleClick)
	addEventHandler("onClientGUIDoubleClick", gui.window, handleDoubleClick)
	addEventHandler("onClientGUIFocus", gui.window, handleFocusEvent)
end

addEventHandler("onClientKey", getRootElement(), handleKeyEvent)
