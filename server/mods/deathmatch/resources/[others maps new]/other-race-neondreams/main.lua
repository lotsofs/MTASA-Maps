settings = {
	music = "camarofever.mp3",
	models = {"delorean", "delorean_low", "delorean_lower", "tire", "tire_low", "checkpoint", "checkpoint_low", "road", "road_low", "barrier", "barrier_low", "warning", "arrow", "palm", "tony", "gate", "bicycle"},
	songs = {
		camarofever   = {band=230,	vmin=0.08,	vmax=0.22, title="#00CBFFCamaro Fever#FF00B6 by #00CBFFSelloRekT#FF00B6"},
		andromeda     = {band=3	,	vmin=0.26,	vmax=0.54, title="#00CBFFAndromeda#FF00B6 by #00CBFFDance With the Dead#FF00B6"},
		silentstrike  = {band=1,	vmin=0.14,	vmax=0.59, title="#00CBFFSilent Strike#FF00B6 by #00CBFFGarth Knight#FF00B6"},
		sexualizer    = {band=180,	vmin=0.09,	vmax=0.13, title="#00CBFFSexualizer#FF00B6 by #00CBFFPerturbator#FF00B6"},
		overdrive     = {band=208,	vmin=0.09,	vmax=0.13, title="#00CBFFOverdrive#FF00B6 by #00CBFFLazerhawk#FF00B6"},
		breakpoint    = {band=240,	vmin=0.04,	vmax=0.09, title="#00CBFFBreakpoint#FF00B6 by #00CBFFGarth Knight#FF00B6"},
		soelectric    = {band=1,	vmin=0.21,	vmax=0.63, title="#00CBFFSo Electric#FF00B6 by #00CBFFLifelike#FF00B6"},
		rollermobster = {band=7,	vmin=0.33,	vmax=0.41, title="#00CBFFRoller Mobster#FF00B6 by #00CBFFCarpenter Brut#FF00B6"},
	},
	opponent_tires = false,
	draw_distance = 120,
	dev_mode = false,
	draw_bg = true,
	audio_vis = false,
	splash_delay = 5000,
}

------------------------
--- Helper functions ---
------------------------

function split(inputstr, sep)							-- Splits a string along a given separator string
	if sep == nil then
			sep = "%s"
	end
	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			t[i] = str
			i = i + 1
	end
	return t
end

function range(oldValue,oldMin,oldMax,newMin,newMax)	-- Converts a number to a new range
	local newValue = (((oldValue - oldMin) * (newMax - newMin)) / (oldMax - oldMin)) + newMin
	
	if newValue > newMax then newValue = newMax
	elseif newValue < newMin then newValue = newMin
	end
	
	return newValue
end

function round(num, numDecimalPlaces)					-- Rounds a number to given decimal places
  return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

-------------------------
--- Drawing functions ---
-------------------------

function drawLine3D(x1,y1,z1, x2,y2,z2, color)			-- Draws a line between Vector3(x,y,z) and Vector3(x2,y2,z2) world positions on the screen
	if not color then color = 0xFFFFFFFF end
	local scrx1,scry1 = getScreenFromWorldPosition(x1,y1,z1, 100000000000, false)
	local scrx2,scry2 = getScreenFromWorldPosition(x2,y2,z2, 100000000000, false)
	
	if scrx1 and scrx2 then
		dxDrawLine(scrx1,scry1,scrx2,scry2, color, 1)
		linesDrawn=linesDrawn+1
	end
end

function drawOffset(element, x1,y1,z1,x2,y2,z2, color)	-- Draws a line on the screen between two offset points of an element
	local m = getElementMatrix(element)
	
    local p1x = x1 * m[1][1] + y1 * m[2][1] + z1 * m[3][1] + m[4][1]
    local p1y = x1 * m[1][2] + y1 * m[2][2] + z1 * m[3][2] + m[4][2]
    local p1z = x1 * m[1][3] + y1 * m[2][3] + z1 * m[3][3] + m[4][3]
	
	local p2x = x2 * m[1][1] + y2 * m[2][1] + z2 * m[3][1] + m[4][1]
    local p2y = x2 * m[1][2] + y2 * m[2][2] + z2 * m[3][2] + m[4][2]
    local p2z = x2 * m[1][3] + y2 * m[2][3] + z2 * m[3][3] + m[4][3]
	
	drawLine3D(p1x,p1y,p1z, p2x,p2y,p2z, color)
