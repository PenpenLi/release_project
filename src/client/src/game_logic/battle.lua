local collider			= import( 'game_logic.collider' )
local state_mgr			= import( 'game_logic.state_mgr' )
local camera_mgr		= import( 'game_logic.camera_mgr' )
local command_mgr		= import( 'game_logic.command_mgr' )
local cmd_handler		= import( 'game_logic.cmd_handler' )
local command			= import( 'game_logic.command' )
local ai				= import( 'game_logic.ai' )
local battle_const		= import( 'game_logic.battle_const' )
local tutor				= import( 'game_logic.tutor' )
local music_mgr			= import( 'world.music_mgr' )
local director			= import( 'world.director')
local keyboard_cmd		= import( 'world.keyboard_cmd' )
local model 			= import( 'model.interface' )
local combat_attr 		= import( 'model.combat' )
local operate_cmd 		= import( 'ui.operate_cmd')
local ui_touch_layer	= import( 'ui.ui_touch_layer' )
local boss_hp 			= import( 'ui.boss_hp')
local ui_mgr 			= import( 'ui.ui_mgr' )
local skill_button 		= import( 'ui.skill_button' ) 
local physics   	 	= import( 'physics.world')
local math_ext			= import( 'utils.math_ext')
local timer 			= import( 'utils.timer' )
local trigger_mgr 		= import( 'game_logic.trigger_mgr')


battle = lua_class( 'battle' )

NeutralityGroup = 0
PetConfID = 13
AiFrequency = 60

function battle:_init( id, proxy )
	self.id = id
	self.proxy = proxy
	self.data = data.fuben[id]
	self.scene_data = data.scene[self.data.scene_id]
	self.entities = {}
	if self.data.ai_conf ~= nil then
		self.ai = import('behavior.'.. self.data.ai_conf)
	end
	self.id_counter = 0
	self.main_player = nil
	self.players = {}
	-- 场景 ai fuben_test
	self.blackboard = {}
	self.debug_ai = DebugSceneAi
	self.ai_frame = 1
	self.frame_count = 1
	self.ground_height = 0

	camera_mgr.set_bound(self.scene_data.width, self.scene_data.height)
	self.proxy:play_bg_music()

	self.player_fc = model.get_player():get_final_attrs():get_fighting_capacity()


end

function battle:grab_id()
	self.id_counter = self.id_counter + 1
	return self.id_counter
end

function battle:begin()
	-- 物理，战斗设置
	_extend.set_seed(os.time())
	physics.init()
	self.ground_height = self.proxy:create_physics_world(self.scene_data)

	-- 创建玩家
	local tmp_id = self:grab_id()
	local born_pos = self.scene_data.born_pos
	local player = model.get_player()
	local e = self:create_player(tmp_id, player)
	state_mgr.enter_state(e, 'idle')
	e:set_world_pos(born_pos[1], born_pos[2])
	self.entities[tmp_id] = e
	self.players[tmp_id] = e
	self.main_player = e
	self.proxy:set_real_cmd(self.main_player.cmd)
	camera_mgr.set_player(e)
	skill_button.set_player(e)
	command_mgr.register_player_cmd(e.cmd)
	operate_cmd.set_real_cmd(e.cmd)
	keyboard_cmd.set_real_cmd(e.cmd)

	--e:ai_ctrl()

	-- 每个副本第一关，重置玩家属性
	if data.fuben_entrance[self.data.chapter_id][self.data.instance_id] == self.id then
		e.combat_attr:reset_relive( e )
	end

	-- 宠物
	for _, pet_id in pairs(e.pet_id) do
		local pet = self:create_monster({type='pet',id=pet_id,pos={200,200},gravity=false,no_obstacle=true})
		pet.combat_attr:copy_from_attr( e.combat_attr )
	end

	-- 怪物出来
	self:create_scene_object()

	-- 场景buff出来
	self:create_scene_buff()

	-- 开场对话
	if self.data.begin_dialog ~= nil and player:get_fuben() < self.id then
		self.proxy: start_dialog( self.data.begin_dialog )
	end
	-- tutor.trigger('enter_scene')
	local is_auto = self.proxy:get_is_auto()

	self:set_auto_battle(is_auto)
	self.proxy:hide_go_icon()
	self.proxy:add_fuben_cnt()
end

