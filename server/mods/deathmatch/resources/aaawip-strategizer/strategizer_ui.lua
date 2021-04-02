screenWidth, screenHeight = guiGetScreenSize()

function drawBorderedText(text, borderSize, width, height, width2, height2, color, size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	text2 = string.gsub(text, "#%x%x%x%x%x%x", "")
	width = width * screenWidth
	height = height * screenHeight
	width2 = width2 * screenWidth
	height2 = height2 * screenHeight
	size = screenWidth * size * 0.0005
	borderSize = screenWidth * borderSize * 0.0005

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

-- sortedCars = {}
-- unassignedCars = {}

function drawHud()
	if (isSetup == false) then
		return
	end
	if (#selectedTrackNames == 0) then
		drawBorderedText("Generating tracks...", 2, 0.02, 0.2 + (0*0.033), 0.8, 0.9, tocolor(255, 255, 255, 255), 1.8, "default-bold", "left", "top", false, true, true, false)
		return
	end
	drawBorderedText("Assigned Car - (Est. Length) Track - Assigned Car", 2, 0.02, 0.2 + (0*0.033), 0.8, 0.9, tocolor(255, 255, 255, 255), 1.8, "default-bold", "left", "top", false, true, true, false)
	for i = 1, 10 do
		text = selectedTrackNames[i]
		if (sortedCars[i] ~= nil) then
			text = getVehicleNameFromModel(sortedCars[i]) .. " - " .. text
		else 
			text = "<none> - " .. text
		end
		if (i == currentTrack) then
			text = text .. " <==="
		end
		drawBorderedText(text, 2, 0.02, 0.2 + (i*0.033), 0.8, 0.9, tocolor(colors[i][1], colors[i][2], colors[i][3], 255), 1.8, "default", "left", "top", false, true, true, true)
	end
	if (#unassignedCars > 0) then
		text = "Unassigned Cars: "
		for i, car in pairs(unassignedCars) do
			text = text .. getVehicleNameFromModel(car)
			if (i < #unassignedCars) then
				text = text .. ", "
			end
		end
		drawBorderedText(text, 2, 0.02, 0.2 + (12*0.033), 0.3, 0.9, tocolor(255, 255, 255, 255), 1.8, "default", "left", "top", false, true, true, false)
	end

end
addEventHandler("onClientRender", root, drawHud)
