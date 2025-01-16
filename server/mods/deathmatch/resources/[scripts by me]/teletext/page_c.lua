Page = {}
Page.__index = Page

ROW_COUNT = 24
COLUMN_COUNT = 44

function Page:createBlank()
	local result = {
		backgroundChars = {},
		backgroundColors = {},
		foregroundChars = {},
		foregroundColors = {},
	}
		
	for row=1,ROW_COUNT do
		result.backgroundChars[row] = {}
		result.backgroundColors[row] = {}
		result.foregroundChars[row] = {}
		result.foregroundColors[row] = {}
		for column=1,COLUMN_COUNT do
			result.backgroundChars[row][column] = '█'
			result.backgroundColors[row][column] = ''
			result.foregroundChars[row][column] = ' '
			result.foregroundColors[row][column] = ''
		end
	end
	result.backgroundColors[1][1] = "#000000"
	result.foregroundColors[1][1] = "#FFFFFF"
	
	return setmetatable	(result, self)
end

-- ----------------
-- Text replacement
-- ----------------

function Page:replaceChar(row, col, char)
	self.foregroundChars[row][col] = char
end

function Page:replaceRowWithString(row, text, startCol)
	startCol = startCol or 1
	local charArray = {}
	charArray[row] = {}
	for i=1, math.min(utf8.len(text), COLUMN_COUNT-startCol+1) do
		charArray[row][startCol + i - 1] = utf8.sub(text,i,i)
	end
	self:overlayCharArray(charArray)
end

function Page:overlayCharArray(charArray)
	for row=1,ROW_COUNT do
		if (charArray[row]) then
			for column=1,COLUMN_COUNT do
				self.foregroundChars[row][column] = charArray[row][column] or self.foregroundChars[row][column]
			end
		end
	end
end

-- --------------
-- Block painting
-- --------------

function Page:setBackgroundByBlock(left, right, top, bottom, filled)
	local char = filled and "█" or " "
	
	for row=1,ROW_COUNT do
		for column=1,COLUMN_COUNT do
			if (row >= top and row <= bottom) then
				if (column >= left and column <= right) then
					self.backgroundChars[row][column] = char
				end
			end
		end
	end
end

function Page:colorByBlock(left, right, top, bottom, colorHex, foreground)
	local colors = foreground and self.foregroundColors or self.backgroundColors

	local lastPreviousColor = colors[1][1]
	for row=1,ROW_COUNT do
		for column=1,COLUMN_COUNT do
			if colors[row][column] ~= "" then
				lastPreviousColor = colors[row][column]
			end
			if (row >= top and row <= bottom) then
				if (column == left) then
					colors[row][column] = colorHex
				elseif (column == right + 1) then
					colors[row][column] = lastPreviousColor
				elseif (column > left and column <= right) then
					colors[row][column] = ""
				elseif (column == 1) then
					colors[row][column] = lastPreviousColor
				end
			elseif (row > bottom) then
				colors[row][column] = lastPreviousColor
			end
		end
	end
end