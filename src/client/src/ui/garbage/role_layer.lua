local uiwindows         = import( 'world.uiwindows')
local combat_attr       = import( 'data.combat_attr')

local entity			= import( 'world.entity' )
local char				= import( 'world.char' )
local model 			= import( 'model.interface' )
local music_mgr			= import( 'world.music_mgr' )
local combat_conf		= import( 'ui.role_detail.role_ui_conf' )
local layer				= import( 'world.layer' )
local locale			= import( 'utils.locale' )
local ui_const			= import( 'ui.ui_const' )

local guider_trigger    = import( 'ui.guider.guider_trigger')

role_layer  	        =  lua_class('role_layer', uiwindows.uiwindows)


local flag = false
local load_texture_type = TextureTypePLIST

EnumEquip = 
{
	equip_type_weapon	 = 1,
	equip_type_helmet	 = 2,
	equip_type_armour	 = 3,
	equip_type_necklace	 = 4,
	equip_type_ring      = 5,
	equip_type_shoe  	 = 6
}

function role_layer:_init()
	super(role_layer, layer)._init()
	self.skin = 'gui/main/new_role_equip_1.ExportJson'
	self.model = model.get_player()
	self.model:unbound_entity()  
end

function role_layer:update_equip_info( eq_info )

	self.lbl_panel_equip_name:setVisible(false)
	self.lbl_equip_prop_main:setVisible(false)
	self.lbl_equip_prop1:setVisible(false)
	self.lbl_equip_prop2:setVisible(false)
	self.lbl_equip_prop3:setVisible(false)
	self.lbl_equip_prop4:setVisible(false)

    --TAG
    self.lbl_equip_prop_mainname:setVisible(false)
    self.lbl_equip_prop1_name:setVisible(false)    
    self.lbl_equip_prop2_name:setVisible(false)    
    self.lbl_equip_prop3_name:setVisible(false)    
    self.lbl_equip_prop4_name:setVisible(false)


	if eq_info.name ~= nil then
		self.lbl_panel_equip_name:setString(eq_info.name)
		self.lbl_panel_equip_name:setVisible(true)
	end
	if eq_info.price ~= nil then
		self.lbl_panel_equip_price:setString(eq_info.price)
	end
	if eq_info.prop ~= nil then
		if eq_info.prop[1] ~= nil then
            local label = string_split(eq_info.prop[1],'/')
            local name = label[1]
            local num  = label[2]
            self.lbl_equip_prop_mainname:setString(name)
            self.lbl_equip_prop_mainname:setVisible(true)
			self.lbl_equip_prop_main:setString(num)
			self.lbl_equip_prop_main:setVisible(true)
		end
		if eq_info.prop[2] ~= nil then
                  
            local label = string_split(eq_info.prop[2],'/')
            local name = label[1]
            local num  = label[2]
            self.lbl_equip_prop1_name:setString(name)
            self.lbl_equip_prop1_name:setVisible(true)
			self.lbl_equip_prop1:setString(num)
			self.lbl_equip_prop1:setVisible(true)
		end
		if eq_info.prop[3] ~= nil then
            local label = string_split(eq_info.prop[3],'/')
            local name = label[1]
            local num  = label[2]
            self.lbl_equip_prop2_name:setString(name)
            self.lbl_equip_prop2_name:setVisible(true)
			self.lbl_equip_prop2:setString(num)
			self.lbl_equip_prop2:setVisible(true)
		end
		if eq_info.prop[4] ~= nil then
            local label = string_split(eq_info.prop[4],'/')
            local name = label[1]
            local num  = label[2]
            self.lbl_equip_prop3_name:setString(name)
            self.lbl_equip_prop3_name:setVisible(true)
			self.lbl_equip_prop3:setString(num)
			self.lbl_equip_prop3:setVisible(true)
		end
		if eq_info.prop[5] ~= nil then
            local label = string_split(eq_info.prop[5],'/')
            local name = label[1]
            local num  = label[2]
            self.lbl_equip_prop4_name:setString(name)
            self.lbl_equip_prop4_name:setVisible(true)
			self.lbl_equip_prop4:setString(num)
			self.lbl_equip_prop4:setVisible(true)
		end
	end

