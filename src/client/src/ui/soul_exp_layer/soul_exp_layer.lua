local layer					= import( 'world.layer' )
local anim_trigger 			= import( 'ui.main_ui.anim_trigger')
local ui_const 				= import( 'ui.ui_const' )
local model 				= import( 'model.interface' )
local soul_card				= import( 'ui.soul_exp_layer.soul_card' )
local main_map				= import( 'ui.main_map' )
local ui_mgr 				= import( 'ui.ui_mgr' ) 
local locale				= import( 'utils.locale' )
local msg_queue 			= import( 'ui.msg_ui.msg_queue' )

soul_exp_layer = lua_class( 'soul_exp_layer' , layer.ui_layer)


local select_s_id = nil
local _json_path = 'gui/main/ui_soul_exp.ExportJson'
local sicon_set = 'icon/s_icons.plist'

function get_skill_id(  )
	return select_s_id
end


function soul_exp_layer:_init(  )
	super(soul_exp_layer,self)._init(_json_path,true)
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2 ,VisibleSize.height/2)
	self.is_remove = false


	-- self.col = cc.LayerColor:create( cc.c4b(0,0,0,180) )
	-- self.cc:addChild(self.col ,-100)
	-- self.col:setPosition(0,0)

	self:set_handler("close_button", self.close_button_event)
	self.soul_page = self:get_widget('soul_page')
	self.page_count_view = self:get_widget('Label_72')
	self:get_widget('lbl_soul_tilte'):setString(locale.get_value('soul_tilte'))


	--翻页按钮
	self.front_button = self:get_widget('Button_74')
	self.next_button  = self:get_widget('Button_73')
	self:set_handler('Button_74', self.front_button_event)
	self:set_handler('Button_73', self.next_button_event)
	self.front_button:setVisible(false) 
	self.next_button:setVisible(false) 


	--种类按钮状态初始化
	self.all_call_button 	= self:get_widget('all_call_button')
	self.fire_button 	= self:get_widget('fire_button')
	self.ice_button 	= self:get_widget('ice_button')
	self.nature_button 	= self:get_widget('nature_button')
	self.all_call_button:setTouchEnabled(false)
	self.all_call_button:setHighlighted(true)

	self:set_handler("all_call_button", self.all_call_button_event)
	self:set_handler("fire_button", self.fire_button_event)
	self:set_handler("ice_button", self.ice_button_event)
	self:set_handler("nature_button", self.nature_button_event)
	
	--把技能分类
	local avatar = model.get_player()
	self.skills = avatar:get_skills()
	--保存所有技能卡的名称
	self.cards = {}

	--卡牌长按
	self.item_id 		= 0
	self.item_num 		= 40
	self.data_table 	= {}
	self.skills_data 	= {}
	self.record_count 	= {} --记录对应魔灵用了多少物品
	self.record_level 	= {} --记录等级
	self.record_exp 	= {} --记录经验

	self.touch_count 		= 0
	self.frame_count 		= 0			--帧计数
	self.start_frame_count	= nil
	self.end_frame_count	= 0
	self.begin_touch_button = false
	self.end_touch_button 	= true
	self.length_btn 		= nil
	self.zhizhaohuang 		= true
	self.page_numbers 		= 0	--页数
	self.skill_type 		= EnumSkillElements.all
	function tick()

		self:layer_tick()
	
	end
	self.tick = cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick, 0, false)

	self:set_page_hander()
	self:reload()

end

--设置当前使用对应经验物品的id
function soul_exp_layer:set_item_id( it_id  )
	self.item_id = it_id
	local player = model.get_player()
	local items = player:get_items()
	local oid = player:get_item_oid_byid(it_id)
	self.data_table = {oid}
	self.item_oid = oid
	self.item_num = player:get_item_number_by_id(it_id)
	
end

--设置物品个数
function soul_exp_layer:set_item_num( num )
	self.item_num = num
end


function soul_exp_layer:set_check_box_handler(name, handler)
	local widget = self:get_widget(name)
	widget:setTouchEnabled(true)
	local function eventType(sender, eventType)
		handler(self, sender, eventType)
	end 
	widget:addEventListener(eventType)
end


