
local layer 				= import('world.layer')
local combat_conf			= import( 'ui.shop_layer.shop_ui_conf' )
local ui_const 				= import( 'ui.ui_const' )
local locale				= import( 'utils.locale' )
local model 				= import( 'model.interface' )

item_info = lua_class('item_info',layer.ui_layer)
local load_texture_type = TextureTypePLIST

function item_info:_init(  )
	super(item_info,self)._init('gui/main/shop_2.ExportJson',true)

	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2,VisibleSize.height/2)
	self.iten_img = self:get_widget('item_img')
	self.lbl_panel_equip_name = self:get_widget('lbl_panel_equip_name')
	self.lbl_tips = self:get_widget('lbl_tips')
	self.lbl_tips:setVisible(false)
	self.price_img = self:get_widget('price_img')


	self.buy_button = self:get_widget('buy_button')
	self:set_handler('buy_button',self.buy_button_event)

	self.is_remove 		= false
	self:set_handler('close_button',self.close_button_event)

	self:init_lbl_font()
end



function item_info:init_lbl_font(  )
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



--设置数据
function item_info:set_item_data( data )
	self.item_data = data
end

--设置物体头像
function item_info:set_item_img( file )
	self.iten_img:loadTexture( file ,load_texture_type)
end


--设置格子oid
function item_info:set_oid( number )
	self.oid = number
end

function item_info:set_tips( tips )
	
	local player = model.get_player()
	local items = player:get_shop1()
	local iteam_type = items[self.oid]:is_equip()
	if iteam_type == false then
		
		self:hide_cell_property()
		self.lbl_tips:setVisible(true)
		if tips==nil then
			tips = ''
		end
		self.lbl_tips:setString(tips)
	end
end




function item_info:set_price( server_data )
	
	local price = 0
	if server_data:get_gold() ~= nil then
		price = server_data:get_gold()
		self:set_price_img( 'gold' )
	else
		price = server_data:get_diamond()
		self:set_price_img( 'diamond' )
	end
	self.lbl_item_price:setString(''..price)
end

function item_info:set_price_img( file )
	self.price_img:loadTexture( 'shop_big_'..file ..'.png' ,load_texture_type)
end
--设置等级
function item_info:set_cell_level( level )
	if level == EnumLevel.White then
		self:get_widget('green'):setVisible(false)
		self:get_widget('blue'):setVisible(false)
		self:get_widget('purple'):setVisible(false)
		self:get_widget('orange'):setVisible(false)
		self.lbl_panel_equip_name:setColor(Color.White)
	elseif level == EnumLevel.Green then
		self:get_widget('green'):setVisible(true)
		self:get_widget('blue'):setVisible(false)
		self:get_widget('purple'):setVisible(false)
		self:get_widget('orange'):setVisible(false)
		self.lbl_panel_equip_name:setColor(Color.Green)
	elseif level == EnumLevel.Blue then
		self:get_widget('green'):setVisible(false)
		self:get_widget('blue'):setVisible(true)
		self:get_widget('purple'):setVisible(false)
		self:get_widget('orange'):setVisible(false)
		self.lbl_panel_equip_name:setColor(Color.Blue)
	elseif level == EnumLevel.Purple then
		self:get_widget('green'):setVisible(false)
		self:get_widget('blue'):setVisible(false)
		self:get_widget('purple'):setVisible(true)
		self:get_widget('orange'):setVisible(false)
		self.lbl_panel_equip_name:setColor(Color.Purple)
	elseif level == EnumLevel.Orange then
		self:get_widget('green'):setVisible(false)
		self:get_widget('blue'):setVisible(false)
		self:get_widget('purple'):setVisible(false)
		self:get_widget('orange'):setVisible(true)
		self.lbl_panel_equip_name:setColor(Color.Orange)
	else
		print('没有这个等级')
	end
end


