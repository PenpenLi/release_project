local avatar			= import('entities.avatar').avatar
local item				= import('model.item')
local db				= import('db')

--背包类型
--none
--bag			背包或身上
--shop1			商店
--shop2
--shop...
--

function avatar:batch_use_items(item_oid,usage)
	if type(usage) ~= 'table' then
		return
	end
	for k, v in pairs(usage) do
		self:_use_item(item_oid, v.n, v.s)
	end
	self.client.finish_batch_use_items()
end

function avatar:use_item(item_oid, number, for_soul)
	self:_use_item(item_oid, number, for_soul)
	self.client.finish_use_item()
end

function avatar:_use_item(item_oid, number, for_soul)
	-- item can only be used when it's in bag
	local it = self.bag[item_oid]
	if it == nil then
		return
	end

	if item.is_usable_item(it.type) then
		local d = data[it.type][it.id]
		if d == nil then
			return
		end

		number = number or 1
		if it.number < number then
			self.client.message('msg_item_not_enough')
			return
		end

		local is_used = false
		if d.energy ~= nil then
			self:_add_energy(d.energy * number)
			is_used = true
		end
		if d.exp ~= nil then
			self:_add_exp(d.exp * number)
			is_used = true
		end
		if d.soul_exp ~= nil and for_soul ~= nil then
			self:_add_soul_exp(tostring(for_soul), d.soul_exp * number)
			is_used = true
		end

		if is_used == true then
			it.number = it.number - number
		end
		if it.number == 0 then
			self:_del_item(it)
			self.bag[item_oid] = nil
			db.item_save(it)
			self.client.del_item(it.id)
		else
			db.item_save(it)
			self.client.sync_items({it})
		end
	end
end

function avatar:_get_item_oid_by_id( id )
	return self.item_map[id]
end


function avatar:_get_item_num_by_id( id )
	--	限于背包中的物品
	local oid	= self:_get_item_oid_by_id( id )
	local item	= self.bag[oid]
	if item	~= nil  then
		return item.number
	else
		return 0
	end
end

function avatar:sell_item( item_id, num )

	local item_type	= data.item_id[item_id]
	local item		= data[item_type][item_id]
	local item_num
	if item_type == 'equip_frag' then
		item_num	= self:_get_equip_frag(item.color, item.position)		
		
	elseif item_type == 'equip_qh_stone' then
		item_num	= self:_get_equip_qh_stone( item.color )

	elseif item_type == 'soul_stone' then
		item_num	= self:_get_soul_frag(item.soul_id)
	else 
		item_num	= self:_get_item_num_by_id( item_id )
	end
	
	if item_num < num then
		return
	end
	self:_gain_item( item_id, -num )

	if item_num == num then
		self:_del_item_by_id( item_id )
	end
	local price	= data[item_type][item_id].price
	if price ~= nil then
		self:_add_money( price * num )
	end
	self.client.server_method_finished()
end

function avatar:_del_item_by_id( item_id )
	local item_type = data.item_id[item_id]
	local item		= data[item_type][item_id]
	if item_type == 'equip_frag' then
		self.db.equip_frag[item.color .. '_' .. item.position] = nil
	elseif item_type == 'equip_qh_stone' then
		self.db.equip_qh_stone[item.color] = nil
	elseif item_type == 'soul_stone' then
		self.db.soul_frag[item.soul_id] = nil
	else
		local oid	= self:_get_item_oid_by_id( item_id )
		local it	= self.bag[oid]
		self:_del_item( it )
		db.item_save( it )
	end
	self.client.del_item( item_id )
	self.client.server_method_finished()
end

function avatar:_del_item(item_object)
	self.item_map[item_object.id] = nil
	item_object.owner_oid = nil
	self.bag[item_object._id] = nil
	self.garbage[item_object._id] = item_object
end

function avatar:change_equip(item_oid)
	local it = self.bag[item_oid]
	if it == nil then
		return
	end
	self.db.wear[it.type] = {_=item_oid}
	self.client.change_equip(item_oid)
