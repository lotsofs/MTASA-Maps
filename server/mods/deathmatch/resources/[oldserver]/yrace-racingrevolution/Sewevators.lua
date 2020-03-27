local people = getRootElement()

local sewevator1 = getElementByID("lift1")
local marker1 = getElementByID("m1")
local x1, y1, z1 = getElementPosition(sewevator1)

function up1()
    if (sewevator1) then
	moveObject (sewevator1, 7500, x1, y1, z1+31.60)
	setTimer(down1, 10000, 1)
    end
end
addEventHandler("onMarkerHit", marker1, function()
    clearElementVisibleTo(marker1)
    setTimer(up1, 500, 1)
end
)

function down1()
    if (sewevator1) then
	moveObject (sewevator1, 3000, x1, y1, z1, 180, 180, 0)
	setElementVisibleTo(marker1, people, true)
    end
end


local sewevator2 = getElementByID("lift2")
local marker2 = getElementByID("m2")
local x2, y2, z2 = getElementPosition(sewevator2)

function up2()
    if (sewevator2) then
	moveObject (sewevator2, 7500, x2, y2, z2+31.60)
	setTimer(down2, 10000, 1)
    end
end
addEventHandler("onMarkerHit", marker2, function()
    clearElementVisibleTo(marker2)
    setTimer(up2, 500, 1)
end
)

function down2()
    if (sewevator2) then
	moveObject (sewevator2, 3000, x2, y2, z2, 180, 180, 0)
	setElementVisibleTo(marker2, people, true)
    end
end


local sewevator3 = getElementByID("lift3")
local marker3 = getElementByID("m3")
local x3, y3, z3 = getElementPosition(sewevator3)

function up3()
    if (sewevator3) then
	moveObject (sewevator3, 7500, x3, y3, z3+31.60)
	setTimer(down3, 10000, 1)
    end
end
addEventHandler("onMarkerHit", marker3, function()
    clearElementVisibleTo(marker3)
    setTimer(up3, 500, 1)
end
)

function down3()
    if (sewevator3) then
	moveObject (sewevator3, 3000, x3, y3, z3, 180, 180, 0)
	setElementVisibleTo(marker3, people, true)
    end
end


local sewevator4 = getElementByID("lift4")
local marker4 = getElementByID("m4")
local x4, y4, z4 = getElementPosition(sewevator4)

function up4()
    if (sewevator4) then
	moveObject (sewevator4, 7500, x4, y4, z4+31.60)
	setTimer(down4, 10000, 1)
    end
end
addEventHandler("onMarkerHit", marker4, function()
    clearElementVisibleTo(marker4)
    setTimer(up4, 500, 1)
end
)

function down4()
    if (sewevator4) then
	moveObject (sewevator4, 3000, x4, y4, z4, 180, 180, 0)
	setElementVisibleTo(marker4, people, true)
    end
end


local sewevator5 = getElementByID("lift5")
local marker5 = getElementByID("m5")
local x5, y5, z5 = getElementPosition(sewevator5)

function up5()
    if (sewevator5) then
	moveObject (sewevator5, 7500, x5, y5, z5+31.60)
	setTimer(down5, 10000, 1)
    end
end
addEventHandler("onMarkerHit", marker5, function()
    clearElementVisibleTo(marker5)
    setTimer(up5, 500, 1)
end
)

function down5()
    if (sewevator5) then
	moveObject (sewevator5, 3000, x5, y5, z5, 180, 180, 0)
	setElementVisibleTo(marker5, people, true)
    end
end



local sewevator6 = getElementByID("lift6")
local marker6 = getElementByID("m6")
local x6, y6, z6 = getElementPosition(sewevator6)

function up6()
    if (sewevator6) then
	moveObject (sewevator6, 7500, x6, y6, z6+31.60)
	setTimer(down6, 10000, 1)
    end
end
addEventHandler("onMarkerHit", marker6, function()
    clearElementVisibleTo(marker6)
    setTimer(up6, 500, 1)
end
)

function down6()
    if (sewevator6) then
	moveObject (sewevator6, 3000, x6, y6, z6, 180, 180, 0)
	setElementVisibleTo(marker6, people, true)
    end
end



local sewevator7 = getElementByID("lift7")
local marker7 = getElementByID("m7")
local x7, y7, z7 = getElementPosition(sewevator7)

function up7()
    if (sewevator7) then
	moveObject (sewevator7, 7500, x7, y7, z7+31.60)
	setTimer(down7, 10000, 1)
    end
end
addEventHandler("onMarkerHit", marker7, function()
    clearElementVisibleTo(marker7)
    setTimer(up7, 500, 1)
end
)

function down7()
    if (sewevator7) then
	moveObject (sewevator7, 3000, x7, y7, z7, 180, 180, 0)
	setElementVisibleTo(marker7, people, true)
    end
end


local sewevator8 = getElementByID("lift8")
local marker8 = getElementByID("m8")
local x8, y8, z8 = getElementPosition(sewevator8)

function up8()
    if (sewevator8) then
	moveObject (sewevator8, 7500, x8, y8, z8+31.60)
	setTimer(down8, 10000, 1)
    end
end
addEventHandler("onMarkerHit", marker8, function()
    clearElementVisibleTo(marker8)
    setTimer(up8, 500, 1)
end
)

function down8()
    if (sewevator8) then
	moveObject (sewevator8, 3000, x8, y8, z8, 180, 180, 0)
	setElementVisibleTo(marker8, people, true)
    end
end
