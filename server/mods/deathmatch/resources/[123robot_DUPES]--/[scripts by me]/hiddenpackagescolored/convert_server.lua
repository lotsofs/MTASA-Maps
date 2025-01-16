function convertOldInformation(account)
	local nonParticipant = getAccountData(account, "coloredPackages.nonParticipant")
	if (nonParticipant) then
		db_setAccountParticipation(getAccountID(account), true)
	end
	local accountID = getAccountID(account)
	local packagesJson = getAccountData(account, "coloredPackages.collected")
	if (not packagesJson) then return end
	local packages = fromJSON(packagesJson)
	for i, v in pairs(packages) do
		local pt, pn = convertOldName(i)
		if pt and pn then
			db_writePlayerCollectedPackage ( pt, pn, accountID, v, "NULL", -1, 0 )
		end
	end
	setAccountData(account, "coloredPackages.collected", nil)
	setAccountData(account, "coloredPackages.collectedBKP", packagesJson)
	setAccountData(account, "coloredPackages.nonParticipant", nil)
end

function convertOldName(str)
	if (str == "") then return false, false end 
	local word, number = str:match("([a-zA-Z]+)(%d+)")
	if (word == "packageNormal") then return 1, number end
	if (word == "packageBike") then return 2, number end
	if (word == "packageWater") then return 3, number end
	if (word == "packageHelicopter") then return 4, number end
	if (word == "packageHard") then return 5, number end
	if (word == "packageExtreme") then return 6, number end
	if (word == "packageCustom") then return 7, number end
	iprint("[Hidden Packages Colored] PACKAGE CONVERSION ERROR "..str)
	return false, false
end