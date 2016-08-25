local combat_conf		= import( 'ui.bag_system_layer.bag_ui_conf' )
local layer				= import( 'world.layer' )
local model 			= import( 'model.interface' )
local locale			= import( 'utils.locale' )
local bag_info_panel	= import( 'ui.bag_system_layer.bag_info_panel' )
local bag_cell			= import( 'ui.bag_system_layer.bag_cell' )
local music_mgr			= import( 'world.music_mgr' )
local math_ext 			= import( 'utils.math_ext' ) 
local navigation_bar	= import( 'ui.equip_sys_layer.navigation_bar' )
local ui_mgr			= import( 'ui.ui_mgr' )

bag_list_panel = lua_class('bag_list_panel')
local load_texture_type = TextureTypePLIST
local iicons = 'icon/item_icons.plist'
local eicon_set = 'icon/e_icons.plist'
local soul_set = 'icon/soul_icons.plist'
local _jsonfile = 'gui/main/ui_bag.ExportJson'

function bag_list_panel:_init( layer )
	self.layer = layer
	self.list_bag		= self.layer:get_widget('list_bag')
	self.equip_button 	= self.layer:get_widget('equip_button')
	self.gem_button 	= self.layer:get_widget('gem_button')
	self.prop_button 	= self.layer:get_widget('prop_button')
	--self:init_goods_data()
	self.bag_row_count = 5 
	self.cur_sel_idx = 1
	self.goods_type = EnumGoods.equip_stone
	self:division_bag_title(self.goods_type)
	self.equip_button:setTouchEnabled(false)
	self.equip_button:setSelectedState(true)
	self.gem_button:setTouchEnabled(true)
	self.gem_button:setSelectedState(false)
	self.prop_button:setTouchEnabled(true)
	self.prop_button:setSelectedState(false)
	--self.layer:get_bag_info_panel():set_msg_button_state(false)

	--导航条 底图，
	self.barbg = self.layer:get_widget( 'barbg' )
	--self.barbg:setScale9Enabled(true)
	self.bar = self.layer:get_widget( 'bar' )
	self.bar:setScale9Enabled(true)
	self.navigation_bar = navigation_bar.navigation_bar(self.bar , self.barbg, self.list_bag)
	------------------
	self.sel_btn = nil
	--self:update_equip_list(1)
	ui_mgr.schedule_once(0, self, self.update_equip_list, 1)



	local function equip_button_event(_, sender, eventType)
		if eventType == ccui.CheckBoxEventType.selected then
			music_mgr.ui_click()
			self.cur_sel_idx = 1
			sender:setTouchEnabled(false)
			sender:setSelectedState(true)
			self.gem_button:setTouchEnabled(false)
			self.gem_button:setSelectedState(false)
			self.prop_button:setTouchEnabled(false)
			self.prop_button:setSelectedState(false)
			self.goods_type = EnumGoods.equip_stone
			self:division_bag_title(self.goods_type)
			self:update_equip_list(1)
			self.gem_button:setTouchEnabled(true)
			self.prop_button:setTouchEnabled(true)
		elseif eventType == ccui.CheckBoxEventType.unselected then
			sender:setTouchEnabled(true)	
		end
	end

	local function gem_button_event(_, sender, eventType)
		if eventType == ccui.CheckBoxEventType.selected then
			music_mgr.ui_click()
			self.cur_sel_idx = 1
			sender:setTouchEnabled(false)
			sender:setSelectedState(true)
			self.equip_button:setTouchEnabled(false)
			self.equip_button:setSelectedState(false)
			self.prop_button:setTouchEnabled(false)
			self.prop_button:setSelectedState(false)
			self.goods_type = EnumGoods.soul_frag
			self:division_bag_title(self.goods_type)
			self:update_equip_list(1)
			self.equip_button:setTouchEnabled(true)
			self.prop_button:setTouchEnabled(true)
		elseif eventType == ccui.CheckBoxEventType.unselected then
			sender:setTouchEnabled(true)	
		end
	end

	local function prop_button_event(_, sender, eventType)
		if eventType == ccui.CheckBoxEventType.selected then
			music_mgr.ui_click()
			self.cur_sel_idx = 1
			sender:setTouchEnabled(false)
			sender:setSelectedState(true)
			self.equip_button:setTouchEnabled(false)
			self.equip_button:setSelectedState(false)
			self.gem_button:setTouchEnabled(false)
			self.gem_button:setSelectedState(false)
			self.goods_type = EnumGoods.item
			self:division_bag_title(self.goods_type)
			self:update_equip_list(1)
			self.equip_button:setTouchEnabled(true)
			self.gem_button:setTouchEnabled(true)
		elseif eventType == ccui.CheckBoxEventType.unselected then
			sender:setTouchEnabled(true)	
		end
	end

	self.layer:set_handler("equip_button", equip_button_event)
	self.layer:set_handler("gem_button", gem_button_event)
	self.layer:set_handler("prop_button", prop_button_event)

	--self.layer:get_widget('Image_199'):setVisible(false)
