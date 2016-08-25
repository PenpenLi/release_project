local entity			= import( 'world.entity' )
local monster			= import( 'world.entities.monster' )
local math_ext			= import( 'utils.math_ext' )
local model 			= import( 'model.interface' )
local command			= import( 'game_logic.command' )
local state_mgr			= import( 'game_logic.state_mgr' )
local director			= import( 'world.director' )

airmonster  = lua_class( 'airmonster', monster.monster )
local _ground_height = 50

function airmonster:_init( id, conf_id )
	super(airmonster, self)._init(id, conf_id)
end

-----------------飞行怪ai--------------------------------
--飞行怪的检查范围 传入参数：front：前方多少像素，behind：后方多少像素 
function airmonster:air_check_player_target(args)
	-- self.nearest_enemy = model.get_player().entity 	-- 在battle会更新最近敌人

	if self.nearest_enemy == nil then
		-- self.nearest_enemy = model.get_player().entity
		return false
	end

	--飞行怪的坐标
	local e_pos = self:get_world_pos()
	--飞行怪偏移上方的y
	local e_y = e_pos.y
	--玩家坐标
	local p_pos = self.nearest_enemy:get_world_pos()

	local left = args.left
	local right  = args.right
	--玩家的y坐标在飞行怪的下方
	if self.in_battle == false then
		--上下
		if p_pos.y > e_y+args.up or p_pos.y < e_y-args.down then
			return false
		end

		--并玩家在前方多少米内
		--面向左
		local dis
		if self:is_flipped() then
			dis = e_pos.x - p_pos.x
		else
			dis = p_pos.x - e_pos.x
		end
		if dis < -left or dis > right then
			return false
		end

	end

	self.in_battle = true

	return true

end

---检查周围有没有玩家 传入参数：front：前方多少像素，behind：后方多少像素 
function airmonster:air_monster_no_target(args)
	return not self:air_check_player_target( args ) 
end

--飞到玩家旁边攻击 
function airmonster:fly_to_player( args )
	-- body
	if self.nearest_enemy == nil then
		return false
	end
	if not self:in_state({'run', 'idle'}) then
		return false
	end

	local default_fly_speed = 0
	self.dest_pos = nil
	
	self:face_target(args)
	local pet_x ,pet_y = self.physics:get_pos()
	local player = 	self.nearest_enemy
	self.air_reach_destination = true

	if player:is_player() and not player:on_ground() then
		return false
	end

	--飞到玩家前方
	--print('air_stop:',self.air_stop)
	local player_x ,player_y = player:get_world_pos().x,player:get_world_pos().y+args.height
	local random_dis = math.random(-30, 30)
	local width = args.width+random_dis
	local height = args.height+random_dis

	if pet_x <= player:get_world_pos().x then

		local final_x ,final_y = player:get_world_pos().x-width,player:get_world_pos().y+height
		player_x ,player_y = final_x+50,final_y
	else

		local final_x ,final_y = player:get_world_pos().x+width,player:get_world_pos().y+height
		player_x ,player_y = final_x-50,final_y
	end

	local f_x ,f_y = math_ext.p_sub(player_x,player_y,pet_x,pet_y)

	--得出长度

	local length = math_ext.p_getLength(f_x,f_y)

	if length >=400 then
		default_fly_speed = self.fly_speed
	elseif length <400 and length >200 then

		default_fly_speed = self.fly_speed *1.0
	elseif length <= 200 and length > 50 then
		default_fly_speed = self.fly_speed *0.5
	elseif length < 50 then
		default_fly_speed = self.fly_speed *0.2
	end
	--归一向量
	local n_f_x,n_f_y = math_ext.p_normalize(f_x,f_y)
	local enemy_pos = self.nearest_enemy:get_world_pos()
	--范围

	if ((pet_x>=player_x-50) and (pet_x<=player_x+50)) and (pet_y>=player_y-50) and (pet_y<=player_y+50) then
		self:set_velocity(0,0)
		self.dest_pos = nil
		self.air_reach_destination = true
		
		
	else

		self.dest_pos = nil
		self.air_reach_destination = true
		--获取距离向量的百分之多少为速度，达到减速效果
		self.physics:set_speed(default_fly_speed*n_f_x,default_fly_speed*n_f_y)
	
		return false

	end

	return true

end


function airmonster:fly_move_to_player(args)

	if self.nearest_enemy == nil then
		return false
	end
	if not self:in_state({'run', 'idle'}) then
		return false
	end
	local y_speed = 0

	self:face_target(args)
	local enemy_pos = self.nearest_enemy:get_world_pos()
	local pos = self:get_world_pos()
	
	local height = self:get_world_pos().y-_ground_height
	local range = 40
	if height >= args.height+range  then
		
		y_speed=-self.fly_speed*0.5
	end
	if  height <= args.height-range then
		
		y_speed=self.fly_speed*0.5
	end

	if math.abs(enemy_pos.x - pos.x) < args.distance_max and (height<args.height+range and height>args.height-range ) then
		return true
	else
		if enemy_pos.x < pos.x then
			
			self:set_velocity(-self.fly_speed,y_speed)
		else
			
			self:set_velocity(self.fly_speed,y_speed)
		end
	end

	return false
