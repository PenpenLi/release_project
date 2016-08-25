local battle_const		= import( 'game_logic.battle_const' )
local command			= import( 'game_logic.command' )


function check_collide(a, real_hit_box)
	-- mao
	if real_hit_box == nil then
		return nil
	end

	local b = nil
	for i,v in ipairs(real_hit_box) do
		b = v
		local ok = true

		if a[3] < b[1] or a[1] > b[3] then
			ok = false
		end
		if a[4] < b[2] or a[2] > b[4] then
			ok = false
		end
		if ok then
			return i
		end
	end
	return nil
end

function in_box(pos, box)
	return pos.x >= box[1] and pos.x <= box[3] and pos.y >= box[2] and pos.y <= box[4]
end

function check_attack_side(att_pos, hit_box_d, hit_pos, on_ground, auto_state)
	local fix_dis = -10
	if auto_state ~= nil then
		fix_dis = 0
	end

	for i,v in ipairs(hit_box_d) do
		local hit_box = v
		local ok = true

		if (att_pos.y + battle_const.AutoAttY < hit_box[2]) or (att_pos.y > hit_box[4]) then
			ok = false
		end
		
		if (att_pos.x + battle_const.AutoAttX + fix_dis < hit_box[1]) or (att_pos.x - battle_const.AutoAttX - fix_dis > hit_box[3]) then
			ok = false
		end

		local box_x = (hit_box[1] + hit_box[3])/2
		if ok and (box_x < att_pos.x) then
			return command.stick_left
		end

		if ok then
			return command.stick_right
		end
	end
	return nil
end

function check_same_level(pos1, pos2)
	return math.abs(pos1.y-pos2.y) < battle_const.MonsterAlertLevel
end
