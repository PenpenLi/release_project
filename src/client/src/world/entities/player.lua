local entity			= import( 'world.entity' )
local battle_const		= import( 'game_logic.battle_const' )
local command_mgr		= import( 'game_logic.command_mgr' )
local command			= import( 'game_logic.command' )
local cmd_handler		= import( 'game_logic.cmd_handler' )
local keyboard_cmd		= import( 'world.keyboard_cmd' )
local combat_attr 		= import( 'model.combat' )
local operate_cmd 		= import( 'ui.operate_cmd')
local skill_button 		= import( 'ui.skill_button' ) 
local director			= import( 'world.director' )
local collider			= import( 'game_logic.collider' )
local math_ext			= import( 'utils.math_ext')
local physics   	 	= import( 'physics.world')

player	= lua_class( 'player', entity.entity)

function player:_init( id, conf_id )
	super(player, self)._init(id, conf_id)
end

function player:is_player()
	return true
end

function player:init_special_attr()

	self.conf = import('char.'.. self.conf_id)
	self.battle_group = self.id
	self.del = false
	self.loaded_skills = {}
	-- self.x_speed = battle_const.RunSpeed
	-- combat 
	self.ai_hit_box_id = 0
end

function player:init_player(player)
	--[[self.combat_attr = player.final_attrs
	self.combat_attr:set_player(player)
	self.src_combat_attr:copy_from_attr(self.combat_attr)
	self.src_combat_attr:set_player(player)]]

	self.src_combat_attr = player.final_attrs
	self.src_combat_attr:set_player(player)
	self.combat_attr:copy_from_attr(self.src_combat_attr)
	self.combat_attr:set_player(player)

	self.buff = player.buff
	self.buff:bound_entity(self)
	self.buff:reshow_buff()
	--weapon
	self.char:change_equip(self.char.equip_conf.weapon, player:get_wear('weapon'))
	self.char:change_equip(self.char.equip_conf.helmet, player:get_wear('helmet'))
	self.char:change_equip(self.char.equip_conf.armor, player:get_wear('armor'))

	--skill

	local states = {}
	local orders = {}
	-- death
	states['death'] = self.conf.death
	table.insert(orders, 'death')
	skill_orders = {}
	table.insert(orders, skill_orders)
	self.pet_id = {}
	self.skill_cd = {}
	-- cast
	local skills = nil
	if player.is_candidate then
		skills = player:get_pvp_def_skills()
	else
		skills = player:get_loaded_skills()
	end
	if skills then
		for _, skill in pairs(skills) do
			if skill.data.type == EnumSkillTypes.active and skill.data.conf ~= nil then
				local name = skill:get_state_name()
				local s = skill:get_conf()
				states[name] = s
				if string.sub(self.conf_id, 1, 6) == 'tutor_' then
					-- 新手释放技能限制
					if s.enter_cond == nil then
						s.enter_cond = {}
					end
					s.enter_cond.tutor_can_releaseskill = {}
				end
				table.insert(skill_orders, name)
				self.loaded_skills[skill.id] = skill
				self.skill_cd[skill.id] = 0
				--临时增加宠物设定
				local pet_id = skill:get_pet_model()
				if pet_id ~= nil then
					table.insert(self.pet_id, pet_id)
				end
			else
			end
		end
		self.combat_attr:apply_element_def(skills)
	end

	--基础技能
	local role_type = self.conf_id
	for _, name in pairs(player.basic_skills) do
		states[name] = import('skills.'..role_type..'.'..name)[name]
		table.insert(skill_orders, name)
	end

	-- normal
	local normal_state = {'fall_ground', 'fly_hit', 'hit_fly',  'double_jump','jump', 'attack', 'hit', 'rising', 'falling', 'run', 'idle', }
	for _, name in pairs(normal_state) do
		states[name] = self.conf[name]
		table.insert(orders, name)
	end
	self.states = states
	self.state_order = orders
	self:update_skin(player)
	self:update_wing(player)
	self.can_portal = false
