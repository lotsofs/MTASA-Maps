local switch = 0
local dartboardX1 = 3900
local dartboardX2 = 0
local dartboardX3 = 0
local totalScore = 0
local sx, sy = guiGetScreenSize()
local lvl = 0
local c = {}
local barrel = {}
local scores = {}
local krakenInnit = 0
local showStartText = 1
elementDataKey = "Pscore"
elementDataKey2 = "Lscore"
setElementData (localPlayer, elementDataKey , 0, true)
setElementData (localPlayer, elementDataKey2 , 0, true)
innit = false


addEventHandler( "onClientResourceStart", getRootElement( ),
    function ()
		white = guiCreateStaticImage(0, 0, sx, sy, "files/white.png", false )
		guiSetVisible (white, true )
		MVG = guiCreateStaticImage(sx/2-414, sy/2-414, 829, 829, "files/MVG.jpg", false )
		guiSetVisible (MVG, true )
		dartMark = createMarker(0,0,0,"corona",4,255,255,0,100)
		startFreeze()
		setTimer(function()
			guiSetVisible (white, false)
			guiSetVisible (MVG, false)
			updateScores()
		end, 4000, 1)
		setTimer(function()
			showStartText = 0
		end, 8000, 1)
    end
);

function startFreeze()
	local veh = getPedOccupiedVehicle(localPlayer)
	if veh then
		setElementFrozen(veh, true)
	end
end
addEvent( "freezeStart", true )
addEventHandler( "freezeStart", localPlayer, startFreeze )

