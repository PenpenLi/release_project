
local layer					= import( 'world.layer' )
local soul_list_panel 		= import( 'ui.soul_system.soul_list_panel' )
local anim_trigger 			= import( 'ui.main_ui.anim_trigger')
local soul_info_panel 		= import( 'ui.soul_system.soul_info_panel' )

soul_system_layer = lua_class('soul_system_layer',layer.ui_layer)


function soul_system_layer:_init(  )

	super(soul_system_layer,self)._init('gui/main/ui_soul_sys.ExportJson',true)

	self.widget:setPosition(VisibleSize.width/2 ,VisibleSize.height/2)

	self.soul_list_panel = soul_list_panel.soul_list_panel( self )
	self.soul_info_panel = soul_info_panel.soul_info_panel( self )

	self.is_remove = false

	self:set_handler("close_button", self.close_button_event)
end

function soul_system_layer:close_button_event(  sender, eventtype  )
	if eventtype == 0 then
		print('press close')
	end
	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  
	elseif eventtype == ccui.TouchEventType.ended then
		sender:setTouchEnabled(false)
		self.cc:setVisible(false)
		self.is_remove = true
		anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_UP_ANIM,false)
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end

function soul_system_layer:release(  )
	print('remove ui_soul_sys.plise')

	cc.SpriteFrameCache: getInstance(): removeSpriteFramesFromFile( 'gui/ui_soul_sys/UI_SKI~10.plist' )
	cc.SpriteFrameCache: getInstance(): removeSpriteFramesFromFile( 'gui/ui_soul_sys/UI_SKI~11.plist' )
	self.is_remove = false
end