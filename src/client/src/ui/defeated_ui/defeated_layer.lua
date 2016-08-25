local layer 			= import('world.layer')
local battle_layer 		= import('world.battle_layer')
local director			= import( 'world.director' )
local entity			= import( 'world.entity' )
local model 			= import( 'model.interface' )
local combat 			= import( 'model.combat' )
local state_mgr			= import( 'game_logic.state_mgr' )
local operate_cmd 		= import( 'ui.operate_cmd' )
local operate_layer		= import('ui.operate_layer')
local music_mgr			= import( 'world.music_mgr' )
local ui_touch_layer	= import( 'ui.ui_touch_layer' )
local director			= import( 'world.director' )
local ui_const			= import( 'ui.ui_const' )
local ui_mgr			= import( 'ui.ui_mgr' )

defeated_layer = lua_class('defeated_layer',layer.layer)
local _to_scene_id = 1 ---切换场景id

function defeated_layer:_init( layer )
	-- body
	super(defeated_layer,self)._init()
	self.layer = layer
	self:create_defeated(  )
	self.isremove=false
	self.defeated_count=0		--限定界面被载入次数
end

function defeated_layer:create_defeated(  )
	-- body
	self.defeated_root = ccs.GUIReader:getInstance():widgetFromJsonFile('gui/battle/Ui_D.ExportJson')
	--self.cc:addChild(self.defeated_root)
	self.defeated_root:ignoreAnchorPointForPosition(true)
	self.defeated_root:setPosition(VisibleSize.width/2,VisibleSize.height/2)

		--黑屏
	self.black_root = ccs.GUIReader:getInstance():widgetFromJsonFile('gui/battle/Ui_Black.ExportJson')
	self.cc:addChild(self.black_root,0,0)
	self.black_root:setPosition(0,0)
	self.black_root:addChild(self.defeated_root,1,1)


	local function touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.began then
			--self:renew_button_callback_event()
		elseif eventType == ccui.TouchEventType.moved then
			
		elseif eventType == ccui.TouchEventType.ended then
			music_mgr.stop_bg_music()
			self:renew_button_callback_event()
		elseif eventType == ccui.TouchEventType.canceled then
			
		end
	end

	self.close_button = self.defeated_root:getChildByName('失败面板'):getChildByName('否')
	self.close_button:addTouchEventListener(touchEvent)


	local function yes_touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.began then
			--self:renew_button_callback_event()
		elseif eventType == ccui.TouchEventType.moved then
			
		elseif eventType == ccui.TouchEventType.ended then
			self:renew_button_callback_event2(1)
			music_mgr.resume_bg_music()
		elseif eventType == ccui.TouchEventType.canceled then
			
		end
	end

	self.yes_button = self.defeated_root:getChildByName('失败面板'):getChildByName('是')
	self.yes_button:addTouchEventListener(yes_touchEvent)



	local label = self.defeated_root:getChildByName('失败面板'):getChildByName('lbl_fail')
	--label:setFontName('fonts/msyh.ttf')
	label:enableOutline(ui_const.UilableStroke, 3)

	--label = self.defeated_root:getChildByName('失败面板'):getChildByName('Label_6')
	--label:setFontName('fonts/msyh.ttf')
	--label:enableOutline(ui_const.UilableStroke, 3)

	label = self.defeated_root:getChildByName('失败面板'):getChildByName('lbl_fail_body')
	--label:setFontName('fonts/msyh.ttf')
	label:enableOutline(ui_const.UilableStroke, 3)

	self.diamond_label = self.defeated_root:getChildByName('失败面板'):getChildByName('获得石头数')
	--self.diamond_label:setFontName('fonts/msyh.ttf')
	self.diamond_label:enableOutline(ui_const.UilableStroke, 3)

	self.ext_label = self.close_button:getChildByName('lbl_return')
	--self.ext_label:setFontName('fonts/msyh.ttf')
	self.ext_label:enableOutline(ui_const.UilableStroke, 3)

	self.yes_label = self.yes_button:getChildByName('lbl_alive')
	--self.yes_label:setFontName('fonts/msyh.ttf')
	self.yes_label:enableOutline(ui_const.UilableStroke, 3)

	
	local function qh_btn_touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.began then
			--self:renew_button_callback_event()
		elseif eventType == ccui.TouchEventType.moved then
			
		elseif eventType == ccui.TouchEventType.ended then
			director.get_scene():resume()
			director.enter_scene(import( 'world.main_scene' ), 'main_scene')
			ui_mgr.add_wait_ui('main_scene', import('ui.equip_sys_layer.equip_sys_layer'), 'equip_sys_layer')
		elseif eventType == ccui.TouchEventType.canceled then
			
		end
	end

	local function soul_btn_touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.began then
			--self:renew_button_callback_event()
		elseif eventType == ccui.TouchEventType.moved then
			
		elseif eventType == ccui.TouchEventType.ended then
			director.get_scene():resume()
			director.enter_scene(import( 'world.main_scene' ), 'main_scene')
			ui_mgr.add_wait_ui('main_scene', import('ui.soul_system.soul_page_panel'), 'soul_page_panel')
		elseif eventType == ccui.TouchEventType.canceled then
			
		end
	end

	local function strengthen_touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.began then
			--self:renew_button_callback_event()
		elseif eventType == ccui.TouchEventType.moved then
			
		elseif eventType == ccui.TouchEventType.ended then
			director.get_scene():resume()
			director.enter_scene(import( 'world.main_scene' ), 'main_scene')
			ui_mgr.add_wait_ui('main_scene', import('ui.proficient_layer.proficient_layer'), 'proficient_layer')
		elseif eventType == ccui.TouchEventType.canceled then
			
		end
	end

	self.btn_qh = self.defeated_root:getChildByName('失败面板'):getChildByName('btn_qh')
	self.btn_qh:addTouchEventListener(qh_btn_touchEvent)
	self.btn_soul = self.defeated_root:getChildByName('失败面板'):getChildByName('btn_soul')
	self.btn_soul:addTouchEventListener(soul_btn_touchEvent)
	self.btn_strengthen = self.defeated_root:getChildByName('失败面板'):getChildByName('btn_strengthen')
	self.btn_strengthen:addTouchEventListener(strengthen_touchEvent)
