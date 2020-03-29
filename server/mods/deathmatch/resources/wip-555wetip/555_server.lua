	-- todo: Play "HEY THATS THE DA. HES A GOOD TIPPER" sound
	-- todo: rest of the map

function onPlayerReachCheckpoint(checkpoint, time_)
	if (checkpoint == 1) then
		-- player arrives at hotel
		-- move player away
		vehicle = getPedOccupiedVehicle(source)
		setElementFrozen(vehicle, true)
		toggleAllControls(source, false, true, false)
			-- <location id="tempPlayerHideHotel" interior="0" dimension="0" posX="-1734.2" posY="981.29999" posZ="83" rotX="0" rotY="0" rotZ="180"></location>
		setElementPosition(vehicle, -1734.2, 981.29999, 83)
		-- play cutscene
		triggerClientEvent(source, "playDACutscene", resourceRoot)
		setTimer(function(vehicle, player)
				--  <vehicle id="Place_Car_Here_Hotel colors 4 4 0 0" sirens="false" paintjob="3" interior="0" alpha="255" model="551" plate="9IA8P8R" dimension="0" 
				--  color="88,88,83,245,245,245,0,0,0,0,0,0" posX="-1757.8" posY="953.70001" posZ="24.6" rotX="0" rotY="0" rotZ="90"></vehicle>
			-- teleport player into DA car in parking spot
			setElementFrozen(vehicle, false)
			toggleAllControls(player, true)
			checkpoint = getElementByID("checkpoint2cutscene")
			checkpoint2 = getElementByID("checkpoint3cutscene")
			setElementPosition(vehicle, getElementPosition(checkpoint))
			setElementPosition(vehicle, getElementPosition(checkpoint2))
			setElementPosition(vehicle, -1757.8, 953.7, 24.6)
			setElementModel(vehicle, 551)
			setVehicleColor(vehicle, 4, 4, 4, 4)
			fixVehicle(vehicle)
			setElementRotation(vehicle, 0, 0, 90)
		end, 6000, 1, vehicle, source)
	end
end
addEventHandler("onPlayerReachCheckpoint", root, onPlayerReachCheckpoint)

-- player reaches third checkpoint
-- repair the car
-- place car in right orientation
-- despawn the DA

-- if car is damaged
-- disable the final marker
-- prompt player to repair their vehicle
-- place a blip at pay n spray
-- place a blip at the garage

-- player goes to garage after already having been there
-- repair the car
-- place car in right orientation

-- player reaches fourth checkpoint
-- prompt player to park in the marker

-- player parks in marker
-- teleport player to last checkpoint
-- teleport player back

-- player dies
-- if at start = nothing needed to be done
-- if during cutscene = WHY?
-- if after cutscene = check if they respawn on top of the building, then teleport?, this might not be completely foolrpoof though
-- if after garage = idk

