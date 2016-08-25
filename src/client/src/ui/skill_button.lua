local command_mgr		= import( 'game_logic.command_mgr' )
local command			= import( 'game_logic.command' )
local interface			= import( 'model.interface' )

skill_button 	= lua_class('skill_button')

local load_texture_type = TextureTypePLIST


local _size				= cc.Director:getInstance():getVisibleSize()	--屏幕大小
local _jump_button		= nil
local _player 			= nil
local sicon_set 		= 'icon/s_icons.plist'

function skill_button:_init( widget, idx, skill )
	-- body
	self.skill = skill
	self.precent 			= 0			--设置进度百分值
	cc.SpriteFrameCache:getInstance():addSpriteFrames( sicon_set )
	local btn = widget:getChildByName('skill_button_'..idx)
	btn:setVisible(true)
	-- btn:loadTextureNormal(skill.data.icon)
	-- --btn:loadTexturePressed(skill.data.icon)
	-- btn:loadTextureDisabled(skill.data.icon)
	local img = ccui.ImageView:create()
	img:loadTexture( skill.data.icon ,load_texture_type)
	img:setPosition( 97/2, 97/2 )
	img:setAnchorPoint( 0.5, 0.5 )
	btn:addChild(img,0,10)
	--战魂技能
	local bar = btn:getChildByName('skill_bar_'..idx)
	
	if self.skill:get_cd() ~= nil then
		bar:setVisible(true)
	end
	bar:setPercent( 0 )
	local function touchEvent(sender,eventType)
		self:launch_skill_button(sender,eventType)
	end

	btn:addTouchEventListener(touchEvent)
	self.bar = bar
	self.btn = btn
end

function skill_button:cast_skill()
	print('cast_skill')
	self.btn:setBright(false)
	if self.skill:get_cd() ~= nil then
		self.precent = 100
	end
	self.bar:setPercent( self.precent )
end

function skill_button:launch_skill_button( sender,eventType )
		print('pressed', self.skill.name)
	-- body
	if eventType == ccui.TouchEventType.began then
		if self.precent <= 0 and self:enough_mana() then
			command_mgr.skill_command(self.skill:get_command())
		end
		
	elseif eventType == ccui.TouchEventType.moved then
			
	elseif eventType == ccui.TouchEventType.ended then

	elseif eventType == ccui.TouchEventType.canceled then
			
	end

end

--设置要操控的对象
function set_player( entity )
	_player = entity
end

function skill_button:enough_mana()
	return _player.combat_attr.mp >= self.skill:get_mana_cost()
end

function skill_button:tick()
	if self:enough_mana() and self.precent <= 0 then
		self.btn:setBright(true)
		self.btn:setColor(cc.c3b(255, 255, 255))
	else
		self.btn:setBright(false)
		self.btn:setColor(cc.c3b(150, 150, 150))
	end

	local cd = self.skill:get_cd()*Fps
	if self.precent > 0 then
		self.precent = self.precent - 100.0/cd
		self.bar:setPercent( self.precent )
	end
end

function skill_button:set_skill_cd(cd)
	if cd == nil then 
		return
	end
	cd = cd * Fps
	local s_cd = self.skill:get_cd()*Fps
	local pas_cd = s_cd - cd
	pas_cd = math.max(pas_cd, 0)
	print(pas_cd)
	self.precent = 100 - pas_cd*100.0/s_cd
	print(self.precent)
	self.bar:setPercent( self.precent )
end

function  skill_button:touch_event( touchPoint )
	-- body
     local istouch=true

            --在按钮以外的范围就返回false，传递给其他层
    if touchPoint.y < self.btn:getPositionY()-self.btn:getLayoutSize().height/2 then
            	istouch=false
            end
    if touchPoint.y >self.btn:getPositionY()+self.btn:getLayoutSize().height/2 then
            	istouch=false

            end
   if touchPoint.x < self.btn:getPositionX()-self.btn:getLayoutSize().width/2 then
            	istouch=false
            end
    if touchPoint.x  > self.btn:getPositionX()+self.btn:getLayoutSize().width/2 then
            	istouch=false
     end

	return istouch

end

--移除触摸事件
function skill_button:remove_touch_event(  )
	-- body
	self.cc:getEventDispatcher():removeAllEventListeners()
end
