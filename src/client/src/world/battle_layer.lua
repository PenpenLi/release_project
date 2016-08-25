local battle			= import( 'game_logic.battle' )
local command_mgr		= import( 'game_logic.command_mgr' )
local layer				= import( 'world.layer' )
local entity			= import( 'world.entity' )
local camera_mgr		= import( 'game_logic.camera_mgr' )
local director			= import( 'world.director' )
local shadow_layer		= import( 'world.shadow_layer' )
local keyboard_cmd		= import( 'world.keyboard_cmd' )
local ui_touch_layer	= import( 'ui.ui_touch_layer' )
local damage_effect		= import( 'world.damage_effect' )
local physics			= import( 'physics.world' )
local char				= import( 'world.char' )
local defeated_layer	= import( 'ui.defeated_ui.defeated_layer') 
local operate_cmd 		= import( 'ui.operate_cmd' )
local music_mgr			= import( 'world.music_mgr' )
local blade_light		= import( 'world.blade_light' )
local guider_info		= import( 'ui.guider_info' )
local battle_const		= import( 'game_logic.battle_const' )
local message_box		= import( 'ui.message_box' )
local dialog			= import( 'ui.dialog' )
local timer 			= import( 'utils.timer' )
local ui_mgr 			= import( 'ui.ui_mgr' )
local victory_layer		= import( 'ui.victory_layer.victory_layer')  
local model				= import( 'model.interface' )
local math_ext			= import( 'utils.math_ext')
local swallow	 		= import( 'utils.swallow' )


battle_layer 			= lua_class('battle_layer', layer.layer )

PortalBitmask           = 1
PortalPhysicsGroup      = -2
BoundaryPhysicsGroup	= 2
PlatformPhysicsGroup	= 1
EntityPhysicsGroup		= -1
GroundGroup = 3

local _real_cmd = nil 


local _border_width     =10 	--边界宽，设置左右两边
local _border_height    =10 	--边界高，设置地面厚度
local _hp_warn_pr_percent = 20 --剩下百分之多少血，就亮红色警告


function battle_layer:_init(scene_id, fuben_id)
	

	super(battle_layer, self)._init()

	--清除计时器
	timer.remove_all_time()
	self.to_scene_id = -1
	self.scene_data = data.scene[scene_id]
	self.music = self.scene_data.bg_music
	--music_mgr.preload_bg_music(self.scene_data)
	
	self:init_background()

	--加入ui层
	self.entities = {}
	self.chars = {}
	self.sub_chars = {}
	self.bg_chars = {}
	self:create_ui_layer()
	self:handle_event()
  
	--阴影结构 
	self.shadow = shadow_layer.shadow_layer()
	self.bg:addChild(self.shadow.cc)

	--字效
	self.damage_effect = damage_effect.damage_effect()
	self.bg:addChild(self.damage_effect.cc)

	self.d_layer = defeated_layer.defeated_layer(self.ui_layer)
	self.cc:addChild(self.d_layer.cc)
	self.d_layer.cc:setVisible(false)
	-- self.v_layer = victory_layer.victory_layer(self.ui_layer)
	-- self.cc:addChild(self.v_layer.cc)
	-- self.v_layer.cc:setVisible(false)

	self.blade_light = blade_light.blade_light()
	self.cc: addChild(self.blade_light.cc)
	self.blade_light.cc: setLocalZOrder( ZEffect )

	self.scene_id = scene_id
	self.fuben_id = fuben_id
	operate_cmd.enable(true)

	self:get_fuben_num()

	self:play_scene_anim()
end

function battle_layer:start_dialog( dial_id, cb )
    if dial_id ~= nil then
		-- self:add_message_box()
		self:add_dialog_box()
		local function end_callback() 
			self.dialog.cc: setVisible(false)
			self.dialog:end_dialog()
			self.ui_layer.cc:setVisible(true)
			if cb ~= nil then
				cb()
			end
		end
		self.dialog: set_dialog_end_cb( end_callback )
		self.dialog: show_dialog( dial_id )
	end 
end

--新手引导用
function battle_layer:set_real_cmd(real)
	_real_cmd = real
end

function battle_layer:pause()
	for id, c in pairs(self.chars) do
		c:pause_anim()
	end
