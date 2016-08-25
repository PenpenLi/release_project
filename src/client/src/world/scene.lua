local loading_layer				= import( 'ui.loading_layer.loading_layer' )
local battle_const				= import( 'game_logic.battle_const' )
local msg_layer 				= import( 'ui.msg_ui.msg_layer' )	
local ui_mgr 					= import( 'ui.ui_mgr' ) 

scene = lua_class( 'scene' )

function scene:_init()
	-- print(' class(scene) init' )
	self.cc = cc.Scene:create()
	self.loading_layer = loading_layer.loading_layer()
	self.cc: addChild( self.loading_layer.cc )
	self.loading_layer.cc: setVisible( false )
	self.loading_layer.cc: setLocalZOrder( ZUILoading )

	self.msg_layer = msg_layer.msg_layer()
	self.msg_layer.cc:setPosition(VisibleSize.width/2,VisibleSize.height/2)
	self.cc:addChild( self.msg_layer.cc , 2 )

	local function tick()
		--检查是否移除ui
		self.msg_layer:tick()
		ui_mgr.check_remove_ui()
		self:scene_tick()
	end
	self.tick = cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick, 0, false)
end

function scene:show_loading()
	-- print(' scene begin loading ')
	self.loading_layer: show()
end

function scene:hide_loading()
	-- print(' scene end loading ')
	self.loading_layer: hide()
end

function scene:enter_scene()
	--cc.Director:getInstance():purgeCachedData()
	collectgarbage("collect")
	if cc.Director:getInstance():getRunningScene() then
		--cc.Director:getInstance():replaceScene(cc.TransitionFade:create(battle_const.ChangeSceneDelay, self.cc, cc.c3b(0, 0, 0)))
		cc.Director:getInstance():replaceScene(self.cc)
	else
		cc.Director:getInstance():runWithScene(self.cc)
	end
	-- cc.Director:getInstance():pushScene(self.cc)
	-- print('[scene] pushScene')
end

function scene:release()
	collectgarbage("collect")
	-- print(' class(scene) release' )
	-- Actions必须在removeNode之前。否则crash
	--ccs.ActionManagerEx:destroyInstance()
	ccs.ActionManagerEx:getInstance():releaseActions()
	self.msg_layer:release()
	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.tick)
	ui_mgr.remove_scene_ui(self._name)
	self:scene_release()
	self.loading_layer:release()
	--ccs.ArmatureDataManager:destroyInstance()
	--cc.Director:getInstance():purgeCachedData()
end

-- for children override
function scene:scene_release()
	-- children release
end

function scene:scene_tick()
end
