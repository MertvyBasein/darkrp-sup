local pairs = pairs
if SERVER then
	util.AddNetworkString( "PlayerDisplayChat" )
	local PLAYER = FindMetaTable( "Player" )

    function PLAYER:SendMessage( ... )
         local args = { ... }
         net.Start( "PlayerDisplayChat" )
             net.WriteTable( args )
         net.Send( self )
    end

    function PLAYER:SendMessageFD( ... )
         local args = { ... }
         net.Start( "PlayerDisplayChat" )
             net.WriteTable( args )
         net.Send( self )
    end
    function PLAYER:svtext( ... )
         local args = { ... }
         net.Start( "PlayerDisplayChat" )
             net.WriteTable( args )
         net.Send( self )
    end
	function SendMessageAll( ... )
         local args = { ... }
         net.Start( "PlayerDisplayChat" )
             net.WriteTable( args )
         net.Broadcast()
    end
end

if CLIENT then
    net.Receive( "PlayerDisplayChat", function()
        local args = net.ReadTable()
        chat.AddText( unpack( args ) )
    end)
end