end

function battle_layer:resume()
	for id, c in pairs(self.chars) do
		c:resume_anim()
	end
end

function battle_layer:release()
	-- stop bg music
	music_mgr.stop_bg_music()
	for id, c in pairs(self.chars) do
		c:release()
	end
	-- 变身char
	for sid, sc in pairs(self.sub_chars) do
		sc:release()
	end
	for sid, sc in pairs(self.bg_chars) do
		sc:release()
	end
	if self.guide_info ~= nil then
		for gid, gc in pairs(self.guide_info) do
			gc: release()
		end
	end
	self.ui_layer:stop()
	self.ui_layer:release()
	self.blade_light: release()
	if self.dialog ~= nil then
		self.dialog: release()
	end
	super(battle_layer, self).release()
end

function battle_layer:create_char(conf)
	if conf.json == nil or type(conf.json) == 'table' then
		return swallow.swallow(), swallow.swallow()
	end
	local entity_anim = char.char(conf)
	if conf.scale_y ~= nil then
		entity_anim.cc:setScaleY(conf.scale_y)
	end
	entity_anim:play_def_anim()
	if conf.zorder ~= nil then
		entity_anim.cc:setLocalZOrder(conf.zorder)
	else
		entity_anim.cc:setLocalZOrder(ZMonster)
	end
	local entity_bg
	if conf.bgjson ~= nil then
		entity_bg = char.char({json=conf.bgjson, name=conf.bgname})
		entity_bg.cc:setLocalZOrder(conf.bgzorder)
		self.bg:addChild(entity_bg.cc)
	end

	self.bg:addChild(entity_anim.cc)
	return entity_anim, entity_bg
end

function battle_layer:create_avatar( id, args )
	local e

	if args.type == 'bullet' then
		local conf_id = args.conf_id
		local skill = args.skill
		e = import('world.entities.bullet').bullet(id, skill:get_bullet_conf(conf_id), skill)
		-- 设置子弹来自谁
		e:set_is_from(args.is_from)
	elseif args.type == 'player' then
		e = import('world.entities.player').player(id, args.role_type)
	elseif args.type == 'pet' then
		e = import('world.entities.pet').pet(id, args.id)
	elseif args.scenebuff_id ~= nil then
		e = import('world.entities.scenebuff').scenebuff(id, args.conf_id, args.scenebuff_id)
	else
		local conf_id = args.conf_id

		local avatar = data.monster[conf_id]
		local model = data.monster_model[avatar.model_id].class
		e = import('world.entities.' .. model)[model](id, conf_id)

		-- 怪物出生自带buff
		local monster_buff = avatar.buff
		local model_conf_id = avatar.model_id
		local monster_model_buff = data.monster_model[model_conf_id].buff

		if model_conf_id and monster_model_buff then
			e.buff:apply_buff(monster_model_buff, nil, nil)
		end

		if conf_id and monster_buff then
			e.buff:apply_buff(monster_buff, nil, nil)
		end
		-- print("----------", conf_id, monster_buff, model_conf_id, monster_model_buff)
	end

	self.entities[id] = e
	local c, bg = self:create_char(e.conf)
	self.chars[id] = c
	self.bg_chars[id] = bg
	e:set_char(c, bg)

	if e:is_random_y() == true then
		if e.y_axis_offset < 0 then
			c.cc:setLocalZOrder(c.cc:getLocalZOrder() + 15)
		elseif e.y_axis_offset > 0 then
			c.cc:setLocalZOrder(c.cc:getLocalZOrder() - 15)
		end
	end
	if e.conf.shadow ~= false then
		self.shadow:add_shadow(e, id)
	end
	--如果是玩家，boss ，宠物
	if e:is_player() then
		self.player_array_id = e.id
	elseif e:is_boss() then
		self.boss_array_id = e.id
	end
	return e
end

function battle_layer:entity_transform( id, conf_key )
	if self.entities[id] == nil then
		return
	end
	local e = self.entities[id]
	if e.sub_char ~= nil then
		e.sub_char: release( )
	end
	local tr_conf = import( conf_key )
	local c = self:create_char(tr_conf)
	e.sub_char = c
	self.sub_chars[id] = c
	e.char.cc: setVisible( false )