function soul_exp_layer:table_count( ht )
	local n = 0
	for i,v in pairs(ht) do
		n = n+1
	end
	return n
end


function soul_exp_layer:getIntPart( x )
	-- body
	local i,_ = math.modf(x)
	return i
end




function soul_exp_layer:update_page(  )
	cc.SpriteFrameCache:getInstance():addSpriteFrames( sicon_set )
	
	print('update_page')
	self:reload_json()
	self.z1_1 = self:get_widget('Label_72')
	local avatar = model.get_player()					--获取玩家数据
	self.skills = avatar:get_skills()

	--玩家技能的列表长度

	local skill_keys = {}
	local activate = {}
	for key, skill in pairs(data.skill) do
		--只显示选中
		key = tostring(key)
		if  self.zhizhaohuang == true then
			if self.skills[key] ~= nil then
				
				if (self.skill_type == EnumSkillElements.all or self.skill_type == self.skills[key]:get_element_type()) then
				 	local temp_key = tonumber(key)
					table.insert(activate, temp_key)
				end
			end
		end

	end

	if self.zhizhaohuang == true then
		local function cmp(a,b)
			return a < b
		end
		table.sort(activate, cmp)
		table.sort(skill_keys, cmp)
		for _,v in ipairs(activate) do
			table.insert(skill_keys, v)
		end
	end


	local page_count = 0
	local cur_cell_count = #skill_keys

	
	--计算页数
	local temp_count = self:getIntPart(cur_cell_count/8)
	
	if temp_count < cur_cell_count/8 then
		page_count = temp_count+1
	else
		page_count = temp_count
	end 

	self.page_numbers = page_count
	
	local temp = 0
	local count = 0
	local z_count = 1
	--取出已装备的数据
	if page_count > 1 and self.soul_page:getCurPageIndex() + 1 >1 then
		self.soul_page:scrollToPage(0)
		
	end
	self.soul_page:removeAllPages()
	
	local cast_skill = avatar.skills.cast  --装备的技能
	for i = 1 , page_count do
		--新建页面
		local layout = ccui.Layout:create()
		layout:setContentSize(cc.size(760, 500))
		self.soul_page:addPage(layout)
		--self.skill_page:insertPage(layout,i)
		temp = (i-1)*8+1+8-1  --
		
		--如果比实际总个数少和等于，这一页就按temp的数量
		if temp >= cur_cell_count then
			temp = cur_cell_count
		end

		for j = (i-1)*8+1,temp do
			local skill_id = skill_keys[j]
			skill_id = tostring(skill_id)
			local skill = self.skills[skill_id]
			if skill ~= nil then
				--召唤的
				local data = skill.data
				count = count + 1
				local cell = soul_card.soul_card(self)
				cell:set_head_view(data.icon)
				cell:set_name( data.name )
				cell:set_pro_type( data.element_type )
				--cell:set_pro_level( data.star )
				cell:set_skill_id(skill_id)
				local temp_level = self.record_level[skill_id]
				if temp_level ~= nil then
					--print('等级2222：',temp_level)
					cell:set_level(temp_level)
				else
					cell:set_level(skill:get_level())
				end

				cell:set_top_level(avatar:get_level())

				local temp_exp = self.record_exp[skill_id]
				if temp_exp ~= nil and temp_level ~= nil then
					--print('temp_exp',temp_exp,temp_level)
					cell:set_bar_view(temp_exp,temp_level)
				else 
					cell:set_bar_view(skill:get_exp(),skill:get_level())
				end

				local temp_cnt = self.record_count[skill_id]
				if temp_cnt ~= nil then
					cell:set_t_count(temp_cnt)
					cell:hade_lbl_exp_count()
				end

				--保存到卡牌容器
				self.cards[skill_id] = cell
				local SoulBox = cell:get_card( )
				if (count-8*(i-1))%4 == 1 then
					SoulBox:setPosition(101,368-self:getIntPart((count-8*(i-1))/4)*241)
				elseif (count-8*(i-1))%4 == 2 then
					SoulBox:setPosition(287,368-self:getIntPart((count-8*(i-1))/4)*241)					
				elseif (count-8*(i-1))%4 == 3 then
					SoulBox:setPosition(473,368-self:getIntPart(((count-8*(i-1))/4))*241)				
				elseif (count-8*(i-1))%4 == 0 then
					SoulBox:setPosition(659,368-self:getIntPart(((count-8*(i-1))/4)-1)*241)		
				end
				--由高到低，z值越少。
				z_count = z_count - 1
				layout:addChild(SoulBox,z_count)

				--为每个格子设置监听时间
				self:set_cell_hander( cell ,skill_id )	
			else

			end




		end

	end
 	--没有插入页时显示为第一页
   	if page_count <= 1 then
   		page_count = 1
   	end
   	--页数显示
	local pageInfo = 1 ..'/'.. page_count
	self.z1_1:setString(pageInfo)
    --崩毁原因：如果只有一页，还跳转到第一页，有机会出现崩毁
    if page_count > 1 and self.soul_page:getCurPageIndex() + 1 >1 then
    --跳回到第一页
		self.soul_page:scrollToPage(0)
	end
	if page_count == 1 then
		self.next_button:setVisible(false)
		self.front_button:setVisible(false)
	else
		self.next_button:setVisible(true)
	end


