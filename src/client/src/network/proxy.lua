local model				= import( 'model.interface' )
local avatar			= import( 'model.avatar' )
local command_mgr		= import( 'game_logic.command_mgr' )
local director			= import( 'world.director' )
local battle			= import( 'game_logic.battle' )
local camera_mgr		= import( 'game_logic.camera_mgr' )
local ui_mgr 			= import( 'ui.ui_mgr' )
local msg_queue 		= import( 'ui.msg_ui.msg_queue' )
local locale			= import( 'utils.locale' )
local chat_ui			= import( 'ui.chat_box_layer.chat_box_layer')
local locale			= import( 'utils.locale' )

proxy = lua_class( 'proxy' )

function proxy:_init()
end

function proxy:message( msg_key, args )
	--TODO: 服务器直接弹幕消息，支持多语言
	local msg = locale.get_value_with_var( msg_key, args )
	msg_queue.add_msg(msg)
end

function proxy:login_ok(msg) 
	-- login done
	print('[server]登陆成功 : ',msg)
end

function proxy:player_online( server_data )
	local new_player = avatar.avatar()
	if self.player ~= nil then
		new_player.attrs = self.player.attrs
		new_player.final_attrs = self.player:get_attr()
	end
	self.player = new_player
	self.player:init_server_data(server_data)
	model.set_main_player(self.player)
end

function proxy:show_gain_msg( items )
	for _, it in pairs(items) do
		local it_type = data.item_id[it.id]
		if it_type == 'soul' then
			local d = data.soul[it.id]
			if d ~= nil then
				self:gain_skill(d.soul_id)
			end
		else
			msg_queue.add_item_msg(it.id, it.number)
		end
	end
end

function proxy:del_item(item_id)
	local item_type = data.item_id[item_id]
	local item 		= data[item_type][item_id]

	if item_type == 'equip_frag' then
		self.player:del_equip_frag(item.color, item.position)
	
	elseif item_type == 'equip_qh_stone' then
		self.player:del_equip_qh_stone(item.color)
	
	elseif item_type == 'soul_stone' then
		self.player:del_soul_frag(item.soul_id)

	else
		local oid 	= self.player:get_item_oid_byid(item_id)
		self.player:del_item(oid)
	end
end

function proxy:del_quest_daily( quest_id )
	self.player:del_quest_daily( quest_id )
	--ui_mgr:reload()
end

function proxy:del_quest( quest_id )
	self.player:del_quest( quest_id )
	--ui_mgr:reload()
end

function proxy:update_quest( quest_id, cnt )
	self.player:update_quest( quest_id, cnt )
	ui_mgr:reload()
end

function proxy:update_quest_daily( quest_id, cnt )
	self.player:update_quest_daily( quest_id, cnt )
	ui_mgr:reload()
end

function proxy:finish_signin()
	self.player.sign_in_times = self.player.sign_in_times + 1
	self.player.latest_sign_time = os.time()
	ui_mgr.get_ui('sign_in_layer'):reload()
end

function proxy:clear_sign_in( ) --每月清表
	self.player.sign_in_times = 0
	self.player.latest_sign_time = 0
end

function proxy:finish_midas_touch( critical_mul )
	self.player:set_midas_touch(self.player:get_midas_touch() + 1)
	ui_mgr.get_ui('midas_touch_layer'):set_critical_mul(critical_mul)
	ui_mgr.get_ui('midas_touch_layer'):reload()
end

function proxy:finish_batch_use_items(  )
	ui_mgr.get_ui('bag_system_layer'):reload()
end

function proxy:sync_one_proxy_money( coin_type, number )
	self.player:set_one_proxy_money( coin_type, number )
end

function proxy:sync_shop_f5_times( times )
	-- 刷新次数
end

function proxy:finish_equip_levelup(  )
	ui_mgr:reload()
	ui_mgr.get_ui('strengthen_layer'):play_tx()
end

function proxy:finish_wear_equip(  )
	ui_mgr:reload()
end

function proxy:finish_activate_equip(  )
	-- body
	ui_mgr.get_ui('equip_sys_layer'):reload()
	ui_mgr.get_ui('equipment_info_panel'):set_activation_info()
	
end

function proxy:finish_use_item()

	ui_mgr:reload()