function battle:release()
	--self.main_player.buff:clear_buffs()
	local e = self.main_player
	e.src_combat_attr.hp = e.combat_attr.hp
	e.src_combat_attr.mp = e.combat_attr.mp
end

function battle:create_player(tmp_id, player)
	local e = self.proxy:create_avatar(tmp_id, {type = 'player', role_type = player.role_type} )
	e:init_player(player)
	return e
end

function battle:create_scene_object()
	local objects = ccexp.TMXTiledMap:create( self.data.object_conf ):getObjectGroup( "object" )
	if objects == nil then
		return
	end
	for _, obj in ipairs(objects:getObjects()) do
		local conf_id = tonumber(obj.type)
		if obj.monster_id == nil then
			conf_id = conf_id*1000 + self.data.monster_level
		end
		if obj.dest == nil then
			self:create_monster({conf_id=conf_id,battle_group=tonumber(obj.group),pos={obj.x,obj.y}}) 
		else
			self:create_monster({conf_id=conf_id,battle_group=tonumber(obj.group),pos={obj.x,obj.y},gravity=false,dest=obj.dest}) 
		end
	end
end

function battle:create_scene_buff()
	local objects = ccexp.TMXTiledMap:create( self.data.object_conf ):getObjectGroup( "buff" )
	if objects == nil then
		return
	end
	for _, obj in ipairs(objects:getObjects()) do
		local conf_id = tonumber(obj.type)
		if obj.dest == nil then
			self:create_monster({conf_id=100051,battle_group=tonumber(obj.group),pos={obj.x,obj.y},scenebuff_id = conf_id}) 
		else
			self:create_monster({conf_id=100051,battle_group=tonumber(obj.group),pos={obj.x,obj.y},scenebuff_id = conf_id,gravity=false,dest=obj.dest}) 
		end
	end
end

function battle:set_ground(height)
	self.ground_height = height
end

function battle:get_ground()
	return self.ground_height
end

function battle:get_ai()
	return self.ai
end

function battle:tick_ai()
	self.frame_count = self.frame_count + 1
	if self.frame_count > self.ai_frame then
		ai.tick(self)
		self.ai_frame = self.frame_count + AiFrequency
	end
end

---------------ai相关开始---------------------

-- 返回有多少个怪物, 参数输入怪物阵营 主角=1 怪物=2or3 基地=-1 , 剔除了子弹
function battle:count_entity( args )
	-- args.group
	local sum = 0
	local group = args.group

	for i, e in pairs(self.entities) do
		for _, g in pairs(group) do
			if e.battle_group == g and e:is_bullet() == false then
				sum = sum + 1
				break
			end
		end
	end
	return sum
end

function battle:check_entity_count( args )
	local cnt = 0
	for id, e in pairs(self.entities) do
		local flag = true
		local conf_id = args.conf_id
		local types = args.types
		local battle_group = args.battle_group
		if types ~= nil then
			flag = false
			for _, type_id in pairs(types) do
				if type_id == e.type_id then
					flag = true
				end
			end
		end
		if conf_id ~= nil and e.conf_id ~= conf_id then
			flag = false
		end
		if battle_group ~= nil and e.battle_group ~= battle_group then
			flag = false
		end
		if e.combat_attr.hp == 0 then
			flag = false
		end
		if flag then
			cnt = cnt + 1
		end
	end
	local max = args.max
	if max ~= nil and cnt > max then
		return false
	end
	local min = args.min
	if min ~= nil and cnt < min then
		return false
	end
	return true
end

