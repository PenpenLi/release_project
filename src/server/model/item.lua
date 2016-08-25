local db		= import('db')
local utils		= import('utils')

--此方法不存盘
function create_equipment(owner_oid, item_id)
	if owner_oid == nil then
		dbglog('item', '不能创建没有归属的物品')
	end
	local item_type = data.item_id[item_id]
	local conf = data[item_type][item_id]
	local tbl = {
		_id = db.gen_oid(),
		id = item_id,
		type = item_type,
		bag = 'none',
		owner_oid = owner_oid,
		level = 0,
		main_attr = {type=conf.main_prop_key, init=conf.main_prop_init, growth=conf.main_prop_growth, },
		add_attr = {
		},
	}
	local attr = tbl.add_attr
	if conf.append_1 ~= nil then
		local get_prop =  _throw_dice_deter_prop( conf.append_1 )
		attr['1'] = {type=get_prop[1], init=get_prop[2],}
		-- attr['1'] = {type=conf.prop_1, init=conf.prop_init_1, growth=conf.prop_growth_1,}
	end
	if conf.append_2 ~= nil then
		local get_prop = _throw_dice_deter_prop( conf.append_2 )
		attr['2'] = {type=get_prop[1], init=get_prop[2],}
	end
	if conf.append_3 ~= nil then
		local get_prop =  _throw_dice_deter_prop( conf.append_3 )
		attr['3'] = {type=get_prop[1], init=get_prop[2],}
	end
	if conf.append_4 ~= nil then
		local get_prop = _throw_dice_deter_prop( conf.append_4 )
		attr['4'] = {type=get_prop[1], init=get_prop[2],}
	end

	return tbl
end

function create_material(owner_oid, item_id, number)
	if owner_oid == nil then
		dbglog('item', '不能创建没有归属的物品')
	end
	local item_type = data.item_id[item_id]
	local conf = data[item_type][item_id]
	local tbl = {
		_id = db.gen_oid(),
		id = item_id,
		type = item_type,
		bag = 'none',
		owner_oid = owner_oid,
		number = number,
	}
	return tbl
end

function create_virtual_item(owner_oid, item_id, number, item_bag)
	if owner_oid == nil then
		dbglog('item', '不能创建没有归属的物品')
	end
	item_bag = item_bag or 'none'
	local item_type = data.item_id[item_id]
	if item_type == nil then
		dbglog('item', 'CONFIG ERROR: item nil', item_id)
	end
	local conf = data[item_type][item_id]
	local tbl = {
		_id = db.gen_oid(),
		id = item_id,
		type = item_type,
		bag = item_bag,
		owner_oid = owner_oid,
		number = number,
	}
	return tbl
end

--随机掉落附加属性
function _throw_dice_deter_prop( append_prop )
	local temp_arr = {}
	for k, v in pairs( append_prop ) do
		table.insert(temp_arr, v[3])
	end
	local get_idx = utils.weight_random(temp_arr)
	return append_prop[get_idx]
end

function is_equipment(item_type)
	--另一种虚拟物品
	return item_type == 'weapon' or
		item_type == 'helmet' or
		item_type == 'armor' or
		item_type == 'necklace' or
		item_type == 'ring' or
		item_type == 'shoe'
end

function is_soul(item_type)
	return item_type == 'soul'
end

function is_material(item_type)
	return item_type == 'material' or
		item_type == 'item' or item_type == 'gem'
end

function is_virtual_item(item_type)
	--虚拟物品在得到的时候直接起作用,不存背包 
	return item_type == 'soul_stone' or
		item_type == 'equip_frag' or
		item_type == 'equip_qh_stone'
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

function is_proxy_money(item_type)
	return item_type == 'token_coin'
end

function is_sweep(item_type)
	return item_type == 'sweep'
end

function is_usable_item(item_type)
	return item_type == 'item'
end

function create(args)
	if args.owner_oid == nil then
		dbglog('item', '创建物品失败，无owner_oid', args.item_id)
	end
	if is_equipment(data.item_id[args.item_id]) then
		return create_equipment(args.owner_oid, args.item_id)
	elseif is_material(data.item_id[args.item_id]) then
		return create_material(args.owner_oid, args.item_id, args.item_num)
	end
	dbglog('item', args.item_id, args.owner_oid, '创建物品失败')
end

