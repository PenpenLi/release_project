local battle			= import( 'game_logic.battle' )
local combat_attr 		= import( 'model.combat' )
local math_ext			= import( 'utils.math_ext')
local physics   	 	= import( 'physics.world')
local collider			= import( 'game_logic.collider' )
local model 			= import( 'model.interface' )
local td_mons_count		= import('ui.td_ui.td_mons_count')
local timer 			= import( 'utils.timer' )
local director			= import( 'world.director')
local music_mgr			= import( 'world.music_mgr' )
local operate_cmd 		= import( 'ui.operate_cmd')
local state_mgr			= import( 'game_logic.state_mgr' )
local ui_touch_layer	= import( 'ui.ui_touch_layer' )

towerdefense = lua_class( 'towerdefense', battle.battle )

local _dis1 	= 150
local _dis2 	= -150
local _avatar	= nil
local _begin_id	= 7000
local _monster_max_leve_up = 79

function towerdefense:_init( id, proxy )
	super(towerdefense, self)._init( id, proxy )
	self.proxy:hide_fuben_cnt()
	self.monster_level_up = {
		[1]		=	0,
		[2]		=	1,
		[3]		=	2,
		[4]		=	2,
		[5]		=	5,
		[6]		=	5, 
		[7]		=	6,
		[8]		=	7,
		[9]		=	8,
		[10]	=	9,
	}
end

function towerdefense:special_tick()
end

function towerdefense:begin(  )
	super(towerdefense,self).begin()

	local home_pos = nil
	for _,e in pairs(self.entities) do
		if e.battle_group == 2 then
			self.deliver_entity = e 	-- 传送门的entity
		end
		if e.battle_group == -1 then
			self.home_entity = e
			home_pos = self.home_entity:get_world_pos()
		end
	end

	_avatar = model.get_player()

	-- 显示怪物进度条
	self.proxy:show_td_mons_count()

	-- boss出现 ui
	self.proxy:ui_td_boss_coming()

	-- 计算一共有多少怪
	self:statistics_monster()

	--左边界
	physics.create_wall(home_pos.x +70, -100, home_pos.x +70, 100000)

	--设置玩家位置
	self.main_player:set_world_pos(300, 300)

	--基地根据玩家血量变化
	local attr = _avatar:get_attr()
	local hp = attr:get_max_hp()

	--第几关
	self.now_id = self.id - _begin_id + 1

	local home_hp = {
		[1]		=	hp * 1,
		[2]		=	hp * 2,
		[3]		=	hp * 2,
		[4]		=	hp * 2,
		[5]		=	hp * 2,
		[6]		=	hp * 2, 
		[7]		=	hp * 2,
		[8]		=	hp * 2,
		[9]		=	hp * 2,
		[10]	=	hp * 2,
	}

	--上次胜利基地血量
	local db_home_hp = _avatar:get_td_home_hp()

	if db_home_hp == -1 or db_home_hp == nil then
		self.home_entity.combat_attr.hp = home_hp[self.now_id]
		self.home_entity.src_combat_attr.hp = home_hp[self.now_id]
	else
		self.home_entity.combat_attr.hp = db_home_hp
		self.home_entity.src_combat_attr.hp = db_home_hp
	end

	self.home_entity.combat_attr.max_hp = home_hp[self.now_id]
	self.home_entity.src_combat_attr.max_hp = home_hp[self.now_id]

	--	显示基地的无敌按钮
	self.proxy:show_td_home(self.home_entity)
end

function towerdefense:statistics_monster()
	local table = data.shuaguai[self.id]

	self.blackboard.sum = 0
	for i=1, #table do
		self.blackboard.sum = self.blackboard.sum + table[i].monster_count[1]
	end
end

function towerdefense:show_monster_count( args )
	-- args.group
	local g = args.group
	local table = data.shuaguai[self.id]

	local remain_count = 0
	local id = self.blackboard.now_id or 1

	for i = id, #table do
		remain_count = remain_count + table[i].monster_count[1]
	end

	local now_mons_count = self:count_entity( {group=g} ) - 1

	remain_count = remain_count + now_mons_count

	-- 更新怪物数量ui
	td_mons_count.update_td_mons_count((self.blackboard.sum-remain_count)/self.blackboard.sum)
	return false
end

