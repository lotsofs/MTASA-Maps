
-- ### Variables

-- # Please don't edit unless you know what you do

root = getRootElement()
currentText = "Loading text failed."
currentVersion = 0
currentLastChanged = ""
waitForMessage = false
local screenWidth, screenHeight = guiGetScreenSize()



-------------------------
-- Edit Gui (for Admins)
-------------------------

editgui = {}

--[[
-- createEditGui
--
-- Creates the edit Gui if it isn't already created.
-- ]]
function createEditGui()
	if editgui.window ~= nil then
		return
	end

	editgui.window = guiCreateWindow(screenWidth/2 - width/2, screenHeight/2 - height/2,width,height,"Edit Motd (Version "..currentVersion..")", false )

	editgui.memo = guiCreateMemo(14,30,width - 14*2,height - 70,"",false,editgui.window)

	editgui.closeButton = guiCreateButton(width - 120,height - 30, 100,20,"Close",false,editgui.window)
	addEventHandler("onClientGUIClick",editgui.closeButton,closeEditGui,false)

	editgui.saveButton = guiCreateButton(20,height - 30,100,20,"Save",false,editgui.window)
	addEventHandler("onClientGUIClick",editgui.saveButton,saveEditGui,false)

	editgui.dontIncreaseVersion = guiCreateCheckBox(130,height - 30,140,20,"Don't increase version",false,false,editgui.window)

	guiSetVisible(editgui.window,false)
end

--[[
-- openEditGui
--
-- Opens the edit gui and requests the current data from the server.
-- ]]
function openEditGui()
	createEditGui()
	guiSetVisible(editgui.window,true)
	showCursor(true)
	sendMessageToServer("get")
end
--[[
-- closeEditGui
--
-- Hides the edit gui.
-- ]]
function closeEditGui()
	guiSetVisible(editgui.window,false)
	showCursor(false)
end

--[[
-- saveEditGui
--
-- Sends the current text and the value of the increase version checkbox
-- to the server.
--]]
function saveEditGui()
	local text = guiGetText(editgui.memo)
	local dontIncreaseVersion = guiCheckBoxGetSelected(editgui.dontIncreaseVersion)
	sendMessageToServer("save",{text,dontIncreaseVersion})
end



--------------
-- Normal Gui
--------------

gui = {}

--[[
-- createGui
--
-- Creates the motd gui if it isn't already created.
-- ]]
function createGui()
	if gui.window ~= nil then
		return
	end
	if (screenWidth <= 1280) and (screenHeight <= 820) then
		gui.window = guiCreateWindow ( screenWidth/2 - width/2, screenHeight/2 - height/2, width, height, "Message of the day", false )

		local imageHeight2 = 0
		if image ~= "" and image ~= nil then
			gui.image = guiCreateStaticImage( width/2 - imageWidth/2, 30, imageWidth, imageHeight, image, false, gui.window )
			imageHeight2 = imageHeight + 10
		end
	
		gui.memo = guiCreateMemo(margin,30 + imageHeight2,width - 2*margin,height - 116 - imageHeight2,currentText,false,gui.window)
		guiMemoSetReadOnly(gui.memo,true)

		gui.closeButton = guiCreateButton(margin,height - 76,width - 2*margin,40,"Close",false,gui.window)
		addEventHandler("onClientGUIClick",gui.closeButton,closeGui,false)

		local checked = getSettings()
		gui.checkbox = guiCreateCheckBox(20,height - 20 - margin + 4,240,20,"Don't show again until text changes",checked,false,gui.window)
		addEventHandler("onClientGUIClick",gui.checkbox,toggleCheckbox,false)

		gui.label = guiCreateLabel(width - 160,height - 20 - margin + 8,200,20,"last changed "..currentLastChanged:sub(1,10),false,gui.window)
	else
		gui.window = guiCreateWindow ( screenWidth/3 - width/3, screenHeight/3 - height/3, width * 1.5, height * 1.5, "Message of the Day", false )

		local imageHeight2 = 0
		if image ~= "" and image ~= nil then
			gui.image = guiCreateStaticImage( width/3 - imageWidth/3, 30, imageWidth * 1.5, imageHeight * 1.5, image, false, gui.window )
			imageHeight2 = imageHeight + 10
		end
	
		gui.memo = guiCreateMemo(margin,30 + imageHeight2,(width - 2*margin) * 1.5,(height - 116 - imageHeight2) * 1.5,currentText,false,gui.window)
		guiMemoSetReadOnly(gui.memo,true)

		gui.closeButton = guiCreateButton(margin,(height - 76) * 1.5,(width - 2*margin) * 1.5,40 * 1.5,"Close",false,gui.window)
		addEventHandler("onClientGUIClick",gui.closeButton,closeGui,false)

		local checked = getSettings()
		gui.checkbox = guiCreateCheckBox(20,(height - 20 - margin + 4) * 1.5,240 * 1.5,20 * 1.5,"Don't show again until text changes",checked,false,gui.window)
		addEventHandler("onClientGUIClick",gui.checkbox,toggleCheckbox,false)

		gui.label = guiCreateLabel(width - 160,(height - 20 - margin + 8) * 1.5,200 * 1.5,20 * 1.5,"last changed "..currentLastChanged:sub(1,10),false,gui.window)
	end

	guiSetVisible(gui.window,false)
