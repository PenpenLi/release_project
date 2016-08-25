local avatar_main		= import('entities.avatar')
local utils             = import('utils')
avatar = avatar_main.avatar

function avatar:midas_touch() 
	local k = self:_get_midas_touch_cnt()
	local total_times = self:_get_vip_midas_time()
	if k >= total_times then
		return false
	end
	local d = data.midas_touch[k + 1]
	if d == nil then
		return false
	end
	if self:_get_diamond() < d.diamond then
		self.client.message('msg_more_diamond')
		return false
	end
	local critical_mul	
	if d.critical_multiple ~= nil then
		local tmp_arr = {}
		for i, v in pairs(d.critical_multiple) do
			table.insert(tmp_arr,i, v)
		end
		critical_mul = utils.weight_random(tmp_arr)
	end
	self:_set_midas_touch_cnt(k + 1)
	self:_add_diamond(-d.diamond)
	self:_add_money(d.gold * critical_mul)

	self.client.finish_midas_touch(critical_mul)
	self:_trigger_quest_event('dianJin')
	return true
end

function avatar:midas_touch_continue() --连续使用
	local t = self:_get_midas_con_cnt()
	local times = 3 + 2 * t 
	local f = false
	for i = 1, times do
		if self:midas_touch() == false then
			break
		else
			f = true
		end
	end
	if f then
		self:_set_midas_con_cnt(t + 1)
		self.client.sync_midas_con_cnt(t + 1)
	end
end

function avatar:_sync_midas_touch()
	self.client.sync_midas_touch(self:_get_midas_touch_cnt())
end

function avatar:_sync_midas_con_cnt()
	self.client.sync_midas_con_cnt(self:_get_midas_con_cnt())
end
