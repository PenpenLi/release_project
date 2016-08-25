local combat			= import( 'model.combat' )
local item				= import( 'model.item' )
local skill				= import( 'model.skill' )
local quest				= import( 'model.quest' )
local swallow	 		= import( 'utils.swallow' )
local table_utils		= import( 'engine.table_utils' )
local command			= import( 'game_logic.command' )
local buff				= import( 'game_logic.buff' )
local model				= import( 'model.interface' )
local math_ext			= import( 'utils.math_ext')

avatar = lua_class( 'avatar' )

import('model.vip')
function avatar:_init()
	self.attrs = combat.combat_attr()
	self.items = {}
	self.level = 1

	self.quests = {}
	self.quests_daily = {}
	self.skills = {}
	self.loaded_skills = {}
	self.pvp_def_skills = {}
	self.shop1 = {}
	self.shop2 = {}
	self.equip_frag = {}
	self.equip_qh_stone = {}
	self.equips = {}
	self.wear = {}
	self.final_attrs = combat.combat_attr()
	self.entity = swallow.swallow()
	self.buff = buff.buff(self.entity)
	self.pvp_candidate = {}
	self.total_fc = 0
	self.strength_lv = {1,1,1,1,1,1}  --1:power 2:courage 3:technique 4:life 5:strong 6:tenacity
	--只会在“单机测试”按钮进入时设置为true
	self.offline_mode = false
	self.item_map = {}
	self.emails = {}
	self.pvp_rank = {}
	self.pvp_candidate = {}
	self.pvp_candidate_flag = {}
	self.pvp_record = {}
	self.proxy_money = {}
	self.cur_boss = {}
	self.mc_left_day = 0
	self.finish_boss = {}
	self.boss_award = {}
	self.guide_done = {}
	self.guide_done_cache = {}
	self.screen_player = {}
	self.guide_state = {}
end

function avatar:add_item_map(item)
	if item == nil or item.server_data == nil then
		return
	end

	if self.item_map[item.id] == nil then
		self.item_map[item.id] = item.server_data._id
	else
		print('[WARNING] remap item oid', item.id)
		self.item_map[item.id] = item.server_data._id
	end
end

function avatar:get_item_oid_byid(item_id)
	return self.item_map[item_id]
end

function avatar:get_attr()
	return self.final_attrs
end

function avatar:init_server_data(server_data)
	--basic
	self.id = server_data._id
	self.user_name = server_data.user_name
	self.role_type = server_data.role_type -- 'cike'
	self.nick_name = server_data.nick_name
	self.money = server_data.money
	self.level = server_data.lv
	self.exp = server_data.exp
	self.energy = server_data.energy
	self.diamond = server_data.diamond
	self.fuben = server_data.fuben
	self.elite_fuben = server_data.elite_fuben
	self.td_fuben 	= server_data.td_fuben
	self.td_chests = server_data.td_chests
	self.td_home_hp = server_data.td_home_hp
	self.soul_frag = server_data.soul_frag
	self.equip_frag = server_data.equip_frag
	self.equip_qh_stone = server_data.equip_qh_stone
	self.wear = server_data.wear
	self.strength_lv = server_data.strength_lv --精通强化等级
	self.fc = server_data.fc
	self.lottery = server_data.lottery
	self.sign_in_times = server_data.sign_in_times
	self.latest_sign_time = server_data.latest_sign_time
	self.pvp_point = server_data.pvp_point
	self.pvp_honor = server_data.pvp_honor
	self.pvp_ticket = server_data.pvp_ticket
	self.vip		= server_data.vip
	self.mall		=server_data.mall
	-- self.pvp_candidate 	= server_data.pvp_candidate
	-- self.pvp_record		= server_data.pvp_record
	self.pvp_candidate_refresh_time = server_data.pvp_candidate_refresh_time
	self.emails	= server_data.emails
	self.proxy_money = server_data.proxy_money
	self.cur_boss = server_data.cur_boss
	self.finish_boss = server_data.finish_boss
	self.boss_award = server_data.boss_award

	self.midas_touch_cnt = server_data.midas_touch_cnt
	self.midas_con_cnt   = server_data.midas_con_cnt
	self.sweep_ticket = server_data.sweep_ticket
	self.fuben_daily = server_data.fuben_daily
	self.energy_buy_daily = server_data.energy_buy_daily
	self.fuben_reset_daily = server_data.fuben_reset_daily
	self.wing = server_data.wing
	--equipments
	for k, v in pairs(server_data.equips) do
		local equip = item.equipment()
		equip:init_server_data(v)
		self.equips[k] = equip
	end
	--skills
	for k, v in pairs(server_data.skills) do --key是 string
		self.skills[k] = skill.skill(v)
	end
	for k, v in pairs(server_data.loaded_skills) do
		if v ~= -1 then -- 占位
			self:load_skill(k, v)
		end
	end
	--pvp_def_skills
	for k,v in pairs(server_data.pvp_def_skills) do
		if v ~= -1 then -- 占位
			self:load_pvp_def_skill(k, v)
		end
	end

	self.basic_skills = {'slash_up', 'slash_down', 'charge_left', 'charge_right'}

