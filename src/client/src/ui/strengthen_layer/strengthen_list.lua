
local strengthen_cell  	= import( 'ui.strengthen_layer.strengthen_cell' )
local model 			= import( 'model.interface' )
local navigation_bar	= import( 'ui.equip_sys_layer.navigation_bar' ) 
local ui_const 				= import( 'ui.ui_const' )

strengthen_list = lua_class('strengthen_list')
local eicon_set = 'icon/e_icons.plist'

function strengthen_list:_init( layer ,select_id)
	self.layer = layer
	
	self.list_row_count = 5 
	self.select_id = select_id --选中的装备id
	self.sel_eq_cell 		= nil
	self.sel_btn			= nil
	--self.eqed_cell 			= nil
	if select_id == nil then
		self.cur_wearing_type = 'weapon'
	else
		self.cur_wearing_type = data.item_id[select_id]
	end
	self.list_equip = self.layer:get_widget('list_strengthen')
	self.lbl_title = self.layer:get_widget('lbl_title')
	
	self:init_button()
	self:updata_button(self.cur_wearing_type)
	--self:update_list()
end



function strengthen_list:init_button(  )
	self.weapon_button = self.layer:get_widget('weapon_button')
	self.helmet_button = self.layer:get_widget('helmet_button')
	self.armor_button = self.layer:get_widget('armor_button')
	self.necklace_button = self.layer:get_widget('necklace_button')
	self.ring_button = self.layer:get_widget('ring_button')
	self.shoe_button = self.layer:get_widget('shoe_button')


	-- event handler
	local function weapon_button_event(_, sender, eventType)
		if eventType == ccui.CheckBoxEventType.selected then
			self.sel_btn:setSelectedState(false)
			self.sel_btn:setTouchEnabled(true)
			sender:setSelectedState(true)
			sender:setTouchEnabled(false)
			self.sel_btn = sender
			self.select_id = nil
			self.cur_wearing_type = 'weapon'
			self:update_list()
		elseif eventType == ccui.CheckBoxEventType.unselected then
		end
	end

	local function helmet_button_event(_, sender, eventType)
		if eventType == ccui.CheckBoxEventType.selected then
			self.sel_btn:setSelectedState(false)
			self.sel_btn:setTouchEnabled(true)
			sender:setSelectedState(true)
			sender:setTouchEnabled(false)
			self.sel_btn = sender
			self.select_id = nil
			self.cur_wearing_type = 'helmet'
			self:update_list()
		elseif eventType == ccui.CheckBoxEventType.unselected then
		end
	end

	local function armor_button_event(_, sender, eventType)
		if eventType == ccui.CheckBoxEventType.selected then
			self.sel_btn:setSelectedState(false)
			self.sel_btn:setTouchEnabled(true)
			sender:setSelectedState(true)
			sender:setTouchEnabled(false)
			self.sel_btn = sender
			self.select_id = nil
			self.cur_wearing_type = 'armor'
			self:update_list()
		elseif eventType == ccui.CheckBoxEventType.unselected then
		end
	end

	local function necklace_button_event(_, sender, eventType)
		if eventType == ccui.CheckBoxEventType.selected then
			self.sel_btn:setSelectedState(false)
			self.sel_btn:setTouchEnabled(true)
			sender:setSelectedState(true)
			sender:setTouchEnabled(false)
			self.sel_btn = sender
			self.select_id = nil
			self.cur_wearing_type = 'necklace'
			self:update_list()
		elseif eventType == ccui.CheckBoxEventType.unselected then
		end
	end

	local function ring_button_event(_, sender, eventType)
		if eventType == ccui.CheckBoxEventType.selected then
			self.sel_btn:setSelectedState(false)
			self.sel_btn:setTouchEnabled(true)
			sender:setSelectedState(true)
			sender:setTouchEnabled(false)
			self.sel_btn = sender
			self.select_id = nil
			self.cur_wearing_type = 'ring'
			self:update_list()
		elseif eventType == ccui.CheckBoxEventType.unselected then
		end
	end

	local function shoe_button_event(_, sender, eventType)
		if eventType == ccui.CheckBoxEventType.selected then
			self.sel_btn:setSelectedState(false)
			self.sel_btn:setTouchEnabled(true)
			sender:setSelectedState(true)
			sender:setTouchEnabled(false)
			self.sel_btn = sender
			self.select_id = nil
			self.cur_wearing_type = 'shoe'
			self:update_list()
		elseif eventType == ccui.CheckBoxEventType.unselected then
		end
	end

	self.layer:set_handler('weapon_button',weapon_button_event)
	self.layer:set_handler('helmet_button',helmet_button_event)
	self.layer:set_handler('armor_button',armor_button_event)
	self.layer:set_handler('necklace_button',necklace_button_event)
	self.layer:set_handler('ring_button',ring_button_event)
	self.layer:set_handler('shoe_button',shoe_button_event)