function towerdefense:create_entitys( args ) -- 刷出一批次怪
	-- args.id 	args.shuaguai_id

	local table = data.shuaguai[self.id]
	local ran = _extend.random(#table[self.blackboard.now_id].monster_id)
	
	local table_id = table[self.blackboard.now_id]

	if table_id.flag_boss then
		-- 显示boss出现
		self.proxy:show_td_boss_coming()
	end

	local deliver_pos = self.deliver_entity:get_world_pos() -- 获取传送门的位置

	local deliver_pos_table = {[1]=deliver_pos.x+_dis1, [2]=deliver_pos.x+_dis2}
	local _ran_x_pos = _extend.random(2)

	-- 怪物提升(对应主角的)等级
	local level_up = self.monster_level_up[self.now_id] + _avatar:get_level()
	if level_up > _monster_max_leve_up then
		level_up = _monster_max_leve_up
	end

	for i=1,table_id.monster_count[ran] do
		local e = self:create_monster({conf_id=table_id.monster_id[ran]+level_up,battle_group=table_id.monster_group[ran],pos={deliver_pos_table[_ran_x_pos], deliver_pos.y}})

		-- 设置怪物初始速度
		if table_id.speed_x ~= nil then
			-- local vx, vy = e.combat_attr:get_speed_x()
			e.src_combat_attr:set_speed_x(table_id.speed_x)
			e.combat_attr:set_speed_x(table_id.speed_x)
		end
	end
	
	-- conf
	self.blackboard.now_id = self.blackboard.now_id + 1
	if self.blackboard.now_id <= #table then
		self.blackboard.cd_time = table[self.blackboard.now_id].interval
	else
		self.blackboard.cd_time = 1000000
	end
	self.blackboard.now_time = self.frame_count/60
	return true
end

function towerdefense:cd_over( args )

	local table = data.shuaguai[self.id]

	-- print("---- now_id is = ", self.blackboard.now_id, self.frame_count/60)

	if self.blackboard.now_id == nil then 				-- 初进关卡
		self.blackboard.now_id = 1 						-- 批次id
		self.blackboard.now_time = self.frame_count/60
		self.blackboard.cd_time = table[self.blackboard.now_id].interval
		return true
	end

	if self.blackboard.now_id > #table then
		return false
	end

	local gone_time = self.frame_count/60 - self.blackboard.now_time

	if (gone_time >= self.blackboard.cd_time) then -- cd 冷却了
		return true
	else
		if (self.blackboard.cd_time - gone_time >3) and self:check_entity_count({types={1,2,3},max=2}) then -- 无怪，把下一批怪提前刷出
			self.blackboard.cd_time = gone_time + 2
		end
		return false
	end

	return false
end

function towerdefense:all_over( args )

	local table = data.shuaguai[self.id]
	
	if self.blackboard.now_id and self.blackboard.now_id > #table then -- 所有批次完了
		print(" --- all_over --- ")
		-- print(" --- check_entity_count --- ",self:check_entity_count({types={1,2,3},max=1}))
		return true
	else return false
	end
end

function towerdefense:home_hp_range( args )
	local hp_percentage = self.home_entity.combat_attr.hp / self.home_entity.combat_attr.max_hp * 100 
	local in_range = hp_percentage >= args[1]
	in_range = in_range and hp_percentage < args[2]
	return in_range
end

function towerdefense:get_home_entity(  )
	return self.home_entity
end

-- 更新最近敌人
function towerdefense:update_nearest_enemy( )
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
				if hit_pos.x <= att_pos.x and hit_group ~= NeutralityGroup and self:check_group_relation(att_group, hit_group) and hit_box ~= nil and att_e:is_same_platform( hit_e ) then
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

-- 更新玩家面向
function towerdefense:update_player_face(  )
	for id, player in pairs(self.players) do
		local target_enemy = nil
		local face_direction = nil
		local moving_direction = player.moving_direction
		local att_pos = player:get_world_pos()
		for hit_id, hit_e in pairs(self.entities) do
			local hit_group = hit_e:get_battle_group()
			local hit_box = hit_e:get_world_hit_box()
			local hit_pos = hit_e:get_world_pos()
			-- if hit_group ~= NeutralityGroup and hit_group ~= player:get_battle_group() and hit_box ~= nil then
			if hit_group ~= NeutralityGroup and self:check_group_relation(player:get_battle_group(), hit_group) and hit_box ~= nil then--att_pos.x < hit_pos.x then
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

-- function towerdefense:show_victory( args )

-- 	if self.blackboard.pass ~= nil then
-- 		return true
-- 	end
-- 	-- timer.set_timer(10, function () print() end)
-- 	local function callback(  )
-- 		self:show_victory_callback(args)
-- 	end
-- 	self.blackboard.pass = 1
-- 	timer.set_timer(2, callback)
-- end

function towerdefense:victory( )
	local cast_skill = model.get_player():get_loaded_skills()  --装备的技能
	self.player_bef_skills = {}
	for idx = 1, 3 do
		local sk = cast_skill[idx]
		if sk ~= nil then
			self.player_bef_skills[idx] = sk.lv
		end
	end
	local account_data = {
		bef_lv	= self.player_bef_lv,
		gold = 0,
		diamond = 0,
		gain_exp = 0,
		soul_exp = 0,
		items = {},
		bef_skills = self.player_bef_skills
	}  --	

	self.proxy:show_victory( account_data )
end

function towerdefense:show_victory( args )
	local player = model.get_player()
	director.get_scene():pause()
	operate_cmd.enable(false)
	self.player_bef_lv = player:get_level()
	server.td_battle_end(self.id, tonumber(cc.UserDefault:getInstance():getStringForKey('battle_token')), self.home_entity.combat_attr.hp)
	self.proxy:down_battle_ui()
	director.show_loading()
	music_mgr.stop_bg_music()
	music_mgr.victory_music()
	return true
end