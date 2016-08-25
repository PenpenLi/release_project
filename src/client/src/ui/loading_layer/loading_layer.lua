local layer					= import( 'world.layer' )

loading_layer = lua_class('loading_layer',layer.ui_layer)

function loading_layer:_init(  )
	-- print(' loading layer ')
	super(loading_layer,self)._init('gui/global/ui_network.ExportJson') -- base package resource
	self.is_hide = true
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2 ,VisibleSize.height/2)
	self.circle_img = ccui.Helper:seekWidgetByName( self.widget, 'Image_15' )
	self.circle_img: runAction( cc.RepeatForever: create( cc.RotateBy: create( 2, -540 )))

	self:set_text('加载中...')

	-- 监听事件
	--[[
	local function click_began()
		if self.is_hide ~= true then
			-- 拦截，click_ended
			-- return true
			return false
		end
	end

	local function click_ended()
	end

	self.layer_listener = cc.EventListenerTouchOneByOne: create()
	self.layer_listener: setSwallowTouches( true )
	self.layer_listener: registerScriptHandler( click_began, cc.Handler.EVENT_TOUCH_BEGAN )
	self.layer_listener: registerScriptHandler( click_ended, cc.Handler.EVENT_TOUCH_ENDED )
	self.eventDispatcher = self.cc:getEventDispatcher()
	self.eventDispatcher: addEventListenerWithSceneGraphPriority(self.layer_listener, self.cc )
	--]]
end

function loading_layer:show()
	self.is_hide = false
	self.cc: setVisible( true )
end

function loading_layer:hide()
	self.is_hide = true
	self.cc: setVisible( false )
end

function loading_layer:set_text( txt )
	if self.lbl_text == nil then
		self.lbl_text = ccui.Helper: seekWidgetByName( self.widget, 'Label_8_0' )
	end
	self.lbl_text: setString( txt )
end

function loading_layer:release(  )
	if self.circle_img ~= nil then
		self.circle_img: stopAllActions()
	end
	super(loading_layer, self).release()
	self.is_remove = true
	--self.cc:removeFromParent()
	-- print('remove loading_layer.plist')
	-- cc.SpriteFrameCache: getInstance(): removeSpriteFramesFromFile( 'gui/ui_loading/loading0.plist' )
end
