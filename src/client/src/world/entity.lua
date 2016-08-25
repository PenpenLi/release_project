local camera_mgr		= import( 'game_logic.camera_mgr' )
local command_mgr		= import( 'game_logic.command_mgr' )
local char				= import( 'world.char' )
local actions			= import( 'utils.actions' )
local primitives		= import( 'utils.primitives' )
local state_mgr			= import( 'game_logic.state_mgr' )
local command			= import( 'game_logic.command' )
local battle_const		= import( 'game_logic.battle_const' )
local math_ext			= import( 'utils.math_ext' )
local ai				= import( 'game_logic.ai' )
local cmd_handler		= import( 'game_logic.cmd_handler' )
local combat_attr 		= import( 'model.combat' )
local collider	 		= import( 'game_logic.collider' )
local physics	 		= import( 'physics.world' )
local swallow	 		= import( 'utils.swallow' )
local director			= import( 'world.director' )
local buff				= import( 'game_logic.buff' )
local model 			= import( 'model.interface' )

local keyboard_cmd		= import('world.keyboard_cmd')
local operate_cmd 		= import('ui.operate_cmd')
local skill_button 		= import( 'ui.skill_button' ) 
local bubble_dialog 	= import( 'ui.bubble_dialog.bubble_dialog' ) 
local timer 			= import( 'utils.timer' )
local shadow_layer		= import( 'world.shadow_layer' )

AttackBoxTag 	= 101
-- HitBoxTag 		= 102
PhyBoxTag 		= 103
-- 多个受击盒
HitBoxTag 	= {[1] = 105, [2] = 106, [3] = 107, [4] = 108, [5] = 109}

entity = lua_class( 'entity' )

function entity:_init( id, conf_id )
	self.id = id
	self.conf_id = conf_id
	self.buff = buff.buff( self )
	self:init_attr()

	self:create_physics()

	function hit_wall_callback( )
		self.blackboard.dest_pos = nil
	end
	self.physics:set_hit_wall_cb( hit_wall_callback )

	self:init_debug()

	-- 是否需要在同一个平台
	self.platform = nil

	-- 来自谁创建, 例如子弹来自主角
	self.is_from = nil
end

-- 外观相关 begin
function entity:update_skin(player)
	self.char:change_equip(self.char.equip_conf.weapon, player:get_wear('weapon'))
	self.char:change_equip(self.char.equip_conf.helmet, player:get_wear('helmet'))
	self.char:change_equip(self.char.equip_conf.armor, player:get_wear('armor'))
	player:bound_entity(self)
end

function entity:update_wing( avatar )
	self.char:change_wing(avatar:get_wing(), avatar:get_role_type())
end

function entity:set_char(c, bg)
	if c ~= nil then
		self.char = c
	end
	if bg ~= nil then
		self.bgchar = bg
	end
end

function entity:transform( sub_conf_key )
	director.get_cur_battle().proxy: entity_transform( self.id, sub_conf_key )
end

function entity:detransform( )
	director.get_cur_battle().proxy: entity_detransform( self.id )
end

function entity:is_transformed()
	return self.sub_char ~= nil
end

function entity:init_debug()
	self.hit_box_view = 0
	self.attack_box_view = nil
end

function entity:clean_hit_box_view()
	if self.hit_box_view == nil or self.hit_box_view == 0 then
		return
	end

	for i=1,self.hit_box_view do
		self.char.cc:removeChildByTag(HitBoxTag[i])
	end
	self.hit_box_view = 0
end

function entity:draw_debug_view()
	
	if DrawBoxes ~= true then
		return
	end

	-- mao
	-- if self.hit_box_view == nil and self.hit_box ~= nil then
	-- 	local hit_box = primitives.draw_box(self.hit_box, cc.c4f(0,0,0.5,0.5), self.conf.anim_flipped)
	-- 	self.char.cc:addChild(hit_box, 0, HitBoxTag)
	-- 	self.hit_box_view = HitBoxTag
	-- elseif self.hit_box_view ~= nil and self.hit_box == nil then
	-- 	self.hit_box_view = nil
	-- 	self.char.cc:removeChildByTag(HitBoxTag)
	-- end
	-- 画受击盒
	if self.hit_box_view == 0 and self.hit_box ~= nil then

		for i,v in ipairs(self.hit_box) do
			
			local hit_box = primitives.draw_box(v, cc.c4f(0,0,0.5,0.5), self.conf.anim_flipped)
			self.char.cc:addChild(hit_box, 0, HitBoxTag[i])
			self.hit_box_view = self.hit_box_view + 1
		end
	end

	if self.hit_box_view >= 1 and self.hit_box == nil then
		self:clean_hit_box_view()
	end

	-- 画攻击盒
	local function remove_attack_box_view(  )
		if self.attack_box_view == nil then
			return true
		end
		self.attack_box_view = nil
		self.char.cc:removeChildByTag(AttackBoxTag)
	end
	local function create_attack_box_view(  )
		local attack_box = primitives.draw_box(self.attack_info.attack_box, cc.c4f(0.5,0.9,0,0.8), self.conf.anim_flipped)
		self.char.cc:addChild(attack_box, 0, AttackBoxTag)
		self.attack_box_view = AttackBoxTag
	end

	-- info 没有改变
	if self.attack_info_last and self.attack_info_last == self.attack_info then
		return true
	end

	-- info 改变了
	self.attack_info_last = self.attack_info
	remove_attack_box_view()

	if self.attack_info ~= nil and self.attack_info.attack_box ~= nil then
		create_attack_box_view()
	end
