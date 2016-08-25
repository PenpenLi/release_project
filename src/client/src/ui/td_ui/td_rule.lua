local layer					= import( 'world.layer' )
local anim_trigger 			= import( 'ui.main_ui.anim_trigger')
local ui_const				= import( 'ui.ui_const' )
local ui_mgr 				= import( 'ui.ui_mgr' )

td_rule = lua_class('td_rule',layer.ui_layer)

local default_size = 22
local default_color = cc.c3b( 0,   0,   0 )

function td_rule:_init(  )
	super(td_rule,self)._init('gui/main/td_map_2.ExportJson',true)

	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2,VisibleSize.height/2)

	self.rule_list = self:get_widget('rule_list')
	self.rule_list:ignoreAnchorPointForPosition(true)

	self:set_handler("close_button", self.close_button_event)

end

function td_rule:close_button_event( sender, event_type )
	if event_type == ccui.TouchEventType.ended then
			sender:setTouchEnabled(false)
			self.cc:setVisible(false)
			self.is_remove = true
			anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_UP_ANIM,false)
	end
end

function td_rule:release(  )
	super(td_rule,self).release()
end

function td_rule:add_rule(str, font_size, color)
	self:reload_json()
	font_size = font_size or default_size
	color = color or default_color
	local rule = self:get_widget('lbl_rule'):clone()
	rule:setString(str)
	rule:setFontSize(font_size)
	rule:setColor(color)
	print(str)
	self.rule_list:pushBackCustomItem(rule)
end