addCommandHandler("interiormusic",
    function()
		iprint("toggling interior music")
        setInteriorSoundsEnabled(not getInteriorSoundsEnabled())
    end
)