end

function proxy:finish_login(is_new_player)
	self.player:finish_server_data()
	local director = import('world.director')
	local cur_scene = director.get_scene()._name
	if cur_scene == 'login_scene' then
		if self.player.nick_name == '' then
			director.enter_scene(import( 'world.chose_characters_scene' ), 'chose_characters_scene')
		elseif is_new_player == true then
			director.enter_battle_scene(999)
		else
			director.enter_scene(import( 'world.main_scene' ), 'main_scene')
		end
	elseif cur_scene == 'battle_scene' then
		self.player:bound_entity(director.get_cur_battle().main_player)
	end
	ui_mgr:reload()
	if not is_new_player then 
		self:message('msg_login_welcom')
	end
end

function proxy:finish_create_avatar()
	--新手引导
	director.enter_battle_scene(999)
end

function proxy:create_avatar_fail(msg)
	msg_queue.add_msg(locale.get_value(msg))
end

function proxy:login_failure(state)
	print('[server]登陆失败 : ',state)
	msg_queue.add_msg('登陆失败,请重试！')
end

function proxy:replace_login()
	director.enter_scene(import( 'world.login_scene' ), 'login_scene')()
	msg_queue.add_msg('您被顶号。')
	disconnect()
end

function proxy:close_mail_info()
	local mail_info_ui = ui_mgr.get_ui('mail_info')
	if mail_info_ui ~= nil then
		mail_info_ui:play_down_anim()
	end
end

--金币一抽十抽
function proxy:lottery_money_one_result( goods_id , exist )
	print('抽卡接口')
	ui_mgr.get_ui('lottery_layer'):gl_one_event(goods_id,exist)
	ui_mgr:reload()
end

function proxy:lottery_money_ten_result( goods_ids , exists )

	ui_mgr.get_ui('lottery_layer'):gl_ten_event(goods_ids,exists)
	ui_mgr:reload()
end

--砖石一抽十抽
function proxy:lottery_diamond_one_result( goods_id , exist)
	ui_mgr.get_ui('lottery_layer'):dl_one_event(goods_id,exist)
	ui_mgr:reload()
end

function proxy:lottery_diamond_ten_result( goods_ids , exists )
	ui_mgr.get_ui('lottery_layer'):dl_ten_event(goods_ids,exists)
	ui_mgr:reload()
end

function proxy:battle_limited()
	director.hide_loading()
	print('[server]进入失败')
	msg_queue.add_msg('您没达到进入副本的条件')
end

function proxy:battle(battle_id, token)
	cc.UserDefault:getInstance():setStringForKey('battle_token', token)
	director.hide_loading()
	director.enter_battle_scene(battle_id)
end

function proxy:battle_finish(battle_id, status)
	-- 结束战斗，显示结算
	director.hide_loading()
	for i, v in pairs(status.items) do
		-- print('物品:',i,v)
		-- dir(v)
		-- print('----------')
	end
	director.get_cur_battle():victory(status.items)
end

function proxy:pvp_battle( battle_id, token )
	cc.UserDefault:getInstance():setStringForKey('battle_token', token)
	self.player.pvp_token = token
	director.hide_loading()
	director.enter_battle_scene(battle_id)
end

function proxy:pvp_battle_finish( result, point, honor )
	director.hide_loading()
	if result >=1 then -- 胜利
		local pvp_v = ui_mgr.create_ui(import('ui.pvp_ui.pvp_victory'), 'pvp_victory')
		pvp_v:set_point_honor(point, honor)
	else
		local pvp_d = ui_mgr.create_ui(import('ui.pvp_ui.pvp_defeat'), 'pvp_defeat')
		pvp_d:set_point_honor(point)
	end
end

function proxy:boss_battle_finish( result )
	director.hide_loading()
	director.get_cur_battle():victory()
end

function proxy:td_battle_finish( result )
	director.hide_loading()
	director.get_cur_battle():victory()
end

function proxy:warriortest_battle_finish( result )
	director.hide_loading()
	director.get_cur_battle():victory()
end

function proxy:gain_item( item )
	ui_mgr:reload()
end