function item_info:show_property(  )
	local player = model.get_player()
	local it = self.item_data
	if it:is_equip() == false then
		return
	end


	local equip_info_to_return = {}
	equip_info_to_return.name = it:get_data().name
	equip_info_to_return.level = it:get_level()
	equip_info_to_return.main_growth = it:get_main_prop_growth()
	equip_info_to_return.data = it:get_data()
	equip_info_to_return.prop = {}

	local main_name = locale.get_value('role_'..it:get_main_prop_key())
	local main_value = it:get_main_prop_value()
	local main_data= {['name'] = main_name,['value'] = main_value}
	table.insert(equip_info_to_return.prop, main_data )
	for i =1, 4 do
		local k = it:get_prop_key(i)
		if k ~= nil then
			local name = locale.get_value('role_'..k)
			local value = it:get_prop_value(i)
			local prop_key = k
			local pro_data= {['name'] = name,['value'] = value,['prop_key']=prop_key}
			table.insert(equip_info_to_return.prop,pro_data)
		end
	end

	self:update_equip_info( equip_info_to_return  )

end


function item_info:hide_cell_property(  )
	self:get_widget('lbl_equip_prop_main_growth'):setVisible(false)
	self:get_widget('lbl_panel_equip_name'):setVisible(false)
	self:get_widget('lbl_equip_prop_main'):setVisible(false)
	self:get_widget('lbl_equip_prop1'):setVisible(false)
	self:get_widget('lbl_equip_prop2'):setVisible(false)
	self:get_widget('lbl_equip_prop3'):setVisible(false)
	self:get_widget('lbl_equip_prop4'):setVisible(false)

	self:get_widget('lbl_equip_prop_mainname'):setVisible(false)
	self:get_widget('lbl_equip_prop1_name'):setVisible(false)    
	self:get_widget('lbl_equip_prop2_name'):setVisible(false)    
	self:get_widget('lbl_equip_prop3_name'):setVisible(false)    
	self:get_widget('lbl_equip_prop4_name'):setVisible(false)

	--暂时隐藏
	self:get_widget('equip_prop_main_bg'):setVisible(false)
	self:get_widget('equip_prop_main_img'):setVisible(false)
	self:get_widget('equip_prop1_img'):setVisible(false)    
	self:get_widget('equip_prop2_img'):setVisible(false)    
	self:get_widget('equip_prop3_img'):setVisible(false)    
	self:get_widget('equip_prop4_img'):setVisible(false)
end

