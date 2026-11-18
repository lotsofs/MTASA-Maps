
props = {
	{['model'] = 3243, ['resize'] = 1,    ['zoffset'] = 0.34, ['description'] = 'a TeePee'                   },
	{['model'] = 3615, ['resize'] = 1,    ['zoffset'] = 2.53, ['description'] = 'a beach hut'                },
	{['model'] = 3426, ['resize'] = 0.25, ['zoffset'] = 0.27, ['description'] = 'an oil pump'                },
	{['model'] = 3175, ['resize'] = 1,    ['zoffset'] = 0.34, ['description'] = 'a trailer'                  },
	{['model'] = 1454, ['resize'] = 1,    ['zoffset'] = 1.14, ['description'] = 'a hay bale'                 },
	{['model'] = 3337, ['resize'] = 1,    ['zoffset'] = 0.34, ['description'] = 'a green sign'               },
	{['model'] = 3244, ['resize'] = 1,    ['zoffset'] = 0.34, ['description'] = 'a big power pylon'          },
	{['model'] = 3269, ['resize'] = 0.25, ['zoffset'] = 0.34, ['description'] = 'an airplane wreck'          },
	{['model'] = 3350, ['resize'] = 1,    ['zoffset'] = 0.34, ['description'] = "Mike's Mic"                 },
	{['model'] = 3524, ['resize'] = 1,    ['zoffset'] = 1.98, ['description'] = 'a flaming skull'            },
	{['model'] = 1349, ['resize'] = 1,    ['zoffset'] = 0.91, ['description'] = 'a shopping cart'            },
	{['model'] = 1280, ['resize'] = 1,    ['zoffset'] = 0.73, ['description'] = 'a park bench'               },
	{['model'] = 1211, ['resize'] = 1,    ['zoffset'] = 0.94, ['description'] = 'a fire hydrant'             },
	{['model'] = 3594, ['resize'] = 1,    ['zoffset'] = 1.05, ['description'] = 'a car wreck'                },
	{['model'] = 712 , ['resize'] = 1,    ['zoffset'] = 9.45, ['description'] = 'a small palm tree'          },
	{['model'] = 1341, ['resize'] = 1,    ['zoffset'] = 1.35, ['description'] = 'an ice cream cart'          },
	{['model'] = 1676, ['resize'] = 1,    ['zoffset'] = 1.92, ['description'] = 'a gas pump'                 },
	{['model'] = 1373, ['resize'] = 1,    ['zoffset'] = 2.90, ['description'] = 'a railroad crossing sign'   },
	{['model'] = 3853, ['resize'] = 1,    ['zoffset'] = 4.22, ['description'] = 'a fabulous lamp post'       },
	{['model'] = 1369, ['resize'] = 1,    ['zoffset'] = 0.97, ['description'] = 'a rusty wheelchair'         },
	{['model'] = 1461, ['resize'] = 1,    ['zoffset'] = 1.14, ['description'] = 'a personal flotation device'},
	{['model'] = 1215, ['resize'] = 1,    ['zoffset'] = 0.91, ['description'] = 'a bollard light'            },
	{['model'] = 1319, ['resize'] = 1,    ['zoffset'] = 0.89, ['description'] = 'a striped bollard'          },
	{['model'] = 973 , ['resize'] = 1,    ['zoffset'] = 1.2, ['description'] = 'a road barrier'             },
	{['model'] = 3281, ['resize'] = 1,    ['zoffset'] = 1.36, ['description'] = 'an xtreme pro-laps sign'    },
	{['model'] = 1256, ['resize'] = 1,    ['zoffset'] = 1.00, ['description'] = 'a stone bench'              },
	{['model'] = 1216, ['resize'] = 1,    ['zoffset'] = 1.00, ['description'] = 'a payphone'                 },
	{['model'] = 1257, ['resize'] = 1,    ['zoffset'] = 1.625, ['description'] = 'a bus stop shelter'         },
	{['model'] = 1219, ['resize'] = 1,    ['zoffset'] = 0.61, ['description'] = 'a wooden pallet'            },
	{['model'] = 1267, ['resize'] = 0.5,  ['zoffset'] = 8.4, ['description'] = 'a double billboard'         },
	{['model'] = 1285, ['resize'] = 1,    ['zoffset'] = 0.9, ['description'] = 'a yellow newspaper stand'   },
	{['model'] = 1300, ['resize'] = 1,    ['zoffset'] = 0.69, ['description'] = 'a rectangular bin'          },
	{['model'] = 1415, ['resize'] = 1,    ['zoffset'] = 0.47, ['description'] = 'a wood filled dumpster'     },
	{['model'] = 1690, ['resize'] = 1,    ['zoffset'] = 1.01, ['description'] = 'a pair of small roof vents' },
	{['model'] = 1498, ['resize'] = 1,    ['zoffset'] = 0.34, ['description'] = 'a white door'               },
	{['model'] = 956,  ['resize'] = 1,    ['zoffset'] = 0.75, ['description'] = 'a candy vending machine'    },
	{['model'] = 1365, ['resize'] = 1,    ['zoffset'] = 1.5, ['description'] = 'a large waste container'    },
	{['model'] = 1503, ['resize'] = 1,    ['zoffset'] = 0.75, ['description'] = 'a small makeshift ramp'     },
	{['model'] = 3852, ['resize'] = 1,    ['zoffset'] = 1.9, ['description'] = 'a concrete utility shed'    },
	{['model'] = 3458, ['resize'] = 0.6,  ['zoffset'] = 1.25, ['description'] = 'a car shade'                },
	-- [7981] -- small radar
	-- [963]  -- a ticket machine
    -- [955]  -- a soda vending machine
}