function proxy:gain_skill( skill_id )
	ui_mgr.hide_loading()
	local ui_gain = ui_mgr.create_ui(import('ui.soul_gain_layer.soul_gain_layer'), 'soul_gain_layer')
	ui_gain:init_skill_with_id(skill_id)
	local function cb(  )
		local ui_soul = ui_mgr.get_ui('soul_page_panel')
		ui_soul:set_is_act(false)
	end
	ui_gain:set_end_callback(cb)
	ui_gain:play_start_anim()
	ui_mgr.reload()

end

function proxy:update_skill( skill )
	self.player:update_skill(skill)
	--ui_mgr:reload()
end


function proxy:up_star_finish(  )
	ui_mgr.get_ui('soul_info_panel'):play_star_anim()
	ui_mgr.get_ui('soul_page_panel'):set_update_card()
	ui_mgr:reload() 
end

function proxy:change_equip( item_oid )
	self.player:change_equip( item_oid )
	ui_mgr.get_ui('equip_sys_layer'):reload()
end

function proxy:say(msg_data)
	chat_box = ui_mgr.get_ui('chat_box_layer')
	chat_ui.add_to_list(msg_data)
	chat_ui.set_recent_msg(msg_data)
	if chat_box ~= nil and msg_data['channel'] ~= nil then
		chat_box:update_list(msg_data['channel'])
	end

	main_surface = ui_mgr.get_ui('main_surface_layer')
	if main_surface ~= nil then
		main_surface:updata_msg(chat_ui.get_recent_msg())
	end
end

function proxy:update_chat_his(pos, maxi_num, history)	
	if history ~= nil then
		chat_ui.load_history(pos, maxi_num, history)
		chat_box = ui_mgr.get_ui('chat_box_layer')
		if chat_box ~= nil then
			chat_box:update_list('all')
		end
	end
end

function proxy:server_method_failed()
	-- hide loading
	ui_mgr.hide_loading()
end

function proxy:server_method_finished()
	ui_mgr.hide_loading()
	ui_mgr.reload()
end


function proxy:strengthen_success(new_lv)
	-- for k, v in pairs(new_lv) do
	-- 	print(k, v)
	-- end
	director.hide_loading()
	ui_mgr:reload()
	ui_mgr.get_ui('proficient_layer'):play_tx()
end

function proxy:strengthen_fail(type)
	print("at strengthen_fail")
end

function proxy:player_can_rebirth( )
	local player_entity = self.player.entity
	player_entity.combat_attr:reset_relive( player_entity )

	--TODO: ui_mgr
	local battle = director.get_cur_battle()
	if battle ~= nil then
		battle.proxy.d_layer:player_can_rebirth()
		-- ui_mgr.get_ui('defeated_layer'):player_can_rebirth()
	end
	ui_mgr.hide_loading()
	-- dir(ui_mgr.get_ui('defeated_layer'))
end

function proxy:show_player_info( data )
	local player = avatar.avatar()
	player:init_server_data(data)
	player:finish_server_data()
	local info_layer = ui_mgr.create_ui(import('ui.avatar_info_layer.avatar_info_layer'), 'avatar_info_layer')
	info_layer:set_info(player)
end


function proxy:buy_limit()
	msg_queue.add_msg('您没达到购买的条件')
end

function proxy:refresh_limit()
	msg_queue.add_msg('您的代币不足')
end

function proxy:finish_sweep( battle_id, reword, ex_reward)
	local reward = ui_mgr.create_ui(import('ui.fuben_detail.sweep_layer'), 'sweep_layer')
	reward:play_up_anim( battle_id, reword, ex_reward )
end

function proxy:add_limit_msg( str )
	msg_queue.add_msg(locale.get_value(str))
end

---====================----sync-------========================
function proxy:sync_items( its )
	self.player:add_items(its)
end

function proxy:sync_guide_done( guide_done )
	self.player: set_guide_done_array( guide_done )
end

function proxy:sync_guide_state( guide_state )
	self.player: set_guide_state_array( guide_state )
end

function proxy:ui_guide_all_done()
	self.player: set_ui_guide_all_done()
end

function proxy:sync_single_guide_done( guide_id )
	self.player: finish_guide( guide_id )
	deep_dir(self.player:get_guide_done_array())
end

function proxy:sync_one_mall_count(good_id_str, count)
	self.player.mall[good_id_str] = count
	ui_mgr:reload()