end

function role_layer:finish_init()
    self.widget:setPosition(VisibleSize.width/2, VisibleSize.height/2)


	self.list_one 	   = self:get_widget('list_property')
    self.list_one:setVisible(false)
    self.list_property = self:get_widget('list_pro')
    self.list_equip    = self:get_widget('list_equip')

    --show equip相关
    self.equip_box      = self:get_widget('equip_box')

    self.equip_button   = self:get_widget('button_equip')


   --self.equip_button:setBright(false)

    self.takeoff_button = self:get_widget('button_takeoff')

    self.takeoff_button:setVisible(false)

    --
    self.equip_view  = self:get_widget('equip_view')

	--正在使用的装备
    self.equip_table = {}

    --设置变量存使用的装备
    self.cur_wearing_idx = nil 
    self.helmet    = nil 
    self.armour	   = nil 
    self.necklace  = nil 
    self.ring      = nil 
    self.shoe      = nil 

	self.cur_wearingtype = 1

    --列表中的装备
    self.show_equip  = {}

	for i = 1, 6 do 
	 	table.insert(self.equip_table, self:get_widget(string.format("equip_%d", i)))
	end 
	self.equip_table[1]:setSelectedState(true)
	self.equip_table[1]:setTouchEnabled(false)
	--load图
	--根据啥的

	-- 主角动画
	self.model:init_combat_attr()
	local conf = import('char.role01') 
	local shadow_widget = self:get_widget('role_shadow')
	self.player = self:add_char()
	shadow_widget:addChild(self.player.cc)
	shadow_widget:setAnchorPoint(cc.p(0.5, 0.5))
	self.player.cc:setAnchorPoint(cc.p(0.5, 0))
	local shadow_size = shadow_widget:getLayoutSize()
	self.player.cc:setPosition(shadow_size.width/2-10, shadow_size.height*2/3)

	local player_pos = shadow_widget:getWorldPosition()
	local clickable_size = {width = 160, height = 220 }
	self.char_layer_x1 = player_pos.x - clickable_size.width/2
	self.char_layer_x2 = player_pos.x + clickable_size.width/2
	self.char_layer_y1 = player_pos.y 
	self.char_layer_y2 = player_pos.y + clickable_size.height

	-- 初始化文本框 start
	local player_attr = self.model.final_attrs
	for name, val in pairs(combat_conf.role_combat_attr) do
		self['lbl_' .. name] = self:get_widget('lbl_' .. name)
		self['txt_' .. name] = self:get_widget('txt_' .. name)
		local temp_name = self['lbl_' .. name]
		local temp_val = self['txt_' .. name]
		if temp_name ~= nil then
			--temp_name:setFontName('fonts/msyh.ttf')
			-- temp_name:setString(val .. '：')
			temp_name:setString(locale.get_value('role_' .. name) .. '：')
		end
		if temp_val ~= nil then
			--temp_val:setFontName('fonts/msyh.ttf')
			if player_attr[name] ~= nil then
				temp_val:setString(player_attr[name])
			else
				temp_val:setString('0')
			end
		end
	end

	-- 
	for name, val in pairs(combat_conf.role_ui_label) do
		self['lbl_' .. name] = self:get_widget('lbl_' .. name)
		local temp_label = self['lbl_' .. name]
		if temp_label ~= nil then
			--temp_label:setFontName('fonts/msyh.ttf')
			-- temp_label:setString(val.text)
			temp_label:setString(locale.get_value('role_' .. name))
			if val.edge ~= nil and val.edge > 0 then
				temp_label:enableOutline(ui_const.UilableStroke, val.edge)
			end
		end
	end
	-- 初始化文本框 end

	--显示武器
	self:add_list_equip()
	self:check_show_table()

	self.equip_descript = self:get_widget('equip_descript')
    self.equip_descript:setVisible(true)
	self:set_handler("button_close", self.button_close)
	self:set_handler("button_property", self.show_property)
	self:set_handler("button_equip" , self.button_equip)
	self:set_handler("button_takeoff", self.button_takeoff)

	--字体相关
	--左边 选择中的装备检查
	self:equip_check()

	--self:add_list_property()
	--初始化已有的装备
	
	self:update_panel()

