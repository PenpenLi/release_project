local layer				= import( 'world.layer' )
local message_box		= import( 'ui.message_box')
local utf_utils		= import( 'utils.utf8' )
local ui_const 		= import('ui.ui_const')

rich_text_layout = lua_class('rich_text_layout')

local listChannel =
{
	['all'] 		= "【综合】",
    ['private'] 	= "【私聊】",
    ['lianmeng'] 	= "【联盟】",
    ['system']		= "【系统】"
}
local listColor =
{
	['all'] 		= cc.c3b(255, 246, 216),
    ['private'] 	= cc.c3b(146, 216, 47),
    ['lianmeng'] 	= cc.c3b(189, 252, 201),
    ['system']		= cc.c3b(255, 0, 0),
}

local default_font = ui_const.UiLableFontType
local default_font_size = 22

function rich_text_layout:_init(msg_data, width, high)
	self.tag = 0
	self.len = 0
	self.rich_text = ccui.RichText:create()  
	self.rich_text:ignoreContentAdaptWithSize(false)  
	self.rich_text:setContentSize(cc.size(width, high))
	self.text = ""
	self.type = msg_data['channel']
	self:push_text(listChannel[msg_data['channel']], listColor[msg_data['channel']])
	self.args = self:decode(msg_data)
	self:set_rich_handle()
end

function rich_text_layout:get_len()
	return self.len
end

function rich_text_layout:add_text(text)
	self.text = self.text .. text
    local currentIndex = 1
    while currentIndex <= #text do
        local char = string.byte(text, currentIndex)
        local siz = utf_utils.chsize(char)
        currentIndex = currentIndex + siz
        if siz > 1 then
        	self.len = self.len + 2
        else
        	self.len = self.len + 1
        end
    end
end

function rich_text_layout:get_rich_text()
	return self.rich_text
end

function rich_text_layout:grab_tag()
	self.tag = self.tag + 1
	return self.tag
end

--<a type='player','item' ..>lint text</a>
--<img path='...' />
function rich_text_layout:decode(msg_data)
	-- (s1, e1) to <a type='' >
	-- (s2, e2) to </a>
	local text = msg_data.msg
	if text == nil then 
		return nil
	end
	local href_args = {}
	local pos = 1, s1, s2, e1, e2, a_start, a_end, i_end, i_start
	local flag
	if msg_data['channel'] == 'system' then
		 repeat
			a_start, a_end = text:find("<a.->", pos)
			i_start, i_end = text:find("<img", pos)
			if a_start == nil and i_start == nil then 
				self:push_text(text:sub(pos, text:len()))
				break
			end
			a_start = a_start or 10000000 --设为无穷大
			i_start = i_start or 10000000 
			
	print("begin   ",a_start, a_end, i_start, i_end)
	if i_start then
		print("i_start is nil ????????????????")
	end
			if i_start == nil or a_start < i_start then
				flag = 1
				s1, e1 = a_start, a_end
				s2, e2 = text:find("</a>", pos)
			else
				flag = 2
				s1, e1 = i_start, i_end
				s2, e2 = text:find("/>", pos)
			end
			if s2 == nil or e2 == nil or e1 > s2 then 
				print('命令不合法！！！！！！')
				return
			end	
	print("catch:::::     ", s1, e1, s2, e2, pos)
			self:push_text(text:sub(pos, s1-1))
			self:add_text(text:sub(pos, s1-1))
			if flag == 1 then
				-- 获取参数
				for k, v in string.gmatch(text:sub(s1, e1), "(%w+)%s*=%s*(%w+)") do
			 		href_args[k] = v
			 	end
			 	self:push_text_link(text:sub(e1+1,  s2-1), listColor[msg_data['channel']])
			 	self:add_text(text:sub(e1+1,  s2-1))
			else
				local args = {}
				print("path match:  ", string.gmatch(text:sub(s1, s2), "(%w+)%s*=%s*([%S]+%.png)")())
				for k, v in string.gmatch(text:sub(s1, s2), "(%w+)%s*=%s*([%S]+%.png)") do
			 		args[k] = v
			 		print("img !!!!", k, v)
			 	end
			 	print("path!!!!!!!!!!!!", args['path'])
			 	if args['path'] ~= nil then
					self:push_image(args['path'])
				end
			end
			pos = e2+1
		 until(pos > text:len())
	else
		self:push_text(text, listColor[msg_data['channel']])
		self:add_text(text)
	end
	-- for k, v in pairs(href_args) do
	-- 	print(k, v)
	-- end
	return href_args
end


function rich_text_layout:push_text( text_content, color )
	color = color or Color.White
	temp_tag = self:grab_tag()
	local rich_text = ccui.RichElementText: create( temp_tag, color, 255, text_content, default_font, default_font_size )
	self.rich_text: pushBackElement(rich_text)
end

function rich_text_layout:push_image( image_path )
	--TODO: 暂不支持plist打包的图片，只支持单张小图 Sprite::create( png )
	temp_tag = self:grab_tag()
	local rich_image = ccui.RichElementImage: create( temp_tag, Color.White, 255, image_path )
	self.rich_text: pushBackElement( rich_image )
	return temp_tag
end

function rich_text_layout:push_text_link( text_content, color )
	color = color or Color.White
	temp_tag = self:grab_tag()
	local rich_text = ccui.RichElementText: create( temp_tag, color, 255, text_content, default_font, default_font_size )
	self.rich_text: pushBackElement(rich_text)
end

function rich_text_layout:set_rich_handle()
	local function item_event( sender,eventtype )
		if eventtype == ccui.TouchEventType.began then
		elseif eventtype == ccui.TouchEventType.moved then
		elseif eventtype == ccui.TouchEventType.ended then
			print("show item !!!!!!!!")
		elseif eventtype == ccui.TouchEventType.canceled then
		end
	end

	local function player_event( sender,eventtype )
		if eventtype == ccui.TouchEventType.began then
		elseif eventtype == ccui.TouchEventType.moved then
		elseif eventtype == ccui.TouchEventType.ended then
			print("show player msg !!!!!!!!")
		elseif eventtype == ccui.TouchEventType.canceled then
		end
	end

	self.rich_text:setTouchEnabled(true)
	if self.args == nil then 
		return 
	end
	if self.args['type'] == 'player' then
		self.rich_text:addTouchEventListener(player_event)
	elseif self.args['type'] == 'item' then 
		self.rich_text:addTouchEventListener(item_event)
	end
end