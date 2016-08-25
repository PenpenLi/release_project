local avatar			= import('entities.avatar').avatar
local utils				= import('utils')
local item				= import('model.item')
local rmb_cost			= import('model.rmb_cost')

local _star_space = 1000

function avatar:_get_fuben_daily(star_id)
	local bid = tostring(star_id)
	local time = self.db.fuben_daily[bid]
	if time == nil then
		return 0
	end
	return time
end

function avatar:_add_fuben_daily(star_id)
	local bid = tostring(star_id)
	local time = self.db.fuben_daily[bid]
	if time == nil then
		time = 0
	end
	self.db.fuben_daily[bid] = time + 1
	self:_writedb()
	self.client.sync_one_fuben_daily(bid,self.db.fuben_daily[bid])
end

function avatar:reset_one_fuben_daily(elite_fuben_id)
	local fuben_data = data.fuben[elite_fuben_id]
	local fuben_id	= fuben_data.instance_id
	local chapter_id	= fuben_data.chapter_id
	local star_id = chapter_id * _star_space + fuben_id
	local bid	= tostring(star_id)
	local reset_time_daily = self:_get_vip_reset_JY_time()
	if reset_time_daily <= self.db.fuben_reset_daily then
		self.client.add_limit_msg( 'reset_time_limit' )
		return 
	end
	self:_setdbc('fuben_reset_daily', self.db.fuben_reset_daily + 1)
	self.db.fuben_daily[bid] = 0
	self:_writedb()
	self.client.sync_one_fuben_daily(bid,self.db.fuben_daily[bid])
	self.client.server_method_finished()
end

function avatar:_verify_battle_id(battle_id)
	local d = data.fuben[battle_id]
	local fuben_id = d.instance_id
	local chapter_id = d.chapter_id
	local star_id = chapter_id * _star_space + fuben_id
	
	if d == nil then
		return false
	end
	local pre_barrier = d.pre_barrier
    if pre_barrier ~= nil then
		for i,v in pairs(pre_barrier) do
			if v > 3000 and v < 5000 then 
				if v > self.db.elite_fuben then 
					return false
				end
			elseif v > 1000 and v < 3000 then 
				if v > self.db.fuben then
					return false
				end
			else 
				return false
			end
		end
	end

	if d.type == 'JY' then
		if self.db.elite_fuben == 0 and d.id ~= 3001 then
			return false
		end
	elseif d.type == nil then
		if self.db.fuben ~= 0 and d.id - 1 > self.db.fuben then
            return false
        elseif self.db.fuben == 0 and d.id ~= 1001 then
            return false
        end
	elseif d.type == 'towerdefense' then
		if self.db.td_fuben ~= 0 and d.id - 1 > self.db.td_fuben then
			return false
		elseif self.db.td_fuben == 0 and d.id ~= 7000 then
			return false
		end
	end
	if d.lv_limit ~= nil and self:_get_level() < d.lv_limit then
		return false
	end
	if d.daily_limit ~= nil and self:_get_fuben_daily(star_id) >= d.daily_limit then
		return false
	end
	return true
end

function avatar:_verify_energy_for_fuben(battle_id)
	local d = data.fuben[battle_id]
	if d == nil then
		return false
	end
	if d.energy ~= nil and self:_get_energy() < d.energy then
		return false
	end
	return true
end

function avatar:begin_battle(battle_id)
	local d = data.fuben[battle_id]
	local fuben_id = d.instance_id
	local chapter_id = d.chapter_id
	local star_id = chapter_id * _star_space + fuben_id	

	if not self:_verify_battle_id(battle_id) then
		self.client.battle_limited()
		return
	end
	if not self:_verify_energy_for_fuben(battle_id) then
		self.client.battle_limited()
		return
	end
	self:_add_fuben_daily(star_id)
	if d.energy ~= nil then
		self:_add_energy(-d.energy)
	end

	self.fuben_token = math.random(99999999999999)

	self:_log('battle', 'begin', star_id .. '-' .. battle_id)
	self.client.battle(battle_id, self.fuben_token)
