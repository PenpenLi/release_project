local command		= import( 'game_logic.command' )
local command_mgr	= import( 'game_logic.command_mgr' )

local _real_cmd = nil
local _real_layer = nil 
local _key_table = { W = 143, A = 121, S = 139, D = 124,
	K = 131, I = 129, O = 135, Left = 132, Z = 146, X = 144, C = 123,
 	R = 24, L = 23, UP = 25, Down = 26, Jump = 130 , U = 141, ['M'] = 133, [','] = 69, ['.']= 71}
local _key_map = {}
_key_map[command.stick_left] = 0
_key_map[command.stick_right] = 0

local function init()
	_key_map[command.stick_left] = 0
	_key_map[command.stick_right] = 0
end

function set_real_cmd(cmd)
	_real_cmd = cmd
	init()
end

local function on_key_pressed(keyCode, event)
	if _real_cmd == nil then
		return
	end
	if keyCode == _key_table["W"] then
		_real_cmd.command[command.touch_right_begin] = 19
	elseif keyCode == _key_table["A"] then 
		_real_cmd.direction = command.stick_left
		_key_map[command.stick_left] = 1
	elseif keyCode == _key_table["S"] then
		_real_cmd.command[command.slide_down] = command_mgr.CommandTtl
	elseif keyCode == _key_table["D"] then
		_real_cmd.direction = command.stick_right
		_key_map[command.stick_right] = 1
	elseif keyCode == _key_table["R"] or keyCode == _key_table["Left"] then
		_real_cmd.command[command.slide_right] = command_mgr.CommandTtl
	elseif keyCode == _key_table["L"] or keyCode == _key_table["K"] then
		_real_cmd.command[command.slide_left] = command_mgr.CommandTtl	
	elseif keyCode == _key_table["UP"] or keyCode == _key_table["I"]  then
		_real_cmd.command[command.slide_up] = command_mgr.CommandTtl
	elseif keyCode == _key_table["Down"] or keyCode == _key_table["O"] then
		_real_cmd.command[command.slide_down] = command_mgr.CommandTtl
	elseif keyCode ==  _key_table["Jump"] then 
		_real_cmd.command[command.touch_right_begin] = 19
	elseif keyCode == _key_table["M"]  then 
		_real_cmd.command[command.skill_1] = command_mgr.CommandTtl
	elseif keyCode == _key_table[","]  then 
		_real_cmd.command[command.skill_2] = command_mgr.CommandTtl
	elseif keyCode == _key_table["."]  then 
		_real_cmd.command[command.skill_3] = command_mgr.CommandTtl
	elseif keyCode == _key_table["U"]  then 
		--_real_cmd.command[command.skill_2] = CommandTtl
    elseif keyCode == _key_table['T'] or keyCode == _key_table['H'] then 
     
	end
end

local function on_key_released(keyCode, event, uilayer)
	if _real_cmd == nil then
		return
	end
	if keyCode == _key_table["W"] then
		_real_cmd.command[command.touch_right] = command_mgr.CommandTtl
	elseif keyCode == _key_table["A"] then
		_key_map[command.stick_left] = 0
		if _key_map[command.stick_right] == 1 then
			_real_cmd.direction = command.stick_right
		else
			_real_cmd.direction = command.none
		end
	elseif keyCode == _key_table["S"] then
	elseif keyCode == _key_table["D"] then
		_key_map[command.stick_right] = 0
		if _key_map[command.stick_left] == 1 then
			_real_cmd.direction = command.stick_left
		else
			_real_cmd.direction = command.none
		end
	elseif keyCode == _key_table["R"] or keyCode == _key_table["Left"] then
	elseif keyCode == _key_table["L"] or keyCode == _key_table["K"] then
	elseif keyCode == _key_table["UP"] or keyCode == _key_table["I"]  then
	elseif keyCode == _key_table["Down"] or keyCode == _key_table["O"] then
	elseif keyCode == _key_table["Jump"] then
		_real_cmd.command[command.touch_right] = command_mgr.CommandTtl
    elseif keyCode ==  cc.KeyCode.KEY_MENU or keyCode == cc.KeyCode.KEY_ESCAPE or keyCode == cc.KeyCode.KEY_BACKSPACE then 

        _real_layer:close_button_callback_event()
	end
end 

function setup_keyboard_cmd(node, eventDispatcher, uilayer)
	_real_layer = uilayer
    local listener = cc.EventListenerKeyboard:create();
    listener:registerScriptHandler(on_key_pressed, cc.Handler.EVENT_KEYBOARD_PRESSED);
    listener:registerScriptHandler(on_key_released,cc.Handler.EVENT_KEYBOARD_RELEASED);
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node);
end
