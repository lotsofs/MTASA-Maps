-- DO NOT CHANGE THE MODELS, THEY'RE FINE
local VEHICLES = {602,545,496,517,401,410,518,600,527,436,589,580,419,439533,549,526,491,474,445,604,507,585,587,466,492,546,551,516,467,426,547,405,409,550,566,540,421,529,581,509,481,462,521,463,510,522,461,448,468,586,485,552,431,438,437,574,420,525,408,416,433,427,490,528,407,544,523,470,598,596,597,599,601,428,499,609,498,524,532,578,486,573,455,588,403,514,423,414,443,515,531,456,459,422,482,605,530,418,572,582,413,440,543,583,478,554,536,575,534,567,535,576,412,402,542,603,475,568,424,504,457,483,508,571,500,471,495,429,541,415,480,562,323,492,502,503,411,559,561,560,506,451,558,555,477,579,400,404,489,505,479,442,458}
-- MARKER HERE
local MARKER = createMarker(4207.5,-2000,18,"corona",10,185,255,40,153)
local MARKER2 = createMarker(5689,-2000,40,"corona",10,185,255,40,153)
local MARKER3 = createMarker(6361.95703125,-2580,25,"corona",15,185,255,40,153)
-- HIT FUNCTION
addEventHandler("onClientMarkerHit", MARKER,
function(hitPlayer)
	if DELAY then
		return
	end
	if hitPlayer == localPlayer then
		local VEHICLE = getPedOccupiedVehicle(localPlayer)
		if isElement(VEHICLE) then
			local MODEL = VEHICLES[math.random(#VEHICLES)]
			setElementModel(VEHICLE, MODEL)
			DELAY = true
			setTimer(function() DELAY = nil end, 10000, 1)
		end
	end
end)

addEventHandler("onClientMarkerHit", MARKER2,
function(hitPlayer)
	if DELAY then
		return
	end
	if hitPlayer == localPlayer then
		local VEHICLE = getPedOccupiedVehicle(localPlayer)
		if isElement(VEHICLE) then
			local MODEL = VEHICLES[math.random(#VEHICLES)]
			setElementModel(VEHICLE, MODEL)
			DELAY = true
			setTimer(function() DELAY = nil end, 10000, 1)
		end
	end
end)

addEventHandler("onClientMarkerHit", MARKER3,
function(hitPlayer)
	if DELAY then
		return
	end
	if hitPlayer == localPlayer then
		local VEHICLE = getPedOccupiedVehicle(localPlayer)
		if isElement(VEHICLE) then
			local MODEL = VEHICLES[math.random(#VEHICLES)]
			setElementModel(VEHICLE, MODEL)
			DELAY = true
			setTimer(function() DELAY = nil end, 10000, 1)
		end
	end
end)
