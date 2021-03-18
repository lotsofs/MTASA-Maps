activePlayers = {}
scores = {}
maxTiles = {}


--function to update the various values up for display
addEventHandler ( "onClientElementDataChange", getRootElement(),
function ( dataName )
	--outputChatBox("data change")
	if getElementType ( source ) == "player" and dataName == "2048_score" then
		scores[source] = getElementData(source,"2048_score")
	end
	
	if getElementType ( source ) == "player" and dataName == "2048_max" then
		maxTiles[source]= getElementData(source,"2048_max")
	end
	
	if getElementType ( source ) == "player" and dataName == "2048_active" then
		if getElementData(source,"2048_active") then
			activePlayers[source] = true
		else
			activePlayers[source] = nil
		end
	end
	
end )

textures = {}

textures[2] = dxCreateTexture("images/2.png")
textures[4] = dxCreateTexture("images/4.png")
textures[8] = dxCreateTexture("images/8.png")
textures[16] = dxCreateTexture("images/16.png")
textures[32] = dxCreateTexture("images/32.png")
textures[64] = dxCreateTexture("images/64.png")
textures[128] = dxCreateTexture("images/128.png")
textures[256] = dxCreateTexture("images/256.png")
textures[512] = dxCreateTexture("images/512.png")
textures[1024] = dxCreateTexture("images/1024.png")
textures[2048] = dxCreateTexture("images/2048.png")



function drawImages ()
	--outputChatBox(#activePlayers)
	for index,_ in pairs (activePlayers) do
		if isElement(index) then
			--local index = localPlayer
			local x,y,z = getPedBonePosition(index,22)--getPedBonePosition(index,8)
			local tile = maxTiles[index]
			if not tile then tile = 2 end
			local img = textures[tile]
			
			dxDrawMaterialLine3D(x-0.75,y,z+1.55,x-0.75,y,z+1.05,img,0.5,tocolor(255,255,255,255),x-0.75,y-1,z+1.55)
			
			-- bottom
			dxDrawMaterialLine3D(x-0.75,y,z+1,x-0.75,y,z+1.01,img,0.6,tocolor(255,255,255,255),x-0.75,x-0.75,y-1,z+1)
			
			-- left
			dxDrawMaterialLine3D(x-1.05,y,z+1,x-1.05,y,z+1.6,img,0.01) --tocolor(255,255,255,255),x-0.75,y+1,z+1.05)
			
			-- right
			dxDrawMaterialLine3D(x-0.45,y,z+1,x-0.45,y,z+1.6,img,0.01) --tocolor(255,255,255,255),x-0.75,y+1,z+1.05)
			
			-- top
			dxDrawMaterialLine3D(x-0.75,y,z+1.59,x-0.75,y,z+1.60,img,0.6,tocolor(255,255,255,255),x-0.75,x-0.75,y-1,z+1)
			
			--connecting with player
			dxDrawMaterialLine3D(x,y,z,x-0.75,y,z+1,img,0.005)
		end
	end
end
addEventHandler ( "onClientRender", root, drawImages )