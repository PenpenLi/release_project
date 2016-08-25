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

boss = lua_class( 'boss', battle.battle )

local lv_offset = 3

function boss:_init( id, proxy )
	super(boss, self)._init( id, proxy )
	self.proxy:hide_fuben_cnt()
end

function boss:create_scene_object()
	local player = model.get_player()
	local level = player:get_level()

	local objects = ccexp.TMXTiledMap:create( self.data.object_conf ):getObjectGroup( "object" )
	if objects == nil then
		return
	end
	for _, obj in ipairs(objects:getObjects()) do
		local conf_id = tonumber(obj.type)
		local conf_lv = level
		
		conf_lv = math.min(math.max(conf_lv + lv_offset, 1), 80)
		conf_id = conf_id*1000 + conf_lv
		print('create boss id', conf_id)

		if obj.dest == nil then
			self:create_monster({conf_id=conf_id,battle_group=tonumber(obj.group),pos={obj.x,obj.y}}) 
		else
			self:create_monster({conf_id=conf_id,battle_group=tonumber(obj.group),pos={obj.x,obj.y},gravity=false,dest=obj.dest}) 
		end
	end
end

function boss:show_victory( args )
	local player = model.get_player()
	director.get_scene():pause()
	operate_cmd.enable(false)
	self.player_bef_lv = player:get_level()
	server.boss_battle_end(self.id, tonumber(cc.UserDefault:getInstance():getStringForKey('battle_token')))
	self.proxy:down_battle_ui()
	director.show_loading()
	music_mgr.stop_bg_music()
	music_mgr.victory_music()
	return true
end


function boss:show_defeated( args )
	--显示失败界面
	if self.proxy.d_layer.defeated_count < 1 then
		self.proxy.d_layer.defeated_count=1
		local function callback(  )
			local function func()
				local ui_queue = ui_mgr.ui_his_dequeue['main_scene']
				if ui_queue ~= nil then
					local top_ui
					for i = 1, 1 do
						top_ui = ui_queue:pop_front()
						if top_ui ~= nil then
							ui_mgr.add_wait_ui('main_scene', top_ui.mod, top_ui.name)
						end
					end
				end
				director.enter_scene(import( 'world.main_scene' ), 'main_scene')
			end
			operate_cmd.enable(false)
			if self.proxy.ui_layer.boss_hp.imgbg:isVisible() then
				self.proxy.ui_layer:play_action("Ui_Battle_BossBlood.ExportJson", "down")
			end
			self.proxy:down_battle_ui()
			director.get_scene():pause()
			self.proxy.ui_layer:play_action('Ui_Black.ExportJson','up')
			self.proxy.ui_layer:play_action('Ui_D.ExportJson','up')
			
			self.proxy.d_layer.cc:setVisible(true)
			self.proxy.d_layer:set_close_btn_event(func)
			music_mgr.pause_bg_music()
			music_mgr.fail_music()
		end
		timer.set_timer(1,callback)
		return true
	end
	return false
end

function boss:victory( )

	local function func()
		local ui_queue = ui_mgr.ui_his_dequeue['main_scene']
		if ui_queue ~= nil then
			local top_ui
			for i = 1, 1 do
				top_ui = ui_queue:pop_front()
				if top_ui ~= nil then
					ui_mgr.add_wait_ui('main_scene', top_ui.mod, top_ui.name)
				end
			end
		end
		director.enter_scene(import( 'world.main_scene' ), 'main_scene')
	end
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

	self.proxy:show_victory_callfunc( func, account_data )
end