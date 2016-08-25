local layer 		= import('world.layer')
local locale		= import('utils.locale')
local anim_trigger 			= import( 'ui.main_ui.anim_trigger')

complete_layer			= lua_class('complete_layer',layer.ui_layer)
local eicon_set			= 'icon/e_icons.plist'
local iicon_set 		= 'icon/item_icons.plist'
local soul_set  		= 'icon/soul_icons.plist'
local _json_path 	= 'gui/main/fuben_detail_2.ExportJson'
local load_texture_type 	= TextureTypePLIST


function complete_layer:_init( )
	super(complete_layer,self)._init(_json_path,true)
	self.cc:removeAllChildren()
	self.widget:ignoreAnchorPointForPosition(true)
	local p_complete = self:get_widget('p_complete')
	local size = p_complete:getContentSize()
	p_complete:ignoreAnchorPointForPosition(true)
	self.is_remove	= false
end


function complete_layer:get_complete()
	return self.widget
end

function complete_layer:play_anim()
	self:play_action('fuben_detail_2.ExportJson','up2')
	self:play_action('fuben_detail_2.ExportJson','xz')
end

function complete_layer:release()
	self.is_remove	= false
	super(complete_layer,self).release()
end