end
-- 外观相关 end

function entity:set_is_from( e )
	local f = e:get_is_from()
	if f ~= nil then
		self.is_from = f
	else
		self.is_from = e
	end
end

function entity:get_is_from(  )
	return self.is_from
end

function entity:is_player()
	return false
end

function entity:is_bullet( )
	return false
end

function entity:is_pet( )
	-- body
	return self.conf.pet
end

function entity:is_boss( )
	return self.conf.boss
end

function entity:is_random_y()
	return self.conf.random_y_offset
end

function entity:get_main_element()
	return self.combat_attr.element[self.data.element_type]
end

function entity:init_special_attr()
	self.conf = import('char.'..self.data.state)
	if self.data.ai ~= nil then
		self.ai = import('behavior.'..self.data.ai)
		self.ai_frequency = self.data.ai_frequency
	end
	self.battle_group = 2

	-- self.x_speed = 10

	self.src_combat_attr: init_with_configdata( self.attr_data )
	if self.conf.default_run_speed ~= nil then
		self.src_combat_attr: set_speed_x( self.conf.default_run_speed )
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

--只在初始化设置。状态清理请用clear_attr
function entity:init_attr()
	-- src_combat_attr: 怪的load表；玩家的final_attr
	self.src_combat_attr = combat_attr.combat_attr()
	self.combat_attr = combat_attr.combat_attr()
	-- 仅显示时偏移，不影响逻辑判断
	self.y_axis_offset = 0
	self.ai = nil
	self.ai_frequency = 30
	self.cmd = cmd_handler.cmd()
	self.skills = {}

	-- 不同子类有不同的参数
	self:init_special_attr()

	self.state_order = self.conf.state_order
	self.states = self.conf
	self.char = swallow.swallow()
	self.bgchar = swallow.swallow()

	--帧缓存table
	self.world_pos = cc.p(0,0)
	self.velocity = cc.p(0,0)
	self.world_hit_box = nil
	

	-- 战斗属性
	self.mana_cost = 0

	-- attr
	self.in_air = false
	self.all_angle = false

	--状态相关
	self.cur_state = nil
	self.cur_state_obj = nil
	self.state_frame = 0
	self.state_duration = 0
	self.pause_frame = -1  -- 停到哪一帧停
	self.child_state = nil
	self.is_bati = false
	self.timetolive = nil

	--战斗属性
	self.attack_info = nil
	self.hit_entities = {}
	self:set_hit_box(nil)
	self.enemy_in_range = false
	self.double_jump = 2
	self.charge_count = 3
	self.charge_count_up = 2
	self.hit = false
	self.attack_times = nil
	self.inherit_speed = false
	self.active_skill = nil
	self.in_battle = false

	--敌人设置
	--self.battle_group = 1 -- 0 中立 大于0则不同group敌对
	self.target_enemy = nil
	self.nearest_enemy = nil
	self.in_battle_enemy = nil
	self.trigger_enemy = nil

	--面向管理
	self.facing = nil -- 面向策略
	self.stick_ctrl = true
	self.stick_direction = command.none
	self.moving_direction = command.stick_right
	self.auto_face_direction = nil
	self.force_flipped = nil
	self.final_flipped = self.conf.default_flipped

	-- 角色 ai auto_attack
	self.blackboard = {}
	self.debug_ai = DebugEntityAi
	self.ai_frame = _extend.random(60)
	self.frame_count = 1

	self.last_attack_frame = 0
	self.ai_state_frame = {}

	--跟随
	self.is_follow = 0
	self.follow_speed = 0.0009
	self.dest_offset = {0,0}
	self.cur_follow_speed = self.follow_speed
	self.dest_pos = 0
	self.air_reach_destination = true
	self.air_stop = false
	self.bullet_speed = 50
	self.rate_count = 0
	self.follow_rate = 1

	--子弹环绕
	self.is_surround = nil		-- entity 是否被环绕
	self.surround_bullets = {}
	self.surround_offset_x = {}
	self.surround_offset_y = {}

	---气泡对话
	self.blackboard.is_say = false
	self.blackboard.is_fst_say = true
	self.blackboard.time_id = nil

	
end


--每次切换状态清理
function entity:clear_attr()
	-- attr
	self.in_air = false

	--self.cur_state = nil
	--self:set_gravity_enable(true)
	self.state_frame = 0
	self.state_duration = 0
	self.is_bati = false
	self.mana_cost = 0
	self.inherit_speed = false

	self.child_state = nil
	self:set_hit_box(self.conf.default_hit_box)

	self.attack_info = nil

	self.facing = nil
	self.stick_direction = command.none
	self.stick_ctrl = false
	self.force_flipped = nil
	self:set_reverse(0)
	--[[
	if self.combat_attr.speed_x ~= 0 then
		self.x_speed = self.combat_attr.speed_x
	elseif self.conf.default_run_speed ~= nil then
		self.x_speed = self.conf.default_run_speed
	else
		self.x_speed = 15
	end
	--]]

	if self.conf.default_fly_speed ~= nil then
		self.fly_speed = self.conf.default_fly_speed
	else
		self.fly_speed = 25
	end
	self.hit_entities = {}
