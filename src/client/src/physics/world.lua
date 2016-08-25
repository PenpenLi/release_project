
local point			= import('physics.point')
local platform 		= import('physics.platform') 
local wall 			= import('physics.wall') 


local _objects = {}
local _points = {}
local _platforms = {}
local _walls = {}
local _counter = 0
Gravity = 3.2/FpsRate/FpsRate

function get_platforms(  )
	return _platforms
end

function get_platform_by_standing( standing )
	return _platforms[standing]
end

function init()
	_objects = {}
	_points = {}
	_platforms = {}
	_walls = {}
	_counter = 0
end

local function grab_id()
	_counter = _counter + 1
	return _counter
end

local _eps = 0.001

local function dotdet( x1, y1, x2, y2 )
	return x1*x2+y1*y2
end

local function det( x1, y1, x2, y2 )
	return x1*y2-x2*y1
end

local function dot( x1, y1, x2, y2, x3, y3 )
	return dotdet(x2-x1, y2-y1, x3-x1, y3-y1)
end

local function cmp(f)
	if math.abs(f) < _eps then 
		return 0
	elseif f < 0 then
		return -1
	else
		return 1
	end
end

local function between_cmp( x1, y1, x2, y2, x3, y3 )
	return cmp(dot(x1, y1, x2, y2, x3, y3))
end

local function cross( x1, y1, x2, y2, x3, y3 )
	return det(x2-x1, y2-y1, x3-x1, y3-y1)
end

local function calc_intersect( x1, y1, x2, y2, x3, y3, x4, y4 )
	--print(x1, y1, x2, y2, x3, y3, x4, y4)
	local c1 = cross(x1,y1, x2,y2, x3,y3)
	local c2 = cross(x1,y1, x2,y2, x4,y4)
	local c3 = cross(x3,y3, x4,y4, x1,y1)
	local c4 = cross(x3,y3, x4,y4, x2,y2)
	--单向平台 求交点
	--TODO 算法可能有bug
	if (cmp(c1)*cmp(c2))<0 and cmp(c3)>=0 and cmp(c4)<=0 then
		return (x3*c2-x4*c1)/(c2-c1), (y3*c2-y4*c1)/(c2-c1)
	end
	return nil
end

local function calc_intersect_wall( x1, y1, x2, y2, x3, y3, x4, y4 )
	--print(x1, y1, x2, y2, x3, y3, x4, y4)
	local c1 = cross(x1,y1, x2,y2, x3,y3)
	local c2 = cross(x1,y1, x2,y2, x4,y4)
	local c3 = cross(x3,y3, x4,y4, x1,y1)
	local c4 = cross(x3,y3, x4,y4, x2,y2)
	local d1 = cmp(c1)
	local d2 = cmp(c2)
	local d3 = cmp(c3)
	local d4 = cmp(c4)
	--规范相交
	if (d1*d2)<0 and (d3*d4)<0 then
		return true
		--交点
		--return (x3*c2-x4*c1)/(c2-c1), (y3*c2-y4*c1)/(c2-c1)
	end
	--非规范相交
	if (d1==0 and between_cmp(x3,y3,x1,y1,x2,y2)<=0) or 
		(d2==0 and between_cmp(x4,y4,x1,y1,x2,y2)<=0) or 
		(d3==0 and between_cmp(x1,y1,x3,y3,x4,y4)<=0) or 
		(d4==0 and between_cmp(x2,y2,x3,y3,x4,y4)<=0) then
		--非规范相交，交点可能不唯一
		return true
	end 

	return false
end

function create_point( x, y )
	local id = grab_id()
	local p = point.point(id, x, y)
	_objects[id] = p
	_points[id] = p
	return p
end

function create_rigid_in_entity( pnt_id, x1, y1, x2, y2 )
	if _platforms[pnt_id] == nil then
		local p = platform.platform(pnt_id, x1, y2, x2, y2)
		_platforms[pnt_id] = p
	end

	if _walls[pnt_id] == nil then
		local middle_x = x1 + math.abs(x2 - x1)
		local w = wall.wall(pnt_id, middle_x, y1 - 1, middle_x, y2)
		_walls[pnt_id] = w
	end
end

function create_platform( x1, y1, x2, y2 )
	local id = grab_id()
	local p = platform.platform(id, x1, y1, x2, y2)
	_objects[id] = p
	_platforms[id] = p
	return p
end


function create_wall( x1, y1, x2, y2 )
	local id = grab_id()
	local p = wall.wall(id, x1, y1, x2, y2)
	_objects[id] = p
	_walls[id] = p
	return p
