
addEvent"onMapStarting"

GhostPlayback = {}
GhostPlayback.__index = GhostPlayback

function GhostPlayback:create( map )
	local result = {
		map = map,
		bestTime = math.huge,
		racer = "",
		recording = {},
		hasGhost = false,
		ped = nil,
		vehicle = nil
		-- blip = nil
	}
	return setmetatable( result, self )
end

function GhostPlayback:destroy()
	if self.hasGhost then
		triggerClientEvent( "clearMapGhost", root )
	end
	self.ped = nil
	self.vehicle = nil
end

function GhostPlayback:deleteGhost()
	local mapName = getResourceName( self.map )
	-- if fileExists( "ghosts/" .. mapName .. ".ghost" ) then
	-- 	fileDelete( "ghosts/" .. mapName .. ".ghost" )
	-- 	self:destroy()
	-- 	playback = nil
	-- 	return true
	-- end
	return false
end

function GhostPlayback:loadGhost(which)
	if not which then
		which = "top"
	end

	-- Load the old ghost if there is one
	-- We must first retrieve the name of this ghost
	local mapName = getResourceName( self.map )
	local ghostResourceName

	local toc = xmlLoadFile("ghosts/" .. mapName .. ".toc")

	if not toc then
		-- Look for old file (backwards compatibility)
		local fileName = "ghosts/" .. mapName .. ".ghost"
		local old = xmlLoadFile( fileName )
		if not old then
			-- Look for .backup instead
			fileName = "ghosts/" .. mapName .. ".backup"
			local old = xmlLoadFile( fileName )
		end
		if old then
			-- Found old file, write it to a new table of contents
			xmlUnloadFile( old )
			ghostResourceName = fileName

			toc = xmlCreateFile( "ghosts/" .. mapName .. ".toc", "toc")
			if toc then
				top = xmlCreateChild( toc, "top" )
				if (top) then
					xmlNodeSetAttribute( top, "f", fileName)
				end	
				xmlSaveFile( toc )
				xmlUnloadFile( toc )
			end
		end
	else
		local top = xmlFindChild( toc, which, 0 )
		if top then
			ghostResourceName = xmlNodeGetAttribute(top, "f") or false
		end

		xmlUnloadFile( toc )
	end
	if not ghostResourceName then return end

	local ghost = xmlLoadFile( ghostResourceName )

	if ghost then
		-- Retrieve info about the ghost maker
		local info = xmlFindChild( ghost, "i", 0 )
		if info then
			self.racer = xmlNodeGetAttribute( info, "r" ) or "unknown"
			self.bestTime = tonumber( xmlNodeGetAttribute( info, "t" ) ) or math.huge
		end

		-- Construct a table
		local index = 0
		local node = xmlFindChild( ghost, "n", index )
		self.recording = {}
		while (node) do
			if type( node ) ~= "userdata" then
				outputDebugString( "race_ghost - playback_server.lua: Invalid node data while loading ghost: " .. type( node ) .. ":" .. tostring( node ), 1 )
				break
			end

			local attributes = xmlNodeGetAttributes( node )
			local row = {}
			for k, v in pairs( attributes ) do
				row[k] = convert( v )
			end
			table.insert( self.recording, row )
			index = index + 1
			node = xmlFindChild( ghost, "n", index )
		end
		xmlUnloadFile( ghost )

		-- Validate
		local bValidForMap = isBesttimeValidForMap( self.map, self.bestTime )
		local bValidForRecording = isBesttimeValidForRecording( self.recording, self.bestTime )
		if not bValidForMap or not bValidForRecording then

			-- TODO: Erase the time from the toc

			-- -- Use backup file if it exists
			-- local backup = xmlLoadFile( "ghosts/" .. mapName .. ".backup" )
			-- if backup then
			-- 	xmlUnloadFile( backup )
			-- 	copyFile( "ghosts/" .. mapName .. ".ghost", "ghosts/" .. mapName .. ".invalid" )
			-- 	copyFile( "ghosts/" .. mapName .. ".backup", "ghosts/" .. mapName .. ".ghost" )
			-- 	fileDelete( "ghosts/" .. mapName .. ".backup" )
			-- 	outputDebugServer( "Trying backup as found an invalid ghost file", mapName, nil, " (Besttime not valid for recording. Error: " .. getRecordingBesttimeError( self.recording, self.bestTime ) .. ")" )
			-- 	self.recording = {}
			-- 	return self:loadGhost()
			-- end
			if not bValidForMap then
				outputDebugServer( "Found an invalid ghost file", mapName, nil, " (Besttime not valid for map. Error: " .. getMapBesttimeError( self.map, self.bestTime ) .. ")" )
			end
			if not bValidForRecording then
				outputDebugServer( "Found an invalid ghost file", mapName, nil, " (Besttime not valid for recording. Error: " .. getRecordingBesttimeError( self.recording, self.bestTime ) .. ")" )
			end
			return false
		end

		-- Create the ped & vehicle
		for _, v in ipairs( self.recording ) do
			if v.ty == "st" then
				-- Check start is near a spawnpoint
				local bestDist = math.huge
				for _,spawnpoint in ipairs(getElementsByType("spawnpoint")) do
					bestDist = math.min( bestDist, getDistanceBetweenPoints3D( v.x, v.y, v.z, getElementPosition(spawnpoint) ) )
				end
				if bestDist > 5 then
					for _,spawnpoint in ipairs(getElementsByType("spawnpoint_onfoot")) do
						bestDist = math.min( bestDist, getDistanceBetweenPoints3D( v.x, v.y, v.z, getElementPosition(spawnpoint) ) )
					end
				end
				if bestDist > 5 then
					outputDebugServer( "Found an invalid ghost file", mapName, nil, " (Spawn point too far away - " .. bestDist .. ")" )
					return false
				end
				self.ped = { p = v.p, x = v.x, y = v.y, z = v.z }
				self.vehicle = { m = v.m, x = v.x, y = v.y, z = v.z, rx = v.rX, ry = v.rY, rz = v.rZ }
				outputDebugServer( "Found a valid ghost", mapName, nil, " (Besttime dif: " .. getRecordingBesttimeError( self.recording, self.bestTime ) .. ")" )
				self.hasGhost = true
				return true
			end
		end
	end
	outputDebugServer( "No ghost file", mapName, nil )
	return false