end



function soul_exp_layer:layer_tick(  )


	self.frame_count = self.frame_count + 1




	--print('帧数: ',self.frame_count)
	for id,cell in pairs(self.cards) do
		local player = model.get_player()
		local player_lv = player:get_level()+1
		local soul_lv = cell:get_level()
		if cell:get_can_touch() == false then
			cell:get_card():setColor(cc.c3b(180, 180, 180))
			
		else
			if cell:get_tick() == true  then
				--print('开始tick')
				self:update_exp_view(cell)

			end
		end
	end

	local player = model.get_player()
	local player_lv = player:get_level()+1
	if self.length_btn ~= nil then
		local soul_lv = self.length_btn:get_level()
		if self.length_btn:get_can_touch() == false then
			self.length_btn:get_card():setColor(cc.c3b(180, 180, 180))
			return
		end
	end


	if self.touch_count >= self.item_num  then
		if self.length_btn ~= nil then
		self.record_count[self.length_btn:get_skill_id()] = self.length_btn:get_t_count()
		self.record_level[self.length_btn:get_skill_id()] = self.length_btn:get_level()
		self.record_exp[self.length_btn:get_skill_id()] = self.length_btn:get_exp()
		end
		return
	end
	if self.start_frame_count ~= nil and self.start_frame_count > 0  then
		local surplus_time =  self.frame_count - self.start_frame_count
		if self.length_btn ~= nil and surplus_time%20 == 0 then

			  --记录所有点击次数
			-- print('吊几次=========')
			
			self.length_btn:set_t_count(1)
			self.length_btn:hade_t_count()
			self.length_btn:set_tick(true)
			self.is_length_touch = true
			if self.touch_count < self.item_num  then
				local cur_exp = self.length_btn:get_exp()
				local cur_level = self.length_btn:get_level()
				local item_type = data.item_id[self.item_id]
				--print('类型：',item_type)
				local item_data = data[item_type][self.item_id]
				local added_exp = item_data.soul_exp
				self.length_btn:cal_level_and_exp(added_exp)
			end
			self.touch_count = self.touch_count + 1
		end
	end

	

end

