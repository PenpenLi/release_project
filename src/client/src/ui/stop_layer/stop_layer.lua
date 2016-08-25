local layer = import('world.layer')
local ui_const			= import( 'ui.ui_const' )
local avatar			= import( 'model.avatar' )
local item				= import( 'model.item' )
local director			= import( 'world.director' )
local battle_scene 		= import( 'world.battle_scene' )
local operate_cmd 		= import( 'ui.operate_cmd' )
local operate_layer		= import('ui.operate_layer')
local music_mgr			= import( 'world.music_mgr' )
local ui_touch_layer	= import( 'ui.ui_touch_layer' )
stop_layer = lua_class('stop_layer',layer.layer)


function stop_layer:_init( layer )
	-- body
	super(stop_layer,self)._init()
	self.layer = layer
	self:create_skill_panel(  )
	self.istouch = false
	--self:init_skill()
	self.player = avatar.avatar()

end

function stop_layer:create_skill_panel(  )
	-- body
	self.skill_root = ccs.GUIReader:getInstance():widgetFromJsonFile('gui/battle/Ui_Set.ExportJson')
	--self.cc:addChild(self.skill_root,1,1)
	self.skill_root:ignoreAnchorPointForPosition(true)
	self.skill_root:setPosition(VisibleSize.width/2,VisibleSize.height/2)
	---self.skill_root:setTouchEnabled(false)
	--黑屏
	self.black_root = ccs.GUIReader:getInstance():widgetFromJsonFile('gui/battle/Ui_Black.ExportJson')
	self.cc:addChild(self.black_root,0,0)
	self.black_root:setPosition(0,0)
	self.black_root:addChild(self.skill_root,1,1)
	


	
	local function touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.began then

		elseif eventType == ccui.TouchEventType.moved then
			
		elseif eventType == ccui.TouchEventType.ended then
			if director.get_scene():is_pause() ~= true then
				return
			end
			self:prohibit_button_touch()
			self:close_button_callback_event()
			music_mgr.resume_bg_music()
		elseif eventType == ccui.TouchEventType.canceled then
			
		end
	end

	self.close_button = self.skill_root:getChildByName('设置面板'):getChildByName('返回按钮_0')
	self.close_button:addTouchEventListener(touchEvent)

	local function anwe_event(sender,eventType)
		if eventType == ccui.TouchEventType.began then

		elseif eventType == ccui.TouchEventType.moved then
			
		elseif eventType == ccui.TouchEventType.ended then
			if director.get_scene():is_pause() ~= true then
				return
			end
			self:prohibit_button_touch()
			director.enter_battle_scene(director.get_scene():get_begin_id())
			music_mgr.resume_bg_music()
		elseif eventType == ccui.TouchEventType.canceled then
			
		end
	end

	self.anew_button = self.skill_root:getChildByName('设置面板'):getChildByName('返回按钮')
	self.anew_button:addTouchEventListener(anwe_event)
	

	local function main_touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.began then
				
		elseif eventType == ccui.TouchEventType.moved then
				
		elseif eventType == ccui.TouchEventType.ended then
			self:prohibit_button_touch()
			director.get_scene():resume()
			director.enter_scene(import( 'world.main_scene' ), 'main_scene')
		elseif eventType == ccui.TouchEventType.canceled then
			
		end
	end

	self.main_scene = self.skill_root:getChildByName('设置面板'):getChildByName('主界面')
	self.main_scene:addTouchEventListener(main_touchEvent)

	local function music_touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			music_mgr.alter_ef_sound_enable()
			if self.img_music:isVisible() == false then
				self.img_music:setVisible(true)
			else
				self.img_music:setVisible(false)
			end
		end
	end
	self.main_music = self.skill_root:getChildByName('设置面板'):getChildByName('音乐')
	self.main_music:addTouchEventListener(music_touchEvent)
	self.img_music = self.main_music:getChildByName('img_music')
	local game_music_on = cc.UserDefault:getInstance():getBoolForKey('game_music_on')
	if game_music_on then
		self.img_music:setVisible(false)
		self.main_music:setSelectedState(false)
	else
		self.img_music:setVisible(true)
		self.main_music:setSelectedState(true)
	end

	local function bm_touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.began then
				
		elseif eventType == ccui.TouchEventType.moved then
				
		elseif eventType == ccui.TouchEventType.ended then
			music_mgr.alter_bg_music_enable()
			if self.img_bg_music:isVisible() == false then
				self.img_bg_music:setVisible(true)
			else
				self.img_bg_music:setVisible(false)
			end
		elseif eventType == ccui.TouchEventType.canceled then
			
		end
	end

	self.bm_button = self.skill_root:getChildByName('设置面板'):getChildByName('背景音效')
	self.bm_button:addTouchEventListener(bm_touchEvent)
	self.img_bg_music = self.bm_button:getChildByName('img_bg_music')
	local bg_music_on = cc.UserDefault:getInstance():getBoolForKey('bg_music_on')
	if bg_music_on then
		self.img_bg_music:setVisible(false)
		self.bm_button:setSelectedState(false)
	else
		self.img_bg_music:setVisible(true)
		self.bm_button:setSelectedState(true)
	end

	-- self.set = self.skill_root:getChildByName('设置面板'):getChildByName('lbl_config')
	-- --self.set:setFontName('fonts/msyh.ttf')
	-- self.set:enableOutline(ui_const.UilableStroke, 3)
	-- self.set = self.close_button:getChildByName('返回')
	-- --self.set:setFontName('fonts/msyh.ttf')
	-- self.set:enableOutline(ui_const.UilableStroke, 3)
