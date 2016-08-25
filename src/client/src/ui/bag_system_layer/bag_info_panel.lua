local locale			= import( 'utils.locale' )
local model 			= import( 'model.interface' )
local combat_conf		= import( 'ui.bag_system_layer.bag_ui_conf' )
local music_mgr			= import( 'world.music_mgr' )
local ui_mgr 			= import(  'ui.ui_mgr' )

bag_info_panel = lua_class('bag_info_panel')
local load_texture_type = TextureTypePLIST
local iicons = 'icon/item_icons.plist'
local eicon_set = 'icon/e_icons.plist'
local soul_set = 'icon/soul_icons.plist'



function bag_info_panel:_init( _layer )
	self.layer = _layer
	self.sell_button 	= self.layer:get_widget('sell_button') 
	self.txt_introduce = self.layer:get_widget('txt_introduce')
	self.lbl_item_name = self.layer:get_widget('lbl_item_name')
	self.use_button = self.layer:get_widget('use_button')
	self:init_goods_view()
	self.goods_view_table 	= nil
	self.goods_view_num		= nil
	self.item_id = nil

	self.sell_button = self.layer:get_widget('sell_button')
	self.msg_button = self.layer:get_widget('msg_button')
	self.msg_button:setVisible(false)
	local function evenType(sender, eventype)
		self:sell_button_event(sender, eventype)
	end 
	self.sell_button:addTouchEventListener(evenType)

	local function evenType2(sender, eventype)
		self:use_button_event(sender, eventype)
	end 
	self.use_button:addTouchEventListener(evenType2)

	local function evenType(sender, eventype)
		self:msg_button_event(sender, eventype)
	end 
	self.msg_button:addTouchEventListener(evenType)
	--使用按钮
	--self.layer:get_widget('use_button'):setVisible(false)
end

--初始化信息框的图片框状态。
function bag_info_panel:init_goods_view(  )
	self.goods_view = self.layer:get_widget('goods_view')
	self.goods_view:getChildByName('green'):setVisible(false)
	self.goods_view:getChildByName('blue'):setVisible(false)
	self.goods_view:getChildByName('purple'):setVisible(false)
	self.goods_view:getChildByName('orange'):setVisible(false)
end

--设置信息面板显示还是不显示
function bag_info_panel:set_info_panel_visible( is_visible )
	self.layer:get_widget('Panel_1'):setVisible(is_visible)
end
--设置物品id
function bag_info_panel:set_item_id( id )
	
	self.item_id = id
end

--出售按钮的状态

function bag_info_panel:set_msg_button_state( is_sell )
	if is_sell == false then
		self.use_button:setVisible(false)
		self.msg_button:setVisible(true)
 	else
 		self.use_button:setVisible(true)
 		self.msg_button:setVisible(false)
 	end
end


