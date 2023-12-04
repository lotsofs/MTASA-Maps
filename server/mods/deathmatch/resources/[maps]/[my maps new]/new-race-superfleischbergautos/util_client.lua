-- Helper functions
-- Helper functions
-- Helper functions
-- Helper functions
-- Helper functions
-- Helper functions
-- Helper functions
-- Helper functions

function findRotation( x1, y1, x2, y2 ) 
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end

function getPointFromDistanceRotation(x, y, dist, angle)
    local a = math.rad(90 - angle);
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;
    return x-dx, y+dy;
end

-- function getDistanceBetweenPoints2DNotBroken(x1,y1,x2,y2)
--     iprint("input",x1,y1,x2,y2)
--     local base = math.abs(x2 - x1)
--     iprint("base",base)
--     local height = math.abs(y2 - y1)
--     iprint("height",height)
--     local baseS = base * base
--     local heightS = height * height
--     iprint("Sq",baseS,heightS)
--     local hypotenuseS = baseS + heightS
--     local hypotenuse = math.sqrt(hypotenuseS)
--     iprint("hypotenuses",hypotenuseS,hypotenuse)
--     return hypotenuse
-- end