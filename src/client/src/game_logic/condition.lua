
local math_ext			= import( 'utils.math_ext' )
local command			= import( 'game_logic.command' )
local tutor				= import( 'game_logic.tutor' )
local collider			= import( 'game_logic.collider' )

function not_in_state( entity, state, args )
	local cs = entity.cur_state
	for _, s in pairs(args) do
		if cs == s then
			return false
		end
	end
	return true
end

function in_state( entity, state, args )
	return entity:in_state(args)
end

function jump_count( entity, state, args )
	return entity.double_jump == args
end

function charge_count( entity, state, args )
	return entity.charge_count > 0
end

function charge_count_up( entity, state, args )
	return entity.charge_count_up > 0
end

function in_air( entity, state, args )
	return not entity:on_ground()
end

function on_ground( entity, state, args )
	return entity:on_ground()
end

function falling( entity, state, args )
	local p = entity:get_velocity()
	return p.y < 0
end


function running_speed( entity, state, args )
	local p = entity:get_velocity()
	return not math_ext.float_equal(p.x,0)
end

function running( entity, state, args )
	return entity.cmd:get_stick_direction() ~= command.none
end

function rising( entity, state, args )
	local p = entity:get_velocity()
	return p.y > 0 and not entity:on_ground()
end

function enemy_in_range( entity, state, args )
	return entity.enemy_in_range
end

function enemy_not_in_range( entity, state, args )
	return not entity.enemy_in_range
end

function hitable( entity, state, args )
	return false
end

function in_bati( entity, state, args )
	-- 霸体
	return entity.cur_state == 'bati'
end

function hp_zero( entity, state, args )
	return entity.combat_attr.hp == 0 and entity.del ~= true
end

function tick_frame( entity, state, args )
	return entity.state_frame == args.frame
end

function trigger_by_enemy( entity, state, args )
	if entity.nearest_enemy ~= nil then
		local pos1 = entity.nearest_enemy:get_world_pos()
		local pos2 = entity:get_world_pos()
		local x_dis = math.abs(pos1.x - pos2.x)
		local y_dis = pos1.y - pos2.y

		local x_max = args.x or 50
		local y_b = args.y_below or -20
		local y_max = args.y or 100
		entity:set_trigger_enemy(entity.nearest_enemy)
		return x_dis < x_max and y_dis > y_b and y_dis < y_max
	end
	return false
end

function trigger_by_enemy_box( entity, state, args )
	local e = entity.nearest_enemy
	if e == nil then
		return false
	end

	local flipped = entity:is_flipped()
	local pos = entity:get_world_pos()
	local real_box = math_ext.fix_box(args, pos, flipped)
	entity:set_trigger_enemy(e)

	if collider.check_collide(real_box, e:get_world_hit_box()) then
		return true
	else
		return false
	end
end

function finish_attack( entity, state, args )
	return entity.attack_times == 0
end

function life_expired( entity, state, args )
	if entity.timetolive ~= nil then
		return entity.timetolive <= 0
	end
	return false
end

function ai_control( entity, state, args )
	return false
end

function mp_limit( entity, state, args )
	return entity.combat_attr.mp >= args.mp
end

function hp_limit( entity, state, args )
	return math.floor(entity.combat_attr.hp/entity.combat_attr.max_hp*100) > args.hp*100
end

function tutor_can_jump( entity, state, args )
	return tutor._character_limit.can_jump == true
end

function tutor_can_charge( entity, state, args )
	return tutor._character_limit.can_charge == true
end

function tutor_can_slashup( entity, state, args )
	return tutor._character_limit.can_slashup == true
end

function tutor_can_slashdown( entity, state, args )
	return tutor._character_limit.can_slashdown == true
end

function tutor_can_releaseskill( entity, state, args )
	return tutor._character_limit.can_releaseskill == true
end
