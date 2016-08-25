local layer 				= import( 'world.layer' )
local combat_conf			= import( 'ui.market_layer.market_ui_conf' )
local market_cell			= import( 'ui.market_layer.market_cell')
local model 				= import( 'model.interface' )
local anim_trigger 			= import( 'ui.main_ui.anim_trigger')
local navigation_bar		= import( 'ui.equip_sys_layer.navigation_bar' ) 
local locale				= import( 'utils.locale')
local ui_const				= import( 'ui.ui_const' )


market_layer = lua_class('market_layer',layer.ui_layer)

local _json = 'gui/main/ui_market.ExportJson'
local imall_set = 'icon/mall_icon.plist'
local load_texture_type = TextureTypePLIST
local _font_size = 25

function market_layer:_init(  )
	super(market_layer,self)._init(_json,true)
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2,VisibleSize.height/2)
	self:init_component()
	self.barbg = self:get_widget( 'barbg' )
	self.bar = self:get_widget( 'bar' )
	self.bar:setScale9Enabled(true)
	self.navigation_bar = navigation_bar.navigation_bar(self.bar , self.barbg, self.list)
	self.p_vip	= self:get_widget('p_vip')
	self.left_btn	= self.p_vip:getChildByName('left_btn')
	self.right_btn	= self.p_vip:getChildByName('right_btn')
	self.vip_list = self.p_vip:getChildByName('list')

	self:set_vip()
	self:jump_to_layer( 1 )
	self.close_button = self:get_widget('close_button')
	self:set_handler('close_button',self.close_button_event)
	self:set_vip_touch_handler(self.left_btn,1)
	self:set_vip_touch_handler(self.right_btn,2)
end

function market_layer:init_component(  )
	self.player = model.get_player()
	self.list = self:get_widget('list')
	self.vip_bar = self:get_widget('vip_bar')		-- vip经验条
	self.bar = self:get_widget('bar')
	self.lbl_vip_lv = self:get_widget('lbl_vip_lv')
	self.lbl_vip_next_lv = self:get_widget('lbl_vip_next_lv')
	self.lbl_gem 		 = self:get_widget('lbl_gem')
	self.lbl_max_lv		 = self:get_widget('lbl_max_lv')
	self.lbl_tip		 = self:get_widget('lbl_tip')
	self.diamond_img	 = self:get_widget('diamond_img')
	self.lbl_grow		 = self:get_widget('lbl_grow')
	self.vip_img		 = self:get_widget('vip_img')

	self.tq_button	= self:get_widget('tq_button')
	self.tq_btn_state = 0
	self:set_tq_touch_handler(self.tq_button, self.player:get_vip().lv)

	for _, name in pairs(combat_conf.market_ui_label) do
		self['lbl_' .. name] = self:get_widget('lbl_' .. name)
		local temp_label = self['lbl_' .. name]
		if temp_label ~= nil then
			-- if locale.get_value('prof_' .. name) ~= ' ' then
			--  	temp_label:setString(locale.get_value('prof_' .. name))		--如果传入的name在languane是没有的，就会返回以个空字符串
			-- end
		end
	end
end

function market_layer:getIntPart( x )
	-- body
	if x <= 0 then
		return math.ceil(x)
	end

	if math.ceil(x) == x then
		x = math.ceil(x)
	else
		x = math.ceil(x) - 1
	end
	return x
end
function market_layer:reset_list_event(  )
	local function scrollViewEvent(sender, evenType)

	end
	self.list:addEventListener(scrollViewEvent)
end

