setCloudsEnabled ( false )
function palm ()
palmtxd = engineLoadTXD("621.txd")
engineImportTXD(palmtxd, 621 )
local palmdff = engineLoadDFF('621.dff', 0) 
engineReplaceModel(palmdff, 621)
palmtxd = engineLoadTXD("622.txd")
engineImportTXD(palmtxd, 622 )
local palmdff = engineLoadDFF('622.dff', 0) 
engineReplaceModel(palmdff, 622)

end
addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()), palm )
