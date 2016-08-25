local ui_const = import( 'ui.ui_const' )
local model 				= import( 'model.interface' )
local skill_select_layer	= import( 'ui.skill_select_system.skill_select_layer' )
local skill_cell 		= import( 'ui.skill_select_system.skill_cell' )
local ui_mgr			= import( 'ui.ui_mgr' )


skill_list_panel = lua_class('skill_list_panel')
local sicon_set = 'icon/s_icons.plist'

function skill_list_panel:_init( layer )
	self.layer = layer

	--向前翻页
	local function front_button_event(_, sender, eventtype )
		if skill_select_layer.get_touch() == false then
			return
		end
		
		if  eventtype == ccui.TouchEventType.ended then
			if self.skill_page:getCurPageIndex()+1 > 1 then 
				self.front_button:setVisible(true)
				self.skill_page:scrollToPage(self.skill_page:getCurPageIndex()-1)
			end
			if self.skill_page:getCurPageIndex()+1 == 1 then
				sender:setVisible(false)
			end

		end
	end


	--向后翻页
	local function next_button_event(_, sender, eventtype )
		if skill_select_layer.get_touch() == false then
			return
		end

		if eventtype == ccui.TouchEventType.ended then
			if self.skill_page:getCurPageIndex()+1 < self.page_numbers then
				self.next_button:setVisible(true) 
				self.skill_page:scrollToPage(self.skill_page:getCurPageIndex()+1)
			end
			if self.skill_page:getCurPageIndex()+1 == self.page_numbers then
				sender:setVisible(false)
			end
		end
	end

	--翻页按钮
	self.front_button = self.layer:get_widget('front_button')
	self.next_button = self.layer:get_widget('next_button')
	self.layer:set_handler('front_button', next_button_event)
	self.layer:set_handler('next_button', front_button_event)
	self.layer:get_widget('next_button'):setVisible(false) 
	--self.layer:get_widget('z1_1'):setFontName(ui_const.UiLableFontType)

	--
	local avatar = model.get_player()
	self.skills = avatar:get_skills()
	self.skill_type = EnumSkillElements.all
	self.skill_1 = nil
	self.skill_2 = nil
	self.skill_3 = nil


	ui_mgr.schedule_once(0, self, self.first_init)
	local function all_button_event(_, sender, eventType )
		if skill_select_layer.get_touch() == false then
			return
		end
		
		if eventType == ccui.CheckBoxEventType.selected then
			--music_mgr.ui_click()
			sender:setTouchEnabled(false)
			sender:setSelectedState(true)
			self.skill_type = EnumSkillElements.all
			self.skill_1 = nil
			self.skill_2 = nil
			self.skill_3 = nil
			self:update_list_view( )
			
			self.fire_button:setTouchEnabled(true)
			self.fire_button:setSelectedState(false)
			self.ice_button:setTouchEnabled(true)
			self.ice_button:setSelectedState(false)
			self.nature_button:setTouchEnabled(true)
			self.nature_button:setSelectedState(false)
			
		elseif eventType == ccui.CheckBoxEventType.unselected then
			sender:setTouchEnabled(true)	
		end
	end

	local function fire_button_event(_, sender, eventType )
		if skill_select_layer.get_touch() == false then
			return
		end
		
		if eventType == ccui.CheckBoxEventType.selected then
			--music_mgr.ui_click()
			sender:setTouchEnabled(false)
			sender:setSelectedState(true)
			self.skill_type = EnumSkillElements.fire
			self.skill_1 = nil
			self.skill_2 = nil
			self.skill_3 = nil
			self:update_list_view( )

			self.all_button:setTouchEnabled(true)
			self.all_button:setSelectedState(false)
			self.ice_button:setTouchEnabled(true)
			self.ice_button:setSelectedState(false)
			self.nature_button:setTouchEnabled(true)
			self.nature_button:setSelectedState(false)
			
		elseif eventType == ccui.CheckBoxEventType.unselected then
			sender:setTouchEnabled(true)	
		end
	end

	local function ice_button_event(_, sender, eventType )
		if skill_select_layer.get_touch() == false then
			return
		end
		
		if eventType == ccui.CheckBoxEventType.selected then
			--music_mgr.ui_click()
			sender:setTouchEnabled(false)
			sender:setSelectedState(true)
			self.skill_type = EnumSkillElements.ice
			self.skill_1 = nil
			self.skill_2 = nil
			self.skill_3 = nil
			self:update_list_view( )
			
			self.fire_button:setTouchEnabled(true)
			self.fire_button:setSelectedState(false)
			self.all_button:setTouchEnabled(true)
			self.all_button:setSelectedState(false)
			self.nature_button:setTouchEnabled(true)
			self.nature_button:setSelectedState(false)
		elseif eventType == ccui.CheckBoxEventType.unselected then
			sender:setTouchEnabled(true)	
		end
	end

	local function nature_button_event(_, sender, eventType )
		if skill_select_layer.get_touch() == false then
			return
		end

		if eventType == ccui.CheckBoxEventType.selected then
			--music_mgr.ui_click()
			sender:setTouchEnabled(false)
			sender:setSelectedState(true)
			self.skill_type = EnumSkillElements.nature
			self.skill_1 = nil
			self.skill_2 = nil
			self.skill_3 = nil
			self:update_list_view( )
			
			self.fire_button:setTouchEnabled(true)
			self.fire_button:setSelectedState(false)
			self.all_button:setTouchEnabled(true)
			self.all_button:setSelectedState(false)
			self.ice_button:setTouchEnabled(true)
			self.ice_button:setSelectedState(false)
		elseif eventType == ccui.CheckBoxEventType.unselected then
			sender:setTouchEnabled(true)	
		end
	end

	--按钮--
	self.all_button 	= self.layer:get_widget('all_button')
	self.fire_button 	= self.layer:get_widget('fire_button')
	self.ice_button 	= self.layer:get_widget('ice_button')
	self.nature_button 	= self.layer:get_widget('nature_button')

	self.layer:set_handler("all_button", all_button_event)
	self.layer:set_handler("fire_button", fire_button_event)
	self.layer:set_handler("ice_button", ice_button_event)
	self.layer:set_handler("nature_button", nature_button_event)
	--self:update_display()
	--更新选择面板和列表
	self.layer:get_skill_display_panel():update_display()
	self:update_list_view( )
	--设置翻页事件
	self:set_page_hander( )
	

	self.all_button:setTouchEnabled(false)
	self.all_button:setSelectedState(true)



