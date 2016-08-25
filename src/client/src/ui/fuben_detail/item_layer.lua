local layer 		= import('world.layer')
local locale		= import('utils.locale')
local anim_trigger 			= import( 'ui.main_ui.anim_trigger')

item_layer			= lua_class('item_layer',layer.ui_layer)
local eicon_set			= 'icon/e_icons.plist'
local iicon_set 		= 'icon/item_icons.plist'
local soul_set  		= 'icon/soul_icons.plist'
local _json_path 	= 'gui/main/fuben_detail_6.ExportJson'
local load_texture_type 	= TextureTypePLIST


function item_layer:_init( )
	super(item_layer,self)._init(_json_path,true)
	self.cc:removeAllChildren()
	self.is_remove	= false
	self.p_item = self.widget:getChildByName('p_item')
	self.widget:ignoreAnchorPointForPosition(true)
	local size = self.p_item:getContentSize()
	self.p_item:ignoreAnchorPointForPosition(true)
end

function item_layer:get_item_widget()
	return self.widget
end

function item_layer:play_anim()
	self.play_action('fuben_detail_6.ExportJson','Animation0')
end

function item_layer:set_img(route, t)
	local img = ccui.Helper:seekWidgetByName(self.widget, 'item')
	img:loadTextureNormal(route, t)
end

function item_layer:get_btn()
	return ccui.Helper:seekWidgetByName(self.widget, 'item')
end

function item_layer:set_num( num )
	local lbl_num	= ccui.Helper:seekWidgetByName(self.widget, 'lbl_num')
	lbl_num:setString('x' .. num)
end

function item_layer:set_img_frame( level )
	local cell = self.p_item:getChildByName('item')
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

function item_layer:release()
	self.is_remove	= false
	super(item_layer,self).release()
end