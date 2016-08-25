local battle			= import( 'game_logic.battle' )
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
local operate_cmd 		= import( 'ui.operate_cmd')
local skill_button 		= import( 'ui.skill_button' ) 
local physics   	 	= import( 'physics.world')
local math_ext			= import( 'utils.math_ext')
local timer 			= import( 'utils.timer' )

pvp = lua_class( 'pvp', battle.battle )

function pvp:_init( id, proxy )
	super(pvp, self)._init( id, proxy )
	self.proxy:hide_fuben_cnt()
end

function pvp:begin()
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

	self.proxy:set_real_cmd(e.cmd)
	camera_mgr.set_player(e)

	-- e:hand_ctrl()
	self:set_auto_battle(cc.UserDefault:getInstance():getIntegerForKey("auto_battle"))

	skill_button.set_player(e)

	-- 每个副本第一关，重置玩家属性
	if data.fuben_entrance[self.data.chapter_id][self.data.instance_id] == self.id then
		e.combat_attr:reset_relive( e )
	end

	-- 宠物
	for _, pet_id in pairs(e.pet_id) do
		local pet = self:create_monster({type='pet',id=pet_id,pos={200,200},gravity=false,no_obstacle=true})
		pet.combat_attr:copy_from_attr( e.combat_attr )
	end
	--e.buff:apply_buff( 9999, e)

	e.src_combat_attr.max_hp = e.src_combat_attr.max_hp*20
	e.combat_attr.max_hp = e.combat_attr.max_hp*20
	e.src_combat_attr.hp = e.src_combat_attr.max_hp
	e.combat_attr.hp = e.combat_attr.max_hp

	-- e.src_combat_attr.max_hp = 1--e.src_combat_attr.max_hp*20
	-- e.combat_attr.max_hp = 1--e.combat_attr.max_hp*20
	-- e.src_combat_attr.hp = 1--e.src_combat_attr.max_hp
	-- e.combat_attr.hp = 1--e.combat_attr.max_hp
	e.src_combat_attr.mp = 100
	e.combat_attr.mp = 100
	
	print('------player1--------')
	print('f_def, i_def, n_def', e.combat_attr.f_def, e.combat_attr.i_def, e.combat_attr.n_def)
--------------------------------------------------
	local player2 = player:get_pvp_player()
	local tmp_id = self:grab_id()
	local e = self:create_player(tmp_id, player2)
	state_mgr.enter_state(e, 'idle')
	e:set_world_pos(born_pos[1]+500, born_pos[2])
	self.entities[tmp_id] = e
	self.players[tmp_id] = e
	self.second_player = e

	print('------player2--------')
	print('f_def, i_def, n_def', e.combat_attr.f_def, e.combat_attr.i_def, e.combat_attr.n_def)

	-- 每个副本第一关，重置玩家属性
	if data.fuben_entrance[self.data.chapter_id][self.data.instance_id] == self.id then
		e.combat_attr:reset_relive( e )
	end
	--e.buff:apply_buff( 9999, e)
	e:ai_ctrl()

	-- e.src_combat_attr.max_hp = 1--e.src_combat_attr.max_hp*20
	-- e.combat_attr.max_hp = 1--e.combat_attr.max_hp*20
	-- e.src_combat_attr.hp = 1--e.src_combat_attr.max_hp
	-- e.combat_attr.hp = 1--e.combat_attr.max_hp

	e.src_combat_attr.max_hp = e.src_combat_attr.max_hp*20
	e.combat_attr.max_hp = e.combat_attr.max_hp*20
	e.src_combat_attr.hp = e.src_combat_attr.max_hp
	e.combat_attr.hp = e.combat_attr.max_hp
end

function pvp:show_victory( re )

	local player = model.get_player()
	local status = {result = re}
	status.his_id = player:get_pvp_player_id()
	status.is_revenge = player:get_pvp_is_revenge() -- 是否为复仇
	-- director.get_scene():pause()
	-- operate_cmd.enable(false)
	status.pt = tonumber(cc.UserDefault:getInstance():getStringForKey('battle_token'))
	director.show_loading()
	server.pvp_battle_end(self.id, status)
	-- self.proxy:down_battle_ui()
	
	-- music_mgr.stop_bg_music()
	-- music_mgr.victory_music()
	return true
end

function pvp:tick(  )
	super(pvp,self).tick()

	local function callback0(  )
		print('pvp callback0')
		self:show_victory(0)
	end

	local function callback1(  )
		print('pvp callback1 show_victory')
		self:show_victory(1)
	end

	if self.main_player.combat_attr.hp <= 0 then
		
		if self.blackboard.vi_flag == nil then
			self.blackboard.vi_flag = 1
			timer.set_timer(2, callback0)
		end
	elseif self.second_player.combat_attr.hp <= 0 then
		
		if self.blackboard.vi_flag == nil then
			self.blackboard.vi_flag = 1
			timer.set_timer(2, callback1)
		end
	end
end