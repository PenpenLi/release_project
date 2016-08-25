server = {}
online = false
local cjson = require 'cjson'

local function connect_failed()
	import( 'ui.msg_ui.msg_queue' ).add_msg('网络不给力...')
	import( 'world.director' ).hide_loading()
end

local function index( t, method_name )
	local function caller( ... )
		if online == false then
			connect_failed()
			return
		end
		_net.send(cjson.encode({method_name,{...}}))
	end
	return caller
end

local meta_table = { __index = index }
setmetatable( server, meta_table )


----------------------------------------------

local server_proxy = nil
function init_server_proxy( proxy )
	if server_proxy == nil then
		server_proxy = import('network.proxy').proxy()
	end
end

--cpp callback
function recv_msg( msg )
	local data = cjson.decode(msg)
	local method = server_proxy[data[1]]
	if method ~= nil and type(method) == "function" then
		print('[RPC][server][' .. tostring(string.len(msg)) .. ']', data[1], ' : ', unpack(data[2]))
		method(server_proxy, unpack(data[2]))
	else
		print('[RPC][WARNING]调用未知方法', data[1])
	end
end

--cpp callback
function recv_none_msg()
end

local function reconect_server()
	if online == true then
		return
	end
	local ui_mgr = import('ui.ui_mgr')
	if ui_mgr.get_ui('msg_ok_layer') ~= nil then
		return
	end
	local reconnect_msg = ui_mgr.create_ui(import('ui.msg_ui.msg_ok_layer'), 'msg_ok_layer')
	reconnect_msg:set_tip('连接已断开，点确定重新连接。')
	local function reconnect_callback()
		if online == true then
			return
		end
		login_server()
		import( 'utils.timer' ).set_timer(5, reconect_server)
	end
	reconnect_msg:set_ok_function(reconnect_callback)
end

local function connect_server()
	if online == true then
		return online
	end
	init_server_proxy()
	print('connecting')
	local server_list = import('server_list')
	local sid = get_server_id()
	_net.connect_async(server_list.list[sid].data[1], server_list.list[sid].data[2])--, 20)
	--online = _net.connect(server_list.list[sid].data[1], server_list.list[sid].data[2], 10)
	return online
end

function login_server()
	print('正在连接服务器...')
	--import( 'ui.msg_ui.msg_queue' ).add_msg('正在连接服务器...')
	local res = connect_server()
	if res == false then
		return true
	end
	return true
end

--cpp callback
function connect_async_success()
	print('连接成功正在登陆...')
	--import( 'ui.msg_ui.msg_queue' ).add_msg('连接成功正在登陆...')
	local username = cc.UserDefault:getInstance():getStringForKey("username")
	
	if username == '' then
		username = _extend.get_uuid()
		cc.UserDefault:getInstance():setStringForKey("username", username)
		cc.UserDefault:getInstance():flush()
	end
	online = true
	local reconnect_msg = import('ui.ui_mgr').get_ui('msg_ok_layer')
	if reconnect_msg ~= nil and reconnect_msg:get_tip() == '连接已断开，点确定重新连接。' then
		reconnect_msg:remove()
	end
	server.login(username, '')
end

--被动断开连接
--cpp callback
function disconnect()
	online = false
	reconect_server()
	--_net.disconnect()
	--login_server()
end

--手动断开连接
function disconnect_server()
	if online == false then
		return
	end
	online = false
	_net.disconnect()
	local msg_queue = import( 'ui.msg_ui.msg_queue' )
	msg_queue.add_msg('连接已断开')
	reconect_server()
end

--cpp callback
function network_applicationDidEnterBackground()
	_net.disconnect()
	online = false
end

--cpp callback
function network_applicationWillEnterForeground()
	if import( 'world.director' ).get_scene()._name == 'login_scene' then
		return
	end
	login_server()
	import( 'utils.timer' ).set_timer(5, reconect_server)
end

----------------------------------------------

function set_server_id(id)
	cc.UserDefault:getInstance():setIntegerForKey("server_id", id)
end

function get_server_id()
	local id = cc.UserDefault:getInstance():getIntegerForKey("server_id")
	if id == 0 then
		id = 1
		cc.UserDefault:getInstance():setIntegerForKey("server_id", id)
		cc.UserDefault:getInstance():flush()
	end
	return id
end

function set_username(username)
	cc.UserDefault:getInstance():setStringForKey("username", username)
end

function get_username()
	local username = cc.UserDefault:getInstance():getStringForKey("username")
	if username == '' then
		username = _extend.get_uuid()
		cc.UserDefault:getInstance():setStringForKey("username", username)
		cc.UserDefault:getInstance():flush()
	end
	return username
end

function set_password(password)
	cc.UserDefault:getInstance():setStringForKey("username", username)
end

function get_password()
	local password = cc.UserDefault:getInstance():getStringForKey("password")
	if password == '' then
		password = _extend.get_uuid()
		cc.UserDefault:getInstance():setStringForKey("password", password)
		cc.UserDefault:getInstance():flush()
	end
	return password
end