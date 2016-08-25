
players = {}
players_pid = {}

function check_status(username)
	local p = players[username]
	local pid = players_pid[username]
	if p ~= nil then
		return p, pid
	end
	return 'offline', pid
end

function get_pid(username)
	return players_pid[username]
end

---------------------------status------------
function login(username, pid)
	players[username] = 'login_begin'
	players_pid[username] = pid
	--syslog('playermgr', 'login['..tostring(pid)..']'..username)
end

function login_finish(username)
	local pid = players_pid[username]
	players[username] = 'online'
	all_avatars[username] = entities[pid]
	local e = entities[pid]
	if e ~= nil then all_avatars_oid[e:_get_oid()] = e end
	--online_avatars[username] = entities[pid]
	--syslog('playermgr', 'online['..tostring(pid)..']'..username)
end

function logout_begin(username)
	local pid = players_pid[username]
	players[username] = 'logout_begin'
	--syslog('playermgr', 'logout['..tostring(pid)..']'..username)
end

function logout(username)
	local pid = players_pid[username]
	--syslog('playermgr', 'offline['..tostring(pid)..']'..username)
	--local e = online_avatars_pid[pid]
	online_avatars[username] = nil
	--online_avatars_oid[e:_get_oid()] = nil
	--players[username] = 'online'
	players_pid[username] = 0
end

function replace_login(username, pid)
	local old_pid = players_pid[username]
	players_pid[username] = pid
	online_avatars[username] = entities[pid]
end
---------------------------status------------

--db login
function db_to_login()
	local db		= import('db')
	local avatar	= import('entities.avatar')
	local client	= import('entities.client')
	local utils		= import('utils')
	local timer		= import('model.timer')
	local const		= import('const')
	require 'network/interface'

	local now = timer.get_now()
	local sub = now - const.active_condition_time
	local mdb = db.get_mongo()
	local _, res = mdb:query(db.TBL_USER, {last_login={['$gte']=sub}}, {username=1}, 0, 0)
	
	if res ~= nil then
		for k,v in pairs(res) do

			local e = avatar.avatar(0)
			e.client = utils.swallow

			e:_login(v.username)
			--scheduler.create_routine('db_login')(e, username)
			all_avatars[v.username] = e
			all_avatars_oid[ e:_get_oid() ] = e
		end
	else
		print('db == nil')
	end
end








