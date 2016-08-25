local avatar_main		= import( 'entities.avatar' )
local timer				= import( 'model.timer' )
local exchange_const	= import( 'const.exchange_mall_const' )

avatar					= avatar_main.avatar

function avatar:_mall_weight_random( good_table )
	local sum = 0
	for i, v in pairs(good_table) do
		sum = sum + data.exchange_mall[v].refresh_weight
	end
	local rand = math.random(sum)
	for i, v in pairs(good_table) do
		if rand <= data.exchange_mall[v].refresh_weight then
			return v
		else
			rand = rand - data.exchange_mall[v].refresh_weight
		end
	end
end

function avatar:_find_goods_at_position( position_count, good_table )
	local good_id_str = ''
	local position_table = {}
	for j = 1, position_count do
		position_table[j] = {}
	end
	for i, good in pairs(good_table) do
		if good.position[1] <= 0 then
			for j = 1, position_count do
				good_id_str = tostring(good.id)
				position_table[j][good_id_str] = good.id
			end
			if good.position[1] < 0 then
				for k, position in pairs(good.position) do
					good_id_str	= tostring(good.id)
					position_table[position] = position_table[position] or {}
					position_table[-position][good_id_str] = nil
				end
			end
		else
			for  k, position in pairs(good.position) do
				good_id_str = tostring(good.id)
				position_table[position] = position_table[position] or {}
				position_table[position][good_id_str] = good.id
			end
		end
	end
	return position_table
end

function avatar:_refresh_exchange_goods( proxy_type )
	self.db.exchange_goods[proxy_type]	= {}
	local random_weight		= 0
	local good_id_str		= ''
	local good_table		= {}
	local suit_good_table	= {}
	local goods_has_add		= {}
	for i, good in pairs(data.exchange_mall) do
		if good.good_type == proxy_type  and good.lv_limit[1] <= self.db.lv and self.db.lv < good.lv_limit[2] then
			good_id_str = tostring(good.id)
			good_table[good_id_str] = good
		end
	end
	local position_table	= self:_find_goods_at_position( exchange_const.shop_count[proxy_type], good_table  )
	for i = 1, exchange_const.shop_count[proxy_type] do
		for j, good in pairs(goods_has_add) do
			good_id_str = tostring(good)
			position_table[i][good_id_str] = nil
		end
		local flag = false
		for j, good_id in pairs(position_table[i]) do
			local good	= data.exchange_mall[good_id]
			if good.refresh_weight == 1000 then 
				good_id_str = tostring(good_id)
				self.db.exchange_goods[proxy_type][good_id_str] = {p = i, f = 0}
				goods_has_add[good_id_str] = good_id
				flag = true
				break
			end
		end
		if (not flag) then
			local good_id =	self:_mall_weight_random(position_table[i])
			if good_id ~= nil then
				good_id_str	= tostring(good_id)
				self.db.exchange_goods[proxy_type][good_id_str] =  {p = i, f = 0}
				goods_has_add[good_id_str] = good_id
			end
		end
	
	end
end

function avatar:_sync_exchange_mall_by_type( proxy_type, ex_good_table )
	self.client.sync_exchange_mall_by_type( proxy_type, ex_good_table )
end

function avatar:_sync_exchange_mall()
	self.client.sync_exchange_mall(self.db.exchange_goods)
end

function avatar:refresh_by_proxy_money( proxy_type )
	if self.db.proxy_money[proxy_type] < exchange_const.RefreshMoneyCost[proxy_type] then
		self.client.refresh_limit()
		return
	end
	self.db.proxy_money[proxy_type] = self.db.proxy_money[proxy_type] - exchange_const.RefreshMoneyCost[proxy_type]
	self.client.sync_one_proxy_money(proxy_type, self.db.proxy_money[proxy_type])
	self:_refresh_exchange_goods( proxy_type )
	self:_sync_exchange_mall_by_type(proxy_type, self.db.exchange_goods[proxy_type])
end

function avatar:buy_from_exchange_mall( good_id )
	local good	= data.exchange_mall[good_id]
	local good_id_str	= tostring(good_id)
	local exchange_good	= self.db.exchange_goods[good.good_type][good_id_str]
	if self.db.proxy_money[good.good_type] < good.price or exchange_good == nil or exchange_good.f == 1 then
		self.client.buy_limit()
		return 
	end
	self.db.proxy_money[good.good_type] = self.db.proxy_money[good.good_type] - good.price
	self:_gain_item( good.item_id, good.sell_num )
	self.db.exchange_goods[good.good_type][good_id_str].f	= 1
	self.client.sync_one_proxy_money(good.good_type, self.db.proxy_money[good.good_type])
	self:_sync_exchange_mall_by_type( good.good_type, self.db.exchange_goods[ good.good_type ] )
end

function avatar:_time_str_to_sec()
	self.refresh_time_sec	= {}
	for proxy_type,refresh_time in pairs(exchange_const.RefreshTime) do
		self.refresh_time_sec[proxy_type]	= {}
		for k, v in pairs(refresh_time) do
			local i,j	= string.find(v,':')
			local hour	= string.sub(v,1,i - 1)
			local min	= string.sub(v,i + 1,-1)
			table.insert(self.refresh_time_sec[proxy_type],tonumber( hour - timer.DAY_START_HOUR ) * timer.SECONDS_PER_HOUR + tonumber(min) * 60)
		end
	end
end

function avatar:_update_goods_by_type( proxy_type )
	local now_time	= timer.get_now()
	local day_pass_sec =timer.get_day_pass_sec()
	if self.db.refresh_time_sec == nil then
		self:_time_str_to_sec()
	end
	if self.db.next_refresh_time[proxy_type] == nil or self.db.next_refresh_time[proxy_type] <= now_time then
		local j = 0
		local flag  = false
        for i, v in pairs(self.refresh_time_sec[proxy_type]) do
            j = i
            if day_pass_sec < v then
                flag    = true
                break
            end
        end
        if flag then
            self.db.next_refresh_time[proxy_type]   = timer.get_day_zero_sec() + self.refresh_time_sec[proxy_type][j]
        else
            self.db.next_refresh_time[proxy_type]   = timer.get_day_zero_sec() + self.refresh_time_sec[proxy_type][1] + timer.SECONDS_PER_DAY
        end
        self:_refresh_exchange_goods ( proxy_type )
		if not self.refresh_all then
			self:_sync_exchange_mall_by_type( proxy_type, self.db.exchange_goods[proxy_type] )
		end
	end
end

function avatar:_update_exchange_mall()
	
	self.refresh_all	= true
	for proxy_type, v in pairs(exchange_const.RefreshTime) do
		if self.db.proxy_money[proxy_type] == nil then
			self.db.proxy_money[proxy_type] = 0
			self:_setdb('proxy_money',self.db.proxy_money) 
		end
		self:_update_goods_by_type( proxy_type )
	end 
	self.refresh_all	= false
end