function battle:create_monster( args )
	-- args: id, pos{}, duration(ttl), attack_times, flipped, limit
	if args.type == nil and data.monster[args.conf_id] == nil then
		print('不存在的怪物ID:', args.conf_id, '副本ID:', self.id)
		return
	end
	-- 超出边界
	args.pos = args.pos or {0, 0}
	if args.ground == true then
		args.pos[2] = self.ground_height
	end

	local function fix_bound(pos, cur_battle)
		if pos[1] < 1 then
			pos[1] = 1
		end
		if pos[2] < 1 then
			pos[2] = 200 
		end
		if pos[1] > cur_battle.scene_data.width then
			pos[1] = cur_battle.scene_data.width - 100
		end
	end
	fix_bound(args.pos, self)

	local tmp_id = self:grab_id()
	local e = self.proxy:create_avatar(tmp_id, args)
	self.entities[tmp_id] = e

	--生存时间
	e.timetolive = args.duration

	--攻击次数
	e.attack_times = args.attack_times

	--传送门目的地
	e.portal_dest = args.portal_dest

	if args.dest_offset ~= nil then
 		e:set_dest_offset(args.dest_offset)
 	end

	--判断是否开启
	if args.is_follow ~= nil and args.is_follow ~= 0 then
		e:set_bullet_speed(args.fly_speed)
		e:set_follow_rate(args.is_follow_rate)
 		e:set_follow(args.is_follow)
 	end

 	--重力设置
	if args.gravity ~= nil then
		if args.gravity == false then
			e:set_gravity(0)
		elseif args.gravity == true then
			e:set_gravity(1)
		else
			e:set_gravity(args.gravity)
		end
	end

	--是否检测平台碰撞
	if args.no_obstacle ~= nil then
		e.physics.no_obstacle = args.no_obstacle
	end

	--发射位置
	e:set_world_pos(args.pos[1], args.pos[2])

	--初始进入状态
	state_mgr.enter_state(e, 'idle')

	--翻转
	e:set_force_flipped(args.set_flipped)

	--阵营
	if args.battle_group ~= nil then
		e.battle_group = args.battle_group
	end

	--初始速度
	if args.velocity ~= nil then
		--TODO: deprecated
		if args.set_flipped == true then
			e:set_velocity(-args.velocity[1],args.velocity[2])
		else
			e:set_velocity(args.velocity[1],args.velocity[2])
		end
	elseif args.fly_speed ~= nil then
		if args.set_flipped == true then
			e:set_velocity(-args.fly_speed, 0)
		else
			e:set_velocity(args.fly_speed, 0)
		end
	end

	--旋转
	if args.all_angle == true then
		e.all_angle = true
		-- init velocity
		if args.dest_pos ~= nil then
			local self_pos = {}
			self_pos[1], self_pos[2] = e.physics:get_pos()
			
			local width = args.dest_pos[1] - self_pos[1]
			local height = args.dest_pos[2] - self_pos[2]
			local distance = math.sqrt(width^2 + height^2)
			args.fly_speed = args.fly_speed or 1
			local t = distance / args.fly_speed
			if t ~= 0 then
				e:set_velocity( width / t, height / t )
			end
		end
	end

	--继承战斗属性
	if args.combat_attr ~= nil then
		-- e.combat_attr = args.combat_attr
		e.combat_attr:copy_from_attr( args.combat_attr )
	end

	--飞行单位就保存高度，设置不受重力
	if e.conf.is_air_monster == true then
		e:set_gravity(0)
		e:preserve_start_pos_width_hight( args.pos[1],args.pos[2] )
		e:set_obstacle(true)
	end
	physics.move_rigid(e.physics.id)
	return e
end

function battle:portal_to_next( args )
	local function end_dialog_cb()
		if self.data.next_barrier then
			args.portal_dest = self.data.next_barrier
			if self.main_player ~= nil then
				--local player_pos = self.main_player: get_world_pos()
				args.pos = {}
				args.pos[1] = 1000000
				args.pos[2] = args.offset[2] - 90
			end
			self.proxy:show_go_icon()
			self.main_player.can_portal = true
			return self:create_monster( args )
		end
	end

	if self.data.end_dialog ~= nil and model.get_player():get_fuben() < self.id then
		self.proxy: start_dialog( self.data.end_dialog, end_dialog_cb )
		return true
	else
		return end_dialog_cb()
	end
end

function battle:portal_to_main( args )
	local function end_dialog_cb()
		if self.main_player ~= nil then
		--	local player_pos = self.main_player: get_world_pos()
			args.pos = {}
			args.pos[1] = 1000000
			args.pos[2] = args.offset[2] - 90
		end
		self.proxy:show_go_icon()
		return self:create_monster( args )
	end

	if self.data.end_dialog ~= nil and model.get_player():get_fuben() < self.id then
		self.proxy: start_dialog( self.data.end_dialog, end_dialog_cb )
		return true
	else
		return end_dialog_cb()
	end
end

function battle:remove_entities_by_confid( conf_id )
	for k, v in pairs(self.entities) do
		if v.conf_id == conf_id then
			self.entities[k]:pre_release()
		end
	end
end

