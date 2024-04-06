Exit = {}

function Exit:new(group)
	local o = {}
	setmetatable(o, self)

	self.__index = self

	o.vans = {}
	o.barricades = {}
	o.walls = {}
	o.blips = {}
	o.markers = {}
	o.exits = {}

	for _, e in ipairs(getElementChildren(group)) do
		local type = getElementType(e)
		if type == "exit_barricade" then
			local barricade = createObject(981, getElementPosition(e))
			setElementRotation(barricade, getElementData(e, "rotX"), getElementData(e, "rotY"), getElementData(e, "rotZ"))
			o.barricades[#o.barricades + 1] = barricade
		elseif type == "exit_wall" then
			local wall = createObject(8172, getElementPosition(e))
			setElementRotation(wall, getElementData(e, "rotX"), getElementData(e, "rotY"), getElementData(e, "rotZ"))
			o.walls[#o.walls + 1] = wall
		elseif type == "swat_van" then
			local van = createVehicle(427, getElementPosition(e))
			setElementRotation(van, getElementData(e, "rotX"), getElementData(e, "rotY"), getElementData(e, "rotZ"))
			o.vans[#o.vans + 1] = van
		elseif type == "exit_point" then
			local x, y, z = getElementPosition(e)
			local col = createColCircle(x, y, 10)
			addEventHandler("onColShapeHit", col, function(element)
				if not o.active then return end

				local player, vehicle = toPlayer(element)
				if not player then return end
				if not vehicle then return end -- in case of spectator?
				if getPlayerTeam(player.player) ~= g_CriminalTeam then return end

				triggerEvent("onPlayerReachCheckpointInternal", player.player, 1)
			end)
			o.exits[#o.exits + 1] = e
		end
	end

	o:disable()

	return o
end

function Exit:disable()
	if not self.active then return end

	for _, wall in ipairs(self.walls) do
		setElementCollisionsEnabled(wall, true)
		setElementAlpha(wall, 0)
	end
	for _, barricade in ipairs(self.barricades) do
		setElementCollisionsEnabled(barricade, true)
		setElementAlpha(barricade, 255)
	end
	for _, van in ipairs(self.vans) do
		setElementCollisionsEnabled(van, true)
		setElementAlpha(van, 255)
	end
	for _, blip in ipairs(self.blips) do
		destroyElement(blip)
	end
	for _, marker in ipairs(self.markers) do
		destroyElement(marker)
	end
	self.blips = {}
	self.markers = {}

	self.active = false
end

function Exit:enable()
	if self.active then return end

	for _, wall in ipairs(self.walls) do
		setElementCollisionsEnabled(wall, false)
		setElementAlpha(wall, 0)
	end
	for _, barricade in ipairs(self.barricades) do
		setElementCollisionsEnabled(barricade, false)
		setElementAlpha(barricade, 0)
	end

	for _, van in ipairs(self.vans) do
		setElementCollisionsEnabled(van, false)
		setElementAlpha(van, 0)
	end

	for _, e in ipairs(self.exits) do
		local x, y, z = getElementPosition(e)
		self.blips[#self.blips + 1] = createBlip(x, y, z, 0, 2, 255, 220, 0)
		self.markers[#self.markers + 1] = createMarker(x, y, z, "checkpoint", 8, 255, 220, 0)
	end

	self.active = true

	triggerClientEvent(getRootElement(), g_ESCAPE_ROUTE_APPEARED, resourceRoot)
end