end


--飞行怪随机移动逻辑 移动到随机点，
function airmonster:fly_to_rand_pos(args)
	if not self:in_state({'run', 'idle'}) then
		return false
	end
	local e_pos = self:get_world_pos()
	--是否在左边的范围内
	local default_fly_speed = self.fly_speed
	
	local left_dis = self.start_pos_width-args.left_dis
	local right_dis = self.start_pos_width+args.right_dis
	if self.air_reach_destination == true then
		self.air_reach_destination = false
		if e_pos.x < left_dis then
			--生成中左边范围的坐标x
			self.dest_pos = right_dis + _extend.random(args.rand)*args.multiple
		elseif e_pos.x > right_dis then
			--是否在右边的范围内
			self.dest_pos = left_dis - _extend.random(args.rand)*args.multiple
		else
			--是否在在中间的范围内
			if self:is_flipped() then
				self.dest_pos = left_dis  - _extend.random(args.rand)*args.multiple
			else
				self.dest_pos = right_dis + _extend.random(args.rand)*args.multiple
			end
		end
	end
	self.physics.bound_x2 = right_dis
	self.physics.bound_x1 = left_dis
	--根据玩家朝向设置宠物到达的位置
	local f_x ,f_y = math_ext.p_sub(self.dest_pos,self.start_pos_hight,e_pos.x,e_pos.y)
	local n_f_x,n_f_y = math_ext.p_normalize(f_x,f_y)

	local length = math_ext.p_getLength(f_x,f_y)
	if length >=400 then
		default_fly_speed = default_fly_speed
	elseif length <400 and length >200 then

		default_fly_speed = default_fly_speed *0.5
	elseif length <= 200 and length > 50 then
		default_fly_speed = default_fly_speed *0.3
	elseif length < 50 then
		default_fly_speed = default_fly_speed *0.2
	end


	--范围
	if ((e_pos.x>=self.dest_pos-20) and (e_pos.x<=self.dest_pos+20)) and (e_pos.y>=self.start_pos_hight-20) and (e_pos.y<=self.start_pos_hight+20)then
		self.air_reach_destination = true
		--return true
	else

		--获取距离向量的百分之多少为速度，达到减速效果
		--面向
		if self.dest_pos <= e_pos.x then
			self:set_flipped(true)

		else
			self:set_flipped(false)	
		end
		self.physics:set_speed(default_fly_speed*n_f_x,default_fly_speed*n_f_y)
		return false
	end

	return true
end

-- function airmonster:set_velocity(x, y)
-- 	super(airmonster, self).set_velocity( x, math.min(y, 0) )
-- end


----------飞行怪逃离玩家AI---------------------
-----------逃离ai----------------------------------


--陆地怪逃离玩家 flee_dis：逃离多远距离产生点， speed_multiple：速度倍数
function airmonster:flee_player( args )
	--感应范围
	if not self:in_state({'run', 'idle'}) then
		return false
	end
	local feel_dis = 450
	--逃离的距离
	if self.nearest_enemy == nil then
		return false
	end
	local flee_dis = args.flee_dis

	local enemy_pos = self.nearest_enemy:get_world_pos()
	local pos = self:get_world_pos()

    local dis  = math_ext.p_get_distance(enemy_pos, pos)


	--local platform_width = math.abs(self.physics.bound_x2 - self.physics.bound_x1)
		

	local enemy_pos = self.nearest_enemy:get_world_pos()
	local pos = self:get_world_pos()
	if enemy_pos.x < pos.x then
		self:set_flipped(false)
		flee_dis = flee_dis
		
	else
		self:set_flipped(true)
		flee_dis = -flee_dis
		
	end
	local pos_dis = self:get_world_pos().x + flee_dis
	if self.physics.bound_x2 <= pos_dis then
		pos_dis = self.physics.bound_x2
		
	end
	if pos_dis <= self.physics.bound_x1 then
		pos_dis = self.physics.bound_x1
		
	end
	
	self.blackboard.dest_pos = pos_dis

	
	self.blackboard.is_reach_pos = false
	
	return self:flee_to_pos(args)
	

end


-- 逃离移动到生成的目标点
function airmonster:flee_to_pos( args )
	
	if not self:in_state({'run', 'idle'}) then
		return false
	end

	if self.blackboard.is_reach_pos ~= nil 
	and self.blackboard.is_reach_pos == true then
		-- 走到了目标点
		self.blackboard.dest_pos = nil
		return true
	end

	-- 未到 - 面向 和 移动
	local pos_x = self:get_world_pos().x
	if self.blackboard.dest_pos < pos_x then
		
		-- self:set_velocity(-self.x_speed*args.speed_multiple, 0)
		self:set_velocity(-self.combat_attr:get_speed_x()*args.speed_multiple, 0)
	else
		
		self:set_velocity(self.combat_attr:get_speed_x()*args.speed_multiple, 0)
	end

	return false
end
