local layer				= import( 'world.layer' )
local ui_const			= import( 'ui.ui_const' )
local locale			= import( 'utils.locale' )
local model				= import( 'model.interface' )

buy_info = lua_class('buy_info',layer.ui_layer)

local eicon_set = 'icon/e_icons.plist'
local iicon_set = 'icon/item_icons.plist'
local isoul     = 'icon/soul_icons.plist'
local mall_icon	= 'icon/mall_icon.plist'
local common	= 'icon/common.plist'

function buy_info:_init( )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( eicon_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( iicon_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( isoul )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( mall_icon )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( common )
	super(buy_info,self)._init('gui/main/ui_dhshop_2.ExportJson',true)
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width / 2, VisibleSize.height / 2)
	self.good_icon	= self:get_widget('good_icon')
	self.good_name	= self:get_widget('good_name')
	self.good_desc	= self:get_widget('good_desc')
	self.buy_num	= self:get_widget('buy_num')
	self.money_cost	= self:get_widget('money_cost')
	self.proxy_icon	= self:get_widget('proxy_icon')
	self.buy_btn	= self:get_widget('buy_btn')
	self:set_handler('buy_btn',self.buy_btn_event)
	self:set_handler('close_btn',self.close_btn_event)
	self.is_remove	= false
end

function buy_info:init_info( good )
	self.good_name:setString( good.item_name )
	self.buy_num:setString(tostring(good.sell_num))
	self.good_desc:setString(good.good_desc)
	self.money_cost:setString(tostring(good.price))
	self:set_good_id( good.id )
	--self.proxy_icon:loadTexture(route, load_texture_type)
	--self.good_icon:loadTexture( route, load_texture_type)
end

function buy_info:set_good_id( id )
	self.good_id = id
end

function buy_info:set_good_icon(route,t)
	if t ~= nil then
		self.good_icon:loadTexture( route, t )
	else
		self.good_icon:loadTexture( route )
	end
end

function buy_info:set_good_name( name )
	self.good_name:setString(name)
end

function buy_info:set_buy_num(num)
	self.buy_num:setString(tostring(num))
end

function buy_info:set_good_desc( desc ) 
	self.good_desc:setString(desc)
end

function buy_info:set_money_cost( cost )
	self.money_cost:setString(tostring(cost))
end

function buy_info:set_proxy_icon( route,t )
	self.proxy_icon:loadTexture(route, t )
	self.proxy_icon:setScale(0.5)
end

--播放弹出动画
function buy_info:play_up_anim(  )

	self:play_action('ui_dhshop_2.ExportJson','up')
end

--播放收起动画
function buy_info:play_down_anim( )
	local function callFunc(  )
		self.is_remove = true
	end
	local callFuncObj=cc.CallFunc:create(callFunc)
	self:play_action('ui_dhshop_2.ExportJson','down',callFuncObj)
end

function buy_info:buy_btn_event( sender,eventtype )
	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  
	elseif eventtype == ccui.TouchEventType.ended then
		self:play_down_anim( )
		server.buy_from_exchange_mall( self.good_id )
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end

function buy_info:close_btn_event( sender, eventtype )
	if eventtype == ccui.TouchEventType.began then

	elseif eventtype == ccui.TouchEventType.moved then

	elseif eventtype == ccui.TouchEventType.ended then
		self:play_down_anim()
	elseif eventtype == ccui.TouchEventType.canceled then

	end
end


function buy_info:release(  )
	self.is_remove	= false
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( eicon_set )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( iicon_set )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( isoul )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( mall_icon )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( common )
	super(buy_info,self).release()
end