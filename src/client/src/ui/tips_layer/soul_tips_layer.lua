local ui_const 				= import( 'ui.ui_const' )
local layer					= import( 'world.layer' )

soul_tips_layer = lua_class( 'soul_tips_layer' , layer.ui_layer )
local _json_path = 'gui/global/ui_soul_tips.ExportJson'
local sicon_set = 'icon/s_icons.plist'
local load_texture_type = TextureTypePLIST
local boss_type = 3
function soul_tips_layer:_init(  )
	super(soul_tips_layer,self)._init(_json_path,true)

	cc.SpriteFrameCache: getInstance(): addSpriteFrames( sicon_set )

	self.is_remove = false 
	self.can_touch = false
	self.soul_id = nil
	self:init_widget()
	
	self:set_is_gray(false)
end

function soul_tips_layer:init_widget(  )
	self.soul_img = self:get_widget('soul_img')
	self.bottom_bg = self:get_widget('Image_2')
	self.tips_panel = self:get_widget('Panel_14')
	self.tips_bg = self:get_widget('Image_3')
	self.lbl_soul_name = self:get_widget('lbl_soul_name')
	self.lbl_soul_level = self:get_widget('lbl_soul_level')
	self.lbl_boss = self:get_widget('lbl_boss')
	self.tips_bg:setScale9Enabled(true)
	self.bottom_bg:setScale9Enabled(true)
	self.bef_tips_h = self.tips_bg:getContentSize().height
	self.bef_bottom_h = self.bottom_bg:getContentSize().height
	self.bef_bottom_w = self.bottom_bg:getContentSize().width

end

function soul_tips_layer:set_content( id ,battle_id )
	self:set_item_id(id)
	local icon = data.monster_model[id].icon
	local color = data.monster_model[id].color
	local name = data.monster_model[id].name
	local tips = data.monster_model[id].tips
	local level = data.fuben[battle_id].monster_level
	local element_type = data.monster_model[id].element_type
	local monster_type = data.monster_model[id].type
	self:set_item_name(name)
	self:set_level(level)
	self:set_item_img(icon)
	self:set_lbl_tips(tips)
	self:set_pro_img(element_type)
	self:set_boss(monster_type)
end

--设置物品id
function soul_tips_layer:set_item_id( id )
	self.item_id = id
end

--设置图标
function soul_tips_layer:set_item_img( file )
	self.soul_img:loadTexture( file ,load_texture_type)
end
--设置怪物类型
function soul_tips_layer:set_boss( m_type )
	if m_type ~= boss_type then
		self.lbl_boss:setVisible(false)
	end
end

--设置名字
function soul_tips_layer:set_item_name( name )
	self.lbl_soul_name:setString(name)
	--self.lbl_soul_name:setColor(Color[color])
end

function soul_tips_layer:set_level(level)
	self.lbl_soul_level:setString('lv: '.. level)
end

function soul_tips_layer:set_pro_img( element_type )
	self.soul_img:getChildByName(element_type..'_img'):setVisible(true)
end
--设置在左边
function soul_tips_layer:set_position( posx,posy )
	local x = posx-self.bef_bottom_w 
	local y = posy+self.bottom_bg:getBoundingBox().height/2
	self.cc:setPosition(x,y)
end
--设置屏幕中心
function soul_tips_layer:set_center_position( posx,posy )
	local x = posx-self.bef_bottom_w/2
	local y = posy+self.bottom_bg:getBoundingBox().height/2
	self.cc:setPosition(x,y)
end

function soul_tips_layer:set_lbl_tips( tips )
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

function soul_tips_layer:play_up_anim(  )
	local function callFunc(  )
		self.can_touch = true
	end
	local callFuncObj=cc.CallFunc:create(callFunc)
	self:play_action('ui_soul_tips.ExportJson','up',callFuncObj)
end

function soul_tips_layer:play_down_anim(  )
	local function callFunc(  )
		self.is_remove = true
	end
	local callFuncObj=cc.CallFunc:create(callFunc)
	self:play_action('ui_soul_tips.ExportJson','down',callFuncObj)
end

function soul_tips_layer:set_remove(  )
	self.is_remove = true
end

function soul_tips_layer:touch_begin_event( touch, event )
	
	if self.can_touch == true then
		self.can_touch = false
		self:play_down_anim()
	end

end

function soul_tips_layer:reload(  )
	-- body
end

function soul_tips_layer:release(  )

	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( sicon_set )

	super(soul_tips_layer,self).release()
	self.is_remove 		= false
end