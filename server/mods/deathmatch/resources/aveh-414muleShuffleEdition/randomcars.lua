local cars = {
	[400] = 2.22, --landstalker,
	[401] = 1.55, --bravura,
	[402] = 1.55, --buffalo,
	[403] = 2.77, --linerunner,
	[404] = 1.44, --perennial,
	[405] = 1.55, --sentinel,
	[406] = 4.44, --dumper,
	[407] = 2.11, --firetruck,
	[408] = 2.77, --trashmaster,
	[409] = 1.55, --stretch,
	[410] = 1.55, --manana,
	[411] = 1.55, --infernus,
	[412] = 1.33, --voodoo,
	[413] = 2.22, --pony,
	--[414] = 2.33, --mule,
	[415] = 1.55, --cheetah,
	[416] = 2.11, --ambulance,
	[417] = 2.22, --leviathan,
	[418] = 1.99, --moonbeam,
	[419] = 1.22, --esperanto,
	[420] = 1.73, --taxi,
	[421] = 1.55, --washington,
	[422] = 1.88, --bobcat,
	[423] = 2.22, --mrwhoopee,
	[424] = 1.88, --bfinjection,
	--[425] = 2.11, --hunter,
	[426] = 1.55, --premier,
	[427] = 2.11, --enforcer,
	[428] = 1.88, --securicar,
	[429] = 1.33, --banshee,
	--[430] = 1.55, --predator,
	[431] = 2.11, --bus,
	[432] = 2.44, --rhino,
	[433] = 2.88, --barracks,
	[434] = 2.11, --hotknife,
	--[435] = 3.22, --trailer1,
	[436] = 1.55, --previon,
	[437] = 2.11, --coach,
	[438] = 1.55, --cabbie,
	[439] = 1.55, --stallion,
	[440] = 2.38, --rumpo,
	--[441] = 0.44, --rcbandit,
	[442] = 1.55, --romero,
	[443] = 2.77, --packer,
	[444] = 2.55, --monster,
	[445] = 1.55, --admiral,
	--[446] = 1.55, --squalo,
	--[447] = 1.55, --seasparrow,
	[448] = 1.44, --pizzaboy,
	--[449] = 1.55, --tram,
	--[450] = 3.22, --trailer2,
	[451] = 1.88, --turismo,
	--[452] = 1.55, --speeder,
	--[453] = 2.22, --reefer,
	--[454] = 1.55, --tropic,
	[455] = 3.11, --flatbed,
	[456] = 2.61, --yankee,
	[457] = 1.11, --caddy,
	[458] = 1.44, --solair,
	[459] = 2.11, --berkleysrcvan,
	--[460] = 3.55, --skimmer,
	[461] = 1.33, --pcj600,
	[462] = 1.55, --faggio,
	[463] = 1.37, --freeway,
	--[464] = 0.44, --rcbaron,
	--[465] = 0.44, --rcraider,
	[466] = 1.55, --glendale,
	[467] = 1.55, --oceanic,
	[468] = 1.44, --sanchez,
	--[469] = 1.55, --sparrow,
	[470] = 2.11, --patriot,
	[471] = 1.44, --quadbike,
	--[472] = 1.55, --coastguard,
	--[473] = 1.66, --dinghy,
	[474] = 1.55, --hermes,
	[475] = 1.55, --sabre,
	--[476] = 4.44, --rustler,
	[477] = 1.55, --zr350,
	[478] = 2.22, --walton,
	[479] = 2.01, --regina,
	[480] = 1.55, --comet,
	[481 ] = 0.88, --bmx,
	[482] = 2.11, --burrito,
	[483] = 2.11, --camper,
	--[484 ] = 1.55, --marquis,
	[485] = 1.11, --baggage,
	[486] = 2.22, --dozer,
	--[487] = 1.77, --maverick,
	--[488] = 1.77, --newschopper,
	[489] = 2.55, --rancher,
	[490] = 2.55, --fbirancher,
	[491] = 1.77, --virgo,
	[492] = 1.55, --greenwood,
	--[493] = 2.22, --jetmax,
	[494] = 1.44, --hotringracer,
	[495] = 3.44, --sandking,
	[496 ] = 1.55, --blistacompact,
	[497] = 1.77, --policemaverick,
	[498] = 2.55, --boxville,
	[499] = 2.00, --benson,
	[500] = 1.77, --mesa,
	--[501] = 0.44, --rcgoblin,
	--[502] = 1.44, --hotringracer2,
	--[503] = 1.44, --hotringracer3,
	[504] = 1.22, --bloodringbanger,
	--[505] = 2.11, --rancherlure,
	[506] = 1.55, --supergt,
	[507] = 1.55, --elegant,
	[508] = 2.44, --journey,
	[509] = 0.99, --bike,
	[510] = 0.99, --mountainbike,
	--[511] = 3.11, --beagle,
	--[512] = 4.33, --cropduster,
	--[513] = 3.33, --stuntplane,
	[514] = 3.44, --tanker,
	[515] = 3.55, --roadtrain,
	[516] = 1.77, --nebula,
	[517] = 1.55, --majestic,
	[518] = 1.15, --buccaneer,
	--[519] = 4.88, --shamal,
	[520] = 4.88, --hydra,
	[521] = 1.33, --fcr900,
	[522] = 1.33, --nrg500,
	[523] = 1.33, --hpv1000,
	[524] = 3.66, --cementtruck,
	[525] = 1.88, --towtruck,
	[526] = 1.33, --fortune,
	[527] = 1.44, --cadrona,
	[528] = 2.44, --fbitruck,
	[529] = 1.55, --willard,
	[530] = 1.55, --forklift,
	[531] = 2.33, --tractor,
	[532] = 3.77, --combineharvester,
	[533] = 1.55, --feltzer,
	[534] = 1.11, --remington,
	[535] = 0.99, --slamvan,
	[536] = 1.11, --blade,
	--[537] = 1.55, --freight,
	--[538] = 1.55, --brownstreak,
	[539] = 1.22, --vortex,
	[540] = 1.88, --vincent,
	[541] = 1.77, --bullet,
	[542] = 1.55, --clover,
	[543] = 1.66, --sadler,
	[544] = 2.11, --firetruckladder,
	[545] = 1.55, --hustler,
	[546] = 1.55, --intruder,
	[547] = 1.55, --primo,
	--[548] = 5.55, --cargobob,
	[549] = 1.55, --tampa,
	[550] = 1.55, --sunrise,
	[551] = 1.55, --merit,
	[552] = 1.41, --utilityvan,
	--[553] = 5.55, --nevada,
	[554] = 1.99, --yosemite,
	[555] = 1.55, --windsor,
	--[556] = 2.55, --monster2,
	--[557] = 2.55, --monster3,
	[558] = 1.38, --uranus,
	[559] = 1.45, --jester,
	[560] = 1.61, --sultan,
	[561] = 1.55, --stratum,
	[562] = 1.44, --elegy,
	--[563] = 2.11, --raindance,
	[564] = 0.44, --rctiger,
	[565] = 1.44, --flash,
	[566] = 1.55, --tahoma,
	[567] = 1.28, --savanna,
	[568] = 1.44, --bandito,
	--[569] = 1.55, --freightflatbed,
	--[570] = 2.11, --brownstreakcarriage,
	[571] = 0.01, --kart,
	[572] = 1.11, --mower,
	[573] = 2.59, --dune,
	[574] = 1.22, --sweeper,
	[575] = 0.89, --broadway,
	[576] = 0.99, --tornado,
	--[577] = 3.55, --at400,
	[578] = 3.44, --dft30,
	[579] = 1.99, --huntley,
	[580] = 1.55, --stafford,
	[581] = 1.33, --bf400,
	[582] = 1.99, --newsvan,
	[583] = 0.99, --tug,
	--[584] = 4.11, --trailertankercommando,
	[585] = 1.55, --emperor,
	[586] = 1.55, --wayfarer,
	[587] = 1.55, --euros,
	[588] = 2.11, --hotdog,
	[589] = 1.44, --club,
	--[590] = 1.55, --boxfreight,
	--[591] = 3.22, --trailer3,
	--[592] = 4.55, --andromada,
	[593] = 2.88, --dodo,
	--[594] = 0.22, --rccam,
	--[595] = 1.99, --launch,
	--[596] = 1.55, --policels,
	[597] = 1.55, --policesf,
	[598] = 1.55, --policelv,
	[599] = 1.99, --policeranger,
	[600] = 1.77, --picador,
	[601] = 1.51, --swat,
	[602] = 1.55, --alpha,
	[603] = 1.55, --phoenix,
	[604] = 1.55, --glendaledamaged,
	[605] = 1.66, --sadlerdamaged,
	[606] = 2.22, --baggagetrailercovered,
	[607] = 2.22, --baggagetraileruncovered,
	--[608] = 3.11, --trailerstairs,
	[609] = 2.55, --boxvillemission,
	--[610] = 1.33, --farmtrailer,
	--[611] = 1.99, --streetcleantrailer,
}
-- 212 - 51 comments = 161

