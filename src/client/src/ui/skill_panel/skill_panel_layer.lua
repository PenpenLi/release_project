local layer = import('world.layer')
local avatar			= import( 'model.avatar' )
local item				= import( 'model.item' )
local skill				= import( 'model.skill' )
skill_panel_layer = lua_class('skill_panel_layer',layer.layer)


sprites = {}

function skill_panel_layer:_init(  )
	-- body
	super(skill_panel_layer,self)._init()

	self:create_skill_panel(  )
	self.istouch = false
	self:init_skill()
	self.player = avatar.avatar()
end

function skill_panel_layer:create_skill_panel(  )
	-- body
	self.skill_root = ccs.GUIReader:getInstance():widgetFromJsonFile('gui/main/skill_bag.ExportJson')

	self.cc:addChild(self.skill_root)
	
	local function touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.began then

        elseif eventType == ccui.TouchEventType.moved then
			
		elseif eventType == ccui.TouchEventType.ended then
			self:close_button_callback_event()
		elseif eventType == ccui.TouchEventType.canceled then
			
		end
    end

    self.close_button = self.skill_root:getChildByName('close_button')
    self.close_button:addTouchEventListener(touchEvent)
	
    
end

function skill_panel_layer:close_button_callback_event(  )
	-- body
	--
	self:set_visible(false)
	local function callFunc(  )
		self.istouch = true
	end
	local callFuncObj=cc.CallFunc:create(callFunc)
	self:play_action("Ui-Battle.ExportJson", "界面-up")
	self:play_action("Ui-Battle.ExportJson", "boss-up",callFuncObj)
	
end

function skill_panel_layer:set_visible( isvisble , obj )
	-- body
	self.cc:setVisible(isvisble)
	if obj ~= nil then
		self.obj = obj
	end
end

function skill_panel_layer:get_istouch(  )
	-- body
	return self.istouch
end


function  skill_panel_layer:init_skill(  )

	--换技能显示思路逻辑 暂时手势换技能效果
	-- body
	self.touch_type = 0		--记录点击已选技能面板时，技能面板的技能类型，与未选技能按钮进行类型比较

	--按钮的属性有：图片id 、skill_type技能类型(：1：上划 2：下划 3：左右冲)； 
	for i=1 ,4 do
		local skill_button = ccui.Helper:seekWidgetByName(self.skill_root, string.format('skill_grid%d',i))

		--图片带有技能类型，和技能 id
		local sprite = cc.Sprite:create(string.format('gui/skill_img/%d.png',i))
		if i ==4 then --测试相同类型的技能替换							
			--根据图片设置按钮类型,按钮带有 图片id 和技能类型、技能id
			skill_button.skill_type =2
			skill_button.img_id = 4
			skill_button.skill_id = 4
			skill_button:addChild(sprite)
			sprite:setPosition(skill_button:getLayoutSize().width/2,skill_button:getLayoutSize().height/2)
		else							
			--根据图片设置按钮类型,按钮带有 图片id 和技能类型、技能id
			skill_button.skill_type = i
			skill_button.img_id = i
			skill_button.skill_id = i
			skill_button:addChild(sprite)
			sprite:setPosition(skill_button:getLayoutSize().width/2,skill_button:getLayoutSize().height/2)
		end

		local function touchEvent(sender,eventType)
			if eventType == ccui.TouchEventType.began then
				---触摸到未选技能按钮类型与可选择技能按钮类型的比较，同样就交换
				if self.touch_type == skill_button.skill_type then
					skill_button:removeAllChildren()

					--获取出战面板被点击的按钮
					local s_button = ccui.Helper:seekWidgetByName(self.skill_root, string.format('skilled_grid%d',skill_button.skill_type))
					--如果出战按钮也有技能图片，就与未出战按钮图标互换，没有就直接安放技能图标到已出战按钮。
					if #s_button:getChildren() ~= 0 then
						s_button:removeAllChildren()
						local img = cc.Sprite:create(string.format('gui/skill_img/%d.png',skill_button.img_id))
						local img2 = cc.Sprite:create(string.format('gui/skill_img/%d.png',s_button.img_id))
						local img_id = s_button.img_id
						local skill_id = s_button.skill_id
						s_button.img_id = skill_button.img_id
						s_button.skill_id = skill_button.skill_id
						skill_button.skill_id = skill_id
						skill_button.img_id = img_id 
						s_button:addChild(img)
						skill_button:addChild(img2)
						skill_button.skill_type=s_button.skill_type
						img:setPosition(skill_button:getLayoutSize().width/2,skill_button:getLayoutSize().height/2)
						img2:setPosition(skill_button:getLayoutSize().width/2,skill_button:getLayoutSize().height/2)
						self.touch_type = 0

					else
						
						local img = cc.Sprite:create(string.format('gui/skill_img/%d.png',skill_button.img_id))
						s_button.img_id = skill_button.img_id
						s_button.skill_id = skill_button.skill_id
						s_button:addChild(img)
						skill_button.skill_type=-1 	--代表这个未选按钮没有技能安放
						img:setPosition(skill_button:getLayoutSize().width/2,skill_button:getLayoutSize().height/2)
						self.touch_type = 0
					end

				end

        	elseif eventType == ccui.TouchEventType.moved then
			
			elseif eventType == ccui.TouchEventType.ended then
				
			elseif eventType == ccui.TouchEventType.canceled then
			
			end
		end
		 skill_button:addTouchEventListener(touchEvent)
	end

	--初始化已出战面板按钮
	for i=1 ,4 do
		local skill_button = ccui.Helper:seekWidgetByName(self.skill_root, string.format('skilled_grid%d',i))
		---	固定类型
		skill_button.skill_type = i
		skill_button.img_id = 0
		skill_button.skill_id = 0
		local function touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.began then
			self.touch_type = skill_button.skill_type
			self.get_to_button = skill_button
        elseif eventType == ccui.TouchEventType.moved then
			
		elseif eventType == ccui.TouchEventType.ended then
			
		elseif eventType == ccui.TouchEventType.canceled then
			
		end
    end
    	skill_button:addTouchEventListener(touchEvent)
	end


end

