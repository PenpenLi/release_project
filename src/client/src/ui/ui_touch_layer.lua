local layer 			= import('world.layer')
local skill_button		= import('ui.skill_button')
local td_home			= import('ui.td_ui.td_home')
local td_mons_count		= import('ui.td_ui.td_mons_count')
local menu_list			= import('ui.menu_list')
local head_portrait 	= import('ui.head_portrait')
local operate_layer		= import('ui.operate_layer')
local operate_cmd		= import('ui.operate_cmd')
local stop_layer 		= import( 'ui.stop_layer.stop_layer')
local boss_hp			= import('ui.boss_hp') 
local director			= import( 'world.director' )
local model				= import( 'model.interface' )
local motion_streak 	= import( 'ui.motion_streak' ) 
local head_icon			= import( 'ui.head_icon.head_icon' )

ui_touch_layer 			= lua_class('ui_touch_layer',layer.layer)


local sicon_set = 'icon/s_icons.plist'

function  ui_touch_layer:_init(  )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( sicon_set )
	super(ui_touch_layer,self)._init()
	
	self.is_auto = cc.UserDefault:getInstance():getIntegerForKey("auto_battle")
	if self.is_auto == nil then
		self.is_auto = 0
		cc.UserDefault:getInstance():setIntegerForKey("auto_battle", self.is_auto)
	end

	self:create_ui_scene()
	self:touch_event()
end