end

function entity:apply_buffs( buff_list )
	if #buff_list == 0 then
		self.src_combat_attr.hp = self.combat_attr.hp
		self.src_combat_attr.mp = self.combat_attr.mp
		self.combat_attr:copy_from_attr(self.src_combat_attr)
		self.stick_direction = command.none
		return
	end

	local effect_list = {}
	for k, v in pairs(buff_list) do
		if effect_list[v.data.name] == nil then
			effect_list[v.data.name] = {sqr = 0, mul = 0, bns = 0}
		end
		effect_list[v.data.name].sqr = effect_list[v.data.name].sqr + v.data.square
		effect_list[v.data.name].mul = effect_list[v.data.name].mul + v.data.multiplier
		effect_list[v.data.name].bns = effect_list[v.data.name].bns + v.data.bonus
	end

	for k, v in pairs(effect_list) do
		if k == 'hp' or k == 'mp' then
			if self.combat_attr[k] ~= nil then
				self.combat_attr[k] = self.combat_attr[k] * self.combat_attr[k] * v.sqr 
									+ self.combat_attr[k] * v.mul 
									+ self.combat_attr[k] + v.bns
			end
		else
			if self.combat_attr[k] ~= nil then
				self.combat_attr[k] = self.src_combat_attr[k] * self.src_combat_attr[k] * v.sqr 
									+ self.src_combat_attr[k] * v.mul 
									+ self.src_combat_attr[k] + v.bns
			end
		end
	end
	self.stick_direction = command.none
end

function entity:pre_release()
	if self.conf.show_damage_data == true and self.damage_stat ~= nil then
		local total_damage = 0
		for k, v in pairs(self.damage_stat) do
			total_damage = total_damage + v.damage
		end
		print(self.id .. '已阵亡')
		for k, v in pairs(self.damage_stat) do
			print('\t累计'.. k .. '伤害：', math.ceil(v.damage/total_damage*100) .. '%', v.damage)
		end
	end
	self.del = true
end

function entity:release()
	print('entity:release')
	self.buff:unbound_entity()
	physics.release_object(self.physics.id)
	self.physics = nil
end

function entity:create_physics()
	print('create_physics')
	local pos = cc.p(500, VisibleSize.height / 4 * 1)
	self.physics = physics.create_point(pos.x, pos.y)
	if self.conf.rigid_box ~= nil then
		local box = self.conf.rigid_box
		physics.create_rigid_in_entity( self.physics.id, box[1], box[2], box[3], box[4])
	end
end

function entity:hit_red_body()
	self.char:hit_red_body()
	self.bgchar:hit_red_body()
	if self.sub_char ~= nil then
		self.sub_char:hit_red_body()
	end
end
--mao
function entity:calc_world_hit_box()
	self:set_hit_box(self.hit_box)
	if self.hit_box == nil then
		self.world_hit_box = nil
		return
	end

	self.world_hit_box = {}

	local box = self.hit_box
	local pos = self:get_world_pos()

	if self:is_flipped() then

		for i,v in ipairs(box) do
			self.world_hit_box[i] = {0,0,0,0}

			self.world_hit_box[i][1] = -v[3]+pos.x
			self.world_hit_box[i][2] = v[2]+pos.y
			self.world_hit_box[i][3] = -v[1]+pos.x
			self.world_hit_box[i][4] = v[4]+pos.y
		end
		-- self.world_hit_box[1] = -box[3]+pos.x
		-- self.world_hit_box[2] = box[2]+pos.y
		-- self.world_hit_box[3] = -box[1]+pos.x
		-- self.world_hit_box[4] = box[4]+pos.y
	else
		for i,v in ipairs(box) do
			self.world_hit_box[i] = {0,0,0,0}

			self.world_hit_box[i][1] = v[1]+pos.x
			self.world_hit_box[i][2] = v[2]+pos.y
			self.world_hit_box[i][3] = v[3]+pos.x
			self.world_hit_box[i][4] = v[4]+pos.y
		end
		-- self.world_hit_box[1] = box[1]+pos.x
		-- self.world_hit_box[2] = box[2]+pos.y
		-- self.world_hit_box[3] = box[3]+pos.x
		-- self.world_hit_box[4] = box[4]+pos.y
	end
end

--设置子弹的频率
function entity:set_follow_rate( f_r )
	if f_r ~= nil then
		self.follow_rate = f_r
	end
end


--设置子弹速度
function entity:set_bullet_speed( sp )

	if sp ~= nil then
		self.bullet_speed = sp
	end
end

function entity:set_trigger_enemy( e )
	self.trigger_enemy = e
end

function entity:get_trigger_enemy(  )
	return self.trigger_enemy
end

