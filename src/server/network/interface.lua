local client			= import('entities.client')
local cjson				= require 'cjson'
local scheduler			= require 'network/scheduler'
local utils				= import('utils')
local peers = {}

entities = {}

-- 所有活跃用户集合 key为username,oid
all_avatars = {}
all_avatars_oid = {}

-- 玩家真正在线集合 key为username
online_avatars = {}

function handle_udp_connect( pid )
	dbglog('RPC', 'accepted', pid)
	local function index( e, method_name )
		local function caller( ... )
			peers[pid]:send(cjson.encode({method_name,{...}}))
		end
		return caller
	end

	local e = client.client(pid)
	e.client = {}
	local meta_table = { __index = index }
	setmetatable( e.client, meta_table )
	entities[pid] = e
	peers[pid] = UdpPeer(pid)
	--scheduler.resume()
end

function shift_udp_handler( pid, entity )
	local function index( e, method_name )
		local function caller( ... )
			peers[pid]:send(cjson.encode({method_name,{...}}))
		end
		return caller
	end

	entity.client = {}
	local meta_table = { __index = index }
	setmetatable( entity.client, meta_table )
	entities[pid] = entity
end

function handle_udp_event( pid, msg )
	if msg == nil or msg == '' then
		return
	end
	dbglog('RPC', 'message', pid, msg)
	local data = cjson.decode(msg)
	local e = entities[pid]
	local method = e[data[1]]
	if method ~= nil and type(method) == "function" then
		scheduler.create_routine(method)(e, unpack(data[2]))
		--method(e, unpack(data[2]))
	else
		dbglog('RPC', '调用未知方法', data[1])
	end
	--scheduler.resume()
end

function handle_udp_disconnect( pid )
	dbglog('RPC', 'disconnect', pid)

	local e = entities[pid]
	if e == nil then
		return
	end
	e.client = utils.swallow
	entities[pid] = nil
	peers[pid] = nil

	local method = e['_logout']
	--scheduler.create_routine(method)(e)
	method(e)
end

function broadcast_avatars(func)
	for pid, e in pairs(online_avatars) do
		scheduler.create_routine(func)(e)
	end
end