end

function avatar:battle_finish(battle_id, status)
	local d = data.fuben[battle_id]
	local fuben_id = d.instance_id
	local chapter_id = d.chapter_id
	local star_id = chapter_id * _star_space + fuben_id
	if status.ft ~= self.fuben_token then
		return
	end
	if status.star == nil then
		return
	end
	if not self:_verify_battle_id(data.fuben_entrance[chapter_id][fuben_id]) then
		return
	end
	self:_add_money(d.gold)
	self:_add_exp(d.exp)
	self:_add_diamond(d.diamond)
	--战灵经验
	for _, v in pairs(self.db.loaded_skills) do
		if v ~= nil and v > 0 then
			self:_add_soul_exp(tostring(v), d.soul_exp)
		end
	end

	--掉落
	local items = {}
	local fuben_pre_id
	if d.type == nil then
		fuben_pre_id = self.db.fuben
	elseif d.type == 'JY' then
		fuben_pre_id = self.db.elite_fuben
	elseif d.type == 'towerdefense' then
		fuben_pre_id = self.db.td_fuben 
	end
	if fuben_pre_id < battle_id and d.first_drop ~= nil then
		for _, store_item_id in pairs(d.first_drop) do
			local drop_item = data.store_item[store_item_id].item
			local item_num  = data.store_item[store_item_id].item_num
			local t_item = self:_gain_item(drop_item, item_num)
			if t_item ~= nil then
				table.insert(items, t_item)
				if item.is_equipment(t_item.type) then
					self:_sync_eq_to_frag(drop_item)
				end
			end
		end
	end
	if d.drop ~= nil then
		for i, v in pairs(d.drop) do
			local tmp_arr = {}
			for idx, dat in pairs(v) do
				table.insert(tmp_arr, idx, dat)
			end
			local store_item_id = utils.weight_random(tmp_arr)
				if store_item_id ~= 0 then
				local drop_item = data.store_item[store_item_id].item
				local item_num  = data.store_item[store_item_id].item_num
				local t_item = self:_gain_item(drop_item, item_num)
				if t_item ~= nil then
					table.insert(items, t_item)
					if item.is_equipment(t_item.type) then
						self:_sync_eq_to_frag(drop_item)
					end
				end
			end
		end
	end
	
	local status = {
		items = items,
	}
	self.fuben_token = math.random(99999999999999)
	local itlog = ''
	for _, it in pairs(items) do
		itlog = itlog .. cjson.encode(it)
	end
	self:_log('battle', 'finish', star_id .. '-' .. battle_id, status.star, itlog)
	if d.type == nil then
		if self.db.fuben < battle_id then
			self.db.fuben	= battle_id
		end
		self:_trigger_quest_event('puTong')
		self:_trigger_quest_event('PT' .. chapter_id .. '.' .. fuben_id )
	elseif d.type == 'towerdefense' then
		self:_trigger_quest_event('TD')
		self:_trigger_quest_event('puTong')
		if self.db.td_fuben <  battle_id then
			self.db.td_fuben = battle_id
		end
	elseif d.type == 'JY' then
		if self.db.elite_fuben < battle_id then
			self.db.elite_fuben	= battle_id
		end
		self:_trigger_quest_event('puTong')
		self:_trigger_quest_event('jingYing')
		self:_trigger_quest_event('JY' .. chapter_id .. '.' .. fuben_id)
	end
	self.client.sync_fuben(self.db.fuben)
	self.client.sync_elite_fuben(self.db.elite_fuben)
	self.client.sync_items(items)
	self.client.battle_finish(battle_id, status)
end

function avatar:tutor_done()
	self.is_new_user = false
end

function avatar:rebirth_rightnow()
	local diamond_cost = rmb_cost.get_cost_by_id(8)
	if self:_get_diamond() < diamond_cost then
		self.client.message('msg_more_diamond')
		self.client.server_method_failed()
		return
	end
	self:_add_diamond( -diamond_cost )
	self.client.player_can_rebirth()
