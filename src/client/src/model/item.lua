local combat			= import( 'model.combat' )
local math_ext			= import( 'utils.math_ext' )

item = lua_class( 'item' )

function is_equip(t)
	return t == 'weapon' or t == 'helmet' or t == 'armor' or t == 'necklace' or t == 'ring' or t == 'shoe'
end

function is_material(t)
	return t == 'material' or t == 'item' or t == 'gem'
end

function is_soul_stone(item_type)
	return item_type == 'soul_stone'
end

function is_equip_frag(item_type)
	return item_type == 'equip_frag'
end

function is_equip_qh_stone(item_type)
	return item_type == 'equip_qh_stone'
end

function item:_init(type, id)
	self.type = type
	self.id = id
	self.level = 0
	self.data = data[type][id]
end

function item:get_type()
	return self.type
end

function item:get_id()
	return self.id
end

function item:get_data()
	return self.data
end

function item:get_server_data()
	return self.server_data
end

function item:get_oid()
	return self.server_data._id
end

function item:get_icon()
	return self.data.icon
end

function item:get_name(  )
	return self.data.name
end

function item:get_gold()
	return self.server_data.gold
end

function item:get_diamond()
	return self.server_data.diamond
end

function item:get_number()
	return self.server_data.number
end

function item:get_color()
	return self.data.color
end

function item:is_equip()
	return false
end

function item:init_server_data(item_data)
	self.bag = item_data.bag
	self.number = item_data.number

	self.server_data = item_data
end

equipment = lua_class( 'equipment', item )

function equipment:_init( )
end

function equipment:get_level()
	return self.level
end

function equipment:set_level( lv )
	self.level = lv or 0
end

function equipment:get_prop_key()
	return self.prop_key
end

function equipment:get_prop_value()
	-- 装备上可以附加多少属性
	if self.data_strengthen == nil then
		return 0
	end
	local growth = self.data_strengthen[self.level][self.prop_key .. '_sum'] or 0
	return (self.prop_init + growth)
end

function equipment:get_prop_growth()
	-- 提升到下一级可以提升多少
	if self.data_strengthen == nil then
		return 0
	end
	local growth = self.data_strengthen[self.level][self.prop_key] or 0
	return growth
end

function equipment:get_activate_prop_key()
	return self.act_prop_key
end

function equipment:get_activate_prop_value()
	return self.act_prop_value
end

function equipment:is_equip()
	return true
end

-- function equipment:get_stone_requirement()
function equipment:get_req_qh_stone()
	-- 强化到下一级需要多少碎片
	if self.data_lv == nil then
		return math.huge
	end
	local d = self.data_lv[self.level + 1]
	if d == nil then
		return math.huge
	end
	if d['stone'] then
		return d['stone']
	else
		return 0
	end
end

function equipment:get_req_qh_gold()
	-- 强化到下一级需要多少碎片
	if self.data_lv == nil then
		return math.huge
	end
	local d = self.data_lv[self.level + 1]
	if d == nil then
		return math.huge
	end
	if d['gold'] then
		return d['gold']
	else
		return 0
	end
end

function equipment:init_server_data(item_data)
	--  item_data = { id = n, lv = m }
	local id = tonumber(item_data.id)
	local type = data.item_id[id]
	self.type = type
	self.bag = ''
	self.id = id
	self.level = item_data.lv
	self.data = data[type][id]

	self.server_data = item_data
	self.data_lv = data.equipment_lv[self.data.color]
	self.data_strengthen = data.equipment_strengthen[self.data.color .. '_' .. type]

	if self.data.attack ~= nil then
		self.prop_key = 'attack'
		self.prop_init = self.data.attack
	elseif self.data.defense ~= nil then
		self.prop_key = 'defense'
		self.prop_init = self.data.defense
	elseif self.data.max_hp ~= nil then
		self.prop_key = 'max_hp'
		self.prop_init = self.data.max_hp
	elseif self.data.crit_level ~= nil then
		self.prop_key = 'crit_level'
		self.prop_init = self.data.crit_level
	else
		self.prop_key = 'attack'
		self.prop_init = 0
	end

	if self.data.act_attack ~= nil then
		self.act_prop_key = 'attack'
		self.act_prop_value = self.data.act_attack
	elseif self.data.act_defense ~= nil then
		self.act_prop_key = 'defense'
		self.act_prop_value = self.data.act_defense
	elseif self.data.act_max_hp ~= nil then
		self.act_prop_key = 'max_hp'
		self.act_prop_value = self.data.act_max_hp
	elseif self.data.act_crit_level ~= nil then
		self.act_prop_key = 'crit_level'
		self.act_prop_value = self.data.act_crit_level
	else
		self.act_prop_key = 'attack'
		self.act_prop_value = 0
	end
end


material = lua_class( 'material', item )

function material:init_server_data(item_data)
	self.bag = item_data.bag
	self.number = item_data.number
	self.server_data = item_data
end

function material:get_number( )
	return self.number
end