end

function player:update_state( base_state, append_state )
	local temp_state = table_deepcopy( base_state )
	for k, v in pairs(append_state) do
		temp_state[k] = v
	end
	return temp_state
end

function player:get_star_state( states, state_name, star, conf )
	local new_state = states[state_name]
	for i = 1, star do
		if conf['star_'..i] == nil then
			break
		end

		local get_append_state = states[conf['star_' .. i]]
		if get_append_state ~= nil then
			new_state = self: update_state( new_state, get_append_state )
		end
	end
	return new_state
end

function player:get_loaded_skills()
	return self.loaded_skills
end

function player:cast_skill( cmd, skill_id )
	local battle = director.get_cur_battle()
	if battle ~= nil then
		battle:cast_skill( cmd )
	end

	if skill_id ~= nil then
		local as =  self.loaded_skills[skill_id]
		self.skill_cd[skill_id] = self.frame_count + as:get_cd()*Fps
		self.combat_attr.mp = self.combat_attr:calculate_mp(self.combat_attr.mp, as:get_mana_cost())
		--apply self buff
		self.buff: apply_multi_buff( {buff_conf_id = as:get_self_buff() }, self, as)
		self.active_skill = as
	else
		self.active_skill = nil
	end
end

function player:ai_ctrl()
	if command_mgr.get_player_cmd() == self.cmd then
		operate_cmd.set_real_cmd(nil)
		keyboard_cmd.set_real_cmd(nil)
		command_mgr.register_player_cmd(nil)
	end
	
	self.ai = import('behavior.player_ai')
	self.ai_frequency = 2
end

function player:hand_ctrl()
	self:stop_move()
	operate_cmd.set_real_cmd(self.cmd)
	keyboard_cmd.set_real_cmd(self.cmd)
	command_mgr.register_player_cmd(self.cmd)
	
	self.ai = nil
	self.ai_frequency = 0
end

----------player ai---------------
function player:command(args)
	if command[args.cmd] == nil then
		return false
	end
	self.cmd.command[command[args.cmd]] = 2
	return true
end

function player:charge_left(args)
	self.cmd.command[command.slide_left] = 2
	return true
end

function player:charge_right(args)
	self.cmd.command[command.slide_right] = 2
	return true
end

function player:slide_up(args)
	self.cmd.command[command.slide_up] = 2
	return true
end

function player:slide_down(args)
	self.cmd.command[command.slide_down] = 2
	return true
end

function player:jump(args)
	if self.double_jump <= 0 then
		return false
	end
	self.cmd.command[command.touch_right] = 2
	return true
end

function player:enough_mana(args)
	return args.mp ~= nil and self.combat_attr.mp >= args.mp
end

function player:_enough_mana(mp)
	return self.combat_attr.mp >= mp
end

function player:enemy_in_box_flipped(args)
	if self.nearest_enemy == nil then
		return false
	end
	local hit_box = self.nearest_enemy:get_world_hit_box()
	local pos = self:get_world_pos()
	local flipped = self:is_flipped()
	local real_box = math_ext.fix_box(args, pos, flipped)
	for i, box in pairs(hit_box) do
		local enemy_pos = {x=(box[1]+box[3])/2,y=(box[2]+box[4])/2}
		if collider.in_box(enemy_pos, real_box) then
			self.ai_hit_box_id = i
			return true
		end
	end
	return false
end

function player:enemy_in_box(args)
	if self.nearest_enemy == nil then
		return false
	end
	local hit_box = self.nearest_enemy:get_world_hit_box()
	local pos = self:get_world_pos()
	local real_box = math_ext.fix_box(args, pos)
	for i, box in pairs(hit_box) do
		local enemy_pos = {x=(box[1]+box[3])/2,y=(box[2]+box[4])/2}
		if collider.in_box(enemy_pos, real_box) then
			self.ai_hit_box_id = i
			return true
		end
	end
	return false
