local layer						= import( 'world.layer' )
local battle_layer				= import( 'world.battle_layer' )
local fast_actions				= import( 'utils.actions' )
local camera_mgr				= import( 'game_logic.camera_mgr' )
local command_mgr				= import( 'game_logic.command_mgr' )
local battle					= import( 'game_logic.battle' )
local show_global				= import( 'utils.show_global' )
local battle_const				= import( 'game_logic.battle_const' )
local battle_scene				= import( 'world.battle_scene' )
local main_scene				= import( 'world.main_scene' )
local chose_characters_scene 	= import( 'world.chose_characters_scene' )
local model						= import( 'model.interface' )
local login_scene				= import( 'world.login_scene' )
local music_mgr					= import( 'world.music_mgr' )
local locale					= import( 'utils.locale' )
local loading_layer				= import( 'ui.loading_layer.loading_layer' )
local timer						= import( 'utils.timer' )
local ui_mgr 					= import( 'ui.ui_mgr' ) 
local loading_scene 			= import('world.loading_scene')

local _scene = nil
local _show_global = nil
_temp_scene = nil
local _is_loading = false

function get_cur_battle()
	if _scene == nil then
		return nil
	end
	return _scene.logic
end

-- scene
function get_scene()
	return _scene
end

function show_loading()
	_is_loading = true
	_scene: show_loading()
end

function hide_loading()
	_is_loading = false
	_scene: hide_loading()
end

function is_loading()
	return _is_loading
end

function init()
	locale.set_locale( Locale )
	if cc.UserDefault:getInstance():getBoolForKey('bg_music_on', true) then
		music_mgr.preload_normal_bg_music()
	else
		if music_mgr._is_bg_enable then
			music_mgr.alter_bg_music_enable()
		end
	end
	if not cc.UserDefault:getInstance():getBoolForKey('game_music_on', true) then
		if music_mgr._is_ef_enable then
			music_mgr.alter_ef_sound_enable()
		end
	end
	camera_mgr.init()
	enter_scene(import( 'world.login_scene' ), 'login_scene')
	register_timer()
end

function enter_scene(mod, name)
	local _loading_scene
	if _scene ~= nil then
		
		_loading_scene = loading_scene.loading_scene()
		_loading_scene:enter_scene()
		_scene:release()
	end
	
	local function func()
		ccs.ArmatureDataManager:destroyInstance()
		cc.Director:getInstance():purgeCachedData()
		_scene = mod[name]()
		if _scene ~= nil then
			_scene: enter_scene()
			ui_mgr.create_wait_ui()
			if _loading_scene ~= nil then
				timer.schedule_once(0, nil, function() _loading_scene:scene_release() print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo()) end)
			end
		end
	end
	timer.schedule_once(0, nil, func)
end

function register_timer()
	local timer_tick = cc.Director:getInstance():getScheduler():scheduleScriptFunc(timer.tick, 1, false)
end

-- 变换场景
function enter_battle_scene( scene_id )
	local _loading_scene
	if _scene ~= nil then
		_loading_scene = loading_scene.loading_scene()
		_loading_scene:enter_scene()
		_scene:release()
	end
	local function func()
		ccs.ArmatureDataManager:destroyInstance()
		cc.Director:getInstance():purgeCachedData()
		_scene = battle_scene.battle_scene(scene_id)
		if _scene ~= nil then
			_scene: enter_scene()
			_scene: scene_tick()
			if _loading_scene ~= nil then
				timer.schedule_once(0, nil, function()  _loading_scene:scene_release() print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo()) end)
			end
		end
	end
	timer.schedule_once(0, nil, func)
end

function enter_battle( scene_id )
	collectgarbage("collect")
	_scene:enter_battle( scene_id )
	collectgarbage("collect")
end


-- 抖抖屏幕
function shake_scene( _duration, _strength_x, _strength_y, _offset_x, _offset_y )
	print('shake scene')
	local duration = _duration or 0.1
	local strength_x = _strength_x or 2
	local strength_y = _strength_y or 2
	local offset_x = _offset_x or 0
	local offset_y = _offset_y or 0

	_scene.cc:runAction(fast_actions.shake_action( duration, strength_x, strength_y, offset_x, offset_y ))
end 
function  shake_right(_duration, _strength_x, _strength_y, _offset_x, _offset_y)
	-- print('shake right')

	local duration = _duration or 0.1
	local strength_x = _strength_x or 2
	local strength_y = _strength_y or 2
	local offset_x = _offset_x or 4
	local offset_y = _offset_y or 0

	_scene.cc:runAction(fast_actions.shake_action(duration, strength_x, strength_y, offset_x, offset_y))
end
function shake_left(_duration, _strength_x, _strength_y, _offset_x, _offset_y)
	-- print('shake left')

	local duration = _duration or 0.1
	local strength_x = _strength_x or 2
	local strength_y = _strength_y or 2
	local offset_x = -_offset_x or -4
	local offset_y = _offset_y or 0

	_scene.cc:runAction(fast_actions.shake_action(duration, strength_x, strength_y, offset_x, offset_y))
end 
function  shake_up()
	-- print('shake up')
	_scene.cc:runAction(fast_actions.shake_action(0.1, 2, 2, 0, 5))
end
function shake_down()
	-- print('shake down')
	_scene.cc:runAction(fast_actions.shake_action(0.1, 2, 2, 0, -5))
end 
function fast_zoom()
	_scene.cc:runAction(fast_actions.fast_zoom(1.02))
end
