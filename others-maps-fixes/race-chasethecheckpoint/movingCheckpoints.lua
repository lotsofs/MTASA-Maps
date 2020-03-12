function aankleding()
	clr1 = math.random(0, 25) * 10
	clr2 = math.random(0, 25) * 10
	clr3 = math.random(0, 25) * 10
	clr4 = math.random(0, 25) * 10
	clr5 = math.random(0, 25) * 10
	clr6 = math.random(0, 25) * 10
	cde1 = math.random(0, 25) * 10
	cde2 = math.random(0, 25) * 10
	cde3 = math.random(0, 25) * 10
	cde4 = math.random(0, 25) * 10
	cde5 = math.random(0, 25) * 10
	cde6 = math.random(0, 25) * 10
	setSkyGradient(clr1, clr2, clr3, clr4, clr5, clr6)
	setWaterColor ( 255, 215, 0, 255 )
	setTime (0, 0)
end

function spelStart()
	luchtKleur = 0
	songOff = 0 -- 0 = geluid aan 1 = geluid uit
	snelheid = 50 -- in ms
	afstand = 1 -- in coords
	locX1 = 80
	locY1 = 4077.5
	locZ1 = 60
	locX2 = 80
	locY2 = 4117.5
	locZ2 = 60
	beweeg1 = 0 -- start bewegen
	beweeg2 = 0
	desX1 = 80
	desY1 = 4077.5
	desZ1 = 60
	desX2 = 80
	desY2 = 4117.5
	desZ2 = 60
	getX1 = 0
	getY1 = 0
	getZ1 = 0
	getX2 = 0
	getY2 = 0
	getZ2 = 0
	varX1 = 0
	varY1 = 0
	varZ1 = 0
	varX2 = 0
	varY2 = 0
	varZ2 = 0
	ran1 = 0 -- start willekeurig
	ran2 = 0
	scheef1 = 0
	scheef2 = 0
	prog1 = 0
	prog2 = 0
	arr = 0
	CP = 1
	stopMove = 0
	nep1 = createMarker(locX1, locY1, locZ1, "checkpoint", 5, 0, 0, 255, 255)
	nep2 = createMarker(locX2, locY2, locZ2, "checkpoint", 5, 0, 0, 255, 255)
	nep1Blip = createBlipAttachedTo(nep1, 0, 2, 0, 0, 255, 255, 0, 99999.0)
	nep2Blip = createBlipAttachedTo(nep2, 0, 1, 0, 0, 255, 255, 0, 99999.0)
	setMarkerTarget(nep1, locX2, locY2, locZ2)
	cpCollected = guiCreateLabel(0.5, 0.5, 1, 1, "", true)
	pricedown = guiCreateFont("files/pricedown.ttf", 21) 
	guiSetFont(cpCollected, pricedown)
end

function raakMarker(hitPlayer)
	if hitPlayer == localPlayer then
		if source == nep1 then
			--local markerX,markerY,markerZ = getElementPosition(nep1)
			--local playerX,playerY,playerZ = getElementPosition(localPlayer)
			--local schuin = math.pow(math.pow((markerX - playerX), 2) + math.pow((markerY - playerY), 2), 0.5)
			--if schuin <= 7.5 then
				if CP == 1 then
					guiSetText(cpCollected, CP.. "/9 checkpoint collected!")
				elseif CP <= 9 then
					guiSetText(cpCollected, CP.. "/9 checkpoints collected!")
				end
				if CP <= 8 then
					desX1 = desX2
					desY1 = desY2
					desZ1 = desZ2
					getX1 = getX2
					getY1 = getY2
					getZ1 = getZ2
					scheef1 = scheef2
					prog1 = prog2
					setElementPosition(nep1, varX2, varY2, varZ2)
				end
				if CP <= 7 then
					ran2 = 0
					locX2 = math.random(0, 180) - 10
					locY2 = math.random(4000, 4175) - 10
					locZ2 = 60
					setElementPosition(nep2, locX2, locY2, locZ2)
					prog2 = 0
				end
				if CP == 7 then
					--setMarkerIcon(nep2, "finish")
				end
				if CP == 8 then
					destroyElement(nep2)
					destroyElement(nep2Blip)
					setMarkerIcon(nep1, "finish")
					songSpeedup()
					afstand = 1.25
				end
				if CP >= 9 then
					stopMove = 1
					songStop()
					destroyElement(nep2)
					destroyElement(nep1Blip)
				end
				local vehicle = getPedOccupiedVehicle(localPlayer)
				local vehX,vehY,vehZ = getElementPosition(vehicle)
				local speedX, speedY, speedZ = getElementVelocity(vehicle)
				setElementPosition(vehicle, 080, 4077.5, 105)
				setElementPosition(vehicle, vehX,vehY,vehZ)
				setElementVelocity(vehicle, speedX, speedY, speedZ)
				--outputChatBox("CP " .. CP)
				CP = CP + 1
				setTimer(wacht, 100, 1)
				setTimer(removeText, 1000, 1)
			--end
		end
	--else
		--outputChatBox(getPlayerName(hitPlayer) .. " tried to steal your CP! :O")
	end