end

function getOffset(element, x,y,z)						-- Gets a world position offset from a given element
	local m = getElementMatrix(element)
	local px = x * m[1][1] + y * m[2][1] + z * m[3][1] + m[4][1]
	local py = x * m[1][2] + y * m[2][2] + z * m[3][2] + m[4][2]
	local pz = x * m[1][3] + y * m[2][3] + z * m[3][3] + m[4][3]
	
	return px,py,pz
end

function drawModel(element, model_name, opacity)		-- Draws the given JSON model attached to the given element, with optional {color,opacity} override
	if opacity == nil then
		opacity = 1
	end
	
	for _,line in pairs(models[model_name].lines) do
		local pos1 = models[model_name].points[line.start]
		local pos2 = models[model_name].points[line["end"]]
		drawOffset(element, pos1.x,pos1.y,pos1.z, pos2.x, pos2.y, pos2.z, tocolor(line.color.r, line.color.g, line.color.b, line.color.a*opacity*255))
	end
end

-----------------------
--- Image renderers ---
-----------------------

function drawHorizonImage(image, x,y, scale, tint)		-- Draws an image on the horizon based on the given world x,y position
	if not scale then scale = 1 end
	if not tint then tint = 0xFFFFFFFF end
	local scaledWidth,scaledHeight = screenWidth/1920*image.width, screenHeight/1080*image.height
	
	scaledWidth = scaledWidth * scale
	scaledHeight = scaledHeight * scale
	
	local wx,wy = getScreenFromWorldPosition(x,y,0,2)
	if wx then
		dxDrawImage(wx-scaledWidth/2,horizon-scaledHeight, scaledWidth,scaledHeight, image.image, 0,0,0, tint)
	end
end

function drawStars()									-- Draws stars above the horizon, rotating with the camera
	local cx,cy,cz,clx,cly,clz = getCameraMatrix()
	local scaledWidth,scaledHeight = screenWidth/1920*images.stars.width, screenHeight/1080*images.stars.height
	
	-- Get camera yaw delta this frame
	local cx,cy,cz,clx,cly,clz = getCameraMatrix()
	local cPitch = cz-clz
	local cYaw = math.atan2(cx-clx, cy-cly) * 180 / math.pi + 180
	local cYawChange = cYaw - cYawLast
	cYawLast = cYaw
	
	-- Handle passing over -180 to 180 point
	if cYawChange > 350 then
		cYawChange = 360-cYawChange
	elseif cYawChange < -350 then
		cYawChange = -360-cYawChange
	end
	
	starX = starX - cYawChange*15
	
	-- Keep middle star image in range of center
	if starX > scaledWidth then
		starX = starX % scaledWidth
	elseif starX < 0 then
		starX = scaledWidth - starX
	end
	
	-- Draw three star images
	dxDrawImage(starX,math.min(0,horizon-scaledHeight), scaledWidth,scaledHeight, images.stars.image)
	dxDrawImage(starX-scaledWidth,math.min(0,horizon-scaledHeight), scaledWidth,scaledHeight, images.stars.image)
	dxDrawImage(starX+scaledWidth,math.min(0,horizon-scaledHeight), scaledWidth,scaledHeight, images.stars.image)
end

---------------------------------
--- Model functions/renderers ---
---------------------------------

function loadModels()									-- Loads models from JSON files
	models = {}
	for _,v in pairs(settings.models) do
		local f = fileOpen("models/"..v..".json", true)
		local jsonstring = fileRead(f, fileGetSize(f))
		fileClose(f)
		local jsondata = json.parse(jsonstring)
		local newdata = {
			points = {},
			lines = jsondata.lines,
		}
		
		for k,v in pairs(jsondata.points) do
			newdata.points[v.id] = v
		end
		
		models[v] = newdata
	end
end

function drawWall(      element, opacity)				-- Draws walls
	drawModel(element, "barrier_low", opacity)
