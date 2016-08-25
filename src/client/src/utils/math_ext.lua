local battle_const		= import( 'game_logic.battle_const' )
Eps = 0.001

function float_equal(v1, v2)
	return math.abs(v1-v2) < Eps
end

--WARNNING: 此函数会new table
function flipped_box(box, flipped)
	if flipped then
		return { -box[3], box[2], -box[1], box[4] }
	end
	return { box[1], box[2], box[3], box[4] }
end

--WARNNING: 此函数会new table
function fix_box(box, pos, flipped)
	if flipped then
		return { -box[3]+pos.x, box[2]+pos.y, -box[1]+pos.x, box[4]+pos.y }
	end
	return { box[1]+pos.x, box[2]+pos.y, box[3]+pos.x, box[4]+pos.y }
end


function p_get_distance(p1, p2)
    
    if p1 ~= nil and p2 ~= nil then 
        local x = p1.x - p2.x
        local y = p1.y - p2.y
        return math.sqrt( x*x+y*y)
    end

    return math.sqrt(0)
end

function p_sub(p1_x,p1_y, p2_x,p2_y)
	local x = p1_x - p2_x 
	local y = p1_y - p2_y
	return x, y
end

function p_add(p1_x,p1_y, p2_x,p2_y)

	local x = p1_x + p2_x
	local y = p1_y + p2_y
	return x ,y 
end

function  p_mul( p1_x,p1_y, factor )
	-- body
	local x = p1_x * factor 
	local y = p1_y * factor
	return x, y
end

function p_getLength( pt_x, pt_y )
	-- body
	return math.sqrt( pt_x * pt_x + pt_y * pt_y )
end

function p_normalize( pt_x, pt_y )
	-- body
	local length = p_getLength( pt_x, pt_y )
    if 0 == length then
    	local x = 1.0
    	local y = 0.0 
        return x, y 
    end
    local x = pt_x / length
    local y = pt_y / length
    return x, y
end

-- 权重随机
-- 传入数组，返回随机中了的index
function weight_random( arr )
	--math.randomseed(os.time())
	local sum = 0
	for i, v in pairs(arr) do
		sum = sum + v
	end
	local rand = math.random(sum)
	for i, v in pairs(arr) do
		if rand <= v then
			return i
		else
			rand = rand - v
		end
	end
end

function get_star_id( battle_id )

	local d = data.fuben[battle_id]
	if d == nil then
		return 0
	end
	local fuben_id = d.instance_id
	local chapter_id = d.chapter_id
	local star_id = chapter_id * battle_const.StarSpace + fuben_id

	return star_id
end