end

function battle_layer:entity_detransform( id )
	if self.entities[id] == nil then
		return
	end
	local e = self.entities[id]
	if e.sub_char ~= nil then
		e.sub_char: release( )
		e.sub_char = nil 
	end
	self.sub_chars[id] = nil
	e.char.cc: setVisible( true )
end

function battle_layer:remove_avatar( id )

	if self.sub_chars[id] ~= nil then
		self.sub_chars[id]: release()
		self.sub_chars[id] = nil
	end

	if self.bg_chars[id] ~= nil then
		self.bg_chars[id]: release()
		self.bg_chars[id] = nil
	end
	self.chars[id]:release()
	self.chars[id] = nil
	--清除阴影
	if self.entities[id].conf.shadow ~= false then
		self.shadow:remove_shadow(id)
	end
	self.entities[id] = nil
	--self.damage_effect:remove(id)
end

--单面碰撞
function battle_layer:handle_event()

	local eventDispatcher = self.cc:getEventDispatcher()
	--eventDispatcher:removeAllEventListeners()

	command_mgr.setup_touches(self.cc, eventDispatcher)

	--键盘模拟相关
	keyboard_cmd.setup_keyboard_cmd(self.cc, eventDispatcher, self.ui_layer)

	-- --手柄
end 

--测试创建物理台阶
function  battle_layer:create_physics_world( scene_data )
	-- body
	local x = scene_data.width/2
	local y = scene_data.height/2
	
	local map = ccexp.TMXTiledMap:create( scene_data.floot_file )
	self.cc:addChild( map )
	--创建地面和台阶
	local objects = map:getObjectGroup( scene_data.floot )
	local lower_ground = 10000
	if objects ~= nil then 
		for _, obj in ipairs( objects:getObjects() ) do
			-- print('obj is -----------------', obj.x, obj.y, obj.width, obj.height)
			if obj.wall == nil then
				local p = physics.create_platform(obj.x, obj.y+obj.height, obj.x+obj.width, obj.y+obj.height)
				if obj.type and obj.type == 'dimian' then
					p:set_is_ground(true)
				end
				if lower_ground > obj.y+obj.height then
					lower_ground = obj.y+obj.height
				end
			else
				physics.create_wall(obj.x, -100, obj.x, obj.y + obj.height - 1)
			end
		end
	end

	--左边界
	physics.create_wall(0, -100, 0, 100000)
	--右边界
	physics.create_wall(scene_data.width, -100, scene_data.width, 100000)
	--底边界
	physics.create_wall(-100, 0, 100000, 0)
	return lower_ground
end

function battle_layer:init_background()
	-- self.bg = ccs.GUIReader:getInstance():widgetFromJsonFile("sceneA/B1920x1140.ExportJson")
	self.bg = ccs.GUIReader:getInstance():widgetFromJsonFile(self.scene_data.bg_json)
	self:record_plist_from_json( self.scene_data.bg_json )
	--self.bg = cc.Layer:create()
	--self.bg:setTouchEnabled(true)
	--self.bg:setFocused(false)
	self.cc:addChild(self.bg)
	local root = self.cc:getChildByTag(self.scene_data.root_tag)
	self.layer0 = root:getChildByName('0')
	self.layer01 = root:getChildByName('01')
	self.layer02 = root:getChildByName('02')
	self.layer03 = root:getChildByName('03')
	self.layer04 = root:getChildByName('04')
	self.layer05 = root:getChildByName('05')
	self:play_action(string_split(self.scene_data.bg_json,'/')[2], 'Animation0')

	---加入技能面板

end

function battle_layer:play_bg_music()
	-- AudioEngine.playMusic(self.music, true)
	if music_mgr._is_bg_enable then
		music_mgr.fade_to_new_music( self.music )
		music_mgr._is_normal_bg_playing = false
	end
end


--创建技能按钮 
function battle_layer:create_ui_layer()
	self.ui_layer = ui_touch_layer.ui_touch_layer()
	self.cc:addChild(self.ui_layer.cc, ZUIInteract)
	self.ui_layer:setup_operate_cmd(self.cc, self.cc:getEventDispatcher())