end

function GhostPlayback:sendGhostData( target, playbackID )
	if self.hasGhost then
		triggerClientEvent( target or root, "onClientGhostDataReceive", root, self.recording, self.bestTime, self.racer, self.ped, self.vehicle, playbackID )
	end
end

addEventHandler( "onMapStarting", root,
	function()
		if topPlayback then
			topPlayback:destroy()
		end
		if personalPlayback then
			personalPlayback:destroy()
		end

		local mapName = exports.mapmanager:getRunningGamemodeMap()
		topPlayback = GhostPlayback:create( mapName )
		topPlayback:loadGhost()
		topPlayback:sendGhostData()
		personalPlayback = GhostPlayback:create( mapName )
		for i, v in pairs(getElementsByType("player")) do
			-- if (i > 1) then break end
			vName = removeColorCoding((getPlayerName(v)))
			hasPB = personalPlayback:loadGhost("pb_" .. vName:gsub('[%p%c%s]', ''))
			if (hasPB) then
				personalPlayback:sendGhostData(v, "pb")   
			end
		end
	end
)

addEventHandler( "onPlayerJoin", root,
	function()
		triggerClientEvent( source, "race_ghost.updateOptions", resourceRoot, g_GameOptions ); -- We need to send server settings first or it's going to throw errors
		if topPlayback then
			topPlayback:sendGhostData( source )
		end
		if personalPlayback then
			vName = removeColorCoding((getPlayerName(source)))
			local hasPB = personalPlayback:loadGhost("pb_" .. vName:gsub('[%p%c%s]', ''))
			if (hasPB) then
				personalPlayback:sendGhostData(source, "pb")   
			end
		end
	end
)

function convert( value )
	if tonumber( value ) ~= nil then
		return tonumber( value )
	else
		if tostring( value ) == "true" then
			return true
		elseif tostring( value ) == "false" then
			return false
		else
			return tostring( value )
		end
	end
end