end

function drawRoad(      element, opacity)				-- Draws lines on road surfaces (object 3569 - lasntrk3)
	drawModel(element, "road_low", opacity)
end

function drawCar(       element, opacity, is_player)	-- Draws a car around a vehicle
	if is_player then
		drawModel(element, "delorean", opacity)
		
		drawTire(element, "wheel_lf_dummy", opacity)
		drawTire(element, "wheel_rf_dummy", opacity)
		drawTire(element, "wheel_lb_dummy", opacity)
		drawTire(element, "wheel_rb_dummy", opacity)
	else
		if car_model == "high" then
			drawModel(element, "delorean_low", opacity)
		elseif car_model == "low" then
			drawModel(element, "delorean_lower", opacity)
		end
	end
end

function drawBike(		element, opacity)				-- Draws a bicycle over a vehicle (kinda broken!)
	--drawModel(element, "bicycle", opacity)
		
	drawTire(element, "wheel_front", opacity)
	drawTire(element, "wheel_rear", opacity)
	
	
	local px,py,pz = getVehicleComponentPosition(element, "chassis", "parent")
	local rx,ry,rz = getVehicleComponentRotation(element, "chassis_vlo", "parent")
	
	if not rx then return end
	
	local zRot = math.rad(rz)
	local xRot = math.rad(rx)
	
	local driver = getVehicleController(element)
	if driver then
		local bones = {
			head = Vector3(getPedBonePosition(driver, 6)),
			neck = Vector3(getPedBonePosition(driver, 4)),
			spine = Vector3(getPedBonePosition(driver, 3)),
			pelvis = Vector3(getPedBonePosition(driver, 2)),
			
			rshoulder = Vector3(getPedBonePosition(driver, 22)),
			relbow = Vector3(getPedBonePosition(driver, 23)),
			rwrist = Vector3(getPedBonePosition(driver, 24)),
			
			lshoulder = Vector3(getPedBonePosition(driver, 32)),
			lelbow = Vector3(getPedBonePosition(driver, 33)),
			lwrist = Vector3(getPedBonePosition(driver, 34)),
			
			rknee = Vector3(getPedBonePosition(driver, 52)),
			rankle = Vector3(getPedBonePosition(driver, 53)),
			rfoot = Vector3(getPedBonePosition(driver, 54)),
			
			lknee = Vector3(getPedBonePosition(driver, 42)),
			lankle = Vector3(getPedBonePosition(driver, 43)),
			lfoot = Vector3(getPedBonePosition(driver, 44)),
		}
		
		function drawBone(b1,b2)
			drawLine3D(bones[b1].x,bones[b1].y,bones[b1].z, bones[b2].x, bones[b2].y, bones[b2].z, 0xFFFFFFFF)
		end
		
	
		drawBone("head", "neck")
		drawBone("neck", "spine")
		drawBone("spine", "pelvis")
		
		drawBone("neck", "rshoulder")
		drawBone("rshoulder", "relbow")
		drawBone("relbow", "rwrist")
		
		drawBone("neck", "lshoulder")
		drawBone("lshoulder", "lelbow")
		drawBone("lelbow", "lwrist")
		
		drawBone("pelvis", "rknee")
		drawBone("rknee", "rankle")
		drawBone("rankle", "rfoot")
		
		drawBone("pelvis", "lknee")
		drawBone("lknee", "lankle")
		drawBone("lankle", "lfoot")
	end
		
	for _,s in pairs(models.bicycle.lines) do
		local p1 = models.bicycle.points[s.start]
		local p2 = models.bicycle.points[s["end"] ]
		
		local point = {[1]={},[2]={}}
		point[1][1] = {
			x = p1.x,
			y = p1.y*math.cos(xRot) - p1.z*math.sin(xRot),
			z = p1.y*math.sin(xRot) + p1.z*math.cos(xRot),
		}
		point[1][2] = {
			x = point[1][1].x*math.cos(zRot) - point[1][1].y*math.sin(zRot),
			y = point[1][1].x*math.sin(zRot) + point[1][1].y*math.cos(zRot),
			z = point[1][1].z,
		}
		point[2][1] = {
			x = p2.x,
			y = p2.y*math.cos(xRot) - p2.z*math.sin(xRot),
			z = p2.y*math.sin(xRot) + p2.z*math.cos(xRot),
		}
		point[2][2] = {
			x = point[2][1].x*math.cos(zRot) - point[2][1].y*math.sin(zRot),
			y = point[2][1].x*math.sin(zRot) + point[2][1].y*math.cos(zRot),
			z = point[2][1].z,
		}
		
		drawOffset(element, px+point[1][2].x, py+point[1][2].y, pz+point[1][2].z, px+point[2][2].x, py+point[2][2].y, pz+point[2][2].z, 0xFFFFFF00)
	end
