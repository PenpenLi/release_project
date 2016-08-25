local ui_const = import( 'ui.ui_const' )

soul_card = lua_class('soul_card')

local load_texture_type = TextureTypePLIST


function soul_card:_init( layer)
	
	self.layer = layer
	self.soul_data = nil
	self.card = nil
	self.bar_seep = 2
	self.jin_count = 0
	self.tick_bar = false
	self.add_exp = 0
	self.can_touch = true
	self:create_card()

	--属性图片
	self.pro_view = self.button:getChildByName('pro_view')
	self.name = self.button:getChildByName('name')
	self.lbl_level = self.button:getChildByName('level')
	self.head_view = self.button:getChildByName('head_view')
	self.call_panel = self.card:getChildByName('call')
	self.lbl_bar = self.call_panel:getChildByName('lbl_exp_bar')
	self.bar = self.call_panel:getChildByName('exp_barbg'):getChildByName('exp_bar')
	self.lbl_exp_count = self.card:getChildByName('lbl_exp_count')
	self.lbl_exp_count:enableOutline(ui_const.UilableStroke, 1)
	self.bar_length = self.bar:getContentSize().width

	--设置字体
	self.lbl_level:enableOutline(ui_const.UilableStroke, 1)
	self.name:enableOutline(ui_const.UilableStroke, 1)
	self.lbl_bar:enableOutline(ui_const.UilableStroke, 1)


	--记录点击次数,技能id
	self.touch_count = 0 
	self.skill_id = 0 
end

function soul_card:get_card(  )
	return self.card
end

function soul_card:get_button(  )
	return self.button
end

function soul_card:set_tick( t )
	self.tick_bar = t
end
	
function soul_card:get_tick(  )
	return self.tick_bar
end

function soul_card:set_top_level( lv )
	self.top_level = lv
end

function soul_card:create_card( )



	self.card = self.layer:get_widget('soul_card'):clone()
	self.button = self.card:getChildByName('card')
	self.card:setName('card_panel')
	self.card:ignoreAnchorPointForPosition(true)


end

--设置战灵头像
function soul_card:set_head_view( img_name )

	self.head_view:loadTexture( img_name ,load_texture_type )
	self.head_img_name = img_name
end


--设置属性图标
function soul_card:set_pro_type( pro_name )
	--pro_name 要是字符串
	self.pro_view:loadTexture(pro_name..'.png',load_texture_type)

end


--设置战灵名称

function soul_card:set_name( name )
	
	self.name:setString(name)
end

--设置战灵等级
function soul_card:set_level( level )
	self.level = level
	self.lbl_level:setString(''..level)
end

function soul_card:get_level(  )
	return self.level
end

--设置id
function soul_card:set_skill_id( id )
	self.skill_id = id
end

--获取id
function soul_card:get_skill_id(  )
	return self.skill_id 
end

--设置touch次数
function soul_card:set_t_count( t_c )
	self.touch_count = self.touch_count + t_c

	self.lbl_exp_count:setVisible(true)
	self.lbl_exp_count:setOpacity(255)
	self.lbl_exp_count:setString(''..self.touch_count)

end

function soul_card:hade_lbl_exp_count(  )
	self.lbl_exp_count:setOpacity(0)
end

function soul_card:hade_t_count(  )
	if self.touch_count > 0 then
		self.lbl_exp_count:setOpacity(255)
		self.lbl_exp_count:stopAllActions()
		local fadeout = cc.FadeOut:create(1.2)
		self.lbl_exp_count:runAction(fadeout)
	end
end

--获取touch次数
function soul_card:get_t_count(  )
	return self.touch_count
end


