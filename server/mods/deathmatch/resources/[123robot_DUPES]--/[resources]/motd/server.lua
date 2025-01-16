
root = getRootElement()
settings = Xml:new("motd.xml","motd")
defaultText = "Put your text here."


--[[
-- clientMessage
--
-- Handles messages received from a client. Saves the motd
-- if an admin edited it or sends the motd to the player.
--
-- @param   string   message: The 'type' of message
-- @param   mixed    parameter: Any data
-- ]]
function clientMessage(message,parameter)
	local player = client

	if message == "get" then
		sendMotdToClient(player)
	end

	if message == "save" then
		if not hasObjectPermissionTo(player,"resource.motd.edit",false) then
			return
		end
		local text = parameter[1]
		local dontIncreaseVersion = parameter[2]

		settings:open()
		if not dontIncreaseVersion then
			local currentVersion = tonumber(settings:getAttribute("root","version"))
			settings:setAttribute("root","version",currentVersion + 1)
		end
		settings:setAttribute("root","lastChanged",makeCurrentDatetime())
		settings:setValue("root",text)
		settings:save(true)
		sendMotdToClient(player)
	end
end

--[[
-- sendMotdToClient
--
-- Sends the current motd (read from an XML file on the server) to the given player.
--
-- @param   player   player: The player to whom the motd should be sent.
-- ]]
function sendMotdToClient(player)
	settings:open()
	local text = settings:getValue("root")
	local version = tonumber(settings:getAttribute("root","version"))
	local lastChanged = settings:getAttribute("root","lastChanged")
	settings:unload()

	--outputDebugString("text: "..tostring(text).." version: "..tostring(version))
	sendMessageToClient(player,"get",{text,version,lastChanged})
end

--[[
-- sendMessageToClient
--
-- Sends any message to the given players client.
--
-- @param   player   player: The player to whom the message should be sent
-- @param   string   message: The 'type' of message
-- @param   mixed    parameter: Any data that should be sent
-- ]]
function sendMessageToClient(player,message,parameter)
	triggerClientEvent(player,"onClientMotdServerMessage",root,message,parameter)
end

addEvent("onMotdClientMessage",true)
addEventHandler("onMotdClientMessage",root,clientMessage)

--[[
-- edit
--
-- Opens the edit gui for a player on request (if he has permission).
--
-- @param   player    player: The player
-- ]]
function edit(player)
	if hasObjectPermissionTo(player,"resource.motd.edit",false) then
		sendMessageToClient(player,"edit")
	end
end
addCommandHandler("editmotd",edit)

--[[
-- initiate
--
-- Initiates the XML file.
-- ]]
function initiate()
	settings:open()
	local text = settings:getValue("root")
	local version = tonumber(settings:getAttribute("root","version"))
	local lastChanged = settings:getAttribute("root","lastChanged")
	if text == "" or text == false then
		settings:setValue("root",defaultText)
	end
	if type(version) ~= "number" then
		settings:setAttribute("root","version",1)
	end
	if lastChanged == "" or lastChanged == false then
		settings:setAttribute("root","lastChanged","0000-00-00 00:00:00")
	end
	settings:save(true)
end
addEventHandler("onResourceStart",getResourceRootElement(getThisResource()),initiate)



------------------
-- Help functions
------------------

--[[
-- makeCurrentDatetime
--
-- Creates date and time (realtime, not ingame time) in the YYYY-MM-DD HH:MM:SS format.
-- ]]
function makeCurrentDatetime()
	local time = getRealTime()
	local year = time.year + 1900
	local month = fillDigits(time.month + 1)
	local day = fillDigits(time.monthday)
	local hour = fillDigits(time.hour)
	local minute = fillDigits(time.minute)
	local second = fillDigits(time.second)
	return year.."-"..month.."-"..day.." "..hour..":"..minute..":"..second
end

--[[
-- fillDigits
--
-- Adds leading zeros to a string, until it reaches a certain length.
--
-- @param   string   text: The string
-- @param   number   min: How long the string should at least be
-- ]]
function fillDigits(text,min)
	if min == nil then
		min = 2
	end
	local text = tostring(text)
	return string.rep("0",min - text:len())..text
end
