local cjson = require 'cjson'
local plist_cache = import( 'ui.plist_cache' )

-- layer class
layer = lua_class( 'layer' )

function layer:_init(is_touch)
	self.cc = cc.Layer:create()
	--self.cc:setAnchorPoint( {x = 0, y = 0} )
	self.loaded_json = {}
	self.actions = {}
	self.is_gray = true
	self.is_remove = false
		--是否开启吞噬事件
	if is_touch == true then
		local listener = cc.EventListenerTouchOneByOne:create()
		--设置吞噬事件，只有单点触控事件才有
		listener:setSwallowTouches(true)
		listener:registerScriptHandler(function(touch, event)
			self:touch_begin_event(touch, event)
			return true
		end,cc.Handler.EVENT_TOUCH_BEGAN)

		listener:registerScriptHandler(function(touch, event)	
			self:touch_move_event( touch, event )
			return false
			
		end,cc.Handler.EVENT_TOUCH_MOVED )

		listener:registerScriptHandler(function(touch, event)
			self:touch_end_event( touch, event )
			return false
		end,cc.Handler.EVENT_TOUCH_ENDED )
		
		self.cc:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.cc)
	end
end

function layer:set_is_gray(is_gray)
	self.is_gray = is_gray
end

function layer:play_action(json_name, action_name, call_func)
	local action = ccs.ActionManagerEx:getInstance():playActionByName(json_name, action_name, call_func)
	if action == nil then
		return
	end
	if self.actions[action] == nil then
		action:retain()
		self.actions[action] = json_name
	end
	return action
end

function layer:release_action(json_name)
	ccs.ActionManagerEx:getInstance():releaseActionsByJsonName(json_name)
end

function layer:record_plist_from_json( json )
	if self.loaded_json[json] == nil then
		self.loaded_json[json] = 1
	end
	plist_cache.retain_UIjson( json )
end

function layer:release()
	for action, json_name in pairs(self.actions) do
		action:stop()
		ccs.ActionManagerEx:getInstance():releaseActionsByJsonName(json_name)
		action:release()
	end

	if self.loaded_json ~= nil then
		for i, v in pairs(self.loaded_json) do
			plist_cache.release_UIjson( i )
		end
	end
end



function layer:touch_begin_event( touch, event )
	--print('触摸开始')
end

function layer:touch_move_event( touch, event )
	-- body
end

function layer:touch_end_event( touch, event )
	-- body
end



ui_layer = lua_class( 'ui_layer', layer )

function ui_layer:_init( conf , is_touch)
	super(ui_layer, self)._init(is_touch)

	self.is_remove = false
	self.conf = conf
	--self.cc = ccui.Layout:create()
	--self.cc:setAnchorPoint( {x = 0, y = 0} )
	if self.conf ~= nil then
		self.widget = ccs.GUIReader:getInstance():widgetFromJsonFile(conf)
		self:record_plist_from_json( conf )
		self.cc:addChild(self.widget)
	end
	--self.widget:setPosition(VisibleSize.width/2, VisibleSize.height/2)

	self.cc:registerScriptHandler(function(event_type)
		if event_type == "enter" then 
			self:on_enter()
		elseif event_type == "exit" then 
			self:on_exit()
		end
	end)


end

function ui_layer:on_enter()
end

function ui_layer:on_exit()
end

function ui_layer:reload()
end

function ui_layer:reload_json()
	ccs.GUIReader:getInstance():widgetFromJsonFile(self.conf)
end
function ui_layer:get_widget(name)
	return ccui.Helper:seekWidgetByName(self.widget, name)
end

function ui_layer:set_handler(name, handler)
	--local widget = tolua.cast(self:get_widget(name), "ccui.Button")
	local widget = self:get_widget(name)
	widget:setTouchEnabled(true)
	local function evenType(sender, eventype)
		local ui_guide = import('world.ui_guide')
		if sender:getDescription() == 'CheckBox' and
			--CheckBox
		   eventype == ccui.CheckBoxEventType.selected then
			ui_guide.touch_ended()
			if ui_guide.check_touch( self._name, name, nil, eventype ) == true then
				handler(self, sender, eventype)
			end
		else
			--普通按钮
			if eventype == ccui.TouchEventType.began then
				self.touch_moved = false
				handler(self, sender, eventype)
			elseif eventype == ccui.TouchEventType.moved then
				if ui_guide.is_guiding() == true then
					return true
				end
				if math.abs(sender:getTouchMovePosition().x - sender:getTouchBeganPosition().x) > 10 then
					self.touch_moved = true
				end
				handler(self, sender, eventype)
			elseif eventype == ccui.TouchEventType.ended then
				if ui_guide.is_guiding() == true then
					if self.touch_moved == true then
						self.touch_moved = false
						return true
					end
					ui_guide.touch_ended()
				end
				if ui_guide.check_touch( self._name, name, nil, eventype ) == true then
					handler(self, sender, eventype)
				end
			end
		end
	end 
	widget:addTouchEventListener(evenType)
end

--直接对控件设置响应事件
function ui_layer:set_widget_handler( widget, handler, tag )
	widget:setTouchEnabled(true)
	local function evenType(sender, eventype)
		local ui_guide = import('world.ui_guide')
		if sender:getDescription() == 'CheckBox' and
			--CheckBox
		   eventype == ccui.CheckBoxEventType.selected then
			ui_guide.touch_ended()
			if ui_guide.check_touch( self._name, widget:getName(), tag, eventype ) == true then
				handler(sender, eventype)
			end
		else
			--普通按钮
			if eventype == ccui.TouchEventType.began then
				self.touch_moved = false
				handler(sender,eventype)
			elseif eventype == ccui.TouchEventType.moved then
				if ui_guide.is_guiding() == true then
					return true
				end
				if math.abs(sender:getTouchMovePosition().x - sender:getTouchBeganPosition().x) > 10 then
					self.touch_moved = true
				end
				handler(sender,eventype)
			elseif eventype == ccui.TouchEventType.ended then
				if ui_guide.is_guiding() == true then
					if self.touch_moved == true then
						self.touch_moved = false
						return true
					end
					ui_guide.touch_ended()
				end
				if ui_guide.check_touch( self._name, widget:getName(), tag, eventype ) == true then
					handler(sender, eventype)
				end
			end
		end
	end 
	widget:addTouchEventListener(evenType)
end

function ui_layer:remove()
	self.is_remove = true
end

function ui_layer:release()

	--cc.SpriteFrameCache: getInstance(): removeSpriteFramesFromFile( 'gui/ui_black_bg/ui_black_bg0.plist' )
	super(ui_layer, self).release()
	ccs.ActionManagerEx:getInstance():releaseActionsByJsonName(self.conf)
	--ccs.ActionManagerEx:getInstance():releaseActions()
	ccs.ArmatureDataManager:destroyInstance()
	--cc.Director:getInstance():purgeCachedData()

end