end

function battle_layer:add_dialog_box()
    self.ui_layer.cc:setVisible(false)
    self.dialog = dialog.dialog()
    self.cc:addChild(self.dialog.cc, 1000)
end 

--TODO: for test
function battle_layer:add_message_box()
	self.msg_box = message_box.message_box()
	self.cc:addChild(self.msg_box._richText)
	self.msg_box._richText: setPosition( 500, 200 )
	
	local function click_event( )
		self.msg_box:push_text( '[ don\'t click me 加些中文 ]', Color.Red)
		self.msg_box:push_image( 'msg.png' )
		self.msg_box._richText: setContentSize( 400, 100 )
		self.msg_box:get_height()
	end

	self.msg_box:push_text_link( '[click me]', click_event, Color.Yellow)
end

-- 新手引导 start
function battle_layer:show_guide( json, anim, tips, gest_name, pos, origin_point )
	if self.guide_info == nil then
		self.guide_info = {}
	end
	if self.guide_info[json] == nil then
		local temp_guide_layer = guider_info.guider_info(json)
		-- self.cc: addChild( temp_guide_layer.cc, ZUITutor )
		self.ui_layer.cc: addChild( temp_guide_layer.cc, 99 )
		self.guide_info[json] = temp_guide_layer
	end

	local temp_info = self.guide_info[json]
	if tips ~= nil then
		temp_info: set_tips( tips )
		if gest_name ~= nil then
			temp_info: show_gesture( gest_name, pos, origin_point)
		end
	end
	temp_info:set_later_visible( true )
	if anim ~= nil then
		temp_info: play_anim( anim )
	else
		temp_info: update_visibility()
	end
end

function battle_layer:hide_guide( json, anim, tips )
	if self.guide_info == nil or self.guide_info[json] == nil then
		return
	end

	local temp_info = self.guide_info[json]
	if tips ~= nil then
		temp_info: set_tips( tips )
	end
	temp_info:set_later_visible( false )
	if anim ~= nil then
		temp_info: play_anim( anim )
	else
		temp_info: update_visibility()
	end
end
-- 新手引导 end



function battle_layer:flash(box1, box2, scale, ttl)
	if self.damage_box == nil then
		self.damage_box = {0,0,0,0}
	end
	self.damage_box[1] = math.max(box1[1], box2[1])
	self.damage_box[2] = math.max(box1[2], box2[2])
	self.damage_box[3] = math.min(box1[3], box2[3])
	self.damage_box[4] = math.min(box1[4], box2[4])

	self.x_pos = math.abs(self.damage_box[3] - self.damage_box[1])
	self.y_pos = math.abs(self.damage_box[4] - self.damage_box[2])

	if self.x_pos >= 1 then
		self.x_pos = math.random(self.x_pos) + self.damage_box[1]
	else
		self.x_pos = self.damage_box[1]
	end
	if self.y_pos >= 1 then
		self.y_pos = math.random(self.y_pos) + self.damage_box[2]
	else
		self.y_pos = self.damage_box[2]
	end

	-- self.blade_light:generate_light( math.max(box1[1], box2[1]), math.min(box1[4], box2[4]), scale, ttl )
	-- self.blade_light:generate_light( x, y, scale, ttl )
	self.blade_light:new_light( self.x_pos, self.y_pos, scale, ttl )
end

function battle_layer:tick()
 	-- 触发: 传送门
 	if self.to_scene_id ~= -1 then
		if type(self.to_scene_id) == 'number' then
			director.enter_battle(self.to_scene_id)
		elseif self.to_scene_id == 'main' then
			director.enter_scene(import( 'world.main_scene' ), 'main_scene')
		end
 	end

	self.shadow:tick_pos()
	self.blade_light: tick()

	local pos = camera_mgr.get_camera_pos()

	local x = pos.x - VisibleSize.width/2
	local y = pos.y - VisibleSize.height/2
	self.layer0:setPosition( -x*self.scene_data.sr_0,  -y*self.scene_data.sr_0)
	self.layer01:setPosition(-x*self.scene_data.sr_01, -y*self.scene_data.sr_01)
	self.layer02:setPosition(-x*self.scene_data.sr_02, -y*self.scene_data.sr_02)
	self.layer03:setPosition(-x*self.scene_data.sr_03, -y*self.scene_data.sr_03)
	self.layer04:setPosition(-x*self.scene_data.sr_04, -y*self.scene_data.sr_04)
	self.layer05:setPosition(-x*self.scene_data.sr_05, -y*self.scene_data.sr_05)

	--字效位置
	self.damage_effect.cc:setPosition(cc.p(-x, -y))
 	self.ui_layer:tick()
