TABLE_NAME = "hiddenpackages_collected"
TABLE_NAME_ACCOUNTS = "hiddenpackages_participants"

local TABLE_COLUMNS = {
	{"packageType", "INT"},
	{"packageNumber", "INT"},
	{"playerAccount", "INT"},
	{"vehicle", "INT"},
	{"map", "STRING"},
	{"checkpoint", "INT"},
	{"timestamp", "INT DEFAULT 0"},
	{"reset", "BOOLEAN DEFAULT FALSE"},
}

function db_createTablesIfNotExists()
	local cmd = "CREATE TABLE IF NOT EXISTS "..TABLE_NAME.."("
	for i,t in ipairs(TABLE_COLUMNS) do
		cmd = cmd..t[1].." "..t[2]
		if (i < #TABLE_COLUMNS) then
			cmd = cmd..", "
		end
	end
	cmd = cmd..");"
	executeSQLQuery(cmd)

	db_addNewColumns ( )

	cmd = "CREATE TABLE IF NOT EXISTS "..TABLE_NAME_ACCOUNTS.."("
		.. "accountId INT PRIMARY KEY," 
		.. "accountName INT, "
		.. "nonParticipant BOOLEAN DEFAULT FALSE" 
		.. ");"
	executeSQLQuery(cmd)
end

function db_addNewColumns ( )
	local cmd = "PRAGMA table_info("..TABLE_NAME..")";
	local pragma = executeSQLQuery(cmd)
	local columns = {}
	for _,p in ipairs(pragma) do
		columns[p.name] = true
	end
	for _,t in ipairs(TABLE_COLUMNS) do
		if not columns[t[1]] then
			cmd = "ALTER TABLE "..TABLE_NAME.." ADD COLUMN "..t[1].." "..t[2];
			executeSQLQuery(cmd)
		end
	end
end

function db_getPlayerCollectedPackages ( player )
	local account = getPlayerAccount(player)
	if (not account or isGuestAccount(account)) then
		return {}
	end
	local accountID = getAccountID(account)
	cmd = "SELECT packageType, packageNumber FROM "..TABLE_NAME.." WHERE playerAccount = "..accountID.." AND reset IS FALSE;"
	return executeSQLQuery(cmd)
end

function db_writePlayerCollectedPackage ( packageType, packageNumber, playerAccount, vehicle, map, checkpoint, timestamp )
	local cmd = "INSERT INTO "..TABLE_NAME.."(packageType, packageNumber, playerAccount, vehicle, map, checkpoint, timestamp, reset) VALUES ("
		..packageType..", "
		..packageNumber..", "
		..playerAccount..", "
		..vehicle..", \""
		..map.."\", "
		..checkpoint..", "
		..timestamp..", FALSE);"
	return executeSQLQuery(cmd)
end

function db_resetPlayerCollectedPackage ( packageType, packageNumber, playerAccount, timestamp)
	local cmd = "UPDATE "..TABLE_NAME
		.." SET reset = TRUE WHERE "
		.." packageType = "..packageType
		.." AND packageNumber = "..packageNumber
		.." AND playerAccount = "..playerAccount
		.." AND timestamp < "..timestamp
	return executeSQLQuery(cmd)
end

function db_enterAccountSQLData(id,name)
	local cmd = "INSERT INTO "..TABLE_NAME_ACCOUNTS.." (accountId, accountName, nonParticipant) VALUES ("
		..id..", '"
		..name.."', FALSE);"
	return executeSQLQuery(cmd)
end

function db_setAccountParticipation(id,nonParticipant)
	local cmd = "UPDATE "..TABLE_NAME_ACCOUNTS
		.." SET nonParticipant = "..tostring(nonParticipant)
		.." WHERE accountId = "..id
		..";"
	return executeSQLQuery(cmd)
end

function db_getAccountSQLData(id)
	local cmd = "SELECT nonParticipant FROM "..TABLE_NAME_ACCOUNTS.." WHERE accountId="..id..";"
	return executeSQLQuery(cmd)
end

addEventHandler("onResourceStart", resourceRoot, db_createTablesIfNotExists)