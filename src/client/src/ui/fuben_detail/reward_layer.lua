local layer 		= import('world.layer')
local locale		= import('utils.locale')

reward_layer			= lua_class('reward_layer',layer.ui_layer)
local eicon_set			= 'icon/e_icons.plist'
local iicon_set 		= 'icon/item_icons.plist'
local soul_set  		= 'icon/soul_icons.plist'
local _json_path 	= 'gui/main/fuben_detail_4.ExportJson'
local load_texture_type 	= TextureTypePLIST

function reward_layer:_init( )
	super(reward_layer,self)._init(_json_path,true)
	self.cc:removeAllChildren()
	self.is_remove	= false
	local p_reward = self.widget:getChildByName('p_reward')
	self.widget:ignoreAnchorPointForPosition(true)
	p_reward:ignoreAnchorPointForPosition(true)
end

function reward_layer:get_widget()
	return self.widget
end

function reward_layer:get_item_list()
	--return self:get_widget( 'item_list' )
	return ccui.Helper:seekWidgetByName(self.widget, 'item_list')
end

function reward_layer:set_lbl_visible( v )
	ccui.Helper:seekWidgetByName(self.widget, 'lbl_gain_nothing'):setVisible(v)
end

function reward_layer:set_battle( str )
	local temp = self.widget:getChildByName('p_reward')
	self.p_reward	= temp:getChildByName('Image_2')
	local lbl_battle	= self.p_reward:getChildByName('lbl_battle')
	-- lbl_money 	= self.p_reward:getChildByName('lbl_gold')
	-- lbl_exp		= self.p_reward:getChildByName('lbl_exp')
	lbl_battle:setString(locale.get_value(str))
end

function reward_layer:set_gold( num )
	local temp = self.widget:getChildByName('p_reward')
	self.p_reward	= temp:getChildByName('Image_2')
	local lbl_gold	= self.p_reward:getChildByName('lbl_gold')
	lbl_gold:setString( tostring(num) )
end

function reward_layer:set_exp( num )
	local temp = self.widget:getChildByName('p_reward')
	self.p_reward	= temp:getChildByName('Image_2')
	local lbl_exp	= self.p_reward:getChildByName('lbl_exp')
	lbl_exp:setString( tostring(num) )
end

function reward_layer:release()
	self.is_remove	= false
	super(reward_layer,self).release()
end
