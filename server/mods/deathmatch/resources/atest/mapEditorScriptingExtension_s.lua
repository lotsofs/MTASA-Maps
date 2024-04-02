function onResourceStart(startedResource)
    iprint("ADS")
	blahblah = getElementsByType("packageCustom")
	fileHandle = fileCreate("output.txt")
	if (fileHandle) then
		for a,baaa in ipairs(blahblah) do
			local x, y, z = getElementPosition(baaa)
			local d = getElementData(baaa, "mapAssignment")
			fileWrite(fileHandle, a .. " " .. d .. " " .. tostring(x) .. " " .. tostring(y) .. " " .. tostring(z) .. "\n")
			
			iprint(getAllElementData(baaa))
		end		
	end
	fileClose(fileHandle)
end
addEventHandler("onResourceStart", resourceRoot, onResourceStart)