end

function battle_layer:update_main_player_info(player)
	if player == nil then
		return
	end
	local player_max_hp = player.combat_attr.max_hp
	local player_cur_hp = player.combat_attr.hp
	self.ui_layer:up_hp(player_cur_hp / player_max_hp * 100,player_cur_hp)

	local player_max_mp = player.combat_attr.max_mp
	local player_cur_mp = player.combat_attr.mp
	local pers = player_cur_mp/player_max_mp *100
	self.ui_layer:up_mp(pers,player_cur_mp)



	if player:is_dead() then
		self:hide_no_hp_prompt()
		return
	end

	if player_cur_hp <= player_max_hp * _hp_warn_pr_percent/100 then
		self:show_no_hp_prompt()
	elseif player_cur_hp > player_max_hp * _hp_warn_pr_percent/100 then
		self:hide_no_hp_prompt()
		--self.red_view_warn_count=0
	end 

end

function battle_layer:show_boss_info()
	self.ui_layer:show_boss_hp()
end

function battle_layer:update_boss_info(boss)
	if boss == nil then
		return
	end
	if boss.conf.show_blood_slot == false then
		return
	end
	self.ui_layer:show_boss_hp()
	local boss_max_hp = boss.combat_attr.max_hp
	local boss_cur_hp = boss.combat_attr.hp
	if boss_cur_hp == 0 then
		self.ui_layer:hide_boss_hp()
	end
	self.ui_layer:up_boss_hp(boss_cur_hp / boss_max_hp * 100,boss_cur_hp)
end

function battle_layer:show_damage_effect(eff_table)
	--战斗数据
	self.damage_effect:show_effect(eff_table);
end 


function battle_layer:cast_skill(cmd)
	self.ui_layer:cast_skill(cmd)
end 

function battle_layer:show_no_hp_prompt(  )
	self.ui_layer:show_no_hp_prompt()
end

function battle_layer:hide_no_hp_prompt(  )
	self.ui_layer:hide_no_hp_prompt()
end

function battle_layer:down_battle_ui(  )
	self.ui_layer:down_battle_ui()
end


function battle_layer:up_battle_ui(  )
	self.ui_layer:up_battle_ui()
end

--播放场景动画
function battle_layer:play_scene_anim(  )
	-- body
	
	if self.scene_data.scene_anims ~= nil then
		local label = string_split(self.scene_data.bg_json,'/')
		local js_name = label[2]


		for k,v in pairs(self.scene_data.scene_anims) do
			self:play_action(js_name,v)
		end
	end
	
end

function battle_layer:show_victory( account_data )
	local v_layer = ui_mgr.create_ui(victory_layer,'victory_layer')

	local star = 3
	v_layer:set_star(star)
	v_layer:set_bef_lv(account_data.bef_lv)
	v_layer:set_items(account_data.items)
	v_layer:set_money(account_data.gold)
	v_layer:set_gem(account_data.diamond)
	v_layer:set_gain_exp(account_data.gain_exp)
	v_layer:cal_exp_level()
	v_layer:set_soul_exp(account_data.soul_exp)
	v_layer:set_bef_attack(account_data.bef_att)
	v_layer:set_bef_defense(account_data.bef_def)
	v_layer:set_bef_crit(account_data.bef_crit)
	v_layer:set_bef_hp(account_data.bef_hp)
	v_layer:set_bef_skills(account_data.bef_skills)
	
	v_layer:update_bar()
	v_layer:init_skills()


	-- set fuben star
	local battle = director.get_cur_battle()
	local player = model.get_player()
	-- player:set_fuben_star(battle.data.instance_id, star)
	v_layer:play_anim()

end