function selectVehicle()
	local desiredIndex = math.random(161)
	local selectedIndex = 1
	for i, h in pairs(cars) do
		if selectedIndex == desiredIndex then
			local oldHeight = 2.33
			local newHeight = h
			local diffHeight = newHeight/2 - oldHeight/2 + 0.1
			if i == 478 then
				diffHeight = diffHeight + 0.5
			elseif i == 486 then
				diffHeight = diffHeight + 0.5
			elseif i == 456 then
				diffHeight = diffHeight + 0.5
			elseif i == 414 then
				diffHeight = diffHeight + 0.3
			elseif i == 499 then
				diffHeight = diffHeight + 0.5
			elseif i == 552 then
				diffHeight = diffHeight + 0.5
			elseif i == 433 then
				diffHeight = diffHeight + 0.5
			elseif i == 543 then
				diffHeight = diffHeight + 0.5
			elseif i == 605 then
				diffHeight = diffHeight + 0.5
			elseif i == 609 then
				diffHeight = diffHeight + 0.5
			elseif i == 498 then
				diffHeight = diffHeight + 0.5
			elseif i == 525 then
				diffHeight = diffHeight + 0.5
			elseif i == 571 then
				diffHeight = diffHeight + 0.15
			elseif i == 432 then
				diffHeight = diffHeight + 1
			end
			return i, diffHeight
		else
			selectedIndex = selectedIndex + 1
		end
	end
	iprint ("[Pack ?] Index out of range " .. desiredIndex, selectedIndex)
	return 414, 0
