local ui_const 				= import( 'ui.ui_const' )
local layer					= import( 'world.layer' )

item_tips_layer = lua_class( 'item_tips_layer' , layer.ui_layer )
local _json_path = 'gui/global/ui_item_tips.ExportJson'
local renwu_set = 'icon/renwu.plist'
local iicon_set = 'icon/item_icons.plist'
local eicon_set = 'icon/e_icons.plist'
local soul_set = 'icon/soul_icons.plist'
local load_texture_type = TextureTypePLIST

function item_tips_layer:_init(  )
	super(item_tips_layer,self)._init(_json_path,true)
	
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( renwu_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( iicon_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( eicon_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( soul_set )
	self.is_remove = false 

	self.item_id = nil
	self:init_widget()
	
	self.can_touch = false
	self:set_is_gray(false)
end

function item_tips_layer:init_widget(  )
	self.item_img = self:get_widget('item_img')
	self.bottom_bg = self:get_widget('Image_2')
	self.tips_panel = self:get_widget('tips_panel')
	self.tips_bg = self:get_widget('Image_3')
	self.lbl_item_name = self:get_widget('lbl_item_name')
	self.lbl_item_level = self:get_widget('lbl_item_level')
	self.lbl_gold = self:get_widget('lbl_gold')
	self.gold_img = self:get_widget('gold_img')
	self.lbl_item_level:setVisible(false)
	self.tips_bg:setScale9Enabled(true)
	self.bottom_bg:setScale9Enabled(true)
	self.bef_tips_h = self.tips_bg:getContentSize().height
	self.bef_bottom_h = self.bottom_bg:getContentSize().height
	self.bef_bottom_w = self.bottom_bg:getContentSize().width
end

function item_tips_layer:set_content( id  )
	self:set_item_id(id)
	local item_type = data.item_id[id]
	local icon = data[item_type][id].icon
	local color = data[item_type][id].color
	local name = data[item_type][id].name
	local tips = data[item_type][id].tips
	local price = data[item_type][id].price

	self:set_item_name(name)
	self:set_item_img(icon)
	self:set_item_color(color)
	self:set_lbl_tips(tips)
	self:set_item_price(price)
end

--设置物品id
function item_tips_layer:set_item_id( id )
	self.item_id = id
end

--设置图标
function item_tips_layer:set_item_img( file )
	self.item_img:loadTexture( file ,load_texture_type)
end
--设置颜色
function item_tips_layer:set_item_color( color )

	self.item_img:getChildByName(color):setVisible(true)
end

--设置名字
function item_tips_layer:set_item_name( name )
	self.lbl_item_name:setString(name)
end

--设置价钱
function item_tips_layer:set_item_price( price )
	if price == nil then
		self.lbl_gold:setVisible(false)
		self.gold_img:setVisible(false)
		return
	end
	self.lbl_gold:setString(price)
end

function item_tips_layer:set_position( posx,posy )
	local x = posx-self.bef_bottom_w 
	local y = posy+self.bottom_bg:getBoundingBox().height/2
	self.cc:setPosition(x,y)
end

function item_tips_layer:set_center_position( posx,posy )
	local x = posx-self.bef_bottom_w/2
	local y = posy+self.bottom_bg:getBoundingBox().height/2
	self.cc:setPosition(x,y)
end

function item_tips_layer:play_up_anim(  )
	local function callFunc(  )
		self.can_touch = true
	end
	local callFuncObj=cc.CallFunc:create(callFunc)
	self:play_action('ui_item_tips.ExportJson','up',callFuncObj)
end

function item_tips_layer:play_down_anim(  )
	local function callFunc(  )
		self.is_remove = true
	end
	local callFuncObj=cc.CallFunc:create(callFunc)
	self:play_action('ui_item_tips.ExportJson','down',callFuncObj)
end

function item_tips_layer:set_lbl_tips( tips )
	local lbl = cc.Label:create()
	lbl:setSystemFontName(ui_const.UiLableFontType)
	lbl:enableOutline(ui_const.UilableStroke,1)
	lbl:setWidth(300)
	lbl:setSystemFontSize(22)
	lbl:setString(tips)	
	lbl:setAnchorPoint(0,1)
	lbl:setPositionX(15)
	lbl:setColor(Color.Dark_Yellow)
	self.tips_panel:addChild(lbl,2)
	local height = lbl:getBoundingBox().height
	local width  = lbl:getBoundingBox().width
	local tips_w = self.tips_bg:getContentSize().width
	local botton_w = self.bottom_bg:getContentSize().width
	self.tips_bg:setContentSize(tips_w,height)
	local bottom_h = height-self.bef_tips_h
	self.bottom_bg:setContentSize(botton_w,self.bef_bottom_h+bottom_h)
end

function item_tips_layer:set_remove(  )
	self.is_remove = true
end

function item_tips_layer:touch_begin_event( touch, event )
	
	if self.can_touch == true then
		self.can_touch = false
		self:play_down_anim()
	end

end

function item_tips_layer:reload(  )
	-- body
end

function item_tips_layer:release(  )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( renwu_set )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( eicon_set )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( iicon_set )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( soul_set )
	super(item_tips_layer,self).release()
	self.is_remove 		= false
end