end

function drawCheckpoint(element, opacity)				-- Draws checkpoint gates
	drawModel(element, "checkpoint", opacity)
end

function drawTire(      vehicle, tirename, opacity)		-- Draws a tire for a given vehicle and component name (e.g. 'wheel_lf_dummy')
	local px,py,pz = getVehicleComponentPosition(vehicle, tirename, "parent")
	local rx,ry,rz = getVehicleComponentRotation(vehicle, tirename, "parent")
	
	if not rx then return end
	
	local zRot = math.rad(rz)
	local xRot = math.rad(rx)
	
	tire_model = models.tire_low
	
	for _,s in pairs(tire_model.lines) do
		local p1 = tire_model.points[s.start]
		local p2 = tire_model.points[s["end"] ]
		
		local point = {[1]={},[2]={}}
		point[1][1] = {
			x = p1.x,
			y = p1.y*math.cos(xRot) - p1.z*math.sin(xRot),
			z = p1.y*math.sin(xRot) + p1.z*math.cos(xRot),
		}
		point[1][2] = {
			x = point[1][1].x*math.cos(zRot) - point[1][1].y*math.sin(zRot),
			y = point[1][1].x*math.sin(zRot) + point[1][1].y*math.cos(zRot),
			z = point[1][1].z,
		}
		point[2][1] = {
			x = p2.x,
			y = p2.y*math.cos(xRot) - p2.z*math.sin(xRot),
			z = p2.y*math.sin(xRot) + p2.z*math.cos(xRot),
		}
		point[2][2] = {
			x = point[2][1].x*math.cos(zRot) - point[2][1].y*math.sin(zRot),
			y = point[2][1].x*math.sin(zRot) + point[2][1].y*math.cos(zRot),
			z = point[2][1].z,
		}
		
		drawOffset(vehicle, px+point[1][2].x, py+point[1][2].y, pz+point[1][2].z, px+point[2][2].x, py+point[2][2].y, pz+point[2][2].z, 0xFFFF00B6)
	end
end

function drawWarning(   element, opacity)				-- Draws a warning sign
	drawModel(element, "warning", opacity)
end

function drawArrow(     element, opacity)				-- Draws arrow on road
	drawModel(element, "arrow", opacity)
end

function drawPalm(      element, opacity)				-- Draws palm tree
	drawModel(element, "palm", opacity)
end

function drawTony(      element, opacity)				-- Draws 'tony the lemur'
	drawModel(element, "tony", opacity)
end

function drawGate(      element, opacity)				-- Draws gate obstacle
	drawModel(element, "gate", opacity)
end

----------------------
--- Event handlers ---
----------------------

