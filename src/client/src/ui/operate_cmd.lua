local command		= import( 'game_logic.command' )
local command_mgr	= import( 'game_logic.command_mgr' )
local math_ext 		= import('utils.math_ext')
local _real_cmd = nil
local _touch_side = {}								--存储刚开始点击位置
local _enable= true
function set_real_cmd(cmd)
	_real_cmd = cmd;
end

function enable(flag)
	_enable = flag
end

function  setup_operate_cmd(node, eventDispatcher,operate_layer)
	-- body
	local listener = cc.EventListenerTouchAllAtOnce:create()
	listener:registerScriptHandler(function(touches, event)
	local size  = cc.Director:getInstance():getWinSize()

	for _, touch in ipairs(touches) do
			local id = touch:getId()
			local pos = touch:getLocation()
			

			if pos.x < size.width/2 and _real_cmd ~= nil then
				_touch_side[id] = command_mgr.EnumTouchSide.left
				--operate_layer:showJoystick(pos,_real_cmd)
				_real_cmd.direction = operate_layer:showJoystick(pos)
			else
				_touch_side[id] = command_mgr.EnumTouchSide.right
			end
	end
	return true
	end,cc.Handler.EVENT_TOUCHES_BEGAN )

	listener:registerScriptHandler(function(touches, event)	
	local size  = cc.Director:getInstance():getWinSize()

	--operate_layer.m_joystick:stopAllActions()
	for _, touch in ipairs(touches) do
		local id = touch:getId()
		--local start = cc.p(operate_layer.m_joystickBg:getPosition())
		local start_x, start_y = operate_layer.m_joystickBg:getPosition()
		local pos = touch:getLocation()
		if _enable == true then  ---没有失败界面就更新摇杆
					
			if _touch_side[id] == command_mgr.EnumTouchSide.left and _real_cmd ~= nil then
				--local distance =cc.pGetLength(cc.pSub(start,pos))
				--local direction = cc.pNormalize(cc.pSub(pos,start))

				local distance = math_ext.p_getLength(math_ext.p_sub(start_x,start_y,pos.x,pos.y))
				local direction_x,direction_y = math_ext.p_normalize(math_ext.p_sub(pos.x,pos.y,start_x,start_y))

				_real_cmd.direction = operate_layer:updateJoystick(direction_x,direction_y,distance )
			end
		end
		
	end
		return true
	end,cc.Handler.EVENT_TOUCHES_MOVED )

	listener:registerScriptHandler(function(touches, event)
		local size  = cc.Director:getInstance():getWinSize()
		for _, touch in ipairs(touches) do
			local id = touch:getId()
			if _touch_side[id] == command_mgr.EnumTouchSide.left and _real_cmd ~= nil then

				--按住屏幕，同时失败或者胜利，手指同时按住并拖动，摇杆会显示的bug
				-- 是不是失败了，或者是成功了，是在拖动，就隐藏摇杆，
				if _enable == false then 
					operate_layer:hideJoystick2()
					_real_cmd.direction = command.none
					_enable = true
					return
				end

			
				---没有失败界面就更新摇杆
				operate_layer:hideJoystick()
				--控制角色移动
				_real_cmd.direction = command.none
				---operate_layer.m_joystick:stopAllActions()	
			end
		end
		
	end,cc.Handler.EVENT_TOUCHES_ENDED )
	
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node) --0
	--eventDispatcher:addEventListenerWithFixedPriority(listener, -120)
end