function entity:update_follow_info()

	if self.is_follow ~= nil and self.is_follow == 1 then
		self.rate_count = self.rate_count + 1
		if self.rate_count%self.follow_rate ~= 0 then
			return
		end
		--求球指向玩家的向量，向量相减，玩家减去球
		local b_x ,b_y = self.physics:get_pos()
		local player = 	director.get_cur_battle().entities[1]
		local p_x ,p_y = player:get_world_pos().x+self.dest_offset[1],player:get_world_pos().y+self.dest_offset[2]
		local f_x ,f_y = math_ext.p_sub(p_x,p_y,b_x,b_y)
		--归一向量
		local n_f_x,n_f_y = math_ext.p_normalize(f_x,f_y)
		self.physics:set_speed(n_f_x*self.bullet_speed,n_f_y*self.bullet_speed)
		--self.physics:set_speed(150,150)
	end 
	if self.is_follow ~= nil and self.is_follow == 2 then
		--求球指向玩家的向量，向量相减，玩家减去球

		if self.rate_count%self.follow_rate ~= 0 then
			return
		end
		local b_x ,b_y = self.physics:get_pos()
		local player = 	director.get_cur_battle().entities[1]
		local p_x ,p_y = player:get_world_pos().x+self.dest_offset[1],player:get_world_pos().y+self.dest_offset[2]
		local f_x ,f_y = math_ext.p_sub(p_x,p_y,b_x,b_y)
		--归一向量
		local n_f_x,n_f_y = math_ext.p_normalize(f_x,f_y)
		self.physics:set_force(f_x*self.cur_follow_speed,f_y*self.cur_follow_speed)
	end 		
end

-- 子弹环绕
function entity:update_surround_info(  )

	-- entity 是否被环绕
	if self.is_surround == nil then
		return
	end

	local entities = director.get_cur_battle().entities
	local pos = self:get_world_pos()

	for i,v in pairs(self.surround_bullets) do

		if entities[i] == nil then
			self.surround_bullets[i] = nil
			self.surround_offset_x[i] = nil
			self.surround_offset_y[i] = nil
		else
			v:set_world_pos( pos.x + self.surround_offset_x[i], pos.y + self.surround_offset_y[i])
		end
	end
end

-- 此方法每帧在battle tick开始时调用
function entity:update_physics_info()
	local x, y = self.physics:get_pos()
	local vx, vy = self.physics:get_speed()
	self.world_pos.x = x
	self.world_pos.y = y
	self.velocity.x = vx
	self.velocity.y = vy
	self:update_follow_info()
	-- 更新子弹环绕
	self:update_surround_info()

	self:calc_world_hit_box()
	if self.physics.standing ~= 0 then
		self.double_jump = 2
		self.charge_count = 3
		self.charge_count_up = 2
	end
end

--设置穿墙
function  entity:set_obstacle( is_obstacle )
	self.physics.no_obstacle = is_obstacle
end

-- WARNNING: 此方法copy！！不要频繁调用！
function entity:get_world_pos_copy()
	return cc.p(self.world_pos.x, self.world_pos.y)
end

-- WARNNING: 此方法不copy！！只读！
function entity:get_world_pos()
	return self.world_pos
end

function entity:set_world_pos( x, y )
	self.physics:set_pos(x, y)
	self.world_pos.x = x
	self.world_pos.y = y
end

function entity:goto_state(state)
	self.gstate = state
end

function entity:pop_goto_state()
	local s = self.gstate
	self.gstate = nil
	return s
end

--TODO: new table
function entity:set_attack_info( info )
	if self.attack_info ~= nil then
		local group_id = self.attack_info.group_id
		if group_id == nil or info.group_id ~= group_id then
			self.hit_entities = {}
		end
	end
	self.attack_info = table_deepcopy(info)

	--init_skillinfo
	if self.active_skill ~= nil then
		self.attack_info.skill = self.active_skill
	end

end

function entity:set_hit_box( box )

	if box == nil then
		self.hit_box = nil
	else
		local new_box = box
		if type(box[1]) ~= 'table' then
			new_box = {[1] = box}
		end
		self.hit_box = new_box
	end

	-- mao
	if self.hit_box_view and (self.hit_box_view >=1) then
		self:clean_hit_box_view()
	end
end

function entity:play_anim( anim )
	self.char:play_anim( anim )
	self.bgchar:play_anim( anim )
end

function entity:handle_movement()
	if self.stick_ctrl == true then
		local cmd_dir = self.cmd:get_stick_direction()
		local cur_dir = self.stick_direction
		if cmd_dir ~= cur_dir then
			if cmd_dir == command.none then
				local pnt = self:get_velocity()
				self:set_velocity(0, pnt.y)
			end
			if cmd_dir == command.stick_left then
				if cmd_dir ~= self.moving_direction then
					self.moving_direction = cmd_dir
				end

				local pnt = self:get_velocity()
				-- self:set_velocity(-(self.x_speed+self.combat_attr.speed_x), pnt.y)
				self:set_velocity(-self.combat_attr:get_speed_x(), pnt.y)
			end
			if cmd_dir == command.stick_right then
				if cmd_dir ~= self.moving_direction then
					self.moving_direction = cmd_dir
				end
				
				local pnt = self:get_velocity()
				-- self:set_velocity(self.x_speed+self.combat_attr.speed_x, pnt.y)
				self:set_velocity(self.combat_attr:get_speed_x(), pnt.y)
			end
			self.stick_direction = cmd_dir
		end
	end