function onClientRender()
	if totalScore <= 59 then
		if showStartText == 1 then
			dxDrawText("Score 60 points to win!", 0, 0, sx+5, sy+5, tocolor(0, 0, 0, 255), 5, "default-bold", "center", "center")
			dxDrawText("Score 60 points to win!", 0, 0, sx, sy, tocolor(255, 255, 255, 255), 5, "default-bold", "center", "center")
		end
		if switch == 0 and showStartText == 0 then
			local veh = getPedOccupiedVehicle(localPlayer)
			if veh then
				setElementFrozen(veh, false)
			end
			x, y, z = getElementPosition(localPlayer)
			if lvl == 0 then
				xt = x - dartboardX1
			elseif lvl == 1 then
				xt = x - dartboardX2
			elseif lvl == 2 then
				xt = x - dartboardX3
			end
			zt = z - 65.3
			trigg = math.sqrt(xt^2 + zt^2)
			if y <= -1947.5 and trigg <= 50 then
				dartScore()
			end
		end
		if switch == 1 and showStartText == 0 then
			dxDrawText("You scored " .. score .. " points", 0, sy/2, sx+5, sy+5, tocolor(0, 0, 0, 255), 5, "default-bold", "center", "center")
			dxDrawText("You scored " .. score .. " points", 0, sy/2, sx, sy, tocolor(255, 255, 30, 255), 5, "default-bold", "center", "center")
			local veh = getPedOccupiedVehicle(localPlayer)
			if veh then
				setElementFrozen(veh, true)
			end
			if dartMark and isElement(dartMark) then
				if lvl == 0 then
					setElementPosition(dartMark, dartboardX1+xt, y-2, z)
				elseif lvl == 1 then
					setElementPosition(dartMark, dartboardX2+xt, y-2, z)		
				elseif lvl == 2 then
					setElementPosition(dartMark, dartboardX3+xt, y-2, z)
				end
			end
			local veh = getPedOccupiedVehicle(localPlayer)
			if veh then
				if lvl == 0 then
					setElementPosition(veh, dartboardX1+xt, y, z)
				elseif lvl == 1 then
					setElementPosition(veh, dartboardX2+xt, y, z)
				elseif lvl == 2 then
					setElementPosition(veh, dartboardX3+xt, y, z)
				end
			end
		end
		dxDrawText("Score: " .. totalScore, sx, (sy*0.12)+3, (sx*0.97)+3, sy, tocolor(0, 0, 0, 255), 3.5, "default-bold", "right")
		dxDrawText("Score: " .. totalScore, sx, sy*0.12, sx*0.97, sy, tocolor(255, 255, 30, 255), 3.5, "default-bold", "right")
		local players = getElementsByType("player")
		for i,player in ipairs(players) do
			if (i<11) then
				if innit then
					if scores[i][4] ~= 0 then
						if scores[i][4] <= 4 then
							dxDrawText("+"..scores[i][4],sx-148,((sy/4)+scores[i][1]*32)+2,sx,(sy/4)+scores[i][1]*32,tocolor(0,0,0,255),1.5,"arial","center","center",false,false,false,true)
							dxDrawText("+"..scores[i][4],sx-150,(sy/4)+scores[i][1]*32,sx,(sy/4)+scores[i][1]*32,tocolor(150,150,150,255),1.5,"arial","center","center",false,false,false,true)
						end
						if scores[i][4] >= 5 and scores[i][4] <= 7 then
							dxDrawText("+"..scores[i][4],sx-148,((sy/4)+scores[i][1]*32)+2,sx,(sy/4)+scores[i][1]*32,tocolor(0,0,0,255),1.5,"arial","center","center",false,false,false,true)
							dxDrawText("+"..scores[i][4],sx-150,(sy/4)+scores[i][1]*32,sx,(sy/4)+scores[i][1]*32,tocolor(190,190,190,255),1.5,"arial","center","center",false,false,false,true)
						end
						if scores[i][4] >= 8 and scores[i][4] <= 9 then
							dxDrawText("+"..scores[i][4],sx-148,((sy/4)+scores[i][1]*32)+2,sx,(sy/4)+scores[i][1]*32,tocolor(0,0,0,255),1.5,"arial","center","center",false,false,false,true)
							dxDrawText("+"..scores[i][4],sx-150,(sy/4)+scores[i][1]*32,sx,(sy/4)+scores[i][1]*32,tocolor(230,230,230,255),1.5,"arial","center","center",false,false,false,true)
						end
						if scores[i][4] == 10 then
							dxDrawRectangle (sx-310, (((sy/4))+(scores[i][1])*32)-14, 300,30, tocolor(255,255,0,100))
							dxDrawText("+"..scores[i][4],sx-148,((sy/4)+scores[i][1]*32)+2,sx,(sy/4)+scores[i][1]*32,tocolor(0,0,0,255),1.5,"arial","center","center",false,false,false,true)
							dxDrawText("+"..scores[i][4],sx-150,(sy/4)+scores[i][1]*32,sx,(sy/4)+scores[i][1]*32,tocolor(255,255,0,255),1.5,"arial","center","center",false,false,false,true)
						end
					end
					dxDrawText("Top Ten",sx-197,((sy/4)-25)+3,sx,(sy/4)-25,tocolor(0,0,0,255),2,"arial","left","center",false,false,false,true)
					dxDrawText("Top Ten",sx-200,(sy/4)-25,sx,(sy/4)-25,tocolor(255,255,255,255),2,"arial","left","center",false,false,false,true)
					dxDrawText(scores[i][1] .. ". " .. scores[i][2] .. "#FFFFFF     ",sx-298,((sy/4)+scores[i][1]*32)+2,sx*2/3,(sy/4)+scores[i][1]*32,tocolor(0,0,0,255),1.5,"arial","left","center",false,false,false,true)
					dxDrawText(scores[i][1] .. ". " .. scores[i][2] .. "#FFFFFF     ",sx-300,(sy/4)+scores[i][1]*32,sx*2/3,(sy/4)+scores[i][1]*32,tocolor(255,255,255,255),1.5,"arial","left","center",false,false,false,true)
					dxDrawText(scores[i][3],sx-58,((sy/4)+scores[i][1]*32)+2,sx,(sy/4)+scores[i][1]*32,tocolor(0,0,0,255),1.5,"arial","center","center",false,false,false,true)
					dxDrawText(scores[i][3],sx-60,(sy/4)+scores[i][1]*32,sx,(sy/4)+scores[i][1]*32,tocolor(255,255,255,255),1.5,"arial","center","center",false,false,false,true)
				end
			end
		end
	end
end
addEventHandler("onClientRender", root, onClientRender)

function updateScores()
	if totalScore <= 59 then
		scoreTicker = setTimer( function ()
			local players = getElementsByType("player")
			table.sort(players,comp)
			for i,player in ipairs(players) do
				if (i<11) then
					local scorey = getElementData(player,elementDataKey)
					local lastScore = getElementData(player,elementDataKey2)
					if not scorey then return end
					if (scorey)then
						local playerName = string.gsub(getPlayerName(player), "#%x%x%x%x%x%x", "") 
						local playerNam = string.sub(playerName, 1, 16)
						scores[i] = {i, playerNam, scorey, lastScore}
						innit = true
					end
				end
			end
		end, 300, 0)
	else
		killTimer (scoreTicker)
	end
end

