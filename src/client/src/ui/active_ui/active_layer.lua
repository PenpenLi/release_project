local layer				= import( 'world.layer' )
local active_cell		= import( 'ui.active_ui.active_cell' )
local model				= import( 'model.interface' )
local anim_trigger		= import( 'ui.main_ui.anim_trigger' )
local navigation_bar	= import( 'ui.equip_sys_layer.navigation_bar' )
local locale			= import( 'utils.locale' )
local ui_const			= import( 'ui.ui_const' ) 
local ui_mgr			= import( 'ui.ui_mgr' ) 

active_layer	= lua_class('active_layer',layer.ui_layer)

local icon_p  	= 'icon/common.plist'
local _json		= 'gui/main/ui_active.ExportJson'
local _edgSize	= 5
local _font_size	= 22
local _title_font_size	= 25
local load_texture_type = TextureTypePLIST

function active_layer:_init( )
	super(active_layer,self)._init(_json,true)
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width / 2, VisibleSize.height / 2)
	self.active_table	= data.activities
	self.notice_table	= data.notice
	self:init_component( )
	self.is_remove = false
	--ui_mgr.schedule_once(0, self, self.first_init)
	self:first_init()
end

function active_layer:first_init()
	self:init_read_t()
	self:updata_active_list( )
	self:updata_content_list( self.keys[1][1], self.keys[1][2] )

	self.close_button	= self:get_widget('close_btn')
	self:set_handler('close_btn',self.close_button_event)
end

function active_layer:init_read_t()

	local read_str	= cc.UserDefault:getInstance():getStringForKey("had_read")
	self.read_table	= {}
	if read_str ~= '' then
	 	for m in string.gmatch(read_str,'[^|]+') do
	 		local type_n	= tonumber(string.sub(m,1,2))
	 		local id 		= tonumber(string.sub(m,3,-1))
	 		if type_n == 10 then
	 			if self.notice_table[id] ~= nil then
	 				self.read_table[m]	= 1
	 			end
	 		elseif type_n == 20 then 
	 			if self.active_table[id] ~= nil then
	 				self.read_table[m]	= 1
	 			end
	 		end
	 	end
	end
end

function active_layer:init_component( )
	self.active_list 	= self:get_widget('active_list')
	self.content_list	= self:get_widget('content_list')
	self.active_title	= self:get_widget('active_title')
	self.active_time_title	= self:get_widget('active_time_title')
	self.active_time 		= self:get_widget('active_time')
	
end

function active_layer:reset_list_event( widget )
	local function scrollViewEvent(sender, eventtype)
	
	end
	widget:addEventListener( scrollViewEvent )
end

function active_layer:create_cell( i )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( icon_p )
	local a_panel	= active_cell.active_cell(self)
	local a_cell 	= a_panel:get_btn()
	local active
	local time_str
	local unread_icon 	= a_cell:getChildByName('unread_icon')
	if self.keys[i][1] == 1 then
		local read_id_str = '10' .. self.keys[i][2]
		if self.read_table[read_id_str] ~= nil then
			unread_icon:setVisible(false)
		end
		active 	= self.notice_table[self.keys[i][2]]
		self:set_touch_handler(a_cell,1,active.id)
		a_panel:set_icon_img('common/haojiao.png',load_texture_type)
	else
		local read_id_str = '20' .. self.keys[i][2]
		if self.read_table[read_id_str] ~= nil then
			unread_icon:setVisible(false)
		end
		active 	= self.active_table[self.keys[i][2]]
		local year,month,day,hour 	= self:time_to_str(active.end_time)
		local time_t 				= {['year'] = year,['month'] = month,['day'] = day,['hour'] = hour}
		time_str = locale.get_value_with_var('active_end_time',time_t)
		self:set_touch_handler(a_cell,2,active.id)
		a_panel:set_icon_img('common/huodong.png',load_texture_type)
	end
	a_panel:set_title(active.title)
	a_panel:set_time(time_str)
	if time_str ~= nil then
		a_panel:set_time(time_str)
	end
	a_cell:ignoreAnchorPointForPosition(false)
	self.active_list:pushBackCustomItem(a_cell)
end