end

function avatar:add_items(items)

	for k, it in pairs(items) do
		if item.is_equip(it.type) then 
			self:set_one_equip( it )
		elseif item.is_material(it.type) then
			local item_oid = self:get_item_oid_byid(it.id)
			local exist_it = self.items[item_oid]
			if exist_it ~= nil then
				exist_it.number = it.number
			else
				local temp_item = item.material(it.type, it.id)
				temp_item:init_server_data(it)
				self.items[it._id] = temp_item
				self:add_item_map(temp_item)
			end
		end
	end
end

function avatar:get_item_number_by_id( id )
	local item_oid = self:get_item_oid_byid(id)
	local exist_it = self.items[item_oid]
	if exist_it ~= nil then
		return exist_it.number
	else
		return 0
	end

end

function avatar:add_equip( equip )
	local e = item.equipment()
	e:init_server_data(equip)
	local id_str = tostring(equip.id)
	self.equips[id_str] = e
end

function avatar:add_quest(quests)
	for k, q in pairs(quests) do
		if q == 1 then
			self.quests[k] = 1
		else
			local temp_quest = quest.quest('quest',q.id)
			temp_quest:init_server_data(q)
			self.quests[k] = temp_quest
		end
	end
end

function avatar:add_quest_daily(quests)
	for k, q in pairs(quests) do
		if q == 1 then
			self.quests_daily[k] = 1
		else
			local temp_quest = quest.quest('quest_daily',q.id)
			temp_quest:init_server_data(q)
			self.quests_daily[k] = temp_quest
		end
	end
end

function avatar:add_email(email)
	self.emails[email._id] = email
end

function avatar:get_emails()
	return self.emails
end

function avatar:update_quest( quest_id, cnt)
	self.quests[quest_id].complete_count = cnt
end

function avatar:update_quest_daily( quest_id, cnt )

	self.quests_daily[quest_id].complete_count = cnt
end
function avatar:del_quest_daily( quest_id_str )
	self.quests_daily[quest_id_str] = nil
end

function avatar:del_quest( quest_id )
	self.quests[quest_id] = nil 
end

function avatar:is_quest_received( quest_id )
	quest_id = tostring(quest_id)
	return (self.quests[quest_id] == 1)
end

function avatar:is_quest_daily_received( quest_id )
	quest_id = tostring(quest_id)
	return (self.quests_daily[quest_id] == 1)
end

function avatar:del_item(item_oid)
	self.items[item_oid] = nil
end

function avatar:del_equip_qh_stone(color)
	self.equip_qh_stone[color]	= nil
end

