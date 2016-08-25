
local layer 		= import('world.layer')
local model 				= import( 'model.interface' )
local anim_trigger 			= import( 'ui.main_ui.anim_trigger' )
local navigation_bar		= import( 'ui.equip_sys_layer.navigation_bar' ) 
local locale				= import( 'utils.locale' )
local dhshop_cell			= import( 'ui.dhshop_layer.dhshop_cell' )
local mall_const			= import( 'const.exchange_mall_const' )
local ui_mgr				= import( 'ui.ui_mgr' )
local item 					= import( 'model.item' )

dhshop_layer = lua_class('dhshop_layer',layer.ui_layer)

local _json_path = 'gui/main/ui_dhshop.ExportJson'
local eicon_set = 'icon/e_icons.plist'
local iicon_set = 'icon/item_icons.plist'
local isoul     = 'icon/soul_icons.plist'
local mall_icon	= 'icon/mall_icon.plist'
local common	= 'icon/common.plist'
local load_texture_type = TextureTypePLIST

function dhshop_layer:_init(  )
	super(dhshop_layer,self)._init(_json_path,true)
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2,VisibleSize.height/2)
	self.is_remove 		= false
	self.player 		= model.get_player()
	self.proxy_money_data	= data.token_coin
	self.list = self:get_widget('list')
	self.barbg = self:get_widget( 'barbg' )
	self.bar = self:get_widget( 'bar' )
	self.proxy_icon	= self:get_widget( 'proxy_icon' )
	self.proxy_type = self:get_widget( 'proxy_type' )
	self.proxy_money 	= self:get_widget( 'proxy_money' )
	self.bar:setScale9Enabled(true)
	self.navigation_bar = navigation_bar.navigation_bar(self.bar , self.barbg, self.list)
	self.close_button	= self:get_widget('close_button')
	self:set_handler('close_button',self.close_button_event)
	self.up_button		= self:get_widget('up_button')
	self.lbl_reminder	= self:get_widget('lbl_reminder')
	self:update_btn_list()
end


function dhshop_layer:update_btn_list()
	self.shop_btn	= {}
	local btn_name	= ''
	local shop_btn
	local shop_lbl 	= ''
	for i = 1 ,6 do
		btn_name	= 'shop_btn_' .. i
		shop_btn 	= self:get_widget(btn_name)
		shop_btn:setVisible(false)
	end
	for i, v in pairs(mall_const.shop_name) do
		btn_name	= 'shop_btn_' .. i
		shop_btn 	= self:get_widget(btn_name)
		shop_btn:setVisible(true)
		self.shop_btn[btn_name] = shop_btn
		shop_lbl	= shop_btn:getChildByName('lbl_shop_btn')
		shop_lbl:setString(v)
		self:set_shop_touch_handler(shop_btn,i)
	end
end


function dhshop_layer:getIntPart( x )
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
function dhshop_layer:reset_list_event(  )
	local function scrollViewEvent(sender, evenType)

	end
	self.list:addEventListener(scrollViewEvent)
end