function soul_card:set_bar_view( num ,level )

	self.level = level
	self.exp = num
	self.sum_exp =self.exp --魔灵实际总经验
	local bef_level = self.level-1
	if self.level >=80 then
		self.lbl_bar:setString('经验已到满')

		self.can_touch = false
		self.card:setColor(cc.c3b(180,180,180))
		self.lbl_bar:setString('经验已到满')
		return
	end
	if bef_level > 0 and self.level <80 then
		--print('初始显示经验值1：', self.sum_exp,data.soul_upgrade[bef_level].sum_exp)
		local show_exp = self.sum_exp - data.soul_upgrade[bef_level].sum_exp
		--print('初始显示经验值1：',show_exp,data.soul_upgrade[self.level].exp)
		if show_exp >= data.soul_upgrade[self.level].exp then
			--print('初始显示经验值2：',show_exp,data.soul_upgrade[self.level].exp)
			
			if self.level ~= self.top_level then
				show_exp = show_exp - data.soul_upgrade[self.level].exp
				self.level = self.level + 1
				self:set_level(self.level)
				self.lbl_bar:setString(''.. show_exp .. '/' .. data.soul_upgrade[self.level].exp)
			else
				show_exp = data.soul_upgrade[self.level].exp
				self.level = self.level
				self:set_level(self.level)
				self.lbl_bar:setString(''.. show_exp .. '/' .. data.soul_upgrade[self.level].exp)
			end
		else
			self.lbl_bar:setString(''.. show_exp .. '/' .. data.soul_upgrade[self.level].exp)
		end
		local perc =show_exp/data.soul_upgrade[self.level].exp
		local dis = data.soul_upgrade[self.level].exp - show_exp
		if perc>=1 or dis == 1 then
			perc = 1
		end 
		--print('差值是多少：',dis,self.top_level)
		self.bar:setPositionX(self.bar:getContentSize().width*perc)
		--满了经验和等级和人物一样，就设置为不能触摸
		if self.level == self.top_level and perc == 1 then
			self.can_touch = false
			self.card:setColor(cc.c3b(180,180,180))
			self.lbl_bar:setString('经验已到满')
		end
	else

		self.lbl_bar:setString(''.. num .. '/' .. data.soul_upgrade[self.level].exp)
		local perc = num/data.soul_upgrade[self.level].exp
		local dis = data.soul_upgrade[self.level].exp - num
		if perc>=1 or dis == 1 then
			perc = 1
		end 
		self.bar:setPositionX(self.bar:getContentSize().width*perc)
		if self.level == self.top_level and  perc == 1 then
			self.can_touch = false
			self.card:setColor(cc.c3b(180,180,180))
			self.lbl_bar:setString('经验已到满')
		end
	end

	

end

--计算添加经验后的等级和多余经验
function soul_card:cal_level_and_exp( add_exp ,is_length )
	--现在的等级和经验
	local cur_lv = self.level
	local cur_exp = self.exp + add_exp
	self.add_exp = self.add_exp + add_exp
	self.cur_level = self.level
	--print('现在的等级：',self.level)

	for i,v in ipairs(data.soul_upgrade) do
		if self.exp < v.sum_exp then
			if i > 1 then
				self.bef_view_exp = self.exp - data.soul_upgrade[i-1].sum_exp

				break
			else
				
				self.bef_view_exp = self.exp
				break
			end

		end
	end

	for i,v in ipairs(data.soul_upgrade) do
		if cur_exp < v.sum_exp then
			--多出来经验要最后运行的
			--在2到最高等级之间
			if i > 1 and i <= self.top_level then
				self.surplus = cur_exp - data.soul_upgrade[i-1].sum_exp
				--print('经验多少',cur_exp,data.soul_upgrade[i-1].sum_exp,self.surplus)
				--将要到达的等级
				self.future_lv = data.soul_upgrade[i].soul_level
				--之间隔多少个级
				self.dif_lv = self.future_lv - cur_lv
			
				break
			elseif i > self.top_level then --在大于最高等级
 				self.surplus = data.soul_upgrade[self.top_level].exp
				--将要到达的等级
				self.future_lv = data.soul_upgrade[self.top_level].soul_level
				--之间隔多少个级
				self.dif_lv = self.future_lv - cur_lv
			else --在等级1
				--要运行到那个经验值
				self.surplus = cur_exp
				--将要到达的等级
				self.future_lv = data.soul_upgrade[i].soul_level
				--之间隔多少个级
				self.dif_lv = self.future_lv - cur_lv
				
				break
			end

		end

	end

	self.exp = self.exp + add_exp

	self.bar_seep = self.add_exp/20
	self.jin_count = 0
	--print('加了的经验：',self.exp)
