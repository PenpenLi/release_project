scroll_view = lua_class('scroll_view')

function scroll_view:_init(scroll_view)	
	self.scroll_view = scroll_view

	self.list = {}
	self.num_column = 0
	self.num_row = 0
	self.used_width = 0
	self.used_height = 0

	self.list_widgth = self.scroll_view:getContentSize().width
	self.list_height = self.scroll_view:getContentSize().height
	self.margin = 0
	self.single_row_hieght = 124
	self.container = ccui.Layout:create()
	self.scroll_view:addChild(self.container)

	self.scroll_view:setInnerContainerSize(cc.size(self.list_widgth, self.list_height))
	self.cur_tag = 0
end

function scroll_view:add_row()
	if self.num_row == 0 then
		self.used_height = self.used_height + self.single_row_hieght
	else
		self.used_height = self.used_height + self.margin + self.single_row_hieght
	end
	self.used_width = 0
	self.num_column = 0
	self.num_row = self.num_row + 1
	local inner_size = self.scroll_view:getInnerContainerSize()
	if self.used_height + self.single_row_hieght >= inner_size.height then
		self.scroll_view:setInnerContainerSize(cc.size(self.list_widgth, inner_size.height + self.single_row_hieght))
		self.container:setContentSize(self.list_widgth, inner_size.height + self.single_row_hieght)
		local x, y = self.container:getPosition()
		self.container:setPosition(x, y + self.single_row_hieght)
	end
end

function scroll_view:get_new_pos(cell)
	local cell_width = cell:getContentSize().width
	local cell_height = cell:getContentSize().height
	local pos = {}

	if self.num_column == 0 then
		pos.x = self.used_width + cell_width / 2
		self.used_width = self.used_width + cell_width
		self.num_column = self.num_column + 1
	else
		pos.x = self.used_width + self.margin + cell_width / 2
		self.used_width = self.used_width + self.margin + cell_width
		
		if self.used_width > self.list_widgth then
			self:add_row()
			pos.x = self.used_width + cell_width / 2
			self.used_width = self.used_width + cell_width
		end

		self.num_column = self.num_column + 1
	end

	pos.y = self.used_height + cell_height / 2

	pos.y = self.list_height - pos.y
	return pos
end

function scroll_view:update_list()
	self.container:removeAllChildren()
	self.num_column = 0
	self.num_row = 0
	self.used_width = 0
	self.used_height = 0
	for tag, item in pairs(self.list) do
		self:push_back_item(item, tag, false)
	end
	-- for i = 1, self.index - 1 do
	-- 	self:push_back_item(self.list[i], false)
	-- end
end

function scroll_view:add_to_list(item, tag)
	self.list[tag] = item
	--self.index = self.index + 1
end

function scroll_view:push_back_item(item, tag, is_to_list)
	local pos = self:get_new_pos(item)
	item:setPosition(pos.x, pos.y)
	if is_to_list ~= false then
		if tag == nil then
			self:grap_tag()
		else
			self.cur_tag = tag + 1
		end
		self:add_to_list(item, tag)
	end
	self.container:addChild(item)
end

function scroll_view:get_scroll_view()
	return self.scroll_view
end

function scroll_view:remove_all_children()
	self.container:removeAllChildren()
	self.list = {}
	self.cur_tag = 0

	self.num_column = 0
	self.num_row = 0
	self.used_width = 0
	self.used_height = 0
end

function scroll_view:grap_tag()
	for i = 1, 1000 do
		self.cur_tag = self.cur_tag + 1
		if self.list[self.cur_tag] == nil then
			break
		end
	end
	return self.cur_tag
end

function scroll_view:get_item_by_tag(tag)
	return self.list[tag]
end