end

function entity:update_before_state_tick()
	-- 更新指令
	self.cmd:tick()
	--这段代码前后都要加
	self:handle_movement()

	-- 实体存活时间
	if self.timetolive ~= nil then
		self.timetolive = self.timetolive - 1
		if self.timetolive < 0 then
			self:pre_release()
		end
	end

	-- 更新ai
	self.frame_count = self.frame_count + 1
	if self:get_ai() ~= nil and self.frame_count > self.ai_frame then
		ai.tick(self)
		self.ai_frame = self.frame_count + self.ai_frequency + _extend.random(10) - 5
	end

	-- 顿帧回复
	-- if self.state_frame == self.pause_frame then
	if self.pause_frame == 0 then
		self.pause_frame = self.pause_frame - 1
		self:resume()
	elseif self.pause_frame > 0 then
		self.pause_frame = self.pause_frame - 1
	end

	-- 帧计数
	if self.pause_frame <= 0 then
		self.state_frame = self.state_frame + 1
	end

	--获得状态中帧信息
	if self.pause_frame <= 0 and self.states[self.cur_state] ~= nil then
		local frames = self.states[self.cur_state].frames
		local cur_frame = self.state_frame
		if frames~=nil and cur_frame%FpsRate==0 and frames[self.state_frame/FpsRate] ~= nil then
			local frame_info = frames[self.state_frame/FpsRate]
			if frame_info ~= nil then
				--TODO: new table
				self:set_attack_info(frame_info)
			end
		end
	end
end

function entity:update_after_state_tick()
	--计算面向
	if self:is_player() or self:is_bullet() then
		if self.force_flipped ~= nil then
			if self.force_flipped == true then
				self.final_flipped = true
			else
				self.final_flipped = false
			end
		elseif self.facing == 'auto' and self.auto_face_direction ~= nil then
			if self.auto_face_direction == command.stick_left then
				self.final_flipped = true
			else
				self.final_flipped = false
			end
		elseif self.facing == 'move' then
			if self.moving_direction == command.stick_left then
				self.final_flipped = true
			else
				self.final_flipped = false
			end
		end

	else

		-- 如果到了边界，就停下来
		-- for ai: 移动到目标点
		if self.blackboard.dest_pos ~= nil and self.blackboard.is_reach_pos == false then	
			-- 距离目标点还有多远
			local remain_distance = math.abs(self.blackboard.dest_pos - self.world_pos.x)
			-- if remain_distance <= self.x_speed then
			if remain_distance <= self.combat_attr:get_speed_x() then
				self.blackboard.is_reach_pos = true
				self:set_velocity(0, 0)
			end

			-- 到边界
			-- if self.world_pos.x - self.x_speed*3 <= self.physics.bound_x1
			if self.world_pos.x - self.combat_attr:get_speed_x()*3 <= self.physics.bound_x1
			and self:is_flipped() then
				self.blackboard.is_reach_pos = true
				self:set_velocity(0, 0)
			end
			-- if self.world_pos.x + self.x_speed*3 >= self.physics.bound_x2 
			if self.world_pos.x + self.combat_attr:get_speed_x()*3 >= self.physics.bound_x2 
			and not self:is_flipped() then
				self.blackboard.is_reach_pos = true
				self:set_velocity(0, 0)
			end
		end

	end

	self:handle_movement()
	--更新血量和魔法值
	
	self.combat_attr:tick()
	

end

function entity:draw()
	--画盒子
	self:draw_debug_view()

	if self.all_angle == true then
		local rotate = math.atan2((self.velocity.x),(self.velocity.y))*180/math.pi
		if self:is_flipped() then
			self.char.cc: setRotation( rotate+90 )
			self.bgchar.cc: setRotation( rotate+90 )
		else
			self.char.cc: setRotation( rotate-90 )
			self.bgchar.cc: setRotation( rotate-90 )
		end
	end
	self.char:tick()

	--翻转
	if self.conf.anim_flipped == true then
		if self:is_flipped() then
			self.char:set_flipped( false )
			self.bgchar:set_flipped( false )
			if self.sub_char ~= nil then
				self.sub_char:set_flipped( false )
			end
		else
			self.char:set_flipped( true )
			self.bgchar:set_flipped( true )
			if self.sub_char ~= nil then
				self.sub_char:set_flipped( true )
			end
		end
	else
		if self:is_flipped() then
			self.char:set_flipped( true )
			self.bgchar:set_flipped( true )
			if self.sub_char ~= nil then
				self.sub_char:set_flipped( true )
			end
		else
			self.char:set_flipped( false )
			self.bgchar:set_flipped( false )
			if self.sub_char ~= nil then
				self.sub_char:set_flipped( false )
			end
		end
	end

	--位置
	local spos = camera_mgr.world_to_screen(self:get_world_pos())
	self.char.cc:setPosition(spos.x, spos.y+self.y_axis_offset)
	self.bgchar.cc:setPosition(spos.x, spos.y+self.y_axis_offset)
	if self.sub_char ~= nil then
		self.sub_char.cc:setPosition(spos.x, spos.y)
	end
