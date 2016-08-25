local avatar			= import('entities.avatar').avatar
local db				= import('db')


function avatar:_strengthen(strengthen_id)
	local flag = true
	local a_s = data.avatar_strengthen[strengthen_id]
	local s_type = math.floor(strengthen_id/100000)  --获到升级的属性
	local lv = strengthen_id%100   --获取要升级的级数

	if a_s == nil then
		flag = false
		return false
	end	
	--精通等级不能超过强化等级
	if lv > self:_get_level() then
		flag = false
		return false
	end
	--是否够钱
	if a_s.gold ~= nil and a_s.gold > self:_get_money() then
		flag = false
	end
	--是否够物品
	if a_s.item_id ~= nil then
		local has_item = false
		for _, it in pairs(self.bag) do
			if it.id == a_s.item_id then
				has_item = true
				break
			end
		end
		if has_item ~= true then
			flag = false
		end
	end
	if flag ~= true then 
		return false
	end
--[[	--用钱
	if a_s.gold ~= nil then
		self:_add_money(-a_s.gold)
	end
	--用物品
	if a_s.item_id ~= nil then
		local oid = self.item_map[a_s.item_id]
		local it = self.bag[oid]
		it.number = it.number - 1
		if it.number <= 0 then
			self:_del_item(it)
			self.bag[it._id] = nil
			db.item_save(it)
			self.client.del_item(it._id)
		else
			db.item_save(it)
			self.client.sync_items({it})
		end
	end
	self:_strength_up(s_type)
]]
	return flag, a_s.gold, a_s.item_id
end

function avatar:strengthen(strengthen_id)
	strengthen_id = tonumber(strengthen_id)
	local s_type = math.floor(strengthen_id/100000)  --获到升级的属性
	local flag, money, item_id = self:_strengthen(strengthen_id)
	if flag ~= true then
		self.client.strengthen_fail(flag)
	else
		self:_log('strengthen success', 'strengthen id ', strengthen_id)
		self:_trigger_quest_event('jingTongQH')
		if money ~= nil then
			self:_add_money(-money)
		end
		--用物品
		if item_id ~= nil then
			local oid = self.item_map[item_id]
			local it = self.bag[oid]
			it.number = it.number - 1
			if it.number <= 0 then
				self:_del_item(it)
				self.bag[it._id] = nil
				db.item_save(it)
				self.client.del_item(it._id)
			else
				db.item_save(it)
				self.client.sync_items({it})
			end
		end
		self:_strength_up(s_type)

		self.client.strengthen_success(self:_get_strength_lv())
	end
end


function avatar:strengthens(strengthen_id)
	strengthen_id = tonumber(strengthen_id)
	local s_type = math.floor(strengthen_id/100000)  --获到升级的属性
	local lv = strengthen_id%100
	local id = strengthen_id
	local money, item_id, flag 
	local money_sum = 0
	local items_id = {}
	local lv_sum = 0
	for i = 1, 80 do
		flag, money, item_id = self:_strengthen(id)
		if flag == false then
			break
		end
		self:_log('strengthen success', 'strengthen id ',id)
		if money ~= nil then
			money_sum = money_sum + money
		end
		if item_id ~= nil then
			table.insert(items_id, item_id)
		end
		lv_sum = lv_sum + 1
		lv = lv + 1
		id = id + 1
		self:_trigger_quest_event('jingTongQH')
		if lv%10 == 1 then
			break
		end
	end
	if id ~= strengthen_id then
		if money_sum ~= nil and money_sum ~= 0 then
			self:_add_money(-money_sum)
		end
		--用物品
		if items_id ~= nil then
			for _, item_id in pairs(items_id) do
				local oid = self.item_map[item_id]
				local it = self.bag[oid]
				it.number = it.number - 1
				if it.number <= 0 then
					self:_del_item(it)
					self.bag[it._id] = nil
					db.item_save(it)
					self.client.del_item(it._id)
				else
					db.item_save(it)
					self.client.sync_items({it})
				end
			end
		end
		self:_strength_up_more(s_type, lv_sum)

		self.client.strengthen_success(self:_get_strength_lv())
	else
		self.client.strengthen_fail(flag)
	end
end 
