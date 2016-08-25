
local condition 	= import( 'game_logic.condition' )
local op_unit		= import( 'game_logic.op_unit' )
local command		= import( 'game_logic.command' )
local director		= import( 'world.director' )
local command_mgr	= import( 'game_logic.command_mgr' )
local camera_mgr	= import( 'game_logic.camera_mgr' )
local physics		= import( 'physics.world' )
local tutor			= import( 'game_logic.tutor' )
local music_mgr		= import( 'world.music_mgr' )


function handle_operation( operations, entity, to_state )
	if operations == nil then
		return
	end
	local speed = entity:get_velocity()

	local add_to_player     = operations.add_to_player
	local hit_box 		= operations.hit_box
	local is_bati 		= operations.bati
	local is_wudi 		= operations.wudi
	local force 		= operations.force
	local impulse 		= operations.impulse
	local impulse_flipped = operations.impulse_flipped
	local gravity 		= operations.gravity
	local obstacle		= operations.obstacle
	local flipped_x 	= operations.flipped_x
	local create_obj 	= operations.create_obj
	local velocity 		= operations.velocity
	local velocity_flipped = operations.velocity_flipped
	local jump 			= operations.jump
	local cost_charge_count 	= operations.cost_charge_count
	local cost_charge_count_up	= operations.cost_charge_count_up
	local x_speed 		= operations.x_speed
	local y_speed 		= operations.y_speed
	local facing 		= operations.facing
	local stick_ctrl 	= operations.stick_ctrl
	local remove_obj 	= operations.remove_obj
	local mana_cost 	= operations.mana_cost
	local hp_cost		= operations.hp_cost
	local run_speed 	= operations.run_speed
	local transfer_to 	= operations.transfer_to
	local sound			= operations.sound
	local fix_attr		= operations.fix_attr
	local transformation	= operations.transformation
	local detransformation	= operations.detransformation
	local offset		= operations.offset
	local fade 		= operations.fade
	local event			= operations.event
	local goto_state	= operations.goto_state
	local face_target	= operations.face_target
	local anim			= operations.anim
	local bubble_dialogue_info		= operations.bubble_dialogue_info	--气泡对话
	local apply_buffs	= operations.apply_buffs
	local apply_trigger_buffs	= operations.apply_trigger_buffs
	local clear_buffs	= operations.clear_buffs
	local clear_goto_state	= operations.clear_goto_state
	local shake_scene	= operations.shake_scene						--晃动屏幕
	local turn_around	= operations.turn_around
	local speed_reverse  = operations.speed_reverse
	local jump_speed	= operations.jump_speed

	if sound ~= nil then
		music_mgr.playEffect(sound)
	end
	
	-- 计算能量值
	if mana_cost ~= nil then
		entity.combat_attr.mp = entity.combat_attr:calculate_mp(entity.combat_attr.mp,mana_cost)
		entity.mana_cost = mana_cost
	end

	if hp_cost ~= nil then
		entity.combat_attr.hp = entity.combat_attr:calculate_hp(entity.combat_attr.hp, hp_cost)
	end


	if run_speed ~= nil then
		entity.src_combat_attr:add_property('speed_x', run_speed)
		entity.combat_attr:add_property('speed_x', run_speed)
	end

	-- 受击盒
	if is_wudi == true then
		entity:set_hit_box(nil)
	elseif hit_box ~= nil then
		entity:set_hit_box(hit_box)
	end

	-- 霸体
	if is_bati ~= nil then
		entity.is_bati = is_bati
	end

	-- 加速度
	if force ~= nil then
		entity:apply_force(force[1], force[2])
	end

	-- 速度（状态）
	if velocity ~= nil then
		entity:set_velocity(velocity[1], velocity[2])
	end

	-- 速度（状态）
	if velocity_flipped ~= nil then
		if entity:is_flipped() then
			entity:set_velocity(-velocity_flipped[1], velocity_flipped[2])
		else
			entity:set_velocity(velocity_flipped[1], velocity_flipped[2])
		end
	end

	-- 速度
	if impulse ~= nil then
		entity:apply_impulse(impulse[1], impulse[2])
	end
	-- 速度
	if impulse_flipped ~= nil then
		if entity:is_flipped() then
			entity:apply_impulse(-impulse_flipped[1], impulse_flipped[2])
		else
			entity:apply_impulse(impulse_flipped[1], impulse_flipped[2])
		end
	end

	-- 重置x方向速度
	if x_speed ~= nil then
		entity:set_velocity(x_speed, speed.y)
	end

	-- 重置y方向速度
	if y_speed ~= nil then
		entity:set_velocity(speed.x, y_speed)
	end

	--xy速度倍数改变速度
	if speed_reverse ~= nil then
		entity:set_reverse(speed_reverse)
	end

	-- 重力
	if gravity ~= nil then
		entity:set_gravity(gravity)
	end

	-- 撞墙
	if obstacle ~= nil then
		entity:set_obstacle(not obstacle)
	end

	-- 减跳计数
	if jump ~= nil then
		entity:count_jump()
	end

	if cost_charge_count ~= nil then
		entity:cost_charge_count(cost_charge_count)
	end

	if cost_charge_count_up ~= nil then
		entity:cost_charge_count_up(cost_charge_count_up)
	end

	-- 翻转
	if flipped_x ~= nil then
		entity:set_force_flipped(flipped_x)
	end

	-- 创建物体
	if create_obj ~= nil then
		entity:fire_bullet(create_obj)
	end

	-- 自动面向
	if facing ~= nil then
		entity:set_facing(facing)
	end

	-- 自动面向
	if stick_ctrl == true then
		entity.stick_ctrl = stick_ctrl
	end

	-- 传送门传送
	if transfer_to ~= nil then
		if transfer_to == 'battle' then
			director.get_cur_battle().proxy.to_scene_id = entity.portal_dest
		elseif transfer_to == 'main' then
			director.get_cur_battle().proxy.to_scene_id = 'main'
		end
	end

	if fix_attr ~= nil then
		for k, v in pairs(fix_attr) do
			-- add_mp, add_hp
			if entity.combat_attr['add_' .. k] ~= nil then
				entity.combat_attr['add_' .. k]( entity.combat_attr, v )
			end
		end
	end

	-- 捡物品
	if add_to_player ~= nil then
		print(".....................add_score")
		player = director.get_cur_battle().main_player
		if(player ~= nil) then 
			for k, v in pairs(add_to_player) do
				print("here:                     ", k, "    ", v)
				if player.combat_attr['add_' .. k] ~= nil then
					player.combat_attr['add_' .. k]( player.combat_attr, v )
				end
			end
		end
	end

	if remove_obj ~= nil and remove_obj == true then
		director.get_cur_battle():remove_entity( entity.id )
	end

	if goto_state ~= nil then
		entity:goto_state(goto_state)
	end

	-- 变身
	if transformation ~= nil then
		entity:transform( transformation )
	end

	if detransformation == true then
		entity:detransform( )
	end

	if fade ~= nil then
		entity:fade(fade[1],fade[2])
	end

	if event ~= nil then
		tutor.trigger(event.name, entity.conf_id)
	end

	if face_target == true then
		entity:_face_target()
	end

	if anim ~= nil then
		entity:play_anim(anim)
	end

	if bubble_dialogue_info ~=nil then
		entity:bubble_dialogue(bubble_dialogue_info)
	end

	if apply_buffs ~= nil then
		entity.buff:apply_multi_buff( {buff_conf_id = apply_buffs}, entity, entity)
	end

	if apply_trigger_buffs ~= nil then
		entity:get_trigger_enemy().buff:apply_multi_buff( {buff_conf_id = apply_trigger_buffs}, entity, nil)
	end

	if clear_buffs ~= nil then
		entity.buff:clear_buffs()
	end

	if clear_goto_state ~= nil then
		entity:pop_goto_state()
	end

	if shake_scene ~= nil then
		director.shake_scene(shake_scene[1], shake_scene[2], shake_scene[3], shake_scene[4], shake_scene[5])
	end

	if turn_around == true then
		entity:turn_around()
	end

	-- offset
	if offset ~= nil then
		local pos = entity:get_world_pos_copy()
		camera_mgr.fix_scene_pos(pos)

		if entity:is_flipped() then
			if physics.try_horizontal_offset(-offset[1], offset[2], entity.physics.id) == false then
				pos.x = pos.x - offset[1]
				pos.y = pos.y + offset[2]
				entity:set_world_pos(pos.x, pos.y)
			end
		else
			if physics.try_horizontal_offset(offset[1], offset[2], entity.physics.id) == false then
				pos.x = pos.x + offset[1]
				pos.y = pos.y + offset[2]
				entity:set_world_pos(pos.x, pos.y)
			end
		end
	end

	if jump_speed ~= nil then
		jump_addition = entity.combat_attr:get_jump_addition()
		if jump_addition ~= nil then
			entity:set_velocity(speed.x, jump_speed + jump_addition)
		else
			entity:set_velocity(speed.x, jump_speed)
		end
	end