offsets = { {80, -80},
            {90, -70},
            {90, -90},
            {70, -70},
            {70, -90},}

local selected_props = {}

local descriptions = {}

local gate1,gate2,gate3,gate4

function raceState(newstate,oldstate)

    if (newstate == 'LoadingMap') then

        -- select 5 random props
        for i=1,5 do
            local selected_prop = table.remove(props, math.random(#props))

            local o = createObject(selected_prop['model'], offsets[i][1], offsets[i][2], selected_prop['zoffset'])
            setElementCollisionsEnabled(o, false)
            setObjectScale(o, selected_prop['resize'])
            setObjectBreakable(o, false)
            setElementDoubleSided(o, true)

            table.insert(selected_props, selected_prop)
            descriptions[selected_prop['model']] = selected_prop['description']
        end

        for key, value in pairs (descriptions) do
            print(key, value)
        end

        -- create gates
        gate1 = createObject(8210, 80, -107.96972656, 2.9, 0, 0, 180)
        gate2 = createObject(8210, 80, -52.009765625, 2.9, 0, 0, 0)
        gate3 = createObject(8210, 107.98046875, -80, 2.9, 0, 0, 270)
        gate4 = createObject(8210, 51.98046875, -80,  2.9, 0, 0, 90)

    end

    if (newstate == "PreGridCountdown") then
        
    end

    if (newstate == "GridCountdown") then

        triggerClientEvent ("receivePropData", resourceRoot, selected_props )
        addEventHandler ( "onPlayerJoin", root, sendPropData )

        outputChatBox ( "Find 3 out of the 5 shown objects. There is a detection beam on the front of your bike. You need to find:", root, 0, 255, 0, true )
        for i, prop in ipairs(selected_props) do
            outputChatBox ( "- " .. prop['description'], root, 0, 255, 0, true )
        end
        outputChatBox ( "The gates will open soon, good luck! ", root, 0, 255, 0, true )

        -- create gate countdown display
        countdownDisplay = textCreateDisplay()
        countdownText = textCreateTextItem("15",0.5,0.25,"medium",255,0,0,255,3,"center","center",255)
        textDisplayAddText (countdownDisplay,countdownText)
        for index,thePlayer in ipairs (getElementsByType("player")) do
            textDisplayAddObserver(countdownDisplay,thePlayer)
        end

    end

    if (newstate == "Running" and oldstate == "GridCountdown") then

        -- countdown gates
        local timeLeft = 15
        setTimer(function()
            timeLeft = timeLeft - 1
            if (timeLeft <= 0) then
                textDestroyDisplay(countdownDisplay)
            else
                textItemSetText(countdownText,tostring(timeLeft))
            end
        end,1000,15)
        
        -- open gates
        setTimer(function()
            triggerClientEvent ("soundAirHorn", resourceRoot)

            for i, gate in ipairs ({gate1, gate2, gate3, gate4}) do
                local x,y,z = getElementPosition(gate)
                print(x,y,z)
                moveObject(gate ,5000, x,y,z-20)
            end
        end, 15000, 1)
    end
end
addEvent ( "onRaceStateChanging", true )
addEventHandler ( "onRaceStateChanging", getRootElement(), raceState )


function sendPropData ( )
    triggerClientEvent (source, "receivePropData", resourceRoot, selected_props )
end


-- Send messages on first find of an object
collected_props = {}
function onServerSendMessage(collected, x, y, z)
    if (not client) then -- 'client' points to the player who triggered the event, and should be used as security measure (in order to prevent player faking)
        return false -- if this variable doesn't exists at the moment (for unknown reason, or it was the server who triggered this event), stop code execution
    end

    local matchingSource = (source == client) -- check whether source element (2nd argument in triggerServerEvent) passed from client was the exact same player

    if (not matchingSource) then -- apparently it wasn't
        return false -- so do not process this event
    end

    if not collected_props[collected] then
        collected_props[collected] = true
        outputChatBox ( getPlayerName(client) .. "#FFFFFF was first to find " .. descriptions[collected] .. " in #00FF00" .. getZoneName(x, y, z) .. " - " .. getZoneName(x, y, z, true) .. "!", root, 0, 255, 0, true )
    end
end
addEvent("onServerSendMessage", true) -- 2nd argument should be set to true, in order to be triggered from counter side (in this case client-side)
addEventHandler("onServerSendMessage", root, onServerSendMessage)