end

function avatar:sweep(battle_id, sweep_times, vip)
	if sweep_times > 10 then
		return 
	end
	local d = data.fuben[battle_id]
	local d_star = d
	local energy = d.energy * sweep_times
	local reword = {}
	local chapter_id = d.chapter_id
	local fuben_id	 = d.instance_id
	local star_id = chapter_id * _star_space + fuben_id 

	if d.type ~= nil and d.type ~= 'JY' then
		return 
	end

	while d.ai_conf ~= 'fubenAI_putong_victory' do
		d = data.fuben[d.next_barrier]
		if d == nil or d.id - battle_id > 3 then
			return
		end
	end
	self.db.fuben_daily[tostring(star_id)] = self.db.fuben_daily[tostring(star_id)] or 0
	if d_star.daily_limit ~= nil and (self.db.fuben_daily[tostring(star_id)] + sweep_times) > d_star.daily_limit then
		self.client.add_limit_msg( 'daily_battle_time_limit' )
		return 
	end
	if self.db.vip.lv < vip then
		self.client.add_limit_msg( 'vip_lv_limit' )
		return
	end
	if (d_star.type == nil and d_star.id > self.db.fuben) or (d_star.type == 'JY' and d_star.id > self.db.elite_fuben) then
		return
	end
	if self:_get_energy() < energy then
		self.client.add_limit_msg( 'energy_limit' )
		return
	end
	if self:_get_sweep_ticket() < sweep_times then
		self.client.add_limit_msg( 'sweep_ticket_limit' )
		return
	end
	
	self:_add_energy(-energy) 
	self:_add_sweep_ticket(-sweep_times)
	
	self:_add_money(d.gold * sweep_times)
	self:_add_exp(d.exp * sweep_times)
	self:_add_diamond(d.diamond * sweep_times)
	local items = {} 
	for i = 1, sweep_times do
		if d.type == nil then
			if self.db.fuben < battle_id then
				self.db.fuben   = battle_id
			end 
			self:_trigger_quest_event('puTong')
			self:_trigger_quest_event('PT' .. chapter_id .. '.' .. fuben_id )
	    elseif d.type == 'towerdefense' then
		    self:_trigger_quest_event('TD')
			self:_trigger_quest_event('puTong')
			if self.db.td_fuben <  battle_id then
			    self.db.td_fuben = battle_id
		    end 
		elseif d.type == 'JY' then
			if self.db.elite_fuben < battle_id then
		        self.db.elite_fuben = battle_id
		    end  
			self:_trigger_quest_event('puTong')
			self:_trigger_quest_event('jingYing')
		    self:_trigger_quest_event('JY' .. chapter_id .. '.' .. fuben_id)
	    end
		reword[i] = {}
		if d.drop ~= nil then
			for _, v in pairs(d.drop) do
				local tmp_arr = {}
				for idx, dat in pairs(v) do
					table.insert(tmp_arr, idx, dat)
				end
				local store_item_id = utils.weight_random(tmp_arr)
				if store_item_id ~= 0 then
					local drop_item = data.store_item[store_item_id].item
					local item_num  = data.store_item[store_item_id].item_num
					local t_item = self:_gain_item(drop_item, item_num)
					table.insert(reword[i],{drop_item, item_num})
					if t_item ~= nil then
						table.insert(items, t_item)
						if item.is_equipment(t_item.type) then
							self:_sync_eq_to_frag(drop_item)
						end
					end
				end
			end
		end
		self:_add_fuben_daily(star_id)
	end
	local ex_reward = {}
	if d.extra_reward ~= nil then
		for i,v in pairs(d.extra_reward) do
			self:_gain_item(v[1],v[2] * sweep_times)
			table.insert(ex_reward,{v[1], v[2] * sweep_times})
		end
	end
	self.client.sync_items(items)
	self.client.finish_sweep(d.id, reword, ex_reward)
	self.client.server_method_finished()
end
