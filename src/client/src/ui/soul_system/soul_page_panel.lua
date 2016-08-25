local layer					= import( 'world.layer' )
local anim_trigger 			= import( 'ui.main_ui.anim_trigger')
local ui_const 				= import( 'ui.ui_const' )
local model 				= import( 'model.interface' )
local soul_card				= import( 'ui.soul_system.soul_card' )
local main_map				= import( 'ui.main_map' )
local ui_mgr 				= import( 'ui.ui_mgr' ) 
local locale			= import( 'utils.locale' )

soul_page_panel = lua_class( 'soul_page_panel' , layer.ui_layer)


local select_s_id = nil
local _json_path = 'gui/main/ui_soul_sys.ExportJson'
local sicon_set = 'icon/s_icons.plist'

function get_skill_id(  )
	return select_s_id
end


function soul_page_panel:_init(  )
	super(soul_page_panel,self)._init(_json_path,true)
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2 ,VisibleSize.height/2)

	self.page_panel = self:get_widget('Panel_68')
	
	self.is_remove = false
	self:set_handler("Button_70", self.close_button_event)

	--self.soul_page = self:get_widget('PageView_113')
	self.page_count_view = self:get_widget('Label_72')

	--self.page_count_view:setFontName(ui_const.UiLableFontType)
	--self:get_widget('lbl_soul_tilte'):setFontName(ui_const.UiLableFontType)
	self:get_widget('lbl_soul_tilte'):setString(locale.get_value('soul_tilte'))
	--self:get_widget('lbl_all_button'):setFontName(ui_const.UiLableFontType)
	self:get_widget('lbl_all_button'):setString(locale.get_value('soul_all'))
	self.page_numbers = 0	--页数
	--火table
	self.fire_table = {}
	--冰table
	self.ice_table = {}
	--自然table
	self.nature_table = {}
	--把技能分类
	local avatar = model.get_player()
	self.skills = avatar:get_skills()


	--保存所有技能卡的名称
	self.cards = {}
	self.skill_type = EnumSkillElements.all
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
	--self.all_button:setSelectedState(false)
	self.all_call_button:setHighlighted(true)

	self:set_handler("all_call_button", self.all_call_button_event)
	self:set_handler("fire_button", self.fire_button_event)
	self:set_handler("ice_button", self.ice_button_event)
	self:set_handler("nature_button", self.nature_button_event)

	self.real_button  = self:get_widget('all_button')
	self:set_handler('all_button', self.real_button_event)
	
	--召唤标记
	self.zhizhaohuang = true
	--激活技能id
	self.activate_id = nil
	self.is_activating = false
	--self:update_page()
	--self:set_page_hander()
	ui_mgr.schedule_once(0, self, self.update_page)
	--self:reload()

end


function soul_page_panel:set_check_box_handler(name, handler)
	local widget = self:get_widget(name)
	widget:setTouchEnabled(true)
	local function eventType(sender, eventType)
		handler(self, sender, eventType)
	end 
	widget:addEventListener(eventType)
end


function soul_page_panel:table_count( ht )
	local n = 0
	for i,v in pairs(ht) do
		n = n+1
	end
	return n
end


function soul_page_panel:getIntPart( x )
	-- body
	local i,_ = math.modf(x)
	return i
end