end

function role_layer:button_close(sender, eventtype)

    	if eventtype == 0 then
		    print('press close')
		    music_mgr.ui_click()
	    end
	     if eventtype == ccui.TouchEventType.began then
	    
	     elseif eventtype == ccui.TouchEventType.moved then
	  
	     elseif eventtype == ccui.TouchEventType.ended then
	             self.cc:setVisible(false)

                 --新手指引相关
               --if not flag then 
                   --guider_trigger.post_notification()
                  -- flag = not flag 
              --  else

               -- end 
	     elseif eventtype == ccui.TouchEventType.canceled then
	     	
	     end
end  

function role_layer:button_equip(sender, eventype)
	--找到左边select状态的按钮
	if  eventype == ccui.TouchEventType.began then
		music_mgr.ui_click()
		for i, _v in pairs (self.show_equip) do 
			if _v:getSelectedState() and _v:getName() == 'false' then 

				for k, _k in pairs (self.equip_table) do 

					--为了快速拿到属性 --实际应道具id
					--现在应该改为装备id 不应该火weapon_id
					self.cur_wearing_idx = _v:getTag()

					if _k:getSelectedState() then 
                       if _k:getChildrenCount() > 0  then 
						--根据装备load 图
						    _k:removeAllChildren(true)
                       
						    --重置装备栏的状态
						    for i2, _v2 in pairs (self.show_equip) do 
							    --
							    if not _v2:getSelectedState () and _v2:getName() == 'true' then 
								    --_v2:removeChildByTag(99)
								    --重重装备为未装备状态
								    _v2:setName('false')
								    --_v2:getChildByTag(199):setVisible(false)
                                    _v2:getChildByName('select_light'):setVisible(false)
                                    _v2:getChildByName('equip_back'):setVisible(false)
                                    _v2:setTouchEnabled(true)
                                else

							    end 
						    end 
                        else
                            
                        end 


						-- print("doing here~~~~!", self.cur_wearing_idx)
    
				    	if self.cur_wearingtype == 1 then
							--self.model:change_weapon(self.cur_wearing_idx)
							self.player:change_equip(self.player.equip_conf.weapon, self.model.wearing.weapon)
						elseif self.cur_wearingtype == 2 then
							--self.model:change_helmet(self.cur_wearing_idx)
							self.player:change_equip(self.player.equip_conf.helmet, self.model.wearing.helmet)
						elseif self.cur_wearingtype == 3 then
							--self.model:change_armor(self.cur_wearing_idx)
							self.player:change_equip(self.player.equip_conf.armor, self.model.wearing.armor)
                        elseif self.cur_wearingtype == 4 then
							--self.model:change_necklace(self.cur_wearing_idx)
                        elseif self.cur_wearingtype == 5 then
							--self.model:change_ring(self.cur_wearing_idx)
                        elseif self.cur_wearingtype == 6 then
							--self.model:change_shoe(self.cur_wearing_idx)
						end

						server.change_equip(self.cur_wearing_idx)
						local view = ccui.ImageView:create()
						
                        view:loadTexture( self.wearing_data[_v:getTag()].data.icon, load_texture_type)

						view:setAnchorPoint(cc.p(0, 0))

                        --local show = _v:getChildByName('equip_show'):clone()

                        --  show:setAnchorPoint(cc.p(0, 0))

						_k:addChild(view, 100)
					end 
				end 

				--设置现在的装备状态
				_v:setName("true")

			 
                 _v:getChildByName('select_light'):setVisible(true)
                 _v:getChildByName('equip_back'):setVisible(true)
				self.equip_button:setVisible(false)
				self.takeoff_button:setVisible(true)

			elseif _v:getSelectedState () and _v:getName() == 'true' then 
			end 

			self:update_panel()
		end 
	end			
