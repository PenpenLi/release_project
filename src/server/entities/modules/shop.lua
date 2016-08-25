local avatar			= import('entities.avatar').avatar
local item				= import('model.item')
local db				= import('db')
local utils				= import('utils')

function avatar:buy_normal_item(item_oid)
	local flag = true
	local buy_result
	local buying_item = self.shop1[item_oid]

	if buying_item == nil then
		buy_result = 'msg_shop_sold_out'
		flag = false
	else
		-- 有货
		if buying_item.gold ~= nil then
			--需要钱
			if buying_item.gold <= self:_get_money() then
				self:_add_money(-buying_item.gold)
			else
				buy_result = 'msg_more_gold'
				flag = false
			end
		end

		if buying_item.diamond ~= nil then
			-- 需要钻
			if buying_item.diamond <= self:_get_diamond() then
				self:_add_diamond(-buying_item.diamond)
			else
				buy_result = 'msg_more_diamond'
				flag = false
			end
		end
	end

	if flag ~= true then
		self.client.message( buy_result )
		return
	else
		-- gain item
		buying_item.bag = ''
		buying_item.gold = nil
		buying_item.diamond = nil
		self.shop1[item_oid] = nil

		if item.is_material(buying_item.type) then
			-- buying_item transfering
			local bag_item_oid = self.item_map[buying_item.id]
			local bag_item = self.bag[bag_item_oid]
			if bag_item ~= nil then
				print('bag_item')
				bag_item.number = bag_item.number + buying_item.number
				db.item_save(buying_item)
				db.item_save(bag_item)
				self.client.sync_items({bag_item})
			else
				print('bag_item 2')
				buying_item.bag = 'bag'
				self.bag[item_oid] = buying_item
				db.item_save(buying_item)
				self:_add_item_map(buying_item)
				self.client.sync_items({buying_item})
			end
			self.client.show_gain_msg({{id = buying_item.id, number = buying_item.number}})
		else
			-- virtual item( stones and equipments )
			self:_gain_item(buying_item.id, buying_item.number)
			self.client.show_gain_msg({{id = buying_item.id, number = buying_item.number}})
		end

		self:_sync_shops()
	end
	--TODO: need finish_shopping callback?
end

function avatar:refresh_shop1()
	local refresh_times = self:_get_shop_f5_times()
	if refresh_times == nil or refresh_times <= 0 then
		self.client.message('msg_shop_no_refreshtime', { times = 3 })
		return
	end

	self:_add_shop_f5_times(-1)
	self:_refresh_normal_shop()
	self:_sync_shops()
end

function avatar:_clear_normal_shop()
	if self.shop1 == nil then
		return
	end
	for item_oid, it in pairs(self.shop1) do
		self.shop1[item_oid] = nil
		self:_del_item(it)
		db.item_save(it)
	end
end

function avatar:_refresh_normal_shop()
	local d = self:_get_shop_config('shop1')
	if d == nil then
		dbglog('shop', 'refresh with nil data', self:_get_level())
		return
	end

	--start refresh
	self:_clear_normal_shop()

	local goods = {}
	local weights = {}

	local function generator(i)
		local n = d['num_'..i]
		if n == nil then
			return 
		end
		for id, w in pairs(d['rand_'..i]) do
			table.insert(goods, id)
			table.insert(weights, w)
		end
		if #goods < n then
			dbglog('shop', 'config error', i)
			return 
		end

		for j = 1, n do
			local idx = utils.weight_random(weights)
			local id_str = goods[idx]
			local info = data.store_item[tonumber(id_str)]
			if info ~= nil then
				local it = item.create_virtual_item(self:_get_oid(), info.item, info.item_num, 'shop1')
				it.gold = info.gold
				it.diamond = info.diamond
				self.shop1[it._id] = it
				db.item_save(it)
			end
			table.remove(weights, idx)
			table.remove(goods, idx)
		end
		goods = {}
		weights = {}

		return
	end

	for k = 1, 3 do
		generator(k)
	end

end

function avatar:_sync_shops()
	self.client.sync_shop1(self.shop1)
end

function avatar:_get_shop_config(shop_type)
	local key_lv_list = 'shop1_level_list'
	local key_shop_conf = 'shop1'
	if shop_type == 'shop2' then
		key_lv_list = 'shop2_level_list'
		key_shop_conf = 'shop2'
	end
	local conf_id = data[key_lv_list][self:_get_level()]
	return data[key_shop_conf][conf_id]
end