end

function proxy:sync_sweep_ticket( num )
	self.player:set_sweep_ticket ( num )
	ui_mgr:reload()
end

function proxy:sync_mc_left_day( day )
	self.player.mc_left_day = day
end

function proxy:sync_exchange_mall( good_table )
	self.player.exchange_goods	= good_table
	print('-----------sync')
end

function proxy:sync_exchange_mall_by_type( proxy_type, good_table )
	self.player.exchange_goods[proxy_type]	= good_table
	print('-----------sync')
	ui_mgr:reload()
end

function proxy:sync_pvp_rank( i, rank, num )
	if i == 1 then
		self.player.pvp_rank = {}
		self.player.pvp_rank_num = num
		table.insert(self.player.pvp_rank, rank)
	else
		table.insert(self.player.pvp_rank, rank)
	end

	--self.player.pvp_rank = rank
	--self.player.pvp_rank_num = num -- 自己的名次
end

function proxy:sync_pvp_point( point )
	self.player.pvp_point = point

	local pvp_layer = ui_mgr.get_ui('pvp_layer')
	if pvp_layer ~= nil then
		pvp_layer:refresh_point()
	end
end

function proxy:sync_pvp_honor( honor )
	self.player.pvp_honor = honor

	local pvp_layer = ui_mgr.get_ui('pvp_layer')
	if pvp_layer ~= nil then
		pvp_layer:refresh_honor()
	end
end

function proxy:sync_pvp_ticket( ticket )
	self.player.pvp_ticket = ticket
end

function proxy:sync_pvp_candidate_refresh_time( time )
	self.player.pvp_candidate_refresh_time = time
end


--pvp
function proxy:sync_pvp_candidate(candidates, oid_flag)
	self.player.pvp_candidate = {} -- oid -> obj
	self.player.pvp_candidate_flag = oid_flag -- oid_flag

	for i, j in pairs(candidates) do
		local player = avatar.avatar()
		player.is_candidate = true
		player:init_server_data(table_deepcopy(j))
		player.id = i
		-- model.add_player(player)
		player:finish_server_data()
		self.player:add_pvp_candidate(player)
	end

	-- 刷新pvp 选人UI
	local pvp_layer = ui_mgr.get_ui('pvp_layer')
	if pvp_layer ~= nil then
		pvp_layer:refresh_pvp_checkbox_ui(1)
		self:message('msg_successful_refresh')
	end
end

function proxy:sync_pvp_record( record, refresh_ui )
	self.player.pvp_record = record

	-- 刷新pvp战斗记录UI
	if refresh_ui == nil then
		return
	end

	local pvp_layer = ui_mgr.get_ui('pvp_layer')
	if pvp_layer ~= nil then
		pvp_layer:refresh_pvp_checkbox_ui(2)
		self:message('msg_successful_refresh')
	end
end

function proxy:sync_bag( bag )
	ui_mgr:reload()
end

function proxy:sync_cur_boss(cur_boss)
	self.player:set_cur_boss(cur_boss)
	ui_mgr:reload()
end

function proxy:sync_finish_boss(finish_boss)
	self.player:set_finish_boss(finish_boss)
	ui_mgr:reload()
end

function proxy:sync_boss_award(award)
	self.player:set_boss_award(award)
end

function proxy:finish_boss_award(items)
	local award_info = ui_mgr.create_ui(import('ui.box_reward_layer.box_reward_layer'), 'box_reward_layer')
	award_info:set_yes_button_handel(function() award_info:play_down_anim() end)
	award_info:set_reward(items)
	ui_mgr:reload()
	director.hide_loading()
end

function proxy:sync_time( os_time )
	local time = os.time()
	local sub = time - os_time
	self.player.cs_time = sub
end

function proxy:sync_fuben( fuben )
	self.player.fuben = fuben
end

function proxy:sync_td_fuben_chests( td_fuben, td_chests, td_home_hp)
	self.player.td_fuben = td_fuben
	self.player.td_chests = td_chests
	self.player.td_home_hp = td_home_hp
	ui_mgr:reload()
end

