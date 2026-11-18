-- Screen stuff
screenX, screenY = guiGetScreenSize()
screenAspect = math.floor((screenX / screenY)*10)/10

-- Stats box
-- if screenAspect >= 1.7 then 
	-- -- 16:9 screen ratio
	s_offsets = {0.285, 0.0155, 0.175, 0.235} -- X-left, Y-top, width, height for a box
	st_offsets = {0.29, 0.01625, 0.63, screenX/(1745*5), screenX/(1920*4)} -- X-left, Y1, Y2, textsize
	-- else 
	-- -- 4:3 and others screens
	-- 	s_offsets = {0.285, 0.0155, 0.175, 0.235} -- X-left, Y-top, width, height for a box
	-- 	st_offsets = {0.27, 0.20, 0.63, screenX/1745, screenX/1920} -- X-left, Y1, Y2, textsize
-- end

-- Records
displayStats = false
statsInited = false
statsAlpha = 0
displayedRecords = {}
for i = 1, 11 do
	displayedRecords[i] = {}
	displayedRecords[i]["playername"] = ""
	displayedRecords[i]["time"] = 0
end
helpText = "F5"

statsHideTimer = nil

-- Function that enables stats and requests data from the database
-- Called from key bind and finish of the race
function showStats()
	-- Get vehicle model
	if not getPedOccupiedVehicle(localPlayer) then return end 
	local vehicleModel = getElementModel(getPedOccupiedVehicle(localPlayer))
	
	-- Request data for stats for this model
	triggerServerEvent("getStats", getLocalPlayer(), vehicleModel)
	
	-- Show stats
	displayStats = not displayStats
	if (displayStats) then
		statsHideTimer = setTimer(showStats, 16000, 1)
	elseif (statsHideTimer) then
		killTimer(statsHideTimer)
		statsHideTimer = nil
	end
end


-- Generating text message
local b = 1
local button = {}
for key, state in pairs(getBoundKeys("showtimes")) do
	button[b] = key
	bindKey(key, "down", showStats)
	
	b = b + 1 
	if b > 4 then 
		b = 4
		break
	end
end 

b = b - 1
helpText = string.upper(button[1])
if b > 1 then
	for i = 2, b do
		helpText = helpText.. " #E7D9B0or #00FF00" ..string.upper(button[i])
	end
end
-- outputChatBox("#E7D9B0You can get records for your vehicle by pressing #00FF00" ..helpText, 0, 0, 0, true)

-- Function that draws stats on the screen
function drawStats()
	if not statsInited or not getPedOccupiedVehicle(localPlayer) then return end

	-- Get vehicle name from xml
	local vehicleName = VEHICLE_NAMES[getElementModel(getPedOccupiedVehicle(localPlayer))]
	
	-- Draw vehicle's name
	dxDrawText(vehicleName, 	screenX*(st_offsets[1]+0.00), 	screenY*(st_offsets[2]-0.002), 			screenX*st_offsets[1], 		screenY, 	tocolor(255, 255, 255, statsAlpha), 	st_offsets[5]*5, 		"pricedown")
	dxDrawText("Vehicle Top Times", 	screenX*(st_offsets[1]+0.085), 	screenY*(st_offsets[2]+0.005), 			screenX*st_offsets[1], 		screenY, 	tocolor(255, 255, 255, statsAlpha), 	st_offsets[5]*5, 		"default-bold")

	-- Draw records for this vehicle
	for i = 1, 11 do
		local textY = screenY*(st_offsets[2]+0.0155+0.018*i)
		dxDrawText(i.. ".", 																screenX*st_offsets[1], 			textY, 	screenX*st_offsets[1]*1.03, 	screenY, 	tocolor(220, 220, 225, statsAlpha), 	st_offsets[5]*4.8, 	"default-bold", "right")
		dxDrawText(tostring(displayedRecords[i]["playername"]):gsub("#%x%x%x%x%x%x", ""), 	screenX*(st_offsets[1]*1.05), 	textY, 	screenX*st_offsets[1], 			screenY, 	tocolor(220, 220, 225, statsAlpha), 	st_offsets[5]*4.8, 	"default-bold")
		dxDrawText(convertToRaceTime(displayedRecords[i]["time"]), 							screenX*(st_offsets[1]+0.03), 	textY, 	screenX*(st_offsets[1]+0.1675), 	screenY, 	tocolor(220, 220, 225, statsAlpha), st_offsets[5]*4.8, 	"default-bold", "right")
	end
end

-- Function that convers time in ms into string in format "MM:SS.MS"
function convertToRaceTime(time)
	if time ~= nil then
		local m = math.floor(time / 1000 / 60)
		local s = math.floor((time / 1000) - m*60)
		local ms = math.floor(time - (m*60+s)*1000)
		
		if m < 1 then m = ""
		else m = m.. ":" end
		if s < 10 then s = "0" ..s end
		if ms < 10 then ms = "00" ..ms
		elseif ms < 100 and ms > 9 then ms = "0" ..ms end
		
		return m.. "" ..s.. "." ..ms
	end
end

-- Onscreen stuff and seed generation
addEventHandler("onClientRender", getRootElement(), function()
	if displayStats then
		-- Fade In
		if statsAlpha < 255 then statsAlpha = statsAlpha + 51
		else statsAlpha = 255 end
	else
		-- Fade out
		if statsAlpha > 0 then statsAlpha = statsAlpha - 51
		else statsAlpha = 0 end
	end
	
	-- Draw Stats
	if statsAlpha > 102 then
		dxDrawRectangle(screenX*s_offsets[1], screenY*s_offsets[2], screenX*s_offsets[3], screenY*s_offsets[4], tocolor(38, 31, 26, 102, 50))
		dxDrawRectangle(screenX*s_offsets[1], screenY*s_offsets[2], screenX*s_offsets[3], screenY*s_offsets[4]/8.5, tocolor(38, 31, 26, 102, 50))
	else
		dxDrawRectangle(screenX*s_offsets[1], screenY*s_offsets[2], screenX*s_offsets[3], screenY*s_offsets[4], tocolor(38, 31, 26, statsAlpha, 50))
		dxDrawRectangle(screenX*s_offsets[1], screenY*s_offsets[2], screenX*s_offsets[3], screenY*s_offsets[4]/8.5, tocolor(38, 31, 26, statsAlpha, 50))
	end

	drawStats()
end )

-- Event called from the server script for receiving stats data
addEvent("receiveStats", true)
addEventHandler("receiveStats", getRootElement(), function(recordsStats)		
	-- Handle Vehicle Records
	for i, recordsData in pairs(recordsStats) do 
		displayedRecords[i]["playername"] = recordsData["playername"]
		displayedRecords[i]["time"] = recordsData["score"]
	end
	
	if #recordsStats < 11 then
		for i = #recordsStats + 1, 11 do
			displayedRecords[i]["playername"] = "-- Empty --"
			displayedRecords[i]["time"] = 0
		end
	end
	
	statsInited = true
end )