function battle:remove_entity( entity_id )
	print('remove id:', entity_id)
	self.entities[ entity_id ]:pre_release()
	return true
end

function battle:player_dead( args )
	if self.main_player ~= nil and self.main_player.combat_attr.hp <= 0 then
		return true
	else
		return false
	end
end

function battle:change_scene( args )
	self.proxy.to_scene_id = args.scene_id
	return true
end

function battle:in_scene_id( args )
	local flag = false
	for _, i in ipairs(args.ids) do
		if self.data.scene_id == i then
			flag = true
			break
		end
	end
	return flag
end

function battle:in_scene_id_scale( args )
	local max = args.max
	if max ~= nil and self.data.scene_id > max then
		return false
	end
	local min = args.min
	if min ~= nil and self.data.scene_id < min then
		return false
	end
	return true
end

function battle:show_victory_callback( args )
	local status = {star=3}
	local player = model.get_player()
	director.get_scene():pause()
	operate_cmd.enable(false)
	status.ft = tonumber(cc.UserDefault:getInstance():getStringForKey('battle_token'))
	self.player_bef_lv = player:get_level()
	server.battle_finish(self.id, status)
	local attr = player:get_attr()
	self.player_bef_att = attr:get_attack()
	self.player_bef_def = attr:get_defense()
	self.player_bef_cri = attr:get_crit_level()
	self.player_bef_hp = attr:get_max_hp()

	--技能信息
	local cast_skill = model.get_player():get_loaded_skills()  --装备的技能
	self.player_bef_skills = {}
	for idx = 1, 3 do
		local sk = cast_skill[idx]
		if sk ~= nil then
			self.player_bef_skills[idx] = sk.lv
		end

	end

	-- director.get_scene():pause()
	self.proxy:down_battle_ui()
	director.show_loading()
	music_mgr.stop_bg_music()
	music_mgr.victory_music()
	return true
end

function battle:show_victory( args )
	local function end_dialog_cb()
		self:show_victory_callback(args)
	end
	if self.data.end_dialog ~= nil and model.get_player():get_fuben() < self.id then
		self.proxy: start_dialog( self.data.end_dialog, end_dialog_cb )
	else
		end_dialog_cb()
	end
end

function battle:victory( items )

	local account_data = {
		bef_lv	= self.player_bef_lv,
		bef_att = self.player_bef_att,
		bef_def = self.player_bef_def,
		bef_crit = self.player_bef_cri,
		bef_hp = self.player_bef_hp,
		bef_skills = self.player_bef_skills,
		gold = self.data.gold,
		diamond = self.data.diamond,
		gain_exp = self.data.exp,
		soul_exp = self.data.soul_exp,
		items = items,
	}  --									获得副本经验	之前的人物经验		魔灵经验

	self.proxy:show_victory( account_data )
	--gold,diamond,gain_exp,cur_exp,need_exp,soul_exp ,items
end

function battle:show_defeated( args )
	--显示失败界面
	if self.proxy.d_layer.defeated_count < 1 then
		self.proxy.d_layer.defeated_count=1
		local function callback(  )
			operate_cmd.enable(false)

			if self.proxy.ui_layer.boss_hp.imgbg:isVisible() then
				self.proxy.ui_layer:play_action("Ui_Battle_BossBlood.ExportJson", "down")
			end

			self.proxy:down_battle_ui()
			director.get_scene():pause()
			self.proxy.ui_layer:play_action('Ui_Black.ExportJson','up')
			self.proxy.ui_layer:play_action('Ui_D.ExportJson','up')
			
			self.proxy.d_layer.cc:setVisible(true)
			-- music_mgr.stop_bg_music()
			music_mgr.pause_bg_music()
			music_mgr.fail_music()
		end
		timer.set_timer(1,callback)
		return true
	end
	return false
end

function battle:enter_battle_show( )
	-- 新手引导用
	return true
end

---------------ai相关结束---------------------
-- 判断阵营关系
function battle:check_group_relation( att_group,hit_group ) -- 敌对return true

	local table = data.fuben[self.id].group_relation

	if table == nil then
		if att_group ~= hit_group then
			return true
		else
			return false
		end
	end

	-- group_relation={[1]={[2]=2, [3]=3}, [2]={[-1]=-1, [1]=1}, [3]={[-1]=-1}}
	if table[att_group] and table[att_group][hit_group] == hit_group then
		return true
	else
		return false
	end
