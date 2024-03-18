hideThisMap = false
hideType = "0"
afkCount = 0
screenWidth = 0
screenHeight = 0
showAFKWarning = false

function init()
	triggerServerEvent( "clientAsksForHideType", resourceRoot)
	triggerServerEvent( "clientAsksForCanHide", resourceRoot)

	screenWidth,screenHeight = guiGetScreenSize()
end
addEventHandler('onClientResourceStart', resourceRoot, init)
addCommandHandler ("login", function() setTimer(init, 1000, 1) end)

addEvent( "canHide", true )
addEventHandler("canHide", root, function() 
	hideThisMap = true;

	if hideType == "0" then
		-- do nothing lol
	elseif hideType == "1" then
		--outputChatBox ("Players hidden by distance for this map")
	elseif hideType == "2" then
		hidePlayersFull()
		--outputChatBox ("Players hidden for this map")
	end
end 
)

addEvent( "cantHide", true )
addEventHandler("cantHide", root, function() 
	hideThisMap = false
	if hideType == "0" then
		-- do nothing lol
	elseif hideType == "1" or hideType == "2" then
		--outputChatBox ("Cannot hide other players on this map")
	end
end 
)

function mapEnded()
	hideThisMap = false
end
addEventHandler("onClientMapStopping",getRootElement(),mapEnded)

function mapStarted()
	if hideType == "0" then
		-- do nothing lol
	elseif hideType == "1" or hideType == "2" then
		triggerServerEvent( "clientAsksForCanHide", resourceRoot)
	end
end
addEventHandler("onClientMapStarting",localPlayer,mapStarted)

addEvent( "receiveHideType", true )
function receiveHideType(type)
	previousHideType = hideType

	--outputChatBox("Hide type is: " .. tostring(type) .. " Hide this map is: ".. tostring(hideThisMap))

	hideType = type

	if previousHideType == "0" then
		triggerServerEvent( "clientAsksForCanHide", resourceRoot)
	end

	if previousHideType == "2" and hideThisMap == true and hideType ~= "2" then
		for index, players in ipairs(getElementsByType("player")) do
			if players ~= getLocalPlayer() then
				currentDimension = getElementDimension(getLocalPlayer())
				
				setElementDimension(getPedOccupiedVehicle(players), currentDimension)
				setElementDimension(players, currentDimension)
				setElementAlpha(getPedOccupiedVehicle (players), 140)
				setElementAlpha(players, 140)
			end
		end
	elseif previousHideType == "1" and hideThisMap == true and hideType ~= "1" then
		for index, players in ipairs(getElementsByType("player")) do
			if players ~= getLocalPlayer() then
				setElementAlpha(getPedOccupiedVehicle (players), 140)
				setElementAlpha(players, 140)
			end
		end
	end

	if hideType == "2" and hideThisMap == true then
		hidePlayersFull()
	end

	if hideType == "0" then
		setElementAlpha(getPedOccupiedVehicle(getLocalPlayer()), 140)
		setElementAlpha(getLocalPlayer(), 140)
		outputChatBox ("ASS setting: Not hiding players", 153, 51, 0)
	elseif hideType == "1" then
		outputChatBox ("ASS setting: Hiding players by distance", 153, 51, 0)
	elseif hideType == "2" then
		outputChatBox ("ASS setting: Hiding all players", 153, 51, 0)
	end

end	
addEventHandler("receiveHideType",getRootElement(),receiveHideType)

function hidePlayersFull ( )
	if hideThisMap and hideType == "2" then
		currentDimension = getElementDimension(getLocalPlayer())

		for index, players in ipairs(getElementsByType("player")) do
			if players ~= getLocalPlayer() then
				setElementDimension(getPedOccupiedVehicle(players), currentDimension+1)
				setElementDimension(players, currentDimension+1)
			end
		end
		setElementAlpha(getPedOccupiedVehicle(getLocalPlayer()), 255)
		setElementAlpha(getLocalPlayer(), 255)

		setTimer(hidePlayersFull, 5000, 1)
	end
end