function avatar:del_equip_frag(color, position)
	local key = color .. '_' .. position
	self.equip_frag[key]	= nil
end

function avatar:del_soul_frag(skill_id)
	self.soul_frag[skill_id]	= nil 
end

function avatar:finish_server_data()
	self:init_combat_attr()
end

function avatar:init_combat_attr( )
	--TODO: load from server data
	self.attrs:init_with_level( self.level )
	self.attrs:init_with_strengthen_level( self.strength_lv )
	self.attrs:set_player(self)
	self.final_attrs:copy_from_attr(self.attrs)
	self.final_attrs:set_player(self)
	self.final_attrs:final_combat_attr()
	self:calc_fighting_capacity()
end

function avatar:bound_entity(entity)
	self.entity = entity
	--self.buff:bound_entity(entity)
end

function avatar:unbound_entity()
	self.entity = swallow.swallow()
	--self.buff:unbound_entity(self.entity)
end

function avatar:change_equip(eq_id_str)
	local eq = self.equips[eq_id_str]
	if not eq:is_equip() then
		return
	end
	server.wear_equip(eq_id_str)
end

function avatar:load_skill(slot, skill_id)
	--unload
	local ls = self.loaded_skills[slot]
	if ls ~= nil then
		ls:change_command(command.placeholder)
	end
	self.loaded_skills[slot] = nil

	--load
	-- local s = self.skills[skill_id]
	local s = self.skills[tostring(skill_id)]
	if s ~= nil then
		self.loaded_skills[slot] = s
		s:change_command(command.placeholder + slot)
	end
	self.final_attrs:final_combat_attr()
	self:calc_fighting_capacity()
end

function avatar:unload_skill( skill_id )
	for k, v in pairs(self.loaded_skills) do
		if v:get_id() == skill_id then
			v.conf.command = command.placeholder
			self.loaded_skills[k] = nil
			break
		end
	end
end

function avatar:remove_skill( skill_id_str )
	if self.skills[skill_id_str] ~= nil then
		self.skills[skill_id_str] = nil 
	end
end

function avatar:load_pvp_def_skill( slot, skill_id )
	local ls = self.pvp_def_skills[slot]
	-- if ls ~= nil then
		-- ls:change_command(command.placeholder)
	-- end
	self.pvp_def_skills[slot] = nil

	local s = self.skills[tostring(skill_id)]
	if s ~= nil then
		self.pvp_def_skills[slot] = s
		-- s:change_command(command.placeholder + slot)
	end
	--self.final_attrs:final_combat_attr()
end

function avatar:update_skill(s)
	if self.skills[tostring(s.id)] == nil then
		self.skills[tostring(s.id)] = skill.skill(s)
	else
		self.skills[tostring(s.id)]:update_server_data(s)
	end
end

function avatar:get_skills()
	return self.skills
end

function avatar:get_loaded_skills()
	return self.loaded_skills
end

function avatar:get_pvp_def_skills(  )
	return self.pvp_def_skills
end

function avatar:get_items()
	return self.items
end

function avatar:get_quests()
	return self.quests
end

function avatar:get_quests_daily()
	return self.quests_daily
end

function avatar:get_wear(e_type)
	
	local wearing_id = self.wear[e_type]


	if wearing_id == nil then
		return nil
	end
	return self:get_equip(wearing_id)
end

function avatar:get_equip(id)
	return self.equips[tostring(id)]
end

function avatar:get_equips(  )
	return self.equips
end

--取出实际属性
function avatar:get_final_attrs()
	return self.final_attrs
end

function avatar:get_fuben_star( star_id )
	if star_id <= math_ext.get_star_id(self.fuben) then
		return 3
	else
		return 0
	end
end

-- 获取(客户端 - 服务器)的时间差
function avatar:get_cs_time(  )
	return self.cs_time
end

function avatar:set_offline( )
	self.offline_mode = true
end