function market_layer:updata_list(  )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( imall_set )
	self:reset_list_event( )
	self.list:removeAllChildren()
	self.list:jumpToTop()

	--默认显示并选中第一个物品的信息

	self.list_count	= 0
	self.good_table	= data.mall
	self.keys	= {}
	self.keys_recommend	= {}
	for i, v in pairs(data.mall) do
		local good_id_str = tostring( v.id )
		if v.can_buy_count == nil or self.player.mall[good_id_str] == nil or self.player.mall[good_id_str] < v.can_buy_count then
	 		self.list_count	= self.list_count + 1
	 		if v.recommend == 1 then 
				table.insert(self.keys_recommend,i)
			else 
				table.insert(self.keys,i)
			end
		end
	end

	local function cmp(a,b)
		return a < b
	end
	table.sort(self.keys,cmp)
	table.sort(self.keys_recommend,cmp)
	for i, v in pairs(self.keys_recommend) do
		table.insert(self.keys, i , v)
	end
	--默认高度为5行
	self.row_count=3
	local l_count = self:getIntPart(self.list_count/2)
	local ls_count = self.list_count/2
	local compare_count = 0
	if ls_count>l_count then
		if self.row_count <= ls_count then
			self.row_count = self:getIntPart(ls_count+1) 
		end
	else
		if self.row_count <= self:getIntPart(self.list_count/2) then
			self.row_count = self:getIntPart(self.list_count/2)
		end
	end
	--计算有多少格子 
	local count = 0
	local height = 0

	local sum_h
	local sum_l_h
	self.cell_hight = 132
	if self.row_count > 3 then
		sum_h = 142*self.row_count-self.cell_hight/2
		sum_l_h = 142*self.row_count
	else
		sum_h = self.list:getContentSize().height-self.cell_hight/2
		sum_l_h = self.list:getContentSize().height
	end
	local num = 0
	if 8 < self.list_count then
		num = 8
	else
		num = self.list_count
	end
 	for i=1,num do

		count = count + 1
		local l_panel = market_cell.market_cell( self )
		local l_cell = l_panel:get_cell()
		local good 	 = self.good_table[self.keys[i]]
		l_cell:ignoreAnchorPointForPosition(true)
		l_panel:set_good_name( good.name )
		l_panel:set_good_price( locale.get_value('money_type') .. good.price)
		l_panel:set_good_title( good.title)
		l_panel:set_good_img(good.icon_route,load_texture_type)
		if good.good_type == 1 then 
			if self.player.mc_left_day > 0 then
				l_panel:set_good_title( locale.get_value_with_var( 'month_card',{times = self.player.mc_left_day} ) )
			end
		end
		if count%2 == 1 then
			if self.row_count > 3 then
					local y = sum_h-10
					l_cell:setPosition(200,y)
			else
				local y = sum_h-10
					l_cell:setPosition(200,y)
			end
		elseif count%2 == 0 then
			if self.row_count > 3 then
					local y = sum_h-10
					l_cell:setPosition(570,y)
					sum_h = sum_h-self.cell_hight-10
			else
				local y = sum_h-10
					l_cell:setPosition(570,y)
					sum_h = sum_h-self.cell_hight-10
			end
		end
		if good.recommend == 1 then
			l_panel:set_recommend(true)
		else
			l_panel:set_recommend(false)
		end
		self:set_touch_handler(l_panel:get_btn(),good.id)
		self.list:addChild(l_cell)
		l_cell:setTag(count)
	end
	self.sum_h = sum_h
	self.list:setInnerContainerSize(cc.size(794,sum_l_h))
	-----导航条思路做法------------
	self.navigation_bar:init_bar(6,self.list_count,self.list:getContentSize().height)

	local function tick()
		--检查是否移除ui
		self:second_creat()
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.tick)
	end
	if num > 8 then 
		self.tick = cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick, 0.01, false)
	end
end

function market_layer:second_creat(  )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( imall_set )
	local count = 8
	for i=9,self.list_count do

		count = count + 1
		local l_panel = market_cell.market_cell( self )
		local l_cell = l_panel:get_cell()
		local good   = self.good_table[self.keys[i]]
		l_cell:ignoreAnchorPointForPosition(true)
		l_panel:set_good_name( good.name )
		l_panel:set_good_price( locale.get_value('money_type') .. good.price)
		l_panel:set_good_title( good.title)
		l_panel:set_good_img(good.icon_route,load_texture_type)
		if good.good_type == 1 then 
			if self.player.mc_left_day > 0 then
					l_panel:set_good_title( locale.get_value_with_var( 'month_card',{times = self.player.mc_left_day} ) )
			end
		end
		if count%2 == 1 then
			if self.row_count > 3 then
					local y = self.sum_h-10
					l_cell:setPosition(200,y)
			else
				local y = self.sum_h-10
					l_cell:setPosition(200,y)
			end
		elseif count%2 == 0 then
			if self.row_count > 3 then
					local y = self.sum_h-10
					l_cell:setPosition(570,y)
					self.sum_h = self.sum_h-self.cell_hight-10
			else
				local y = self.sum_h-10
					l_cell:setPosition(570,y)
					self.sum_h = self.sum_h-self.cell_hight-10
			end
		end
		if good.recommend == 1 then
			l_panel:set_recommend(true)
		else
			l_panel:set_recommend(false)
		end
		self:set_touch_handler(l_panel:get_btn(),good.id)
		self.list:addChild(l_cell)
	end
end

