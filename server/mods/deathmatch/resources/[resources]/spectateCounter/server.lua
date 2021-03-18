addEventHandler("onResourceStart", getResourceRootElement(getThisResource()),
	function ()

		x_position = get("x_position")
		y_position = get("y_position")
		time = get("refresh_time")

		displays = {}
		texts = {}
		playerTargets = {}

		setTimer(function()
			
			targetCount = {}

			for i,p in ipairs (getElementsByType("player")) do 
				local target = getCameraTarget(p) --note: can return false

				if target then -- Count players watching this target

					if not targetCount[target] then -- Increase the count of the target
						targetCount[target] = 0 -- Start at 0 because otherwise you count yourself.
					else
						targetCount[target] = targetCount[target] + 1
					end

					if playerTargets[p] ~= target then -- Target is different from the stored value

						if displays[playerTargets[p]] then
							textDisplayRemoveObserver(displays[playerTargets[p]],p) --Remove player from old display if it exists
						end
						playerTargets[p] = target -- Store the new target 
					end

				else -- If you do not have a target, remove yourself from the previous display

					if displays[playerTargets[p]] then
						textDisplayRemoveObserver(displays[playerTargets[p]], p ) --Remove player from old display
					end
				end

			end

			-- Now display the count for everyone watching target
			for i,p in ipairs (getElementsByType("player")) do 
				
				local target = playerTargets[p]
				
				if target then

					if targetCount[target] then
						if not displays[target] then -- The target doesn't have a display yet, create a new one with count
							displays[target] = textCreateDisplay()
					    	texts[target]    = textCreateTextItem ( "Spectators: " .. targetCount[target], x_position, y_position )
					    	textDisplayAddText ( displays[target], texts[target] )    
						else --update the count
							textItemSetText(texts[target], "Spectators: " .. targetCount[target])
						end

						-- Add the player to the target display
						textDisplayAddObserver ( displays[target], p)      
					end

				end
			end

		end,time,0)

	end
)

-- Destroy displays
function quitPlayer ( quitType )
	playerTargets[source] = nil	

	if texts[source] then
		textDestroyTextItem ( texts[source] )
		texts[source] = nil
	end	

	if displays[source] then
		textDestroyDisplay ( displays[source] )
		displays[source] = nil
	end		
end
addEventHandler ( "onPlayerQuit", root, quitPlayer )
