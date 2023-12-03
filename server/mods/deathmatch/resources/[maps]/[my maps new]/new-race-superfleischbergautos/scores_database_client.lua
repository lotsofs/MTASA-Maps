---- Scoreboard and UI stuff
---- Scoreboard and UI stuff
---- Scoreboard and UI stuff
---- Scoreboard and UI stuff
---- Scoreboard and UI stuff
---- Scoreboard and UI stuff
---- Scoreboard and UI stuff
---- Scoreboard and UI stuff
---- Scoreboard and UI stuff

TEXT = ""
SHOW_SCOREBOARD = false

function setScoreBoard(scores)
	text = "Top times for the Full Experience:\n_______________________________________\n"
	for i, v in pairs(scores) do
		time_ = v["score"]
	
		milliseconds = time_ % 1000
		seconds = ((time_ - milliseconds) % 60000) / 1000
		minutes = (time_ - milliseconds - (seconds * 1000)) / 60000

		zeroSeconds = ""
		zeroMinutes = ""
		zeroMilliseconds = ""
		if (seconds < 10) then
			zeroSeconds = "0"
		end
		if (minutes < 10) then
			zeroMinutes = "0"
		end
		if (milliseconds < 10) then
			zeroMilliseconds = "00"
		elseif (milliseconds < 100) then
			zeroMilliseconds = "0"
		end
		timeText = zeroMinutes .. minutes .. ":" .. zeroSeconds .. seconds .. "." .. zeroMilliseconds .. milliseconds
		
		zeroPos = ""
		if (i < 10) then
			zeroPos = "0"
		end
		text = text .. zeroPos .. i .. ".   " .. timeText .. "    " .. v["playername"] .. "\n"
	end
	if (#scores < 10) then
		for i = #scores + 1, 10, 1 do
			zeroPos = ""
			if (i < 10) then
				zeroPos = "0"
			end
			text = text .. zeroPos .. i .. ".   -- Empty --\n"
		end
	end
	TEXT = text
end
addEvent("setScoreBoard", true)
addEventHandler("setScoreBoard", root, setScoreBoard)

function showScoreBoardCmd()
	showScoreBoard(true, 15000)
end

function showScoreBoard(enabled, duration)
	SHOW_SCOREBOARD = enabled
	if (duration) then
		setTimer(function()
			SHOW_SCOREBOARD = false
		end, duration, 1)
	end
end
addEvent("showScoreBoard", true)
addEventHandler("showScoreBoard", root, showScoreBoard)
addCommandHandler("showtimes", showScoreBoardCmd)

function drawScoreBoard()
	if (SHOW_SCOREBOARD) then
		local width,height = guiGetScreenSize()
		boxX = width * 0.275
		boxY = height * 0.015
		boxWidth = width * 0.18
		boxHeight = (boxWidth * 0.6875)
		dxDrawRectangle(boxX, boxY, boxWidth, boxHeight, tocolor(5, 33, 51, 127))
		dxDrawText(TEXT, width*0.28, height*0.025, width*0.8, height*0.9, tocolor(230, 245, 255, 255), width / 1600, "default-bold", "left", "top", false, true, false, false)
	end
	if (SHOW_TUTORIAL) then
		drawBorderedText(TUTORIAL_BLURB, 2, SCREENWIDTH*0.20, SCREENHEIGHT*0.25, SCREENWIDTH*0.8, SCREENHEIGHT, tocolor(255, 255, 255, 255), 3, "default-bold", "center", "top", false, true, true, false)
	end
	if (SHOW_MID_PLAY_TUTORIAL) then
		drawBorderedText(MID_PLAY_BLURB, 2, SCREENWIDTH*0.25, SCREENHEIGHT*0.75, SCREENWIDTH*0.75, SCREENHEIGHT, tocolor(255, 255, 255, 255), 2, "default-bold", "center", "top", false, true, true, false)
	end
end
addEventHandler("onClientRender", root, drawScoreBoard)

function drawBorderedText(text, borderSize, width, height, width2, height2, color, size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	text2 = string.gsub(text, "#%x%x%x%x%x%x", "")
	-- width = width * screenWidth
	-- height = height * screenHeight
	-- width2 = width2 * screenWidth
	-- height2 = height2 * screenHeight
	-- size = screenWidth * size * 0.0005
	-- borderSize = size

	dxDrawText(text2, width+borderSize, height, width2+borderSize, height2, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width, height+borderSize, width2, height2+borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width, height-borderSize, width2, height2-borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width-borderSize, height, width2-borderSize, height2, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width+borderSize, height+borderSize, width2+borderSize, height2+borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width-borderSize, height-borderSize, width2-borderSize, height2-borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width+borderSize, height-borderSize, width2+borderSize, height2-borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width-borderSize, height+borderSize, width2-borderSize, height2+borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text, width, height, width2, height2, color, size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
end