end

function entity:in_state( args )
	local cs = self.cur_state
	for _, s in pairs(args) do
		if cs == s then
			return true
		end
	end
	return false
end

function entity:has_state( state )
	return self.states[state] ~= nil
end

function entity:set_force_flipped( flipped )
	self.force_flipped = flipped
	if flipped then
		self.moving_direction = command.stick_left
	else
		self.moving_direction = command.stick_right
	end
end

--真实的翻转
function entity:is_flipped()
	return self.final_flipped
end

function entity:set_flipped(flipped)
	self.final_flipped = flipped
end

function entity:apply_impulse(x, y)
	self.physics:add_speed(x, y)
end

function entity:on_ground()
	return self.physics.standing ~= 0
end

function entity:count_jump()
	self.double_jump = self.double_jump - 1
end

function entity:cost_charge_count(charge_count)
	self.charge_count = self.charge_count - charge_count
end

function entity:cost_charge_count_up(charge_count_up)
	self.charge_count_up = self.charge_count_up - charge_count_up
end

function entity:apply_force(x, y)
	self.physics:set_force(x, y)
end

function entity:set_velocity(x, y)
	self.velocity.x = x
	self.velocity.y = y
	self.physics:set_speed(x, y)
	if self.inherit_speed == true then
		self:set_inherit_speed(x, y)
	end
end

function entity:set_y_speed(v)
	self.physics:set_y_speed(v)
end

function entity:set_x_speed(v)
	self.physics:set_x_speed(v)
end

function entity:change_x_speed( args ) -- 增加速度

	local vx, vy = self.combat_attr:get_speed_x()
	self.src_combat_attr:set_speed_x(args.v+vx)
	self.combat_attr:set_speed_x(args.v+vx)
	return true
end

function entity:set_reverse( rs )
	self.physics:set_reverse(rs)
end

function entity:execute_count( args )
	
	if self.execute_n == nil then
		self.execute_n = 1
	end
	if self.execute_n <= args.n then
		self.execute_n = self.execute_n + 1
		return true
	else return false
	end
end

function entity:get_velocity()
	return self.velocity
end

function entity:set_gravity(b)
		self.physics:set_gravity(b)
end

function entity:pause(frame)
	self.pause_frame = frame
	self.char:pause_anim()
	self.physics:set_enable(false)
end

function entity:resume()
	self.char:resume_anim()
	self.physics:set_enable(true)
end

function entity:get_battle_group()
	return self.battle_group
end

function entity:get_world_hit_box()
	return self.world_hit_box
end

function entity:set_facing( facing )
	self.facing = facing
end

--开启跟随
function entity:set_follow( flag )
	
	if flag ~= nil then
		self.is_follow = flag
		self.physics:set_gravity(0)
	end
end

--设置子弹在目标偏移位置
function entity:set_dest_offset( num )
	self.dest_offset = num
end

--保存起始飞行高度
function entity:preserve_start_pos_width_hight( x, y )
	self.start_pos_hight = y
	self.start_pos_width = x
end


--设置继承速度
function entity:set_inherit_speed( x, y )
	local entities = director.get_cur_battle().entities
	for hit_id, _ in pairs(self.hit_entities) do
		if entities[hit_id] ~= nil  then
			entities[hit_id]:set_velocity( x, y )
		end
	end
end

function entity:cast_skill( cmd, skill_id )
end


function entity:get_active_skill()
	return self.active_skill
end

--消失
function entity:fade( t ,op )
	self.char:fade(t, op)
	shadow_layer.fade_shadow_with_id( self.id , t, op )
end

