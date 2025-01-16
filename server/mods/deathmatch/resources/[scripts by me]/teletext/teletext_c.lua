
_previousSecond = 0

g_Pages = {}
g_CurrentPageNumber = 0

function getCurrentPage()
	return g_Pages[g_CurrentPageNumber]
end

WEEKDAYS = {
	[0] = "Sun",
	[1] = "Mon",
	[2] = "Tue",
	[3] = "Wed",
	[4] = "Thu",
	[5] = "Fri",
	[6] = "Sat",
}

function initialize()
	g_CurrentPageNumber = 100
	local page = Page:createBlank()

	-- |1234567890    5    0    5    0    5    01234|
	-- |--------------------------------------------|
	-- | P100 _CEEFAX_ 100   Thu 2024/01/01 12:00:00|
	-- |                                            |
	-- |   ▄█  ▄▀▀▄ ▄▀▀▄ █▀▀▄ ▄▀▀▄ █▀▀▄ ▄▀▀▄ ▀█▀▀   |
	-- |  ▀▀█  ▀  █ ▀  █ █  █ █  █ █  █ █  █  █     |
	-- |    █    ▄▀   ██ █▄█  █  █ █▀█  █  █  █     |
	-- |    █   █   ▄  █ █ ▀▄ █  █ █  █ █  █  █     |
	-- |  ▄▄█▄ █▄▄▄ ▀▄▄▀ █  █ ▀▄▄▀ █▄▄▀ ▀▄▄▀  █     |
	-- |                 Speedrunner's Server       |
	-- |                                            |
	-- |════════════════════════════════════════════|



  	page:replaceRowWithString( 3, "   ▄█  ▄▀▀▄ ▄▀▀▄ █▀▀▄ ▄▀▀▄ █▀▀▄ ▄▀▀▄ ▀█▀▀   ")
	page:replaceRowWithString( 4, "  ▀▀█  ▀  █ ▀  █ █  █ █  █ █  █ █  █  █     ")
	page:replaceRowWithString( 5, "    █    ▄▀   ██ █▄█  █  █ █▀█  █  █  █     ")
	page:replaceRowWithString( 6, "    █   █   ▄  █ █ ▀▄ █  █ █  █ █  █  █     ")
	page:replaceRowWithString( 7, "  ▄▄█▄ █▄▄▄ ▀▄▄▀ █  █ ▀▄▄▀ █▄▄▀ ▀▄▄▀  █     ")
	page:replaceRowWithString( 8, "                 Speedrunner's Server       ")
	page:replaceRowWithString( 9, "                                            ")
	page:replaceRowWithString(10, "═══ Choose ═════════════════════════════════")

	page:setBackgroundByBlock(1, 44, 11, 24, false)
	page:colorByBlock(1, 44, 2, 8, "#FFFF00", true)
	page:colorByBlock(1, 44, 9, 9, "#FFFFFF", true)
	page:colorByBlock(17, 42, 2, 8, "#0000FF")

	g_Pages[g_CurrentPageNumber] = page
end
addEventHandler( "onClientResourceStart", resourceRoot, initialize );

