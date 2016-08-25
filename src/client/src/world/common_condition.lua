
function done_basic_tutor( player )
	return player:get_tutor_done()
end

function reach_level( player, args )
	--人物达到某个等级
	if args == nil then 
		return true
	else
		return player:get_level() >= tonumber(args)
	end
end

function finish_battle( player, args )
	--完成某个关卡
	if args == nil then
		return player:get_fuben() >= 0
	else
		return player:get_fuben() >= tonumber(args)
	end
end

function receive_quest_reward( player, args )
	--领取某个任务奖励
	if args == nil then
		return false
	else
		return player:is_quest_received( args )
	end
end

function receive_quest_daily_reward( player, args )
	--领取某个任务奖励
	if args == nil then
		return false
	else
		return player:is_quest_daily_received( args )
	end
end

function loaded_soul( player, args )
	local check_id = tonumber(args)
	for k, v in pairs(player:get_loaded_skills()) do
		if v.id == check_id then
			return true
		end
	end
	return false
end

function first_lot_coin( player, args )
	return player:check_guide_state( 'first_lot_coin' )
end

function first_lot_gem( player, args )
	return player:check_guide_state( 'first_lot_gem' )
end

function first_quest_reward( player, args )
	return player:check_guide_state( 'first_quest_reward' )
end

function first_proficiency( player, args )
	return player:check_guide_state( 'first_proficiency' )
end

function first_eq_activation( player, args )
	return player:check_guide_state( 'first_eq_activation' )
end

function first_eq_strengthen( player, args )
	return player:check_guide_state( 'first_eq_strengthen' )
end

