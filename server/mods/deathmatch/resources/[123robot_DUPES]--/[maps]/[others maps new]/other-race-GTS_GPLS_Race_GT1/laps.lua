local times = {}

addEvent("onPlayerReachCheckpoint", true)
addEventHandler("onPlayerReachCheckpoint", getRootElement(),
    function(cp, time)
        if cp == 24 then
            -- triggerEvent("onPlayerFinish", source, 1000, time)
            triggerClientEvent(source, "onLapStarted", getRootElement())
            times[source] = getTickCount()
            setElementData(source, "Lap", 2)
            triggerClientEvent(source, 'onLapTime', getRootElement(), time)
        end
        if cp == 48 then
            local c_time = getTickCount()
            local l_time = c_time - times[source]
            times[source] = getTickCount()
            -- triggerEvent("onPlayerFinish", source, 1000, l_time)
            triggerClientEvent(source, "onLapStarted", getRootElement())
            setElementData(source, "Lap", 3)
            triggerClientEvent(source, 'onLapTime', getRootElement(), l_time)
        end
        if cp == 72 then
            local c_time = getTickCount()
            local l_time = c_time - times[source]
            times[source] = getTickCount()
            -- triggerEvent("onPlayerFinish", source, 1000, l_time)
            triggerClientEvent(source, "onLapStarted", getRootElement())
            setElementData(source, "Lap", 4)
            triggerClientEvent(source, 'onLapTime', getRootElement(), l_time)
        end
        if cp == 96 then
            local c_time = getTickCount()
            local l_time = c_time - times[source]
            times[source] = getTickCount()
            -- triggerEvent("onPlayerFinish", source, 1000, l_time)
            triggerClientEvent(source, "onLapStarted", getRootElement())
            setElementData(source, "Lap", 5)
            triggerClientEvent(source, 'onLapTime', getRootElement(), l_time)
        end
        if cp == 120 then
            local c_time = getTickCount()
            local l_time = c_time - times[source]
            times[source] = getTickCount()
            -- triggerEvent("onPlayerFinish", source, 1000, l_time)
            triggerClientEvent(source, "onLapStarted", getRootElement())
            setElementData(source, "Lap", 6)
            triggerClientEvent(source, 'onLapTime', getRootElement(), l_time)
        end
        if cp == 144 then
            local c_time = getTickCount()
            local l_time = c_time - times[source]
            times[source] = getTickCount()
            -- triggerEvent("onPlayerFinish", source, 1000, l_time)
            triggerClientEvent(source, "onLapStarted", getRootElement())
            setElementData(source, "Lap", 7)
            triggerClientEvent(source, 'onLapTime', getRootElement(), l_time)
        end
        if cp == 168 then
            local c_time = getTickCount()
            local l_time = c_time - times[source]
            times[source] = getTickCount()
            -- triggerEvent("onPlayerFinish", source, 1000, l_time)
            triggerClientEvent(source, "onLapStarted", getRootElement())
            setElementData(source, "Lap", 8)
            triggerClientEvent(source, 'onLapTime', getRootElement(), l_time)
        end
        if cp == 192 then
            local c_time = getTickCount()
            local l_time = c_time - times[source]
            times[source] = getTickCount()
            -- triggerEvent("onPlayerFinish", source, 1000, l_time)
            triggerClientEvent(source, "onLapStarted", getRootElement())
            setElementData(source, "Lap", 9)
            triggerClientEvent(source, 'onLapTime', getRootElement(), l_time)
        end
        if cp == 216 then
            local c_time = getTickCount()
            local l_time = c_time - times[source]
            times[source] = getTickCount()
            -- triggerEvent("onPlayerFinish", source, 1000, l_time)
            triggerClientEvent(source, "onLapStarted", getRootElement())
            setElementData(source, "Lap", 10)
            triggerClientEvent(source, 'onLapTime', getRootElement(), l_time)
        end        
        if cp == 240 then
            local c_time = getTickCount()
            local l_time = c_time - times[source]
            times[source] = getTickCount()
            -- triggerEvent("onPlayerFinish", source, 1000, l_time)
            triggerClientEvent(source, "onLapStarted", getRootElement())
            setElementData(source, "Lap", 11)
            triggerClientEvent(source, 'onLapTime', getRootElement(), l_time)
        end
        if cp == 264 then
            local c_time = getTickCount()
            local l_time = c_time - times[source]
            times[source] = getTickCount()
            -- triggerEvent("onPlayerFinish", source, 1000, l_time)
            triggerClientEvent(source, "onLapStarted", getRootElement())
            setElementData(source, "Lap", 12)
            triggerClientEvent(source, 'onLapTime', getRootElement(), l_time)
        end
        if cp == 288 then
            local c_time = getTickCount()
            local l_time = c_time - times[source]
            times[source] = getTickCount()
            -- triggerEvent("onPlayerFinish", source, 1000, l_time)
            triggerClientEvent(source, "onLapStarted", getRootElement())
            setElementData(source, "Lap", 13)
            triggerClientEvent(source, 'onLapTime', getRootElement(), l_time)
        end
        if cp == 312 then
            local c_time = getTickCount()
            local l_time = c_time - times[source]
            times[source] = getTickCount()
            -- triggerEvent("onPlayerFinish", source, 1000, l_time)
            triggerClientEvent(source, "onLapStarted", getRootElement())
            setElementData(source, "Lap", 14)
            triggerClientEvent(source, 'onLapTime', getRootElement(), l_time)
        end
        if cp == 336 then
            local c_time = getTickCount()
            local l_time = c_time - times[source]
            times[source] = getTickCount()
            -- triggerEvent("onPlayerFinish", source, 1000, l_time)
            triggerClientEvent(source, "onLapStarted", getRootElement())
            setElementData(source, "Lap", 15)
            triggerClientEvent(source, 'onLapTime', getRootElement(), l_time)
        end
        
    end
)

addEvent("onPlayerFinish", true)
addEventHandler("onPlayerFinish", getRootElement(),
    function(rank,time)
        if rank == 1000 then return end
        local c_time = getTickCount()
        local l_time = c_time - times[source]
        times[source] = getTickCount()
        --outputChatBox("lap 5 time for "..getPlayerName(source)..": "..formatTime(l_time))
        triggerEvent("onPlayerFinish", source, 1000, l_time)
        triggerClientEvent(source, 'onLapTime', getRootElement(), l_time)
    end
)

addEventHandler("onResourceStart", getResourceRootElement(getThisResource()),
    function()
        for i,player in ipairs(getElementsByType("player")) do
            setElementData(player, "Lap", 1)
        end
        call(getResourceFromName("scoreboard"), "scoreboardAddColumn", "Lap")
    end
)

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

addEvent("onRaceStateChanging")
addEventHandler("onRaceStateChanging", getRootElement(),
    function(old,new)
        if old == 'Running' then
            for i,player in ipairs(getElementsByType("player")) do
                triggerClientEvent(player, "onLapStarted", getRootElement())
                triggerClientEvent(player, "onStartBla", getRootElement())
            end
        end
    end
)