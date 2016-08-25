local avatar			= import('entities.avatar').avatar
local db				= import('db')
local const				= import('const')
local timer				= import('model.timer')
local utf8_utils		= import('utils.utf8')
local player_mgr		= import('model.player_mgr')

function avatar:_try_levelup()
	local exp = self:_get_exp()
	for i = self:_get_level(), 80 do
		if exp >= data.level[i].sum_exp then
			self:_levelup()
		else
			break
		end
	end
end

function avatar:_get_oid()
	return self.db._id
end

function avatar:_levelup()
	self:_setdbc('lv', self:_get_level() + 1)
	self:_recalc_fc()
	self:_levelup_update_quest(self.db.lv)
	self:_trigger_quest_event('level',self.db.lv)
end

function avatar:_get_money()
	return self.db.money
end

function avatar:_get_diamond()
	return self.db.diamond
end

function avatar:_get_exp()
	return self.db.exp
end

function avatar:_get_level()
	return self.db.lv
end

function avatar:_strength_up(type)
	local strength_lv = self:_get_strength_lv()
	strength_lv[type] = strength_lv[type] + 1
	self:_setdbc('strength_lv', strength_lv)
	self:_recalc_fc()
end

function avatar:_strength_up_more(type, lvs)
	local strength_lv = self:_get_strength_lv()
	strength_lv[type] = strength_lv[type] + lvs
	self:_setdbc('strength_lv', strength_lv)
	self:_recalc_fc()
end

function avatar:_get_energy()
	return self.db.energy
end

function avatar:_get_vip_lv()
	return self.db.vip.lv
end

function avatar:_get_midas_touch_cnt()
	return self.db.midas_touch_cnt
end

function avatar:_set_midas_touch_cnt(midas_touch_cnt)
	self:_setdb('midas_touch_cnt', midas_touch_cnt)
end

function avatar:_get_midas_con_cnt()
	return self.db.midas_con_cnt
end

function avatar:_set_midas_con_cnt(times)
	self:_setdb('midas_con_cnt', times)
end

function avatar:_get_shop_f5_times()
	return self.db.shop_f5_times
end

function avatar:_get_strength_lv()
	return self.db.strength_lv
end

function avatar:_get_all_soul_frags()
	-- all soul stone
	return self.db.soul_frag
end

function avatar:_get_soul_frag(skill_id)
	-- some soul stone
	skill_id = tostring(skill_id)
	if self.db.soul_frag[skill_id] == nil then
		return 0
	end
	return self.db.soul_frag[skill_id]
end

function avatar:_get_all_equip_frags()
	return self.db.equip_frag
end

function avatar:_get_equip_frag(color, position)
	local key = color .. '_' .. position
	if self.db.equip_frag[key] == nil then
		return 0
	end
	return self.db.equip_frag[key]
end

function avatar:_get_equip_qh_stone(color)
	if self.db.equip_qh_stone[color] == nil then
		return 0
	end
	return self.db.equip_qh_stone[color]
end

function avatar:_add_energy_buy_daily( )
	self:_setdbc('energy_buy_daily', self.db.energy_buy_daily + 1)
end

function avatar:_add_equip_qh_stone(color, num)
	if type(num) ~= 'number' then
		return
	end
	if self.db.equip_qh_stone[color] == nil then
		self.db.equip_qh_stone[color] = num
	else
		self.db.equip_qh_stone[color] = self.db.equip_qh_stone[color] + num
	end

	-- wrate db
	self:_writedb()
	self.client.sync_one_equip_qh_stone(color, self.db.equip_qh_stone[color])
end

function avatar:_add_equip_frag(quality, position, num)
	if type(num) ~= 'number' then
		return
	end
	local key = quality .. '_' .. position
	if self.db.equip_frag[key] == nil then
		self.db.equip_frag[key] = num
	else
		self.db.equip_frag[key] = self.db.equip_frag[key] + num
	end

	-- wrate db
	self:_writedb()
	self.client.sync_one_equip_frag(key, self.db.equip_frag[key])
end

function avatar:_get_sweep_ticket()
	return self.db.sweep_ticket