--加入场景
function  ui_touch_layer:create_ui_scene(  )
	local jsn_the_blood = 'gui/battle/Ui_Battle_TheBlood.ExportJson'
	local jsn_button = 'gui/battle/Ui_Battle_Button.ExportJson'
	local jsn_rocker = 'gui/battle/Ui_Battle_Rocker.ExportJson'
	local jsn_bossblood = 'gui/battle/Ui_Battle_BossBlood.ExportJson'
	local jsn_pause = 'gui/battle/Ui_Battle_Pause.ExportJson'
	local jsn_blood = 'gui/battle/Ui_Blood.ExportJson'
	local jsn_go_icon =	'gui/battle/Ui_zdzd3.ExportJson'
	local jsn_fuben_cnt =	'gui/battle/Ui_zdzd1.ExportJson'
	local jsn_auto_battle =	'gui/battle/Ui_zdzd2.ExportJson'

	-- body
	--玩家头像
	self.head_portrait_root = ccs.GUIReader:getInstance():widgetFromJsonFile(jsn_the_blood)
	self:record_plist_from_json( jsn_the_blood )
	self.cc:addChild(self.head_portrait_root)
	self.head_portrait_root:ignoreAnchorPointForPosition(true)
	self.head_portrait_root:setPosition(VisibleSize.width/2,VisibleSize.height)
	local head_img = self.head_portrait_root:getChildByName('Panel_3'):getChildByName('img_head')
	self.head_icon = head_icon.head_icon(model.get_player().role_type, model.get_player().wear.helmet)
	self.head_icon:set_scale(0.8)
	self.head_icon.cc:setPosition(140, -10)
	head_img:addChild(self.head_icon.cc, 100)

	--技能按钮
	self.skill_button_root = ccs.GUIReader:getInstance():widgetFromJsonFile(jsn_button)
	self:record_plist_from_json( jsn_button )
	self.skill_button_panel = self.skill_button_root:getChildByName('Panel_30')
	self.cc:addChild(self.skill_button_root)
	self.skill_button_root:ignoreAnchorPointForPosition(true)
	self.skill_button_root:setPosition(VisibleSize.width,0)


	--摇杆 
	self.operate_layer_root = ccs.GUIReader:getInstance():widgetFromJsonFile(jsn_rocker)
	self:record_plist_from_json( jsn_rocker )
	self.operate_layer_panel = self.operate_layer_root:getChildByName('Rocker')
	self.cc:addChild(self.operate_layer_root)
	self.operate_layer_root:setPosition(0,0)

	--boss血条
	self.boss_hp_root = ccs.GUIReader:getInstance():widgetFromJsonFile(jsn_bossblood)
	self:record_plist_from_json( jsn_bossblood )
	--self.boss_hp_panel = self.boss_hp_root:getChildByName('bossBlood')
	self.boss_hp_root:ignoreAnchorPointForPosition(true)
	self.cc:addChild(self.boss_hp_root)
	self.boss_hp_root:setPosition(VisibleSize.width/2,0)
	self.boss_hp_root: setVisible(false)

	--暂停按钮
	self.pause_button_root = ccs.GUIReader:getInstance():widgetFromJsonFile(jsn_pause)
	self:record_plist_from_json( jsn_pause )
	self.cc:addChild(self.pause_button_root)
	self.pause_button_root:ignoreAnchorPointForPosition(true)
	self.pause_button_root:setPosition(VisibleSize.width,VisibleSize.height)
	local pause_panel = self.pause_button_root:getChildByName('Panel_9')
	pause_panel:ignoreAnchorPointForPosition(true)

	--红屏没血
	self.no_hp_prompt_root = ccs.GUIReader:getInstance():widgetFromJsonFile(jsn_blood)
	self:record_plist_from_json( jsn_blood )
	self.cc:addChild(self.no_hp_prompt_root)
	--self.no_hp_prompt_root:ignoreAnchorPointForPosition(true)
	self.no_hp_prompt_root:setPosition(0,0)

	for i = 1, 3 do
		self.skill_button_panel:getChildByName('skill_button_'..i):setVisible(false)
		self.skill_button_panel:getChildByName('skill_button_'..i):getChildByName('skill_bar_'..i):setVisible(false)
		--widget:getChildByName('skill_button_'..i):setVisible(false)
		--widget:getChildByName('skill_button_'..i):getChildByName('skill_bar_'..i):setVisible(false)
	end

	--go箭头
	self.go_icon_root = ccs.GUIReader:getInstance():widgetFromJsonFile(jsn_go_icon)
	self:record_plist_from_json( jsn_go_icon )
	self.cc:addChild(self.go_icon_root)
	self.go_icon_root:ignoreAnchorPointForPosition(true)
	self.go_icon_root:setPosition(VisibleSize.width-80,VisibleSize.height/2)
	self.go_icon = self.go_icon_root:getChildByName('Image_5')
	self.go_icon:setVisible(false)
	self.go_icon:ignoreAnchorPointForPosition(true)

	--关卡计数
	self.fuben_cnt_root = ccs.GUIReader:getInstance():widgetFromJsonFile(jsn_fuben_cnt)
	self:record_plist_from_json( jsn_fuben_cnt )
	self.cc:addChild(self.fuben_cnt_root)
	self.fuben_cnt_root:ignoreAnchorPointForPosition(true)
	self.fuben_cnt_root:setPosition(VisibleSize.width,VisibleSize.height)
	self.fuben_cnt = self.fuben_cnt_root:getChildByName('Panel_9'):getChildByName('lbl_cnt')
	self.fuben_cnt_root:getChildByName('Panel_9'):ignoreAnchorPointForPosition(true)

	local function auto_btn_event(sender,eventType)
		if eventType == ccui.TouchEventType.began then
		elseif eventType == ccui.TouchEventType.moved then
		elseif eventType == ccui.TouchEventType.ended then
			local cur_battle = director.get_cur_battle()
			self.is_auto = 1 - self.is_auto
			cur_battle:set_auto_battle(self.is_auto)
			cc.UserDefault:getInstance():setIntegerForKey("auto_battle", self.is_auto)
		elseif eventType == ccui.TouchEventType.canceled then
			
		end
	end	


	--自动攻击
	self.auto_battle_root = ccs.GUIReader:getInstance():widgetFromJsonFile(jsn_auto_battle)
	self:record_plist_from_json( jsn_auto_battle )
	self.cc:addChild(self.auto_battle_root)
	self.auto_battle_root:ignoreAnchorPointForPosition(true)
	self.auto_battle_root:setPosition(0,VisibleSize.height)
	self.auto_btn = self.auto_battle_root:getChildByName('Panel_9'):getChildByName('btn_auto')
	self.auto_battle_root:getChildByName('Panel_9'):ignoreAnchorPointForPosition(true)
	self.auto_btn:addTouchEventListener(auto_btn_event)
	if self.is_auto == 1 then
		self.auto_btn:setSelectedState(true)
	else
		self.auto_btn:setSelectedState(false)
	end

	

	--取出技能按钮
	--[[
	self.skill_btn = {}
	self.command_to_btn = {}
	local player = model.get_player()
	local skills = player:get_loaded_skills()
	if skills ~= nil then
		local idx = 3
		for i = 6, 1, -1 do
			local skill = skills[i]
			if skill ~= nil and skill.data.type == EnumSkillTypes.active then
				local command = skill:get_command()
				self.skill_btn[skill.id] = skill_button.skill_button(self.skill_button_panel, idx, skill)
				--self.skill_btn[skill.id] = skill_button.skill_button(widget, idx, skill)
				idx = idx - 1
				self.command_to_btn[command] = self.skill_btn[skill.id]
			end
		end
	end
	--]]
	self:refresh_skill_buttons()
	
	-- --self.menu_lt = menu_list.menu_list(widget,'CheckBox_19')

	self.head_pt = head_portrait.head_portrait(self.head_portrait_root,'Image_9')
	--self.head_pt = head_portrait.head_portrait(widget,'Image_9')
	self.operate_lyr = operate_layer.operate_layer(self.operate_layer_panel,'joystick_l','joystick_bg')

	--self.operate_lyr = operate_layer.operate_layer(widget,'joystick','joystick_bg')

	self.boss_hp = boss_hp.boss_hp(self.boss_hp_root,'bossBlood')

	self.stop_layer =  stop_layer.stop_layer(self)
	self.cc:addChild(self.stop_layer.cc,100)
	self.stop_layer:set_visible(false)
	--self.

	local function touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.began then

		elseif eventType == ccui.TouchEventType.moved then
			
		elseif eventType == ccui.TouchEventType.ended then
				self:close_button_callback_event()
		elseif eventType == ccui.TouchEventType.canceled then
			
		end
	end

	self.close_button = self.pause_button_root:getChildByName('Panel_9'):getChildByName('Pause')
	--self.close_button = widget:getChildByName('暂停按钮')
	self.close_button:addTouchEventListener(touchEvent)	

	--加入拖尾效果层
	self.motion = motion_streak.motion_streak()
	self.cc:addChild(self.motion.cc,1,100)

	self.no_hp_prompt = self.no_hp_prompt_root:getChildByName('Noblood')
	self.no_hp_prompt:setVisible(false)

