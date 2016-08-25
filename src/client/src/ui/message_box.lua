-- local primitives = import( 'utils.primitives' )
local ui_const			= import( 'ui.ui_const' )

message_box	= lua_class('message_box')

function message_box:_init()
	self._tag = 0

	self._richText = ccui.RichText: create()
	self._richText: ignoreContentAdaptWithSize(false)
	self._richText: setContentSize(cc.size(300, 100))

	self.default_font = 'fonts/msyh.ttf'
	self.default_font_size = 20
	self.line_characters = 50
	self._text = ''

	--[[
	local function touch_event( )
		print('adfasdfasdfasdfasdfasdfas')
	end
	--]]

	-- self:push_text( '一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四' )
	-- self:push_image( 'gui/streak1.png' )
	-- 不支持plist: self:push_image( 'sicon/skill (1).png' )
	-- self:push_text_link( 'click me 中文 ', touch_event )
end

function message_box:grab_tag()
	self._tag = self._tag + 1
	return self._tag
end

function message_box:show_text( text )
	self._text = text
	--TODO: 初始化信息：切割、push文字、push图片、push链接
end

function message_box:push_text( text_content, color )
	color = color or Color.White
	local temp_tag = self:grab_tag()
	local rich_text = ccui.RichElementText: create( temp_tag, color, 255, text_content, self.default_font, self.default_font_size )
	self._richText: pushBackElement(rich_text)
	self._text = self._text .. text_content

	return temp_tag
end

function message_box:push_image( image_path )
	--TODO: 暂不支持plist打包的图片，只支持单张小图 Sprite::create( png )
	local temp_tag = self:grab_tag()
	local rich_image = ccui.RichElementImage: create( temp_tag, Color.White, 255, image_path )
	self._richText: pushBackElement( rich_image )
	self._text = self._text .. '[图]'

	return temp_tag
end

function message_box:push_text_link( text_content, func, color )
	color = color or Color.White
	local temp_tag = self:grab_tag()
	local trans_back = cc.Scale9Sprite: create( 'transparentdot.png' )
	local fore_text = cc.LabelTTF:create( text_content, self.default_font, self.default_font_size )
	fore_text: setColor( color )
	local linkable_btn = cc.ControlButton: create( fore_text, trans_back )
	linkable_btn: setZoomOnTouchDown( false )
	linkable_btn: registerControlEventHandler( func, cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE )

	local rich_button = ccui.RichElementCustomNode: create( temp_tag, Color.White, 255, linkable_btn )

	self._richText: pushBackElement( rich_button )
	self._text = self._text .. text_content

	return temp_tag
end

function message_box:get_height()
	local size = self._richText: getContentSize()
	-- charcount 行容量
	--TODO: magic number: 2.3 （中文和英文的字宽不一致，字体不同也有不同的表现）
	local charcount = size.width / self.default_font_size * 2.3
	local lines = math.ceil(string.len(self._text) / charcount)

	--[[
	local pos_x, pos_y = self._richText: getPosition()
	print(' x, y ', size.width , pos_y )
	local box = { 0, 0, pos_x , lines * self.default_font_size * 1.25 }
	local drawing = primitives.draw_box( box, cc.c4f(0.5,0.3,0.1,0.8))
	self._richText: addChild( drawing )
	--]]
	return lines * self.default_font_size * 1.25
end
