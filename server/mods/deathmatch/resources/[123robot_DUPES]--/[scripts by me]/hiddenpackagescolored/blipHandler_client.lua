g_showBlips = false

function toggleBlips()
	if (g_nonParticipant) then
		return
	end
	
	g_showBlips = not g_showBlips
	blipCollectedPackages()
end

function blipCollectedPackages()
	for i, p in pairs(Packages.instances) do
		if (p.collected) then
			if (p.packType ~= PACKAGE_BLACK_TYPE) then
				p:toggleBlip(g_showBlips)
			elseif (p.packType == PACKAGE_BLACK_TYPE and p.region == g_currentMapFileName) then
				p:toggleBlip(g_showBlips)
			else
				p:toggleBlip(false)
			end
		else
			p:toggleBlip(false)
		end
	end
end

addCommandHandler("toggleblips", toggleBlips, false, false)