end

-- 更新玩家面向
function battle:update_player_face(  )
	for id, player in pairs(self.players) do
		local target_enemy = nil
		local face_direction = nil
		local moving_direction = player.moving_direction
		local att_pos = player:get_world_pos()
		for hit_id, hit_e in pairs(self.entities) do
			local hit_group = hit_e:get_battle_group()
			local hit_box = hit_e:get_world_hit_box()
			-- if hit_group ~= NeutralityGroup and hit_group ~= player:get_battle_group() and hit_box ~= nil then
			if hit_group ~= NeutralityGroup and self:check_group_relation(player:get_battle_group(), hit_group) and hit_box ~= nil then
				local hit_pos = hit_e:get_world_pos()
				local enemy_direction = collider.check_attack_side(att_pos, hit_box, hit_pos, hit_e:on_ground(), player.auto_face_direction)
				if enemy_direction ~= nil and (target_enemy == nil or moving_direction == enemy_direction) then
					target_enemy = hit_e
					face_direction = enemy_direction
				end
			end
		end
		player.target_enemy = target_enemy
		player.auto_face_direction = face_direction
		if target_enemy ~= nil then
			player.enemy_in_range = true
		else
			player.enemy_in_range = false
		end
	end
end

-- 更新最近敌人
function battle:update_nearest_enemy(  )
	for att_id, att_e in pairs(self.entities) do
		local att_group = att_e:get_battle_group()
		local att_pos = att_e:get_world_pos()
		att_e.nearest_enemy = nil
		att_e.in_battle_enemy = nil
		local min_distance = nil
		if att_group ~= NeutralityGroup then
			for hit_id, hit_e in pairs(self.entities) do
				local hit_group = hit_e:get_battle_group()
				local hit_pos = hit_e:get_world_pos()
				local hit_box = hit_e:get_world_hit_box()
				-- if hit_group ~= NeutralityGroup and hit_group ~= att_group and hit_box ~= nil then
				if hit_group ~= NeutralityGroup and self:check_group_relation(att_group, hit_group) and hit_box ~= nil and att_e:is_same_platform( hit_e ) then
					local distance = math_ext.p_get_distance(att_pos, hit_pos)
					if min_distance == nil or distance < min_distance then
						min_distance = distance
						att_e.in_battle_enemy = hit_e
						att_e.nearest_enemy = hit_e
					end
				end
			end
		end
	end
end

-- 改变被击entity的状态
function battle:try_change_all_state_or_reenter( hit_e, hit_state, y_speed_flag )
	local hit_attr = hit_e.combat_attr
	if hit_e.hit and hit_e.combat_attr.is_force_bati == 0 then
		if hit_e.is_bati ~= true then
			if hit_attr.hp == 0 then
				hit_e.buff:clear_buffs()
				state_mgr.change_state(hit_e, 'death')
			elseif hit_state ~= nil then
				--强制受击状态
				hit_e:hit_red_body()
				state_mgr.change_state(hit_e, 'hit', hit_state)
			elseif hit_e:on_ground() and y_speed_flag == true and hit_e:has_state('hit_fly') then
				--击飞
				hit_e:hit_red_body()
				state_mgr.try_change_state_or_reenter(hit_e, 'hit_fly')
			elseif not hit_e:on_ground() and hit_e:has_state('fly_hit') and y_speed_flag == true then
				--浮空受击
				hit_e:hit_red_body()
				state_mgr.try_change_state_or_reenter(hit_e, 'fly_hit')
			else
				--普通受击
				hit_e:hit_red_body()
				state_mgr.try_change_state_or_reenter(hit_e, 'hit')
			end
		else
			hit_e:hit_red_body()
		end
		hit_e.hit = false
	end
end