end 

function role_layer:button_takeoff(sender, eventype)
	if  eventype == ccui.TouchEventType.began then
		music_mgr.ui_click()
		for i, v in pairs (self.show_equip) do 
			if v:getSelectedState() and v:getName() == 'true' then 
	
				v:setName('false')

                --v:getChildByName('select_light'):setVisible(false)
                v:getChildByName('equip_back'):setVisible(false)

				self.equip_button:setVisible(true)
			
				self.takeoff_button:setVisible(false)
			

				for k, _k in pairs(self.equip_table) do 
					if _k:getSelectedState() then 
						_k:removeAllChildren()
					end 
				end 

				if self.cur_wearingtype == 1 then
					self.model:unload_weapon()
					self.player:change_equip(self.player.equip_conf.weapon, self.model.wearing.weapon)
				elseif self.cur_wearingtype == 2 then
					self.model:unload_helmet()
					self.player:change_equip(self.player.equip_conf.helmet, self.model.wearing.helmet)
				elseif self.cur_wearingtype == 3 then 
					self.model:unload_armor()
					self.player:change_equip(self.player.equip_conf.armor, self.model.wearing.armor)
				elseif self.cur_wearingtype == 4 then
					self.model:unload_necklace()
				elseif self.cur_wearingtype == 5 then
					self.model:unload_ring()
				elseif self.cur_wearingtype == 6 then
					self.model:unload_shoe()
				else
					-- others
				end
			end 	
		end 
		self:update_panel()
	end 

end 

function role_layer:set_visible()

    self.list_one:setVisible(false)
    self.equip_descript:setVisible(true)	
    --判断是显示装备还是卸下
    --weapon_id需要修改
    for i, _v in pairs (self.show_equip) do 
	    if _v:getTag() == self.cur_wearing_idx and _v:getSelectedState() and _v:getName() == 'true' then 
		    self.takeoff_button:setVisible(true)

	         self.equip_button:setVisible(false)
		    break
	    end 
    end 
			
    if not self.takeoff_button:isVisible() then 
	  
	    self.equip_button:setVisible(true)
    end 

end 

function role_layer:show_property(sender, eventype)
	-- 点击“属性”按钮
	if eventype == ccui.TouchEventType.began then
		if self.list_one:isVisible() then 
			self:set_visible()
			-- self.lbl_btn_property:setString('属性')
			self.lbl_btn_property:setString(locale.get_value('role_btn_property'))
		else
			self:updata()
			self.list_one:setVisible(true)

			self.equip_descript:setVisible(false)
			self.equip_button:setVisible(false)
		    self.takeoff_button:setVisible(false)
			
			-- self.lbl_btn_property:setString('装备')
			self.lbl_btn_property:setString(locale.get_value('role_btn_equip'))
		end  
		music_mgr.ui_click()
	end
end 

