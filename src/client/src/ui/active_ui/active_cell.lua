local ui_const			= import( 'ui.ui_const' )

active_cell		= lua_class( 'active_cell' )

function active_cell:_init( layer )
	self.layer	= layer
	self:create_cell()
	self:init_lbl()
end

function active_cell:create_cell()
	self.btn	= self.layer:get_widget( 'active_btn' ):clone( ) 
end

function active_cell:get_btn()
	return self.btn
end

function active_cell:init_lbl()
	self.icon_img	= self.btn:getChildByName( 'icon_img' )
	self.lbl_active_title	= self.btn:getChildByName( 'lbl_active_title' )
	self.lbl_active_time	= self.btn:getChildByName( 'lbl_active_time' )
end

function active_cell:set_icon_img( route,t )
	self.icon_img:loadTexture(route,t)
end

function active_cell:set_title( title )
	self.lbl_active_title:setString( title )
end

function active_cell:set_time( time_str )
	self.lbl_active_time:setString( time_str )
end