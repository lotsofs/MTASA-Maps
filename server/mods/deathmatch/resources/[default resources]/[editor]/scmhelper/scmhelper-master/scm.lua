--00A4:   actor $PLAYER_ACTOR sphere 0 in_cube_cornerA 685.9716 -1433.523 11.0857 cornerB 965.9512 -1379.386 14.9731
--00FE:   actor $PLAYER_ACTOR sphere 0 in_sphere 812.4495 -1343.488 12.532 radius 80.0 80.0 20.0
--0395: clear_area 1 at -1944.025 135.5236 24.7109 radius 100.0 
--00FF:   actor 40@ sphere 0 in_sphere -779.844 499.811 1367.571 radius 0.75 0.75 2.0 on_foot 
--00B0:   car 316@ sphere 0 in_rectangle_cornerA 960.4431 2087.975 cornerB 996.5055 2182.153 
--80FE:   not actor $PLAYER_ACTOR sphere 0 in_sphere $X_STUNT_MISSION_NRG500 $Y_STUNT_MISSION_NRG500 $Z_STUNT_MISSION_NRG500 radius 4.0 4.0 3.0 
--01A6:   actor $PLAYER_ACTOR sphere 0 in_cube_cornerA -777.827 510.0 1369.0 cornerB -797.0 494.0 1373.0 on_foot 
--8100:   not actor $PLAYER_ACTOR in_sphere 7500.0 2478.34 200.0 radius 100.0 100.0 200.0 sphere 0 in_car 
--81AC:   not car 112@ sphere 0 in_cube_cornerA 1636.319 1144.478 7.0 cornerB 1261.411 1780.672 14.0 stopped 
--03BA: clear_cars_from_cube_cornerA -1328.999 1239.997 -5.0 cornerB -1655.868 1638.755 10.0

local function createCuboid(x1, y1, z1, x2, y2, z2)
	local x = x1
	if (x2 < x1) then
		x = x2
	end
	local y = y1
	if (y2 < y1) then
		y = y2
		
	end
	local z = z1
	if (z2 < z1) then
		z = z2
	end

	local width = math.abs(x2 - x1)
	local depth = math.abs(y2 - y1)
	local height = math.abs(z2 - z1)

	return createColCuboid(x, y, z, width, depth, height)
end

local function parse0395(arg)
	local x = tonumber(arg[5])
	local y = tonumber(arg[6])
	local z = tonumber(arg[7])
	local r = tonumber(arg[9])
	return createColCircle(x, y, r)
end

local function parse00A4(arg)
	local x1 = tonumber(arg[7])
	local y1 = tonumber(arg[8])
	local z1 = tonumber(arg[9])
	local x2 = tonumber(arg[11])
	local y2 = tonumber(arg[12])
	local z2 = tonumber(arg[13])
	local sphere = arg[5] == "1"
	if not sphere then
		return createCuboid(x1, y1, z1, x2, y2, z2)
	else
		outputConsole("Unknown 00A4")
		return false
	end
end

local function parseCuboid(x1,y1,z1,x2,y2,z2)
	x1 = tonumber(x1)
	y1 = tonumber(y1)
	z1 = tonumber(z1)
	x2 = tonumber(x2)
	y2 = tonumber(y2)
	z2 = tonumber(z2)
	return createCuboid(x1, y1, z1, x2, y2, z2)
end

local function parse00FE(arg)
	local x = tonumber(arg[7])
	local y = tonumber(arg[8])
	local z = tonumber(arg[9])

	local r = tonumber(arg[11])
	local r2 = tonumber(arg[12])
	local h = tonumber(arg[13])
	local sphere = arg[5] == "1"
	if not sphere then
		outputConsole("Creating cuboid")
		return createColCuboid(x - r, y - r, z, r*2, r*2, h)
	else
		outputConsole("Unknown 00FE")
		return false
	end
end

local function parse8100(arg)
	local x = tonumber(arg[6])
	local y = tonumber(arg[7])
	local z = tonumber(arg[8])

	local r = tonumber(arg[10])
	local r2 = tonumber(arg[11])
	local h = tonumber(arg[12])
	local sphere = arg[14] == "1"
	if not sphere then
		outputConsole("Creating cuboid")
		return createColCuboid(x - r, y - r, z, r*2, r*2, h)
	else
		outputConsole("Unknown 00FE")
		return false
	end
end

local function parse81AC(arg)
	local x = tonumber(arg[8])
	local y = tonumber(arg[9])
	local z = tonumber(arg[10])

	local r = tonumber(arg[12])
	local r2 = tonumber(arg[13])
	local h = tonumber(arg[14])
	local sphere = arg[6] == "1"
	if not sphere then
		outputConsole("Creating cuboid")
		return createColCuboid(x - r, y - r, z, r*2, r*2, h)
	else
		outputConsole("Unknown 00FE")
		return false
	end
end

local function parse00B0(arg)
	local x1 = tonumber(arg[7])
	local y1 = tonumber(arg[8])
	local x2 = tonumber(arg[10])
	local y2 = tonumber(arg[11])
	return createCuboid(x1, y1, 0, x2, y2, 1000)
end

-- Stuff that was collected from several lines under a section, like several coordinate assignments
local function parseSection(code)
	local check = string.match(code, "COORDINATES:([%d%.- ]+)$")
	if check ~= nil then
		local coords = check:split(" ")
		local x = tonumber(coords[1])
		local y = tonumber(coords[2])
		local z = tonumber(coords[3])
		return createMarker(x, y, z)
	end
	return false
end

function createMarkerForCode(code)
	local arg = code:split(" ")
	local opcode = arg[1]
	outputConsole(opcode)
	if opcode == "00A4:" or opcode == "01A6:" then
		return parse00A4(arg)
	elseif opcode == "00FE:" or opcode == "00FF:" then
		return parse00FE(arg)
	elseif opcode == "80FE:" then
		return parse00FE(tail(arg))
	elseif opcode == "0395:" then
		return parse0395(arg)
	elseif opcode == "8100:" then
		return parse8100(arg)
	elseif opcode == "81AC:" then
		return parse81AC(arg)
	elseif opcode == "00B0:" then
		return parse00B0(arg)
	elseif opcode == "03BA:" then
		return parseCuboid(arg[3],arg[4],arg[5],arg[7],arg[8],arg[9])
	elseif opcode ~= nil and opcode:starts(":") then
		return parseSection(code)
	end

	return false
end