end

--物品数据
function bag_list_panel:init_goods_data(  )
	--武器数据
	self.weapon_data = self.layer:get_model().items.weapon
	self.helmet_data = self.layer:get_model().items.helmet
	self.armor_data	= self.layer:get_model().items.armor
	self.necklace_data = self.layer:get_model().items.necklace
	self.ring_data =self.layer:get_model().items.ring
	self.shoe_data = self.layer:get_model().items.shoe

	--宝石数据
	self.helmet_data2 = self:copyTab(self.layer:get_model().items.helmet)
	self.armor_data2	= self:copyTab(self.layer:get_model().items.armor)
	self.necklace_data2 = self:copyTab(self.layer:get_model().items.necklace)
	self.ring_data2 = self:copyTab(self.layer:get_model().items.ring)
	self.shoe_data2 = self:copyTab(self.layer:get_model().items.shoe)

	--道具数据
	self.necklace_data3 = self:copyTab(self.layer:get_model().items.necklace)
	self.ring_data3 = self:copyTab(self.layer:get_model().items.ring)
	self.shoe_data3 = self:copyTab(self.layer:get_model().items.shoe)
end


--更新标题
function bag_list_panel:division_bag_title( equip_type )
	--更新右栏的文字显示
	if equip_type == EnumGoods.equip_stone then
		self:set_bag_title(locale.get_value('bag_lbl_equip'))
	elseif equip_type == EnumGoods.soul_frag then
		self:set_bag_title(locale.get_value('bag_lbl_gem'))
	elseif equip_type == EnumGoods.item then
		self:set_bag_title(locale.get_value('bag_lbl_prop'))
	end
end
--设置右边框标题
function bag_list_panel:set_bag_title( role_lbl_equip_name )

	self.layer.lbl_bag_title:setString(role_lbl_equip_name)

end


function bag_list_panel:copyTab(st)
	local tab = {}
	for k, v in pairs(st or {}) do
		if type(v) ~= "table" then
			tab[k] = v
		else
			tab[k] = self:copyTab(v)
		end
	end
	return tab
end

function bag_list_panel:table_count( ht )
	local n = 0
	for _,v in pairs(ht) do
		n = n + 1
	end
	return n
end

