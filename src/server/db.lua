local timer				= import('model.timer')
local scheduler			= require 'network/scheduler'

local default_deep = 2

--redis = nil
mongo = nil

TBL_USER = 'user'
TBL_ITEM = 'item'
TBL_TRACEBACK = 'traceback'

function init()
	--local redisl = require 'redis'
	--redis = redisl.connect( DBRedis.host, DBRedis.port )

    local mongol = require "mongol"
    mongo = mongol( DBMongo.host, DBMongo.port )

	--return redis ~= nil and mongo ~= nil
	return mongo ~= nil
end

function get_mongo()
	return mongo:new_db_handle( DBMongo.db )
end

function gen_oid()
	local oid = require "mongol.object_id"
	return oid.new()
end

function _save_(tbl, d)
	local mdb = get_mongo()
	mdb:update(tbl, {_id=d._id}, d, true)
	syslog('db', 'save ' .. tbl, oid_to_str(d._id))
end

------------------------------------------
users = {}
items = {}
tracebacks = {}

function item_save(item)
	items[item._id] = item
end

function item_save_now(oid)
	local item = items[oid]
	if item ~= nil then
		items[oid] = nil
		--迭代中执行coroutine，必须保证coroutine内不对table插入元素
		scheduler.create_routine(_save_)(TBL_ITEM, item)
		--_save_(TBL_ITEM, item)
	end
end

function user_save(user)
	users[user._id] = user
end

function user_save_now(oid)
	local user = users[oid]
	if user ~= nil then
		users[oid] = nil
		--迭代中执行coroutine，必须保证coroutine内不对table插入元素
		scheduler.create_routine(_save_)(TBL_USER, user)
		--_save_(TBL_USER, user)
	end
end

function traceback_save(o)
	local oid = gen_oid()
	o._id = oid
	tracebacks[oid] = o
end

function traceback_save_now(oid)
	local o = tracebacks[oid]
	if o ~= nil then
		tracebacks[oid] = nil
		scheduler.create_routine(_save_)(TBL_TRACEBACK, o)
	end
end

function tick()
	local t = timer.get_now()
	if t % 60 == 53 then
		for key, it in pairs(items) do
			item_save_now(it._id)
		end
	end
	if t % 30 == 0 then
		for _, u in pairs(users) do
			user_save_now(u._id)
		end
	end
	if t % 30 == 0 then
		for oid, v in pairs(tracebacks) do
			traceback_save_now(oid)	
		end
	end
end

function reload_data()
	syslog('db', 'reload_data')
	for key, _ in pairs(package.loaded) do
		if string.sub(key,1,5) == 'data/' then
			package.loaded[key] = nil
		end
	end
	_G['data'] = {}
	load_data()
end

function load_data()
require 'data/fuben'
require 'data/fuben_entrance'
require 'data/scene'
require 'data/monster'
require 'data/weapon'
require 'data/helmet'
require 'data/armor'
require 'data/necklace'
require 'data/ring'
require 'data/shoe'
require 'data/skill'
require 'data/buff'
require 'data/equip'
require 'data/item_id'
require 'data/language'
require 'data/dialog'
require 'data/level'
require 'data/quest'
require 'data/quest_daily'
require 'data/quest_condition'
require 'data/shop1'
require 'data/shop1_level_list'
require 'data/shop2'
require 'data/shop2_level_list'
require 'data/avatar_strengthen'
require 'data/material'
require 'data/soul_stone'
require 'data/soul_evolution'
require 'data/soul_upgrade'
require 'data/equip_frag'
require 'data/equip_qh_stone'
require 'data/equipment_lv'
require 'data/email'
require 'data/lottery'
require 'data/lottery2'
require 'data/sign_in'
require 'data/item'
require 'data/equipment_activation'
require 'data/mall'
require 'data/vip'
require 'data/exchange_mall'
require 'data/token_coin'
require 'data/gem'
require 'data/store_item'
require 'data/boss_battle'
require 'data/soul'
require 'data/midas_touch'
require 'data/guide'
require 'data/equipment_strengthen'
require 'data/skill_initstar'
require 'data/box_drop'
require 'data/energy_purchase'
require 'data/rmb_cost'
require 'data/guide_state'
end


function shutdown()
	local function none(...) end

	_G['handle_udp_connect'] = none
	_G['handle_udp_event'] = none

	for pid, _ in pairs(entities) do
		handle_udp_disconnect(pid)
	end
end

function set_default_db(user_data, default_data, deep)
	if deep == nil then 
		deep = default_deep
	end
	if deep <= 0 then
		return 
	end
	for k, v in pairs(default_data) do
		if user_data[k] == nil then
			if type(v) == 'table' then
				user_data[k] = table_deepcopy(v)
			else
				user_data[k] = v
			end
		elseif type(user_data[k]) == 'table' then
			set_default_db(user_data[k], default_data[k], deep - 1)
		end
	end
end