end

function player:platforms_in_box( args )
	local ps = physics.get_platforms()
	if ps == nil then return false end

	local pos = self:get_world_pos()
	local flipped = self:is_flipped()
	local real_box = math_ext.fix_box(args, pos, flipped)

	for _, p in pairs(ps) do
		if p:get_is_ground() == nil then
			local x1 = p.pos1.x
			local x2 = p.pos2.x
			local y1 = p.pos1.y

			if collider.check_collide({x1, y1, x2, y1}, {real_box}) then
				return true
			end
		end
	end

	return false
end

function player:check_platform_enemy( args )
	local e = self.nearest_enemy
	if e == nil then return false end

	local standing = self.physics.standing
	local e_standing = e.physics.standing

	if standing == e_standing then return true end
	return false
end

function player:move_to_target(args)
	if self.nearest_enemy == nil then
		self.cmd.direction = command.none
		return false
	end

	local enemy_pos = self.nearest_enemy:get_world_pos()
	local pos = self:get_world_pos()
	local hit_box = self.nearest_enemy:get_world_hit_box()
	if hit_box ~= nil and hit_box[self.ai_hit_box_id] ~= nil then
		local box = hit_box[self.ai_hit_box_id]
		enemy_pos = {x=(box[1]+box[3])/2,y=(box[2]+box[4])/2}
	end

	if math.abs(enemy_pos.x - pos.x) < args.distance_max then
		self:face_target(args)
		self.cmd.direction = command.none
		return true
	else
		if enemy_pos.x < pos.x then
			self:face_target(args)
			self.cmd.direction = command.stick_left
		else
			self:face_target(args)
			self.cmd.direction = command.stick_right
		end
	end

	return false
end

function player:check_difference_ground( args )

	local e = self.nearest_enemy
	if e == nil then return false end

	local e_standing = e.physics.standing
	if e_standing == 0 then return false end

	local standing = self.physics.standing
	if standing == 0 then return false end

	if standing == e_standing then return false end

	if e:get_world_pos().y - self:get_world_pos().y >= 5 then return false end

	local p = physics.get_platform_by_standing(standing)
	if p == nil then return false end

	if p:get_is_ground() then return false end

	return true
end

function player:escape_platform( args )

	local standing = self.physics.standing
	if standing == 0 then return false end

	local p = physics.get_platform_by_standing(standing)
	if p == nil then return false end

	local x1 = p.pos1.x
	local x2 = p.pos2.x

	local pos_x = self:get_world_pos().x

	if x2-pos_x >= pos_x-x1 then
		-- left
		return false
	else
		return true
	end
end

function player:move_to_right( args )
	self:face_target(args)
	self.cmd.direction = command.stick_right
	return true
end

function player:move_to_left( args )
	self:face_target(args)
	self.cmd.direction = command.stick_left
	return true
end

function player:try_cast_skill(args)
	local cs
	local score = 0
	for id, s in pairs(self:get_loaded_skills()) do
		if self:_enough_mana(s:get_mana_cost()) and self.skill_cd[s.id] < self.frame_count then
			local ai_area = s:get_ai_area()
			if ai_area == nil or self:enemy_in_box_flipped(ai_area) then
				setfenv(s:get_ai_score_formula(), {a=self.combat_attr, s=s})()
				local new_score = s._ai_score
				print(s.id, new_score)
				if new_score > score then
					cs = s
					score = new_score
				end
			end
		end
	end
	if cs == nil then
		return false
	end
	self.cmd.command[cs:get_command()] = 2
	return true
end

function player:move_to_portal(args)
	if self.can_portal == false then
		return false
	end
	self.cmd.direction = command.stick_right
	return false
end

function player:stop_move(args)
	self.cmd.direction = command.none
	return false
end