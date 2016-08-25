local math_ext			= import('utils.math_ext')

local _main_entity = nil
local _cur_pos = cc.p(0,0)
local _bound = cc.p(0,0)
local Mid = cc.p(VisibleSize.width/2, VisibleSize.height/2)

local _x_speed = 0
local _y_speed = 0
local _rate   	  = 0.0002
local _distance   = 100

function init()
	_main_entity = nil
	_cur_pos = cc.p(0,0)
	_bound = cc.p(0,0)
	_x_speed = 0
	_y_speed = 0
end

function set_player( entity )
	print('camera player', entity.id)
	_main_entity = entity
end

function set_bound( bx, by )
	_bound = cc.p(bx, by)
end

function fix_scene_pos(pos)
	if pos.x < 0 then
		pos.x = 0
	end
	if pos.y < 0 then
		pos.y = 0
	end
	if pos.x > _bound.x then
		pos.x = _bound.x
	end
	if pos.y > _bound.y then
		pos.y = _bound.y
	end
end


local function fix_bound(pos)
	if pos.x < Mid.x then
		pos.x = Mid.x
	end
	if pos.y < Mid.y then
		pos.y = Mid.y
	end
	if pos.x > _bound.x-Mid.x then
		pos.x = _bound.x-Mid.x
	end
	if pos.y > _bound.y-Mid.y then
		pos.y = _bound.y-Mid.y
	end
end

-- WARNNING: 没有拷贝！不要修改！
function get_camera_pos()
	return _cur_pos
end

function slide_screen()
	--滑屏
	local pos = _main_entity:get_world_pos_copy()
	pos.y = pos.y + 100
	if _main_entity:is_flipped() == true then
		pos.x = pos.x - _distance
	else
		pos.x = pos.x + _distance
	end
	local dis = math_ext.p_get_distance(pos, _cur_pos)
	fix_bound(pos)
	_x_speed = (pos.x-_cur_pos.x)*_rate*dis
	_y_speed = (pos.y-_cur_pos.y)*_rate*dis
	_cur_pos.x = _cur_pos.x + _x_speed
	_cur_pos.y = _cur_pos.y + _y_speed
end 

function tick()
	if _main_entity == nil then
		return
	end
	slide_screen()
	fix_bound(_cur_pos)
end

function world_to_screen( pos )
	return cc.p(Mid.x + pos.x - _cur_pos.x, Mid.y + pos.y - _cur_pos.y)
end

function screen_to_world( pos )
	return cc.p(pos.x - Mid.x + _cur_pos.x, pos.y - Mid.y + _cur_pos.y)
end