end


--[[
-- openGui
--
-- Opens the motd GUI on request or on join. If on join,
-- it checks if the motd should be shown.
--
-- @param   boolean   onJoin: Whether the function has been called on join.
-- ]]
function openGui(onJoin)
	
	-- get the current message and version first, but only if it hasn't already been requested
	if not waitForMessage then
		sendMessageToServer("get")
	end

	-- if message not yet received, stop
	if currentVersion == 0 then
		waitForMessage = true
		return
	end
	waitForMessage = false
	
	-- then check if motd should be shown on join
	if onJoin == true then
		local dontOpen,lastViewed = getSettings()
		if dontOpen and lastViewed == currentVersion then
			return
		end
	end

	-- create gui if necessary and show
	createGui()
	guiSetVisible(gui.window,true)
	showCursor(true)

	-- motd is shown, so update last viewed
	updateLastViewedMotdVersion(currentVersion)
end
addCommandHandler("motd",openGui)


--[[
-- closeGui
--
-- Hides the Gui.
-- ]]
function closeGui()
	guiSetVisible(gui.window,false)
	showCursor(false)
end


--[[
-- toggleCheckbox
--
-- Gets the state of the checkbox and saves it.
-- ]]
function toggleCheckbox()
	local checked = guiCheckBoxGetSelected(source)
	changeSetting(checked)
end



-----------------------------------------------------
-- Settings (read and write "dont show again" stuff)
-----------------------------------------------------

local serverNode = {tag="server",create=true,attribute={ip=serverIp,port=serverPort}}

--[[
-- getSettings
--
-- Gets the current settings from the local XML file
--
-- @return   mixed: The settings
-- ]]
function getSettings()
	settings:open()
	local dontShowMotdAgain = settings:getAttribute(serverNode,"dontShowMotdAgain")
	local welcomeVersion = tonumber(settings:getAttribute(serverNode,"lastViewedMotdVersion"))
	settings:unload()
	if dontShowMotdAgain == "true" then
		return true,welcomeVersion
	end
	return false
end

--[[
-- changeSettings
--
-- Sets whether the motd should be shown again in the local XML file.
--
-- @param   boolean   dontShowMotdAgain: Whether the motd should be shown again.
-- ]]
function changeSetting(dontShowMotdAgain)
	--settings:setAttribute("root","dontShowWelcome",dontShowWelcome)
	settings:setAttribute(serverNode,"dontShowMotdAgain",dontShowMotdAgain)
end

--[[
-- updateLastViewedMotdVersion
--
-- Sets the given motd version as the last viewed.
--
-- @param   number   version: The version
-- ]]
function updateLastViewedMotdVersion(version)
	settings:setAttribute(serverNode,"lastViewedMotdVersion",version)
end

-- ## on start of resource

--[[
-- initiate
--
-- Initiate the XML File and try to open the gui (this is on join).
-- ]]
function initiate()
	settings = Xml:new("settings.xml","settings")
	openGui(true)
end
addEventHandler("onClientResourceStart",getResourceRootElement(getThisResource()),initiate)



-------------------------------
-- Client/Server Communication
-------------------------------

--[[
-- sendMessageToServer
--
-- Sends the given message with some data to the server.
--
-- @param   string   message: The 'type' of the message
-- @param   mixed    parameter: Any data (e.g. a table)
-- ]]
function sendMessageToServer(message,parameter)
	triggerServerEvent("onMotdClientMessage",root,message,parameter)
end

--[[
-- serverMessage
--
-- Handles message sent from the server.
--
-- @param   string   message: The 'type' of the message
-- @param   mixed    parameter: The data
-- ]]
function serverMessage(message,parameter)
	--outputDebugString("Motd server message: "..tostring(message).." "..tostring(parameter))
	if message == "get" then
		currentText = parameter[1]
		currentVersion = parameter[2]
		currentLastChanged = parameter[3]
		if gui.window ~= nil then
			guiSetText(gui.memo,currentText)
			guiSetText(gui.label,"last changed "..currentLastChanged:sub(1,10))
		end
		if waitForMessage then
			openGui(true)
		end
		if editgui.window ~= nil then
			guiSetText(editgui.memo,currentText)
			guiSetText(editgui.window,"Edit Motd (Version "..currentVersion..", "..currentLastChanged..")")
		end
	end
	if message == "edit" then
		openEditGui()
	end
end
addEvent("onClientMotdServerMessage",true)
addEventHandler("onClientMotdServerMessage",root,serverMessage)