end

--否按钮，回到装备界面
function defeated_layer:renew_button_callback_event(  )
	self.cc:setVisible(false)
	director.get_scene():resume()
	director.enter_scene(import( 'world.main_scene' ), 'main_scene')
	local ui_queue = ui_mgr.ui_his_dequeue['main_scene']
	if ui_queue ~= nil then
		local top_ui
		for i = 1, 1 do
			top_ui = ui_queue:pop_front()
			if top_ui ~= nil then
				ui_mgr.add_wait_ui('main_scene', top_ui.mod, top_ui.name)
			end
		end
	end
end

--是，满血原地复活
function defeated_layer:renew_button_callback_event2( scene_id )
	self.defeated_count = 0							--重设界面显示次数

	server.rebirth_rightnow()
end

function defeated_layer:player_can_rebirth()
	local player = model.get_player().entity 		--获得玩家
	player.combat_attr:reset_relive( player )		--让玩家复活	

	-- 塔防玩法，复活基地
	local now_battle = director.get_cur_battle()
	local fuben_type = data.fuben[now_battle.id].type
	if fuben_type == 'towerdefense' then
		local home_e = now_battle:get_home_entity()
		home_e.combat_attr:set_max_hp()
	end

	director.get_scene():resume( )					--恢复更新
	self.cc:setVisible(true)
	--TODO 以后UI动画会用
	local function callFunc(  )
		self.cc:setVisible(false)					--让摇杆再可用 ---暂时让他不隐藏是为了延长吞噬事件到动画结束，才让摇杆恢复
		print('显示按钮')
		operate_layer.reset_Joystick_pos()
		operate_cmd.enable(true)
		self:open_button_touch()
	end
	local callFuncObj=cc.CallFunc:create(callFunc)
	if self.layer.boss_hp.imgbg:isVisible() then
		self:play_action("Ui_Battle_BossBlood.ExportJson", "up")
	end
	-- self:play_action("Ui_Battle_Rocker.ExportJson", "up",callFuncObj)		--恢复控制界面
	-- self:play_action('Ui_Battle_Button.ExportJson','up')
	-- self:play_action('Ui_Battle_TheBlood.ExportJson','up')
	-- self:play_action('Ui_Battle_Pause.ExportJson','up')
	self.layer:up_battle_ui()
	self:play_action('Ui_Black.ExportJson','down')
	self:play_action('Ui_D.ExportJson','down',callFuncObj)


	---------------------
	self:prohibit_button_touch()
	operate_cmd.enable(false)
	operate_layer.show_Joystick()


end


function defeated_layer:prohibit_button_touch()
	self.yes_button:setTouchEnabled(false)
	self.close_button:setTouchEnabled(false)
end
function defeated_layer:open_button_touch(  )
	-- body
	self.yes_button:setTouchEnabled(true)
	self.close_button:setTouchEnabled(true)
end

function defeated_layer:set_close_btn_event(func)
	local function touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.began then
			--self:renew_button_callback_event()
		elseif eventType == ccui.TouchEventType.moved then
			
		elseif eventType == ccui.TouchEventType.ended then
			music_mgr.stop_bg_music()
			self.cc:setVisible(false)
			director.get_scene():resume()
			if type(func) == 'function' then
				func()
			end
		elseif eventType  == ccui.TouchEventType.canceled then
			
		end
	end
	self.close_button = self.defeated_root:getChildByName('失败面板'):getChildByName('否')
	self.close_button:addTouchEventListener(touchEvent)
end

function defeated_layer:release()
end