
local char				= import( 'world.char' )
local entity			= import( 'world.entity' )
local char				= import( 'world.char' )
local model 			= import( 'model.interface' )
local music_mgr			= import( 'world.music_mgr' )
local combat_conf		= import( 'ui.equip_sys_layer.equip_ui_cont' )
local layer				= import( 'world.layer' )
local locale			= import( 'utils.locale' )
local equipment_cell	= import( 'ui.equip_sys_layer.equipment_cell' )
local navigation_bar	= import( 'ui.equip_sys_layer.navigation_bar' ) 
local equipment_info_panel = import( 'ui.equip_sys_layer.equipment_info_panel' )
local ui_mgr 				= import( 'ui.ui_mgr' )

equipment_list_panel = lua_class('equipment_list_panel')
local load_texture_type = TextureTypePLIST
local eicon_set = 'icon/e_icons.plist'

function equipment_list_panel:_init( layer )
	
	self.layer		= layer
	self.list_equip	= self.layer:get_widget('list_equip')
	self.list_cell	= self.layer:get_widget('list_cell')
	self.list_panel = self.layer:get_widget('Image_99')
	self.cur_wearing_type 	= 'weapon'
	self.equip_row_coutn	= 0
	self.equipped_number 	= 0
	--记录当前选中的格子
	self.sel_eq_cell 		= nil
	self.eqed_cell 			= nil


	self.barbg = self.layer:get_widget( 'barbg' )
	--self.barbg:setScale9Enabled(true)


	self.bar = self.layer:get_widget( 'bar' )
	self.bar:setScale9Enabled(true)
	self.bar:setVisible(false)

	self.navigation_bar = navigation_bar.navigation_bar(self.bar , self.barbg, self.list_equip)

	self.layer.lbl_panel_attack:setString(self:getIntPart(self.layer:get_model().final_attrs.attack))
end


--设置当前的着装类型
function equipment_list_panel:set_cur_wearing_type( w_type )
		self.cur_wearing_type = w_type
end

function equipment_list_panel:get_cur_wearing_type( )

	return self.cur_wearing_type

end

--设置右边框标题
function equipment_list_panel:set_equip_title( role_lbl_equip_name )

	--self.layer.lbl_equip_title:setString(role_lbl_equip_name)
	self.layer:get_lbl_with_name('lbl_equip_title'):setString(role_lbl_equip_name)

end

function equipment_list_panel:table_count( ht )
	local n = 0
	local player = model.get_player()
	local player_lv = player:get_level()
	for _,v in pairs(ht) do
		if v.Lv >= player_lv then
			n = n + 1
		end
	end
	return n
end


