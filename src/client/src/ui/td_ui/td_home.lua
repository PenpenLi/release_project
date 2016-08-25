local command			= import( 'game_logic.command' )
local interface			= import( 'model.interface' )
local director			= import( 'world.director')

td_home 	= lua_class('td_home')

local load_texture_type = TextureTypePLIST

local _size				= cc.Director:getInstance():getVisibleSize()	--屏幕大小
local _entity 			= nil

function td_home:_init( widget )

	self.precent 			= 0			--设置进度百分值
	self.cd_time			= 20*60		--基地无敌cd
	self.frame_count		= 0

	self.td_home_e			= nil
	self.td_home_max_blood	= nil

	self.btn = widget:getChildByName('td_Button')
	self.btn:setVisible(true)

	self.bar = self.btn:getChildByName('td_Button_Bar')
	self.bar:setVisible(true)
	self.bar:setPercent( self.precent )

	self.blood_view = widget:getChildByName('td_ScrollView')
	self.blood_view_len = self.blood_view:getContentSize().height

	self.blood_Image = self.blood_view:getChildByName('Image_blood')
	self.blood_Image_y = self.blood_Image:getPositionY()

	local function touchEvent(sender,eventType)
		self:launch_skill_button(sender,eventType)
	end
	self.btn:addTouchEventListener(touchEvent)
end

function td_home:set_td_home_info( home_entity )
	self.td_home_e = home_entity
	self.td_home_max_blood = self.td_home_e.combat_attr.max_hp
end

function td_home:launch_skill_button( sender,eventType )

	if eventType == ccui.TouchEventType.began then
		if self.precent <= 0 and self.td_home_e ~= nil then
			self.td_home_e.buff:apply_buff(110, nil, nil) -- 使用基地技能
			self.frame_count = director.get_cur_battle().frame_count
			self.precent =100
		end
	elseif eventType == ccui.TouchEventType.moved then
			
	elseif eventType == ccui.TouchEventType.ended then

	elseif eventType == ccui.TouchEventType.canceled then
			
	end
end

function td_home:tick()
	-- 基地技能cd处理
	if self.precent <= 0 then
		self.btn:setBright(true)
		self.btn:setColor(cc.c3b(255, 255, 255))
	else
		self.btn:setBright(false)
		self.btn:setColor(cc.c3b(150, 150, 150))

		local now_frame_cout = director.get_cur_battle().frame_count
		local now_precent = ((now_frame_cout - self.frame_count) / self.cd_time)*100
		if now_precent > 100 then -- 已过时间
			now_precent = 100
		end
		self.precent = 100 - now_precent
		self.bar:setPercent( self.precent )
	end

	-- 基地血量条
	if self.td_home_e and self.td_home_max_blood then
		local hp = self.td_home_e.combat_attr.hp
		local y = (1 - hp/self.td_home_max_blood)*self.blood_view_len
		self.blood_Image:setPositionY( self.blood_Image_y - y )
	end
end

--移除触摸事件
function td_home:remove_touch_event(  )
	-- body
	self.cc:getEventDispatcher():removeAllEventListeners()
end
