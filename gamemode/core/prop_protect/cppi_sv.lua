do return end -- deprecated

props = {}

ents.GetProps = function()
	return props
end

timer.Create( 'pen-check', 3, 0, function() 
	for k,bool in pairs( props ) do
		local v = k
		if !IsValid( k ) then continue end
		local phys = v:GetPhysicsObject()
		if IsValid( phys ) and phys:IsPenetrating() and IsValid( v:CPPIGetOwner() ) then
			v.penetration_prevented = true
			v.originalcg = v:GetCollisionGroup()
			v:SetCollisionGroup( COLLISION_GROUP_WORLD )
			phys:EnableMotion( false )
		end
	end
end )

hook.Add( 'OnEntityCreated', 'memeoir', function( ent )
	if ent:GetClass() == 'prop_physics' then
		props[ent] = true
	end
end)

hook.Add( 'OnEntityCreated', 'memeoir', function( ent )
	if ent:GetClass() == 'prop_physics' then
		props[ent] = nil
	end
end)