

navigation_bar = lua_class('navigation_bar')

function navigation_bar:_init( bar ,barbg , list_equip )
	
	self.bar = bar
	self.barbg = barbg
	self.list_equip = list_equip


end

function navigation_bar:init_bar( cell_count ,cur_count , list_width ,callback)
	self.callback = callback
	self.bar_dis = 12
	self.barbg_h = self.barbg:getLayoutSize().height-self.bar_dis*2

	self.bar:setPositionY(self.bar_dis+self.barbg_h-self.barbg_h*(list_width/self.list_equip:getInnerContainerSize().height))
	local temp = self.bar:getPositionY()
	--print('高度22：',self.barbg_h ) 
	self.cur_count =cur_count
	if self.cur_count > cell_count then
		--导航条相关
		--self.bar:setVisible(true)
		--self.barbg:setVisible(true)
		self.bar:setContentSize(19,self.barbg_h *(list_width /self.list_equip:getInnerContainerSize().height))
		--self.bar:setPositionY(15+self.barbg_h-self.barbg_h*(282/self.list_equip:getInnerContainerSize().height))
		self.can_move_dis = self.list_equip:getInnerContainerSize().height-list_width
		--local temp = self.bar:getPositionY()

		if self.list_equip:getChildByTag(1) ~= nil then
			self.start_pos = self.list_equip:getChildByTag(1):getWorldPosition().y
			self.s_pos = temp
			self.head_pos = self.list_equip:getChildByTag(1):getWorldPosition().y
			self.tail_pos = self.head_pos + self.can_move_dis
		end

		--设置滚动事件
		self:set_scroll_hander()

	else
		self:remove_scroll_hander()
		self.bar:setContentSize(19,self.barbg_h)
		self.bar:setPositionY(temp)
		--self.bar:setVisible(false)
		--self.barbg:setVisible(false)
	end
end

function navigation_bar:set_scroll_hander()
	local function scrollViewEvent(sender, evenType)
		if self.callback ~= nil then
			self.callback()
		end
		if evenType == ccui.ScrollviewEventType.scrollToBottom then
			--print("到下边")

			if self.list_equip:getChildByTag(1) ~= nil then

				--self.isBottom = true
				
				--print('头坐标:',self.tail_pos)
				self.bar:setPositionY(self.bar_dis)
				
				self.end_pos = self.list_equip:getChildByTag(1):getWorldPosition().y
				self.start_pos = self.end_pos

			end

		elseif evenType ==  ccui.ScrollviewEventType.scrollToTop then
			--print("到上边")
			
			if self.list_equip:getChildByTag(1) ~= nil then
				self.bar:setPositionY(self.s_pos)
				--end
				self.end_pos = self.list_equip:getChildByTag(1):getWorldPosition().y
				self.start_pos = self.end_pos

			end

		elseif evenType == ccui.ScrollviewEventType.bounceBottom then --下边超过后回弹
			
			--print('下边超过后回弹')
			if self.list_equip:getChildByTag(1) ~= nil then
				self.bar:setPositionY(self.bar_dis)
				
				self.end_pos = self.list_equip:getChildByTag(1):getWorldPosition().y
				self.start_pos = self.end_pos
			end

		elseif evenType == ccui.ScrollviewEventType.bounceTop then --上边超过后回弹
			
			--print('上边超过后回弹')
			if self.list_equip:getChildByTag(1) ~= nil then
				self.bar:setPositionY(self.s_pos)
				
				self.end_pos = self.list_equip:getChildByTag(1):getWorldPosition().y
				self.start_pos = self.end_pos
			end

			

		elseif evenType == ccui.ScrollviewEventType.scrolling then --回弹
			
			if self.list_equip:getChildByTag(1) ~= nil then
				local pos1 = self.list_equip:getChildByTag(1):getWorldPosition().y
				--local pos2 = self.list_equip:getChildByTag(self.cur_count):getWorldPosition().y
				--print('pos1:',pos1)
				--print('self.tail_pos：',self.tail_pos)
				if self.bar:getPositionY() >= self.bar_dis and self.bar:getPositionY() <= self.s_pos and pos1 > self.head_pos  and pos1 < self.tail_pos then
					self.end_pos = self.list_equip:getChildByTag(1):getWorldPosition().y
					--self.eend_pos = self.list_equip:getChildByTag(self.cur_count):getWorldPosition().y
					self.child_move_dis = self.start_pos-self.end_pos
					--print('距离：',self.child_move_dis)
					self.start_pos = self.end_pos
					--if self.s_pos <= self.end_pos or self.se_pos > self.eend_pos then
					if (self.bar:getPositionY()+self.barbg_h*(self.child_move_dis/self.list_equip:getInnerContainerSize().height)) >= self.bar_dis and (self.bar:getPositionY()+self.barbg_h*(self.child_move_dis/self.list_equip:getInnerContainerSize().height)) <= self.s_pos then 
						self.bar:setPositionY(self.bar:getPositionY()+self.barbg_h*(self.child_move_dis/self.list_equip:getInnerContainerSize().height))
						--print('进入了')
					end
					
				elseif self.bar:getPositionY() < self.bar_dis then

					self.bar:setPositionY(self.bar_dis)
				elseif self.bar:getPositionY() > self.s_pos then

					self.bar:setPositionY(self.s_pos)
				elseif pos1 <= self.head_pos then
					self.bar:setPositionY(self.s_pos)
				elseif pos1 >= self.tail_pos then
					self.bar:setPositionY(self.bar_dis)
				end

				if self.bar:getPositionY() < self.bar_dis or self.bar:getPositionY() > self.s_pos or pos1 <= self.head_pos or  pos1 >= self.tail_pos then
					self.end_pos = self.list_equip:getChildByTag(1):getWorldPosition().y
					self.start_pos = self.end_pos
				end

			end
		end
	end
	self.list_equip:addEventListener(scrollViewEvent)
end

function navigation_bar:remove_scroll_hander(  )
	-- body
	--self.list_equip:getEventDispatcher()
	local function scrollViewEvent(sender, evenType)
	
	end
	self.list_equip:addEventListener(scrollViewEvent)
end