end

function stop_layer:close_button_callback_event(  )
	-- body
	self:set_visible(true,nil)
	--self.skill_root:getChildByName('设置面板'):setVisible(false)
	local function callFunc( )
		self.istouch = true
		--self.skill_root:getChildByName('设置面板'):setVisible(true)
		self:set_visible(false,nil)
		operate_layer.reset_Joystick_pos()
		--self:remove_touch_event(  )
		self:open_button_touch()
		operate_cmd.enable(true)

	end
	director.get_scene():resume()
	local callFuncObj=cc.CallFunc:create(callFunc)
	--[[self:play_action("Ui-Battle.ExportJson", "界面-up",callFuncObj)]]
	if self.layer.boss_hp.imgbg:isVisible() then
		self:play_action("Ui_Battle_BossBlood.ExportJson", "up")
	end
	self:prohibit_button_touch()
	-- self:play_action("Ui_Battle_Rocker.ExportJson", "up")		--恢复控制界面
	-- self:play_action('Ui_Battle_Button.ExportJson','up')
	-- self:play_action('Ui_Battle_TheBlood.ExportJson','up')
	-- self:play_action('Ui_Battle_Pause.ExportJson','up')
	self.layer:up_battle_ui()
	self:play_action('Ui_Black.ExportJson','down')
	self:play_action('Ui_Set.ExportJson','down',callFuncObj)
	operate_cmd.enable(true)
	operate_layer.show_Joystick()
	

end

function stop_layer:set_visible( isvisble )
	-- body
	self.cc:setVisible(isvisble)
	if isvisble == true then -- true??
		music_mgr.pause_bg_music()
	end
end

function stop_layer:get_istouch(  )
	-- body
	return self.istouch
end


function  stop_layer:init_skill(  )


end

function  stop_layer:set_touch_event(  )
	---单点触控事件
	self.listener = cc.EventListenerTouchOneByOne:create()
	--设置吞噬事件，只有单点触控事件才有
	self.listener:setSwallowTouches(true)
	self.listener:registerScriptHandler(function(touch, event)
		
	return true
	end,cc.Handler.EVENT_TOUCH_BEGAN)

	self.listener:registerScriptHandler(function(touch, event)	
		return false
		
	end,cc.Handler.EVENT_TOUCH_MOVED )

	self.listener:registerScriptHandler(function(touch, event)
		return false
	end,cc.Handler.EVENT_TOUCH_ENDED )
	self.cc:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener, self.cc)


end

function stop_layer:remove_touch_event(  )
	-- body
	self.cc:getEventDispatcher():removeEventListener(self.listener)
end

function stop_layer:prohibit_button_touch()
	self.bm_button:setTouchEnabled(false)
	self.close_button:setTouchEnabled(false)
	self.main_scene:setTouchEnabled(false)
	self.main_music:setTouchEnabled(false)
end
function stop_layer:open_button_touch(  )
	-- body
	self.bm_button:setTouchEnabled(true)
	self.close_button:setTouchEnabled(true)
	self.main_scene:setTouchEnabled(true)
	self.main_music:setTouchEnabled(true)
end



function stop_layer:release()
	ccs.ActionManagerEx:getInstance():releaseActionsByJsonName('gui/battle/Ui_Set.ExportJson')
	super(stop_layer, self).release()
end