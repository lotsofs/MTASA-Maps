---- Scoreboard and UI stuff
---- Scoreboard and UI stuff
---- Scoreboard and UI stuff
---- Scoreboard and UI stuff
---- Scoreboard and UI stuff
---- Scoreboard and UI stuff
---- Scoreboard and UI stuff
---- Scoreboard and UI stuff
---- Scoreboard and UI stuff

SCREENWIDTH, SCREENHEIGHT = guiGetScreenSize()

SHOW_TUTORIAL = false
SHOW_MID_PLAY_TUTORIAL = false
SHOW_CAR = false

TEXT = ""
TUTORIAL_BLURB = "<blurb>"
MID_PLAY_BLURB = "<blurb>"
CAR_BLURB = "wwwwwwww"

function drawHudOverlay()
	if (SHOW_TUTORIAL) then
		drawBorderedText(TUTORIAL_BLURB, 2, SCREENWIDTH*0.20, SCREENHEIGHT*0.25, SCREENWIDTH*0.8, SCREENHEIGHT, tocolor(255, 255, 255, 255), 3, "default-bold", "center", "top", false, true, true, true)
	end
	if (SHOW_MID_PLAY_TUTORIAL) then
		drawBorderedText(MID_PLAY_BLURB, 2, SCREENWIDTH*0.25, SCREENHEIGHT*0.75, SCREENWIDTH*0.75, SCREENHEIGHT, tocolor(255, 255, 255, 255), 2, "default-bold", "center", "top", false, true, true, true)
	end
	if (SHOW_CAR) then
		drawBorderedText(CAR_BLURB, 2, SCREENWIDTH*0.2, SCREENHEIGHT*0.88, SCREENWIDTH*0.98, SCREENHEIGHT, tocolor(54, 104, 44, 255), 3, "bankgothic", "left", "top", false, false, true, true)
	end
end
addEventHandler("onClientRender", root, drawHudOverlay)

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