function init()											-- Initializes race (onClientResourceStart)
	-- Set up global variables
	screenWidth,screenHeight = guiGetScreenSize()
	uiScale = screenWidth/1920
	horizon = 0
	starX = 0
	cYawLast = 0
	tickStart = getTickCount()
	fade = 0
	drawBG = settings.draw_bg
	road_index = 0
	camera_locked = false
	render_delta = 0
	previous_tick_count = 0
	car_model = "high"
	
	-- Create the colshape centered on the camera that determines what to render
	local cx,cy,cz,clx,cly,clz = getCameraMatrix()
	colshape = createColCircle(cx,cy, 110)
	
	-- Set up music
	triggerServerEvent("onClientRequestSong", resourceRoot)
	music = false
	song_name = false
	song_progress = {
		downloading=true,
		blink=true,
		percent=0,
	}
	song_progress.blink_timer = setTimer(function()
		song_progress.blink = not song_progress.blink
	end, 750, 0)
	
	-- Use custom road trailer model to reduce edge banging
	col = engineLoadCOL("road.col")
	engineReplaceCOL(col,3569)
	
	-- Set really short render distance since we aren't seeing the world anyway
	setFarClipDistance(60)
	
	-- Apply breakable states
	for k, obj in pairs(getElementsByType("object", resourceRoot)) do
		local breakable = getElementData(obj, "breakable")
		if breakable then
			setObjectBreakable(obj, breakable == "true")
		end
	end
	
	-- Load images into a table with width and height values
	images = {
		scanlines = {
			image = dxCreateTexture("images/scanlines.png", "dxt5", true, "clamp"),
			width = 1024, height = 256,
		},
		sunset = {
			image = dxCreateTexture("images/horizon.png", "dxt5", true, "clamp"),
			width = 1024, height = 512,
		},
		city = {
			image = dxCreateTexture("images/buildings.png", "dxt5", true, "clamp"),
			width = 1024, height = 512,
		},
		tower = {
			image = dxCreateTexture("images/tower.png", "dxt5", true, "clamp"),
			width = 1024, height = 512,
		},
		towerlights = {
			image = dxCreateTexture("images/tower-lights.png", "dxt5", true, "clamp"),
			width = 1024, height = 512,
		},
		splashes = {
			base = {
				image = dxCreateTexture("images/splashes/base.png", "dxt5", true, "clamp"),
				width = 1024, height = 512,
			},
		},
		stars = {
			image = dxCreateTexture("images/stars.png", "dxt5", true, "clamp"),
			width = 1024, height = 1024,
		},
	}
	
	-- Load models from JSON
	loadModels()
	
	-- Create font for song download progress bar
	vcr_font = dxCreateFont("vcr_osd_mono.ttf", 16, false, "proof")
	
	-- Load songs
	for songname,_ in pairs(settings.songs) do
		images.splashes[songname] = {
			image = dxCreateTexture("images/splashes/"..songname..".png", "dxt5", true, "clamp"),
			width = 580, height = 49,
		}
	end
	
	-- Holds explosion spark balls
	all_balls = {}
	
	-- Explode if we fall off the track
	setTimer(function()
		local vehicle = getPedOccupiedVehicle(localPlayer)
		if vehicle then
			local _,_,z = getElementPosition(vehicle)
			if z <= 0 then
				blowVehicle(vehicle)
			end
		end
	end, 200, 0)
end

