local layer 				= import('world.layer')
local combat_conf			= import( 'ui.shop_layer.shop_ui_conf' )
local ui_const 				= import( 'ui.ui_const' )
local locale				= import( 'utils.locale' )
local shop_cell				= import( 'ui.shop_layer.shop_cell' )
local model 				= import( 'model.interface' )
local anim_trigger 			= import( 'ui.main_ui.anim_trigger')
local navigation_bar		= import( 'ui.equip_sys_layer.navigation_bar' ) 
local item_info 			= import( 'ui.shop_layer.item_info' )
local ui_mgr 				= import( 'ui.ui_mgr' )
local locale				= import( 'utils.locale' )
local shop_npc 				= import( 'ui.shop_layer.shop_npc' )
local ui_guide				= import( 'world.ui_guide' )

shop_layer 					= lua_class( 'shop_layer' , layer.ui_layer )
local load_texture_type 	= TextureTypePLIST
local iicon_set 			= 'icon/item_icons.plist'
local eicon_set 			= 'icon/e_icons.plist'
local soul_set 				= 'icon/soul_icons.plist'
local _json_path			= 'gui/main/shop_1.ExportJson'

function shop_layer:_init(  )
	
	
	super(shop_layer,self)._init(_json_path,true)
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2,VisibleSize.height/2)
	self.is_remove 		= false
	self.items_list 	= self:get_widget('item_list')
	self.lbl_money 		= self:get_widget('lbl_money')
	self.lbl_diamond 	= self:get_widget('lbl_diamond')


	self.bar = self:get_widget('bar')
	self.barbg = self:get_widget('barbg')
	self.bar:setScale9Enabled(true)
	self.items_list:setEnabled(false)
	
	self:set_handler('refresh_button',self.refresh_button_event)
	self:set_handler('close_button',self.close_button_event)
	self:init_lbl_font()
	self:add_npc()
	self:play_anim( )
	self:reload()

	ui_guide.trigger( 'enter_shop_layer' )
end

function shop_layer:add_npc(  )
	self.npc = shop_npc.shop_npc()
	self.npc_img = self:get_widget('Image_10')
	local posx,posy = self.npc_img:getPosition()
	self:get_widget('Panel_7'):addChild(self.npc.cc,1)
	self.npc:play_anim(posx,posy)
end

--对文字的描边
function shop_layer:init_lbl_font(  )
	for name, val in pairs(combat_conf.shop_ui_label) do
		self['lbl_' .. name] = self:get_widget('lbl_' .. name)
		local temp_label = self['lbl_' .. name]
		if temp_label ~= nil then
			--temp_label:setFontName(ui_const.UiLableFontType)
			if locale.get_value('shop_' .. name) ~= ' ' then
				temp_label:setString(locale.get_value('shop_' .. name))		--如果传入的name在languane是没有的，就会返回以个空字符串
			end
			if val.edge ~= nil and val.edge > 0 then 					--edge的值大于0就描边
				temp_label:enableOutline(ui_const.UilableStroke, val.edge)  ---，描边，厚度 role_ui_conf.lua中role_ui_label的edge
			end
		end
	end
end

--计算物品多少
function shop_layer:cal_table_length( t )
	local i = 0
	for k,v in pairs(t) do
		i = i+1
	end
	return i
end

--加入物品框
function shop_layer:add_items(  )
	self:reload_json()
	local player = model.get_player()
	local items = player:get_shop1()

	self.items_list:jumpToTop()
	self.items_list:removeAllChildren()
	self.navigation_bar = navigation_bar.navigation_bar(self.bar,self.barbg, self.items_list)
	self.task_count = self:cal_table_length(items)
	
	if self.task_count <= 4 then
		self.task_count =4
		
	end
	
	local cur_count = self.task_count

	self.start_count =4
	self.c_h= self.items_list:getContentSize().height/self.start_count --每格之间距离
	self.cell_hight = 107


	local keys = {}
	for k , v in pairs(items) do
		table.insert(keys, k)
	end
	local function cmp(a,b)
		return a < b
	end
	table.sort(keys, cmp)
	local cnt = 0
	local k = 1
	for i=1,cur_count do
		if keys[i] ~= nil then
			local index = keys[i]
			self:create_task_cell( index,items,i )
		end
	end
	
	
	self.items_list:setInnerContainerSize(cc.size(self.items_list:getContentSize().width,self.task_count*self.c_h))
	self.navigation_bar:init_bar(self.start_count,self.task_count,self.items_list:getContentSize().height)

