
local command		= import( 'game_logic.command' )
local command_mgr	= import( 'game_logic.command_mgr' )
local math_ext 		= import('utils.math_ext')



operate_layer = lua_class('operate_layer')

local _joystick_radius 				= nil							--摇杆半径
local _joystickBg_radius 			= 50	
local _joystickBg_Diameter 			= nil						--底盘直径
local _joystick_joystickBg_dis		= 50
local _joystick_joystickBg_pos		= cc.p(150,100)		--初始坐标
local _joystickBg_can_run_for_dis 	= 50				--摇杆离底盘水平150远，底盘就跟着移动
local _joystickBg_old_pos 			= cc.p(0,0)
local _joystickBg_swidth 			= VisibleSize.width*0.078					--地盘左端点
local _size  						= cc.Director:getInstance():getVisibleSize()
local _joystickBg_twidth 			= VisibleSize.width*0.268					--地盘右端点
local _joystick_swidth 				= 0
local _joystick_l = nil
local _joystickBg = nil
local _joystick_r = nil
local _start_pos_y  = nil
local _start_pos_y = nil
local _j_scale = 1.2
function operate_layer:_init( widget )
	--super(operate_layer, self)._init()

	self.m_joystick_l			= widget:getChildByName('joystick_l')
	self.m_joystickBg 			= widget:getChildByName('joystick_bg')
	_joystick_l 				= self.m_joystick_l
	_joystickBg 				= self.m_joystickBg
	self.m_joystick_r 			= widget:getChildByName('joystick_r')
	_joystick_r 				= self.m_joystick_r

	
	_joystickBg_old_pos.x 		= self.m_joystickBg:getPositionX()
	_joystickBg_old_pos.y 		= self.m_joystickBg:getPositionY()

	_joystick_radius 			= 25							--摇杆半径
	_joystick_swidth 			= _joystick_radius
	--print('高度',self.m_joystick)
	_joystickBg_Diameter 		= self.m_joystickBg:getBoundingBox().height			--底盘直径

	self.m_joystickBg:setVisible(true)
	self.m_joystick_l:setVisible(true)

	self.start_pos_x = self.m_joystickBg:getPositionX()
	self.start_pos_y = self.m_joystickBg:getPositionY()
	_start_pos_y	 = self.start_pos_y
	_start_pos_x 	 = self.start_pos_x

	self.old_posx 	 = self.m_joystickBg:getPositionX()
	self.old_posY 	 = self.m_joystickBg:getPositionY()



end


--显示摇杆
function operate_layer:showJoystick( pos )

	--限制底盘显示距离
	self.m_joystick_l:setScale(1)
	self.m_joystick_r:setScale(1)
	self.m_joystickBg:stopAllActions()
	self.m_joystick_l:stopAllActions()

	local size  = cc.Director:getInstance():getVisibleSize()
	

	--限制点击时产生摇杆的位置
	pos.x,pos.y=self:limit(pos.x,pos.y,_joystick_radius)

	--移动摇杆
	--取前一刻地盘的坐标
	local bg_pos = _joystickBg_old_pos

	--local dis = cc.pGetDistance(pos,bg_pos)
	local dis = math_ext.p_get_distance(pos,bg_pos)
	--self.m_joystick:setPosition(pos)
	
	if dis >_joystickBg_radius then
		if pos.x>_joystickBg_old_pos.x then

			
			self.old_posx = pos.x-_joystick_joystickBg_dis
			
			_joystickBg_old_pos.x = self.old_posx
			_joystickBg_old_pos.y = self.m_joystickBg:getPositionY()
			self.m_joystick_r:setScale(_j_scale)
			return command.stick_right
		end

		if pos.x<_joystickBg_old_pos.x then
			
			self.old_posx = pos.x+_joystick_joystickBg_dis
			
			_joystickBg_old_pos.x = self.old_posx
			_joystickBg_old_pos.y = self.m_joystickBg:getPositionY()
			self.m_joystick_l:setScale(_j_scale)
			return command.stick_left
		end
	end


	--限制底盘的走动

	--当点击在地盘内，直接设置摇杆位置
 	 
 	  	_joystickBg_old_pos.x = self.old_posx
		_joystickBg_old_pos.y = self.m_joystickBg:getPositionY()
 	   if pos.x < _joystickBg_old_pos.x then

 	   	self.m_joystick_l:setScale(_j_scale)
 	   	return command.stick_left
 	  else
	  	
	  	self.m_joystick_r:setScale(_j_scale)
 	  	return command.stick_right
 	  end

end