end

function strengthen_list:set_select_id( select_id )
	self.select_id = select_id --选中的装备id
	if select_id == nil then
		self.cur_wearing_type = 'weapon'
	else
		self.cur_wearing_type = data.item_id[select_id]
	end
	self:updata_button(self.cur_wearing_type)
end

function strengthen_list:updata_button( equip_type )
	--self:set_btns_unTouch()
	--默认显示武器按钮，首先设为普通
	--在设当前类型按钮显示选中
	if self.sel_btn ~= nil then
		self.sel_btn:setSelectedState(false)
		self.sel_btn:setTouchEnabled(true)
	end
	self.sel_btn = self[equip_type..'_button']
	self.sel_btn:setSelectedState(true)
	self.sel_btn:setTouchEnabled(false)
end

function strengthen_list:set_btns_unTouch(  )
	self.weapon_button:setSelectedState(false)
	self.weapon_button:setTouchEnabled(true)
	self.helmet_button:setSelectedState(false)
	self.helmet_button:setTouchEnabled(true)
	self.armor_button:setSelectedState(false)
	self.armor_button:setTouchEnabled(true)
	self.necklace_button:setSelectedState(false)
	self.necklace_button:setTouchEnabled(true)
	self.ring_button:setSelectedState(false)
	self.ring_button:setTouchEnabled(true)
	self.shoe_button:setSelectedState(false)
	self.shoe_button:setTouchEnabled(true)
end

function strengthen_list:getIntPart( x )
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

function strengthen_list:_update_list()
	self.list_equip:removeAllChildren()
	self.list_equip:jumpToTop()
	self.equip_keys = {}
	local player = model.get_player()
	local player_lv = player:get_level()
	local equips = player:get_equips()
	local act_equip = {} 		--已激活的武器
	--分开激活
	for id, it in pairs(data[self.cur_wearing_type]) do
	 	--人物等级达到需要的等级
	 	if player_lv >=  it.Lv  then
			if equips[tostring(id)] ~= nil then
				table.insert(act_equip, id) 	--插入激活
			end
		end

	end
	--按id排序
	local function cmp(a,b)
		return a < b
	end
	table.sort(act_equip, cmp)

	--把激活插入到总列表
	for _,v in ipairs(act_equip) do
		table.insert(self.equip_keys, v)
	end
	act_equip = nil
	self.cur_wearing_idx = player:get_wear(self.cur_wearing_type):get_id()
	--计算装备有多少行
	self.equip_row_coutn	= 4
	local list_count = #self.equip_keys
	local cell_count = list_count

	if cell_count <= 4 then
		cell_count =4	
	end
	
	local cur_count = cell_count

	self.start_count =4
	self.c_h= self.list_equip:getContentSize().height/self.start_count --每格之间距离
	self.cell_hight = 113

	local cur_count = 0
	--排列装备图标
	-- print('进入了',cell_count)
	-- dir(equips)
	local sum_pos
	if cell_count > 4 then
		sum_pos = 119*cell_count-self.cell_hight/2
	else
		sum_pos = self.list_equip:getContentSize().height-self.cell_hight/2
	end
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( eicon_set )
	self.layer:reload_json()
	for k, v in ipairs(self.equip_keys) do

		cur_count = cur_count+1
		if equips[tostring(v)] ~= nil then
			
			--已经激活
			local player_lv = player:get_level()
			local equip_data 	 = equips[tostring(v)]
			local equip_cell 	 = strengthen_cell.strengthen_cell(self.layer)
			local cell 			 = equip_cell:get_equip_cell()
			if cell_count > 4 then
				--cell:setPosition(215,119*cell_count-self.cell_hight*(cur_count-1)-self.cell_hight/2-6*(cur_count))
				local y = sum_pos-10
				cell:setPosition(215,y)
				sum_pos = sum_pos-self.cell_hight-5
			else
				--cell:setPosition(215,self.list_equip:getContentSize().height-self.cell_hight/2-10-self.cell_hight*(cur_count-1))
				local y = sum_pos-10
				cell:setPosition(215,y)
				sum_pos = sum_pos-self.cell_hight-5
			end
			equip_cell:set_cell_level( equip_data:get_color())
			equip_cell:set_equip_name( equip_data:get_name(),equip_data:get_level())
			equip_cell:set_cell_Image( equip_data:get_icon() )
			--equip_cell:set_equip_state(false)
			equip_cell:set_main_value(equip_data:get_prop_value())
			equip_cell:set_main_pro_img(equip_data:get_prop_key())
			equip_cell:set_activation_value(equip_data:get_activate_prop_value())
			equip_cell:set_activation_pro_img(equip_data:get_activate_prop_key())
			equip_cell:set_equip_data( equip_data )
			equip_cell:set_id(v)

			cell:setTag(cur_count)
			self.list_equip:addChild(cell)
			

			if self.select_id == nil and cur_count == 1 then
				self.select_id = v 
			end
			if v == self.select_id  then 
				self.sel_eq_cell = equip_cell
				equip_cell:set_selected_state(true)
				equip_cell:set_touch_enabled(false)
				self.layer:get_info_panel():show_cell_property( equip_cell:get_id(),self.goods_type )
			end

			--注册事件
			self:set_cell_handel(equip_cell)
		end

		--测试缓冲
		-- local equip_data 	 = data[self.cur_wearing_type][v]
		-- local equip_cell 	 = strengthen_cell.strengthen_cell(self.layer,false)
		-- local cell 			 = equip_cell:get_equip_cell()
		-- local pro_keys,pro_value = self:get_pro_key(equip_data)
		-- if cell_count > 4 then
		-- 	local y = sum_pos-10
		-- 	cell:setPosition(215,y)
		-- 	sum_pos = sum_pos-self.cell_hight-5
		-- else
		-- 	cell:setPosition(215,self.list_equip:getContentSize().height-self.cell_hight*(cur_count-1)-self.cell_hight/2-5*(cur_count-1))
		-- end
		-- equip_cell:set_equip_name( equip_data.name )
		-- equip_cell:set_cell_Image( equip_data.icon )
		-- --equip_cell:set_bar_img(equip_data.color)
		-- --equip_cell:set_equip_state(false)
		-- equip_cell:set_main_value(pro_value[1])
		-- equip_cell:set_main_pro_img(pro_keys[1])
		-- equip_cell:set_activation_value(pro_value[2])
		-- equip_cell:set_activation_pro_img(pro_keys[2])
		-- equip_cell:set_equip_data( equip_data )
		-- --equip_cell:set_frag_bat(player:get_one_equip_stone(equip_data.color..'_'..self.cur_wearing_type))
		-- cell:setTag(cur_count)
		-- self.list_equip:addChild(cell)

		--self:set_cell_handel(equip_cell)

	end
	--设置滑动层的宽高
	self.list_equip:setInnerContainerSize(cc.size(433,cell_count*119))
