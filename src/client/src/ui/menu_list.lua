local ui_const			= import( 'ui.ui_const' )

menu_list = lua_class('menu_list')


function menu_list:_init( widget,name )

	self.i=1
	self:creat_menu_ui( widget,name )
end

function menu_list:creat_menu_ui( widget,name )
	-- body
	self.zhu_button = widget:getChildByName(name)
	local size = cc.Director:getInstance():getVisibleSize()
	local x = size.width-self.zhu_button:getLayoutSize().width/2
	local y = size.height-self.zhu_button:getLayoutSize().height/2
	--print('宽',self.zhu_button:getLayoutSize())
	self.button_list = widget:getChildByName('button_all')

	self.button_list:setPosition(x,y)
	self.zhu_button:setPosition(x,y)

	local function callFunc(  )
		self.zhu_button:setTouchEnabled(true)
	end
	local function callFunc2(  )
		self.zhu_button:setTouchEnabled(true)
	end

	local function selectedEvent(sender,eventType)
		if self.i%2~=0 then
			self.zhu_button:setTouchEnabled(false)
			self.zhu_button:setSelectedState(false)
			local callFuncObj=cc.CallFunc:create(callFunc)
			self.i=self.i+1
			self.anin2=self:play_action("NewUi_1.ExportJson", "open",callFuncObj)
			
		else
			self.i=self.i+1
			local size = cc.Director:getInstance():getVisibleSize()
			self.zhu_button:setTouchEnabled(false)
			self.zhu_button:setSelectedState(true)
			local callFuncObj=cc.CallFunc:create(callFunc2)
			self.anin2=self:play_action("NewUi_1.ExportJson", "collect",callFuncObj)
		end
	end  
	self.zhu_button:addTouchEventListener(selectedEvent)

end

function  menu_list:touch_event( touchPoint )
	-- body
	 local istouch=true
	--在按钮以外的范围就返回false，传递给其他层
	if touchPoint.y < self.zhu_button:getPositionY()-self.zhu_button:getLayoutSize().height/2 then
				istouch=false
			end
	if touchPoint.y >self.zhu_button:getPositionY()+self.zhu_button:getLayoutSize().height/2 then
				istouch=false

			end
	if touchPoint.x < self.zhu_button:getPositionX()-self.zhu_button:getLayoutSize().width/2 then
				istouch=false
			end
	if touchPoint.x  > self.zhu_button:getPositionX()+self.zhu_button:getLayoutSize().width/2 then
				istouch=false
	 end

	return istouch

end
function menu_list:stop(  )
	-- body
	if self.anin2~=nil then
		self.anin2:stop()
	end
	if self.anin1~=nil then
		self.anin1:stop()
	end
end