end

function wacht()
end

function removeText()
	guiSetText(cpCollected, "")
end

function beweegNep1()
	if ran1 == 0 then
		desX1 = math.random(0, 180) - 10
		desY1 = math.random(4000, 4175) - 10
		desZ1 = 60
		getX1,getY1,getZ1 = getElementPosition(nep1)
		scheef1 = math.floor(math.pow(math.pow((desX1 - getX1), 2) + math.pow((desY1 - getY1), 2), 0.5))
		ran1 = 1
	end
	local vararr = 0
	if snelheid > 1000 then
		vararr = 1
	else
		vararr = 1000 / snelheid
	end
	if arr == vararr then
		if CP <= 8 then
			setMarkerTarget(nep1,varX2,varY2,varZ2)
		end
		arr = 0
	end
	if stopMove == 0 then
		setTimer(bewegerNep1, snelheid, 1)
	end
end

function beweegNep2()
	if CP <= 8 then
		if ran2 == 0 then
			desX2 = math.random(0, 180) - 10
			desY2 = math.random(4000, 4175) - 10
			desZ2 = 60
			getX2,getY2,getZ2 = getElementPosition(nep2)
			scheef2 = math.floor(math.pow(math.pow((desX2 - getX2), 2) + math.pow((desY2 - getY2), 2), 0.5))
			ran2 = 1
		end
		luchtKleur = luchtKleur + 1
		setTimer(bewegerNep2, snelheid, 1)
	end
end

function bewegerNep1()
	arr = arr + 1
	prog1 = prog1 + afstand
	varX1 = getX1 + ((desX1 - getX1) / (scheef1 / afstand)) * prog1
	varY1 = getY1 + ((desY1 - getY1) / (scheef1 / afstand)) * prog1
	varZ1 = getZ1 + ((desZ1 - getZ1) / (scheef1 / afstand)) * prog1
	setElementPosition(nep1, varX1, varY1, varZ1)
	if prog1 > scheef1 then
		ran1 = 0
		prog1 = 0
	end
	beweegNep1()
end

function bewegerNep2()
	if luchtKleur >= 10 then
		if clr1 == cde1 then cde1 = math.random(0, 25) * 10 end
		if clr2 == cde2 then cde2 = math.random(0, 25) * 10 end
		if clr3 == cde3 then cde3 = math.random(0, 25) * 10 end
		if clr4 == cde4 then cde4 = math.random(0, 25) * 10 end
		if clr5 == cde5 then cde5 = math.random(0, 25) * 10 end
		if clr6 == cde6 then cde6 = math.random(0, 25) * 10 end
		if (clr1 - cde1) < 0 then clr1 = ((clr1 - cde1) + 10 + cde1) else clr1 = ((clr1 - cde1) - 10 + cde1) end
		if (clr2 - cde2) < 0 then clr2 = ((clr2 - cde2) + 10 + cde2) else clr2 = ((clr2 - cde2) - 10 + cde2) end
		if (clr3 - cde3) < 0 then clr3 = ((clr3 - cde3) + 10 + cde3) else clr3 = ((clr3 - cde3) - 10 + cde3) end
		if (clr4 - cde4) < 0 then clr4 = ((clr4 - cde4) + 10 + cde4) else clr4 = ((clr4 - cde4) - 10 + cde4) end
		if (clr5 - cde5) < 0 then clr5 = ((clr5 - cde5) + 10 + cde5) else clr5 = ((clr5 - cde5) - 10 + cde5) end
		if (clr6 - cde6) < 0 then clr6 = ((clr6 - cde6) + 10 + cde6) else clr6 = ((clr6 - cde6) - 10 + cde6) end
		setSkyGradient(clr1, clr2, clr3, clr4, clr5, clr6)
		luchtKleur = 0
	end
	prog2 = prog2 + afstand
	varX2 = getX2 + ((desX2 - getX2) / (scheef2 / afstand)) * prog2
	varY2 = getY2 + ((desY2 - getY2) / (scheef2 / afstand)) * prog2
	varZ2 = getZ2 + ((desZ2 - getZ2) / (scheef2 / afstand)) * prog2
	setElementPosition(nep2, varX2, varY2, varZ2)
	if prog2 > scheef2 then
		ran2 = 0
		prog2 = 0
	end
	beweegNep2()