end

--创建格子
function shop_layer:create_task_cell( index ,item_data,pos_index)
		cc.SpriteFrameCache:getInstance():addSpriteFrames( iicon_set )
		cc.SpriteFrameCache:getInstance():addSpriteFrames( eicon_set )
		cc.SpriteFrameCache:getInstance():addSpriteFrames( soul_set )
		local btn = shop_cell.shop_cell(self)
		self.items_list:addChild(btn:get_cell())
		btn:get_cell():setTag(pos_index)
		btn:get_cell():setPosition(165,self.c_h*self.task_count-self.cell_hight*(pos_index-1)-self.cell_hight/2-10*(pos_index-1))
		
		btn:set_img(item_data[index]:get_data().icon)
		
		btn:set_cell_level(item_data[index]:get_data().color)
		btn:set_name(item_data[index]:get_data().name)
		btn:set_price(item_data[index])
		btn:set_number(item_data[index])
		self:set_cell_handel(btn,item_data[index],index)

end


--设置钱
function shop_layer:set_money(m)
	if m == nil then
		m = 0
	end

	self.lbl_money:setString('' .. m)
end

--设置砖石
function shop_layer:set_diamond(d)
	if d == nil then
		d = 0
	end
	self.lbl_diamond:setString(''..d)
end

--更新钱，砖石
function shop_layer:update_money_diamond(  )
	local player = model.get_player()
	
	if player['money'] ~= nil then
		self.lbl_money:setString(player['money']) 
	end
	if player['diamond'] ~= nil then
		self.lbl_diamond:setString(player['diamond']) 
	end
end

--设置框框按钮事件
function shop_layer:set_cell_handel( cell,item_data,oid )


	local function button_event( sender,eventtype )
		if eventtype == ccui.TouchEventType.began then
			
		elseif eventtype == ccui.TouchEventType.moved then
		  
		elseif eventtype == ccui.TouchEventType.ended then
			cc.SpriteFrameCache:getInstance():addSpriteFrames( eicon_set )
			cc.SpriteFrameCache:getInstance():addSpriteFrames( iicon_set )
			cc.SpriteFrameCache:getInstance():addSpriteFrames( soul_set )
			local player = model.get_player()
			local items = player:get_shop1()
			local item_info = ui_mgr.create_ui(import( 'ui.shop_layer.item_info' ), 'item_info')
			item_info:play_up_anim()
			item_info:set_oid(oid)
			item_info:set_item_data(item_data)
			item_info:set_tips(items[oid]:get_data().tips)
			item_info:set_price(items[oid])
			item_info:reload()
		elseif eventtype == ccui.TouchEventType.canceled then
				
		end
	end
	cell:get_cell():addTouchEventListener(button_event)

end

--关闭按钮
function shop_layer:close_button_event( sender,eventtype )

	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  
	elseif eventtype == ccui.TouchEventType.ended then
		self.cc:setVisible(false)

		anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_UP_ANIM,false)
		self.is_remove = true
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end

--刷新按钮
function shop_layer:refresh_button_event( sender,eventtype )

	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  
	elseif eventtype == ccui.TouchEventType.ended then

		server.refresh_shop1()
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end

--播放弹出动画
function shop_layer:play_anim( )
	local function callFunc(  )
		self:get_widget('Image_41'):setVisible(true)
		self:play_action('shop_1.ExportJson','p')
		self.navigation_bar:init_bar(self.start_count,self.task_count,470)
		self.items_list:setEnabled(true)
	end
	local callFuncObj=cc.CallFunc:create(callFunc)
	self:get_widget('Image_41'):setVisible(false)
	self.items_list:setEnabled(false)
	self:play_action('shop_1.ExportJson','down',callFuncObj)
end


--更新
function shop_layer:reload(  )
	super(shop_layer,self).reload()
	self:update_money_diamond()
	self:add_items()
end

function shop_layer:reload_lbl(  )
	super(shop_layer,self).reload()
	self:update_money_diamond()
end
--释放
function shop_layer:release(  )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( iicon_set )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( eicon_set )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( soul_set )
	--ccs.ActionManagerEx:getInstance():releaseActionsByJsonName('shop_1.ExportJson')
	self.npc:release()
	super(shop_layer,self).release()
end