function bag_list_panel:update_equip_list(  index  )
	-- body
	--self:init_goods_data()
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( eicon_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( iicons )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( soul_set )
	ccs.GUIReader:getInstance():widgetFromJsonFile(_jsonfile)
	self.list_bag:removeAllChildren()
	self.list_bag:jumpToTop()
	self.show_goods= nil
	self.show_goods = {}
	self.goods_data = {}
	local player = model.get_player()
	local equip_frags = player:get_equip_frags()
	local equip_qh_stones = player:get_equip_qh_stones()
	local soul_frags = player:get_soul_frag()
	local  items = player:get_items()
	if self.goods_type == EnumGoods.equip_stone then
		local player = model.get_player()
		for id, it in pairs(data.equip_frag) do
			local name = it.color
			local position = it.position
			if equip_frags[name..'_'..position] ~= nil and equip_frags[name..'_'..position] > 0 then
				table.insert(self.goods_data, id)
			end
		end
		for id, it in pairs(data.equip_qh_stone) do
			local name = it.color
			if equip_qh_stones[name] ~= nil and equip_qh_stones[name] > 0 then
				table.insert(self.goods_data, id)
			end
		end
		self.layer:get_bag_info_panel():set_msg_button_state(false)
	elseif self.goods_type == EnumGoods.soul_frag then 
		
		for id, it in pairs(data.soul_stone) do

			local soul_id = tostring(it.soul_id)

			if soul_frags[soul_id] ~= nil and  soul_frags[soul_id] > 0 then
				table.insert(self.goods_data, id)
			end
		end
		self.layer:get_bag_info_panel():set_msg_button_state(false)
	elseif self.goods_type == EnumGoods.item then
		for id, it in pairs(items) do
			table.insert(self.goods_data, tonumber(it.id))
		end
		self.layer:get_bag_info_panel():set_msg_button_state(true)
	else
		self.goods_data = {}
	end

	--默认显示并选中第一个物品的信息
	--self.cur_sel_idx = 1
	local list_count=#self.goods_data
	--默认高度为5行
	self.bag_row_count=5
	local l_count = self:getIntPart(list_count/4)
	local ls_count = list_count/4
	local compare_count = 0
	if ls_count>l_count then
		if self.bag_row_count <= ls_count then
			self.bag_row_count = self:getIntPart(ls_count+1) 
		end
	else
		if self.bag_row_count <= self:getIntPart(list_count/4) then
			self.bag_row_count = self:getIntPart(list_count/4)
		end
	end
	--计算有多少格子
	local count = 0

	--当最后一个被卖掉就选回第一个
	if self.cur_sel_idx > list_count then
		self.cur_sel_idx = 1
	end
	
	if self:table_count(self.goods_data) == 0 or list_count==0 then
		self.layer:get_bag_info_panel( ):set_info_panel_visible(false)
		return
	else
		self.layer:get_bag_info_panel( ):set_info_panel_visible(true)
	end

	local height = 0
	
	for index,oid in pairs(self.goods_data) do
		local item_id = data.item_id
		local item_data = data[item_id[oid]]
		local it = item_data[oid]
			if it ~= nil then
				local bag_data = it
				--local bag_data = data[i].data
				count = count + 1
				local bag_cells = bag_cell.bag_cell(self.layer)
				local cell = bag_cells:get_cell()
				bag_cells:set_cell_Image( bag_data.icon, load_texture_type)
				bag_cells:set_cell_number(count)
				bag_cells:set_item_id(oid)
				cell:setTag(count)
				bag_cells:set_data(it)
				bag_cells:set_goods_type(self.cur_wearing_type)		--设置这个格子是什么类型的物品，装备？宝石？道具
				--设置边框颜色
				bag_cells:set_cell_level('White')

				--cell:getChildByName('make_tick'):setVisible(false)
				bag_cells:set_cell_level(bag_data.color )
		
				-- 	---借用等级来测试叠加
				if item_id[oid] == 'equip_frag' then
					bag_cells:set_goods_quantity(equip_frags[bag_data.color..'_'..bag_data.position])
					
				elseif item_id[oid] == 'equip_qh_stone' then
					bag_cells:set_goods_quantity(equip_qh_stones[bag_data.color])
				
				elseif item_id[oid] == 'soul_stone' then
					bag_cells:set_goods_quantity(soul_frags[tostring(bag_data.soul_id)])
		
				else
					bag_cells:set_goods_quantity(player:get_item_number_by_id(bag_data.id))
		
				end

				
				if ls_count > 4 then
					height = 95
				else
					height = 92
				end
				
				if count%4 == 1 then
				
					cell:setPosition(60,self.bag_row_count*height-self:getIntPart(count/4)*95-48)
				elseif count%4 == 2 then
					cell:setPosition(160,self.bag_row_count*height-self:getIntPart(count/4)*95-48)
				elseif count%4 == 3 then
					cell:setPosition(260,self.bag_row_count*height-self:getIntPart(count/4)*95-48)
				elseif count%4 == 0 then
					cell:setPosition(360,self.bag_row_count*height-(self:getIntPart(count/4)-1)*95-48)
				end
				
				self.list_bag:addChild(cell)
				table.insert(self.show_goods, bag_cells)
				--注册事件
				
				--默认选中第一件
				if count == self.cur_sel_idx then 
					
					bag_cells:set_selected_state( true )
					bag_cells:set_touch_enabled( false )
					self.sel_btn = bag_cells
					self.layer:get_bag_info_panel():set_item_id(oid)
					self.layer:get_bag_info_panel():show_prop_property( bag_data,self.goods_type )
					

				end
				self:check_show_table(bag_cells)
			end
		--end
	end
	self.list_bag:setInnerContainerSize(cc.size(500,self.bag_row_count*height))


	-----导航条思路做法------------
	--ui；预留头尾位置
	self.navigation_bar:init_bar(16,count,460)

	----------------------------------


end

function bag_list_panel:getIntPart( x )
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


--点击事件
function bag_list_panel:check_show_table( v )

		local function selected_event(sender, eventType)
			
			if eventType == ccui.CheckBoxEventType.selected then
				sender:setTouchEnabled(false)
				self.sel_btn:set_selected_state(false)
				self.sel_btn:set_touch_enabled(true)
				v:set_selected_state(true)
				v:set_touch_enabled(false)
				self.sel_btn = v
				self.cur_sel_idx = v:get_cell_number()
			elseif eventType == ccui.CheckBoxEventType.unselected then
				sender:setTouchEnabled(true)	
			end
			--显示这个物品的属性
			self.layer:get_bag_info_panel():set_item_id(v:get_item_id())
			self.layer:get_bag_info_panel():show_prop_property( v:get_data(),self.goods_type )

			music_mgr.ui_click()

		end

		v:get_cell():addEventListener(selected_event)
end





