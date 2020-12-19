local handling = {
	mass = 1500,				-- default 1500
	turnMass = 4000,			-- default 4000
	tractionMultiplier = 0.85,	-- default 0.7
	tractionLoss = 1.2,			-- default 0.9
	tractionBias = 0.5,			-- default 0.5
	maxVelocity = 200,			-- default 200
	engineAcceleration = 11.12,	-- default 11.12
}

local songs = {"camarofever", "andromeda", "silentstrike", "sexualizer", "overdrive", "breakpoint", "soelectric", "rollermobster"}
song = false

addEventHandler("onResourceStart", resourceRoot, function()
	chooseSong()
	
	-- Apply custom vehicle handling
	for property,value in pairs(handling) do
		setModelHandling(402, property, value)
	end
	
	-- Hide all world objects since we're not using the world
	for i=550,20000 do
		removeWorldModel(i,10000,0,0,0)
	end
	setOcclusionsEnabled(false)  -- Also disable occlusions when removing certain models
	setWaterLevel(-5000)         -- Also hide the default water as it will be full of holes
	
	setTimer(sendDownloadProgress, 100, 0)
end)

addEventHandler("onResourceStop", resourceRoot, function()
	-- Restore vehicle handling
	for property,_ in pairs(handling) do
		setModelHandling(402, property, nil)
	end
	
	restoreAllWorldModels()
end)

function chooseSong()
	-- Load songs played from XML
	local xml = xmlLoadFile("songs_played.xml")
	local xml_node = xmlFindChild(xml, "played", 0)
	local played_list = xmlNodeGetValue(xml_node)
	
	-- Split played_list into a table
	local played = {}
	for index in string.gmatch(played_list, '([^,]+)') do
		table.insert(played, tonumber(index))
	end
	
	-- Load song_indices with all possible song indices
	local song_indices = {}
	for i=1,#songs do
		song_indices[i] = true
	end
	
	-- Split played_list into a table of indices and remove each one from song_indices
	for _,index in pairs(played) do
		song_indices[index] = false
	end
	
	-- Make a new table of valid song choices
	local valid = {}
	for i,can_play in pairs(song_indices) do
		if can_play then
			table.insert(valid, i)
		end
	end
	
	-- Choose a song from the final list of valid, unplayed ids
	local song_index = valid[math.random(1,#valid)]
	song = songs[song_index]
	
	-- Add this song index to the played xml list
	if #played >= #songs-1 then -- If we've played the last song, wipe the list
		xmlNodeSetValue(xml_node, "")
	else
		table.insert(played, song_index)
		xmlNodeSetValue(xml_node, table.concat(played, ","))
	end
	
	-- Save and unload the XML file
	xmlSaveFile(xml)
	xmlUnloadFile(xml)
end

function sendSong(client, song_name)
	local f = fileOpen("songs/"..song..".mp3", true)
	local song_data = fileRead(f, fileGetSize(f))
	fileClose(f)
	
	triggerClientEvent(client, "onClientReceiveSongName", resourceRoot, song)
	triggerLatentClientEvent(client, "onClientReceiveSong", 1024*1024*2, resourceRoot, song, song_data) -- cap at 2MB/s, makes it 2s per song max, which is enough to start before race start
end

function sendDownloadProgress()
	for _,player in pairs(getElementsByType("player")) do
		local handles = getLatentEventHandles(player)
		if #handles > 0 then
			local status = getLatentEventStatus(player, handles[#handles])
			triggerClientEvent(player, "onClientReceiveSongProgress", root, status.percentComplete, status.totalSize, status.tickEnd)
		end
	end
end

addEvent("onClientRequestSong", true)
addEventHandler("onClientRequestSong", root, function()
	sendSong(client, song)
end)

addCommandHandler("song", function(player, command, songname)
	song = songname
	for _,player in pairs(getElementsByType("player")) do
		sendSong(player, song)
	end
end)

--[[
	in sendSong(), set downloading[player.id] = true
	every 100ms (500ms?), for all players in downloading, triggerClientEvent(player, "onClientReceiveSongProgress", songname, bytes, total) for that player
	in client->receiveSongData, triggerServerEvent("onServerPlayerSongReceived")
	in server->onServerPlayerSongReceived, set downloading[player.id] = false
]]