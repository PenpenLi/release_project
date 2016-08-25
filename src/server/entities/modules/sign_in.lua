local avatar_main		= import('entities.avatar')
local timer			 = import('model.timer')
avatar = avatar_main.avatar

function avatar:_update_signin() 
	if not timer.is_same_month(timer.get_now(), self.db.latest_sign_time) then --清表
		self.db.sign_in_times = 0 
		self.db.latest_sign_time = 0
		self.client.clear_sign_in()
	end
end

function avatar:sign_in()
	if timer.is_same_day(self.db.latest_sign_time, timer.get_now()) then
		return
	end
	local signin_date = timer.get_signin_date()	
	local key = signin_date.year .. '-' .. signin_date.month .. '-' .. (self.db.sign_in_times + 1) 
	if data.sign_in[key] == nil then
		return
	end
	local item_id = data.sign_in[key]['reward'][1]
	local item_num = data.sign_in[key]['reward'][2]
	local vip_limit = data.sign_in[key]['vip_lv_needed']
	if item_id == nil or item_num == nil or vip_limit == nil then
		return
	end
	if vip_limit ~= 0 and self.db.vip.lv >= vip_limit then
		item_num = item_num * 2
	end

	self.db.sign_in_times = self.db.sign_in_times + 1
	self.db.latest_sign_time = timer.get_now()
	if item_id ~= 160001 then
		local item = self:_gain_item(item_id,item_num)
		self.client.show_gain_msg({{id = item_id, number = item_num}})
	else
		self:_add_diamond(item_num)
		self.client.message('msg_gain_diamond', {number = item_num})
	end
	self:_writedb()
	self.client.finish_signin()
end