function battle:attack(att_e, hit_e, hit_box_id)
	-- print('attack', att_e.id, hit_e.id)
	local att_info = att_e.attack_info

	local skill = att_info.skill
	local pause = att_info.att_pause
	local force = att_info.force

	local impulse = att_info.impulse
	local impulse_flipped = att_info.impulse_flipped
	local impulse_away = att_info.impulse_away

	local velocity = att_info.velocity
	local velocity_flipped = att_info.velocity_flipped
	local velocity_away = att_info.velocity_away
	
	local gravity = att_info.gravity
	local hit_state = att_info.hit_state
	local att_state = att_info.att_state
	local mana_gain = att_info.mana_gain
	local inherit_speed = att_info.inherit_speed
	local apply_buff = att_info.apply_buff
	local damage_factor = att_info.damage_factor
	local collider_shake = att_info.collider_shake -- 晃动场景

	if att_state ~= nil then
		att_e:goto_state(att_state)
		return
	end
	if att_e.attack_times ~= nil then
		if att_e.attack_times ~= 0 then
			att_e.attack_times = att_e.attack_times - 1
		else
			return
		end
	end

	if apply_buff ~= nil then
		hit_e.buff:apply_multi_buff( apply_buff, att_e, skill )
	end

	-- 战斗结算 开始

	local att_attr = att_e.combat_attr
	local hit_attr = hit_e.combat_attr
	local formula = battle_const.BasicFormula
	if skill ~= nil then
		formula = skill:get_formula()
	end

	local temp_rand = _extend.random(100)
	local crit_flag = false
	function try_crit(rate)
		if rate == nil then
			rate = 0
		end

		if temp_rand <= ((att_attr.crit_rate+rate) * 100) then
			crit_flag = true
			return 1
		else
			crit_flag = false
			return 0
		end
	end

	local env = {
		a = att_attr,
		b = hit_attr,
		s = skill,
		crit = try_crit,
		rand = temp_rand,
		print = print,
		dir = dir,
	}
	setfenv(formula,env)()
	if damage_factor ~= nil then
		env.d = env.d * damage_factor
	end

	local zhanli = self.player_fc
	local fuben_zhanli = self.data.fighting_capability or 0
	if fuben_zhanli > zhanli then
		if att_e:get_battle_group() == self.main_player:get_battle_group() then
			env.d = env.d * zhanli / fuben_zhanli
		else
			env.d = env.d * fuben_zhanli / zhanli
		end
	end

	env.d = math.floor(env.d) -- 掉血取整

	hit_attr:verify()
	att_attr:verify()

	att_e.crit_flag = crit_flag

	
	-- 结算
	local cur_att_e_state= att_e.states[att_e.cur_state]
	local combat_damage = {is_crit = crit_flag, total = env.d}
	-- hit_attr:sub_hp(combat_damage.total)
	-- att_attr:add_hp(combat_damage.total * att_attr.take_hp)
	hit_attr:add_property('hp', -combat_damage.total)
	att_attr:add_property('hp', combat_damage.total * att_attr.take_hp)
	--TODO: for debug 战斗数据统计
	if hit_e.conf.show_damage_data == true then
		hit_e.damage_stat = hit_e.damage_stat or {}
		local state_stat = hit_e.damage_stat[att_e.cur_state]
		if state_stat == nil then
			state_stat = {}
			state_stat.count = 0
			state_stat.damage = 0
			state_stat.crit_count = 0
			hit_e.damage_stat[att_e.cur_state] = state_stat
		end
		if combat_damage.is_crit then
			state_stat.crit_count = state_stat.crit_count + 1
		end
		state_stat.damage = state_stat.damage + combat_damage.total
		state_stat.count = state_stat.count + 1
		--[[
		print('att:' .. att_e.id .. ' hit:' .. hit_e.id, att_e.cur_state .. '伤害值：', combat_damage.total)
		for k, v in pairs(hit_e.damage_stat) do
			print('\t累计'.. k .. '造成伤害：', v.damage)
		end
		--]]
	end
	-- 战斗结算 结束

	hit_e.in_battle = true

	-- 飘字特效
	local eff_type							-- 飘字类型（颜色）
	if hit_e.battle_group == 1 or hit_e.battle_group == -1 then
		eff_type = 4 						-- 主角 和 基地
	else eff_type = 2 						-- 怪物
	end

	local att_pos = att_e:get_world_pos()
	local hit_pos = hit_e:get_world_pos()
	local hit_box = hit_e:get_world_hit_box()
	local hit_box_x = (hit_box[hit_box_id][1] + hit_box[hit_box_id][3])/2
	
	local _direction = 0					-- 飘字方向
	local abs_x = att_pos.x - hit_box_x		-- x方向距离
	if abs_x > 0 then
		_direction = -1
	else
		-- abs_x = - abs_x
		_direction = 1
	end

	local eff_table = {type=eff_type, pos={x=hit_box_x, y=hit_box[hit_box_id][2]}, direction = _direction, damage=combat_damage}
	self.proxy:show_damage_effect(eff_table)

	-- 晃动场景
	if collider_shake ~= nil then
		dir(collider_shake)
		if _direction > 0 then
			-- print('shake_right')
			director.shake_right(collider_shake[1], collider_shake[2], collider_shake[3], collider_shake[4], collider_shake[5])
		else
			-- print('shake_left')
			director.shake_left(collider_shake[1], collider_shake[2], collider_shake[3], collider_shake[4], collider_shake[5])
		end
	end

	-- 刀光 start mao
	local real_att_box = math_ext.fix_box(att_info.attack_box, att_e:get_world_pos(), att_e:is_flipped())
	local temp_scale = math.random(80) / 100 + 0.6 
	self.proxy:flash(real_att_box, hit_box[hit_box_id], temp_scale, 5)
	-- 刀光 end

	hit_e.hit = true

	if skill ~= nil then
		--apply enemy buff
		hit_e.buff: apply_multi_buff( {buff_conf_id = skill:get_enemy_buff()}, att_e, skill)
	end

	if mana_gain ~= nil and hit_e.hit then
		-- att_e.combat_attr:add_mp( mana_gain )
		-- att_e.combat_attr.mp = att_e.combat_attr.mp + mana_gain
		att_e.combat_attr:add_property('mp', mana_gain )
	end

	if combat_damage.is_crit then
		director.fast_zoom()
	end

	if pause ~= nil and hit_e.hit then
		att_e:pause(pause)
		--hit_e:pause(pause)
	end

	local y_speed_flag = false
	if hit_e.is_bati ~= true and hit_e.combat_attr.is_force_bati == 0 then
		--hit_e:set_velocity(0,0)--先减速
		if force ~= nil and (hit_e.conf.is_air_monster ~= true or force[2] <= 0) then
			hit_e:apply_force(force[1], force[2])
			if force[2] > battle_const.FallGroundYSpeed then
				y_speed_flag = true
			end
		end

		if impulse ~= nil and (hit_e.conf.is_air_monster ~= true or impulse[2] <= 0) then
			hit_e:apply_impulse(impulse[1], impulse[2])
			if impulse[2] > battle_const.FallGroundYSpeed then
				y_speed_flag = true
			end
		end

		if impulse_flipped ~= nil and (hit_e.conf.is_air_monster ~= true or impulse_flipped[2] <= 0) then
			if att_e:is_flipped() then
				hit_e:apply_impulse(-impulse_flipped[1], impulse_flipped[2])
			else
				hit_e:apply_impulse(impulse_flipped[1], impulse_flipped[2])
			end
			if impulse_flipped[2] > battle_const.FallGroundYSpeed then
				y_speed_flag = true
			end
		end

		if impulse_away ~= nil and (hit_e.conf.is_air_monster ~= true or impulse_away[2] <= 0) then
			local dir = (hit_pos.x - att_pos.x)/math.abs(hit_pos.x - att_pos.x)
			if hit_pos.x == att_pos.x then
				dir = 0
			end
			hit_e:apply_impulse(impulse_away[1]*dir, impulse_away[2])
			if impulse_away[2] > battle_const.FallGroundYSpeed then
				y_speed_flag = true
			end
		end

		if velocity ~= nil and (hit_e.conf.is_air_monster ~= true or velocity[2] <= 0) then
			hit_e:set_velocity(velocity[1], velocity[2])
			if velocity[2] > battle_const.FallGroundYSpeed then
				y_speed_flag = true
			end
		end

		if velocity_flipped ~= nil and (hit_e.conf.is_air_monster ~= true or velocity_flipped[2] <= 0) then
			if att_e:is_flipped() then
				hit_e:set_velocity(-velocity_flipped[1], velocity_flipped[2])
			else
				hit_e:set_velocity(velocity_flipped[1], velocity_flipped[2])
			end
			if velocity_flipped[2] > battle_const.FallGroundYSpeed then
				y_speed_flag = true
			end
		end
		if velocity_away ~= nil and (hit_e.conf.is_air_monster ~= true or velocity_away[2] <= 0) then
			local dir = (hit_pos.x - att_pos.x)/math.abs(hit_pos.x - att_pos.x)
			if hit_pos.x == att_pos.x then
				dir = 0
			end
			hit_e:set_velocity(velocity_away[1]*dir, velocity_away[2])
			if velocity_away[2] > battle_const.FallGroundYSpeed then
				y_speed_flag = true
			end
		end

		--攻击继承速度
		--飞行怪不继承 y>0 的速度
		if hit_e.hit == true and inherit_speed == true then
			att_e.inherit_speed = true
			local att_x_speed = att_e.velocity.x
			local att_y_speed = att_e.velocity.y
			if hit_e.conf.is_air_monster ~= true or att_y_speed <= 0 then
			 	hit_e:set_velocity(att_x_speed, att_y_speed)
			end

			if att_y_speed > battle_const.FallGroundYSpeed then
				y_speed_flag = true
			end
		end
	end

	-- 改变状态
	self:try_change_all_state_or_reenter(hit_e, hit_state, y_speed_flag)

	--触发事件
	if att_e.attack_info ~= nil and att_e.attack_info.trigger ~= nil then
		trigger_mgr.try_trigger(self, att_e, hit_e)
	end
