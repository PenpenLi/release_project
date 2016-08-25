local db				= import('db')
local config			= import('config')
local avatar			= import('entities.avatar')
local item				= import('model.item')
local player_mgr		= import('model.player_mgr')

client = lua_class( 'client' )

function client:_init(pid)
	self.pid = pid
end

--此方法内有协程切换
function client:login(username, token)

	local state, pid = player_mgr.check_status(username)
	--如果此账号正在登陆，此时不能顶号，本次登陆失败
	if status == 'login_begin' then
		self.client.login_failure(state)
		return
	--如果此账号在线，执行顶号逻辑
	elseif state == 'online' then
		local old_pid = player_mgr.get_pid(username)
		local new_pid = self.pid

		--local player = entities[old_pid]
		local player = all_avatars[username]
		shift_udp_handler(new_pid, player)
		player:_replace_login(new_pid)

		--记录真实在线
		online_avatars[username] = player
		syslog('client', 'replace_login', self.pid, username, token, state, pid)
		
		if old_pid <= 0 then
			return
		end

		local e = client(old_pid)
		shift_udp_handler(old_pid, e)
		e.client.replace_login()

		return
	--如果此账号正在下线，此时不能顶号，本次登陆失败
	elseif state == 'logout_begin' then
		self.client.login_failure(state)
		return
	end
	--如果此账号不在线，开始登陆

	local player = avatar.avatar(self.pid)
	shift_udp_handler(self.pid, player)
	--Warning: 协程切换
	player:_login(username, token)

	--记录真实在线
	online_avatars[username] = player
	syslog('client', 'login', self.pid, username, token, state, pid)
end

function client:_logout()
end
