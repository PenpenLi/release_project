local entity			= import( 'world.entity' )
local math_ext			= import( 'utils.math_ext' )
local model 			= import( 'model.interface' )
local command			= import( 'game_logic.command' )
local state_mgr			= import( 'game_logic.state_mgr' )
local monster_skill		= import( 'model.monster_skill' )
local director			= import( 'world.director' )

monster  = lua_class( 'monster', entity.entity )

function monster:_init( id, conf_id )
	self.id = id
	self.conf_id = conf_id
	self.attr_data = data.monster[self.conf_id]
	self.model_id = self.attr_data.model_id
	self.data = data.monster_model[self.attr_data.model_id]
	self.type_id = self.data.type
	super(monster, self)._init(id, conf_id)
end

function monster:init_special_attr()
	self.conf = import('char.'..self.data.state)
	local id = self.model_id
	local ms = data.monster_skill[id]
	local skills = {}
	if ms ~= nil then
		for k, v in pairs(ms) do
			skills[k] = monster_skill.skill(id, v)
		end
	end
	self.skills = skills

	if self.data.ai ~= nil then
		self.ai = import('behavior.'..self.data.ai)
	end
	self.battle_group = 2

	-- self.x_speed = 10

	self.src_combat_attr: init_with_configdata( self.attr_data )
	if self.conf.default_run_speed ~= nil then
		self.src_combat_attr: set_speed_x( self.conf.default_run_speed )
	end
	if self.conf.no_flipped ~= nil then
		self:set_no_flipped(self.conf.no_flipped)
	end
	self.combat_attr:copy_from_attr(self.src_combat_attr)

	local y_offset_type = math.random(3)
	if y_offset_type <= 1 then
		self.y_axis_offset = -16
	elseif y_offset_type <= 2 then
		self.y_axis_offset = 0
	else
		self.y_axis_offset = 16
	end
end

---------------ai相关开始---------------------
function monster:aim_target(args)
	local exist_target = self.nearest_enemy ~= nil
	exist_target = exist_target and self.nearest_enemy.physics.x >= self.physics.bound_x1
	exist_target = exist_target and self.nearest_enemy.physics.x <= self.physics.bound_x2
	return exist_target
end

function monster:aim_platform_target(args)
	-- 敌人
	if self.nearest_enemy == nil then
		return false
	end

	--距离
	if args ~= nil and self.in_battle == false then
		if args.dis ~= nil then
			local enemy_pos = self.nearest_enemy:get_world_pos()
			local pos = self:get_world_pos()
			local dis  = math_ext.p_get_distance(enemy_pos, pos)
			if args.dis < dis then
				return false
			end
		end
	end

	--平台
	if self.nearest_enemy.physics.recent_standing ~= self.physics.recent_standing then
		return false
	end

	self.in_battle = true

	return true
end

function monster:search_target(args)
	local exist_target = self.in_battle_enemy ~= nil
	return exist_target
end

function monster:no_target(args)
	return not self:aim_target( args )
end

function monster:check_target_distance(args)
	if self.nearest_enemy == nil then
		return false
	end
	local enemy_pos = self.nearest_enemy:get_world_pos()
	local pos = self:get_world_pos()

	--local dis = cc.pGetDistance(enemy_pos, pos)
    local dis  = math_ext.p_get_distance(enemy_pos, pos)

	if args.distance_max ~= nil and dis > args.distance_max then
		return false
	end
	if args.distance_min ~= nil and dis < args.distance_min then
		return false
	end
	return true
end

function monster:move_to_target(args)
	if not self:on_ground() then
		return false
	end
	if not self:in_state({'run', 'idle'}) then
		return false
	end
	if self.nearest_enemy == nil then
		return false
	end
	self:face_target(args)
	local enemy_pos = self.nearest_enemy:get_world_pos()
	local pos = self:get_world_pos()

	if math.abs(enemy_pos.x - pos.x) < args.distance_max then
		return true
	else
		if enemy_pos.x < pos.x then
			-- self:set_velocity(-self.x_speed, 0)
			self:set_velocity(-self.combat_attr:get_speed_x(), 0)
		else
			-- self:set_velocity(self.x_speed, 0)
			self:set_velocity(self.combat_attr:get_speed_x(), 0)
		end
	end

	return false
end

-- 移动到目标点
function monster:move_to_pos( )
	-- self.blackboard.dest_pos 不为空
	if not self:on_ground() then
		return false
	end
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
		self:set_flipped(true)
		-- self:set_velocity(-self.x_speed, 0)
		self:set_velocity(-self.combat_attr:get_speed_x(), 0)
	else
		self:set_flipped(false)
		-- self:set_velocity(self.x_speed, 0)
		self:set_velocity(self.combat_attr:get_speed_x(), 0)
	end

	return false
end


-- 移动到随机点
function monster:move_to_rand_pos(args)
	if not self:in_state({'run', 'idle'}) then
		return false
	end
	if self.blackboard.dest_pos == nil or self.blackboard.dest_pos == -1 then
		-- 随机生成一个新的目标点
		local left = self.physics.bound_x1
		local right = self.physics.bound_x2
		if args ~= nil then
			local offset = args.max_x
			if offset ~= nil then
				local pos = self:get_world_pos().x
				left = math.max(pos - offset, left)
				right = math.min(pos + offset, right)
			end
		end
		self.blackboard.dest_pos = left + _extend.random(right-left)
		self.blackboard.is_reach_pos = false
	end
	return self:move_to_pos()
end

function monster:jump( args )
	self:set_velocity(args[1], args[2])
	return true
end

-----------逃离ai----------------------------------
--逃离的判断有没有玩家在范围内方法 参数front：前方多少像素，behind：后方多少像素 
function monster:flee_aim_target(args)
	local exist_target = self.nearest_enemy ~= nil
	exist_target = exist_target and self.nearest_enemy.physics.x >= self:get_world_pos().x-args.front
	exist_target = exist_target and self.nearest_enemy.physics.x <= self:get_world_pos().x+args.behind
	return exist_target
end

function monster:target_in_range(args)
	if args == nil then
		return false
	end
	if self.nearest_enemy == nil then
		return false
	end
	local dis = self.nearest_enemy.physics.x - self:get_world_pos().x
	local range = math.abs(dis)
	if args.min ~= nil and args.min > range then
		return false
	end
	if args.max ~= nil and args.max < range then
		return false
	end
	if args.x_max ~= nil and args.x_max < dis then
		return false
	end
	if args.x_min ~= nil and args.x_min > dis then
		return false
	end
	return true
end

--逃离的判断有没有玩家在范围内方法 参数front：前方多少像素，behind：后方多少像素 
function monster:flee_no_target(args) 
	return not self:flee_aim_target( args )
end

--陆地怪逃离玩家 flee_dis：逃离多远距离产生点， speed_multiple：速度倍数
function monster:flee_player( args )
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


	local platform_width = math.abs(self.physics.bound_x2 - self.physics.bound_x1)
		
	if platform_width == 0 then
			self.blackboard.dest_pos = self.physics.bound_x1 
			
	else
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
	end
		
		self.blackboard.is_reach_pos = false
	
	return self:flee_to_pos(args)
	

end


-- 逃离移动到生成的目标点
function monster:flee_to_pos( args )
	
	if not self:on_ground() then
		return false
	end
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
		
		-- self:set_velocity(self.x_speed*args.speed_multiple, 0)
		self:set_velocity(self.combat_attr:get_speed_x()*args.speed_multiple, 0)
	end

	return false
end
---------------ai相关结束---------------------
