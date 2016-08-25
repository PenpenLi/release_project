chat_list = lua_class('chat_list')


function chat_list:_init(  )
	self.msg = {}
	self.maxi_num = 30
	self.pos = self.maxi_num - 1
end

function chat_list:add_msg(msg_data)
	self.pos = (self.pos - 1 + self.maxi_num)%self.maxi_num
	table.insert(self.msg, self.pos, table_deepcopy(msg_data))
	--self.msg[self.pos] = table_deepcopy(msg_data)
end

function chat_list:clear()
	for k, v in pairs(self.msg) do
		self.msg[k] = nil
	end
end