function soul_page_panel:update_page(  )
	cc.SpriteFrameCache:getInstance():addSpriteFrames( sicon_set )
	print('update_page')
	
	self.z1_1 = self:get_widget('Label_72')


	local avatar = model.get_player()					--获取玩家数据
	self.skills = avatar:get_skills()

	--玩家技能的列表长度
	if self.soul_page == nil then
		
		self.soul_page = ccui.PageView:create()
		self.soul_page:setTouchEnabled(true)
		self.soul_page:setContentSize(cc.size(760, 500))
		self.page_panel:addChild(self.soul_page)
		self.soul_page:setPosition(-377,-244)
		
	end
	self:reload_json()
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
			else
				key = tonumber(key)
				if (self.skill_type == EnumSkillElements.all or self.skill_type == data.skill[key][1].element_type) then
					local soul_frag = avatar:get_soul_frag()
					local id = tostring(key)
					local temp_frag = soul_frag[id]
					local initstar = data.skill_initstar[tonumber(id)]
					local evolution = data.soul_evolution[initstar].sum_piece
					if temp_frag ~= nil and temp_frag >= evolution then
					 	local temp_key = tonumber(key)
						table.insert(skill_keys, temp_key)
					end

				end
			end
		end
		if self.zhizhaohuang == false then
			key = tonumber(key)
			if (self.skill_type == EnumSkillElements.all or self.skill_type == data.skill[key][1].element_type) then
				
				table.insert(skill_keys, key)
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
	else
		local function cmp(a,b)
			return a < b
		end
		table.sort(skill_keys, cmp)
	end
	-- else
	-- 	local function cmp(a,b)
	-- 		return self.skills[a]:get_score() > self.skills[b]:get_score()
	-- 	end
	-- 	table.sort(skill_keys, cmp)

	--end

	local page_count = 0
	local to_page = nil
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
				local skill_data = skill.data
				count = count + 1
				local cell = soul_card.soul_card( self,skill_data.type)
				cell:set_head_view(skill_data.icon)
				cell:set_name( skill_data.name )
				cell:set_pro_type( skill_data.element_type )
				cell:set_pro_level( skill_data.star )
				cell:set_level(self.skills[skill_id].lv)
				cell:set_is_call( true )
				--保存到卡牌容器
				self.cards[skill_id] = cell
				-- cell:set_cell_state( 'false' )
				-- cell:set_skill_idx(skill.data.id-3)
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

				--用来跳转到激活技能的那一页
				skill_id = tonumber(skill_id)
				
				if self.activate_id ~= nil and self.activate_id == skill_id then
					to_page = i
				end
			else

				-----没有召唤的
				skill_id = tonumber(skill_id)
				local skill_table = data.skill[skill_id]
				local skill_data = skill_table[1]
				count = count + 1
				local cell = soul_card.soul_card( self,skill_data.type)
				cell:set_head_view(skill_data.icon)
				cell:set_name( skill_data.name )
				cell:set_pro_type( skill_data.element_type )
				cell:set_is_call( false )
				cell:set_no_call( )

				--设置召唤碎片进度条显示
				local avatar = model.get_player()
				local soul_frag = avatar:get_soul_frag()
				local id = tostring(skill_id)
				local temp_frag = soul_frag[id]
				if temp_frag ~= nil then

					local initstar = data.skill_initstar[skill_id]
					local evolution = data.soul_evolution[initstar].sum_piece
					cell:set_bar_lbl(temp_frag,evolution)
					cell:set_bar_view(temp_frag,evolution)
				else
					local initstar = data.skill_initstar[skill_id]
					local evolution = data.soul_evolution[initstar].sum_piece
					cell:set_bar_lbl(0,evolution)
					cell:set_bar_view(0,evolution)
				end
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
		self.front_button:setVisible(false)
		self.next_button:setVisible(true)
	end
	--print('更新页了============================',to_page)
	self:set_page_hander()
	if to_page ~= nil then
		self.soul_page:scrollToPage(to_page-1)
		self.activate_id = nil
		--print('翻页了')
	end

end


--注册列表中按钮监听事件
function soul_page_panel:set_cell_hander( v ,skill_id)
	local function selected_event(sender, eventType)

	if eventType == ccui.TouchEventType.began then

	elseif eventType == ccui.TouchEventType.ended then
			if ui_mgr.get_ui('soul_info_panel') ~= nil then
				return
			end
			if v:get_is_call() == true  then
				
				select_s_id = skill_id
				ui_mgr.create_ui(import('ui.soul_system.soul_info_panel'), 'soul_info_panel')
				return
			end
			if v:get_is_call() == false and self.is_activating == false and v:get_can_call() == true then
				self.is_activating = true
				self.activate_id = skill_id
				ui_mgr.show_loading()
				server.sommon_skill(skill_id)
				return
			end

			if v:get_is_call() == false and v:get_can_call() == false then
				ui_mgr.show_loading()
				server.sommon_skill(skill_id)
			end

			--anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_UP_ANIM,false)
		elseif eventType == ccui.TouchEventType.canceled then
			
		end
	end
		
	v:get_button( ):addTouchEventListener(selected_event)
end






--注册翻页事件

function soul_page_panel:set_page_hander(  )
	 local function pageViewEvent(sender, eventType)
		if eventType == ccui.PageViewEventType.turning then
			local pageView = sender
			local pageInfo = pageView:getCurPageIndex() + 1 ..'/'.. self.page_numbers
				--print('显示前',pageView:getCurPageIndex() + 1)
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





