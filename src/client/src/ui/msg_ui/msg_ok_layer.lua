
local layer				= import( 'world.layer' )
local ui_const 				= import( 'ui.ui_const' )
local locale			= import( 'utils.locale' )
msg_ok_layer 		= lua_class( 'msg_ok_layer' , layer.ui_layer)

local _font_size = 20
local _edgSize	 = 5

local _json_path = 'gui/global/com_tips_1.ExportJson'
local _json_name = 'com_tips_1.ExportJson'

function msg_ok_layer:_init( ) 
	-- body
	super(msg_ok_layer,self)._init(_json_path,true)
	
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2 ,VisibleSize.height/2)
	
	self:set_handler('lbl_ok_btn', self.ok_button_event)
	self:get_widget('lbl_ok'):setString(locale.get_value('com_tip_ok'))
	self.content = ''
	self.panel = self:get_widget('Image_1')
end

function msg_ok_layer:label_width( str )

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

function msg_ok_layer:set_tip( content)
	--self:get_widget('lbl_help_msg'):setString(content)
	self.tip_label = cc.Label:create()
	self.tip_label:setWidth(420)
	self.tip_label:setSystemFontSize(_font_size)
	self.tip_label:setSystemFontName(ui_const.UiLableFontType)
	self.tip_label:setString(content)
	self.tip_label:enableOutline(ui_const.UilableStroke,_edgSize)
	self.tip_label:setColor(Color.White)
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

function msg_ok_layer:get_tip()
	return self.content
end

function msg_ok_layer:set_func_tip( content, ok_func, ok_func_tip )
	if content ~= nil then
		self:set_tip(content)
		self.content = content
	end
	self:set_ok_function(ok_func, ok_func_arg)
end

function msg_ok_layer:set_font_size( font_size )
	self.tip_label:setSystemFontSize(font_size)
end

function msg_ok_layer:set_ok_function( function_name,  arg_list)
	self.function_name = function_name
	self.arg_list = arg_list
end

function msg_ok_layer:ok_button_event( sender,eventtype)
	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  
	elseif eventtype == ccui.TouchEventType.ended then
		self.cc:setVisible(false)
		self.is_remove = true
		if self.function_name ~= nil then
			self.function_name(self.arg_list)
		end
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end

function msg_ok_layer:release(  )
	self.is_remove = false
	super(msg_ok_layer, self).release()
end
