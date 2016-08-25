local layer 		= import('world.layer')
local locale		= import('utils.locale')
local anim_trigger 			= import( 'ui.main_ui.anim_trigger')

ex_reward_layer			= lua_class('ex_reward_layer',layer.ui_layer)
local eicon_set			= 'icon/e_icons.plist'
local iicon_set 		= 'icon/item_icons.plist'
local soul_set  		= 'icon/soul_icons.plist'
local _json_path 	= 'gui/main/fuben_detail_5.ExportJson'
local load_texture_type 	= TextureTypePLIST


function ex_reward_layer:_init( )
	super(ex_reward_layer,self)._init(_json_path,true)
	self.cc:removeAllChildren()
	self.is_remove	= false
	local p_reward = self.widget:getChildByName('p_reward')
	self.widget:ignoreAnchorPointForPosition(true)
	p_reward:ignoreAnchorPointForPosition(true)
end

function ex_reward_layer:get_widget()
	return self.widget
end

function ex_reward_layer:get_item_list()
	return ccui.Helper:seekWidgetByName(self.widget, 'item_list')
end

function ex_reward_layer:set_lbl_visible( v )
	ccui.Helper:seekWidgetByName(self.widget, 'lbl_gain_nothing'):setVisible(v)
end

function ex_reward_layer:release()
	self.is_remove	= false
	super(ex_reward_layer,self).release()
end