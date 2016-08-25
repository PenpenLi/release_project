
local layer				= import( 'world.layer' )
local ui_const 				= import( 'ui.ui_const' )
local locale			= import( 'utils.locale' )
msg_ok_cancel_layer = lua_class( 'msg_ok_cancel_layer' , layer.ui_layer)

local _json_path = 'gui/global/com_tips_2.ExportJson'
local _json_name = 'com_tips_2.ExportJson'

local _font_size = 20
local _edgSize	 = 5

function msg_ok_cancel_layer:_init( ) 
	-- body
	super(msg_ok_cancel_layer,self)._init(_json_path, true)

	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2 ,VisibleSize.height/2)
	self:set_handler('lbl_ok_btn', self.ok_button_event)
	self:set_handler('lbl_cancel_btn', self.cancel_button_event)
	self:get_widget('lbl_ok'):setString(locale.get_value('com_tip_ok'))
	self:get_widget('lbl_cancel'):setString(locale.get_value('com_tip_cancel'))
	self.panel = self:get_widget('Image_1')
	self.content = ''
end

function msg_ok_cancel_layer:label_width( str )

	local temp_label = cc.Label:create()
	
	temp_label:setSystemFontSize(_font_size)
	temp_label:setSystemFontName(ui_const.UiLableFontType)
	temp_label:setString(str)
	temp_label:enableOutline(ui_const.UilableStroke,_edgSize)
	self.panel:addChild(temp_label)

	local width = temp_label:getBoundingBox().width
	temp_label:removeFromParent()
	return width
end

function msg_ok_cancel_layer:set_tip( content)
	self.tip_label = cc.Label:create()

	self.tip_label:setWidth(420)
	self.tip_label:setSystemFontSize(_font_size)
	self.tip_label:setSystemFontName(ui_const.UiLableFontType)
	self.tip_label:setString(content)
	self.tip_label:setColor(Color.White)
	self.tip_label:enableOutline(ui_const.UilableStroke,_edgSize)
	self.tip_label:setAnchorPoint(0.5, 0.5)

	local width = self:label_width(content)
	if width <= 420 then
		self.tip_label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)

	else
		self.tip_label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
		self.tip_label:setVerticalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	end

	local size = self.panel:getContentSize()
	self.tip_label:setPosition(size.width / 2 , size.height / 2)
	self.panel:addChild(self.tip_label)
	self.content = content
end

function msg_ok_cancel_layer:set_font_size( font_size )
	self.tip_label:setSystemFontSize(font_size)
end

function msg_ok_cancel_layer:set_ok_function( function_name, arg_list )
	self.ok_function = function_name
	self.ok_arg_list = arg_list
end

function msg_ok_cancel_layer:set_cancel_function(function_name, arg_list)
	self.cancel_function = function_name
	self.cancel_arg_list = arg_list
end

function msg_ok_cancel_layer:set_func_tip( content, ok_func, ok_func_arg, cancel_func, cancel_func_arg )
	if content ~= nil then
		self:set_tip(content)
	end
	self:set_ok_function(ok_func, ok_func_arg)
	self:set_cancel_function(cancel_func, cancel_func_arg)
end

function msg_ok_cancel_layer:set_button_name( ok_btn_name, cancel_btn_name )
	if ok_btn_name ~= nil then
		self:get_widget('lbl_ok'):setString(ok_btn_name)
	end
	if cancel_btn_name ~= nil then
		self:get_widget('lbl_cancel'):setString(cancel_btn_name)
	end
end

function msg_ok_cancel_layer:ok_button_event(sender,eventtype )
	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  
	elseif eventtype == ccui.TouchEventType.ended then
		--self.cc:setVisible(false)
		
		if self.ok_function ~= nil then
			self.ok_function(self.ok_arg_list)
		end
		self.is_remove = true
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end

function msg_ok_cancel_layer:cancel_button_event( sender,eventtype)
	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  
	elseif eventtype == ccui.TouchEventType.ended then
		if self.cancel_function ~= nil then
			self.cancel_function(self.cancel_arg_list)
		end
		self.cc:setVisible(false)
		self.is_remove = true
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end

function msg_ok_cancel_layer:release(  )
	self.is_remove = true
	super(msg_ok_cancel_layer, self).release()
end