function avatar:is_offline()
	return self.offline_mode == true
end

function avatar:get_level()
	return self.level
end

function avatar:sync_shop1( items )

	self.shop1 = {}
	for k, it in pairs(items) do
		local temp_item
		if item.is_equip(it.type) then
			temp_item = item.equipment(it.type, it.id)
		else
			temp_item = item.item(it.type, it.id)
		end
		temp_item:init_server_data(it)
		self.shop1[it._id] = temp_item
	end
end

function avatar:get_shop1()
	return self.shop1
end

function avatar:calc_fighting_capacity()
	local fc = self:get_attr():get_fighting_capacity()
	for _, s in pairs(self.loaded_skills) do
		fc = fc + s:get_fighting_capacity()
	end
	self.total_fc = fc
end

function avatar:get_fighting_capacity()
	return self.total_fc
end

function avatar:get_soul_frag(  )
	return self.soul_frag
end

function avatar:set_soul_frag( frags )
	self.soul_frag = frags
end

function avatar:set_one_soul_frag( skill_id, frags )
	self.soul_frag[skill_id] = frags
end

function avatar:get_equip_frags()
	return self.equip_frag
end

function avatar:get_one_equip_frag( quality )
	if self.equip_frag[quality] == nil then
		return 0 
	end
	return self.equip_frag[quality]
end

function avatar:set_equip_frag( stones )
	self.equip_frag = stones
end

function avatar:set_one_equip_frag( quality, stones )
	self.equip_frag[quality] = stones
end

function avatar:get_equip_qh_stones()
	return self.equip_qh_stone
end

function avatar:get_one_equip_qh_stone( color )
	if self.equip_qh_stone[color] == nil then
		return 0
	end
	return self.equip_qh_stone[color]
end

function avatar:set_equip_qh_stones( stones )
	self.equip_qh_stone = stones
end

function avatar:set_one_equip_qh_stone( color, stones )
	self.equip_qh_stone[color] = stones
end

function avatar:set_one_equip( equip )
	local id_str = tostring(equip.id)
	if self.equips[id_str] == nil then
		self:add_equip( equip )
		-- for 激活属性
		self.final_attrs:final_combat_attr()
		-- self:calc_fighting_capacity()
	end
	self.equips[id_str]:set_level( equip.lv )
	self.final_attrs:final_combat_attr()
	self:calc_fighting_capacity()
end

function avatar:set_one_wear( eq_type, eq_id )
	self.wear[eq_type] = eq_id
	self.final_attrs:final_combat_attr()
	self:calc_fighting_capacity()
	-- self.entity.char:change_equip(self.entity.char.equip_conf[eq_type], self:get_wear(eq_type))
end

function avatar:get_one_proxy_money( coin_type )
	if self.proxy_money[coin_type] == nil then
		return 0
	end
	return self.proxy_money[coin_type]
end

function avatar:set_one_proxy_money( coin_type, number )
	self.proxy_money[coin_type] = number
end

function avatar:get_one_exchange_goods( proxy_type )
	return  self.exchange_goods[proxy_type]
end

function avatar:set_money( money )
	self.money = money
end

function avatar:set_diamond( diamond )
	self.diamond = diamond
end

function avatar:set_vip( vip )
	self.vip = vip
end

function avatar:get_vip()
	return self.vip
end

function avatar:get_sweep_ticket()
	return self.sweep_ticket
end

function avatar:set_sweep_ticket( num )
	self.sweep_ticket = num 
end

function avatar:get_strength_lv(  )
	return self.strength_lv
end

function avatar:get_money(  )
	return self.money
end

function avatar:get_diamond(  )
	return self.diamond
end

function avatar:set_strength_lv( strengths )
	self.strength_lv = strengths
end

function avatar:set_lv( lv )
	self.level = lv
	self:init_combat_attr()
end

function avatar:set_exp( exp )
	self.exp = exp
end

