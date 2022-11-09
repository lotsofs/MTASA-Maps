g_Root = getRootElement()

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
		vehicle = nil,
		blip = nil
	}
	return setmetatable( result, self )
end

function GhostPlayback:destroy()
	if self.hasGhost then
		triggerClientEvent( "clearMapGhost", g_Root )
	end
	if isElement( self.ped ) then
		destroyElement( self.ped )
		outputDebug( "Destroyed ped." )
	end
	if isElement( self.vehicle ) then
		destroyElement( self.vehicle )
		outputDebug( "Destroyed vehicle." )
	end
	if isElement( self.blip ) then
		destroyElement( self.blip )
		outputDebug( "Destroyed blip." )
	end
	self = nil
end

function GhostPlayback:loadGhost(which)
	if not which then
		which = "top"
	end

	-- Load the old ghost if there is one
	-- LotsOfS: We must now first retrieve the name of the ghost
	local mapName = getResourceName( self.map )
	local ghostResourceName

	local toc = xmlLoadFile( "ghosts/" .. mapName .. ".toc")
	
	if not toc then
		-- Find old file (backwards compatibility)
		local fileName = "ghosts/" .. mapName .. ".ghost"
		local old = xmlLoadFile( fileName )
		if not old then
			-- Look for .backup instead
			fileName = "ghosts/" .. mapName .. ".backup"
			local old = xmlLoadFile( fileName )
		end
		if old then
			-- Found old file, write it to the table of contents
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
			
		-- Create the ped & vehicle
		for _, v in ipairs( self.recording ) do
			if v.ty == "st" then
				self.ped = createPed( v.p, v.x, v.y, v.z )
				self.vehicle = createVehicle( v.m, v.x, v.y, v.z, v.rX, v.rY, v.rZ )
				self.blip = createBlipAttachedTo( self.ped, 0, 1, 150, 150, 150, 50 )
				setElementParent( self.blip, self.ped )
				warpPedIntoVehicle( self.ped, self.vehicle )
				
				outputDebugString( "Found a valid ghost file for " .. mapName )
				self.hasGhost = true
				return true
			end
		end
		return true
	end
	return false
end

function GhostPlayback:sendGhostData( target, playbackID )
	if self.hasGhost then
		triggerClientEvent( target or g_Root, "onClientGhostDataReceive", g_Root, self.recording, self.bestTime, self.racer, self.ped, self.vehicle, playbackID )
	end
end

addEventHandler( "onMapStarting", g_Root,
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
			vName = removeColorCoding((getPlayerName(v)))
			personalPlayback:loadGhost("user_" .. vName:gsub('[%p%c%s]', ''))
			personalPlayback:sendGhostData(v, "pb")   
		end
	end
)

function removeColorCoding ( name )
	return type(name)=='string' and string.gsub ( name, '#%x%x%x%x%x%x', '' ) or name
end

addEventHandler( "onPlayerJoin", g_Root,
	function()
		if topPlayback then
			topPlayback:sendGhostData( source )
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