function market_layer:set_vip()
	if data.vip[self.player.vip.lv + 2] ~= nil then
		self:set_vip_bar( self.player.vip.diamond - data.vip[self.player.vip.lv + 1].sum_diamond)
		self:set_cur_vplv( self.player.vip.lv )
		self:set_next_vplv( self.player.vip.lv + 1)
		local need_diamond = data.vip[self.player.vip.lv + 2].sum_diamond - self.player.vip.diamond
		self:set_need_diamond( need_diamond )
	else
		self:set_cur_vplv( self.player.vip.lv )
		self:set_max_lv()
	end
end

function market_layer:set_need_diamond( num )
	self.lbl_gem:setString(tostring(num))
end
--设置当前vip等级
function market_layer:set_cur_vplv( lv )
	self.lbl_vip_lv:setString(''..lv)
end

function market_layer:set_max_lv()
	self.lbl_max_lv:setString(locale.get_value('highest_lv'))
	self.lbl_tip:setVisible(false)
	self.lbl_grow:setVisible(false)
	self.diamond_img:setVisible(false)
	self.lbl_vip_next_lv:setVisible(false)
	self.lbl_gem:setVisible(false)
	self.vip_img:setVisible(false)
	self.vip_bar:setPositionX(self.vip_bar:getContentSize().width)

end

--设置下个vip等级
function market_layer:set_next_vplv( lv )
	self.lbl_vip_next_lv:setString(''..lv)
end

function market_layer:set_vip_bar( num )
	local need_daimond = data.vip[self.player.vip.lv + 2].sum_diamond - data.vip[self.player.vip.lv + 1].sum_diamond
	local perc = num/need_daimond
	if perc>=1 then
		perc = 1
	end 
	self.vip_bar:setPositionX(self.vip_bar:getContentSize().width*perc)
end

function market_layer:set_touch_handler(btn,good_id)
	local function button_event(sender,eventType)
		if eventType == ccui.TouchEventType.began then

		elseif eventType == ccui.TouchEventType.moved then

		elseif eventType == ccui.TouchEventType.ended then
			server.buy_from_mall(good_id)
		end
	end
	btn:addTouchEventListener(button_event)
end

--关闭按钮
function market_layer:close_button_event( sender,eventtype )

	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  
	elseif eventtype == ccui.TouchEventType.ended then
		self.cc:setVisible(false)

		anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_UP_ANIM,false)
		self.is_remove = true
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end

function market_layer:set_tq_touch_handler(btn, lv)
	local function button_event(sender, eventtype)
		if eventtype == ccui.TouchEventType.began then

		elseif eventtype == ccui.TouchEventType.moved then

		elseif eventtype == ccui.TouchEventType.ended then
			local state 
			if self.tq_btn_state == 1 then
				state	= 2
			elseif self.tq_btn_state == 2 then
				state	= 1
			end
			self:jump_to_layer(state)
		elseif eventtype == ccui.TouchEventType.canceled then

		end
	end
	btn:addTouchEventListener(button_event)
end

function market_layer:set_vip_touch_handler(btn,type)
	local function button_event(sender, eventtype)
		if eventtype == ccui.TouchEventType.began then

		elseif eventtype == ccui.TouchEventType.moved then

		elseif eventtype == ccui.TouchEventType.ended then

			local vip_lv 		= self.show_vip_lv
			if type == 1 then
				self:vip_content_show( vip_lv - 1 )
			elseif type == 2 then
				self:vip_content_show( vip_lv + 1 )
			end
		elseif eventtype == ccui.TouchEventType.canceled then

		end
	end
	btn:addTouchEventListener(button_event)
end

function market_layer:jump_to_layer( state )
	local lbl_tq_button = self.tq_button:getChildByName('lbl_tq_button')
	--local women_img		= self:get_widget('Image_25')
	local women_img_item		= self:get_widget('Image_26')
	local vip_lv 		= self.player:get_vip().lv
	if self.tq_btn_state ~= state then
		self.tq_btn_state = state
		if self.tq_btn_state == 2 then
			lbl_tq_button:setString('商城')
		--	women_img:setVisible(false)
		--	women_img_item:setVisible(false)
			self.p_vip:setVisible(true)
			self.list:setVisible(false)
			self:vip_content_show( vip_lv )
		elseif self.tq_btn_state == 1 then
			self.p_vip:setVisible(false)
			lbl_tq_button:setString('vip特权')
		--	women_img:setVisible(false)
		--	women_img_item:setVisible(false)
			self.list:setVisible(true)
			self:updata_list()
		end
	end 
end

