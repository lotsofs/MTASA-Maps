local people = getRootElement()



local gate1 = getElementByID("toldicht1")
local marker1 = getElementByID("tolmarker1")
local x1, y1, z1 = getElementPosition(gate1)

function open1()
    if (gate1) then
	moveObject (gate1, 1500, x1, y1, z1, 0, 90, 0)
	setTimer(close1, 3000, 1)
    end
end
addEventHandler("onMarkerHit", marker1, function()
    clearElementVisibleTo(marker1)
    setTimer(open1, 2000, 1)
end
)

function close1()
    if (gate1) then
	moveObject (gate1, 1500, x1, y1, z1, 0, -90, 0)
	setElementVisibleTo(marker1, people, true)
    end
end



local gate2 = getElementByID("toldicht2")
local marker2 = getElementByID("tolmarker2")
local x2, y2, z2 = getElementPosition(gate2)

function open2()
    if (gate2) then
	moveObject (gate2, 1500, x2, y2, z2, 0, 90, 0)
	setTimer(close2, 3000, 1)
    end
end
addEventHandler("onMarkerHit", marker2, function()
    clearElementVisibleTo(marker2)
    setTimer(open2, 2000, 1)
end
)

function close2()
    if (gate2) then
	moveObject (gate2, 1500, x2, y2, z2, 0, -90, 0)
	setElementVisibleTo(marker2, people, true)
    end
end



local gate3 = getElementByID("toldicht3")
local marker3 = getElementByID("tolmarker3")
local x3, y3, z3 = getElementPosition(gate3)

function open3()
    if (gate3) then
	moveObject (gate3, 1500, x3, y3, z3, 0, 90, 0)
	setTimer(close3, 3000, 1)
    end
end
addEventHandler("onMarkerHit", marker3, function()
    clearElementVisibleTo(marker3)
    setTimer(open3, 2000, 1)
end
)

function close3()
    if (gate3) then
	moveObject (gate3, 1500, x3, y3, z3, 0, -90, 0)
	setElementVisibleTo(marker3, people, true)
    end
end



local gate4 = getElementByID("toldicht4")
local marker4 = getElementByID("tolmarker4")
local x4, y4, z4 = getElementPosition(gate4)

function open4()
    if (gate4) then
	moveObject (gate4, 1500, x4, y4, z4, 0, 90, 0)
	setTimer(close4, 3000, 1)
    end
end
addEventHandler("onMarkerHit", marker4, function()
    clearElementVisibleTo(marker4)
    setTimer(open4, 2000, 1)
end
)

function close4()
    if (gate4) then
	moveObject (gate4, 1500, x4, y4, z4, 0, -90, 0)
	setElementVisibleTo(marker4, people, true)
    end
end

local weaponizer = createColSphere (-2271.525390625, 1543.455078125, 30.481227874756, 8)

function weaponize(numberOne, matchingDimension)
    giveWeapon(numberOne, 29, 300, true)
    outputChatBox("You have a weapon, now you can do driveby's", numberOne, 255, 255, 255, false)
end
addEventHandler("onColShapeHit", weaponizer, weaponize)
