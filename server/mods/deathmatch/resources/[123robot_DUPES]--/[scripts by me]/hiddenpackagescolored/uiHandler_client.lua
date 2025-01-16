_popupText = "Colored hidden package collected!\n1000 out of 1000\n10 out of 10 in LONG REGION NAME WOWOWOW abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
_popupColor = {0,0,0}
_popupTimer = 0

POPUP_TIME = 300
--DEBUG_UI = true

function drawUI()
	local screenWidth,screenHeight = guiGetScreenSize()
	if (DEBUG_UI) then
		screenWidth,screenHeight = debugUI()
	end

	drawMiniOverlay(screenWidth,screenHeight)
	drawPopupText(screenWidth,screenHeight)
	drawBigTable(screenWidth,screenHeight)
end
addEventHandler("onClientRender", root, drawUI)

function debugUI()
	local x = 800
	local y = 600
	_popupTimer = 9999
	dxDrawRectangle(0, 0, x, y, tocolor(0, 0, 0, 102), false)
	return x,y
end

function updatePopupText(text,r,g,b)
	_popupColor = {r,g,b}
	_popupText = text
	_popupTimer = POPUP_TIME
end

function drawPopupText(width, height)
	if (_popupTimer <= 0) then
		return
	end
	_popupTimer = _popupTimer - 1
	local titleX = width * 0
	local titleY = height * 0
	local titleWidth = width*1
	local titleHeight = height*0.9
	local titleFont = height / 160
	drawBorderedText( _popupText, titleFont * 0.5, titleX, titleY, titleWidth, titleHeight, tocolor(_popupColor[1], _popupColor[2], _popupColor[3], 255), titleFont, "default-bold", "center", "center", false, true, false, false)
end

function drawBorderedText(text, borderSize, width, height, width2, height2, color, size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	text2 = string.gsub(text, "#%x%x%x%x%x%x", "")
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