function equipment_list_panel:update_equip_list( )

	--删除列表中的装备格子
	--跳动顶端。
	self.layer:reload_json()
	self.list_equip:jumpToTop()
	self.list_equip:removeAllChildren()

	self.equip_keys = {}
	local player = model.get_player()
	self.cur_wearing_idx = player:get_wear(self.cur_wearing_type):get_id()
	local player_lv = player:get_level()
	local equips = player:get_equips()
	local act_equip = {} 		--已激活的武器
	local unact_equip = {}		--还没激活的武器
	--分开激活和未激活
	for id, it in pairs(data[self.cur_wearing_type]) do
	 	--人物等级达到需要的等级
	 	if player_lv >=  it.Lv  then
	 		
			if equips[tostring(id)] ~= nil and id ~= self.cur_wearing_idx then
				
				table.insert(act_equip, id) 	--插入激活
			end
			if equips[tostring(id)] == nil and id ~= self.cur_wearing_idx then
				table.insert(unact_equip, id) 	--插入未激活
			end
		end

	end

	--按id排序
	local function cmp(a,b)
		return equips[tostring(a)]:get_level() > equips[tostring(b)]:get_level()
	end
	table.sort(act_equip, cmp)

	local function cmp(a,b)
		return a < b
	end
	
	table.sort(unact_equip, cmp)
	--把激活插入到总列表
	table.insert(self.equip_keys, self.cur_wearing_idx)
	for _,v in ipairs(act_equip) do
	 	
		table.insert(self.equip_keys, v)
	end
	--把未激活插入到总列表
	for _,v in ipairs(unact_equip) do
	 	--人物等级达到需要的等级
		table.insert(self.equip_keys, v)
	end
	act_equip = nil
	unact_equip = nil

	
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
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( eicon_set )
	for k, v in ipairs(self.equip_keys) do

		cur_count = cur_count+1
		if equips[tostring(v)] ~= nil then
			
			--已经激活
			local player_lv = player:get_level()
			local equip_data 	 = equips[tostring(v)]
			local equip_cell 	 = equipment_cell.equipment_cell(self.layer,true)
			local cell 			 = equip_cell:get_equip_cell()

			if cell_count > 4 then
				cell:setPosition(215,118*cell_count-self.cell_hight*(cur_count-1)-self.cell_hight/2-5*(cur_count-1))
			else
				cell:setPosition(215,self.list_equip:getContentSize().height-self.cell_hight*(cur_count-1)-self.cell_hight/2-5*(cur_count-1))
			end
			equip_cell:set_equip_name( equip_data:get_name() ,equip_data:get_level(),equip_data:get_color())
			equip_cell:set_cell_Image( equip_data:get_icon() )
			equip_cell:set_equip_state(false)
			equip_cell:set_main_value(equip_data:get_prop_value())
			equip_cell:set_main_pro_img(equip_data:get_prop_key())
			equip_cell:set_activation_value(equip_data:get_activate_prop_value())
			equip_cell:set_activation_pro_img(equip_data:get_activate_prop_key())
			equip_cell:set_equip_data( equip_data )

			cell:setTag(cur_count)
			self.list_equip:addChild(cell)
			equip_cell:set_cell_level( equip_data:get_color() )

			if v == self.cur_wearing_idx then 
				equip_cell:set_equip_state(true)
			end

			--注册事件
			self:set_cell_handel(equip_cell)
		else
			local equip_data 	 = data[self.cur_wearing_type][v]
			local equip_cell 	 = equipment_cell.equipment_cell(self.layer,false)
			local cell 			 = equip_cell:get_equip_cell()
			local pro_keys,pro_value = self:get_pro_key(equip_data)
			if cell_count > 4 then
				cell:setPosition(215,118*cell_count-self.cell_hight*(cur_count-1)-self.cell_hight/2-5*(cur_count-1))
			else
				cell:setPosition(215,self.list_equip:getContentSize().height-self.cell_hight*(cur_count-1)-self.cell_hight/2-5*(cur_count-1))
			end
			equip_cell:set_equip_name( equip_data.name )
			equip_cell:set_cell_Image( equip_data.icon )
			equip_cell:set_bar_img(equip_data.color,self.cur_wearing_type)
			equip_cell:set_equip_state(false)
			equip_cell:set_main_value(pro_value[1])
			equip_cell:set_main_pro_img(pro_keys[1])
			equip_cell:set_activation_value(pro_value[2])
			equip_cell:set_activation_pro_img(pro_keys[2])
			equip_cell:set_equip_data( equip_data )
			equip_cell:set_frag_bat(player:get_one_equip_frag(equip_data.color..'_'..self.cur_wearing_type),self.cur_wearing_type)
			cell:setTag(cur_count)
			self.list_equip:addChild(cell)

			self:set_cell_handel(equip_cell)

		end


	end
	--设置滑动层的宽高
	self.list_equip:setInnerContainerSize(cc.size(460,cell_count*118))
	--self.items_list:setInnerContainerSize(cc.size(self.items_list:getContentSize().width,self.task_count*self.c_h))
	-----导航条思路做法------------
	self.navigation_bar:init_bar(4,cur_count,self.list_equip:getContentSize().height)

	----------------------------------
	self.bar:setVisible(true)
	
end

function equipment_list_panel:get_pro_key( equip_data )
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

function equipment_list_panel:getIntPart( x )
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