function drawTeletext()
	local width,height = guiGetScreenSize()
	l = 0
	t = 0
	r = width
	b = height
	fontX = width/308
	fontY = height/336

	bgChars = {}
	fgChars = {}
	for row=1,ROW_COUNT do
		for column=1,COLUMN_COUNT do
			bgChars[#bgChars+1] = getCurrentPage().backgroundColors[row][column]
			bgChars[#bgChars+1] = getCurrentPage().backgroundChars[row][column]
			fgChars[#fgChars+1] = getCurrentPage().foregroundColors[row][column]
			fgChars[#fgChars+1] = getCurrentPage().foregroundChars[row][column]
		end
		bgChars[#bgChars+1] = "\n"
		fgChars[#fgChars+1] = "\n"
	end
	local bgText = table.concat(bgChars)
	local fgText = table.concat(fgChars)

	dxDrawText(bgText, l, t, r, b, tocolor(0, 0, 0, 191), 		fontX, fontY, "unifont", "left", "top", false, false, true, true)
	dxDrawText(fgText, l, t, r, b, tocolor(255, 255, 255, 255), fontX, fontY, "unifont", "left", "top", false, false, true, true)
end

function update()
	headerSetDateTime()
	drawTeletext()
	headerSetInputNumber(math.random(100,999))
	headerSetPageNumber(g_CurrentPageNumber)
	headerSetName()
end
addEventHandler("onClientRender", root, update)

-- ----------------------------------------------
-- Header
-- | P100 _CEEFAX_ 100   Thu 2024/01/01 12:00:00|
-- ----------------------------------------------

function headerSetPageNumber(number)
	if (number < 100) then return end
	if (number > 999) then return end
	num_str = tostring(number)
	getCurrentPage():replaceChar(1, 1, " ")
	getCurrentPage():replaceChar(1, 2, "P")
	getCurrentPage():replaceChar(1, 3, num_str:sub(1,1))
	getCurrentPage():replaceChar(1, 4, num_str:sub(2,2))
	getCurrentPage():replaceChar(1, 5, num_str:sub(3,3))
	getCurrentPage():replaceChar(1, 6, " ")
	getCurrentPage():colorByBlock(1, 6, 1, 1, "#FFFFFF", true)
	getCurrentPage():colorByBlock(1, 6, 1, 1, "#000000", false)
end

function headerSetInputNumber(number)
	if (number > 999) then return end
	if (number < 0) then return end
	getCurrentPage():replaceChar(1, 15, " ")
	num_str = tostring(number)
	if (number < 10) then 
		getCurrentPage():replaceChar(1, 16, " ")
		getCurrentPage():replaceChar(1, 17, " ")
		getCurrentPage():replaceChar(1, 18, num_str:sub(1,1))
	elseif (number < 100) then 
		getCurrentPage():replaceChar(1, 16, " ")
		getCurrentPage():replaceChar(1, 17, num_str:sub(1,1))
		getCurrentPage():replaceChar(1, 18, num_str:sub(2,2))
	else
		getCurrentPage():replaceChar(1,16, num_str:sub(1,1))
		getCurrentPage():replaceChar(1,17, num_str:sub(2,2))
		getCurrentPage():replaceChar(1,18, num_str:sub(3,3))
	end
	getCurrentPage():replaceChar(1,19," ")
	getCurrentPage():colorByBlock(16, 19, 1, 1, "#FFFFFF", true)
	getCurrentPage():colorByBlock(16, 19, 1, 1, "#000000", false)
end

function headerSetName()
	getCurrentPage():replaceRowWithString(1, " CEEFAX ", 7)
	-- getCurrentPage():replaceChar(1, 7, " ")
	-- getCurrentPage():replaceChar(1, 8, "C")
	-- getCurrentPage():replaceChar(1, 9, "E")
	-- getCurrentPage():replaceChar(1, 10, "E")
	-- getCurrentPage():replaceChar(1, 11, "F")
	-- getCurrentPage():replaceChar(1, 12, "A")
	-- getCurrentPage():replaceChar(1, 13, "X")
	-- getCurrentPage():replaceChar(1, 14, " ")
	getCurrentPage():colorByBlock(7, 14, 1, 1, "#FFFFFF", true)
	getCurrentPage():colorByBlock(7, 14, 1, 1, "#0000FF", false)
end

function headerSetDateTime()
	local dateTime = getRealTime()
	if (dateTime.timestamp ~= _previousSecond) then
		_previousSecond = dateTime.timestamp
	else
		return
	end

	local ss = string.format("%02d", dateTime.second)
	local mm = string.format("%02d", dateTime.minute)
	local hh = string.format("%02d", dateTime.hour)
	local dd = string.format("%02d", dateTime.monthday)
	local mo = string.format("%02d", dateTime.month + 1)
	local yyyy = string.format("%04d", dateTime.year + 1900)
	local wek = WEEKDAYS[dateTime.weekday]

	getCurrentPage():replaceChar(1, 20, " ")
	getCurrentPage():replaceChar(1, 21, " ")
	getCurrentPage():replaceChar(1, 22, wek:sub(1,1))
	getCurrentPage():replaceChar(1, 23, wek:sub(2,2))
	getCurrentPage():replaceChar(1, 24, wek:sub(3,3))
	getCurrentPage():replaceChar(1, 25, " ")
	getCurrentPage():replaceChar(1, 26, yyyy:sub(1,1))
	getCurrentPage():replaceChar(1, 27, yyyy:sub(2,2))
	getCurrentPage():replaceChar(1, 28, yyyy:sub(3,3))
	getCurrentPage():replaceChar(1, 29, yyyy:sub(4,4))
	getCurrentPage():replaceChar(1, 30, "/")
	getCurrentPage():replaceChar(1, 31, mo:sub(1,1))
	getCurrentPage():replaceChar(1, 32, mo:sub(2,2))
	getCurrentPage():replaceChar(1, 33, "/")
	getCurrentPage():replaceChar(1, 34, dd:sub(1,1))
	getCurrentPage():replaceChar(1, 35, dd:sub(2,2))
	getCurrentPage():replaceChar(1, 36, " ")
	getCurrentPage():replaceChar(1, 37, hh:sub(1,1))
	getCurrentPage():replaceChar(1, 38, hh:sub(2,2))
	getCurrentPage():replaceChar(1, 39, ":")
	getCurrentPage():replaceChar(1, 40, mm:sub(1,1))
	getCurrentPage():replaceChar(1, 41, mm:sub(2,2))
	getCurrentPage():replaceChar(1, 42, ":")
	getCurrentPage():replaceChar(1, 43, ss:sub(1,1))
	getCurrentPage():replaceChar(1, 44, ss:sub(2,2))
	getCurrentPage():colorByBlock(20, 36, 1, 1, "#FFFFFF", true)
	getCurrentPage():colorByBlock(37, 44, 1, 1, "#FFFF00", true)
	getCurrentPage():colorByBlock(20, 44, 1, 1, "#000000", false)
end

