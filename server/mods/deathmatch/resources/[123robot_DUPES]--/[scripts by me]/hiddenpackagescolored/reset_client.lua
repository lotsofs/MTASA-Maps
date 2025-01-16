local WHITE = 1
local GREEN = 2
local BLUE = 3
local ORANGE = 4
local YELLOW = 5
local RED = 6
local BLACK = 7

local NEW_RESETS = {
	-- For the 'no more grabbing through floors' update 2025-01-08 (first rewrite)
	{ YELLOW, 195, 1 }, -- top of emerald isle, helipad
	{ RED, 43, 1 }, -- Frederick Bridge
}

local OLD_RESETS = {
    -- 1: 2024-03-22 Removing too easy black packages after first release feedback
    { 
		{BLACK, 1, 1},
		{BLACK, 2, 1},
		{BLACK, 3, 1},
		{BLACK, 6, 1},
		{BLACK, 7, 1},
		{BLACK, 10, 1},
		{BLACK, 12, 1},
		{BLACK, 17, 1},
		{BLACK, 21, 1},
		{BLACK, 44, 1},
		{BLACK, 46, 1},
		{BLACK, 52, 1},
		{BLACK, 54, 1},
		{BLACK, 59, 1},
	},
    -- 2: 2024-03-25 Package that sticked out through the floor and was automatically picked up
    {
		{BLACK, 7, 1},
	},
    -- 3: 2024-04-29 Package changes to Shanty 8-Track Randomiser
	{
		{BLACK, 181, 1},
		{BLACK, 182, 1},
	},
	-- 4: 2024-09-10 Package changes after 10000% difficult got fixed
	{
		{BLACK, 430, 1},
		{BLACK, 431, 1},
	},	
	-- 5: 2024-10-16 Going Up 3, Luigi Circuit package fix, Bayside green fix
	{
		{BLACK, 494, 1},
		{BLACK, 512, 1},
		{GREEN, 3, 1},
	},
	-- 6: 2024-11-13 Minor tweaks to areas from previous update
	{
		{WHITE, 606, 1},
		{WHITE, 613, 1},
		{RED, 40, 1},
		{RED, 15, 1},		
	},
	-- 7: 2024-11-22 Reset misreset package on Mario Kart map, Mechanic Deadfall II + Build Your Own DD removed
	{
		{BLACK, 511, 1},
		{BLACK, 461, 1},
		{BLACK, 281, 1},
	},
}

local _oldResetsExecuted = false
local _newResetsExecuted = false

function handleOldResets()
	if (_oldResetsExecuted) then return end
	local resetHistory = getElementData(localPlayer, "coloredPackages.resetHistory") or 8
	for i = resetHistory + 1, #OLD_RESETS do
		triggerServerEvent("onClientResetRequest", localPlayer, OLD_RESETS[i])
	end
	_oldResetsExecuted = true
	triggerServerEvent("onClientDidOldReset", localPlayer)
end

function handleNewResets()
	if (_newResetsExecuted) then return end
	local requestResetOnServerFor = {}
	for _, v in ipairs(NEW_RESETS) do
		local pack = Packages.instances[getCompositePackageKey(v[1], v[2])]
		if (pack.collected) then
			table.insert(requestResetOnServerFor, v)
		end
	end
	_newResetsExecuted = true
	triggerServerEvent("onClientResetRequest", localPlayer, requestResetOnServerFor)
end

function checkForResets()
	handleOldResets()
	handleNewResets()
end

function resetCommandHandler(commandName, ...)
	if (g_nonParticipant) then
		outputChatBox("You must enable hidden packages before you can do that.", 49, 206, 13)
		return
	end
	if (not g_loggedIn) then
		outputChatBox("You must be logged in before you can do that.", 49, 206, 13)
	end
	
	local args = {...}
	local packIds = {}
	for _,arg in ipairs(args) do
		if (arg == "all") then
			resetAllPackages()
			return
		else
			local id = convertResetFormatToCompositePackageKey(arg)
			local pack = Packages.instances[id]
			if (pack) then
				table.insert(packIds, {pack.packType, pack.packageNumber})
			else
				local region = Regions:getFromName(arg)
				if (region) then
					local regionPacks = region:getAllPackages(true)
					for _, rp in ipairs(regionPacks) do
						table.insert(packIds, {rp.packType, rp.packageNumber})
					end
				end
			end
		end
	end
	outputChatBox("Resetting "..#packIds.." packages.", 206, 49, 13)
	triggerServerEvent("onClientResetRequest", localPlayer, packIds)
end
addCommandHandler("resetpackages", resetCommandHandler, false, false)

function resetAllPackages()
	local packages = Packages:getAllTypeNumberPairs(true)
	outputChatBox("Resetting "..#packages.." packages.", 206, 49, 13)
	triggerServerEvent("onClientResetRequest", localPlayer, packages)
end