--注册列表中按钮监听事件
function soul_exp_layer:set_cell_hander( v ,skill_id)
	local function selected_event(sender, eventType)
		local player = model.get_player()
		local player_lv = player:get_level()+1
		local soul_lv = v:get_level()
		--print('两个等级',soul_lv,player_lv)
		if eventType == ccui.TouchEventType.began then
			--print('能不能',v:get_can_touch())
			if v:get_can_touch() == false then
				v:get_card():setColor(cc.c3b(180, 180, 180))
				self.record_count[v:get_skill_id()] = v:get_t_count()
				self.record_level[v:get_skill_id()] = v:get_level()
				self.record_exp[v:get_skill_id()] = v:get_exp()
				return
			end

			if self.touch_count >= self.item_num then
				self.record_count[v:get_skill_id()] = v:get_t_count()
				self.record_level[v:get_skill_id()] = v:get_level()
				self.record_exp[v:get_skill_id()] = v:get_exp()
				return
			end
			if self.length_btn == nil then
				self.start_frame_count = self.frame_count
				self.begin_touch_button = true
				self.length_btn = v
				
			end
		elseif eventType == ccui.TouchEventType.canceled then

			if v:get_can_touch() == false and self.length_btn == nil then
				v:get_card():setColor(cc.c3b(180, 180, 180))
				self.record_count[v:get_skill_id()] = v:get_t_count()
				self.record_level[v:get_skill_id()] = v:get_level()
				self.record_exp[v:get_skill_id()] = v:get_exp()
				return
			end

			if self.touch_count >= self.item_num then
				msg_queue.add_msg('经验物品已使用完')
				self.record_count[v:get_skill_id()] = v:get_t_count()
				self.record_level[v:get_skill_id()] = v:get_level()
				self.record_exp[v:get_skill_id()] = v:get_exp()
				return
			end

			if self.begin_touch_button == true then

				self.length_btn = nil
				self.begin_touch_button = false
				self.start_frame_count = nil
				if self.is_length_touch == true then
					--v:hade_t_count()
					self.is_length_touch = false
					self.record_count[v:get_skill_id()] = v:get_t_count()
					self.record_level[v:get_skill_id()] = v:get_level()
					self.record_exp[v:get_skill_id()] = v:get_exp()
				else
					local cur_exp = v:get_exp()
					local cur_level = v:get_level()
					local item_type = data.item_id[self.item_id]
					local item_data = data[item_type][self.item_id]
					local added_exp = item_data.soul_exp
					v:cal_level_and_exp(added_exp)
					self.touch_count = self.touch_count + 1
					v:set_t_count(1)
					v:hade_t_count()
					v:set_tick(true)
					
				end
					self.record_count[v:get_skill_id()] = v:get_t_count()
					self.record_level[v:get_skill_id()] = v:get_level()
					self.record_exp[v:get_skill_id()] = v:get_exp()
					
				return
			end
			local cur_exp = v:get_exp()
			local cur_level = v:get_level()
			local item_type = data.item_id[self.item_id]
			local item_data = data[item_type][self.item_id]
			local added_exp = item_data.soul_exp
			v:cal_level_and_exp(added_exp)

			self.touch_count = self.touch_count + 1
			v:set_t_count(1)
			v:hade_t_count()
			v:set_tick(true)
			self.record_count[v:get_skill_id()] = v:get_t_count()
			self.record_level[v:get_skill_id()] = v:get_level()
			self.record_exp[v:get_skill_id()] = v:get_exp()
			
		elseif eventType == ccui.TouchEventType.ended then
		--print('按了多少次：',self.touch_count,self.item_num)

			if v:get_can_touch() == false and self.length_btn == nil then
				v:get_card():setColor(cc.c3b(180, 180, 180))
				self.record_count[v:get_skill_id()] = v:get_t_count()
				self.record_level[v:get_skill_id()] = v:get_level()
				self.record_exp[v:get_skill_id()] = v:get_exp()
				return
			end
			if self.touch_count >= self.item_num then
				msg_queue.add_msg('经验物品已使用完')
				self.record_count[v:get_skill_id()] = v:get_t_count()
				self.record_level[v:get_skill_id()] = v:get_level()
				self.record_exp[v:get_skill_id()] = v:get_exp()
				return
			end		

			if self.begin_touch_button == true then
				
				
				--print('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')		
				self.length_btn = nil
				
				self.begin_touch_button = false
				self.start_frame_count = nil
				if self.is_length_touch == true then
					--print('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~1')		
					--v:hade_t_count()
					self.is_length_touch = false
					self.record_count[v:get_skill_id()] = v:get_t_count()
					self.record_level[v:get_skill_id()] = v:get_level()
					self.record_exp[v:get_skill_id()] = v:get_exp()
					--print('长按结束')
				else
					--print('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~2')		
					self.touch_count = self.touch_count + 1
					local cur_exp = v:get_exp()
					local cur_level = v:get_level()
					local item_type = data.item_id[self.item_id]
					local item_data = data[item_type][self.item_id]
					local added_exp = item_data.soul_exp
					v:cal_level_and_exp(added_exp)
					v:set_t_count(1)
					v:hade_t_count()
					v:set_tick(true)
					--print('长按结束======================') 
					
				end
					self.record_count[v:get_skill_id()] = v:get_t_count()
					self.record_level[v:get_skill_id()] = v:get_level()
					self.record_exp[v:get_skill_id()] = v:get_exp()
					--print('等级111111111111：',v:get_level())
				return
			end
			--print('==============================')
			self.touch_count = self.touch_count + 1
			local cur_exp = v:get_exp()
			local cur_level = v:get_level()
			local item_type = data.item_id[self.item_id]
			local item_data = data[item_type][self.item_id]
			local added_exp = item_data.soul_exp
			v:cal_level_and_exp(added_exp)
			v:set_t_count(1)
			v:hade_t_count()
			v:set_tick(true)
			self.record_count[v:get_skill_id()] = v:get_t_count()
			self.record_level[v:get_skill_id()] = v:get_level()
			self.record_exp[v:get_skill_id()] = v:get_exp()
			--print('等级33333333333333333333333：',v:get_level())

		end
	end
		
	v:get_button( ):addTouchEventListener(selected_event)