end

function ui_touch_layer:show_timer_counter()
	self.label = cc.Label:createWithTTF('adfasdfsadf', 'fonts/msyh.ttf', 60)
	local visibleSize = cc.Director:getInstance():getVisibleSize()
	self.label:setPosition(cc.p(visibleSize.width/2,visibleSize.height/2))
	self.cc:addChild(self.label, 100)
end

function ui_touch_layer:set_timer_counter(time)
	print("set  time:   ", time)
	self.label:setString(time)
end

function ui_touch_layer:close_button_callback_event(  )
	
	if director.get_scene():is_pause() == true then
		return
	end
	-- body
	--
	director.get_scene():pause()
	operate_cmd.enable(false)
	if self.boss_hp.imgbg:isVisible() then
		self:play_action("Ui_Battle_BossBlood.ExportJson", "down")
	end

	-- self:play_action("Ui_Battle_Rocker.ExportJson", "down")		--恢复控制界面
	-- self:play_action('Ui_Battle_Button.ExportJson','down')
	-- self:play_action('Ui_Battle_TheBlood.ExportJson','down')
	-- self:play_action('Ui_Battle_Pause.ExportJson','down')
	self:down_battle_ui()
	self:play_action('Ui_Set.ExportJson','up')
	self:play_action('Ui_Black.ExportJson','up')

	--self.stop_layer:set_touch_event()
	self.stop_layer:set_visible(true)
end



function  ui_touch_layer:touch_event(  )
	---单点触控事件
	local listener = cc.EventListenerTouchOneByOne:create()
	--设置吞噬事件，只有单点触控事件才有
	listener:setSwallowTouches(true)
	listener:registerScriptHandler(function(touch, event)
		
	-- local touchPoint = touch:getLocation()
	-- local istoucharr = {}
	-- for id, btn in pairs(self.skill_btn) do
	-- 	table.insert(istoucharr,btn:touch_event(touchPoint))
	-- end
	-- --table.insert(istoucharr,self.menu_lt:touch_event(touchPoint))

	-- -- if self.touch ==false then
	-- -- 	self.touch = self.stop_layer:get_istouch()
	-- -- 	return true
	-- -- end
	-- for i,n in ipairs(istoucharr) do           	
	-- 	if n~=nil and n == true then 
	-- 		return true
	-- 	end
	-- end
	-- return false
	--return true
	end,cc.Handler.EVENT_TOUCH_BEGAN)

	listener:registerScriptHandler(function(touch, event)	
		return false
		
	end,cc.Handler.EVENT_TOUCH_MOVED )

	listener:registerScriptHandler(function(touch, event)
		return false
	end,cc.Handler.EVENT_TOUCH_ENDED )
	self.cc:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.cc)


end

function  ui_touch_layer:tick(  )
	-- body
	for id, btn in pairs(self.skill_btn) do
		btn:tick()
	end

	if self.td_home_class then
		self.td_home_class:tick()
	end
end

function ui_touch_layer:stop(  )
	-- body
	--self.menu_lt:stop()
end

