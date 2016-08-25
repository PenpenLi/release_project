local avatar			= import('entities.avatar').avatar
local email				= import('model.email')
local db				= import('db')

--读表
function avatar:_get_data(el)
	local eid = el.eid
	local d = data.email[eid]
	if d == nil then 
		return 
	end
	local e_data = {}
	e_data.id = el.id
	e_data.has_read = el.has_read
	e_data.has_get_items = el.has_get_items
	e_data.with_items = d.with_items 
	e_data.e_sender = d.sender
	e_data.title = d.title
	e_data.body = d.body
	e_data.date = d.date
	e_data.items = d.items
	e_data.money = d.money
	e_data.diamond = d.diamond
	return e_data
end

--邮件发客户端
function avatar:_email_to_client(e)
	self.db.emails[e._id] = e
	self:_writedb()
	self.client.sync_email(e)
end

-- login 时获取邮件列表
function avatar:_sync_emails()
	for _id, e in pairs(email.broadcast_emails) do
		if self.db.emails[_id] == nil then
			self.db.emails[_id] = table_deepcopy(e)
			--print('get new email, eid:', e.eid)
		end
	end
	for _id, e in pairs(self.db.emails) do
		self:_email_to_client(e)
		--print("get mail!!!! ", e._id, e.eid)
	end
end

function avatar:gain_email_items(id)
	local el = self.db.emails[id]
	if el == nil then 
		return 
	end
	--同步客户端
	local e_data = self:_get_data(el)
	--print("has_get_item   with_item", el.has_get_items, e_data.with_items)
	if e_data ~= nil and e_data.has_get_items == false and e_data.with_items == true then
		--发物品
		el.has_get_items = true
		if e_data.diamond ~= nil then
			self:_add_diamond(e_data.diamond)
		end
		if e_data.money ~= nil then
	--		print("add_money!!!", e_data.money)
			self:_add_money(e_data.money)
		end
		if e_data.with_items then
			local items = {}
			d_items = e_data.items
			if d_items ~= nil then
				for id, num in pairs(e_data.items) do
					if num > 0 then
						local t_item = self:_gain_item(id, num)
						if t_item ~= nil then
							self.client.show_gain_msg({{id = t_item.id, number = t_item.number}})
							table.insert(items, t_item)
						end
					end
				end
			end
			self.client.sync_items(items)
		end
	end
	self.client.sync_email(el)
	self:_writedb()
	self.client.close_mail_info()
end

function avatar:read_email(id)
	local el = self.db.emails[id]
	if el == nil then
		return 
	end
	el.has_read = true
--	print('read_mail ', id)	
	self.client.sync_email(el)
	self:_writedb()
end