function role_layer:equip_check()
	for equip_type, v in pairs (self.equip_table) do

	    --暂时 测试   后面根据正在使用的装备设置装备图

	    if equip_type == EnumEquip.equip_type_weapon then
            self.wearing_icon  = self.model.wearing.weapon.data.icon
            	
	    elseif equip_type == EnumEquip.equip_type_helmet then
             self.wearing_icon  = self.model.wearing.helmet.data.icon    
             		 
	    elseif equip_type == EnumEquip.equip_type_armour then	
             self.wearing_icon  = self.model.wearing.armor.data.icon 
          
        elseif equip_type == EnumEquip.equip_type_necklace then       
               self.wearing_icon  = self.model.wearing.necklace.data.icon 
                     
        elseif equip_type == EnumEquip.equip_type_ring then 
               self.wearing_icon  = self.model.wearing.ring.data.icon   
                
        elseif equip_type == EnumEquip.equip_type_shoe then 
               self.wearing_icon  = self.model.wearing.shoe.data.icon
       
	    else
		    self.wearing_data = {} 
	    end
        --dir(self.wearing_data[equip_type].data.icon)
        local equip = ccui.ImageView:create()
        equip:loadTexture( self.wearing_icon, load_texture_type)
        equip:setPosition(cc.p(0, 0))
        equip:setAnchorPoint(cc.p(0, 0))
        v:addChild(equip, 100)


		local function selected_event(sender,eventType)
			music_mgr.ui_click()
	        if eventType == ccui.CheckBoxEventType.selected then
				self.cur_wearingtype = equip_type
	        	sender:setTouchEnabled(false)

	        	--传装备部位
	        	self:add_list_equip()
	        	self:check_show_table()
	        	--卸装相关
				self.takeoff_button:setVisible(false)

				self.list_one:setVisible(false)
                self.equip_descript:setVisible(true)	
               --判断是显示装备还是卸下     
                self:set_visible()		            
	        	--后面改成EnumEquip.equip_type_weapon之类的
	        	if equip_type == EnumEquip.equip_type_weapon then 
	 				-- self.lbl_equip_title:setString("武器")
	 				self.lbl_equip_title:setString(locale.get_value('role_lbl_weapon'))
	 			elseif equip_type == EnumEquip.equip_type_helmet then 
	 				-- self.lbl_equip_title:setString("头盔")
	 				self.lbl_equip_title:setString(locale.get_value('role_lbl_helmet'))
	 			elseif equip_type == EnumEquip.equip_type_armour then 
	 				-- self.lbl_equip_title:setString("盔甲")
	 				self.lbl_equip_title:setString(locale.get_value('role_lbl_armour'))
	 			elseif equip_type == EnumEquip.equip_type_necklace then 
	 				-- self.lbl_equip_title:setString("项链")
	 				self.lbl_equip_title:setString(locale.get_value('role_lbl_necklace'))
	 			elseif equip_type == EnumEquip.equip_type_ring then 
	 				-- self.lbl_equip_title:setString("戒指")
	 				self.lbl_equip_title:setString(locale.get_value('role_lbl_ring'))
	 			elseif equip_type == EnumEquip.equip_type_shoe then 
	 				-- self.lbl_equip_title:setString("鞋子")
	 				self.lbl_equip_title:setString(locale.get_value('role_lbl_shoe'))
	 			end 

	        	for k , _v in pairs(self.equip_table) do 
	        		if equip_type ~= k then 
	        			_v:setSelectedState(false)
	        			_v:setTouchEnabled(true)
	        		end 
	        	end
	        elseif eventType == ccui.CheckBoxEventType.unselected then
	        	sender:setTouchEnabled(true)	
	        end
	    end
	    --装备类型
	    v:setTag(equip_type)
		v:addEventListener(selected_event)
	end  
end 
 