end

function release_object(id)
	_objects[id] = nil
	_points[id] = nil
	_platforms[id] = nil
	_walls[id] = nil
end

function tick()
	--move platform
	
	--穿墙
	for point_id, pnt in pairs(_points) do
		if pnt.enable == true and pnt.no_obstacle == true then
			local vx = pnt.vx + pnt.ax
			local vy = pnt.vy + pnt.ay
			pnt.x = pnt.x + vx
			pnt.y = pnt.y + vy
			pnt.vx = vx 
			pnt.vy = vy 

		end
	end

	--碰撞
	for point_id, pnt in pairs(_points) do
		if pnt.enable == true and pnt.no_obstacle == false then
			local vx = pnt.vx + pnt.ax
			local vy = pnt.vy + pnt.ay
			local px = pnt.x + vx
			local py = pnt.y + vy
			local ps = _platforms[pnt.standing]

			if try_horizontal_offset(vx, vy,  point_id) == true then
				break
			end

			if ps ~= nil then
				if px < ps.pos1.x or px > ps.pos2.x then
					--左右离开平台
					pnt.standing = 0
					pnt.x = px
					pnt.y = ps.pos1.y
					pnt.vx = vx
					pnt.vy = 0
				elseif py > ps.pos1.y then
					--跳起离开平台
					pnt.standing = 0
					pnt.x = px
					pnt.y = py
					pnt.vx = vx
					pnt.vy = vy
				else
					--仍在平台上
					pnt.x = px
					pnt.y = ps.pos1.y
					pnt.vx = vx
					pnt.vy = 0
				end
			else
				local flag = false
				for platform_id, pf in pairs(_platforms) do
					local p1 = pf.pos1
					local p2 = pf.pos2
					local ix, iy = calc_intersect(pnt.x, pnt.y, px, py, p1.x, p1.y, p2.x, p2.y)
					if ix ~= nil then
						--落在平台上
						pnt.standing = platform_id
						pnt.recent_standing = platform_id
						pnt:trigger_on_ground()
						pnt.x = ix
						pnt.y = iy
						pnt.vx = vx	
						pnt.vy = vy * pnt.reverse
						pnt.bound_x1 = p1.x
						pnt.bound_x2 = p2.x
						flag = true
						break
					end
				end
				if flag == false then
					--仍在空中
					pnt.x = px
					pnt.y = py
					pnt.vx = vx
					pnt.vy = vy
				end
			end
		end

	end
end

function move_rigid(point_id)
	local pnt = _points[point_id]
	if pnt ~= nil and _walls[point_id] ~= nil and _platforms[point_id] ~= nil then
		local width = math.abs( _platforms[point_id].pos2.x - _platforms[point_id].pos1.x )
		local height = math.abs(_platforms[point_id].pos1.y - _walls[point_id].pos1.y) - 1 
		_platforms[point_id].pos1.x = pnt.x - width / 2
		_platforms[point_id].pos2.x = pnt.x + width / 2
		_platforms[point_id].pos1.y = pnt.y + height
		_platforms[point_id].pos2.y = pnt.y + height

		_walls[point_id].pos1.x = pnt.x
		_walls[point_id].pos2.x = pnt.x
		_walls[point_id].pos1.y = pnt.y - 1
		_walls[point_id].pos2.y = pnt.y + height
	end

end

function try_horizontal_offset(offset_x, offset_y, point_id)
	local pnt = _points[point_id]
	if pnt == nil then
		return false
	end

	local is_hit_wall = false
	local wall_x = nil
	local min_distance = math.huge
	local new_x = pnt.x + offset_x
	local new_y = pnt.y + offset_y
	for wall_id, pw in pairs(_walls) do
		if wall_id ~= point_id then
			local p1 = pw.pos1
			local p2 = pw.pos2
			local intersect = calc_intersect_wall(pnt.x, pnt.y, new_x, new_y, p1.x, p1.y, p2.x, p2.y)
			if intersect == true then
				is_hit_wall = true
				local temp_distance = math.abs(pnt.x - p1.x)
				if temp_distance < min_distance then
					min_distance = temp_distance
					wall_x = p1.x
				end
			end
		end
	end
	if is_hit_wall == true then
		pnt.x = wall_x + ( (pnt.x-wall_x) / min_distance )
		pnt.vx = pnt.vx * pnt.reverse
		pnt:trigger_hit_wall()
		return true
	end

	return false
end
