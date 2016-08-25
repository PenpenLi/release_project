
local command				= import( 'game_logic.command' )
local cmd_handler			= import( 'game_logic.cmd_handler' )
local math_ext				= import( 'utils.math_ext' )
local motion_streak 	= import( 'ui.motion_streak' ) 

local skill_button		= import('ui.skill_button')
local _pre_pos = {}
local _pre_dir = {}
local _touch_side = {}
local real_cmd = nil

EnumStick = {
	touch_left		= 0,
	stick_left		= 6,
	stick_right		= 7,
	stick_up		= 8,
	stick_down		= 9,
}

EnumCommand = {
	touch_right		= 1,
	slide_left		= 2,
	slide_right		= 3,
	slide_up		= 4,
	slide_down		= 5,
}

EnumTouchSide = {
	left = 0,
	right = 1,
}

EnumDirection = {
	unknown = 0,
	left = 1,
	right = 2,
	up = 3,
	down = 4,
	begin = 5,
}

SlideDistance = 25
StickDistance = 20
CommandTtl = 10

LeftTouchArea = 200
RightTouchArea = 400


function _slide_callback( pos, op )
	slide_callback(pos,op)
end

function _stick_callback( pos, op )
	stick_callback(pos,op)
end

function slide_callback( pos, op )
	if real_cmd == nil then
		return
	end
	if op == EnumDirection.unknown then
		real_cmd.command[command.touch_right] = CommandTtl

	elseif op == EnumDirection.left then
		real_cmd.command[command.slide_left] = CommandTtl

	elseif op == EnumDirection.right then
		real_cmd.command[command.slide_right] = CommandTtl

	elseif op == EnumDirection.up then
		real_cmd.command[command.slide_up] = CommandTtl

	elseif op == EnumDirection.down then
		real_cmd.command[command.slide_down] = CommandTtl

	elseif op == EnumDirection.begin then
		real_cmd.command[command.touch_right_begin] = 10
	end
end

function stick_callback( pos, op )
	if real_cmd == nil then
		return
	end
	if op == EnumDirection.unknown then
		real_cmd.direction = command.none
	elseif op == EnumDirection.left then
		real_cmd.direction = command.stick_left
	elseif op == EnumDirection.right then
		real_cmd.direction = command.stick_right
	elseif op == EnumDirection.up then
		real_cmd.direction = command.stick_up
	elseif op == EnumDirection.down then
		real_cmd.direction = command.stick_down
	end
end

local function getDirection( pos )
	if math.abs(pos.x) == math.abs(pos.y) then
		return EnumDirection.unknown
	elseif math.abs(pos.x) < math.abs(pos.y) then
		if pos.y < 0 then
			return EnumDirection.down
		else
			return EnumDirection.up
		end
	else
		if pos.x < 0 then
			return EnumDirection.left
		else
			return EnumDirection.right
		end
	end
	return EnumDirection.unknown
end

local function slide_move(id, pos)
	local pre_pos = _pre_pos[id]
	if math_ext.p_get_distance(pos, pre_pos) > SlideDistance then
		pre_dir = _pre_dir[id]
		new_dir = getDirection( cc.pSub(pos, pre_pos) )
		if pre_dir ~= new_dir then
			_slide_callback(pre_pos, new_dir)
			_pre_dir[id] = new_dir
		end
		_pre_pos[id] = pos
	end
end

local function slide_end(id, pos)
	local pre_pos = _pre_pos[id]
	local pre_dir = _pre_dir[id]
	if math_ext.p_get_distance(pos, pre_pos) >= SlideDistance then
		pre_dir = getDirection( cc.pSub(pos, pre_pos) )
	end
	if pre_dir == EnumDirection.unknown then
		_slide_callback(pre_pos, pre_dir)
	end
	_pre_pos[id] = nil
	_pre_dir[id] = nil
end

local function stick_begin(id, pos)
end

local function stick_move(id, pos)
	local pre_pos = _pre_pos[id]
	if math_ext.p_get_distance(pos, pre_pos) >= StickDistance then
		_stick_callback( pre_pos, getDirection( cc.pSub(pos, pre_pos) ) )
	else
		_stick_callback( pre_pos, EnumDirection.unknown )
	end
end

local function stick_end(id, pos)
	_stick_callback( pre_pos, EnumDirection.unknown )
end

local function stick_begin2(id, pos)
	if pos.x < LeftTouchArea then
		_stick_callback( pos, EnumDirection.left )
	elseif pos.x < RightTouchArea then
		_stick_callback( pos, EnumDirection.right )
	end
end

local function stick_move2(id, pos)
	if pos.x < LeftTouchArea then
		_stick_callback( pos, EnumDirection.left )
	elseif pos.x < RightTouchArea then
		_stick_callback( pos, EnumDirection.right )
	else
		_stick_callback( pos, EnumDirection.unknown )
	end
end

local function stick_end2(id, pos)
	_stick_callback( pre_pos, EnumDirection.unknown )
end

local function on_touch_begin(touches, event)
	--print('on_touch_begin')

	for _, touch in ipairs(touches) do
		local id = touch:getId()
		local pos = touch:getLocation()
		_pre_pos[id] = pos
		_pre_dir[id] = EnumDirection.unknown
		motion_streak.add_motion(id, pos.x, pos.y)
	--	motion_streak.setPosition(id,pos.x,pos.y)
		if pos.x < VisibleSize.width/2 then
			_touch_side[id] = EnumTouchSide.left
		else
			_touch_side[id] = EnumTouchSide.right
			_slide_callback(pos, EnumDirection.begin)
		end
	end
end

local function on_touch_move(touches, event)
	--print('on_touch_move')
	for _, touch in ipairs(touches) do
		local id = touch:getId()
		local pos = touch:getLocation()
		motion_streak.setPosition(id,pos.x,pos.y)
		if pos.x > VisibleSize.width/2 then
		if _touch_side[id] == EnumTouchSide.right then
			slide_move(id, pos)
			
	end
		end
	end
end

local function on_touch_end(touches, event)
	--print('on_touch_end')
	on_touch_move(touches, event)
	for _, touch in ipairs(touches) do
		local id = touch:getId()
		local pos = touch:getLocation()
		motion_streak.remove_motion(id)
		if _touch_side[id] == EnumTouchSide.right then
			slide_end(id, pos)
		end
	end
end

function get_player_cmd()
	return real_cmd
end

function register_player_cmd( cmd )
	real_cmd = cmd
end

function setup_touches( node, eventDispatcher )
	print('setup_touches' )
	local listener = cc.EventListenerTouchAllAtOnce:create()
	listener:registerScriptHandler(on_touch_begin,cc.Handler.EVENT_TOUCHES_BEGAN )
	listener:registerScriptHandler(on_touch_move,cc.Handler.EVENT_TOUCHES_MOVED )
	listener:registerScriptHandler(on_touch_end,cc.Handler.EVENT_TOUCHES_ENDED )
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)
end

function skill_command( skill )
	if real_cmd == nil then
		return
	end
	real_cmd.command[skill] = CommandTtl
end

function jump_command( jump )
	if real_cmd == nil then
		return
	end
	real_cmd.command[jump] = CommandTtl
end