function item_info:update_equip_info( eq_info  )

	self.lbl_equip_prop_main_growth:setVisible(false)
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



	--对应图片
	self:get_widget('equip_prop_main_img'):setVisible(false)
	self:get_widget('equip_prop1_img'):setVisible(false)
	self:get_widget('equip_prop2_img'):setVisible(false)
	self:get_widget('equip_prop3_img'):setVisible(false)
	self:get_widget('equip_prop4_img'):setVisible(false)

	if eq_info.name ~= nil then
		if eq_info.level > 0 then
			self.lbl_panel_equip_name:setString(eq_info.name..'+'..eq_info.level)
		else
			self.lbl_panel_equip_name:setString(eq_info.name)
		end
		self.lbl_panel_equip_name:setVisible(true)
		self.lbl_panel_equip_name:setColor(self:return_label_color(eq_info.data.color))
	end
	if eq_info.main_growth ~= nil then
		self.lbl_equip_prop_main_growth:setVisible(true)
		self.lbl_equip_prop_main_growth:setString(locale.get_value('equip_growth')..' : '..eq_info.main_growth)
	end


	if eq_info.prop ~= nil then
		if eq_info.prop[1] ~= nil then

			local name = eq_info.prop[1].name
			local num  = eq_info.prop[1].value
			self.lbl_equip_prop_mainname:setString(name)
			self.lbl_equip_prop_mainname:setVisible(true)
			self.lbl_equip_prop_main:setString(num)
			self.lbl_equip_prop_main:setVisible(true)
			self:set_pro_icon('equip_prop_main_img',eq_info.data.main_prop_key)


		end
		if eq_info.prop[2] ~= nil then
				  

			local name = eq_info.prop[2].name
			local num  = eq_info.prop[2].value
			self.lbl_equip_prop1_name:setString(name)
			self.lbl_equip_prop1_name:setVisible(true)
			self.lbl_equip_prop1:setString(num)
			self.lbl_equip_prop1:setVisible(true)
			
			self:set_pro_icon('equip_prop1_img',eq_info.prop[2].prop_key)

		end
		if eq_info.prop[3] ~= nil then

			local name = eq_info.prop[3].name
			local num  = eq_info.prop[3].value
			self.lbl_equip_prop2_name:setString(name)
			self.lbl_equip_prop2_name:setVisible(true)
			self.lbl_equip_prop2:setString(num)
			self.lbl_equip_prop2:setVisible(true)
			self:set_pro_icon('equip_prop2_img',eq_info.prop[3].prop_key)

		end
		if eq_info.prop[4] ~= nil then
			local name = eq_info.prop[4].name
			local num  = eq_info.prop[4].value
			self.lbl_equip_prop3_name:setString(name)
			self.lbl_equip_prop3_name:setVisible(true)
			self.lbl_equip_prop3:setString(num)
			self.lbl_equip_prop3:setVisible(true)
			self:set_pro_icon('equip_prop3_img',eq_info.prop[4].prop_key)

		end
		if eq_info.prop[5] ~= nil then
			
			local name = eq_info.prop[5].name
			local num  = eq_info.prop[5].value
			self.lbl_equip_prop4_name:setString(name)
			self.lbl_equip_prop4_name:setVisible(true)
			self.lbl_equip_prop4:setString(num)
			self.lbl_equip_prop4:setVisible(true)
			self:set_pro_icon('equip_prop4_img',eq_info.prop[5].prop_key)

		end

	end

end



function item_info:return_label_color( color )

	if color == 'White' then
		return Color.White
	elseif color == 'Green' then
		return Color.Green
	elseif color == 'Blue' then
		return Color.Blue
	elseif color == 'Purple' then
		return Color.Purple
	elseif color == 'Orange' then
		return Color.Orange
	end	
end

--设置装备属性的图标
function item_info:set_pro_icon( img_name,pro_name )

	self:get_widget(img_name):loadTexture('shop_' .. pro_name..'.png',TextureTypePLIST)
	self:get_widget(img_name):setVisible(true)

end

function item_info:update_view(  )
	self:set_item_img( self.item_data:get_data().icon )
	self:set_cell_level( self.item_data:get_data().color)
	self:show_property()

end


--播放弹出动画
function item_info:play_up_anim(  )

	self:play_action('shop_2.ExportJson','up')
end

--播放收起动画
function item_info:play_down_anim( )
	local function callFunc(  )
		self.is_remove = true
	end
	local callFuncObj=cc.CallFunc:create(callFunc)
	self:play_action('shop_2.ExportJson','down',callFuncObj)
end


--关闭按钮
function item_info:close_button_event( sender,eventtype )
	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  
	elseif eventtype == ccui.TouchEventType.ended then
		self:play_down_anim( )
		
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end

--购买按钮
function item_info:buy_button_event( sender,eventtype )
	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  
	elseif eventtype == ccui.TouchEventType.ended then
		
		local player = model.get_player()

		local items = player:get_shop1()

		server.buy_normal_item(self.oid)

		self:play_down_anim( )
		
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end

--更新
function item_info:reload(  )
	super(item_info,self).reload()
	self:update_view()
end

--释放
function item_info:release( )
	self.is_remove = false
	--ccs.ActionManagerEx:getInstance():releaseActionsByJsonName('shop_2.ExportJson')
	super(item_info,self).release()
end