end

addEventHandler("onClientResourceStart",getResourceRootElement(getThisResource()),aankleding)
addEventHandler("onClientResourceStart",getResourceRootElement(getThisResource()),spelStart)
addEventHandler("onClientMarkerHit",getResourceRootElement(getThisResource()),raakMarker)
addEventHandler("onClientResourceStart",getResourceRootElement(getThisResource()),beweegNep1)
addEventHandler("onClientResourceStart",getResourceRootElement(getThisResource()),beweegNep2)

function startMusic()
    setRadioChannel(0)
    song1Play()
	setTimer(song2Play, 3506, 1)
	outputChatBox("Map: Chase the Checkpoint Author: Bierbuikje and FantomicanYoshi")
	outputChatBox("Press M to mute the music.")
end

function song1Play()
	song1 = playSound("files/start.mp3",true)
	if songOff == 0 then
		setSoundVolume(song1,1)
	else
		setSoundVolume(song1,0)
	end
end

function song2Play()
	stopSound(song1)
	song2 = playSound("files/couplet.mp3",true)
	if songOff == 0 then
		setSoundVolume(song2,1)
	else
		setSoundVolume(song2,0)
	end
end

function makeRadioStayOff()
    setRadioChannel(0)
    cancelEvent()
end

function toggleSong()
    if songOff == 0 then
	    setSoundVolume(song1,0)
		setSoundVolume(song2,0)
		songOff = 1
		removeEventHandler("onClientPlayerRadioSwitch",getRootElement(),makeRadioStayOff)
	else
	    setSoundVolume(song1,1)
		setSoundVolume(song2,1)
		songOff = 0
		setRadioChannel(0)
		addEventHandler("onClientPlayerRadioSwitch",getRootElement(),makeRadioStayOff)
	end
end

function songSpeedup()
	if song1 then 
		stopSound(song1)
	end
	if song2 then
		stopSound(song2)
	end
    song1PlaySpeed()
    setTimer(song2PlaySpeed, 2806, 1)
end

function song1PlaySpeed()
	if CP <= 9 then
		song1 = playSound("files/start.mp3",true)
		setSoundSpeed(song1, 1.25)
		if songOff == 0 then
			setSoundVolume(song1,1)
		else
			setSoundVolume(song1,0)
		end
	else
	end
end

function song2PlaySpeed()
	if CP <= 9 then
		stopSound(song1)
		song2 = playSound("files/couplet.mp3",true)
		setSoundSpeed(song2, 1.25)
		if songOff == 0 then
			setSoundVolume(song2,1)
		else
			setSoundVolume(song2,0)
		end
	else
	end
end

function songStop()
	if song1 then 
		stopSound(song1)
	end
	if song2 then
		stopSound(song2)
	end
end

addEventHandler("onClientResourceStart",getResourceRootElement(getThisResource()),startMusic)
addEventHandler("onClientPlayerRadioSwitch",getRootElement(),makeRadioStayOff)
addEventHandler("onClientPlayerVehicleEnter",getRootElement(),makeRadioStayOff)
addCommandHandler("mkmap1_racetheme",toggleSong)
bindKey("m","down","mkmap1_racetheme")