function active_layer:updata_active_list( )
	self:reset_list_event( self.active_list )
	self.active_list:removeAllItems()
	self.active_list:jumpToTop()

	self.list_count	= 0
	self.cell_hight	= 114
	self.keys		= {}
	self.temp_keys	= {}

	local function compare(a,b)
		return a[2] < b[2]
	end

	for i, v in pairs(self.notice_table) do
		self.list_count	= self.list_count + 1
		table.insert(self.keys, {1,i})
		print('insert!!!!!!!!!!!!!!!!!!!!!!!!')
	end
	table.sort(self.keys,compare)

	for i, v in pairs(self.active_table) do	
		local year, month, day, hour = self:time_to_str(v.end_time)
		local end_date = {['year'] = tonumber(year),  ['month'] = tonumber(month),  ['day'] = tonumber(day),  ['hour'] = tonumber(hour)}
		local end_time_stamp = os.time(end_date)
		local year, month, day, hour = self:time_to_str(v.start_time)
		local start_date = {['year'] = tonumber(year),  ['month'] = tonumber(month),  ['day'] = tonumber(day),  ['hour'] = tonumber(hour)}
		local start_time_stamp = os.time(start_date)
		local now_time = os.time()
		if end_time_stamp > now_time and now_time > start_time_stamp then
			self.list_count	= self.list_count + 1
			table.insert(self.temp_keys, {i,end_time_stamp})
		end
	end
	table.sort(self.temp_keys,compare)

	for i,v in pairs(self.temp_keys) do
		table.insert(self.keys, {2,v[1]})
		print('insert!!!!!!!!!!!!!!!!!!!!!!!!')
	end
	local num = 0
	if 8 < self.list_count then
		num = 8
	else 
		num = self.list_count
	end
	for i = 1, num do
		self:create_cell( i )
	end
	
	local function tick()
		self:second_create()
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.tick)
	end
	if num > 8 then
		self.tick	= cc.Director:getInstance():getScheduler():schedulerScriptFun(tick,0.1,false)
	end
	print('asdfsadfsdfsadfsdf')
end


function active_layer:second_create()
	for i = 9, self.list_count do
		self:create_cell( i )
	end
end

function active_layer:add_content( str, panel_width, color , font_size)
	local lbl_cont = cc.Label:create()
	lbl_cont:setSystemFontName(ui_const.UiLableFontType)
	lbl_cont:enableOutline(ui_const.UilableStroke,_edgSize)
	lbl_cont:setWidth(520)
	lbl_cont:setSystemFontSize(font_size)
	lbl_cont:setString(str)	
	lbl_cont:setColor(color)
	lbl_cont:setAnchorPoint(0,1)
	local height = lbl_cont:getBoundingBox().height
	local width  = lbl_cont:getBoundingBox().width
	return lbl_cont,height
end

function active_layer:string_split(str, s)
	local str_table = {}
	while true do
		local i,j = string.find(str,s)
		if i == nil or j == nil then 
			break
		end
		local temp_str = string.sub(str,1,i - 1)
		if temp_str ~= '' then
			table.insert(str_table, temp_str)
		end
		str = string.sub(str, j + 1, -1)
	end
	if str ~= '' then
		table.insert(str_table, str)
	end
	return str_table
end

function active_layer:str_to_table( str )
	local p_temp_table = {}
	local str_table = {}
	local sort_table = {}
	p_temp_table = self:string_split(str, '<i>')
	return p_temp_table
end

function active_layer:set_content( content )
	local LB = cc.Label:create()
	LB:setSystemFontName(ui_const.UiLableFontType)
	LB:enableOutline(ui_const.UilableStroke,_edgSize)
	LB:setWidth(520)
	LB:setSystemFontSize(_font_size)
	LB:setString(content)	
	local height = LB:getBoundingBox().height
	local width  = LB:getBoundingBox().width

	return height,width
end

function active_layer:time_to_str( time_str )
	local i,j = string.find(time_str,'-')
	local year = string.sub(time_str,1,i - 1)
	time_str 	= string.sub(time_str,i + 1,-1)
	i,j 	= string.find(time_str,'-')
	local month = string.sub(time_str,1,i - 1)
	time_str 	= string.sub(time_str,i + 1,-1)
	i,j 	= string.find(time_str,'-')
	local day	= string.sub(time_str,1,i - 1)
	local hour	= string.sub(time_str,i + 1,-1)
	return year,month,day,hour