end

function enter_state( entity, state, state_obj )
	if entity.cur_state ~= nil then
		print('cur_state not leave', entity.cur_state, state)
	end

	local s = state_obj
	if s == nil then
		s = entity.states[state]
		if s == nil then
			print('缺少进入状态', state)
			return
		end
	end

	-- 重置属性
	entity:clear_attr()


	-- 重置状态信息
	entity:play_anim(s.anim)
	entity.cur_state = state
	entity.cur_state_obj = s

	if s.duration ~= nil then
		entity.state_duration = s.duration*FpsRate
	end
	entity:cast_skill(s.command, s.skill_id)
	--print('enter_state', entity.id, state)
	--cclog(debug.traceback())

	-- 执行进入状态操作
	handle_operation(s.enter_op, entity, state)

	local as = entity.skills[state]
	if as ~= nil then
		entity.active_skill = as
		--apply self buff
		entity.buff:apply_multi_buff( {buff_conf_id = as:get_self_buff() }, entity, entity.active_skill)
	end

	-- 执行状态同名操作
	if op_unit[state] ~= nil then
		op_unit[state](entity, state)
	end
end

function leave_current_state( entity )
	local state = entity.cur_state
	local s = entity.cur_state_obj

	-- 执行离开状态操作
	if s ~= nil then
		handle_operation(s.leave_op, entity, state)
	end

	-- 重置属性
	entity:clear_attr()
	
	entity.cur_state = nil
	entity.cur_state_obj = nil
