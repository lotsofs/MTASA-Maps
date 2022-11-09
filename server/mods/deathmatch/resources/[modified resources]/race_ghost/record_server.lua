addEvent( "onGhostDataReceive", true )

addEventHandler( "onGhostDataReceive", g_Root,
	function( recording, bestTime, racer, mapName, top, pb )
		-- May be inaccurate, if recording is still being sent when map changes
		--[[local currentMap = exports.mapmanager:getRunningGamemodeMap()
		local mapName = getResourceName( currentMap )--]]
		
		-- Create a backup in case of a cheater run -- LotsOfS: Now that we're storing everything, we no longer need to make dedicated backups
		-- local ghost = xmlLoadFile( "ghosts/" .. mapName .. ".ghost" )
		-- if ghost then
		-- 	local info = xmlFindChild( ghost, "i", 0 )
		-- 	local currentBestTime = math.huge
		-- 	if info then
		-- 		currentBestTime = tonumber( xmlNodeGetAttribute( info, "t" ) ) or math.huge
		-- 	end
		
		-- 	if currentBestTime ~= math.huge and currentBestTime - bestTime >= SUSPECT_CHEATER_LIMIT then -- Cheater?
		-- 		outputDebug( "Creating a backup file for " .. mapName .. ".backup" )
		-- 		copyFile( "ghosts/" .. mapName .. ".ghost", "ghosts/" .. mapName .. ".backup" )
		-- 	end
		-- 	xmlUnloadFile( ghost )
		-- end
		
		local filename = "ghosts/" .. mapName .. "_" .. racer:gsub('[%p%c%s]', '') .. "_" .. tostring( bestTime ) .. ".ghost"
		local ghost = xmlCreateFile( filename, "ghost" )
		if ghost then
			local info = xmlCreateChild( ghost, "i" )
			if info then
				xmlNodeSetAttribute( info, "r", tostring( racer ) )
				xmlNodeSetAttribute( info, "t", tostring( bestTime ) )
			end
		
			for _, info in ipairs( recording ) do
				local node = xmlCreateChild( ghost, "n" )
				for k, v in pairs( info ) do
					xmlNodeSetAttribute( node, tostring( k ), tostring( v ) )
				end
			end
			xmlSaveFile( ghost )
			xmlUnloadFile( ghost )
		else
			outputDebug( "Failed to create a ghost file!" )
		end

		if (not top and not pb) then return end

		local toc = xmlLoadFile( "ghosts/" .. mapName .. ".toc", "toc")
		if not toc then
			toc = xmlCreateFile( "ghosts/" .. mapName .. ".toc", "toc")
		end

		if toc then
			if top then
				local topNode = xmlFindChild( toc, "top", 0 )
				if not topNode then
					topNode = xmlCreateChild( toc, "top" )
				end
				if (topNode) then
					xmlNodeSetAttribute( topNode, "f", tostring( filename ))
				end
			end
			if pb then
				local pbNode = xmlFindChild( toc, "user_" .. racer:gsub('[%p%c%s]', ''), 0 )
				if not pbNode then
					pbNode = xmlCreateChild( toc, "user_" .. racer:gsub('[%p%c%s]', '') )
				end
				if (pbNode) then
					xmlNodeSetAttribute( pbNode, "f", tostring( filename ))
				end
			end
			xmlSaveFile(toc)
			xmlUnloadFile(toc)
		else
			outputDebug( "Failed to create toc file!" )
		end
	end
)