end

-- function vehicleRandomiser(checkpoint)
--   if not source then
-- 	  source = getRandomPlayer()
-- 	  checkpoint = 1
--   end

--   local veh = getPedOccupiedVehicle(source) 
--   local vehmodel = getElementModel(veh)
--   local newveh = availablevehicles[math.random(#availablevehicles)]
--   local oldHeight = heights[vehmodel]

--   if 1 <= checkpoint then 
--     setElementModel(veh, newveh) 
--   end
  
--   local newHeight = heights[newveh]
  
--   local x, y, z = getElementPosition(veh)
--   setElementPosition(veh, x, y, z + newHeight / 2 - oldHeight / 2 + 0.1) -- just have to leave the 0.1 to be safe...
--   -- problematic vehicles
--   if veh == walton then
--     setElementPosition(veh, x, y, z + 0.5)
--   elseif veh == dozer then
--     setElementPosition(veh, x, y, z + 0.5)
--   elseif veh == yankee then
--     setElementPosition(veh, x, y, z + 0.5)
--   elseif veh == mule then
--     setElementPosition(veh, x, y, z + 0.3)
--   elseif veh == benson then
--     setElementPosition(veh, x, y, z + 0.5)
--   elseif veh == utilityvan then
--     setElementPosition(veh, x, y, z + 0.5)
--   elseif veh == barracks then
--     setElementPosition(veh, x, y, z + 0.5)
--   elseif veh == sadler then
--     setElementPosition(veh, x, y, z + 0.5)
--   elseif veh == sadlerdamaged then
--     setElementPosition(veh, x, y, z + 0.5)
--   elseif veh == boxville then
--     setElementPosition(veh, x, y, z + 0.5)
--   elseif veh == boxvillemission then
--     setElementPosition(veh, x, y, z + 0.5)
--   elseif veh == towtruck then
--     setElementPosition(veh, x, y, z + 0.5)
--   elseif veh == kart then
--     setElementPosition(veh, x, y, z + 0.15)
--   elseif veh == rhino then
--     setElementPosition(veh, x, y, z + 1) -- will this prevent the bounce???
--   end
-- end
-- addEvent('onPlayerReachCheckpoint') 
-- addEventHandler('onPlayerReachCheckpoint', getRootElement(), vehicleRandomiser) 