function soul_page_panel:front_button_event( sender, eventType )

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

function soul_page_panel:next_button_event( sender, eventType )
		
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


function soul_page_panel:all_call_button_event( sender, eventType )
	if eventType == ccui.TouchEventType.ended then
		--music_mgr.ui_click()
		sender:setTouchEnabled(false)
		sender:setHighlighted(true)
		self.skill_type = EnumSkillElements.all
		self.soul_page:removeFromParent()
		self.soul_page = nil
		self:update_page( )
		
		self.fire_button:setTouchEnabled(true)
		self.fire_button:setHighlighted(false)
		self.ice_button:setTouchEnabled(true)
		self.ice_button:setHighlighted(false)
		self.nature_button:setTouchEnabled(true)
		self.nature_button:setHighlighted(false)
		self.real_button:setTouchEnabled(true)	
	end
end




function soul_page_panel:fire_button_event( sender, eventType )
	if eventType == ccui.TouchEventType.ended then
		--music_mgr.ui_click()
		sender:setTouchEnabled(false)
		sender:setHighlighted(true)
		self.skill_type = EnumSkillElements.fire
		self.soul_page:removeFromParent()
		self.soul_page = nil
		self:update_page(  )
		

		self.all_call_button:setTouchEnabled(true)
		self.all_call_button:setHighlighted(false)
		self.ice_button:setTouchEnabled(true)
		self.ice_button:setHighlighted(false)
		self.nature_button:setTouchEnabled(true)
		self.nature_button:setHighlighted(false)
		self.real_button:setTouchEnabled(true)
	end
end

function soul_page_panel:ice_button_event( sender, eventType )
	if eventType == ccui.TouchEventType.ended then
		--music_mgr.ui_click()
		sender:setTouchEnabled(false)
		sender:setHighlighted(true)
		self.skill_type = EnumSkillElements.ice
		self.soul_page:removeFromParent()
		self.soul_page = nil		
		self:update_page( )
		
		
		self.fire_button:setTouchEnabled(true)
		self.fire_button:setHighlighted(false)
		self.all_call_button:setTouchEnabled(true)
		self.all_call_button:setHighlighted(false)
		self.nature_button:setTouchEnabled(true)
		self.nature_button:setHighlighted(false)
		self.real_button:setTouchEnabled(true)
	end
end

function soul_page_panel:nature_button_event( sender, eventType )
	if eventType == ccui.TouchEventType.ended then
		--music_mgr.ui_click()
		sender:setTouchEnabled(false)
		sender:setHighlighted(true)
		self.skill_type = EnumSkillElements.nature
		self.soul_page:removeFromParent()
		self.soul_page = nil		
		self:update_page( )
		
		
		self.fire_button:setTouchEnabled(true)
		self.fire_button:setHighlighted(false)
		self.all_call_button:setTouchEnabled(true)
		self.all_call_button:setHighlighted(false)
		self.ice_button:setTouchEnabled(true)
		self.ice_button:setHighlighted(false)
		self.real_button:setTouchEnabled(true)
		
	end
end

function soul_page_panel:real_button_event( sender, eventtype )
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
		self.soul_page:removeFromParent()
		self.soul_page = nil
		self:update_page( )

	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end


function soul_page_panel:close_button_event(  sender, eventtype  )
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
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end

function soul_page_panel:release(  )
	print('release soul_page_panel')
	
	self.is_remove = false
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( sicon_set )
	super(soul_page_panel, self).release()
end

--信息界面返回时，更新相应的卡牌
function soul_page_panel:set_update_card( )
	self.is_updata_card = true
end

function soul_page_panel:update_card(  )
	local skill_id 	= tostring(select_s_id)
	local avatar = model.get_player()					--获取玩家数据
	local skills = avatar:get_skills()
	local cell 		= self.cards[select_s_id]
	local skill 	= skills[skill_id]
	local skill_data = skill.data
	
	cell:set_pro_level(skill_data.star)
	self.is_updata_card = false
end

function soul_page_panel:set_is_act( is_act )
	self.is_activating = is_act
end

function soul_page_panel:reload(  )
	super(soul_page_panel,self).reload()
	self:reload_json()
	
	if self.is_updata_card == true then
		self:update_card()
		return
	end

	if self.soul_page ~= nil then
		self.soul_page:removeFromParent()
		self.soul_page = nil
	end
	self:update_page()

end
