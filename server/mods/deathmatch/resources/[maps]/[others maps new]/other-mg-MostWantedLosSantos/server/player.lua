Player = {}

local criminalNames = {
	"Forelli Family",
	"Leone Family",
	"Ancelotti Family",
	"Pegorino Crime Family",
	"Pecorinos",
	"Gambetti Family",
	"Messina Family",
	"McRearys",
	"Mendez Cartel",
	"Albanian Mob",
	"Bulgarin Crime Syndicate",
	"Red Gecko Tong",
	"Mountain Cloud Boys",
	"Da Nang Boys",
	"Yakuza",
	"Yardies",
	"Varrios Los Aztecas",
	"Grove Street Families",
	"Vagos",
	"Colombian Cartel",
	"The Lost MC",
	"Angels of Death",
	"Uptown Riders",
	"Ballas",
	"Bloodhound Gang",
	"Anti-Fleischberg Group",
	"Tunnel Snakes",
	"Los Pollos Hermanos",
	"Trailer Park Mafia",
	"Hillside Posse",
	"Jingweon Mafia",
	"Midtown Gangsters",
	"Wonsu Nodong",
	"Dharma Initiative",
	"E-Corp",
	"Serious Individuals",
	"Jax Trust",
	"Kiketsu Family",
	"Scavengers",
	"Tyger Claws",
	"Voodoo Boys",
	"Rifa",
	"Loco Syndicate",
	"Stetchkov Syndicate",
	"Blood Feather Triad",
	"Snake Farmers",
	"Team Rocket",
	"Cerberus",
	"Discord Mods United",
	"Package Hunters Initiative",
	"Team SKC",
	"GTA Community Rebellion"
}

g_PoliceTeam = createTeam(g_POLICE_TEAM_NAME, 30, 190, 240)
g_CriminalTeam = createTeam(criminalNames[math.random(#criminalNames)], 150, 0 , 200)

function Player:new(player)
	local o = {}
	setmetatable(o, self)

	self.__index = self
	o.role = nil
	o.player = player
	o.delivering = false
	o.perkId = nil

	return o
end

-- return if role successfully set
-- may not be set if there are no cop cars
function Player:setRole(role)
	if role == g_POLICE_ROLE then
		for _, copCar in pairs(getElementsByType("vehicle", resourceRoot)) do
			if getElementModel(copCar) == 596 then
				-- at least 1 cop car to use
				self.role = role
				self.perk = nil
				setPlayerNametagShowing(self.player, true)

				-- change player vehicle and tp to cop vehicle position
				local vehicle = getPedOccupiedVehicle(self.player)
				setElementModel(vehicle, 596) -- police LS
				setElementPosition(vehicle, getElementPosition(copCar))
				setElementRotation(vehicle, getElementRotation(copCar))
				setVehicleHandling(vehicle, "collisionDamageMultiplier", 0)
				setVehicleHandling(vehicle, "acceleration", 27)
				setVehicleColor(vehicle, 0, 0, 0, 255, 255, 255, 0, 0, 0)

				bindKey(self.player, "vehicle_secondary_fire", "down", function()
					giveWeapon(self.player, 31, 9999, true) -- uzi
					setPedDoingGangDriveby(self.player, not isPedDoingGangDriveby(self.player))
				end)

				destroyElement(copCar) -- so players won't spawn on top of each other

				triggerClientEvent(self.player, g_PLAYER_ROLE_SELECTED_EVENT, resourceRoot, role)

				setPlayerTeam(self.player, g_PoliceTeam)
				setElementModel(self.player, 285)
				return true
			end
		end

		return false
	elseif role == g_CRIMINAL_ROLE then
		self.role = role
		self.perk = nil
		setPlayerNametagShowing(self.player, false)
		triggerClientEvent(self.player, g_PLAYER_ROLE_SELECTED_EVENT, resourceRoot, role)

		setPlayerTeam(self.player, g_CriminalTeam)

		local clowncar = getPedOccupiedVehicle(self.player)
		setVehicleHandling(clowncar, "collisionDamageMultiplier", 0.2)
	end

	return true
end

function Player:setPerk(perkId)
	if self.role ~= g_CRIMINAL_ROLE then return end
	self.perkId = perkId
end

function Player:checkPerk()
	local veh = getPedOccupiedVehicle(self.player)

	if veh then
		if self.perkId == g_MECHANIC_PERK.id then
			local vx, vy, vz = getElementVelocity(veh)
			if vx == 0 and vy == 0 and vz == 0 then
				setElementHealth(veh, math.min(getElementHealth(veh) + 2), 1000) -- per tick
			end
		elseif self.perkId == g_FUGITIVE_PERK.id then
			if gameState ~= g_COREGAME_STATE and not self.fugitived then
					setElementAlpha(veh, 0)
					setElementAlpha(self.player, 0)
					setVehicleLightState(veh, 0, 1)
					setVehicleLightState(veh, 1, 1)
					setTimer(function()
						if veh then
							setElementAlpha(veh, 255)
							setElementAlpha(self.player, 255)
							setVehicleLightState(veh, 0, 0)
							setVehicleLightState(veh, 1, 0)
						end
					end, g_DELAY_BETWEEN_EXIT_SPAWN * 1.5, 0) -- invisible until exit spawns and then some
				self.fugitived = true
			end
		elseif self.perkId == g_HOTSHOT_PERK.id then
			setVehicleHandling(veh, "maxVelocity", 450 - getElementHealth(veh) / 4) -- 200 is base, goes from 250 to 450
			setVehicleHandling(veh, "engineAcceleration", 19.5 - getElementHealth(veh) / 120) -- 11.2 is base, this goes from ~11.7 to 20
		end
	end
end