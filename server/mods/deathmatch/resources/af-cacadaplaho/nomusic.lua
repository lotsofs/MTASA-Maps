function disableMusic ( )
	setInteriorSoundsEnabled(false)
end
addEventHandler ( "onResourceStart", resourceRoot, disableMusic )