end

function soul_exp_layer:update_exp_view( cell )
	local level = cell:get_level()
	if level > 0 and level < 80 then
		
		
		local function cb( )
			cell:set_tick(false)
			self.record_count[cell:get_skill_id()] = cell:get_t_count()
			self.record_level[cell:get_skill_id()] = cell:get_level()
			self.record_exp[cell:get_skill_id()] = cell:get_exp()
		end 
		
		cell:move_exp_bar(cb)
	end
end






--注册翻页事件

function soul_exp_layer:set_page_hander(  )
	 local function pageViewEvent(sender, eventType)
		if eventType == ccui.PageViewEventType.turning then
			local pageView = sender
			local pageInfo = pageView:getCurPageIndex() + 1 ..'/'.. self.page_numbers

			if pageView:getCurPageIndex() + 1 > 1 then
				
				self.front_button:setVisible(true)
			else
				
				self.front_button:setVisible(false)
			end
			if pageView:getCurPageIndex() + 1 >= self.page_numbers then
				
				self.next_button:setVisible(false)
			else
				
				self.next_button:setVisible(true)
			end
			self.page_count_view:setString(pageInfo)
		end
	end 
	self.soul_page:addEventListener(pageViewEvent)
end





function soul_exp_layer:front_button_event( sender, eventType )

	if  eventType == ccui.TouchEventType.ended then

		if self.soul_page:getCurPageIndex()+1 > 1 then 
			self.front_button:setVisible(true)
			self.soul_page:scrollToPage(self.soul_page:getCurPageIndex()-1)
		end
		if self.soul_page:getCurPageIndex()+1 == 1 then
			sender:setVisible(false)
		end

	end


end

function soul_exp_layer:next_button_event( sender, eventType )
		
	if eventType == ccui.TouchEventType.ended then
	--print('当前页码：',self.soul_page:getCurPageIndex()+1)
		if self.soul_page:getCurPageIndex()+1 < self.page_numbers then
			self.next_button:setVisible(true) 
			self.soul_page:scrollToPage(self.soul_page:getCurPageIndex()+1)
		end
		if self.soul_page:getCurPageIndex()+1 == self.page_numbers then
			sender:setVisible(false)
		end
	end


end


function soul_exp_layer:all_call_button_event( sender, eventType )
	if eventType == ccui.TouchEventType.ended then
		--music_mgr.ui_click()
		
		sender:setTouchEnabled(false)
		sender:setHighlighted(true)
		self.skill_type = EnumSkillElements.all
		self.cards = {}
		self:update_page( )
		
		self.fire_button:setTouchEnabled(true)
		self.fire_button:setHighlighted(false)
		self.ice_button:setTouchEnabled(true)
		self.ice_button:setHighlighted(false)
		self.nature_button:setTouchEnabled(true)
		self.nature_button:setHighlighted(false)
	end
end