function entity:fire_bullet( create_obj )
	local x, y = 0, 0
	local ex = self:get_world_pos().x
	local ey = self:get_world_pos().y
	if create_obj.self_offset ~= nil then
		if self:is_flipped() then
			x = ex - create_obj.self_offset[1]
		else
			x = ex + create_obj.self_offset[1]
		end
		y = ey + create_obj.self_offset[2]
	end
	
	if create_obj.enemy_offset ~= nil then
		if self.in_battle_enemy == nil then
			return
		end
		local target_pos = self.in_battle_enemy:get_world_pos()

		if self.in_battle_enemy.final_flipped == true then
			x = target_pos.x - create_obj.enemy_offset[1]
		else
			x = target_pos.x + create_obj.enemy_offset[1]
		end
		y = target_pos.y + create_obj.enemy_offset[2]
	end

	if create_obj.scene_offset ~= nil then
		if create_obj.scene_offset[1] == 'self' then
			x = ex
		elseif create_obj.scene_offset[1] == 'player' then
			if self.in_battle_enemy ~= nil then
				x = self.in_battle_enemy:get_world_pos().x
			else
				x = 0
			end
		else
			x = create_obj.scene_offset[1]
		end

		if create_obj.scene_offset[2] == 'self' then
			y = ey
		elseif create_obj.scene_offset[2] == 'player' then
			if self.in_battle_enemy ~= nil then
				y = self.in_battle_enemy:get_world_pos().y
			else
				y = 200
			end
		else
			y = create_obj.scene_offset[2]
		end
	end
	local dest_pos = nil
	if create_obj.dest_offset ~= nil then
		if self.in_battle_enemy ~= nil then
			dest_pos = {0, 0}
			dest_pos[1] = self.in_battle_enemy:get_world_pos().x
			dest_pos[2] = self.in_battle_enemy:get_world_pos().y
			dest_pos[1] = dest_pos[1] + create_obj.dest_offset[1]
			dest_pos[2] = dest_pos[2] + create_obj.dest_offset[2]
		end
	end
	local cnt = 1
	if create_obj.count ~= nil then
		cnt = create_obj.count
	end
	for i=1,cnt do
		if create_obj.random_area ~= nil then
			local area = create_obj.random_area
			local safe_area = create_obj.safe_area
			local random_safe_area = create_obj.random_safe_area
			if random_safe_area ~= nil then
				local rx = area[3] - area[1] - random_safe_area[1]
				local ry = area[4] - area[2] - random_safe_area[2]
				safe_area = {rx, ry, safe_area[1], safe_area[2]}
			end
			if safe_area ~= nil then
				if area[1] == safe_area[1] and area[3] == safe_area[3] then
					x = _extend.random(area[3]-area[1]) + area[1]
					if x >= safe_area[1] and x <= safe_area[3] then
						y = _extend.random(area[4]-area[2] - (safe_area[4] - safe_area[2])) + area[2]
						if y >= safe_area[2] and y <= safe_area[4] then
							y = y + (safe_area[4] - safe_area[2])
						end
					else
						y = _extend.random(area[4]-area[2]) + area[2]
					end
				else
					y = _extend.random(area[4]-area[2]) + area[2]
					if y >= safe_area[2] and y <= safe_area[4] then
						x = _extend.random(area[3]-area[1] - (safe_area[3] - safe_area[1])) + area[1]
						if x >= safe_area[1] and x <= safe_area[3] then
							x = x + (safe_area[3] - safe_area[1])
						end
					else
						x = _extend.random(area[3]-area[1]) + area[1]
					end
				end
			end

			if self:is_flipped() then
				x = ex - x
			else
				x = ex + x
			end
			y = ey + y
		end
		-- 传参
		local obj_args = {}
		obj_args.conf_id = create_obj.conf_id
		obj_args.pos = {x, y}
		obj_args.dest_pos = dest_pos

		obj_args.duration = create_obj.duration
		obj_args.attack_times = create_obj.attack_times
		obj_args.portal_dest = create_obj.portal_dest
		obj_args.is_follow = create_obj.is_follow
		obj_args.is_follow_rate = create_obj.is_follow_rate
		obj_args.fly_speed = create_obj.fly_speed
		obj_args.gravity = create_obj.gravity
		obj_args.no_obstacle = create_obj.no_obstacle
		obj_args.set_flipped = self.final_flipped
		obj_args.battle_group = self.battle_group
		obj_args.velocity = create_obj.velocity
		obj_args.all_angle = create_obj.all_angle
		obj_args.ground = create_obj.ground
		obj_args.dest_offset = create_obj.dest_offset
		obj_args.is_from = self

		if create_obj.inherit_attr == true then
			obj_args.combat_attr = self.combat_attr
		end
		if type(create_obj.conf_id) == 'string' then
			local skill = self:get_active_skill()
			obj_args.skill = skill
			create_obj.inherit_attr = true
			obj_args.combat_attr = self.combat_attr
			obj_args.type = 'bullet'
		end
		local skill = obj_args.skill
		if skill ~= nil and skill:get_bullet_conf(create_obj.conf_id) == nil then
			print('技能不能找到子弹配置', create_obj.conf_id)
		else
			local mons = director.get_cur_battle():create_monster( obj_args )
			
			if create_obj.is_surround then -- 子弹环绕

				-- local _player = director.get_cur_battle().main_player
				self.is_surround = true
				self.surround_bullets[mons.id] = mons
				self.surround_offset_x[mons.id] = create_obj.self_offset[1] or 0
				self.surround_offset_y[mons.id] = create_obj.self_offset[2] or 0
			end
		end
	end
end

function entity:get_state_order()
	if self.combat_attr.state_order ~= nil then
		return self.combat_attr.state_order
	end
	return self.state_order
end


function entity:get_ai()
	if self.combat_attr.ai ~= nil then
		return self.combat_attr.ai
	end
	return self.ai
end

-------------------------- 公用ai start -----------------------
------------- 状态判断、切换公用； 移动跟随 独特 --------------
---------------------------------------------------------------

function entity:set_no_flipped(no_flipped)
	self.no_flipped = no_flipped
end

function entity:_face_target()
	if self.nearest_enemy == nil then
		return false
	end
	if self.no_flipped ~= nil then
		return false
	end
	local enemy_pos = self.nearest_enemy:get_world_pos()
	local pos = self:get_world_pos()
	if enemy_pos.x < pos.x then
		self:set_flipped(true)
	else
		self:set_flipped(false)
	end
	return true
end

