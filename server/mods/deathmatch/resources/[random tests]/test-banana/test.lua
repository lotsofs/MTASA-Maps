function aaa()
	txd = engineLoadTXD("rustler.txd")
	engineImportTXD(txd, 555)
	dff = engineLoadDFF("rustler.dff")
	engineReplaceModel(dff, 555)
end
addEventHandler("onClientResourceStart", resourceRoot, aaa)



-- car = nil
-- sir = nil

-- function aaa()
	-- -- asdf = getModelHandling(476)
	-- -- for i, v in pairs(asdf) do
		-- -- setModelHandling(476, i, v)
	-- -- end
	-- -- for k,_ in pairs(getModelHandling(476)) do
		-- -- setModelHandling(476, k, nil)
	-- -- end
	-- vehicle = getPedOccupiedVehicle(localPlayer)
	-- x,y,z = getElementPosition(vehicle)
	-- if (car) then
		-- destroyElement(car)
	-- end
	-- sir = createPed(120,x+10,y,z)
	-- car = createVehicle(476,x+12, y, z)
	-- warpPedIntoVehicle(sir, car)
	-- attachElements(car,vehicle,0,0,1,10,0,0)
	-- setElementAlpha(localPlayer, 0)
	-- setTimer(function(vehicle)
		-- setElementAlpha(vehicle, 0)
	-- end, 1000, 10, vehicle)
	-- setPedControlState(sir, "accelerate", true)
-- end
-- addCommandHandler("a", aaa)