function dhshop_layer:update_list( proxy_type )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( eicon_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( iicon_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( isoul )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( mall_icon )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( common )
	self.token_coin = proxy_type
	self:set_up_button_handler(self.up_button,proxy_type)
	local token
	for i,v in pairs(self.proxy_money_data) do
		if v.type == proxy_type then
			token = v
			break
		end
	end
	if token == nil then
		print("不存在该种代币")
		return 
	end
	local temp_refresh_time = { time1 = mall_const.RefreshTime[proxy_type][1],time2 = mall_const.RefreshTime[proxy_type][2]}
	self.lbl_reminder:setString(locale.get_value_with_var('dhshop_reminder',temp_refresh_time))
	self.proxy_icon:loadTexture(token.icon,load_texture_type)
	self.proxy_money:setString(self.player:get_one_proxy_money(proxy_type))
	self.proxy_type:setString(mall_const.num_title[proxy_type])
	self.widget = ccs.GUIReader:getInstance():widgetFromJsonFile(_json_path)
	self:reset_list_event( )
	self.list:removeAllChildren()
	self.list:jumpToTop()


	--默认显示并选中第一个物品的信息

	self.list_count	= 0
	self.temp_keys	= self.player:get_one_exchange_goods(proxy_type)
	self.keys 		= {}
	for i, v in pairs(self.temp_keys) do
		local i_n = tonumber(i)
		self.keys[v.p] = {id = i_n, f = v.f}
	end
	self.good_table	= data.exchange_mall
	for i, v in pairs(self.keys) do
		self.list_count	= self.list_count + 1
	end

	self.row_count=3
	local l_count = self:getIntPart(self.list_count/2)
	local ls_count = self.list_count/2
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

 	for i=1,self.list_count do
 		local position_id_str = tostring(i)
		count = count + 1
		local l_panel = dhshop_cell.dhshop_cell( self )
		local l_cell = l_panel:get_cell()
		--local position_str = tostring(i)
		local good 	 = self.good_table[self.keys[i].id]
		local good_type = data.item_id[good.item_id]
		local icon 		= data[good_type][good.item_id].icon
		l_cell:ignoreAnchorPointForPosition(true)

		if count%2 == 1 then
			if self.row_count > 3 then
					local y = sum_h
					l_cell:setPosition(168,y)
			else
				local y = sum_h
					l_cell:setPosition(168,y)
			end
		elseif count%2 == 0 then
			if self.row_count > 3 then
					local y = sum_h
					l_cell:setPosition(500,y)
					sum_h = sum_h-self.cell_hight
			else
				local y = sum_h
					l_cell:setPosition(500,y)
					sum_h = sum_h-self.cell_hight
			end
		end 
		local good_name = good.item_name
		l_panel:set_item_name( good_name )
		l_panel:set_price( good.price )
		l_panel:set_proxy_icon( token.icon,load_texture_type )
		l_panel:set_item_img( icon, load_texture_type )
		if self.keys[i].f == 1 then
			self:set_gray( l_cell )
			l_panel:get_btn():setTouchEnabled(false)
		end

		self:set_good_touch_handler(l_panel:get_btn(),good,icon,token.icon,self.player)
		self.list:addChild(l_cell)
		l_cell:setTag(count)
	end
	self.sum_h = sum_h
	self.list:setInnerContainerSize(cc.size(794,sum_l_h))
	-----导航条思路做法------------
	self.navigation_bar:init_bar(6,self.list_count,self.list:getContentSize().height)

end

function dhshop_layer:set_proxy_type( proxy_type )
	self.token_coin 	= proxy_type
end

function dhshop_layer:set_gray( v )

	local children = v:getChildren()
	if children and #children > 0 then
			--遍历子对象设置
		for i,v in ipairs(children) do

			if self:can_gray(v:getName()) then
				SpriteSetGray(v:getVirtualRenderer())
				self:set_gray(v)
			end

		end
	end
end

function dhshop_layer:can_gray( name )
	local names = {'lbl_item_name','lbl_price'}
	local temp = true
	for _,v in pairs(names) do
		if name == v then
			temp = false
		end
	end
	return temp
end

function SpriteSetGray(sprite)
	local gl_state = cc.GLProgramState:create(cc.GLProgram:createWithFilenames('shaders/ccShader_PositionTextureColor_noMVP.vert','shaders/ccFilterShader_saturation.frag'))
	gl_state:setUniformFloat('u_saturation', 0.3)
	sprite:setGLProgramState(gl_state)
end

function dhshop_layer:set_shop_touch_handler(btn,proxy_id)
	local function button_event(sender,eventType)
		--print('touch_btn')
		if eventType == ccui.TouchEventType.began then

		elseif eventType == ccui.TouchEventType.moved then

		elseif eventType == ccui.TouchEventType.ended then
			local btn_name	= 'shop_btn_' .. proxy_id
			if self.shop_btn[btn_name] == nil then
				return 
			end
			self.shop_btn[btn_name]:setSelectedState( true )
			for i, v in pairs(self.shop_btn) do		
				v:setSelectedState( false )
			end
			self:update_list( proxy_id )
		end
	end
	btn:addTouchEventListener(button_event)
end

function dhshop_layer:set_good_touch_handler(btn,good,icon,token_icon,player)
	local function button_event(sender,eventType)
		if eventType == ccui.TouchEventType.began then

		elseif eventType == ccui.TouchEventType.moved then

		elseif eventType == ccui.TouchEventType.ended then
			local item_info = ui_mgr.create_ui(import( 'ui.dhshop_layer.buy_info' ), 'buy_info')
			item_info:play_up_anim()
			item_info:init_info( good )
			item_info:set_good_icon( icon,load_texture_type )
			item_info:set_proxy_icon( token_icon,load_texture_type )
		end
	end
	btn:addTouchEventListener(button_event)
end

function dhshop_layer:close_button_event( sender,eventtype )
	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  
	elseif eventtype == ccui.TouchEventType.ended then
		self.cc:setVisible(false)
		anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_UP_ANIM,false)
		self.is_remove = true
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end

function dhshop_layer:set_up_button_handler( btn,proxy_type )
	local function button_event(sender,eventtype)
		if eventtype == ccui.TouchEventType.began then
			
		elseif eventtype == ccui.TouchEventType.moved then
		  
		elseif eventtype == ccui.TouchEventType.ended then
			local msg_ui = ui_mgr.create_ui(import( 'ui.msg_ui.msg_ok_cancel_layer' ), 'msg_ok_cancel_layer')
			local content 	= locale.get_value_with_var('refresh_warning',{cost = mall_const.RefreshMoneyCost[proxy_type]})
			msg_ui:set_tip(content)
			msg_ui:set_font_size(30)
			msg_ui:set_ok_function(self.refresh_shop, {self.token_coin})
		elseif eventtype == ccui.TouchEventType.canceled then
				
		end
	end
	btn:addTouchEventListener(button_event)
end

function dhshop_layer:refresh_shop( )
	server.refresh_by_proxy_money(self[1])
end

function dhshop_layer:reload()
	local btn_name	= 'shop_btn_' .. self.token_coin
	if self.shop_btn[btn_name] == nil then
		return 
	end
	for i, v in pairs(self.shop_btn) do
		v:setSelectedState( false )
	end
	self.shop_btn[btn_name]:setSelectedState( true )
	self:update_list( self.token_coin )
end

function dhshop_layer:release( )
	self.is_remove	= false
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( eicon_set )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( iicon_set )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( isoul )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( mall_icon )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( common )
	super(dhshop_layer,self).release()
end