end

function skill_list_panel:first_init()
	--更新选择面板和列表
	self.layer:get_skill_display_panel():update_display()
	self:update_list_view( )
	
	--设置翻页事件
	self:set_page_hander( )
end

function skill_list_panel:getIntPart( x )
	-- body
	if x <= 0 then
		return math.ceil(x)
	end

	if math.ceil(x) == x then
		x = math.ceil(x)
	else
		x = math.ceil(x) - 1
	end
	return x
end

function skill_list_panel:table_count( ht )
	local n = 0
	for i,v in pairs(ht) do
		n = n+1
	end
	return n
end




--更新列表
function skill_list_panel:update_list_view(  )
	-- body
	cc.SpriteFrameCache:getInstance():addSpriteFrames( sicon_set )
	self.layer:reload_json()
	self.skill_page = self.layer:get_widget( 'skill_page' )
	self.z1_1 = self.layer:get_widget('z1_1')
	self.skill_page:removeAllPages()

	local avatar = model.get_player()					--获取玩家数据
	self.skills = avatar:get_skills()
	--玩家技能的列表长度
	local skill_keys = {}
	for key, skill in pairs(self.skills) do
		if self.skill_type == EnumSkillElements.all or self.skill_type == skill:get_element_type() then
			table.insert(skill_keys, key)
		end
	end
	local function cmp(a,b)
		return self.skills[a]:get_score() > self.skills[b]:get_score()
	end
	table.sort(skill_keys, cmp)

	local page_count = 0
	local cur_cell_count = #skill_keys
	--计算页数
	local temp_count = self:getIntPart(cur_cell_count/6)
	
	if temp_count < cur_cell_count/6 then
		page_count = temp_count+1
	else
		page_count = temp_count
	end 
	self.page_numbers = page_count
	
	local temp = 0
	local count = 0
	local z_count = 1
	--取出已装备的数据
	local cast_skill = avatar:get_loaded_skills()  --装备的技能
	for i = 1 , page_count do
		--新建页面
		local layout = ccui.Layout:create()
		self.skill_page:addPage(layout)
		--self.skill_page:insertPage(layout,i)
		temp = (i-1)*6+1+6-1  --
		
		--如果比实际总个数少和等于，这一页就按temp的数量
		if temp >= cur_cell_count then
			temp = cur_cell_count
		end
		-- if temp <= cur_cell_count then
		-- 	temp = temp
		-- -- else
		-- -- 	temp =(i-1)*16+(16-(temp - cur_cell_count))  --实际这一页有多少个
		-- end

		for j = (i-1)*6+1,temp do
			local skill_id = skill_keys[j]
			local skill = self.skills[skill_id]
			if skill ~= nil then
				local data = skill.data
				count = count + 1
				local cell = skill_cell.skill_cell( self.layer )
				cell:set_head_view( data.icon)
				--暂时数据信息设置为图片名
				cell:set_skill_data( skill )
				cell:set_name(data.name)
				cell:set_pro_type( data.element_type )
				cell:set_star_level( skill.star )
				cell:set_cell_state( 'false' )
				cell:set_skill_idx(skill_id)
				cell:set_cell_grade(self.skills[skill_id].lv)
				local SoulBox = cell:get_cell( )

				if (count-6*(i-1))%3 == 1 then
					SoulBox:setPosition(92,407-self:getIntPart((count-6*(i-1))/3)*241)
				elseif (count-6*(i-1))%3 == 2 then
					SoulBox:setPosition(265,407-self:getIntPart((count-6*(i-1))/3)*241)					
				elseif (count-6*(i-1))%3 == 0 then
					SoulBox:setPosition(439,407-self:getIntPart(((count-6*(i-1))/3)-1)*241)		
				end

				--由高到低，z值越少。
				z_count = z_count - 1
				layout:addChild(SoulBox,z_count)
				--根据avator装备那些技能，设置打钩
				--主动 1到3 被动4到6
				for idx = 1, 3 do
					local sk = cast_skill[idx]
					if sk ~= nil and sk == skill  then
						self['skill_'..idx] = cell
						cell:set_cell_state( 'true' )
						cell:set_cell_Image_gray()
						
					end
				end
				--为每个格子设置监听时间
				self:set_cell_hander( cell )	
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
    if page_count > 1 and self.skill_page:getCurPageIndex() + 1 >1 then
    --跳回到第一页
		self.skill_page:scrollToPage(0)
	end
	if page_count == 1 then
		self.next_button:setVisible(false)
		self.front_button:setVisible(false)
	else
		self.front_button:setVisible(true)
	end