end

function avatar:_add_sweep_ticket(sweep_ticket)
	if type(sweep_ticket) ~= 'number' then
		return
	end
	self:_setdb('sweep_ticket', self:_get_sweep_ticket() + sweep_ticket)
	self.client.sync_sweep_ticket(self:_get_sweep_ticket())
end

function avatar:_add_sweep_ticket_daily()
	local vip_lv	= self:_get_vip_lv()
	local send_ticket	= self:_get_vip_send_sweep_ticket()
	self:_add_sweep_ticket(send_ticket) 
end

function avatar:_get_fuben()
	return self.db.fuben
end

function avatar:_get_elite_fuben()
	return self.db.elite_fuben
end

function avatar:_get_td_fuben()
	return self.db.td_fuben
end

function avatar:_add_soul_frag(skill_id, num)
	if type(num) ~= 'number' then
		return
	end
	skill_id = tostring(skill_id)
	if self.db.soul_frag == nil then
		self.db.soul_frag = {}
	end

	if self.db.soul_frag[skill_id] == nil then
		self.db.soul_frag[skill_id] = num
	else
		self.db.soul_frag[skill_id] = self.db.soul_frag[skill_id] + num
	end

	-- self:_setdbc('soul_frag', self:_get_all_soul_frags())
	self:_writedb()
	self.client.sync_one_soul_frag(skill_id, self.db.soul_frag[skill_id])
end

function avatar:_get_proxy_money(coin_type)
	if self.db.proxy_money[coin_type] == nil then
		return 0
	end
	return self.db.proxy_money[coin_type]
end

function avatar:_add_proxy_money(coin_type, num)
	if type(num) ~= 'number' then
		return
	end
	if self.db.proxy_money[coin_type] == nil then
		self.db.proxy_money[coin_type] = num
	else
		self.db.proxy_money[coin_type] = self.db.proxy_money[coin_type] + num
	end

	-- wrate db
	self:_writedb()
	self.client.sync_one_proxy_money(coin_type, self.db.proxy_money[coin_type])
end


function avatar:_add_shop_f5_times(num)
	if type(num) ~= 'number' then
		return
	end
	self:_setdbc('shop_f5_times', self:_get_shop_f5_times() + num)
end

function avatar:_add_money(money)
	if type(money) ~= 'number' then
		return
	end
	self:_setdbc('money', self:_get_money() + money)
end

function avatar:_add_diamond( diamond )
	if type(diamond) ~= 'number' then
		return
	end
	self:_setdbc('diamond', self:_get_diamond() + diamond)
end

function avatar:_add_exp(exp)
	if type(exp) ~= 'number' then
		return
	end
	self:_setdbc('exp', self:_get_exp() + exp)
	self:_try_levelup()
end

function avatar:_add_energy(energy)
	if type(energy) ~= 'number' then
		return
	end
	self:_setdbc('energy', self:_get_energy() + energy)
end

function avatar:_setc(prop, val)
	self[prop] = val
	self.client.sync_property(prop, val)
end

function avatar:_setdb(prop, val)
	self.db[prop] = val
	self:_writedb()
end

function avatar:_setdbc(prop, val)
	self.db[prop] = val
	self:_log('dbc', prop, val)
	self.client['sync_'..prop](val)
	self:_writedb()
end

function avatar:_daily_update()
	local now = timer.get_now()
	if timer.is_same_day(self.db.daily_timestamp, now) then
		return
	end
	--副本次数更新
	local fuben_daily = self.db.fuben_daily
	for k,_ in pairs(fuben_daily) do
		fuben_daily[k] = nil
	end
	--每日任务更新
	self:_update_daily_quest()
	--每日更新商店
	self:_refresh_normal_shop()
	self.db.shop_f5_times = 3
	self.db.daily_timestamp = now
	--更新每日签到奖励
	self:_update_signin()
	--BOSS挑战刷新BOSS
	self:_refresh_finish_boss()
	self:_refresh_cur_boss()
	--金币抽奖免费次数更新
	self.db.lottery.m_free = 5
	--塔防刷新
	self:_reset_td()
	--设置体力购买次数为0
	self.db.energy_buy_daily = 0
	self.db.fuben_reset_daily = 0
	self:_sync_mc_left_day()
	self:_writedb()
	--点金手使用次数设为0
	self:_set_midas_touch_cnt(0)
	self:_set_midas_con_cnt(0)
	self:_add_sweep_ticket_daily()
	--补充体力值
	self:_tili_recovery()
	
