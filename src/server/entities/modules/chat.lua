local avatar			= import('entities.avatar').avatar
local player_mgr		= import('model.player_mgr')
local time				= import('model.timer')
local utf8_utils		= import('utils.utf8')

local msg_max_len = 200
local history_list = {}
local max_num = 10
local pos = 1
local interval = 5  --发言时间间隔

local sys_msg_test = '<img path=gui/chat_test.png /> 发言过于频繁，请稍候！ <a type=player lv=99 playerid=512318>人物超链接测试</a><img path = gui/chat_test.png /><a type = item lv = 12 playerid = 151561>物品超链接测试</a> <img path=gui/chat_test.png />'


local function add_to_his(msg)
	if msg == nil then	
		return 
	end
	history_list[pos] = msg	
	pos = pos%max_num+1
end

function avatar:_sync_chat_his()
	self.client.update_chat_his(pos, max_num, history_list)
end

--系统消息
function avatar:_sys_msg(message)
	local msg_data = {
			name = '系统', 
			lv = 99, 
			hour = 99, 
			min = 99, 
			msg = message,
			channel = 'system',
			}
	print(msg_data.msg)
	for pid, e in pairs(entities) do
		e.client.say(msg_data)
	end
end

function avatar:say(msg_data)
	--判断消息是否合法
	if msg_data.channel == nil or msg_data.msg == nili
		or msg_data.role_type == nil or msg_data.helmet_id == nil then 
		return 
	end
	--判断消息是否超长
	if utf8_utils.utf8size(msg_data.msg) > msg_max_len then
		self.client.message('msg_over_length')
		return
	end
	local t = time.get_now()
	--发言过频繁
	if self.last_say_time ~= nil and t - self.last_say_time < interval then
		self.client.message('msg_say_too_frequence', {times = interval})
		return
	else
		self.last_say_time = t --更新最近发言时间
	end

	local sending_msg = self:_handle_msg(msg_data)
	--综合	
	if sending_msg.channel == 'all' then
		print('in all')
		for pid, e in pairs(entities) do
			e.client.say(sending_msg)
		end
		add_to_his(sending_msg) --添加到聊天历史	
	--联盟
	elseif sending_msg.channel == 'lianmeng' then
	--私聊
	elseif sending_msg.channel == 'private' then
		local tar_id = msg_data.target_id
		local tar_nickname = msg_data.target_nickname
		--没有聊天对象
		if tar_id == nil or tar_nickname == nil then
			return
		end
		--聊天对象不在线
		local tar_e = all_avatars_oid[tar_id]
		if tar_e == nil then
			self.client.message('msg_tar_offline')
			return 
		end
		--发给聊天对象	
		sending_msg.title = {msg = 'chat_first_title', var = {target = self:_get_nick_name()}}--msg_data.name ..' 对您说:'
		tar_e.client.say(sending_msg)
		--发给发送人
		sending_msg.title = {msg = 'chat_second_title', var = {target = tar_nickname}}--"您对 "..tar_nickname.." 说:"
		self.client.say(sending_msg)		
	end
end

function avatar:_handle_msg(msg_data)
	local sending_msg = {}	
	local cur_time = time.get_date()
	sending_msg.title	 = {msg = 'chat_title', var = {target = self:_get_nick_name()}}
	sending_msg.nick_name	 = self:_get_nick_name()
	sending_msg._id		 = self:_get_oid()
	sending_msg.lv		 = self:_get_level()
	sending_msg.role_type= msg_data.role_type
	sending_msg.helmet_id= msg_data.helmet_id
	sending_msg.channel	 = msg_data.channel
	sending_msg.msg		 = msg_data.msg 
	sending_msg.hour	 = cur_time.hour
	sending_msg.min		 = cur_time.min
	
	return sending_msg
end