function entity:turn_around()
	if self.no_flipped ~= nil then
		return false
	end

	if self:is_flipped() then
		self:set_flipped(false)
	else
		self:set_flipped(true)
	end
	return true
end

function entity:face_target(args)
	if self.nearest_enemy == nil then
		return false
	end
	if not self:in_state({'run', 'idle'}) then
		return false
	end
	self:_face_target()
	return true
end

function entity:probability(args)
	return _extend.random(args[2]) <= args[1]
end

function entity:is_alive()
	return self.combat_attr.hp > 0
end

function entity:is_dead()
	return self.combat_attr.hp <= 0
end

function entity:dont_move()
	self:set_velocity(0,0)
	return true
end

function entity:hp_percentage(args)
	if self.blackboard.last_hp_percentage == nil then
		self.blackboard.last_hp_percentage = 100
	end

	local hp_percentage = self.combat_attr.hp / self.combat_attr.max_hp * 100 
	for _, hp_line in ipairs(args) do
		if hp_percentage <= hp_line and self.blackboard.last_hp_percentage > hp_line then
			self.blackboard.last_hp_percentage = hp_percentage
			return true
		end
	end
	return false
end

function entity:hp_range( args )
	local hp_percentage = self.combat_attr.hp / self.combat_attr.max_hp * 100 
	local in_range = hp_percentage >= args[1]
	in_range = in_range and hp_percentage < args[2]
	return in_range
end

function entity:set_group( args ) -- 设置阵营
	if args.group ~= nil and self.battle_group ~= args.group then
		self.battle_group = args.group
	end
	return true
end

-- 判断是否同一平台
function entity:is_same_platform( hit_e )
	if self.platform == nil then
		return true
	end

	--平台
	if hit_e.physics:get_platform() == self.physics:get_platform() then
		return true
	else
		return false
	end
end

function entity:set_platform( args )
	self.platform = args.flag
	return true
end

function entity:ai_state( args )
	if args.state == nil then
		return false
	end
	if self.ai_state_frame[args.state] == nil then
		self.ai_state_frame[args.state] = -10000
	end
	if args.cd ~= nil and self.frame_count - self.ai_state_frame[args.state] < args.cd*Fps then
		return false
	end
	if state_mgr.try_change_state(self, args.state) == false then
		return false
	end
	self:_face_target()
	self.ai_state_frame[args.state] = self.frame_count
	return true
end

function entity:check_state( args )
	if self.cur_state == args.state then
		return true
	else
		return false
	end
end

function entity:attack(args)
	self:set_velocity(0, 0)
	if args ~= nil and args.cd ~= nil and self.frame_count - self.last_attack_frame < args.cd*Fps then
		return false
	end

	self:_face_target()
	self.cmd.command[command.touch_right] = 2
	self.last_attack_frame = self.frame_count
	return true
end

-- 场景的ai
function entity:check_entity_count( args )
	return director.get_cur_battle():check_entity_count( args )
end

-- 怪物AI给怪物一个Buff
function entity:ai_apply_buff( args )
	if args.buff == nil then
		return false
	end

	self.buff:apply_buff(args.buff, nil, nil)
	return true
end

---对话------------------

---计数器
function entity:create_counter( args )
	-- body

	if self.blackboard.counter == nil then
		 self.blackboard.counter = {}
	end

	if self.blackboard.counter[args.counter_id] == nil then
		self.blackboard.counter[args.counter_id] = 0
	end

	self.blackboard.counter[args.counter_id] = self.blackboard.counter[args.counter_id]+1

	if self.blackboard.counter[args.counter_id] > args.count then

		return false
	end
	--print('说的次数：',self.blackboard.counter[args.counter_id])
	return true
end

---顶掉对话
function entity:bubble_dialogue(args)
	--顶掉对话
	if  self.conf.default_hit_box ~= nil and self.blackboard.is_fst_say == false and self.blackboard.time_id ~= nil then
		self.blackboard.is_say = false
		self.blackboard.is_fst_say = true
		self.char:remove_dialog()
		timer.remove_time(self.blackboard.time_id)
		--print('关的id:',self.blackboard.time_id)
		self.blackboard.time_id = nil

	end

	--加入气泡对话
	if self.conf.default_hit_box ~= nil and self.blackboard.is_fst_say == true  then

		-- mao
		local hit_box
		if type(self.conf.default_hit_box[1]) == 'table' then
			hit_box = self.conf.default_hit_box[1]
		else
			hit_box = self.conf.default_hit_box
		end

		self.blackboard.is_fst_say = false
		self.blackboard.is_say = true
		self.char:set_dialog_id(args.id)
		self.char:add_dialog(hit_box[3],hit_box[4])

		--利用计时器准时消掉对话方式。
		local function dialog_release(  )
			self.blackboard.is_say = false
			self.blackboard.is_fst_say = true
			self.blackboard.time_id = nil
			self.char:remove_dialog()
		end 

		self.blackboard.time_id = timer.set_timer(args.time, dialog_release)
		--print('开的id:',self.blackboard.time_id)
	end
	return true
end
--------------------------  公用ai end  -----------------------
------------- 状态判断、切换公用； 移动跟随 独特 --------------
---------------------------------------------------------------
