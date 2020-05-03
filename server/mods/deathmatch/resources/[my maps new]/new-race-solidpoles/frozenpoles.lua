function poleSolid(res)
	poles = getElementsByType("object", resourceRoot)
	for _, pole in pairs(poles) do
		setElementFrozen(pole, true)
	end
end

addEventHandler("onResourceStart", resourceRoot, poleSolid)