function ui_touch_layer:release( )
	--[[local jsn_the_blood = 'gui/battle/Ui_Battle_TheBlood.ExportJson'
	local jsn_button = 'gui/battle/Ui_Battle_Button.ExportJson'
	local jsn_rocker = 'gui/battle/Ui_Battle_Rocker.ExportJson'
	local jsn_bossblood = 'gui/battle/Ui_Battle_BossBlood.ExportJson'
	local jsn_pause = 'gui/battle/Ui_Battle_Pause.ExportJson'
	local jsn_blood = 'gui/battle/Ui_Blood.ExportJson'
	local jsn_go_icon =	'gui/battle/Ui_zdzd3.ExportJson'
	local jsn_fuben_cnt =	'gui/battle/Ui_zdzd1.ExportJson'
	local jsn_auto_battle =	'gui/battle/Ui_zdzd2.ExportJson'
	cc.SpriteFrameCache: getInstance(): removeSpriteFramesFromFile( sicon_set )
	ccs.ActionManagerEx:getInstance():releaseActionsByJsonName(jsn_the_blood)
	ccs.ActionManagerEx:getInstance():releaseActionsByJsonName(jsn_button)
	ccs.ActionManagerEx:getInstance():releaseActionsByJsonName(jsn_rocker)
	ccs.ActionManagerEx:getInstance():releaseActionsByJsonName(jsn_bossblood)
	ccs.ActionManagerEx:getInstance():releaseActionsByJsonName(jsn_pause)
	ccs.ActionManagerEx:getInstance():releaseActionsByJsonName(jsn_blood)
	ccs.ActionManagerEx:getInstance():releaseActionsByJsonName(jsn_go_icon)
	ccs.ActionManagerEx:getInstance():releaseActionsByJsonName(jsn_fuben_cnt)
	ccs.ActionManagerEx:getInstance():releaseActionsByJsonName(jsn_auto_battle)
	super(ui_touch_layer, self).release()]]
end

function ui_touch_layer:up_hp( number,cur_hp )
	-- body
	self.head_pt:set_red_bar(number,cur_hp)
end
function ui_touch_layer:up_boss_hp( number,cur_hp )
	-- body
	self.boss_hp:set_red_bar(number,cur_hp)
end

function ui_touch_layer:show_boss_hp( )
	self.boss_hp_root:setVisible(true)
end

function ui_touch_layer:hide_boss_hp( )
	self.boss_hp_root:setVisible(false)
end

function ui_touch_layer:up_mp( number ,cur_mp)
	-- body
	self.head_pt:set_blue_bar(number,cur_mp)
end

function ui_touch_layer:setup_operate_cmd(layer, eventDispatcher)
	-- body
	--手柄
	operate_cmd.setup_operate_cmd(layer, eventDispatcher,self.operate_lyr)
end

function ui_touch_layer:cast_skill(cmd)
	local btn = self.command_to_btn[cmd]
	if btn ~= nil then
		btn:cast_skill()
	end
end

function ui_touch_layer:refresh_skill_buttons()
	self.skill_btn = {}
	self.command_to_btn = {}
	local player = model.get_player()
	local skills = player:get_loaded_skills()
	if skills ~= nil then
		local idx = 3
		for i = 6, 1, -1 do
			local skill = skills[i]
			if skill ~= nil and skill.data.type == EnumSkillTypes.active then
				local command = skill:get_command()
				self.skill_btn[skill.id] = skill_button.skill_button(self.skill_button_panel, idx, skill)
				idx = idx - 1
				self.command_to_btn[command] = self.skill_btn[skill.id]
			end
		end
	end
end

function ui_touch_layer:hide_skill_buttons()
	if self.skill_button_panel ~= nil then
		self.skill_button_panel: setVisible(false)
	end
end
function ui_touch_layer:show_skill_buttons()
	if self.skill_button_panel ~= nil then
		self.skill_button_panel: setVisible(true)
	end
end

--获取no_hp_Prompt
function ui_touch_layer:show_no_hp_prompt(  )
	-- body
	if self.no_hp_prompt:isVisible() == false then
		self.no_hp_prompt:setVisible(true)
		self.anin=self:play_action("Ui_Blood.ExportJson","没血了啊")
	end
end

-- 塔防，显示boss正在靠近
function ui_touch_layer:ui_td_boss_coming(  )
	local jsn_boss_coming = 'gui/battle/Ui_boss_coming.ExportJson'
	self.boss_coming_root = ccs.GUIReader:getInstance():widgetFromJsonFile(jsn_boss_coming)
	self:record_plist_from_json( jsn_boss_coming )
	self.cc:addChild(self.boss_coming_root)
	self.boss_coming_root:ignoreAnchorPointForPosition(true)
	self.boss_coming_root:setPosition(VisibleSize.width/2, VisibleSize.height/2)
	self.boss_coming_root:setVisible(false)