--传点击的id进来 相应的修改数据表
function role_layer:add_list_equip()

	self.list_equip:requestRefreshView()
   -- self.list_equip:setContentOffset(cc.p(500, 500), true)
   --self.list_equip:scrollToPercentVertical
    --self.list_equip:setInnerContainerSize(cc.size(480, 10000))
	--self.list_equip:refreshView()
	--data.weapondata.weapon
	--清空
	self.show_equip = {}
	self.list_equip:removeAllChildren()

	self.cur_wearing_idx = 1

	if self.cur_wearingtype == 1 then
		self.wearing_data = self.model.items.weapon
		self.cur_wearing_idx = self.model.wearing.weapon.id
	elseif self.cur_wearingtype == 2 then
		self.wearing_data = self.model.items.helmet
		self.cur_wearing_idx = self.model.wearing.helmet.id
	elseif self.cur_wearingtype == 3 then 
		self.wearing_data = self.model.items.armor
		self.cur_wearing_idx = self.model.wearing.armor.id
    elseif self.cur_wearingtype == 4 then 
		self.wearing_data = self.model.items.necklace
		self.cur_wearing_idx = self.model.wearing.necklace.id
    elseif self.cur_wearingtype == 5 then 
		self.wearing_data = self.model.items.ring
		self.cur_wearing_idx = self.model.wearing.ring.id
    elseif self.cur_wearingtype == 6 then 
		self.wearing_data = self.model.items.shoe
		self.cur_wearing_idx = self.model.wearing.shoe.id
	else
		self.wearing_data = {} 
	end

    --dir(self.wearing_data[1].data.icon)
   -- print( self.model.wearing.shoe.id)
   -- print(self.model.wearing.shoe.data.id)
   --print(self.cur_wearing_idx)

   --这里不是从裸装开始读 而是第一件装备开始读
	for index = 1, #self.wearing_data do 

        local box =  self.equip_box:clone()
		local equip_data = self.wearing_data[index].data
        
        box:getChildByName('select_light'):setVisible(false)
        box:getChildByName('equip_back'):setVisible(false)
		box:getChildByName('equip_show'):loadTexture(equip_data.icon, load_texture_type)
        --box:setTag(self.wearing_data[index].id)
        box:setTag(index)
        box:setName("false")
        local label = box:getChildByName('lbl_box_equip_name')
		label:setString(equip_data.name)

        local label2 = box:getChildByName('lbl_box_equip_level')


      
        if self.wearing_data[index].id == self.cur_wearing_idx then 
            print(self.wearing_data[index].id)
			--根据道具id设置tag
			box:setName("true")
			box:getChildByName('equip_back'):setVisible(true)
            --box:setTouchEnabled(false)
		    --self.takeoff_button:setVisible(true) 

		--elseif index == 1 then 
		    box:setSelectedState(true)
		    box:getChildByName('select_light'):setVisible(true)
            self:get_equip_property(index)
            self.equip_view:loadTexture(self.wearing_data[index].data.icon, load_texture_type)
            box:setTouchEnabled(false)

		end

  		self.list_equip:addChild(box)
        
        table.insert(self.show_equip, box)

  	end 
end

function role_layer:check_show_table()
	for i, v in pairs(self.show_equip) do
		local function selected_event(sender, eventType)
			-- self.lbl_btn_property:setString('属性')
	        if eventType == ccui.CheckBoxEventType.selected then
	        	sender:setTouchEnabled(false)

	        	self.equip_descript:setVisible(true)
	        	self.list_one:setVisible(false)
	  
	        	self.equip_view:loadTexture(self.wearing_data[v:getTag()].data.icon, load_texture_type) 
	        		--卸下按钮的显示
	        	  	--判断是否是穿的装备id 
					if v:getSelectedState() and v:getName() == 'true' then                    
						self.equip_button:setVisible(false)

						self.takeoff_button:setVisible(true)   
		
					else
						self.equip_button:setVisible(true)
				
						self.takeoff_button:setVisible(false)
		
					end 
	        	for k , _v in pairs(self.show_equip) do 
	        		if i ~= k then 
	        			_v:setSelectedState(false)
	        			_v:setTouchEnabled(true)
                        _v:getChildByName('select_light'):setVisible(false)		
	        		else
                         _v:getChildByName('select_light'):setVisible(true)	
                         --_v:setTouchEnabled(false)
	        		end 
	        	end
	        elseif eventType == ccui.CheckBoxEventType.unselected then
	        	sender:setTouchEnabled(true)	
	        end

			self:get_equip_property( i )
			music_mgr.ui_click()

	    end

		v:addEventListener(selected_event)
	end 
end

-- 角色属性更新
function role_layer:updata()
	local player_attr = self.model.final_attrs
	for name, val in pairs(combat_conf.role_combat_attr) do
		self['lbl_' .. name] = self:get_widget('lbl_' .. name)
		self['txt_' .. name] = self:get_widget('txt_' .. name)
		local temp_name = self['lbl_' .. name]
		local temp_val = self['txt_' .. name]
		if temp_name ~= nil then
			-- temp_name:setString(val .. '：')
			temp_name:setString(locale.get_value('role_' .. name) .. '：')
		end
		if temp_val ~= nil then
			if player_attr[name] ~= nil then
				temp_val:setString(player_attr[name])
			else
				temp_val:setString('0')
			end
		end
	end

