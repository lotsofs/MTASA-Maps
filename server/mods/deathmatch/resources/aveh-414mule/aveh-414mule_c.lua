SHOW_START = true
STARTTEXT = "Stay as close to the marker as possible!\nThe closer you are, the faster you gain points."

SHOW_POINTS = true
POINTSTEXT = "0 / 1 000 000"

TICK_RATE = 1000/30
SCORE_RATE = 1000/4

LATEST_REWARD_BASE = 0
LATEST_REWARD = 0
CURRENT_POINTS = 0
REQUIRED_POINTS = 1000000

VICINITY_DURATION = 0

MULTIPLIERS = ""
MULTIPLIER = 1

function text()
	if (SHOW_START) then
		drawBorderedTextScreenRelative(STARTTEXT, 1.9, 0.1, 0.15, 0.9, 0.9, tocolor(130, 27, 184, 255), 5, "default", "center", "top", false, true, true, false)
	end

	if (SHOW_POINTS) then
		local thousands = math.floor(CURRENT_POINTS/1000)
		local units = math.fmod(CURRENT_POINTS, 1000)
		local thousandsT = tostring(thousands)
		local unitsT = tostring(units)
		if thousands == 0 then 
			thousandsT = ""
		else
			unitsT = string.format("%03d", units)
		end
		POINTSTEXT = thousandsT .. " " .. unitsT .. " / 1 000 000\n+" .. LATEST_REWARD_BASE
		if (MULTIPLIER > 1) then
			POINTSTEXT = POINTSTEXT .. MULTIPLIERS .. "= + " .. LATEST_REWARD
		end

		
		drawBorderedTextScreenRelative(POINTSTEXT, 2, 0.1, 0.05, 0.85, 0.85, tocolor(255, 255, 255, 255), 2, "default", "right", "top", false, true, true, false)
	end
end
addEventHandler ( "onClientRender", root, text ) -- keep the text visible with onClientRender.

function raceStart()
	if (not SHOW_START) then
		return
	end
	SHOW_START = false
	setTimer(scorePoints, SCORE_RATE, 0)
end
addEvent("onRaceHasBegun", true)
addEventHandler("onRaceHasBegun", root, raceStart)

END_MARKER_A = getElementByID("MARKER_ARROW")
END_MARKER_B = createBlip(500,-2500,5,0,4,130,27,184)
END_MARKER_C = getElementByID("MARKER_CP")

function collectCheckpoints(target)
    local checkpoint = getElementData(localPlayer, "race.checkpoint")
    if (checkpoint > target) then return end
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if (isElementFrozen(vehicle)) then return end
    for i=checkpoint, target do
		local colshapes = getElementsByType("colshape", RACE_RESOURCE)
		if (#colshapes == 0) then
			break
		end
		triggerEvent("onClientColShapeHit",
            colshapes[#colshapes], vehicle, true)
    end
end

function scorePoints()
	local veh = getPedOccupiedVehicle(localPlayer)
	if (not veh) then return end
	local x2,y2,z2 = getElementPosition(veh)
	if (z2 > 1000) then return end
	local x1,y1,_ = getElementPosition(END_MARKER_C)
	local distance = getDistanceBetweenPoints2D(x1,y1,x2,y2)
	distance = math.floor(distance)
	reward = 250 - distance
	reward = math.max(reward, 0)
	LATEST_REWARD_BASE = reward
	MULTIPLIERS = "\n"
	local multiplier = 1
	if (distance < 5) then
		VICINITY_DURATION = VICINITY_DURATION + 1
		MULTIPLIERS = MULTIPLIERS .. "Interiority Multiplier+5\n"
		multiplier = multiplier + 5
	elseif (distance < 15) then
		VICINITY_DURATION = VICINITY_DURATION + 1
		MULTIPLIERS = MULTIPLIERS .. "Proximity Multiplier+3\n"
		multiplier = multiplier + 3
	elseif (distance < 50) then
		VICINITY_DURATION = VICINITY_DURATION + 1
		MULTIPLIERS = MULTIPLIERS .. "Vicinity Multiplier+1\n"
		multiplier = multiplier + 1
	else
		VICINITY_DURATION = 0
	end

	if (VICINITY_DURATION > 120) then
		MULTIPLIERS = MULTIPLIERS .. "Epic Chase Sequence Multiplier+4\n"
		multiplier = multiplier + 4
	end

	local nearestPlayer = true
	for _,p in ipairs(getElementsByType("player")) do
		if (p ~= localPlayer) then
			local pv = getPedOccupiedVehicle(p)
			if pv then
				local x3,y3,z3 = getElementPosition(p)
				if (z3 < 1000) then
					local d3 = getDistanceBetweenPoints2D(x1,y1,x3,y3)
					if (d3 < distance) then
						nearestPlayer = false
						break
					end
				end
			end
		end
	end
	if (nearestPlayer) then
		if (reward == 0) then
			MULTIPLIERS = MULTIPLIERS .. "Top Disaster Tourist Bonus +600\n"
			reward = reward + 200
		else 
			MULTIPLIERS = MULTIPLIERS .. "Nearest Player Multiplier+2\n"
		end
		multiplier = multiplier + 2
	end

	reward = reward * multiplier
	LATEST_REWARD = reward
	MULTIPLIER = multiplier
	CURRENT_POINTS = CURRENT_POINTS + reward
	local targetCp = math.floor(CURRENT_POINTS / 10000)
	targetCp = math.min(targetCp, 100)
	collectCheckpoints(targetCp)
end

function calibrateBlip()
	local x,y,_ = getElementPosition(END_MARKER_C)
	local _,_,z = getElementPosition(localPlayer)
	if (z > 1000) then z = 20 end
	setElementPosition(END_MARKER_B, x, y, z)
	setElementPosition(END_MARKER_A, x, y, z+5)
end
setTimer(calibrateBlip, TICK_RATE, 0)
