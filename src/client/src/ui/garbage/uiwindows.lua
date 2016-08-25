--[[
	uiwindows
	2014.07.29
]]
uiwindows   = lua_class('uiwindows');
function uiwindows:_init()
	self.skin = "";
	self.name = nil;  --窗口的名称
end

function uiwindows:load()

	assert(#self.skin ~= 0, "are you forget to set layer skik?");

	local widget = ccs.GUIReader:getInstance():widgetFromJsonFile(self.skin);

	self.widget = widget;

	self.cc = cc.Layer:create();
	--self.cc:addChild(widget,1);
	--local layer_size  = self.cc:getContentSize();
	--local widget_size = widget:getContentSize();
	--加屏幕适配
	--widget:setPosition(cc.p((layer_size.width - widget_size.width)/2, (layer_size.height - widget_size.height)/2));
		-- self.black_root = ccs.GUIReader:getInstance():widgetFromJsonFile('gui/main/Ui_Black.ExportJson')
	-- self.cc:addChild(self.black_root,0,0)
	-- self.black_root:setPosition(0,0)
	--self.black_root:addChild(widget,1,1)

	self.black_root = ccs.GUIReader:getInstance():widgetFromJsonFile('gui/main/Ui_Black.ExportJson')
	self.cc:addChild(self.black_root,0,0)
	self.black_root:setPosition(0,0)
	--self.black_root:addChild(self.equip_layer.cc,1,1)
	self.black_root:addChild(self.widget,1)
	self.cc:registerScriptHandler(function(event_type)
		if event_type == "enter" then 
			self:on_enter();
		elseif event_type == "exit" then 
			self:on_exit();
		end
	end);
	self:finish_init();
	return self.cc;
end  

--子类重写
--可以设置些回调函数之类的
function uiwindows:finish_init()

end

function uiwindows:on_enter()
end 

function uiwindows:on_exit()
	--self.cc:removeAllChildren()
	--self.cc:removeFromParent(true);
	--self.cc:removeFromParent(true);
end 

-- --小部件初始化，没有测试
-- function uiwindows:ui_widget(...)
-- 	local obj = uiwindows.uiwindows();
-- 	obj.molayer = true;
-- 	obj:load()
-- 	return obj;
-- end


function uiwindows:get_widget(name)

	--local root = self.widget:getChildByName("login_button");
	--local button = root:getChildByName("login_button")
	return ccui.Helper:seekWidgetByName(self.widget, name);
end

--tag
function uiwindows:set_handler(name, handler)
	local widget = self:get_widget(name)
	widget:setTouchEnabled(true);	

	--注册handle
 --    local function touchEvent(sender, eventType)
	--     if eventType == ccui.TouchEventType.began then
	--         self:touch_began()
	--     elseif eventType == ccui.TouchEventType.moved then
	--     	self:touch_moved()
	--     elseif eventType == ccui.TouchEventType.ended then
	--     	self:touch_ended()
	--     elseif eventType == ccui.TouchEventType.canceled then
	--     	self:touch_cancle()
	--     end
	-- end
	-- widget:addTouchEventListener(touchEvent
	local function evenType(sender, eventype)
		handler(self, sender, eventype)
	end 
	widget:addTouchEventListener(evenType)

	-- widget:addTouchEventListener(function(sender, eventType)		
		
	-- 			handler(self, sender, eventType)

	-- end)
end
function uiwindows:touch_began()

end 
function uiwindows:touch_moved()

end 	
function uiwindows:touch_ended()

end 	
function uiwindows:touch_cancle()

end 		
function uiwindows:set_exit_handler(handler)
	self.exit_handle = handler;
end

function uiwindows:remove()
	print("doing remove!")
	--self.cc:removeFromParent(true);
end

function uiwindows:set_title(title)

end

function uiwindows:set_window_name(name)
	self.name = name
end

function uiwindows:get_window_name()
	return self.name
end


function uiwindows:show_help_button(bShow)

end