function battle_layer:show_victory_callfunc(func, account_data)
	local v_layer = ui_mgr.create_ui(victory_layer,'victory_layer')

	v_layer:set_bef_lv(account_data.bef_lv)
	v_layer:set_items(account_data.items)
	v_layer:set_money(account_data.gold)
	v_layer:set_gem(account_data.diamond)
	v_layer:set_gain_exp(account_data.gain_exp)
	v_layer:cal_exp_level()
	v_layer:set_soul_exp(account_data.soul_exp)

	v_layer:set_bef_attack(account_data.bef_att)
	v_layer:set_bef_defense(account_data.bef_def)
	v_layer:set_bef_crit(account_data.bef_crit)
	v_layer:set_bef_hp(account_data.bef_hp)
	v_layer:set_bef_skills(account_data.bef_skills)

	v_layer:update_bar()
	v_layer:init_skills()

	v_layer:play_anim()
	if func == nil then
		func = function() print('no func') end
	end
	v_layer:set_touch_begin_event(func)
end

function battle_layer:get_fuben_num()
	local cur_id = math.max(self.fuben_id - 500, 1000)
	local flag = false

	
	self.fuben_num = 1
	self.cur_fuben = 1

	for i = cur_id, self.fuben_id do
		local tmp_num = 1
		local tmp_cur_fuben = 0
		local tmp_id = cur_id
		--print('!!!!!!!!!!!!!!!!!!!!!! ', tmp_id)
		for j = 1, 500 do
			if tmp_id == self.fuben_id then
				flag = true
			end

			if data.fuben[tmp_id] ~= nil and data.fuben[tmp_id].next_barrier ~= nil then
				tmp_id = data.fuben[tmp_id].next_barrier
				tmp_num = tmp_num + 1
				
				if flag == false then
					tmp_cur_fuben = tmp_cur_fuben + 1
				end
			--	print('has next', tmp_id, tmp_num, tmp_cur_fuben)
			else 
				cur_id = tmp_id + 1
				break
			end
		end

		if flag == true then
			--print('find %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  ', i)
			self.fuben_num = tmp_num
			self.cur_fuben = tmp_cur_fuben
			break
		end
	end
	print(self.fuben_num)
end

-- 显示塔防基地无敌按钮
function battle_layer:show_td_home( home_entity )
	self.ui_layer:show_td_home(home_entity)
end

-- 显示塔防剩余怪物条
function battle_layer:show_td_mons_count(  )
	self.ui_layer:show_td_mons_count( )
end

-- 塔防boss出现ui
function battle_layer:ui_td_boss_coming(  )
	self.ui_layer:ui_td_boss_coming()
end

-- 显示塔防boss出现特效
function battle_layer:show_td_boss_coming(  )
	self.ui_layer:show_td_boss_coming()
end

function battle_layer:show_time_counter( )
	print("here has the time counter !!!!! ")
	self.ui_layer:show_timer_counter()
end

function battle_layer:set_timer_counter(time)
	self.ui_layer:set_timer_counter(time)
end

function battle_layer:refresh_skill_buttons()
	self.ui_layer:refresh_skill_buttons()
end

function battle_layer:hide_skill_buttons()
	self.ui_layer:hide_skill_buttons()
end

function battle_layer:show_skill_buttons()
	self.ui_layer:show_skill_buttons()
end

function battle_layer:show_go_icon()
	self.ui_layer:show_go_icon()
end

function battle_layer:hide_go_icon()
	self.ui_layer:hide_go_icon()
end

function battle_layer:add_fuben_cnt()
	self.cur_fuben = self.cur_fuben + 1
	self:set_fuben_cnt(self.cur_fuben)
end

function battle_layer:set_fuben_cnt(cur, all)
	all = all or self.fuben_num
	cur = cur or 1
	self.ui_layer:set_fuben_cnt(cur, all)
end

function battle_layer:hide_fuben_cnt()
	self.ui_layer:hide_fuben_cnt()
end

function battle_layer:hide_auto_battle()
	self.ui_layer:hide_auto_battle()
end

function battle_layer:get_is_auto()
	return self.ui_layer:get_is_auto()
end

function battle_layer:get_skill_btn()
	return self.ui_layer:get_skill_btn()
end