function hidePlayersDistance ( )
	if hideThisMap and hideType == "1" then

		clientPositionX, clientPositionY, clientPositionZ = 
			getElementPosition(getPedOccupiedVehicle(getLocalPlayer()))

		for index, otherPlayer in ipairs(getElementsByType("player")) do
			if otherPlayer ~= getLocalPlayer() then
				otherPlayerVehicle = getPedOccupiedVehicle(otherPlayer)

				otherPlayerPositionX, otherPlayerPositionY, otherPlayerPositionZ = 
				getElementPosition(otherPlayerVehicle)

				distanceToPlayer = getDistanceBetweenPoints3D(clientPositionX, clientPositionY,
					clientPositionZ, otherPlayerPositionX, otherPlayerPositionY, otherPlayerPositionZ)

				if distanceToPlayer ~= false then

					distanceToPlayer = math.max((distanceToPlayer * 10) - 50, 0)

					if distanceToPlayer <= 255 then
						setElementAlpha(otherPlayerVehicle, distanceToPlayer)
						setElementAlpha(otherPlayer, distanceToPlayer)
					end
				end
			end
		end

		setElementAlpha(getPedOccupiedVehicle(getLocalPlayer()), 255)
		setElementAlpha(getLocalPlayer(), 255)
	end
end

addEvent( "goAFK", true )
addEventHandler("goAFK", root, function() 
	executeCommandHandler("spectate")
end 
)

addEvent( "warnAFK", true )
addEventHandler("warnAFK", root, function() 
	showAFKWarning = true

	setTimer(function()
		showAFKWarning = false
	end, 500, 1)
end 
)

function onPreRender ()
	hidePlayersDistance()

	if showAFKWarning then
		dxDrawBorderedText (1, "AFK!", (screenWidth / 2) - 300, (screenHeight / 2) - 300, 1000, 1000, tocolor ( 255, 255, 255, 255 ), 10, "pricedown")
	end
end
addEventHandler ( "onClientPreRender", root, onPreRender )

function dxDrawBorderedText (outline, text, left, top, right, bottom, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
    local outline = (scale or 1) * (1.333333333333334 * (outline or 1))
    dxDrawText (text:gsub("#%x%x%x%x%x%x", ""), left - outline, top - outline, right - outline, bottom - outline, tocolor (0, 0, 0, 225), scale, font, alignX, alignY, clip, wordBreak, postGUI, false, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
    dxDrawText (text:gsub("#%x%x%x%x%x%x", ""), left + outline, top - outline, right + outline, bottom - outline, tocolor (0, 0, 0, 225), scale, font, alignX, alignY, clip, wordBreak, postGUI, false, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
    dxDrawText (text:gsub("#%x%x%x%x%x%x", ""), left - outline, top + outline, right - outline, bottom + outline, tocolor (0, 0, 0, 225), scale, font, alignX, alignY, clip, wordBreak, postGUI, false, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
    dxDrawText (text:gsub("#%x%x%x%x%x%x", ""), left + outline, top + outline, right + outline, bottom + outline, tocolor (0, 0, 0, 225), scale, font, alignX, alignY, clip, wordBreak, postGUI, false, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
    dxDrawText (text:gsub("#%x%x%x%x%x%x", ""), left - outline, top, right - outline, bottom, tocolor (0, 0, 0, 225), scale, font, alignX, alignY, clip, wordBreak, postGUI, false, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
    dxDrawText (text:gsub("#%x%x%x%x%x%x", ""), left + outline, top, right + outline, bottom, tocolor (0, 0, 0, 225), scale, font, alignX, alignY, clip, wordBreak, postGUI, false, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
    dxDrawText (text:gsub("#%x%x%x%x%x%x", ""), left, top - outline, right, bottom - outline, tocolor (0, 0, 0, 225), scale, font, alignX, alignY, clip, wordBreak, postGUI, false, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
    dxDrawText (text:gsub("#%x%x%x%x%x%x", ""), left, top + outline, right, bottom + outline, tocolor (0, 0, 0, 225), scale, font, alignX, alignY, clip, wordBreak, postGUI, false, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
    dxDrawText (text, left, top, right, bottom, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
end