end

function change_state( entity, to_state, state_obj )

	if entity.cur_state ~= nil then -- 当前状态已离开
		leave_current_state( entity )
	end

	--进入新状态
	enter_state( entity, to_state, state_obj )
end

function try_change_state( entity, to_state, state_obj )
	local ok = false
	for _, sname in pairs(entity:get_state_order()) do
		if type(sname) == 'table' then
			for _, name in pairs(sname) do
				if name == entity.cur_state then
					return false
				elseif name == to_state then
					ok = true
				end
			end
		else
			if sname == entity.cur_state then
				return false
			elseif sname == to_state then
				ok = true
			end
		end
		if ok then
			break
		end
	end
	change_state( entity, to_state, state_obj )
	return true
end

function try_change_state_or_reenter( entity, to_state, state_obj )
	local ok = false
	for _, sname in pairs(entity:get_state_order()) do
		if type(sname) == 'table' then
			for _, name in pairs(sname) do
				if name == to_state then
					ok = true
				elseif name == entity.cur_state then
					return false
				end
			end
		else
			if sname == to_state then
				ok = true
			elseif sname == entity.cur_state then
				return false
			end
		end
		if ok then
			break
		end
	end
	change_state( entity, to_state, state_obj )
	return true
end

-- 多个condition必须同时成立
function check_condition( entity, sname, conditions )
	if conditions == nil then
		return true
	end
	for cname, args in pairs(conditions) do
		local cond = condition[cname]
		if cond ~= nil then
			if cond(entity, sname, args) == false then
				return false
			end
		else
			print('缺少状态条件', sname, cname)
			return false
		end
	end
	return true
end

function match_state( entity, states )
	function match(sname)
		local s = entity.states[sname]
		local ok = false

		if s == nil then
			--print('缺少状态配置', sname)
			return nil
		end

		-- 判断操作控制
		ok = entity.cmd:check_command(s.command)

		-- 判断进入条件
		ok = ok and check_condition( entity, sname, s.enter_cond)

		-- 改变状态
		if ok then
			-- 吞掉当前操作
			entity.cmd:match_command(s.command)
			change_state(entity, sname)
			return true
		end
		return nil
	end
	for _, sname in pairs(states) do
		if type(sname) == 'table' then
			-- 不进入低优先级状态，继续当前状态
			if table_find(sname, entity.cur_state) ~= nil then
				-- 状态未变，时间未结束，保持状态，但需要吞掉操作
				--entity.cmd:match_command(s.command)
				return true
			end
			for _, name in pairs(sname) do
				local res = match(name)
				if res ~= nil then
					return res
				end
			end
		else
			-- 不进入低优先级状态，继续当前状态
			if entity.cur_state == sname then
				-- 状态未变，时间未结束，保持状态，但需要吞掉操作
				--entity.cmd:match_command(s.command)
				return true
			end
			local res = match(sname)
			if res ~= nil then
				return res
			end
		end
	end
	return false
end

function match_child_state( entity, states )
	for _, s in ipairs(states) do
		local ok = false

		-- 判断操作控制
		ok = entity.cmd:check_command(s.command)

		-- 判断进入条件
		ok = ok and check_condition( entity, sname, s.enter_cond)

		-- 进入子状态
		if ok then
			entity.child_state = s
			handle_operation(s.enter_op, entity, entity.cur_state)
			entity:play_anim(s.anim)
			entity.cmd:match_command(s.command)
			return true
		end
	end
	return false
end

function check_current_state( entity )
	local sname = entity.cur_state
	local s = entity.cur_state_obj
	-- 判断持续条件 与 状态时长
	return check_condition( entity, sname, s.last_cond) and entity.state_frame <= entity.state_duration
end

function tick( entity )
	if entity.states == nil or entity:get_state_order() == nil then
		return
	end

	-- 判断当前状态
	if not check_current_state( entity ) then
		leave_current_state( entity )
	end

	--强制状态切换
	local goto_state = entity:pop_goto_state()
	if goto_state ~= nil then
		change_state(entity, goto_state)
	end

	-- 尝试转移状态
	match_state(entity, entity:get_state_order())

	-- 尝试进入当前状态的子状态
	local cur_state = entity.cur_state
	local childs = entity.cur_state_obj.childs
	if childs ~= nil then
		match_child_state(entity, childs)
	end
	local ops = entity.cur_state_obj.operation
	if ops ~= nil and entity.pause_frame <= 0 and entity.state_frame%FpsRate==0 then
		local op = ops[entity.state_frame/FpsRate]
		if op ~= nil then
			handle_operation(op, entity, cur_state)
		end
	end
end

