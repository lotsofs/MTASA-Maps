-- https://wiki.multitheftauto.com/wiki/Resource_Web_Access
-- https://stackoverflow.com/questions/8780798/how-do-i-make-a-2d-array-in-lua
-- https://stackoverflow.com/questions/1601151/how-do-i-check-in-sqlite-whether-a-table-exists

function getMapToptimesInfo(mapName)
	local SQL = {}
	local topsTable = getModeAndMap('Sprint', mapName)
	local exists = executeSQLQuery("SELECT * FROM sqlite_master WHERE tbl_name = 'race maptimes Sprint "..mapName.."' LIMIT 1")
	if #exists == 1 then
		SQL = executeSQLQuery('SELECT * FROM '..qsafetablename(topsTable)..' LIMIT 10')
		if #SQL < 10 then
			for i=#SQL+1, 10 do
				SQL[i] = {}
				--SQL[i]["playerCountry"] = ""
				SQL[i]["playerName"] = "-- Empty --"
				SQL[i]["timeText"] = ""
				SQL[i]["timeDifference"] = ""
				SQL[i]["dateRecorded"] = ""
			end
		end
		local map_names = {}
		for k, v in ipairs(exports.mapmanager:getMapsCompatibleWithGamemode(getResourceFromName("race"))) do
			map_names[(getResourceInfo(v, "name") or getResourceName(v))] = v
		end
		local mapResource = map_names[mapName]
		SQL[11] = {}
		if mapResource then
			local mapAuthor = getResourceInfo(mapResource, "author") or "Unknown"
			SQL[11]["mapAuthor"] = mapAuthor
		else
			SQL[11]["mapAuthor"] = "Unknown"
		end
		SQL[12] = {}
		SQL[12]["totalTops"] = #executeSQLQuery('SELECT * FROM '..qsafetablename(topsTable))
	elseif #exists == 0 then
		for i=1, 10 do
			SQL[i] = {}
			--SQL[i]["playerCountry"] = ""
			SQL[i]["playerName"] = "-- Empty --"
			SQL[i]["timeText"] = ""
			SQL[i]["timeDifference"] = ""
			SQL[i]["dateRecorded"] = ""
		end
		SQL[11] = {}
		SQL[11]["mapAuthor"] = ""
		SQL[12] = {}
		SQL[12]["totalTops"] = ""
	end
	return SQL
end

function getAllToptimesInfo()
	local maps_table = executeSQLQuery("SELECT * FROM sqlite_master WHERE tbl_name LIKE 'race maptimes Sprint %' ORDER BY tbl_name")
	local map_names = {}
	local all_maps = {}
	for k, v in ipairs(exports.mapmanager:getMapsCompatibleWithGamemode(getResourceFromName("race"))) do
		map_names[(getResourceInfo(v, "name") or getResourceName(v))] = (getResourceInfo(v, "name") or getResourceName(v))
	end
	local i = 1
	for k, v in ipairs(maps_table) do
		local mapName = v.tbl_name:gsub("race maptimes Sprint ", "")
		if (map_names[mapName]) then
			all_maps[i] = map_names[mapName]
			i = i + 1
		end
	end
	all_maps[#all_maps+1] = #exports.mapmanager:getMapsCompatibleWithGamemode(getResourceFromName("race"))
	return all_maps
end

function getModeAndMap(gMode, mapName)
	return 'race maptimes '..gMode..' '..mapName
end

function qsafetablename(s)
    return qsafestring(s)
end

function qsafestring(s)
    return "'"..safestring(s).."'"
end

function safestring(s)
    return s:gsub("(['])", "''")
end