function soul_exp_layer:fire_button_event( sender, eventType )
	if eventType == ccui.TouchEventType.ended then
		--music_mgr.ui_click()
		
		sender:setTouchEnabled(false)
		sender:setHighlighted(true)
		self.skill_type = EnumSkillElements.fire
		self.cards = {}
		self:update_page(  )
		

		self.all_call_button:setTouchEnabled(true)
		self.all_call_button:setHighlighted(false)
		self.ice_button:setTouchEnabled(true)
		self.ice_button:setHighlighted(false)
		self.nature_button:setTouchEnabled(true)
		self.nature_button:setHighlighted(false)
	end
end

function soul_exp_layer:ice_button_event( sender, eventType )
	if eventType == ccui.TouchEventType.ended then
		--music_mgr.ui_click()
		
		sender:setTouchEnabled(false)
		sender:setHighlighted(true)
		self.skill_type = EnumSkillElements.ice
		self.cards = {}
		self:update_page( )
		
		
		self.fire_button:setTouchEnabled(true)
		self.fire_button:setHighlighted(false)
		self.all_call_button:setTouchEnabled(true)
		self.all_call_button:setHighlighted(false)
		self.nature_button:setTouchEnabled(true)
		self.nature_button:setHighlighted(false)
	end
end

function soul_exp_layer:nature_button_event( sender, eventType )
	if eventType == ccui.TouchEventType.ended then
		--music_mgr.ui_click()
		
		sender:setTouchEnabled(false)
		sender:setHighlighted(true)
		self.skill_type = EnumSkillElements.nature
		self.cards = {}
		self:update_page( )
		
		
		self.fire_button:setTouchEnabled(true)
		self.fire_button:setHighlighted(false)
		self.all_call_button:setTouchEnabled(true)
		self.all_call_button:setHighlighted(false)
		self.ice_button:setTouchEnabled(true)
		self.ice_button:setHighlighted(false)
		
	end
end

function soul_exp_layer:real_button_event( sender, eventtype )
	if eventtype == 0 then
		print('press close')
	end
	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  
	elseif eventtype == ccui.TouchEventType.ended then
		--sender:setTouchEnabled(false)
		sender:setHighlighted(false)

		self.zhizhaohuang = not self.zhizhaohuang
		local lbl = sender:getChildByName('lbl_all_button')
		if self.zhizhaohuang == true then
			lbl:setString(locale.get_value('soul_all'))
		else
			lbl:setString(locale.get_value('soul_called'))
		end
		self:update_page( )

	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end


function soul_exp_layer:close_button_event(  sender, eventtype  )
	if eventtype == 0 then
		print('press close')
	end
	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  
	elseif eventtype == ccui.TouchEventType.ended then
		sender:setTouchEnabled(false)
		self.cc:setVisible(false)
		self.is_remove = true
		anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_UP_ANIM,false)

		-- for k,v in pairs(self.record_count) do
		-- 	local tp = {n = v ,s = k}
		-- 	table.insert(self.skills_data,tp)
		-- end

		-- server.batch_use_items(self.item_oid, self.skills_data)
		self:use_exp_item()
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end

function soul_exp_layer:use_exp_item()

	local count = 0
	for k,v in pairs(self.record_count) do
		if v ~= nil and v > 0 then
			local tp = {n = v ,s = k}
			table.insert(self.skills_data,tp)
			count = count + 1 
		end
	end
	dir(self.record_count)
	--print('==================')
	deep_dir(self.skills_data)
	if count > 0 then
		--print()
		server.batch_use_items(self.item_oid, self.skills_data)
	end
end

function soul_exp_layer:release(  )
	print('release soul_exp_layer')
	
	self.is_remove = false
	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.tick)
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( sicon_set )
	super(soul_exp_layer, self).release()
end

--信息界面返回时，更新相应的卡牌
function soul_exp_layer:update_card(  )
	local skill_id 	= select_s_id
	local cell 		= self.cards[skill_id]
	local skill 	= self.skills[skill_id]
	local data		= skill.data
	cell:set_head_view(data.icon)
	cell:set_name( data.name )
	cell:set_pro_type( data.element_type )
	--cell:set_pro_level( data.star )
	cell:set_level(skill.lv)
	cell:set_is_call( true )
end

function soul_exp_layer:reload(  )
	super(soul_exp_layer,self).reload()
	self:update_page()
end
