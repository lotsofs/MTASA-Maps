addEventHandler('onClientResourceStart', resourceRoot,  
    function()  
        local txd = engineLoadTXD('files/dart.txd',true) 
        engineImportTXD(txd, 2052) 
        local dff = engineLoadDFF('files/dart.dff', 0)  
        engineReplaceModel(dff, 2052) 
        local col = engineLoadCOL('files/dart.col')  
        engineReplaceCOL(col, 2052) 
        engineSetModelLODDistance(2052, 500) 
        engineSetModelLODDistance(1634, 300)
        engineSetModelLODDistance(8650, 300)
    end  
) 