end

function avatar:_writedb()
	db.user_save(self.db)
end

function avatar:_tick_min()
	-- 竞技场恢复ticket
	self:pvp_ticket_recover()

	-- 自动恢复体力
	self:_tili_recovery()

	local date = timer.get_date()
	local now_time	= timer.get_now()
	if date.min == '0' and date.hour == '6' then
		self:_daily_update()
	end
	local hour = date.hour
    if date.min == 0 and ( hour == 12 or hour == 14 or hour == 18 or hour == 20 or hour == 21 or hour == 23 ) then
		self:_update_food()
	end
	for proxy_type, refresh_time in pairs(self.db.next_refresh_time) do
		if refresh_time <= now_time then
			self:_update_goods_by_type( proxy_type )
		end
	end 
end

-- 算战力
function avatar:_recalc_fc()
	local level = self:_get_level()
	local level_data = data.level[level]

	--等级
	self.attack = level_data.attack
	self.crit_level = level_data.crit
	self.max_hp = level_data.hp
	self.defense = level_data.def
	
	--精通
	for i, j in ipairs(self:_get_strength_lv()) do
		local d = data.avatar_strengthen[i*100000 + j]
		local sum_attack = d.sum_attack
		local sum_defense = d.sum_defense
		local sum_crit_level = d.sum_crit_level
		local sum_hp = d.sum_max_hp
		if sum_attack then
			self.attack = self.attack + sum_attack
		end
		if sum_defense then
			self.defense = self.defense + sum_defense
		end
		if sum_crit_level then
			self.crit_level = self.crit_level + sum_crit_level
		end
		if sum_hp then
			self.max_hp = self.max_hp + sum_hp
		end
	end

	--装备
	for k, v in pairs(self.db.equips) do
		--	v.id v.lv
		local i_type = data.item_id[v.id]
		local i_data = data[i_type][v.id]

		-- 激活
		if i_data.act_attack ~= nil then
			self.attack = self.attack + i_data.act_attack
		end	
		if i_data.act_defense ~= nil then
			self.defense = self.defense + i_data.act_defense
		end
		if i_data.act_max_hp ~= nil then
			self.max_hp = self.max_hp + i_data.act_max_hp
		end
		if i_data.act_crit_level ~= nil then
			self.crit_level = self.crit_level + i_data.act_crit_level
		end

		--穿戴
		local ds = data.equipment_strengthen[ i_data.color .. '_' .. i_type]
		if i_data.attack ~= nil then
			self.attack = self.attack + i_data.attack + (ds[v.lv]['attack_sum'] or 0)
		end	
		if i_data.defense ~= nil then
			self.defense = self.defense + i_data.defense + (ds[v.lv]['defense_sum'] or 0)
		end
		if i_data.max_hp ~= nil then
			self.max_hp = self.max_hp + i_data.max_hp + (ds[v.lv]['max_hp_sum'] or 0)
		end
		if i_data.crit_level ~= nil then
			self.crit_level = self.crit_level + i_data.crit_level + (ds[v.lv]['crit_level_sum'] or 0)
		end
	end

	local def_rate = self.defense / (5000 + self.defense)
	if def_rate < 0 then def_rate = 0 end
	if def_rate > 0.88 then def_rate = 0.88 end
	self.def_rate = def_rate

	local crit_rate = self.crit_level / (6000 + self.crit_level)
	if crit_rate < 0.05 then crit_rate = 0.05 end
	if crit_rate > 0.7 then crit_rate = 0.7 end
	self.crit_rate = crit_rate

	local env = {
		a = self,
	}
	setfenv(const.FightingCapacityFormula,env)()
	self.db.fc = math.floor(env.fc)
	--print('fc is ', self.db.fc)
	
	self:_writedb()
