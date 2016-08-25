package.path = package.path .. ';./lib/?.lua'
package.path = package.path .. ';./lib/?/init.lua'
package.path = package.path .. ';./lib/socket/?.lua'

function __G__TRACKBACK__(msg)
	print("----------------------------------------")
	print("LUA ERROR: " .. tostring(msg) .. "\n")
	print(debug.traceback())
	print("----------------------------------------")
end

function tick()
	local debugger			= require 'network/debugger'
	debugger.tick()

	local db = import('db')
	db.tick()

	local timer = import('model.timer')
	timer.tick()

	local scheduler			= require 'network/scheduler'
	scheduler.resume()
end

function shutdown()
end

local function server_start()
	local player_mgr		= import('model.player_mgr')
	player_mgr.db_to_login()
	local pvp_rank = import('model.pvp_rank')
	pvp_rank.pvp_rank_find()
end

local function main()
require 'engine'
require 'model/log'
require 'network/interface'
require 'config'
	collectgarbage("collect")
	-- avoid memory leak
	collectgarbage("setpause", 100)
	collectgarbage("setstepmul", 5000)

	local db = import('db')
	if db.init() == false then
		dbglog('main', 'db init failure!')
		return
	end
	local debugger			= require 'network/debugger'
	debugger.start()
	
	local scheduler = require 'network/scheduler'
	scheduler.create_routine(server_start)()

	_net.start(ServerPort, 2000)

	db.load_data()

	local function test()
		for i = 1, 10 do
			handle_udp_connect(i)
			handle_udp_event(i, '["login",["' .. tostring(i) .. '",""]]')
		end
	end
	--test()
end

xpcall(main, __G__TRACKBACK__)

