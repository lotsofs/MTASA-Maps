function handleResetRequest(packageIds)
	local account = getPlayerAccount(source)
	local accountID = getAccountID(account)
	for i, p in ipairs(packageIds) do
		db_resetPlayerCollectedPackage ( p[1], p[2], accountID, p[3] or 2147483647)
	end
	sendClientPackageData(source)
end
addEvent("onClientResetRequest", true)
addEventHandler("onClientResetRequest", root, handleResetRequest)


function onClientDidOldReset()
	local account = getPlayerAccount(source)
	local accountID = getAccountID(account)
	setAccountData(account, "coloredPackages.resetHistory", nil)
end
addEvent("onClientDidOldReset", true)
addEventHandler("onClientDidOldReset", root, onClientDidOldReset)