function market_layer:vip_content_show( lv )
	if lv == 0 then
		lv = 1
	end
	self.show_vip_lv 	= lv
	local lbl_vip_lv 	= self.p_vip:getChildByName('lbl_vip_lv')
	lbl_vip_lv:setString(tostring(lv))
	local lbl_pre_lv	=	self.left_btn:getChildByName('lbl_pre_lv')
	local lbl_next_lv   =	self.right_btn:getChildByName('lbl_next_lv')
	local content 		= 	data.vip[lv].privilege
	if self.show_vip_lv == 1 then
		self.left_btn:setVisible(false)
	else
		self.left_btn:setVisible(true)
		lbl_pre_lv:setString(tostring(lv - 1))
	end
	if data.vip[lv + 2] == nil then
		self.right_btn:setVisible(false)
	else
		self.right_btn:setVisible(true)
		lbl_next_lv:setString(tostring(lv + 1))
	end
	self:set_vip_content( content )
end

function market_layer:set_vip_content( str )
	self.vip_list:removeAllItems()
	local content_table = self:str_to_table(str)
	local content_panel		= self:get_widget('content_panel'):clone()
	local panel_width 	= self.vip_list:getLayoutSize().width
	local p_y = 0
	for i, value in pairs(content_table) do
		local item,item_height = self:add_content(value, panel_width, Color.White, _font_size)
		item:setPosition(-self.vip_list:getLayoutSize().width/2 + _font_size / 2,-(p_y - item_height/2  ))
			
		content_panel:addChild(item)
		p_y	= p_y + item_height + 5
	end
	content_panel:ignoreAnchorPointForPosition(true)
	content_panel:setContentSize(cc.size(self.vip_list:getLayoutSize().width, p_y + 51))
	
	self.vip_list:pushBackCustomItem(content_panel)
	self.vip_list:jumpToTop()
end


function market_layer:add_content( str, panel_width, color , font_size)

	local fuben_str = ''
	local _richText	= ccui.RichText:create( )
	_richText:enableOutline(ui_const.UilableStroke,_edgSize)
	_richText:ignoreContentAdaptWithSize(false)
	_richText:setContentSize(cc.size(panel_width,0))
	while true do
		local i,j = string.find(str,'{')

		if i == nil or j == nil then
			break
		end
		local m,n = string.find(str, '}')
		if m == nil or n == nil then 
			break
		end
		local temp_str = string.sub(str,1,i - 1)
		local change_str	= string.sub(str, i + 1, m - 1)
		str 			= string.sub(str, m + 1, -1)
		local i = string.find(change_str,'<')
		local j = string.find(change_str,'>')
		if i == nil  or j == nil then 
			break
		end
		local lbl_color = string.sub(change_str,i + 1, j - 1)
		local true_change_str = string.sub(change_str,1,i - 1)
		fuben_str = fuben_str .. temp_str .. true_change_str
		local rt_temp_str = ccui.RichElementText:create(1, color, 255,temp_str,  ui_const.UiLableFontType,font_size)
		local rt_change_str = ccui.RichElementText:create(1, Color[lbl_color], 255,true_change_str,  ui_const.UiLableFontType,_font_size)
		_richText:pushBackElement(rt_temp_str)
		_richText:pushBackElement(rt_change_str)
	end
	local title = ccui.RichElementText:create(1, color, 255,str,  ui_const.UiLableFontType,_font_size)
	fuben_str = fuben_str .. str
	_richText:pushBackElement(title)
	_richText:setAnchorPoint(cc.p(0,1))
	local height, width = self:set_content( fuben_str )
	_richText:setContentSize(cc.size(width,height))
	return _richText,height
end

function market_layer:set_content( content )
	local LB = cc.Label:create()
	LB:setSystemFontName(ui_const.UiLableFontType)
	LB:enableOutline(ui_const.UilableStroke,_edgSize)
	LB:setWidth(460)
	LB:setSystemFontSize(_font_size)
	LB:setString(content)	
	local height = LB:getBoundingBox().height
	local width  = LB:getBoundingBox().width

	return height,width
end

function market_layer:string_split(str, s)
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

function market_layer:str_to_table( str )
	local p_temp_table = {}
	local str_table = {}
	local sort_table = {}
	p_temp_table = self:string_split(str, '<i>')
	return p_temp_table
end


function market_layer:reload( )
	super(market_layer,self).reload()
	self:set_vip()
	self:jump_to_layer( self.tq_btn_state )
end

function market_layer:release( )
	self.is_remove	= false
	super(market_layer,self).release()
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( imall_set )
end