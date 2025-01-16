

function teleportToMarker(x, y, z)
	outputConsole("Teleport to "..x..","..y..","..z)
	spawnPlayer(client, x, y, z)
	givePedJetPack(client)
end
addEvent("teleportToMarker", true)
addEventHandler("teleportToMarker", root, teleportToMarker)
