function knight()
	txd = engineLoadTXD ( "knight.txd" )
	engineImportTXD ( txd,1)
	dff = engineLoadDFF ( "knight.dff",0)
	engineReplaceModel (dff,1)
end
addEventHandler("onClientResourceStart",getResourceRootElement(),knight)