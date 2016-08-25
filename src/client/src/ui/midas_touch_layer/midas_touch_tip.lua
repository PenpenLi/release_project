local layer 			= import('world.layer')
local ui_mgr 			= import( 'ui.ui_mgr' ) 
local combat_conf		= import( 'ui.midas_touch_layer.midas_touch_cont' )
local locale			= import( 'utils.locale' )
local anim_trigger 		= import( 'ui.main_ui.anim_trigger')
local ui_const			= import( 'ui.ui_const' )

midas_touch_tip = lua_class('midas_touch_tip',layer.ui_layer)
local _json_file 	= 'gui/main/midas_touch_2.ExportJson'

function midas_touch_tip:_init( )

	super(midas_touch_tip,self)._init(_json_file,true)
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2,VisibleSize.height/2)

	self:set_handler('Button_close', self.close_button_event)
	self:set_handler('Button_10', self.check_vip_event)


	self:finish_init()
end

function midas_touch_tip:finish_init()
	for name, val in pairs(combat_conf.midas_touch_2_ui_label) do 	--读出role_ui_conf文件的table
		self['lbl_' .. name] = self:get_widget('lbl_' .. name) --名字加前缀，就可以读出相应的名字label控件
		--self['txt_' .. name] = self:get_widget('txt_' .. name)	--一样，这样就可以读出相应的数值的label控件
		local temp_name = self['lbl_' .. name]			--把读出来的控件存到self的一个table中
		if temp_name ~= nil then 						--名字不为空，就设置字体类似，和显示的内容
			temp_name:setFontName(ui_const.UiLableFontType)
			local label_value = locale.get_value('midas_touch_' .. name)
			if label_value ~= nil then
				temp_name:setString(label_value)	
			end	
			if val.edge ~= nil and val.edge > 0 then 					--edge的值大于0就描边
				temp_name:enableOutline(ui_const.UilableStroke, val.edge)  ---，描边，厚度 role_ui_conf.lua中role_ui_label的edge
			end
		end
	end
end

function midas_touch_tip:check_vip_event( sender,eventtype )
	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  
	elseif eventtype == ccui.TouchEventType.ended then
		self.vip_layer = ui_mgr.create_ui(import('ui.market_layer.market_layer'), 'market_layer')
		self.vip_layer:jump_to_layer(2)
		self:release()
	elseif eventtype == ccui.TouchEventType.canceled then
		
	end
end

function midas_touch_tip:reload( )
	super(midas_touch_tip,self).reload()
end

--移除操作
function midas_touch_tip:release( ) --记得移除图标的plist文件
	self.is_remove = true
	super(midas_touch_tip,self).release()
	-- body
end

--关闭按钮
function midas_touch_tip:close_button_event( sender,eventtype )

	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  
	elseif eventtype == ccui.TouchEventType.ended then
		self.cc:setVisible(false)
		anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_UP_ANIM,false)
		self.is_remove = true
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end