--设置框框按钮事件
function equipment_list_panel:set_cell_handel( cell )


	local function button_event( sender,eventtype )
		if eventtype == ccui.TouchEventType.began then
			
		elseif eventtype == ccui.TouchEventType.moved then
		  
		elseif eventtype == ccui.TouchEventType.ended then
			cc.SpriteFrameCache: getInstance(): addSpriteFrames( eicon_set )
			if cell:get_is_call() == true then
				if ui_mgr.get_ui('equipment_info_panel') ~= nil then
					return
				end
				local ui_info = ui_mgr.create_ui(import('ui.equip_sys_layer.equipment_info_panel'), 'equipment_info_panel')
				ui_info:show_strength_panel(false)
				local player = model.get_player()
				local equips = player:get_equips()
				local id  = cell:get_equip_data():get_id()
				local equip_data = equips[tostring(id)]
				
				ui_info:set_id(id)
				ui_info:set_head_img(equip_data:get_icon())
				ui_info:set_equip_name(equip_data:get_name(),equip_data:get_level(),equip_data:get_color())
				ui_info:set_cell_color( equip_data:get_color() )
				ui_info:set_main_value(equip_data:get_prop_value())
				ui_info:set_main_pro_img(equip_data:get_prop_key())
				ui_info:set_main_name(equip_data:get_prop_key())
				ui_info:set_activation_value(equip_data:get_activate_prop_value())
				ui_info:set_activation_pro_img(equip_data:get_activate_prop_key())
				ui_info:set_activation_name(equip_data:get_activate_prop_key())
				--ui_info:set_stone_requirement(equip_data:get_stone_requirement())
				--ui_info:set_frag_bat(player:get_one_equip_frag(equip_data:get_color()..'_'..self.cur_wearing_type))
				ui_info:play_up_anim()
				ui_info:set_main_state(cell:get_equip_state())

			else
			
				if ui_mgr.get_ui('equipment_info_panel') ~= nil then
					return
				end
				local ui_info = ui_mgr.create_ui(import('ui.equip_sys_layer.equipment_info_panel'), 'equipment_info_panel')
				ui_info:show_strength_panel(true)
				local id  = cell:get_equip_data().id 
				local player = model.get_player()
				local equip_data  = data[self.cur_wearing_type][id]
				local pro_keys,pro_value = self:get_pro_key(equip_data)
				ui_info:set_id(id)
				ui_info:set_head_img(equip_data.icon)
				ui_info:set_cell_color( equip_data.color )
				ui_info:set_bar_img( equip_data.color,self.cur_wearing_type )
				ui_info:set_equip_name(equip_data.name,0,equip_data.color)
				ui_info:set_main_value(pro_value[1])
				ui_info:set_main_pro_img(pro_keys[1])
				ui_info:set_main_name(pro_keys[1])
				ui_info:set_activation_value(pro_value[2])
				ui_info:set_activation_pro_img(pro_keys[2])
				ui_info:set_activation_name(pro_keys[2])
				ui_info:set_stone_requirement(data.equipment_activation[equip_data.color..'_'..self.cur_wearing_type])
				ui_info:set_frag_bat(player:get_one_equip_frag(equip_data.color..'_'..self.cur_wearing_type))

				ui_info:play_up_anim()
				ui_info:set_id(cell:get_equip_data().id)
				ui_info:set_activation_state(false)
				ui_info:set_main_state(cell:get_equip_state())

				-- show
				-- self.sel_id = cell:get_equip_data().id
			end
		elseif eventtype == ccui.TouchEventType.canceled then
				
		end
	end
	self.layer:set_widget_handler( cell:get_button(), button_event, cell:get_is_call() )

end


--设置装备属性的图标
function equipment_list_panel:set_pro_icon( img_name,pro_name )

	self.layer:get_widget(img_name):loadTexture(pro_name..'.png',TextureTypePLIST)
	self.layer:get_widget(img_name):setVisible(true)

end

-- function equipment_list_panel:set_activation_info(  )

-- 	local ui_info = ui_mgr.get_ui('equipment_info_panel')
-- 	ui_info:set_activation_state(true)
-- 	ui_info:show_strength_panel(false)

-- end

function equipment_list_panel:change_equip( idx )
	model.get_player() :change_equip( idx )
end

function equipment_list_panel:reload_ui(  )
	print('update changed')
	local player = model.get_player()
	self.layer:get_player_info_panel():get_player():change_equip(self.layer:get_player_info_panel():get_player().equip_conf[self.cur_wearing_type], player:get_wear(self.cur_wearing_type))
end