end

function ui_touch_layer:show_td_boss_coming(  )

	local function callback(  )
		self.boss_coming_root:setVisible(false)
		if self.boss_coming_anime ~= nil then
			self.boss_coming_anime:stop()
			self.boss_coming_anime = nil
		end
	end

	if self.boss_coming_root:isVisible() == false then
		self.boss_coming_root:setVisible(true)
		self.boss_coming_anime=self:play_action("Ui_boss_coming.ExportJson", "boss", cc.CallFunc:create(callback))
	end
end

-- 显示塔防基地无敌按钮
function ui_touch_layer:show_td_home( home_entity )
	local jsn_td_home = 'gui/battle/Ui_td_home.ExportJson'
	self.td_home_root = ccs.GUIReader:getInstance():widgetFromJsonFile(jsn_td_home)
	self:record_plist_from_json( jsn_td_home )
	self.td_home = self.td_home_root:getChildByName('Panel_1')--:getChildByName('td_home')
	self.cc:addChild(self.td_home_root)
	self.td_home_root:ignoreAnchorPointForPosition(true)
	self.td_home_root:setPosition(0,VisibleSize.height/2)

	self.td_home_class = td_home.td_home(self.td_home)
	self.td_home_class:set_td_home_info(home_entity)
end

-- 显示塔防剩余怪物条
function ui_touch_layer:show_td_mons_count(  )
	local jsn_td_mons_count = 'gui/battle/Ui_td_mons_count.ExportJson'
	self.td_mons_count_root = ccs.GUIReader:getInstance():widgetFromJsonFile(jsn_td_mons_count)
	self:record_plist_from_json( jsn_td_mons_count )
	self.td_mons_count = self.td_mons_count_root:getChildByName('Panel')
	self.cc:addChild(self.td_mons_count_root)
	self.td_mons_count_root:ignoreAnchorPointForPosition(true)
	self.td_mons_count_root:setPosition(VisibleSize.width/2,VisibleSize.height)

	self.td_mons_count_class = td_mons_count.td_mons_count(self.td_mons_count)
end

function ui_touch_layer:hide_no_hp_prompt(  )
	-- body
	if self.anin ~= nil then
		self.no_hp_prompt:setVisible(false)
		self.anin:stop()
		self.anin = nil
	end
end

function ui_touch_layer:show_go_icon( )
	if self.go_icon:isVisible() == false then
		self.go_icon:setVisible(true)
		self.go_anim=self:play_action("Ui_zdzd3.ExportJson","go")
	end
end

function ui_touch_layer:hide_go_icon(  )
	-- body
	if self.go_anim ~= nil then
		self.go_icon:setVisible(false)
		self.go_anim:stop()
		self.go_anim = nil
	end
end

function ui_touch_layer:hide_auto_battle()
	self.is_auto = 0
	self.auto_battle_root:setVisible(false)
end

function ui_touch_layer:hide_fuben_cnt()
	self.fuben_cnt_root:setVisible(false)
end

function ui_touch_layer:set_fuben_cnt(cur, all)
	self.fuben_cnt:setString(cur..'/'..all)
end

function ui_touch_layer:get_is_auto()
	return self.is_auto
end

function ui_touch_layer:down_battle_ui()
	self:play_action("Ui_Battle_Rocker.ExportJson", "down")		--恢复控制界面
	self:play_action('Ui_Battle_Button.ExportJson','down')
	self:play_action('Ui_Battle_TheBlood.ExportJson','down')
	self:play_action('Ui_Battle_Pause.ExportJson','down')
	self:play_action('Ui_td_home.ExportJson','down')
	self:play_action('Ui_td_mons_count.ExportJson','down')
	self:play_action('Ui_zdzd1.ExportJson', 'down')
	self:play_action('Ui_zdzd2.ExportJson', 'down')
end

function ui_touch_layer:up_battle_ui()
	self:play_action("Ui_Battle_Rocker.ExportJson", "up")		--恢复控制界面
	self:play_action('Ui_Battle_Button.ExportJson','up')
	self:play_action('Ui_Battle_TheBlood.ExportJson','up')
	self:play_action('Ui_Battle_Pause.ExportJson','up')
	self:play_action('Ui_td_home.ExportJson','up')
	self:play_action('Ui_td_mons_count.ExportJson','up')
	self:play_action('Ui_zdzd1.ExportJson', 'up')
	self:play_action('Ui_zdzd2.ExportJson', 'up')
end

function ui_touch_layer:get_skill_btn()
	return self.skill_btn
end