---显示道具信息
function bag_info_panel:show_prop_property(  data , good_type)

	cc.SpriteFrameCache: getInstance(): addSpriteFrames( eicon_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( iicons )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( soul_set )
	local goods_data = nil
	
	if data ~= nil then
		goods_data = data
	else
		goods_data = nil
		return
	end
	self.goods_data = goods_data
	if self.goods_view:getChildByTag(10)~=nil then
		self.goods_view:removeChildByTag(10)
	end
	self.goods_view_num = nil
	self.goods_view_table = nil
	local icon_img = self.goods_view:getChildByName('item_img')
	icon_img:loadTexture( data.icon, load_texture_type )
	self.goods_view_num=equip_index
	self.goods_view_table = data
	self:set_cell_color(self.goods_view,'White')
	--要是装备类型的物品才可以设置为其他颜色
	if data.color ~= nil  then
		self:set_cell_color(self.goods_view,data.color)
	end
	self.lbl_item_name:setString(data.name)
	if data.color ~= nil then
		self.lbl_item_name:setColor(Color[data.color])
	end
	self.txt_introduce:setVisible(true)
	self.txt_introduce:setString(data.tips)
	self.layer.lbl_goods_price:setString(data.price)
end

function bag_info_panel:hide_prop_property(  )
	self.txt_introduce:setVisible(false)
end

function bag_info_panel:hide_cell_property(  )
	-- self.layer:get_widget('lbl_equip_prop_main_growth'):setVisible(false)
	-- self.layer:get_widget('lbl_panel_equip_name'):setVisible(false)
	-- self.layer:get_widget('lbl_equip_prop_main'):setVisible(false)
	-- self.layer:get_widget('lbl_equip_prop1'):setVisible(false)
	-- self.layer:get_widget('lbl_equip_prop2'):setVisible(false)
	-- self.layer:get_widget('lbl_equip_prop3'):setVisible(false)
	-- self.layer:get_widget('lbl_equip_prop4'):setVisible(false)
	-- --self.layer:get_widget('lbl_equip_prop5'):setVisible(false)
	-- --TAG
	-- self.layer:get_widget('lbl_equip_prop_mainname'):setVisible(false)
	-- self.layer:get_widget('lbl_equip_prop1_name'):setVisible(false)    
	-- self.layer:get_widget('lbl_equip_prop2_name'):setVisible(false)    
	-- self.layer:get_widget('lbl_equip_prop3_name'):setVisible(false)    
	-- self.layer:get_widget('lbl_equip_prop4_name'):setVisible(false)
	-- --self.layer:get_widget('lbl_equip_prop5_name'):setVisible(false)
	-- --self.layer:get_widget('lbl_panel_equip_level'):setVisible(false)

	-- --暂时隐藏
	-- self.layer:get_widget('equip_prop_main_bg'):setVisible(false)
	-- self.layer:get_widget('equip_prop_main_img'):setVisible(false)
	-- self.layer:get_widget('equip_prop1_img'):setVisible(false)    
	-- self.layer:get_widget('equip_prop2_img'):setVisible(false)    
	-- self.layer:get_widget('equip_prop3_img'):setVisible(false)    
	-- self.layer:get_widget('equip_prop4_img'):setVisible(false)
end

--显示装备信息
function bag_info_panel:show_cell_property( data ,good_type )
	-- body

	local goods_data = nil
	
	if data ~= nil then
		goods_data = data
	else
		goods_data = nil
		return
	end
	-- if goods_data == nil then
	-- 	return
	-- end
	if self.goods_view:getChildByTag(10)~=nil then
		self.goods_view:removeChildByTag(10)
	end
	self.goods_view_num = nil
	self.goods_view_table = nil
	local icon_img = ccui.ImageView:create()
	icon_img:loadTexture( data.icon, load_texture_type )
	icon_img:setPosition( 0, 0 )
	icon_img:setAnchorPoint( 0, 0 )
	self.goods_view:addChild(icon_img,100,10)
	self.goods_view_num=equip_index
	self.goods_view_table = data
	--设置信息的颜色边框--要是装备类型的物品才可以设置为其他颜色
	if data.color ~= nil then
		self:set_cell_color(self.goods_view,data.color)
	end



end


function bag_info_panel:update_goods_info( eq_info , goods_data)

	self.layer:get_widget('lbl_equip_prop_main_growth'):setVisible(false)
	self.layer:get_widget('lbl_panel_equip_name'):setVisible(false)
	self.layer:get_widget('lbl_equip_prop_main'):setVisible(false)
	self.layer:get_widget('lbl_equip_prop1'):setVisible(false)
	self.layer:get_widget('lbl_equip_prop2'):setVisible(false)
	self.layer:get_widget('lbl_equip_prop3'):setVisible(false)
	self.layer:get_widget('lbl_equip_prop4'):setVisible(false)
	--self.layer:get_widget('lbl_equip_prop5'):setVisible(false)
	--TAG
	self.layer:get_widget('lbl_equip_prop_mainname'):setVisible(false)
	self.layer:get_widget('lbl_equip_prop1_name'):setVisible(false)    
	self.layer:get_widget('lbl_equip_prop2_name'):setVisible(false)    
	self.layer:get_widget('lbl_equip_prop3_name'):setVisible(false)    
	self.layer:get_widget('lbl_equip_prop4_name'):setVisible(false)
	--self.layer:get_widget('lbl_equip_prop5_name'):setVisible(false)
	--self.layer:get_widget('lbl_panel_equip_level'):setVisible(false)

	self.layer:get_widget('equip_prop_main_img'):setVisible(false)
	self.layer:get_widget('equip_prop1_img'):setVisible(false)    
	self.layer:get_widget('equip_prop2_img'):setVisible(false)    
	self.layer:get_widget('equip_prop3_img'):setVisible(false)    
	self.layer:get_widget('equip_prop4_img'):setVisible(false)

	--主属性的背景
	self.layer:get_widget('equip_prop_main_bg'):setVisible(true)

	if eq_info.name ~= nil then
		if eq_info.level > 0 then
			self.layer:get_widget('lbl_panel_equip_name'):setString(eq_info.name..'+'..eq_info.level)
		else
			self.layer:get_widget('lbl_panel_equip_name'):setString(eq_info.name)
		end
		self.layer:get_widget('lbl_panel_equip_name'):setVisible(true)
		self.layer:get_widget('lbl_panel_equip_name'):setColor(self:return_label_color(eq_info.data.color))
	end
	if eq_info.main_growth ~= nil then

		self.layer:get_widget('lbl_equip_prop_main_growth'):setVisible(true)
		self.layer:get_widget('lbl_equip_prop_main_growth'):setString(locale.get_value('equip_growth')..' : '..eq_info.main_growth)
	end
	if eq_info.price ~= nil then
		self.layer.lbl_goods_price:setString(eq_info.price)
	end

	if eq_info.prop ~= nil then
		if eq_info.prop[1] ~= nil then

			local name = eq_info.prop[1].name
			local num  = eq_info.prop[1].value
			self.layer:get_widget('lbl_equip_prop_mainname'):setString(name)
			self.layer:get_widget('lbl_equip_prop_mainname'):setVisible(true)
			self.layer:get_widget('lbl_equip_prop_main'):setString(num)
			self.layer:get_widget('lbl_equip_prop_main'):setVisible(true)
			self:set_pro_icon('equip_prop_main_img',eq_info.data.main_prop_key)
		end
		if eq_info.prop[2] ~= nil then
				  
			local name = eq_info.prop[2].name
			local num  = eq_info.prop[2].value
			self.layer:get_widget('lbl_equip_prop1_name'):setString(name)
			self.layer:get_widget('lbl_equip_prop1_name'):setVisible(true)
			self.layer:get_widget('lbl_equip_prop1'):setString(num)
			self.layer:get_widget('lbl_equip_prop1'):setVisible(true)
			
			self:set_pro_icon('equip_prop1_img',eq_info.prop[2].prop_key)
		end
		if eq_info.prop[3] ~= nil then
			local name = eq_info.prop[3].name
			local num  = eq_info.prop[3].value
			self.layer:get_widget('lbl_equip_prop2_name'):setString(name)
			self.layer:get_widget('lbl_equip_prop2_name'):setVisible(true)
			self.layer:get_widget('lbl_equip_prop2'):setString(num)
			self.layer:get_widget('lbl_equip_prop2'):setVisible(true)
			self:set_pro_icon('equip_prop2_img',eq_ieq_info.prop[3].prop_key)
		end
		if eq_info.prop[4] ~= nil then
			local name = eq_info.prop[4].name
			local num  = eq_info.prop[4].value
			self.layer:get_widget('lbl_equip_prop3_name'):setString(name)
			self.layer:get_widget('lbl_equip_prop3_name'):setVisible(true)
			self.layer:get_widget('lbl_equip_prop3'):setString(num)
			self.layer:get_widget('lbl_equip_prop3'):setVisible(true)
			self:set_pro_icon('equip_prop3_img',eq_info.prop[4].prop_key)
		end
		if eq_info.prop[5] ~= nil then
			local name = eq_info.prop[5].name
			local num  = eq_info.prop[5].value
			self.layer:get_widget('lbl_equip_prop4_name'):setString(name)
			self.layer:get_widget('lbl_equip_prop4_name'):setVisible(true)
			self.layer:get_widget('lbl_equip_prop4'):setString(num)
			self.layer:get_widget('lbl_equip_prop4'):setVisible(true)
			self:set_pro_icon('equip_prop4_img',eq_info.prop[5].prop_key)
		end

	end

end

--设置装备属性的图标
function bag_info_panel:set_pro_icon( img_name,pro_name )
	
	self.layer:get_widget(img_name):loadTexture('bag_'..pro_name..'.png',TextureTypePLIST)
	self.layer:get_widget(img_name):setVisible(true)

end

function bag_info_panel:return_label_color( color )

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

function bag_info_panel:set_cell_color( cell,level )
	if level == EnumLevel.White then
		
		cell:getChildByName('green'):setVisible(false)
		cell:getChildByName('blue'):setVisible(false)
		cell:getChildByName('purple'):setVisible(false)
		cell:getChildByName('orange'):setVisible(false)
	elseif level == EnumLevel.Green then
		
		cell:getChildByName('green'):setVisible(true)
		cell:getChildByName('blue'):setVisible(false)
		cell:getChildByName('purple'):setVisible(false)
		cell:getChildByName('orange'):setVisible(false)
	elseif level == EnumLevel.Blue then
		
		cell:getChildByName('green'):setVisible(false)
		cell:getChildByName('blue'):setVisible(true)
		cell:getChildByName('purple'):setVisible(false)
		cell:getChildByName('orange'):setVisible(false)
	elseif level == EnumLevel.Purple then
		
		cell:getChildByName('green'):setVisible(false)
		cell:getChildByName('blue'):setVisible(false)
		cell:getChildByName('purple'):setVisible(true)
		cell:getChildByName('orange'):setVisible(false)
	elseif level == EnumLevel.Orange then
		
		cell:getChildByName('green'):setVisible(false)
		cell:getChildByName('blue'):setVisible(false)
		cell:getChildByName('purple'):setVisible(false)
		cell:getChildByName('orange'):setVisible(true)
	else
		--print('没有这个等级')
	end
end

function bag_info_panel:open_ui( item_data )
	local ui_type = item_data.ui_type
	local battle_id = item_data.battle_id
	local temp_lbl = string_split(EnumUiType[ui_type].file,'.')
	local temp_ui = ui_mgr.create_ui(import(EnumUiType[ui_type].file),temp_lbl[3])
	if ui_type == EnumUiType.soul_exp.type then
		temp_ui:set_item_id(item_data.id)
	end
end

--使用按钮事件
function bag_info_panel:use_button_event( sender, eventType )

	if  eventType == ccui.TouchEventType.ended then
		music_mgr.ui_click()
		local player = model.get_player()
		if self.goods_data.ui_type ~= nil then
			self:open_ui(self.goods_data)
		else
			local player = model.get_player()
			local oid = player:get_item_oid_byid(self.goods_data.id)
			server.use_item(oid, 1)
		end
	end
end

--详情按钮事件
function bag_info_panel:msg_button_event( sender, eventType )
	if  eventType == ccui.TouchEventType.ended then
		music_mgr.ui_click()
		self.guide_tips_layer = ui_mgr.create_ui(import('ui.guide_tips_layer.guide_tips_layer'), 'guide_tips_layer')
		self.guide_tips_layer:gain_from(self.item_id)
	end
end

--出售按钮事件
function bag_info_panel:sell_button_event( sender, eventType )

	if  eventType == ccui.TouchEventType.ended then
		music_mgr.ui_click()
		--售出
		local sell_ui = ui_mgr.create_ui(import('ui.bag_system_layer.sell_panel'),'sell_panel')
		sell_ui:init_data( self.item_id )
		-- local player = model.get_player()
		-- server.sell_item(player:get_item_oid_byid(self.item_id))

	end
end