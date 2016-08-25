local avatar			= import('entities.avatar').avatar
local timer				= import('model.timer')



function avatar:_deduct_money_rmb(money)
	return true
end
--这个是vip的相关函数，暂时写在这里
function avatar:_vip_update( diamond_num )
	local lv		= self.db.vip.lv
	local num		= diamond_num + self.db.vip.diamond 
	
	for i = lv + 2, 80 do
		if data.vip[i] ~= nil and data.vip[i].sum_diamond <= num then
			self.db.vip.lv = self.db.vip.lv + 1
		else 
			break
		end
	end
	self.db.vip.diamond  = num 	
	self.client.sync_vip(self.db.vip)
	self:_writedb()
end

function avatar:_sync_mc_left_day()
	self.client.sync_mc_left_day(timer.count_day(timer.get_now(),self.db.month_card) + 1)
end

function avatar:buy_energy( )
	if self.db.energy_buy_daily == nil then
		self.db.energy_buy_daily = 0
	end
	local daily_buy_time = data.vip[self:_get_vip_lv() + 1].energy_max
	if self.db.energy_buy_daily  >= daily_buy_time then
		self.client.add_limit_msg('buy_time_limit')
	end
	local buy_data = data.energy_purchase[self.db.energy_buy_daily + 1]
	if self:_get_diamond() < buy_data.diamond then
		self.client.add_limit_msg('diamond_limit')
	else
		self:_add_energy_buy_daily( )
		self:_add_diamond(-buy_data.diamond)
		self:_add_energy(buy_data.energy)
		self.client.add_limit_msg('buy_success')
	end
end

function avatar:buy_from_mall(good_id)
	local good = data.mall[good_id]
	local good_id_str = tostring(good_id)
	if self.db.mall[good_id_str] ~= nil and good.can_buy_count <= self.db.mall[good_id_str] then
		return 
	end

	if good == nil then
		return
	end
 
	if self:_deduct_money_rmb(good.price) then
		if good.good_type == 1 then
			if self.db.month_card == nil then
				self.db.month_card = 0
			end
			local end_time	= self.db.month_card
			local now_time		= timer.get_now()
			local new_end_time	= 0
			if timer.compare_two_date(end_time,now_time) < 0 then
				new_end_time = timer.count_end_timestamp(now_time,29)
				self.db.month_card = new_end_time
				self:_update_food()
			else
				new_end_time	= timer.count_end_timestamp(end_time,30)
				self.db.month_card = new_end_time
				local cnt = timer.count_day(now_time, new_end_time) + 1
				self:_trigger_quest_event('yueKa', cnt)
			end		
			self:_sync_mc_left_day()	
		elseif good.good_type == 2 then
			if good.diamond ~= nil then
				self:_add_diamond(good.diamond)
			end
			if good.diamond_send ~= nil then
				self:_add_diamond(good.diamond_send)
			end 
		end
		if good.can_buy_count ~= nil then
			if self.db.mall[good_id_str] == nil then
				self.db.mall[good_id_str] = 1
			else
				self.db.mall[good_id_str] = self.db.mall[good_id_str] + 1
			end
			self.client.sync_one_mall_count(good_id_str,self.db.mall[good_id_str])
		end
		self:_vip_update(good.price * 10) 	
		self.client.add_limit_msg('buy_success')
	end
	self:_writedb()
end