end

function strengthen_list:update_list(  )
	self:_update_list()
end

function strengthen_list:get_pro_key( equip_data )
	local pro_keys = {}
	local pro_value = {}
	if equip_data.attack ~= nil then
		table.insert(pro_keys, 'attack')
		table.insert(pro_value, equip_data.attack)
	elseif equip_data.defense ~= nil then
		table.insert(pro_keys, 'defense')
		table.insert(pro_value, equip_data.defense)
	elseif equip_data.max_hp ~= nil then
		table.insert(pro_keys, 'max_hp')
		table.insert(pro_value, equip_data.max_hp)
	elseif equip_data.crit_level ~= nil then
		table.insert(pro_keys, 'crit_level')
		table.insert(pro_value, equip_data.crit_level)
	else
		table.insert(pro_keys, 'attack')
		table.insert(pro_value, 0)
	end
	if equip_data.act_attack ~= nil then
		table.insert(pro_keys, 'attack')
		table.insert(pro_value, equip_data.act_attack )
	elseif equip_data.act_defense ~= nil then
		table.insert(pro_keys, 'defense')
		table.insert(pro_value, equip_data.act_defense )
	elseif equip_data.act_max_hp ~= nil then
		table.insert(pro_keys, 'max_hp')
		table.insert(pro_value, equip_data.act_max_hp )
	elseif equip_data.act_crit_level ~= nil then
		table.insert(pro_keys, 'crit_level')
		table.insert(pro_value, equip_data.act_crit_level )
	else
		table.insert(pro_keys, 'attack')
		table.insert(pro_value, 0 )
	end
	return pro_keys,pro_value
end

function strengthen_list:set_cell_handel( equip_cell )

	
	local function selected_event(sender, eventType)

		if eventType == ccui.CheckBoxEventType.selected then
			
			self.select_id = equip_cell:get_id()
			sender:setTouchEnabled(false)
			self.sel_eq_cell:set_selected_state(false)
			self.sel_eq_cell:set_touch_enabled(true)
			equip_cell:set_selected_state(true)
			equip_cell:set_touch_enabled(false)
			self.sel_eq_cell = equip_cell
			self.layer:get_info_panel():show_cell_property( equip_cell:get_id(),self.goods_type )
		elseif eventType == ccui.CheckBoxEventType.unselected then
			--sender:setTouchEnabled(true)	
		end
	end
	self.layer:set_widget_handler(equip_cell:get_box(), selected_event, equip_cell:get_id())

end

