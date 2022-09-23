local leveltop = 0
local localPlayerLevel = "-"
local scoreLabel

function updateStuff()
	x,y,z = getElementPosition( localPlayer )
	level = math.floor(z  / 3 - 0.5)
	localPlayerLevel = level
	if (z == 700) then
		setElementData ( localPlayer, "Current level", "-" )
		setElementData ( localPlayer, "Max level", leveltop[localPlayer] )
		setElementData ( localPlayer, "Health", "0%" )
	else
		if (level > leveltop) then
			leveltop = level
			setElementData ( localPlayer, "Max level", leveltop )
		end
		if getElementData ( localPlayer,"Current level" ) ~= level then
			setElementData ( localPlayer, "Current level", level )
		end
		-- local healthText = math.floor(getElementHealth(localPlayer) + 0.5).."%"
		-- if healthText ~= getElementData(localPlayer,"Health") then--save a bit of bw
		-- 	setElementData ( localPlayer, "Health", healthText )
		-- end
	end
end
setTimer ( updateStuff, 200, 0 )

function level(dataName)
	if getElementType(source) ~= "player" then return end--only the player's data is relevant
	if dataName ~= "Current level" then return end--only the player's data is relevant
		local players = getElementsByType( "player" )
		local maxLevelPlayers = {}
		local maxLevel = 0
		for k,v in ipairs(players) do
			level = tonumber(getElementData ( v, "Current level" )) or 0
			if level > maxLevel and level < 100 then
				maxLevel = level
				maxLevelPlayers = {}
				table.insert ( maxLevelPlayers, getPlayerName(v) )
			elseif level == maxLevel then
				table.insert ( maxLevelPlayers, getPlayerName(v) )
			end
		end
		local text
		if #maxLevelPlayers == 1 then
			text = "Leader: "..maxLevelPlayers[1].." ("..maxLevel..")"
		elseif #maxLevelPlayers < 4 then
			text = "Leaders: "
			text = text..table.concat(maxLevelPlayers,",").." ("..maxLevel..")"
		else
			text = "Leader: -".." ("..maxLevel..")"
		end
		text = text.."\nYour level: "..localPlayerLevel
		if scoreLabel then
			guiSetText ( scoreLabel, text )
		end
end
addEventHandler ( "onClientElementDataChange",getRootElement(),level )

addEventHandler ( "onClientResourceStart",getResourceRootElement(getThisResource()),
	function()
		setElementData ( localPlayer, "Current level", "-" )
		setElementData ( localPlayer, "Max level", leveltop )
		--
		scoreLabel = guiCreateLabel ( 0, 0.1, 1, 0.5, "Leader: -\nYour level: 0", true )
		guiLabelSetColor ( scoreLabel, 100, 255, 100 )
		guiSetFont ( scoreLabel, "default-bold-small" )
		guiLabelSetHorizontalAlign ( scoreLabel, "center", false )
		--
		-- setTimer ( toggleControl, 2000, 1, "fire", false )
		-- setTimer ( toggleControl, 2000, 1, "enter_exit", false )
		--
		local instructions = guiCreateLabel ( 0, 0.2, 1, 0.5, "Reach the top of the Haystack!", true )
		guiSetFont ( instructions, "sa-gothic" )
		guiLabelSetColor ( instructions, 255, 100, 100 )
		guiLabelSetHorizontalAlign ( instructions, "center", false )
		setTimer ( destroyElement, 10000, 1, instructions )
		setCameraTarget ( localPlayer )
	end
)

-- addEventHandler ( "onClientResourceStop",getResourceRootElement(getThisResource()),
-- 	function()
-- 		toggleControl ( "fire", true )
-- 		toggleControl ( "enter_exit", true )
-- 	end
-- )

addEventHandler( "onClientPlayerSpawn", localPlayer,
	function()
		setTimer(function()
			r = 20
			angle = math.random(133, 308) --random angle between 0 and 359.99
			centerX = -12
			centerY = -10
			spawnX = r*math.cos(angle) + centerX --circle trig math
			spawnY = r*math.sin(angle) + centerY --circle trig math
			spawnAngle = 360 - math.deg( math.atan2 ( (centerX - spawnX), (centerY - spawnY) ) )
			setElementPosition ( localPlayer, spawnX, spawnY, 3.3 )
			setElementRotation(localPlayer, 0, 0, spawnAngle, "default", true)
			setCameraTarget(localPlayer) -- Make them face the haystack.
			-- Has to be on a timer and 112ms is the lowest it worked for me.
		end, 122, 1, localPlayer)
	end
)
