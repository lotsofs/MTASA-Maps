function getAccountCarData(player, car)
	local account = getPlayerAccount(player)
	if isGuestAccount(account) then return end
	local carData = getElementData(player, "colorPicker123.vehicles", false)
	if not carData then
		local carDataJson = getAccountData(account, "colorPicker123.vehicles")
		if not carDataJson then return end
		carData = fromJSON(carDataJson)
		if not carData then return end
		setElementData(player, "colorPicker123.vehicles", carData, false)
	end
	local model = getElementModel(car)
	local matches = {}
	for i, cd in pairs(carData) do
		if cd["model"] == model then
			table.insert(matches, i)
		end 
	end
	if #matches == 0 then return end
	local random = math.random(1, #matches)
	local carDatum = carData[matches[random]]
	return carDatum
end

function vehicleEntered(theVehicle, seat, jacked)
	if (seat > 1) then return end
	local carDatum = getAccountCarData(source, theVehicle)
	if (carDatum) then
		r1,g1,b1,r2,g2,b2,r3,g3,b3,r4,g4,b4 = getVehicleColor(theVehicle, true)
		r1=carDatum["r1"] or r1
		g1=carDatum["g1"] or g1
		b1=carDatum["b1"] or b1
		r2=carDatum["r2"] or r2
		g2=carDatum["g2"] or g2
		b2=carDatum["b2"] or b2
		r3=carDatum["r3"] or r3
		g3=carDatum["g3"] or g3
		b3=carDatum["b3"] or b3
		r4=carDatum["r4"] or r4
		g4=carDatum["g4"] or g4
		b4=carDatum["b4"] or b4
		setVehicleColor(theVehicle,r1,g1,b1,r2,g2,b2,r3,g3,b3,r4,g4,b4)
		iprint(r1,g1,b1,r2,g2,b2,r3,g3,b3,r4,g4,b4)
	end
end
addEventHandler("onPlayerVehicleEnter", root, vehicleEntered)