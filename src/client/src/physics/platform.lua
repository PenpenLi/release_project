
platform = lua_class( 'platform' )

function platform:_init( id, x1, y1, x2, y2 )
	self.id = id
	self.pos1 = cc.p(x1,y1)
	self.pos2 = cc.p(x2,y2)
end

function platform:set_is_ground( is_ground )
	self.is_ground = is_ground
end

function platform:get_is_ground(  )
	return self.is_ground
end