end 

-- 简明数值更新
function role_layer:update_panel()
	self.lbl_panel_attack:setString(self.model.final_attrs.attack)
	self.lbl_panel_hp:setString(self.model.final_attrs.hp)
	self.lbl_panel_capability:setString('teamtop')

	self:play_first_anim()
end

-- 添加玩家动画
function role_layer:add_char()
	--TODO: 换成配置的import文件
	local conf = import('char.role01') 
	local entity_anim = char.char(conf)
	entity_anim.cc:setLocalZOrder(11110)

	entity_anim:change_equip(entity_anim.equip_conf.weapon, self.model.wearing.weapon)
	entity_anim:change_equip(entity_anim.equip_conf.helmet, self.model.wearing.helmet)
	entity_anim:change_equip(entity_anim.equip_conf.armor, self.model.wearing.armor)

	self.animset = {}
	self.cur_anim_key = '' 
	self.first_key = 'idle'
	self.first_anim = nil

	for k, v in pairs(conf) do
		if type(v) == 'table' and v.anim ~= nil
	   and (k == 'attack' or k == 'idle' or k == 'run') then
			if self.first_anim == nil then
				self.first_key = k
				self.first_anim = v.anim
			end
			self.animset[k] = v.anim
			self.cur_anim_key = k
		end
	end
	entity_anim:play_anim(self.animset[self.cur_anim_key])

	local function click_began(sender, eventType)
		-- print(self.cc:isVisible())
		-- if self.cc:isVisible() == false then
		-- 	return false
		-- end
		-- print('click start')
		-- return true

		-- 点击角色切换动作
		local touch_pos = sender:getLocation()
		if touch_pos.x > self.char_layer_x1 and touch_pos.x < self.char_layer_x2
		and touch_pos.y > self.char_layer_y1 and touch_pos.y < self.char_layer_y2 then
			self:alter_anim()
		end
	end

	local function char_click(sender, eventType)
		print('click end')
		-- -- 点击角色切换动作
		-- local touch_pos = sender:getLocation()
		-- if touch_pos.x > self.char_layer_x1 and touch_pos.x < self.char_layer_x2
		-- and touch_pos.y > self.char_layer_y1 and touch_pos.y < self.char_layer_y2 then
		-- 	self:alter_anim()
		-- end
		-- return false
	end

	local listener1 = cc.EventListenerTouchOneByOne:create()
	listener1:setSwallowTouches(true)
	-- listener1:registerScriptHandler(char_click, cc.Handler.EVENT_TOUCH_BEGAN )
	listener1:registerScriptHandler(click_began, cc.Handler.EVENT_TOUCH_BEGAN )
	listener1:registerScriptHandler(char_click, cc.Handler.EVENT_TOUCH_ENDED )
	local eventDispatcher = self.cc:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, entity_anim.cc)
	return entity_anim
end

function role_layer:play_first_anim()
	self.player:play_anim(self.animset['idle'])
	--[[
	if self.first_anim ~= nil then
		self.player:play_anim(self.first_anim)
		self.cur_anim_key = self.first_key
	end
	--]]
end

function role_layer:alter_anim()
	local flag = false
	local next_key = self.cur_anim_key
	local next_anim = nil
	for k, v in pairs(self.animset) do
		if flag == true then
			next_key = k
			next_anim = v
			break
		end
		if flag == false and self.cur_anim_key == k then
			flag = true
		end
	end
	if self.cur_anim_key == next_key and self.first_anim ~= nil then
		self.player:play_anim(self.first_anim)
		self.cur_anim_key = self.first_key
	elseif next_anim ~= nil then
		self.player:play_anim(next_anim)
		self.cur_anim_key = next_key
	end
end