function render()										-- Draws everything (onClientHUDRender)
	render_delta = getTickCount() - previous_tick_count							-- Performance stuff
	previous_tick_count = getTickCount()
	linesDrawn = 0
	
	local cx,cy,cz,clx,cly,clz = getCameraMatrix()
	local cPitch = cz-clz
	horizon = screenHeight/2 - cPitch*screenHeight
	
	if (drawBG) then
		dxDrawRectangle(0,0,screenWidth,screenHeight,0xFF000000)				-- Black BG
	end
	
	local intensity = 1															-- Calculate music intensity
	local intensity2 = 1
	if music and not isSoundPaused(music) then
		local bt = getSoundFFTData(music,2048,257)
		intensity  = range(math.sqrt(bt[settings.songs[song_name].band]), settings.songs[song_name].vmin, settings.songs[song_name].vmax, 0.5, 1)
		intensity2 = range(math.sqrt(bt[settings.songs[song_name].band]), settings.songs[song_name].vmin, settings.songs[song_name].vmax, 0, 1)
	end
	
	drawStars()
	
	drawHorizonImage(images.sunset, 1600, 10000)								-- Sunset
	drawHorizonImage(images.city, -10000, -10000, 0.5)							-- City
	drawHorizonImage(images.tower, 4000, -4000, 0.75)							-- Tower
	drawHorizonImage(images.towerlights, 4000, -4000, 0.75, tocolor(255,255,255,intensity2*255))	-- Tower lights
	dxDrawLine(0,horizon, screenWidth,horizon, 0x88FFFFFF)						-- Horizon line
	linesDrawn=linesDrawn+1
	
	local camera_target = getCameraTarget()
	
	if camera_target then														-- Own vehicle
		if getVehicleName(camera_target) == "Buffalo" then
			drawCar(camera_target, 1, true)
		elseif getVehicleName(camera_target) == "Mountain Bike" then
			drawBike(camera_target, 1)
		end
	end
	
	setElementPosition(colshape, cx, cy, cz)
	
	local objs = getElementsWithinColShape(colshape, "object")
	for _, obj in ipairs(objs) do
		if getElementModel(obj) == 3567 then drawWall(obj, intensity)			-- Roads
		elseif getElementModel(obj) == 3569 then drawRoad(obj, intensity)		-- Walls
		elseif getElementModel(obj) == 16092 then drawCheckpoint(obj, intensity)-- Checkpoints
		elseif getElementModel(obj) == 3335 then drawWarning(obj, intensity)	-- Warning signs
		elseif getElementModel(obj) == 8843 then drawArrow(obj, intensity)		-- Road arrow
		elseif getElementModel(obj) == 3511 then drawPalm(obj, intensity)		-- Palm tree
		elseif getElementModel(obj) == 1607 then drawTony(obj)					-- 'tony the lemur'
		elseif getElementModel(obj) == 2933 then drawGate(obj)					-- Gate obstacle
		end
	end
	
	local vehicles = getElementsWithinColShape(colshape, "vehicle")				-- Other vehicles
	car_model = #vehicles > 10 and "low" or "high"
	for _, obj in ipairs(vehicles) do
		if obj ~= camera_target then
			if getElementDimension(obj) == getElementDimension(localPlayer) then
				if getVehicleName(obj) == "Buffalo" then
					drawCar(obj, 1, false)
				elseif getVehicleName(obj) == "Mountain Bike" then
					drawBike(obj, 1)
				end
			end
		end
	end
	if song_ready then
		local since = getTickCount() - song_ready
		local splash_alpha = 0
		
		if since > settings.splash_delay+5000 then -- if it's been shown for >5 seconds, start fading out to 6 seconds (1 sec fade)
			splash_alpha = 255-range(since,settings.splash_delay+5000,settings.splash_delay+6000,0,255)
		elseif since > settings.splash_delay+1000 then -- if it's been shown for >1 second, show for 4 seconds before fading out
			splash_alpha = 255
		elseif since > settings.splash_delay then -- if it hasn't been shown at all (and is past the wait time) start fading in over 1 second
			splash_alpha = range(since,settings.splash_delay,settings.splash_delay+1000,0,255)
		end
		
		if splash_alpha > 0 then
			dxDrawImage(screenWidth/2 - (images.splashes.base.width*uiScale/2), 0, images.splashes.base.width*uiScale, images.splashes.base.height*uiScale, images.splashes.base.image, 0,0,0, tocolor(255,255,255,splash_alpha))
			dxDrawImage(screenWidth/2 - (images.splashes[song_name].width*uiScale/2), 220*uiScale, images.splashes[song_name].width*uiScale, images.splashes[song_name].height*uiScale, images.splashes[song_name].image, 0,0,0, tocolor(255,255,255,splash_alpha))
		end
	end
	
	for k,balls in pairs(all_balls) do											-- Car explosion balls/sparks
		for k2,ball in pairs(balls) do
			local bx,by,bz = getElementPosition(ball)
			local old_pos = split(getElementData(ball, "last_position"), ",")
			drawLine3D(bx,by,bz, old_pos[1], old_pos[2], old_pos[3], 0xFFFF5500)
			
			setElementData(ball, "last_position", bx..","..by..","..bz)
			
			if getTickCount() - getElementData(ball, "spawned_at") > 3000 then
				destroyElement(ball)
				
				-- Clean up balls tables
				balls[k2] = nil
				if #balls == 0 then
					all_balls[k] = nil
				end
			end
		end
	end
	
	if song_progress.downloading then											-- Song download progress
		dxDrawText("DOWNLOADING SONG", screenWidth/2 - (100*uiScale), 850*uiScale, screenWidth/2 + (100*uiScale), 920*uiScale, 0xFFFF00B6, uiScale, vcr_font, "center", "center")
		
		for i=1,10 do
			-- draw completed rectangles
			if song_progress.percent then
				local color = 0x33FF00B6
				if song_progress.percent >= 10*i then
					color = 0xFFFF00B6
				end
				dxDrawRectangle(screenWidth/2 - (127*uiScale) + ((i-1)*(16*uiScale)), 900*uiScale, 14*uiScale, 20*uiScale, color) -- draw each rectangle
			end
		end
		
		-- draw current blinking rectangle
		if song_progress.blink and song_progress.percent then
			dxDrawRectangle(screenWidth/2 - (127*uiScale) + (math.floor(song_progress.percent/10)*(16*uiScale)), 900*uiScale, 14*uiScale, 20*uiScale, 0xFFFF00B6)
		end
		
		-- Draw percent
		dxDrawText(math.floor(song_progress.percent), screenWidth/2 + (96*uiScale), 896*uiScale, screenWidth/2 + (100*uiScale), 900*uiScale, 0xFFFF00B6, uiScale, vcr_font) -- draw current rectangle
	end
	
	dxDrawImage(0,0, screenWidth,screenHeight, images.scanlines.image)			-- Scanlines
	
	if settings.audio_vis and music then										-- Audio FFT graph
		dxDrawRectangle(screenWidth/2,0,1,256,tocolor(255,255,255,127))
		local bt = getSoundFFTData(music,2048,257)
		if(not bt) then return end
		for i=1,256 do
			bt[i] = math.sqrt(bt[i])*256
			
			local color = 0xFFFFFFFF
			
			if i > settings.songs[song_name].band - 2 and i < settings.songs[song_name].band + 2 then
				color = 0xFFFF0000
			end
			
			dxDrawRectangle(screenWidth/2-bt[i]/2, i*2-1+20, bt[i], 2, color)
		end
	
		dxDrawRectangle(0,0,screenWidth,20, tocolor(255,255,255))
		dxDrawRectangle(0,0,(intensity)*screenWidth/2,20, tocolor(255,0,0))
		dxDrawRectangle(screenWidth/2,0,(intensity2)*screenWidth,20, tocolor(255,0,0))
		
		dxDrawText("band: " .. settings.songs[song_name].band, 350,30)
		dxDrawText("vmin: " .. settings.songs[song_name].vmin, 350, 45)
		dxDrawText("vmax: " .. settings.songs[song_name].vmax, 350, 60)
		dxDrawText("raw: " .. bt[settings.songs[song_name].band], 350,75)
		dxDrawText("intensity: " .. intensity, 350,90)
	end
	
	if settings.dev_mode then													-- Draw FPS
		dxDrawText("lines: " .. linesDrawn .. "; fps: " .. round(1000/render_delta, 1), 0,0)
	end
	
	if camera_locked then														-- Camera scene at end of race
		local since = getTickCount() - camera_locked
		local mult = (5000-since)/5000
		setCameraMatrix(cx,cy,cz,clx,cly,clz+(render_delta/10000)*mult)
	end