function avatar:get_exp()
	return self.exp
end

function avatar:set_nick_name(nick_name)
	self.nick_name = nick_name
end

function avatar:set_role_type(role_type)
	self.role_type = role_type
end

function avatar:get_role_type()
	return self.role_type
end

function avatar:get_id()
	return self.id
end

-- pvp
function avatar:add_pvp_candidate( player )
	self.pvp_candidate[player.id] = player
end

function avatar:get_pvp_candidate()
	return self.pvp_candidate
end

function avatar:get_pvp_candidate_flag(  )
	return self.pvp_candidate_flag
end

function avatar:get_pvp_player(  )
	return self.pvp_player
end

function avatar:get_pvp_player_id(  )
	return self.pvp_player_id
end

function avatar:set_pvp_player( player_id )
	self.pvp_player_id = player_id
	self.pvp_player = self.pvp_candidate[player_id]
end

function avatar:set_pvp_is_revenge( id )
	self.pvp_is_revenge = id
end

function avatar:get_pvp_is_revenge(  )
	return self.pvp_is_revenge
end

function avatar:get_pvp_point(  )
	return self.pvp_point
end

function avatar:get_pvp_honor(  )
	return self.pvp_honor
end

function avatar:get_pvp_ticket(  )
	return self.pvp_ticket
end

function avatar:get_pvp_candidate_refresh_time(  )
	return self.pvp_candidate_refresh_time
end

function avatar:get_fc(  )
	return math.floor(self.fc)
end

function avatar:pvp_record_to_player( data )
	local player = avatar()
	player.is_candidate = true
	player:init_server_data(table_deepcopy(data))
	player.id = data._id
	model.add_player(player)
	player:finish_server_data()

	-- set pvp player
	self.pvp_player = player
	self.pvp_player_id = player.id

	return player
end

function avatar:get_pvp_record(  )
	return self.pvp_record
end

function avatar:get_pvp_rank(  )
	return self.pvp_rank, self.pvp_rank_num
end

-- 抽卡
function avatar:get_lottery_m_free(  )
	return self.lottery.m_free
end

function avatar:get_lottery_m_time(  )
	return self.lottery.m_time
end

function avatar:get_lottery_d_time(  )
	return self.lottery.d_time
end

function avatar:get_nick_name()
	return self.nick_name
end

function avatar:get_fuben(  )
	return self.fuben
end

function avatar:get_elite_fuben(  )
	return self.elite_fuben
end

function avatar:get_td_fuben()
	return self.td_fuben
end

function avatar:get_td_chests()
	return self.td_chests
end

function avatar:get_td_home_hp(  )
	return self.td_home_hp
end

function avatar:get_cur_boss()
	return self.cur_boss
end

function avatar:get_finish_boss()
	return self.finish_boss
end

function avatar:set_cur_boss(boss)
	if type(boss) == 'table' then
		self.cur_boss = {}
		for id, v in pairs(boss) do
			self.cur_boss[id] = v
		end
	end
end

function avatar:set_finish_boss(boss)
	if type(boss) == 'table' then
		self.finish_boss = {}
		for id, v in pairs(boss) do
			self.finish_boss[id] = v
		end
	end
end

function avatar:get_boss_award()
	return self.boss_award
end

function avatar:set_boss_award(award)
	self.boss_award = award
end

function avatar:is_today_signed()
	if self.latest_sign_time == nil or self.latest_sign_time == 0 then
		return false
	end
	return os.date('*t', os.time() - 21600).day == os.date('*t', self.latest_sign_time - 21600).day
end

function avatar:finish_guide( guide_id )
	if self.guide_done == nil then
		self.guide_done = {}
	end
	table.insert(self.guide_done, guide_id)
end

function avatar:get_guide_done_array()
	if self.guide_done == nil then
		self.guide_done = {}
	end
	return self.guide_done
end

