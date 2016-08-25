
local physics 		= import('physics.world') 


point = lua_class( 'point' )

local _fix_speed = 5.5*FpsRate

function point:_init( id, x, y )
	self.id = id
	self.x = x
	self.y = y

	self.vx = 0
	self.vy = 0

	self.ax = 0
	self.ay = -physics.Gravity

	self.standing = 0
	self.recent_standing = 0
	self.bound_x1 = -1
	self.bound_x2 = -1
	self.gravity = 1
	self.no_obstacle = false
	self.enable = true

	self.reverse = 0

	self.hit_wall_cb = nil
	self.on_ground_cb = nil
end

function point:set_reverse( rs )
	self.reverse = rs
end

function point:set_hit_wall_cb( func )
	self.hit_wall_cb = func
end

function point:trigger_hit_wall()
	if self.hit_wall_cb ~= nil then
		self.hit_wall_cb()
	end
end

function point:set_on_ground_cb( func )
	self.on_ground_cb = func
end

function point:trigger_on_ground()
	if self.on_ground_cb ~= nil then
		self.on_ground_cb()
	end
end

function point:get_pos()
	return self.x, self.y
end

function point:set_pos( x, y )
	self.x = x
	self.y = y
end

function point:get_speed()
	return self.vx*_fix_speed, self.vy*_fix_speed
end

function point:set_y_speed(v)
	if v > 0 then
		self.standing = 0
	end
	self.vy = v/_fix_speed
end

function point:set_x_speed(v)
	self.vx = v/_fix_speed
end

function point:set_speed( x, y )
	--cclog(debug.traceback())
	--print('point:set_speed', x, y)
	if y > 0 then
		self.standing = 0
	end
	self.vx = x/_fix_speed
	self.vy = y/_fix_speed
end

function point:add_speed( x, y )
	self.vx = self.vx + x/_fix_speed
	self.vy = self.vy + y/_fix_speed
end

function point:set_gravity( mass ) --( flag )
	-- if flag == self.gravity then
	-- 	return
	-- end
	-- if flag == false then
	-- 	self.gravity = false
	-- 	self.ay = self.ay + physics.Gravity
	-- 	self.vy = 0
	-- else
	-- 	self.gravity = true
	-- 	self.ay = self.ay - physics.Gravity
	-- 	self.vy = 0
	-- end
	if mass == true then
		mass = 1
	elseif mass == false then
		mass = 0
	end
	local di = mass-self.gravity
	self.ay = self.ay - di * physics.Gravity
	self.gravity = mass
end

function point:set_force( x, y )
	self.ax = x
	self.ay = y
end

function point:apply_force( x, y )
	self.ax = self.ax + x
	self.ay = self.ay + y
end

function point:set_enable(flag)
	self.enable = flag
end

function point:get_platform()
	return self.standing
end