function dartScore ()
	-- x, y, z = getElementPosition(localPlayer)
	-- if lvl == 0 then
	-- 	xt = x - dartboardX1
	-- elseif lvl == 1 then
	-- 	xt = x - dartboardX2
	-- elseif lvl == 2 then
	-- 	xt = x - dartboardX3
	-- end
	-- zt = z - 65.3
	local theta = math.atan(zt / xt)
	local dtheta = math.deg(theta)

	if (zt > 0 and xt < 0) then iprint("Top right") end -- right = 0, top = 90
	if (zt < 0 and xt < 0) then iprint("Bottom right") end -- right = 0, bottom = -90
	if (zt < 0 and xt > 0) then iprint("Bottom left") end -- left = 0, bottom = -90
	if (zt > 0 and xt > 0) then iprint("Top left") end -- left = 0, top = 90

	-- x > 0 = left
	-- 20: 81-90
	-- 5: 63-81
	-- 12: 45 - 63
	-- 9: 27 - 45
	-- 14: 9 - 27 
 	-- 11: -9 - 9
	-- 8: -27 - -9
	-- 16: -45 - -27
	-- 7: -63 - -45
	-- 19: -81 - -63
	-- 3: -90 - -81

	-- x < 0 = right
	-- 20: 81-90
	-- 1: 63-81
	-- 18: 45 - 63
	-- 4: 27 - 45
	-- 13: 9 - 27 
 	-- 6: -9 - 9
	-- 10: -27 - -9
	-- 15: -45 - -27
	-- 2: -63 - -45
	-- 17: -90 - -63
	-- 3: -90 - -81

	-- outer rim (non scoring zone): 132.647058824% 225.5mm
	-- outer wire: 100% 170mm
	-- triple inner wire: 95.2941176471% 8mm
	-- double outer wire: 62.9411764706% 107mm
	-- double inner wire: 58.2352941176% 99mm
	-- outer bull wire: 9.41176470588% 16mm
	-- inner bull wire 7.47058823529% 12.7mm



	switch = 1
	setCameraMatrix(3850 + (500*lvl), -1821, 90, 3900 + (500*lvl), -1926, 70)
	local trig = trigg / 5
	if trig >= 10 then
		trig = 10
	end
	if switch == 1 then
		score = 10 - math.floor(trig)
		if score >= 10 then
			score = 10
		end
	end
	setElementData (localPlayer, elementDataKey2, score, true)
	setTimer ( function ()
		switch = 2
		totalScore = totalScore + score
		if totalScore >= 60 then totalScore = 60 end
		setElementData (localPlayer, elementDataKey , totalScore, true)
		if totalScore >= 10 and lvl == 0 then
			lvl = 1
		end
		if totalScore >= 30 and lvl == 1 then
			lvl = 2
		end
		if totalScore >= 40 and krakenInnit == 0 then
			kraken()
		end
		if totalScore >= 60 and lvl == 2 then
			lvl = 3
		end
		local veh = getPedOccupiedVehicle(localPlayer)
		if veh then
			setElementFrozen(veh, false)
			setElementPosition(veh, 3900 + (500*lvl), -1363.1, 440)
			setElementRotation(veh, 0, 0, 180, "default", true)
			setElementAngularVelocity(veh, 0, 0, 0)
			setElementVelocity(veh, 0, 0, 0)
		end
		setElementPosition(dartMark, 0,0,0)
		setCameraTarget(localPlayer)
		setTimer ( function()
			score = 0
			setElementData (localPlayer, elementDataKey2, 0, true)
			switch = 0
		end, 50, 1)
	end, 3000, 1)
	
end

function respawn()
	setTimer( function()
		local veh = getPedOccupiedVehicle(localPlayer)
		if veh then
			setElementFrozen(veh, false)
			setElementPosition(veh, 3900 + (500*lvl), -1363.1, 440)
			setElementRotation(veh, 0, 0, 180, "default", true)
		end
	end, 500, 1)
end
addEventHandler("onClientPlayerWasted", localPlayer, respawn)

function syncMove (dx1, dx2)
	dartboardX2 = dx1
	dartboardX3 = dx2
end
addEvent( "moveSync", true )
addEventHandler( "moveSync", localPlayer, syncMove )

addEvent ( "updateClientTable", true ) 
addEventHandler ( "updateClientTable", root, 
    function ( theTable ) 
        c = theTable
    end 
)

function kraken()
	for b = 1, 100 do 
		if c[b][4] == 1237 then
			barrel[b] = createObject(c[b][4], c[b][1], c[b][2], c[b][3]+100, 48.8, 0, 0)
			setTimer( function ()
				moveObject(barrel[b], 5000, c[b][1], c[b][2], c[b][3]-0.6, 0, 0, 0, "OutBounce")
			end, math.random()*10000, 1)
		elseif c[b][4] ~= 1237 then
			barrel[b] = createObject(c[b][4], c[b][1], c[b][2], c[b][3]+100, 48.8, 0, 0)
			setTimer( function ()
				moveObject(barrel[b], 5000, c[b][1], c[b][2], c[b][3], 0, 0, 0, "OutBounce")
			end, math.random()*10000, 1)
		end
	end
	krakenInnit = 1
end

function comp(a,b)
	if not getElementData(a,elementDataKey) then return false end
	if not getElementData(b,elementDataKey) then return true end
	if (getElementData(a,elementDataKey)) > (getElementData(b,elementDataKey)) then
		return true
	else
		return false
	end
end