end

function active_layer:updata_content_list( content_type, id )
	self:reset_list_event( self.content_list )
	self.content_list:removeAllItems()
	self.content_list:jumpToTop()
	local read_str = ''
	if content_type == 1 then
		read_str 	= '10' .. id
		self.active_title:setString(self.notice_table[id].title)
		local content_panel			= self:get_widget('content_panel'):clone()
		local active_content_title	= content_panel:getChildByName('active_content_title')
		--local content_table,sort_table		= self:str_to_table( self.notice_table[id].content )
		local content_table		= self:str_to_table( self.notice_table[id].content )
		local panel_width 	= content_panel:getLayoutSize().width
		local p_y = 0
	
		for j, value in pairs(content_table) do

			local item,item_height = self:add_content(value, panel_width, Color.White, _font_size)
			item:setPosition(0,-(p_y - item_height/2))
			
			content_panel:addChild(item)
			
			p_y	= p_y + item_height + 5
		end
		active_content_title:setVisible(false)
		content_panel:setContentSize(cc.size(520, p_y))
		content_panel:ignoreAnchorPointForPosition(true)
		self.content_list:pushBackCustomItem( content_panel )
	else
		read_str 	= '20' .. id
		self.active_title:setString(self.active_table[id].title)
		--活动时间
		local time_panel	= self:get_widget('time_panel'):clone( )
		local active_time_title	= time_panel:getChildByName('active_time_title')
		local active_time 		= time_panel:getChildByName('active_time')
		active_time_title:setString(locale.get_value('active_time_title'))
		local year,month,day,hour 	= self:time_to_str(self.active_table[id].start_time)
		local year_e,month_e,day_e,hour_e	= self:time_to_str(self.active_table[id].end_time)
		local time_t 	= {['year'] = year,['month'] = month,['day'] = day,['hour'] = hour,['year_e'] = year_e,['month_e'] = month_e,['day_e'] = day_e,['hour_e'] = hour_e}
		active_time:setString(locale.get_value_with_var('active_time',time_t))
		time_panel:ignoreAnchorPointForPosition(true)
		self.content_list:pushBackCustomItem( time_panel )

		--活动内容
		local content_panel			= self:get_widget('content_panel'):clone()
		local active_content_title	= content_panel:getChildByName('active_content_title')
		--local active_content,height,width		= self:set_content(self.active_table[id].content)
		local item_table	= self:string_split(self.active_table[id].content,'<i>')
		local p_y = 0
		for j, value in pairs(item_table) do
			local item,item_height = self:add_content(value, panel_width, Color.White, _font_size)
			item:setPosition(0,-(p_y + 31 ))
			
			content_panel:addChild(item)
		
			p_y	= p_y + item_height + 5
		end
		active_content_title:setString(locale.get_value('active_content_title'))
		
		content_panel:setContentSize(cc.size(width, p_y + 51))
		content_panel:ignoreAnchorPointForPosition(true)
		self.content_list:pushBackCustomItem( content_panel )		
	end
	if self.read_table[read_str] == nil then
		self.read_table[read_str] = 1
		self:reload()
	end
end

function active_layer:close_button_event( sender,eventtype)
	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  
	elseif eventtype == ccui.TouchEventType.ended then
		self.cc:setVisible(false)
		local read_str = ''
		for i,v in pairs(self.read_table) do
			read_str 	= read_str .. i .. '|'
		end
		cc.UserDefault:getInstance():setStringForKey("had_read",read_str)
		--cc.UserDefault:getInstance():setStringForKey("had_read",'')
		anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_UP_ANIM,false)
		self.is_remove = true
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end

function active_layer:set_touch_handler(btn,content_type,id)
	local function button_event(sender, eventtype)
		if eventtype == ccui.TouchEventType.began then

		elseif eventtype == ccui.TouchEventType.moved then

		elseif eventtype == ccui.TouchEventType.ended then
			self:updata_content_list(content_type, id)
		end
	end
	--btn:addTouchEventListener( button_event )
	self:set_widget_handler( btn, button_event, content_type .. '_' .. id )
end

function active_layer:reload()
	super(active_layer,self).reload()
	self:updata_active_list( )
end

function active_layer:release( )
	self.is_remove	= false
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( icon_p )
	super(active_layer,self).release()
end
