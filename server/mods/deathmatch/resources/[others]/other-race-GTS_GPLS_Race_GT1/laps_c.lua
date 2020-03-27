local x,y = guiGetScreenSize()
local time = 0
fontLCD22 = dxCreateFont("lcd.ttf", 22)
local lap_time = 0

function hideTime()
    time = 0
end

function formatTime(ms)
    if not ms then
        return ''
    end
    local centiseconds = tostring(math.floor(math.fmod(ms, 1000)/10))
    if #centiseconds == 1 then
        centiseconds = '0' .. centiseconds
    end
    local s = math.floor(ms / 1000)
    local seconds = tostring(math.fmod(s, 60))
    if #seconds == 1 then
        seconds = '0' .. seconds
    end
    local minutes = tostring(math.floor(s / 60))
    return minutes .. ':' .. seconds .. ':' .. centiseconds
end

function updateDisplay()
    local pos = 1
    local pstfx = 'st'
    local target = localPlayer
    if getElementData(localPlayer, 'race.spectating') then
        target = getVehicleOccupant(getCameraTarget(localPlayer), 0)
    end
    dxDrawRectangle(x - 151, y - 128, 150, 30, tocolor(10,10,10,150))
    dxDrawText("000000000", x - 90, y - 125, 40, 30, tocolor(25, 25, 25, 220), 0.6, fontLCD22, "left", "top", false, false, false)
    dxDrawText("*********", x - 90, y - 125, 40, 30, tocolor(25, 25, 25, 220), 0.6, fontLCD22, "left", "top", false, false, false)
    dxDrawText("lap "..tostring(getElementData(target, "Lap")).."/5", x - 90, y- 125, 40, 30, tocolor(255, 255, 255, 255), 0.6, fontLCD22, "left", "top", false, false, false)
    dxDrawRectangle(x - 151, y - 202, 150, 30, tocolor(10,10,10,150))
    dxDrawText("00000000:00:00:00", x-145, y-199, x-145, y-199, tocolor (25, 25, 25, 220), 0.6, fontLCD22)
    dxDrawText("********:**:**:**", x-145, y-199, x-145, y-199, tocolor (25, 25, 25, 220), 0.6, fontLCD22)
    pos = getElementData(target, "race rank")
    if pos == 1 then
        pstfx = 'st'
    elseif pos == 2 then
        pstfx = 'nd'
    elseif pos == 3 then
       pstfx = 'rd'
    else
       pstfx = 'th'
    end
    dxDrawRectangle(x - 151, y - 170, 150, 40, tocolor(10,10,10,150))
    dxDrawText("00", x - 27, y - 170, x - 27, y - 170, tocolor(25, 25, 25, 220), 1, fontLCD22, "right", "top", false, false, false)
    dxDrawText("**", x - 27, y - 170, x - 27, y - 170, tocolor(25, 25, 25, 220), 1, fontLCD22, "right", "top", false, false, false)
    dxDrawText(tostring(pos), x - 27, y - 170, x - 27, y - 170, tocolor(255, 255, 255, 255), 1, fontLCD22, "right", "top", false, false, false)
    dxDrawText("00", x - 5, y - 166, x - 5, y - 166, tocolor(25, 25, 25, 220), 0.6, fontLCD22, "right", "top", false, false, false)
    dxDrawText("**", x - 5, y - 166, x - 5, y - 166, tocolor(25, 25, 25, 220), 0.6, fontLCD22, "right", "top", false, false, false)
    dxDrawText(pstfx, x - 5, y - 166, x - 5, y - 166, tocolor(255, 255, 255, 255), 0.6, fontLCD22, "right", "top", false, false, false)
    if getElementData(localPlayer, 'race.spectating') then return end
    if time ~= 0 then
        dxDrawText("Lap time: "..formatTime(time), x-145, y-199, x-145, y-199, tocolor ( 0, 255, 255, 255 ), 0.6, fontLCD22)
    elseif lap_time == 0 then
        dxDrawText("Lap time: "..formatTime(0), x-145, y-199, x-145, y-199, tocolor ( 255, 255, 255, 255 ), 0.6, fontLCD22)
    else
        dxDrawText("Lap time: "..formatTime(getTickCount() - lap_time), x-145, y-199, x-145, y-199, tocolor ( 255, 255, 255, 255 ), 0.6, fontLCD22)
    end
end


addEventHandler("onClientRender", getRootElement(), updateDisplay)

addEvent("onLapTime", true)
addEventHandler("onLapTime", getRootElement(),
    function(l_time)
        time = l_time
        setTimer(hideTime, 10000, 1)
    end
)

addEvent("onLapStarted", true)
addEventHandler("onLapStarted", getRootElement(),
    function()
        lap_time = getTickCount()
    end
)

addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()),
    function()
        if getElementData(localPlayer, "Lap") ~= 1 then
            setElementData(localPlayer, "Lap", 1)
        end
    end
)