end

function vehicleExploded(x,y,z)							-- Spawns spark balls on exploded cars
	local x,y,z = getElementPosition(source)
	
	local max_velocity = 0.25
	
	local balls = {}
	
	for i=1,30 do
		local ball = createObject(1598, x-0.5+math.random(),y-0.5+math.random(),z-0.5+math.random())
		table.insert(balls, ball)
	end
	
	table.insert(all_balls, balls)
	
	for _,ball in pairs(balls) do
		setElementCollidableWith(ball, source, false)
		setElementData(ball, "spawned_at", getTickCount())
		
		local bx,by,bz = getElementPosition(ball)
		setElementData(ball, "last_position", bx..","..by..","..bz)
		
		for _,ball2 in pairs(balls) do
			setElementCollidableWith(ball, ball2, false)
		end
	end
	
	setTimer(function()
		for _,ball in pairs(balls) do
			setElementPosition(ball, x-0.5+math.random(),y-0.5+math.random(),z-0.5+math.random())
			setElementVelocity(ball, -max_velocity+math.random()*max_velocity*2, -max_velocity+math.random()*max_velocity*2, math.random()*max_velocity)
		end
	end, 500,1)
end

function raceFinished()									-- Triggers camera freeze/pan up when finishing race
	camera_locked = getTickCount()
	setCameraMatrix(getCameraMatrix())
	
	setTimer(function()
		fadeCamera(false, 2)
	end, 3000, 1)
	
	setTimer(function()
		fadeCamera(true,0)
		camera_locked = false
	end, 5000, 1)
