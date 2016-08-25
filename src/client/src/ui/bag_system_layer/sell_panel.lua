local layer				= import( 'world.layer' )
local ui_const			= import( 'ui.ui_const' )
local locale			= import( 'utils.locale' )
local model				= import( 'model.interface' )

sell_panel = lua_class('sell_panel', layer.ui_layer)

local eicon_set 	= 'icon/e_icons.plist'
local iicon_set		= 'icon/item_icons.plist'
local isoul			= 'icon/soul_icons.plist'
local mall_icon			= 'icon/mall_icon.plist'
local load_texture_type = TextureTypePLIST

function sell_panel:_init( )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( eicon_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( iicon_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( isoul )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( mall_icon )
	super(sell_panel,self)._init('gui/main/ui_bag_2.ExportJson',true)
	self.widget:ignoreAnchorPointForPosition( true )
	self.widget:setPosition( VisibleSize.width / 2, VisibleSize.height / 2 )
	self.good_img = self:get_widget( 'good_img' )
	self.lbl_good_name 	= self:get_widget( 'lbl_good_name' )
	self.lbl_good_num	= self:get_widget( 'lbl_good_num' )
	self.lbl_good_price	= self:get_widget( 'lbl_good_price' )
	self.lbl_sell_num	= self:get_widget( 'lbl_sell_num' )
	self.lbl_gain_money	= self:get_widget( 'lbl_gain_money' )
	self.sell_btn		= self:get_widget( 'sell_btn' )
	self.add_btn		= self:get_widget( 'add_btn' )
	self.dec_btn		= self:get_widget( 'dec_btn' )
	self.close_btn 		= self:get_widget( 'close_btn' )
	self.player			= model.get_player()

	self:set_handler('close_btn',self.close_button_event)
	self:set_touch_handler( self.dec_btn,1 )
	self:set_touch_handler( self.add_btn,2 )
	self:set_handler('sell_btn',self.sell_button_event)
	self:play_up_anim()

end

function sell_panel:init_data( good_id )
	local good_type = data.item_id[good_id]
	self.good 		= data[good_type][good_id]
	local equip_frags = self.player:get_equip_frags()
	local equip_qh_stones = self.player:get_equip_qh_stones()
	local soul_frags = self.player:get_soul_frag()

	if good_type == 'equip_frag' then
		self.total_num	= equip_frags[self.good.color..'_'..self.good.position]
		
	elseif good_type == 'equip_qh_stone' then
		self.total_num 	= equip_qh_stones[self.good.color]
	
	elseif good_type == 'soul_stone' then
		self.total_num 	= soul_frags[tostring(self.good.soul_id)]

	else
		self.total_num 	= self.player:get_item_number_by_id(good_id)

	end
	self.sell   	= 1
	self:set_good_img(self.good.icon)
	self:set_good_name(self.good.name)
	self:set_good_price(self.good.price)
	self:set_sell_num(self.sell)
	self:set_gain_money( self.sell * self.good.price)
	self:set_good_num(self.total_num)
	self:set_cell_color( self.good_img, self.good.color )
end

function sell_panel:set_good_img( route )
	self.good_img:loadTexture( route,load_texture_type )
end

function sell_panel:set_good_name( name )
	self.lbl_good_name:setString( name )
end


function sell_panel:set_good_num( num )
	self.lbl_good_num:setString( tostring(num) )
end

function sell_panel:set_good_price( price )
	self.lbl_good_price:setString( tostring(price) )
end

function sell_panel:set_sell_num( num )
	self.lbl_sell_num:setString('' .. num .. '/' .. self.total_num)
end

function sell_panel:set_gain_money( money )
	self.lbl_gain_money:setString( tostring(money) )
end

 --播放弹出动画
function sell_panel:play_up_anim( )
	self:play_action('ui_bag_2.ExportJson','up')
end

--播放收起动画
function sell_panel:play_down_anim( )
	local function callFunc()
		self.is_remove = true
	end
	local callFuncObj = cc.CallFunc:create(callFunc)
	self:play_action('ui_bag_2.ExportJson','down',callFuncObj)
end

function sell_panel:sell_button_event(sender, eventtype)
	if eventtype == ccui.TouchEventType.began then 

	elseif eventtype == ccui.TouchEventType.moved then 

	elseif eventtype == ccui.TouchEventType.ended then 
		sender:setTouchEnabled(false)
		self.add_btn:setTouchEnabled(false)
		self.dec_btn:setTouchEnabled(false)
		self.close_btn:setTouchEnabled(false)
		self:play_down_anim( )
		server.sell_item(self.good.id, self.sell)
	elseif eventtype == ccui.TouchEventType.canceled then 

	end 
end

function sell_panel:close_button_event(sender,eventtype)
	if eventtype == ccui.TouchEventType.began then 

	elseif eventtype == ccui.TouchEventType.moved then 

	elseif eventtype == ccui.TouchEventType.ended then 
		self.sell_btn:setTouchEnabled(false)
		self.add_btn:setTouchEnabled(false)
		self.dec_btn:setTouchEnabled(false)
		sender:setTouchEnabled(false)
		self:play_down_anim()
	elseif eventtype == ccui.TouchEventType.canceled then 

	end 
end

function sell_panel:set_touch_handler(btn, type)
	local c_tick
	local function button_event(sender, eventtype)
		
		local function t_tick()
			if type == 1 then
				if self.sell > 1 then 
					self.sell = self.sell - 1
					self:set_sell_num( self.sell )
					self:set_gain_money( self.sell * self.good.price)
				end
			elseif type == 2 then
				if self.sell < self.total_num then 
					self.sell = self.sell + 1
					self:set_sell_num( self.sell )
					self:set_gain_money( self.sell * self.good.price)
				end	
			end
		end
		if eventtype == ccui.TouchEventType.began then
			c_tick  = cc.Director:getInstance():getScheduler():scheduleScriptFunc(t_tick,0.2,false)
		elseif eventtype == ccui.TouchEventType.moved then

		elseif eventtype == ccui.TouchEventType.ended then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(c_tick)
			t_tick()
		elseif eventtype == ccui.TouchEventType.canceled then

		end
	end
	btn:addTouchEventListener(button_event)
end

function sell_panel:set_cell_color( cell,level )
	if level == EnumLevel.White then
		
		cell:getChildByName('green'):setVisible(false)
		cell:getChildByName('blue'):setVisible(false)
		cell:getChildByName('purple'):setVisible(false)
		cell:getChildByName('orange'):setVisible(false)
	elseif level == EnumLevel.Green then
		
		cell:getChildByName('green'):setVisible(true)
		cell:getChildByName('blue'):setVisible(false)
		cell:getChildByName('purple'):setVisible(false)
		cell:getChildByName('orange'):setVisible(false)
	elseif level == EnumLevel.Blue then
		
		cell:getChildByName('green'):setVisible(false)
		cell:getChildByName('blue'):setVisible(true)
		cell:getChildByName('purple'):setVisible(false)
		cell:getChildByName('orange'):setVisible(false)
	elseif level == EnumLevel.Purple then
		
		cell:getChildByName('green'):setVisible(false)
		cell:getChildByName('blue'):setVisible(false)
		cell:getChildByName('purple'):setVisible(true)
		cell:getChildByName('orange'):setVisible(false)
	elseif level == EnumLevel.Orange then
		
		cell:getChildByName('green'):setVisible(false)
		cell:getChildByName('blue'):setVisible(false)
		cell:getChildByName('purple'):setVisible(false)
		cell:getChildByName('orange'):setVisible(true)
	else
		--print('没有这个等级')
	end
end

function sell_panel:release( )
	self.is_remove = false
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( eicon_set )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( iicon_set )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( isoul )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( mall_icon )
	super(sell_panel,self).release( )

end