end

function avatar:_set_last_login()
	self.db.last_login = timer.get_now()
end

function avatar:_get_fc()
	return self.db.fc
end

function avatar:_get_nick_name()
	return self.db.nick_name
end

function avatar:_set_nick_name(nick_name)
	if nick_name == nil then
		print('nick is nil')
		return
	end
	self:_setdbc('nick_name', nick_name)
end

function avatar:change_nick_name(nick_name)
	if self:_get_diamond() < 100 then
		self.client.message('msg_more_diamond')
		return
	end
	local nick_name_size = 14
	local flag = ''
	if nick_name == nil then
		return
	end	
	local cur_nick_name = self:_get_nick_name()
	if cur_nick_name == nick_name then
		return
	end
	--跟上一次对比，减少查询数据库
	if self.last_nick_name == nil then
		self.last_nick_name = nick_name
	elseif self.last_nick_name == nick_name then
		flag = 'msg_chose_has_used'
	end
	--判断是否合法
	if flag == '' and  nick_name:find("%s+") or utf8_utils.utf8size(nick_name) > nick_name_size then
		flag = 'msg_chose_illegal'
	end
	--判断名字是否已经被用
	if flag == '' then
		local mdb = db.get_mongo()
			local _, tbl = mdb:query(db.TBL_USER, {nick_name = nick_name}, {}, 0, 1)
		if tbl[1] ~= nil then 
			flag = 'msg_chose_has_used'
			self.last_nick_name = nick_name
		end
	end

	if flag ~= '' then 
		self.client.create_avatar_fail(flag)
		return
	end
	self:_add_diamond(-100)
	self:_set_nick_name(nick_name)
	self.client.finish_change_nickname()
end

function avatar:create_avatar(avatar)
	local nick_name_size = 14
	if avatar.nick_name == nil or avatar.role_type == nil then
		return 
	end
	local flag = ''	
	--跟上一次对比，减少查询数据库
	if self.last_nick_name == nil then
		self.last_nick_name = avatar.nick_name
	elseif self.last_nick_name == avatar.nick_name then
		flag = 'msg_chose_has_used'
	end
	--判断是否合法
	if flag == '' and  avatar.nick_name:find("%s+") or utf8_utils.utf8size(avatar.nick_name) > nick_name_size then
		flag = 'msg_chose_illegal'
	end
	--判断名字是否已经被用
	if flag == '' then
		local mdb = db.get_mongo()
			local _, tbl = mdb:query(db.TBL_USER, {nick_name = avatar.nick_name}, {}, 0, 1)
		if tbl[1] ~= nil then 
			flag = 'msg_chose_has_used'
			self.last_nick_name = avatar.nick_name
		end
	end

	if flag ~= '' then 
		self.client.create_avatar_fail(flag)
		return
	end
	self:_set_nick_name(avatar.nick_name)
	self:_setdbc('role_type', avatar.role_type)
	self.client.finish_create_avatar()
end

function avatar:get_player_info(oid)
	if oid == nil then
		return
	end
	local e = all_avatars_oid[oid]
	if e == nil then
		return
	end
	local info = {}
	for k ,_ in pairs(const.MiniInfo) do
		info[k] = e.db[k]	
	end
	self.client.show_player_info(info)
end

function avatar:_tili_recovery()
	local now = timer:get_now()
	local max_tili = 100

	if self.db.energy >= max_tili then
		self:_setdb('last_tili_recover_time', now)
		return
	end

	local time_span = now - self.db.last_tili_recover_time
	local recover_cycle = 5 * 60
	if time_span >= recover_cycle then
		local t = math.floor(time_span / recover_cycle) + self:_get_energy()	
		local spare = time_span % recover_cycle
		if t > max_tili then
			self:_setdbc('energy', max_tili)
		else
			self:_setdbc('energy', t)
		end

		if spare > 0 then
			self:_setdb('last_tili_recover_time', now-spare)
		else
			self:_setdb('last_tili_recover_time', now)
		end
	end
end
