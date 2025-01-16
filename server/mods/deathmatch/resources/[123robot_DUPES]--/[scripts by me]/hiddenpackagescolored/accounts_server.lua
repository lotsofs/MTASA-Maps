function getAccountNonParticipation(account)
	if (not account or isGuestAccount(account)) then
		return false
	end
	local id = getAccountID(account)
	local data = db_getAccountSQLData(id)
	if #data == 0 then
		local name = getAccountName(account)
		db_enterAccountSQLData(id,name)
		return false
	elseif #data > 1 then
		outputDebugString("[Hidden Packages Colored] Found multiple accounts with ID "..id.." in accounts database")
	end
	if (data[1].nonParticipant > 0) then
		return true
	else
		return false
	end
end

function onPlayerLogin(thePreviousAccount, theCurrentAccount)
	sendClientPackageData(source)
end
addEventHandler("onPlayerLogin", root, onPlayerLogin)


function onPlayerLogout(thePreviousAccount, theCurrentAccount)
	sendClientPackageData(source)
end
addEventHandler("onPlayerLogout", root, onPlayerLogout)

function toggleAccountParticipation(playerSource)
	local account = getPlayerAccount(playerSource)
	if isGuestAccount(account) then
		sendClientPackageData(playerSource, true)
		return
	end
	local np = getAccountNonParticipation(account)
	np = not np
	db_setAccountParticipation(getAccountID(account), np)
	sendClientPackageData(playerSource, np)
	if (np) then
		outputChatBox("Hidden Packages Disabled", playerSource, 206, 13, 49)
	else
		outputChatBox("Hidden Packages Enabled", playerSource, 13, 206, 49)
	end
end
addCommandHandler("togglepackages", toggleAccountParticipation, false, false)