end



function soul_card:tick(  )
	
end
 
function soul_card:get_exp( )
	return self.exp
end

function soul_card:get_need_exp(  )
	return self.need_exp
end



function soul_card:move_exp_bar( cb )
	
	if self.dif_lv == 0 then
		local lv = self.cur_level
		self.bef_view_exp = self.bef_view_exp+self.surplus/10

		if self.bef_view_exp >= self.surplus then
			self.bef_view_exp = self.surplus
			self.level = lv
			self.lbl_level:setString(self.level)
			--print('=============2次')
			cb()
		end
		local per = (self.bef_view_exp)/data.soul_upgrade[self.cur_level].exp
		local dis = data.soul_upgrade[self.cur_level].exp - self.bef_view_exp
		if per >= 1 or dis == 1 then
			per = 1
		end

		self.bar:setPositionX(self.bar_length*per)
		self.lbl_bar:setString(''..self.bef_view_exp .. '/' ..data.soul_upgrade[self.level].exp )
		if self.level >= self.top_level and per >= 1 then
			self.can_touch = false
			--print('=============1次')
			self.lbl_bar:setString('经验已到满')
		end
	else
	--不同等级就根据等级差，让进度条运行几次
		--相差等级
		local dis_level = self.dif_lv+1
		--print('最高级：',self.top_level)
		--print('距离多少级：',dis_level,self.jin_count)
		if self.jin_count < dis_level-1 then
			local start_level = self.cur_level + self.jin_count
			
			local temp_need_exp = data.soul_upgrade[start_level].exp
			--print('需要的经验',temp_need_exp)
			self.bef_view_exp = self.bef_view_exp+self.bar_seep
			if self.bef_view_exp >= temp_need_exp then
				self.bef_view_exp = 0
				self.bar:setPositionX(0)
				self.jin_count = self.jin_count + 1
				self.lbl_level:setString(self.cur_level+self.jin_count)
				self.level = self.cur_level+self.jin_count
				
			end
			local number = (self.bef_view_exp)/temp_need_exp
			self.lbl_bar:setString(''..self.bef_view_exp .. '/' ..temp_need_exp )
			self.bar:setPositionX(self.bar_length*number)
		
		end

		if self.jin_count == dis_level-1 then
			
			--print('经验多少',self.surplus)
			self.cur_view_exp = self.surplus
			self.level = self.future_lv
			local start_level = self.future_lv
			--print('达到的等级：',start_level)
			local need_exp = data.soul_upgrade[start_level].exp
			--print('-============================:',need_exp)
			self.lbl_level:setString(start_level)
			self.bef_view_exp = self.bef_view_exp+self.surplus/10
			if self.bef_view_exp >= self.cur_view_exp then
				self.bef_view_exp = self.cur_view_exp
				self.jin_count = 0
				self.exp_bar_ok = true
				
				
				cb()
			end
			local number = (self.bef_view_exp)/need_exp
			--print('-============================:',need_exp)
			self.lbl_bar:setString(''..self.bef_view_exp .. '/' ..need_exp )
			local dis = need_exp - self.bef_view_exp

			if number >= 1 or dis == 1 then
				number = 1
			end

			self.bar:setPositionX(self.bar_length*number)

			if self.level == self.top_level and number == 1 then
					self.can_touch = false
					self.lbl_bar:setString('经验已到满')
			end

		end
	end


end

function soul_card:get_can_touch(  )
	return self.can_touch
end