-- 武器属性更新
function role_layer:get_equip_property( equip_index )
	-- self.lbl_btn_property:setString('属性')
	self.lbl_btn_property:setString(locale.get_value('role_btn_property'))
	local equip_data = nil
	local combat_dat = nil
	if self.cur_wearingtype == 1 then
		equip_data = self.model.items.weapon
	elseif self.cur_wearingtype == 2 then
		equip_data = self.model.items.helmet
	elseif self.cur_wearingtype == 3 then 
		equip_data = self.model.items.armor
    elseif self.cur_wearingtype == 4 then 
		equip_data = self.model.items.necklace
    elseif self.cur_wearingtype == 5 then 
		equip_data = self.model.items.ring
    elseif self.cur_wearingtype == 6 then 
		equip_data = self.model.items.shoe
	else

	end

	if equip_data == nil then
		return
	end

	local equip_info_to_return = {}
	equip_info_to_return.name = equip_data[equip_index].data.name
	equip_info_to_return.price = equip_data[equip_index].data.sell_price
	combat_dat = self.model.attrs:get_appenddata_byid(equip_data[equip_index].data.combat_conf)
	if combat_dat == nil then
		equip_info_to_return.prop = nil
	else
		equip_info_to_return.prop = {}
		local propcount = 1
		if combat_dat.attack > 0 then
			equip_info_to_return.prop[propcount] = locale.get_value('role_attack') .. ' : /' .. combat_dat.attack
			-- equip_info_to_return.prop[propcount] = '攻击力 : /' .. combat_dat.attack
			propcount = propcount + 1
		end
		if combat_dat.defense > 0 then
			equip_info_to_return.prop[propcount] = locale.get_value('role_defense') .. ' : /' .. combat_dat.defense
			-- equip_info_to_return.prop[propcount] = '防御 : /' .. combat_dat.defense
			propcount = propcount + 1
		end
		if combat_dat.hp > 0 then
			equip_info_to_return.prop[propcount] = locale.get_value('role_max_hp') .. ' : /' .. combat_dat.hp
			-- equip_info_to_return.prop[propcount] = '生命 : /' .. combat_dat.hp
			propcount = propcount + 1
		end
		if combat_dat.mp > 0 then
			equip_info_to_return.prop[propcount] = locale.get_value('role_max_mp') .. ' : /' ..combat_dat.mp
			-- equip_info_to_return.prop[propcount] = '能量 : /' ..combat_dat.mp
			propcount = propcount + 1
		end
		if combat_dat.crit_level > 0 then
			equip_info_to_return.prop[propcount] = locale.get_value('role_crit_level') .. ' : /' ..combat_dat.crit_level
			-- equip_info_to_return.prop[propcount] = '暴击等级 : /' ..combat_dat.crit_level
			propcount = propcount + 1
		end
		if combat_dat.hit_level > 0 then
			equip_info_to_return.prop[propcount] =  locale.get_value('role_hit_level') .. ' : /' ..combat_dat.hit_level
			-- equip_info_to_return.prop[propcount] =  '命中等级 : /' ..combat_dat.hit_level
			propcount = propcount + 1
		end
		if combat_dat.avoid_level > 0 then
			equip_info_to_return.prop[propcount] = locale.get_value('role_avoid_level') .. ' : /' .. combat_dat.avoid_level
			-- equip_info_to_return.prop[propcount] = '闪避等级 : /' .. combat_dat.avoid_level
			propcount = propcount + 1
		end
		if combat_dat.hp_recover > 0 then
			equip_info_to_return.prop[propcount] = locale.get_value('role_hp_recover') .. ' : /' ..combat_dat.hp_recover
			-- equip_info_to_return.prop[propcount] = '生命恢复 : /' ..combat_dat.hp_recover
			propcount = propcount + 1
		end
		if combat_dat.take_hp > 0 then
			equip_info_to_return.prop[propcount] = locale.get_value('role_take_hp') .. ' : /' .. combat_dat.take_hp
			-- equip_info_to_return.prop[propcount] = '生命窃取 : /' .. combat_dat.take_hp
			propcount = propcount + 1
		end
	end

	self:update_equip_info( equip_info_to_return )
end

--测试反色
function role_layer:fan_fun()

   
end