end

function battle:special_tick()
end

-- TODO: need optimize
function battle:tick()
	physics.tick()
	for id, e in pairs(self.entities) do
		e:update_physics_info()
	end

	--更新场景ai
	self:tick_ai()
	self:special_tick()

	--更新玩家面向控制
	self:update_player_face()

	-- 更新最近敌人
	self:update_nearest_enemy()

	for id, e in pairs(self.entities) do
		e:update_before_state_tick()
		e.buff:tick()
		state_mgr.tick(e)
		e:update_after_state_tick()
	end

	local function check_attack(att_e, hit_id)
		local hit_frame = att_e.hit_entities[hit_id]
		local interval = 20
		local info = att_e.attack_info
		if info.interval ~= nil then
			interval = info.interval * 2
		end
		return hit_frame == nil or self.frame_count - hit_frame > interval
	end

	-- 需要被更新血量条的怪物对象
	local ui_hp_target = nil
	--攻击判定
	for att_id, att_e in pairs(self.entities) do

		if att_e.pause_frame <= 0 then
		local info = att_e.attack_info
		if info ~= nil then
		local att_count_sum = info.count -- 获取一帧砍敌人数目
		att_count_sum = att_count_sum or battle_const.AttackCount
		local att_count_now = 0
		local att_box = info.attack_box
		if att_box ~= nil then
			local real_att_box = math_ext.fix_box(att_box, att_e:get_world_pos(), att_e:is_flipped())
			for hit_id, hit_e in pairs(self.entities) do
				-- if att_id ~= hit_id and att_e.battle_group ~= hit_e.battle_group and hit_e.pause_frame <= 0 and check_attack(att_e, hit_id) then
				if att_id ~= hit_id and self:check_group_relation(att_e.battle_group, hit_e.battle_group) --[[and hit_e.pause_frame <= 0]] and check_attack(att_e, hit_id) and att_e:is_same_platform( hit_e ) then
				local real_hit_box = hit_e:get_world_hit_box()
				local hit_box_id = collider.check_collide(real_att_box, real_hit_box)
				if hit_box_id then
					-- 限制一帧砍多少个敌人
					if att_count_now and att_count_sum and att_count_now >= att_count_sum then
						break
					end
					att_count_now = att_count_now + 1
					att_e.hit_entities[hit_id] = self.frame_count
					-- 用于确定需要被更新血量条的怪物对象
					if att_e == self.main_player or (att_e:get_is_from() and att_e:get_is_from() == self.main_player) then
						ui_hp_target = hit_e
					end
					self:attack(att_e, hit_e, hit_box_id)
				end
				end
			end
		end
		end
		end
	end

	--更新UI血量
	self.proxy:update_main_player_info(self.main_player)
	self.proxy:update_boss_info(ui_hp_target)

	--draw
	for id, e in pairs(self.entities) do
		if e.del then
			e:release()
			self.proxy:remove_avatar( id )
			self.entities[id] = nil
		else
			e:draw()
		end
	end
end

function battle:cast_skill( cmd )
	self.proxy:cast_skill( cmd )
end

function battle:set_auto_battle(is_auto)
	if is_auto == 1 or is_auto == true then
		self.main_player:ai_ctrl()
	else
		self.main_player:hand_ctrl()
	end
end
