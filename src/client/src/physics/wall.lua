
wall = lua_class( 'wall' )

function wall:_init( id, x1, y1, x2, y2 )
	self.id = id
	self.pos1 = cc.p(x1,y1)
	self.pos2 = cc.p(x2,y2)
end

