local colShape = nil
local x = 0
local y = 0
local w = 10
local l = 10

addCommandHandler("cs2",
    function(command, a, b, c, d)
		x = a
		y = b
		l = c
		w = d
		buildCol2D()
    end
)

addCommandHandler("atme",
	function(command)
		a,b,c = getElementPosition(localPlayer)
		x = a
		y = b
		buildCol2D()
	end
)

addCommandHandler("x",
	function(command, a)
		x = a
		buildCol2D()
	end
)

addCommandHandler("y",
	function(command, a)
		y = a
		buildCol2D()
	end
)

addCommandHandler("l",
	function(command, a)
		l = a
		buildCol2D()
	end
)

addCommandHandler("w",
	function(command, a)
		w = a
		buildCol2D()
	end
)

addCommandHandler("xp",
	function(command, a)
		x = x + a
		buildCol2D()
	end
)

addCommandHandler("yp",
	function(command, a)
		y = y + a
		buildCol2D()
	end
)

addCommandHandler("lp",
	function(command, a)
		l = l + a
		buildCol2D()
	end
)

addCommandHandler("wp",
	function(command, a)
		w = w + a
		buildCol2D()
	end
)

addCommandHandler("o",
	function()
		iprint(x,y,l,w)
	end
)

function buildCol2D ()
	iprint(colShape)
	if colShape then
		destroyElement(colShape)
	end
	colShape = createColRectangle(x, y, l, w)
end