--
function operate_layer:set_stick_pos( pos , dis )
	-- body
	-- self.m_joystickBg:setPosition(dis,100)
	-- self.m_joystick:setPosition(dis,100)
	-- --local mbg_pos = cc.p(self.m_joystickBg:getPosition())
	-- local dis_x=pos.x-mbg_pos.x
	-- local dis_y = pos.y-mbg_pos.y
	-- self.m_joystick:runAction(cc.MoveTo:create(0.3,cc.p(pos.x,100)))
	-- _joystickBg_old_pos=cc.p(self.m_joystickBg:getPosition())

end



--隐藏摇杆
function operate_layer:hideJoystick(  )
	-- body


	self.m_joystick_r:setScale(1)
	self.m_joystick_l:setScale(1)
	self.m_joystickBg:setPosition(self.start_pos_x,self.start_pos_y)
	_joystickBg_old_pos.x = self.m_joystickBg:getPositionX()
	_joystickBg_old_pos.y = self.m_joystickBg:getPositionY()

end

function operate_layer:hideJoystick2(  )
	-- body


	self.m_joystick_r:setScale(1)
	self.m_joystick_l:setScale(1)
	self.m_joystickBg:setPosition(self.start_pos_x,self.start_pos_y)

end

function show_Joystick(  )
	-- body
	_joystick_r:setScale(1)
	_joystick_l:setScale(1)
	_joystickBg:setVisible(true)
	_joystick_l:setVisible(true)
end

function reset_Joystick_pos(  )

	_joystick_r:setScale(1)
	_joystick_l:setScale(1)
	_joystickBg:setPosition(_start_pos_x,_start_pos_y)
	_joystickBg_old_pos.x = _joystickBg:getPositionX()
	_joystickBg_old_pos.y = _joystickBg:getPositionY()
end

function operate_layer:limit(pos_x,pos_y,radius)
	local size  = cc.Director:getInstance():getVisibleSize()
	if pos_x < _joystick_swidth then
		pos_x = _joystick_swidth
	end
	if pos_y < _joystick_swidth then
		pos_y = _joystick_swidth
	end
	if pos_x >size.width/2*0.625 then
		pos_x = size.width/2*0.625
	end
	if pos_y > radius*3 then
		pos_y = radius*3
	end
	return pos_x , pos_y
end
function operate_layer:limit_bg(pos)
	local size  = cc.Director:getInstance():getVisibleSize()
	if pos < _joystickBg_swidth then
		pos = _joystickBg_swidth
	end
	if pos > _joystickBg_twidth then
		pos = _joystickBg_twidth
	end
	return pos
end


function operate_layer:updateJoystick( direction_x,direction_y, distance )
	-- body
	self.m_joystick_r:setScale(1)
	self.m_joystick_l:setScale(1)

	local size  = cc.Director:getInstance():getVisibleSize()
	--local start = cc.p(self.m_joystickBg:getPosition())
	local start_x , start_y= self.old_posx,self.m_joystickBg:getPositionY()

	--限制移动的摇杆的范围

	--local pos =cc.p(cc.pAdd(start,cc.pMul(direction,distance)))
	local x,y=math_ext.p_mul(direction_x,direction_y,distance)
	local pos_x,pos_y=math_ext.p_add(start_x,start_y,x,y)


	pos_x,pos_y=self:limit(pos_x,pos_y,_joystick_radius)
	--self.m_joystick:setPosition(pos_x,pos_y)
	--local bg_pos = cc.p(self.m_joystickBg:getPosition())
	local bg_pos_x , bg_pos_y =self.old_posx,self.m_joystickBg:getPositionY()
	--控制角色移动

	---移动底座
	if pos_x > bg_pos_x+_joystickBg_can_run_for_dis then
		local px = bg_pos_x+_joystickBg_can_run_for_dis
		local pxd = pos_x-px
		if bg_pos_x <_joystickBg_twidth then

		self.old_posx = bg_pos_x+pxd
		else

		self.old_posx = _joystickBg_twidth
		end
	end

	if pos_x < bg_pos_x-_joystickBg_can_run_for_dis then
		local px = bg_pos_x-_joystickBg_can_run_for_dis
		local pxd = -(pos_x-px)
		if bg_pos_x >_joystickBg_swidth then

		self.old_posx = bg_pos_x-pxd
		else
		
		self.old_posx = _joystickBg_swidth
		
	 	end
	 end
	
	local bg_pos2_x = self.old_posx 
	_joystickBg_old_pos.x,_joystickBg_old_pos.y=self.old_posx,self.m_joystickBg:getPositionY()
	if pos_x > bg_pos2_x then
		self.m_joystick_r:setScale(_j_scale)
		return command.stick_right

	else
		self.m_joystick_l:setScale(_j_scale)
		return command.stick_left
	end

end

