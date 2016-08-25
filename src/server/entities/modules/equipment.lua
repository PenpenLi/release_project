local avatar			= import('entities.avatar').avatar
local item				= import('model.item')
local db				= import('db')

function avatar:activate_equip(equip_id)
	equip_id = tonumber(equip_id)

	-- stone cost
	local item_type = data.item_id[equip_id]
	local frag_req, lv, color = self:_get_active_requirement(equip_id)
	if self:_get_equip_frag(color, item_type) < frag_req then
		self.client.message('msg_more_equip_frag')
		return 
	end
	-- level requirment
	if self:_get_level() < lv then
		self.client.message('msg_higher_level')
		return 
	end
	
	-- gain
	self:_add_equip_frag(color, item_type, -frag_req)
	self:_gain_equip(equip_id)

	-- sync
	self:_sync_eq_to_frag(equip_id)
	self:_sync_equips( {tostring(equip_id)} )
	self.client.finish_activate_equip()
end

function avatar:wear_equip(equip_id)
	equip_id = tonumber(equip_id)
	if self:_wear_equip(equip_id) ~= true then
		self.client.message('msg_equip_wear_failed')
		self.client.server_method_failed()
		return
	end

	-- sync
	self:_sync_wearing(equip_id)
	self.client.finish_wear_equip()
end

function avatar:strengthen_equip(equip_id)
	equip_id = tonumber(equip_id)
	local equip_id_str = tostring(equip_id)

	-- already own that equip
	local item_type = data.item_id[equip_id]
	local equip_item = self.db.equips[equip_id_str]
	if equip_item == nil then
		return
	end

	-- stone cost
	local stone_req, gold_req, color = self:_get_qh_stone_requirement(equip_id, equip_item.lv+1)
	if self:_get_equip_qh_stone(color, item_type) < stone_req then
		self.client.message('msg_more_qh_stone')
		return
	end
	-- gold cost
	if self:_get_money() < gold_req then
		self.client.message('msg_more_gold')
		return
	end

	-- level up
	self:_add_equip_qh_stone(color, -stone_req)
	self:_add_money(-gold_req)
	self:_equip_levelup(equip_id_str)
	self:_trigger_quest_event('zhuangBeiQH')
	-- sync
	self:_sync_equips( {equip_id_str} )
	self.client.finish_equip_levelup()
end

-- return eqdata, eqtype
function avatar:_get_equip_data(equip_id)
	local eq_type = data.item_id[equip_id]
	if eq_type == nil then
		return nil, nil
	end
	return data[eq_type][equip_id], eq_type
end

-- return frag_requirement, Lv_requirement, eq_color
function avatar:_get_active_requirement(equip_id)
	local eq_data, eq_type = self:_get_equip_data(equip_id)
	if eq_data == nil then
		return math.huge, math.huge, nil
	end
	local eq_color = eq_data.color
	local eq_type_key = eq_color .. '_' .. eq_type
	local requirement = data.equipment_activation[eq_type_key]
	if requirement == nil then
		return math.huge, math.huge, eq_color
	else
		return requirement, eq_data.Lv, eq_color
	end
end

-- 强化到第N级需要多少强化石,金币
function avatar:_get_qh_stone_requirement(equip_id, level)
	local eq_data = self:_get_equip_data(equip_id)
	if eq_data == nil then
		return math.huge, math.huge, nil
	end
	local color = eq_data.color
	local requirement = data.equipment_lv[color][level]
	if requirement == nil then
		return math.huge, math.huge, color
	end
	local qh_stone = requirement['stone'] or 0
	local qh_gold = requirement['gold'] or 0

	return qh_stone, qh_gold, color
end

function avatar:_gain_equip(equip_id, num)
	local equip_data = self:_get_equip_data(equip_id)
	if equip_data == nil then
		return false
	end
	
	local equip_id_str = tostring(equip_id)
	if self.db.equips[equip_id_str] ~= nil then
		self:_equip_to_frag(equip_id, num)
		return false
	else
		num = (num or 1) - 1
		if num > 0 then
			self:_equip_to_frag(equip_id, num)
		end
		local e = {id=equip_id, lv=0}
		self.db.equips[equip_id_str] = e
		self:_writedb()
		return true
	end
end

function avatar:_equip_to_frag( equip_id, number )
	local eq_data, eq_type = self:_get_equip_data(equip_id)
	if eq_data == nil then
		return
	end
	local eq_color = eq_data.color
	local eq_type_key = eq_color .. '_' .. eq_type
	local requirement = data.equipment_activation[eq_type_key]
	if requirement == nil then
		return
	else
		number = number or 1
		local add_frags = requirement * number
		self:_add_equip_frag(eq_color, eq_type, add_frags)
		return
	end
end

function avatar:_wear_equip(equip_id)
	local equip_id_str = tostring(equip_id)

	local equip_typ = data.item_id[equip_id]
	if equip_typ == nil then
		return false
	end

	local eq = self.db.equips[equip_id_str]
	if eq == nil then
		return false
	end

	self.db.wear[equip_typ] = eq.id
	self:_recalc_fc()
	self:_writedb()
	return true
end

function avatar:_equip_levelup(equip_id_str)
	local equip = self.db.equips[equip_id_str]
	if equip == nil then
		return
	end
	equip.lv = equip.lv + 1
	self:_writedb()
end


-- equipment relative sync

-- deprecated
-- function avatar:_sync_equipment( str_id )

function avatar:_sync_equips( equip_str_ids )
	local equips = {}
	for k, v in pairs(equip_str_ids) do
		table.insert(equips, self.db.equips[v])
	end
	self.client.sync_equips(equips)
end

function avatar:_sync_wearing(equip_id)
	local equip_typ = data.item_id[equip_id]
	if equip_typ ~= nil then
		self.client.sync_one_wear(equip_typ, equip_id)
	end
end

function avatar:_sync_eq_to_frag( equip_id )
	local eq_data, eq_type = self:_get_equip_data(equip_id)
	if eq_data == nil then
		return
	end
	local eq_color = eq_data.color
	local tmp_key = eq_color .. '_' .. eq_type
	self.client.sync_one_equip_frag(tmp_key, self.db.equip_frag[tmp_key])
end