end

function receiveSongName(songname)						-- Initializes song stuff when we get the current track (show title, etc.)
	song_ready = getTickCount()
	setTimer(function()
		song_ready = false
	end, 11000, 1)
	
	song_name = songname
	outputChatBox("Now listening to: " .. settings.songs[song_name].title, 255,0,182, true)
end

function receiveSong(songname, song_data)				-- Saves song to disk and starts playing once we finish receiving it
	local filename = "songs/"..songname..".mp3"
	
	local fileHandle = fileCreate(filename)
	if fileHandle then
		fileWrite(fileHandle, song_data)
		fileClose(fileHandle)
	end
	
	if music then
		stopSound(music)
	end
	
	killTimer(song_progress.blink_timer)
	
	music = playSound(filename, true, false)
	song_progress.downloading = false
end

function receiveSongProgress(percent, size, tick_end)	-- Updates the progress bar when we receive updated progress
	song_progress.percent = percent
	song_progress.size = size
	song_progress.tick_end = tick_end
end

----------------------
--- Initialization ---
----------------------

addEvent("onClientPlayerFinish",        true)
addEvent("onClientTriggerDownloadSong", true)
addEvent("onClientReceiveSong",			true)
addEvent("onClientReceiveSongName",		true)
addEvent("onClientReceiveSongProgress",	true)
addEventHandler("onClientResourceStart",		resourceRoot,	init)
addEventHandler("onClientHUDRender",			root,			render)
addEventHandler("onClientExplosion",			root,			vehicleExploded)
addEventHandler("onClientPlayerFinish",  		root,			raceFinished)
addEventHandler("onClientReceiveSong",			resourceRoot,	receiveSong)
addEventHandler("onClientReceiveSongName",		resourceRoot,	receiveSongName)
addEventHandler("onClientReceiveSongProgress",	resourceRoot,	receiveSongProgress)

bindKey ("m",		"down", function()
	if music then
		if isSoundPaused(music) then
			setSoundPaused(music, false)
		else
			setSoundPaused(music, true)
		end
	end
end)
bindKey ("n",		"down", function()
	if settings.dev_mode then
		loadModels()
	end
end)
bindKey("arrow_u",	"down", function()
	if settings.audio_vis then
		settings.songs[song_name].band = settings.songs[song_name].band - 1
	end
end)
bindKey("arrow_d",	"down", function()
	if settings.audio_vis then
		settings.songs[song_name].band = settings.songs[song_name].band + 1
	end
end)
bindKey("arrow_l",	"down", function()
	if settings.audio_vis then
		settings.songs[song_name].vmin = settings.songs[song_name].vmin - 0.01
	end
end)
bindKey("arrow_r",	"down", function()
	if settings.audio_vis then
		settings.songs[song_name].vmin = settings.songs[song_name].vmin + 0.01
	end
end)
bindKey("delete",	"down", function()
	if settings.audio_vis then
		settings.songs[song_name].vmax = settings.songs[song_name].vmax - 0.01
	end
end)
bindKey("end",		"down", function()
	if settings.audio_vis then
		settings.songs[song_name].vmax = settings.songs[song_name].vmax + 0.01
	end
end)
bindKey("home",		"down", function()
	if settings.audio_vis then
		settings.songs[song_name].band = 1
	end
end)

addCommandHandler("togglebg", function(command)
	if settings.dev_mode then
		drawBG = not drawBG
	end
end)

-- local speed = Vector3(getElementVelocity(vehicle)).length; if speed > 1 then speed = 1 end; if speed < 0.01 then speed = 0.01 end; setSoundSpeed(s, speed)