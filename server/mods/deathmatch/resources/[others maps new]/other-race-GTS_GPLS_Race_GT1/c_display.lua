local screenWidth, screenHeight = guiGetScreenSize()
fontLCD22 = dxCreateFont("lcd.ttf", 22)
local fuel = 20

function drawHUD()
    local target = localPlayer
    if getElementData(localPlayer, 'race.spectating') then
        target = getVehicleOccupant(getCameraTarget(localPlayer), 0)
    end
    local p_veh = getPedOccupiedVehicle(target)
    fuel = getElementData(p_veh, "fuel")
    if isElement(p_veh) then
        hp = getElementHealth(p_veh)/10 -- 24-100
        
        dxDrawRectangle(screenWidth - 151, screenHeight - 96, 150, 80, tocolor(10,10,10,150))
        
        dxDrawRectangle(screenWidth - 106, screenHeight - 56, 101, 15, tocolor(10,10,10,200)) --for fuel
            
        dxDrawRectangle(screenWidth - 105, screenHeight - 55, 4, 13, tocolor(25,25,25,220))
        dxDrawRectangle(screenWidth - 100, screenHeight - 55, 4, 13, tocolor(25,25,25,220))
        dxDrawRectangle(screenWidth - 95, screenHeight - 55, 4, 13, tocolor(25,25,25,220))   
        dxDrawRectangle(screenWidth - 90, screenHeight - 55, 4, 13, tocolor(25,25,25,220))   
        dxDrawRectangle(screenWidth - 85, screenHeight - 55, 4, 13, tocolor(25,25,25,220))  
        dxDrawRectangle(screenWidth - 80, screenHeight - 55, 4, 13, tocolor(25,25,25,220))   
        dxDrawRectangle(screenWidth - 75, screenHeight - 55, 4, 13, tocolor(25,25,25,220))  
        dxDrawRectangle(screenWidth - 70, screenHeight - 55, 4, 13, tocolor(25,25,25,220))   
        dxDrawRectangle(screenWidth - 65, screenHeight - 55, 4, 13, tocolor(25,25,25,220))
        dxDrawRectangle(screenWidth - 60, screenHeight - 55, 4, 13, tocolor(25,25,25,220))
        dxDrawRectangle(screenWidth - 55, screenHeight - 55, 4, 13, tocolor(25,25,25,220))
        dxDrawRectangle(screenWidth - 50, screenHeight - 55, 4, 13, tocolor(25,25,25,220))
        dxDrawRectangle(screenWidth - 45, screenHeight - 55, 4, 13, tocolor(25,25,25,220))
        dxDrawRectangle(screenWidth - 40, screenHeight - 55, 4, 13, tocolor(25,25,25,220))
        dxDrawRectangle(screenWidth - 35, screenHeight - 55, 4, 13, tocolor(25,25,25,220))
        dxDrawRectangle(screenWidth - 30, screenHeight - 55, 4, 13, tocolor(25,25,25,220))
        dxDrawRectangle(screenWidth - 25, screenHeight - 55, 4, 13, tocolor(25,25,25,220))
        dxDrawRectangle(screenWidth - 20, screenHeight - 55, 4, 13, tocolor(25,25,25,220))
        dxDrawRectangle(screenWidth - 15, screenHeight - 55, 4, 13, tocolor(25,25,25,220))
        dxDrawRectangle(screenWidth - 10, screenHeight - 55, 4, 13, tocolor(25,25,25,220))
        
        
        if getVehicleEngineState(p_veh) then
        local f_color = tocolor(10,255,10,200)
        if fuel <= 37 then
            f_color = tocolor(255,200,10,200)
        end
        if fuel <= 17 then
            f_color = tocolor(255,10,10,200)
        end
        if fuel >= 2 then
            dxDrawRectangle(screenWidth - 105, screenHeight - 55, 4, 13, f_color)
        end
        if fuel >=6 then
            dxDrawRectangle(screenWidth - 100, screenHeight - 55, 4, 13, f_color)
        end
        if fuel >=10 then
            dxDrawRectangle(screenWidth - 95, screenHeight - 55, 4, 13, f_color)
        end
        if fuel >=15 then
            dxDrawRectangle(screenWidth - 90, screenHeight - 55, 4, 13, f_color)
        end
        if fuel >=20 then
            dxDrawRectangle(screenWidth - 85, screenHeight - 55, 4, 13, f_color)
        end
        if fuel >=25 then
            dxDrawRectangle(screenWidth - 80, screenHeight - 55, 4, 13, f_color)
        end
        if fuel >=30 then
            dxDrawRectangle(screenWidth - 75, screenHeight - 55, 4, 13, f_color)
        end
        if fuel >=35 then
            dxDrawRectangle(screenWidth - 70, screenHeight - 55, 4, 13, f_color)
        end
        if fuel >=40 then
            dxDrawRectangle(screenWidth - 65, screenHeight - 55, 4, 13, f_color)
        end
        if fuel >=45 then
            dxDrawRectangle(screenWidth - 60, screenHeight - 55, 4, 13, f_color)
        end
        if fuel >=50 then
            dxDrawRectangle(screenWidth - 55, screenHeight - 55, 4, 13, f_color)
        end
        if fuel >=55 then
            dxDrawRectangle(screenWidth - 50, screenHeight - 55, 4, 13, f_color)
        end
        if fuel >=60 then
            dxDrawRectangle(screenWidth - 45, screenHeight - 55, 4, 13, f_color)
        end
        if fuel >=65 then
            dxDrawRectangle(screenWidth - 40, screenHeight - 55, 4, 13, f_color)
        end
        if fuel >=70 then
            dxDrawRectangle(screenWidth - 35, screenHeight - 55, 4, 13, f_color)
        end
        if fuel >=75 then
            dxDrawRectangle(screenWidth - 30, screenHeight - 55, 4, 13, f_color)
        end
        if fuel >=80 then
            dxDrawRectangle(screenWidth - 25, screenHeight - 55, 4, 13, f_color)
        end
        if fuel >=85 then
            dxDrawRectangle(screenWidth - 20, screenHeight - 55, 4, 13, f_color)
        end
        if fuel >=90 then
            dxDrawRectangle(screenWidth - 15, screenHeight - 55, 4, 13, f_color)
        end
        if fuel >=95 then
            dxDrawRectangle(screenWidth - 10, screenHeight - 55, 4, 13, f_color)
        end
        end

        dxDrawText("0000", screenWidth - 142, screenHeight - 59, screenWidth - 142, screenHeight - 59, tocolor(25, 25, 25, 220), 0.5, fontLCD22, "left", "top", false, false, false)
        dxDrawText("****", screenWidth - 142, screenHeight - 59, screenWidth - 142, screenHeight - 59, tocolor(25, 25, 25, 220), 0.5, fontLCD22, "left", "top", false, false, false)
        if getVehicleEngineState(p_veh) then
        dxDrawText("fuel", screenWidth - 142, screenHeight - 59, screenWidth - 142, screenHeight - 59, tocolor(255, 255, 255, 255), 0.5, fontLCD22, "left", "top", false, false, false)
        end
        
        dxDrawRectangle(screenWidth - 106, screenHeight - 34, 101, 15, tocolor(10,10,10,200)) --for hp
            
            
        dxDrawRectangle(screenWidth - 105, screenHeight - 33, 4, 13, tocolor(25,25,25,220))
        dxDrawRectangle(screenWidth - 100, screenHeight - 33, 4, 13, tocolor(25,25,25,220))
        dxDrawRectangle(screenWidth - 95, screenHeight - 33, 4, 13, tocolor(25,25,25,220))   
        dxDrawRectangle(screenWidth - 90, screenHeight - 33, 4, 13, tocolor(25,25,25,220))   
        dxDrawRectangle(screenWidth - 85, screenHeight - 33, 4, 13, tocolor(25,25,25,220))  
        dxDrawRectangle(screenWidth - 80, screenHeight - 33, 4, 13, tocolor(25,25,25,220))   
        dxDrawRectangle(screenWidth - 75, screenHeight - 33, 4, 13, tocolor(25,25,25,220))  
        dxDrawRectangle(screenWidth - 70, screenHeight - 33, 4, 13, tocolor(25,25,25,220))   
        dxDrawRectangle(screenWidth - 65, screenHeight - 33, 4, 13, tocolor(25,25,25,220))
        dxDrawRectangle(screenWidth - 60, screenHeight - 33, 4, 13, tocolor(25,25,25,220))
        dxDrawRectangle(screenWidth - 55, screenHeight - 33, 4, 13, tocolor(25,25,25,220))
        dxDrawRectangle(screenWidth - 50, screenHeight - 33, 4, 13, tocolor(25,25,25,220))
        dxDrawRectangle(screenWidth - 45, screenHeight - 33, 4, 13, tocolor(25,25,25,220))
        dxDrawRectangle(screenWidth - 40, screenHeight - 33, 4, 13, tocolor(25,25,25,220))
        dxDrawRectangle(screenWidth - 35, screenHeight - 33, 4, 13, tocolor(25,25,25,220))
        dxDrawRectangle(screenWidth - 30, screenHeight - 33, 4, 13, tocolor(25,25,25,220))
        dxDrawRectangle(screenWidth - 25, screenHeight - 33, 4, 13, tocolor(25,25,25,220))
        dxDrawRectangle(screenWidth - 20, screenHeight - 33, 4, 13, tocolor(25,25,25,220))
        dxDrawRectangle(screenWidth - 15, screenHeight - 33, 4, 13, tocolor(25,25,25,220))
        dxDrawRectangle(screenWidth - 10, screenHeight - 33, 4, 13, tocolor(25,25,25,220))
        
        
        local h_color = tocolor(10,255,10,200)
        if hp <= 53 then
            h_color = tocolor(255,200,10,200)
        end
        if hp <= 38 then
            h_color = tocolor(255,10,10,200)
        end
     
        if getVehicleEngineState(p_veh) then
        if hp >=24 then
            dxDrawRectangle(screenWidth - 105, screenHeight - 33, 4, 13, h_color)
        end
        if hp >=27.8 then
            dxDrawRectangle(screenWidth - 100, screenHeight - 33, 4, 13, h_color)
        end  
        if hp >=31.6 then
            dxDrawRectangle(screenWidth - 95, screenHeight - 33, 4, 13, h_color)
        end
        if hp >=35.4 then
            dxDrawRectangle(screenWidth - 90, screenHeight - 33, 4, 13, h_color)
        end
        if hp >=39.2 then
            dxDrawRectangle(screenWidth - 85, screenHeight - 33, 4, 13, h_color)
        end
        if hp >=43 then
            dxDrawRectangle(screenWidth - 80, screenHeight - 33, 4, 13, h_color)
        end
        if hp >=46.8 then
            dxDrawRectangle(screenWidth - 75, screenHeight - 33, 4, 13, h_color)
        end
        if hp >=50.6 then
            dxDrawRectangle(screenWidth - 70, screenHeight - 33, 4, 13, h_color)
        end
        if hp >=54.4 then
            dxDrawRectangle(screenWidth - 65, screenHeight - 33, 4, 13, h_color)
        end
        if hp >=58.2 then
            dxDrawRectangle(screenWidth - 60, screenHeight - 33, 4, 13, h_color)
        end
        if hp >=62 then
            dxDrawRectangle(screenWidth - 55, screenHeight - 33, 4, 13, h_color)
        end
        if hp >=65.8 then
            dxDrawRectangle(screenWidth - 50, screenHeight - 33, 4, 13, h_color)
        end
        if hp >=69.6 then
            dxDrawRectangle(screenWidth - 45, screenHeight - 33, 4, 13, h_color)
        end
        if hp >=73.4 then
            dxDrawRectangle(screenWidth - 40, screenHeight - 33, 4, 13, h_color)
        end
        if hp >=77.2 then
            dxDrawRectangle(screenWidth - 35, screenHeight - 33, 4, 13, h_color)
        end
        if hp >=81 then
            dxDrawRectangle(screenWidth - 30, screenHeight - 33, 4, 13, h_color)
        end
        if hp >=84.4 then
            dxDrawRectangle(screenWidth - 25, screenHeight - 33, 4, 13, h_color)
        end
        if hp >=88.6 then
            dxDrawRectangle(screenWidth - 20, screenHeight - 33, 4, 13, h_color)
        end
        if hp >=92.4 then
            dxDrawRectangle(screenWidth - 15, screenHeight - 33, 4, 13, h_color)
        end
        if hp >=96.2 then
            dxDrawRectangle(screenWidth - 10, screenHeight - 33, 4, 13, h_color)
        end
        end
        
        dxDrawText("00", screenWidth - 135, screenHeight - 37, screenWidth - 135, screenHeight - 37, tocolor(25, 25, 25, 220), 0.5, fontLCD22, "left", "top", false, false, false)
        dxDrawText("**", screenWidth - 135, screenHeight - 37, screenWidth - 135, screenHeight - 37, tocolor(25, 25, 25, 220), 0.5, fontLCD22, "left", "top", false, false, false)
        if getVehicleEngineState(p_veh) then
        dxDrawText("hp", screenWidth - 135, screenHeight - 37, screenWidth - 135, screenHeight - 37, tocolor(255, 255, 255, 255), 0.5, fontLCD22, "left", "top", false, false, false)
        end
        
        
        local speed = getVehicleSpeedString()
        dxDrawText("*** ****", screenWidth - 125, screenHeight - 92, screenWidth - 135, screenHeight - 92, tocolor(25,25,25,220), 0.8, fontLCD22, "left", "top", false, false, false)
        dxDrawText("000 0000", screenWidth - 125, screenHeight - 92, screenWidth - 135, screenHeight - 92, tocolor(25,25,25,220), 0.8, fontLCD22, "left", "top", false, false, false)
        if getVehicleEngineState(p_veh) then
        dxDrawText(speed.." km/h", screenWidth - 125, screenHeight - 92, screenWidth - 135, screenHeight - 92, tocolor(255, 255, 255, 255), 0.8, fontLCD22, "left", "top", false, false, false)
        end
        
    end
end

function updateDisplay()
    if isPedInVehicle(localPlayer) then
        drawHUD()
        --dxDrawText("Fuel: "..tostring(fuel).."; "..tostring(property)..": "..tostring(current_property), 44, screenHeight - 41, screenWidth, screenHeight, tocolor ( 255, 255, 255, 255 ), 1.02, "pricedown")
    end
end

addEventHandler("onClientRender", getRootElement(), updateDisplay)