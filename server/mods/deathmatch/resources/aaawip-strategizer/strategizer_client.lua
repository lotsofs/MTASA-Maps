function nextCar(keyName, keyState)
	triggerServerEvent("nextCar", resourceRoot)
end

function prevCar(keyName, keyState)
	triggerServerEvent("prevCar", resourceRoot)
end

function nextTrack(keyName, keyState)
	triggerServerEvent("nextTrack", resourceRoot)
end

function prevTrack(keyName, keyState)
	triggerServerEvent("prevTrack", resourceRoot)
end

for keyName, state in pairs(getBoundKeys("special_control_up")) do
	bindKey(keyName, "down", nextTrack)
end

for keyName, state in pairs(getBoundKeys("special_control_down")) do
	bindKey(keyName, "down", prevTrack)
end

for keyName, state in pairs(getBoundKeys("special_control_left")) do
	bindKey(keyName, "down", prevCar)
end

for keyName, state in pairs(getBoundKeys("special_control_right")) do
	bindKey(keyName, "down", nextCar)
end



