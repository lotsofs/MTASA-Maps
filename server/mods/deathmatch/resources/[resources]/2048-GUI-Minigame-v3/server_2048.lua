-- 2048 in MTA by Ali Digitali
-- the original game can be found at: http://gabrielecirulli.github.io/2048/
-- anyone reading this has permission to copy parts of this script

function winMessage ()
    outputChatBox (getPlayerName(client).."#00FF00 has reached 2048!", getRootElement(),0,255,0,true)
end
addEvent( "on2048win", true )
addEventHandler( "on2048win", root, winMessage )