end

function avatar:_gain_item(item_id, item_num)
	local item_type = data.item_id[item_id]
	item_num = item_num or 1
	if item.is_equipment(item_type) then
		self:_gain_equip(item_id, item_num)
		self:_sync_equips( {tostring(item_id)} )
		local it = item.create_virtual_item(self.db._id, item_id, item_num)
		return it
	elseif item.is_soul_stone(item_type) then
		local d = data.soul_stone[item_id]
		if d ~= nil then
			self:_add_soul_frag(d.soul_id, item_num)
		end
		
		local it = item.create_virtual_item(self.db._id, item_id, item_num)
		return it
	elseif item.is_equip_frag(item_type) then
		local d = data.equip_frag[item_id]
		if d ~= nil then
			self:_add_equip_frag(d.color, d.position, item_num)
		end
		
		local it = item.create_virtual_item(self.db._id, item_id, item_num)
		return it
	elseif item.is_equip_qh_stone(item_type) then
		local d = data.equip_qh_stone[item_id]
		if d ~= nil then
			self:_add_equip_qh_stone(d.color, item_num)
		end
		
		local it = item.create_virtual_item(self.db._id, item_id, item_num)
		return it
	elseif item.is_proxy_money(item_type) then
		local d = data.token_coin[item_id]
		if d ~= nil then
			self:_add_proxy_money(d.type, item_num)
		end
		local it = item.create_virtual_item(self.db._id, item_id, item_num)
		return it
	elseif item.is_material(item_type) then
		-- 放背包的物品
		local item_oid = self.item_map[item_id]
		it = self.bag[item_oid]
		if it ~= nil then
			it.number = it.number + item_num
		else 
			it = item.create_material(self.db._id, item_id, item_num)
			it.bag = 'bag'
			self.bag[it._id] = it
			self:_add_item_map(it)
		end
		db.item_save(it)
		self.client.sync_items({it})
		return it
	elseif item.is_soul(item_type) then
		local d = data.soul[item_id]
		if d ~= nil and d.soul_id ~= nil then
			local s = self.db.skills[tostring(d.soul_id)]
			if s == nil then
				self:_gain_skill(d.soul_id)
				s = self.db.skills[tostring(d.soul_id)]
				self.client.update_skill(s)
				local it = item.create_virtual_item(self.db._id, item_id, item_num)
				return it
			else
				self:_regain_skill_to_frags(d.soul_id)
				local it = item.create_virtual_item(self.db._id, item_id, item_num)
				it.exist = 1 -- soul regain flag
				return it
			end	
		end
	elseif item.is_sweep(item_type) then
		local d = data.sweep[item_id]
		if d ~= nil then
			self:_add_sweep_ticket()
		end
		local it = item.create_virtual_item(self.db._id,  item_id, item_num)
		return it
	end
	return
end

function avatar:_gain_items(item_ids, item_num)
	for _, item_id in pairs(item_ids) do
		self:_gain_item(item_id, item_num)
	end
end

function avatar:_sync_items(login_sync)
	local items = {}
	for id, it in pairs(self.bag) do
		table.insert(items,it)
		if #items == 10 then
			self.client.sync_items(items, login_sync)
			table_clear(items)
		end
	end
	if #items > 0 then
		self.client.sync_items(items, login_sync)
	end
end

function avatar:_set_item_level(item_oid, lv)
	local it = self.bag[item_oid]
	if not item.is_equipment(it.type) then
		return
	end
	it.level = lv
	db.item_save(it)
	self.client.sync_items({it})
end

function avatar:_add_item_map(it)
	-- 只对背包有效
	if it.bag ~= 'bag' then
		return
	end
	if self.item_map[it.id] ~= nil then
		dbglog('item', 'mapping conflict!', it.id, oid_to_str(it._id), oid_to_str(self.item_map[it.id]))
	end
	self.item_map[it.id] = it._id
end