end


--注册翻页事件

function skill_list_panel:set_page_hander(  )
	 local function pageViewEvent(sender, eventType)
		if eventType == ccui.PageViewEventType.turning then
			local pageView = sender
			local pageInfo = pageView:getCurPageIndex() + 1 ..'/'.. self.page_numbers

			if pageView:getCurPageIndex() + 1 > 1 then
				
				self.next_button:setVisible(true)
			else
				
				self.next_button:setVisible(false)
			end
			if pageView:getCurPageIndex() + 1 >= self.page_numbers then
				
				self.front_button:setVisible(false)
			else
				
				self.front_button:setVisible(true)
			end
			self.z1_1:setString(pageInfo)
		end
	end 
	self.skill_page:addEventListener(pageViewEvent)
end


--注册列表中按钮监听事件
function skill_list_panel:set_cell_hander( v )
		local function selected_event(sender, eventType)
			--主动技能
			if skill_select_layer.get_touch() == false then
				return
			end

			if eventType == ccui.TouchEventType.ended then
				self.layer:reload_json()
				if v:get_cell_state() ~= true then
						
						local avatar = model.get_player()	
						local cast_skill = avatar:get_loaded_skills()  --装备的技能
						for idx = 1, 3 do
							local sk = cast_skill[idx]
							if sk == nil  then
			
								v:set_cell_state( 'true' )
								v:set_cell_Image_gray()
								model.get_player():load_skill(idx, v:get_skill_idx())
								self['skill_'..idx] = v
								--插入选择面板的主动icon
								self.layer:get_skill_display_panel():replace_icon(idx , v:get_skill_data().data.icon ,v:get_skill_pro_type() ,'a',v.level )
								
								break
							end
						end
				else
						
						local avatar = model.get_player()	
						local cast_skill = avatar:get_loaded_skills()  --装备的技能
						for idx = 1, 3 do
							local sk = cast_skill[idx]
							if sk ~= nil and sk == v:get_skill_data()  then

								v:set_cell_state( 'false' )
								v:restore_cell_Image_color( )
								model.get_player():load_skill(idx, nil)

								--删除选择面板的主动 icon
								self.layer:get_skill_display_panel():delete_icon( idx ,'a')	
								self['skill_'..idx] = nil
								break
							end
						end
				end
			end

		end
		
		self.layer:set_widget_handler(v:get_cell(), selected_event, v:get_skill_idx())
end



function skill_list_panel:cancel_skill_by_pos( pos )
	local btn = self['skill_'..pos]
	if btn == nil then 
		return
	end
	btn:set_cell_state( 'false' )
	btn:restore_cell_Image_color( )
	self['skill_'..pos] = nil
end