function avatar:set_tutor_done(is_done)
	self.tutor_done = is_done
end

function avatar:get_tutor_done()
	if self.tutor_done == nil then
		return true
	else
		return self.tutor_done
	end
end

function avatar:get_energy()
	return self.energy
end

function avatar:get_midas_touch( )
	return self.midas_touch_cnt
end

function avatar:set_midas_touch( touch_cnt )
	self.midas_touch_cnt = touch_cnt
end

function avatar:set_midas_con_cnt( touch_cnt )
	self.midas_con_cnt = touch_cnt
end

function avatar:get_midas_con_cnt(  )
	return self.midas_con_cnt
end

function avatar:get_one_fuben_daily( bid )
 	return self.fuben_daily[bid]
end

function avatar:set_one_fuben_daily(id, time)
	self.fuben_daily[id] = time
end

function avatar:set_fuben_reset_daily( num )
	self.fuben_reset_daily = num
end
 
function avatar:get_fuben_reset_daily( )
	return self.fuben_reset_daily
end

function avatar:check_guide_done( guide_id )
	--引导是否完成
	return (self:check_guide_done_remote(guide_id) or self:check_guide_done_local(guide_id))
end

function avatar:check_guide_done_remote( guide_id )
	local is_done = false
	--检查服务器同步记录
	for _, t_id in pairs(self.guide_done) do
		if guide_id == t_id then
			is_done = true
			break
		end
	end
	return is_done
end
function avatar:check_guide_done_local( guide_id )
	local is_done = false
	--检查本地记录
	for _, t_id in pairs(self.guide_done_cache) do
		if guide_id == t_id then
			is_done = true
			break
		end
	end
	return is_done
end

function avatar:set_guide_done_cache( guide_id )
	--本地记录完成的步骤
	table.insert(self.guide_done_cache, guide_id)
end

function avatar:guide_done_big_step()
	--本地与服务器同步 “完成条件”符合的步骤
	local done_send = {}
	for i = #self.guide_done_cache, 1, -1 do
		if self:check_guide_done_condition(self.guide_done_cache[i]) == true then
			table.insert(done_send, self.guide_done_cache[i])
			table.insert(self.guide_done, self.guide_done_cache[i])
			table.remove(self.guide_done_cache, i)
		end
	end
	if #done_send > 0 then
		server.finish_guide( done_send )
	end
end

function avatar:add_screen_player( player_id )
	self.screen_player[player_id] = true
end

function avatar:get_screen_player()
	return self.screen_player
end

function avatar:check_guide_done_condition( guide_id )
	--检查“完成条件”是否成立
	local d = data.guide[guide_id]
	if d == nil then
		return false
	end
	if d.fin_pre ~= nil then
		return self:check_guide_done( d.fin_pre )
	else
		return true
	end
end

function avatar:check_guide_state( state_flag )
	local state = self.guide_state[state_flag]
	if state == nil then
		return false
	else
		return state
	end
end

function avatar:set_guide_state_done( state_flag )
	if state_flag == nil then
		return
	end
	if self:check_guide_state( state_flag ) == true then
		return
	end

	local state_id = 0
	for k, v in pairs(data.guide_state) do
		if v.flag == state_flag then
			state_id = k
			break
		end
	end
	if state_id > 0 then
		server.save_guide_state( state_id )
		self.guide_state[state_flag] = true
	end
end

function avatar:set_guide_done_array( guide_done )
	self.guide_done = guide_done
end

function avatar:set_guide_state_array( guide_state )
	if type(guide_state) == 'table' then
		for _, v in pairs(guide_state) do
			local flag = data.guide_state[v].flag
			self.guide_state[flag] = true
		end
	end
end

function avatar:set_ui_guide_all_done()
	self.ui_guide_all_done = true
end

function avatar:get_ui_guide_all_done()
	return self.ui_guide_all_done or false
end

function avatar:get_wing(  )
	return self.wing
end