function proxy:sync_td_award( items )
	director.hide_loading()

	local award_info = ui_mgr.create_ui(import('ui.box_reward_layer.box_reward_layer'), 'box_reward_layer')
	award_info:set_yes_button_handel(function() award_info:play_down_anim() end)
	award_info:set_reward(items)
	ui_mgr:reload()
end

function proxy:sync_elite_fuben( elite_fuben )
	self.player.elite_fuben = elite_fuben
end

-- 抽卡接口
function proxy:sync_lottery( lottery )
	self.player.lottery = lottery
end

function proxy:sync_nick_name( nick_name )
	self.player:set_nick_name( nick_name )
	ui_mgr:reload()
end 

function proxy:sync_role_type( role_type )
	self.player:set_role_type( role_type )
	ui_mgr:reload()
end 

function proxy:sync_strength_lv( strengths )
	local player = model.get_player()
	player:set_strength_lv(strengths)
	ui_mgr:reload()
end

function proxy:sync_email(email)
	self.player:add_email(email)
	local email_layer = ui_mgr.get_ui('mailbox_layer')
	if email_layer ~= nil then
		email_layer:update_mail_list()
	end
end

function proxy:sync_midas_touch(touch_cnt)
	self.player:set_midas_touch(touch_cnt)
end

function proxy:sync_midas_con_cnt(touch_cnt)
	self.player:set_midas_con_cnt(touch_cnt)
end

function proxy:sync_one_proxy_money( coin_type, number )
	self.player:set_one_proxy_money( coin_type, number )
end

function proxy:sync_shop_f5_times( times )
	-- 刷新次数
end

function proxy:sync_soul_frag( frags )
	self.player:set_soul_frag(frags)
	--ui_mgr:reload()
end

function proxy:sync_one_soul_frag( skill_id, frags )
	self.player:set_one_soul_frag( skill_id, frags )
	--ui_mgr:reload()
end

function proxy:sync_equip_frag( stones )
	self.player:set_equip_frag( stones )
end

function proxy:sync_one_equip_frag( quality, frags )
	self.player:set_one_equip_frag( quality, frags )
end

function proxy:sync_one_equip_qh_stone( quality, stones )
	self.player:set_one_equip_qh_stone( quality, stones )
end

function proxy:sync_equips( equips )
	if equips ~= nil then
		for k, v in pairs( equips ) do
			self.player:set_one_equip( v )
		end
	end
end

function proxy:sync_one_equip( equip )
	self.player:set_one_equip( equip )
end

function proxy:sync_one_wear( eq_type, eq_id )
	self.player:set_one_wear( eq_type, eq_id )
	ui_mgr:reload()
end

function proxy:sync_quest( quests )
	self.player:add_quest(quests)
	--ui_mgr:reload()
end

function proxy:sync_quest_daily( quests )
	self.player:add_quest_daily(quests)
	--ui_mgr:reload()
end

function proxy:sync_vip( vip )
	self.player:set_vip( vip )
	ui_mgr:reload()
end

function proxy:sync_shop1( items )
	self.player:sync_shop1( items )
	--购买成功或初始化，刷新商店
	ui_mgr:reload()
end

function proxy:sync_diamond( diamond )
	self.player:set_diamond( diamond )
	ui_mgr.update_lbl()
end

function proxy:sync_money(val)
	self.player:set_money(val)
	ui_mgr.update_lbl()
end

function proxy:sync_exp(val)
	self.player:set_exp(val)
	ui_mgr:reload()
end

function proxy:daily_limit()
	msg_queue.add_msg('今日战斗次数不足')
end

function proxy:finish_change_nickname()
	local change_nick_ui = ui_mgr.get_ui('change_nickname_layer')
	if change_nick_ui ~= nil then
		change_nick_ui:close_ui()
	end
	ui_mgr:reload()
end
function proxy:sync_lv(val)
	self.player:set_lv(val)
	ui_mgr.update_lbl()
end

function proxy:sync_energy(val)
	self.player.energy = val
	ui_mgr.update_lbl()
end

function proxy:sync_energy_buy_daily( num )
	self.player.energy_buy_daily = num
end

function proxy:sync_one_fuben_daily(id, time)
	print('-------',id,time)
	self.player:set_one_fuben_daily(id, time)
end

function proxy:sync_fuben_reset_daily( num )
	self.player:set_fuben_reset_daily( num )
end
