local director			= import( 'world.director' )
local model				= import( 'model.interface' )

_event_list = {}
_character_limit = {}

function init_tutor()
	for k, v in pairs(data.tutor) do
		if _event_list[v.event] == nil then
			_event_list[v.event] = {}
		end
		local is_exist = false
		for ck, cv in pairs(_event_list[v.event]) do
			if cv == k then
				is_exist = true
				break
			end
		end
		if is_exist == false then
			table.insert(_event_list[v.event], k)
		end
	end
end

function trigger( event_key, condition )
	local c_list = _event_list[event_key]
	condition = tostring(condition) or nil
	if c_list ~= nil then
		for k, v in pairs(c_list) do
			local t = data.tutor[v]
			if t ~= nil and (t.bind_monster == nil or t.bind_monster == condition) then
				import('game_logic.tutor')[t.func_name](t.func_arg)
			end
		end
	end
end

-- 新手引导事件 begin
function show_info( args )
	local cur_layer = director.get_cur_battle().proxy
	cur_layer: show_guide(args[1], args[2])
end

function hide_info( args )
	local cur_layer = director.get_cur_battle().proxy
	cur_layer: hide_guide(args[1], args[2])
end

function show_tip( args )
	local cur_layer = director.get_cur_battle().proxy
	cur_layer: show_guide('gui/battle/tips.ExportJson', 'up', args[1], args[2], {args[3], args[4]}, args[5])
end

function hide_tip( args )
	local cur_layer = director.get_cur_battle().proxy
	cur_layer: hide_guide('gui/battle/tips.ExportJson', 'down', args[1], args[2], {args[3], args[4]})
end

function set_true( args )
	if args ~= nil then
		for k, v in pairs(args) do
			_character_limit[v] = true
		end
	end
end

function set_false( args )
	if args ~= nil then
		for k, v in pairs(args) do
			_character_limit[v] = false
		end
	end
end

function remove_object( args )
	if args == nil then
		return
	end
	for k, v in pairs(args) do
		director.get_cur_battle(): remove_entities_by_confid( tonumber(v) )
	end
	return
end

function load_skill( args )
	if args == nil then
		return
	end

	-- player skill
	local player = model.get_player()
	local temp_skill = { 
		id = tonumber(args[1]),
		star = tonumber(args[2]),
		lv = tonumber(args[3]),
		exp = 0
	}
	local orig_loaded_skills = player:get_loaded_skills()
	player:update_skill(temp_skill)

	-- load skill
	local slot = tonumber(args[4])
	if slot ~= nil and orig_loaded_skills[slot] == nil then
		player:load_skill(slot, temp_skill.id)
		local battle = director.get_cur_battle()
		pe = battle.main_player
		local skill = orig_loaded_skills[slot] 
		local skill_name = skill:get_state_name()
		pe.states[skill_name] = skill:get_conf()
		pe.loaded_skills[skill.id] = skill
		table.insert(pe.state_order, 2, skill_name)
		battle.proxy: refresh_skill_buttons()
	end
end

function permanent_skill( args )
	if args == nil then
		return
	end

	-- player skill
	local player = model.get_player()
	local skills = player:get_skills()
	local s_id = tonumber(args[1])
	local s_star = tonumber(args[2])
	local s_lv = tonumber(args[3])
	local s_slot = tonumber(args[4])
	for k, v in pairs(skills) do
		if v.id == s_id then
			return
		end
	end
	server.free_skill(s_id)

	local temp_skill = { 
		id = s_id,
		star = s_star,
		lv = s_lv,
		exp = 0
	}
	local orig_loaded_skills = player:get_loaded_skills()
	player:update_skill(temp_skill)

	-- load skill
	if s_slot ~= nil and orig_loaded_skills[s_slot] == nil then
		player:load_skill(s_slot, temp_skill.id)
		local battle = director.get_cur_battle()
		pe = battle.main_player
		local skill = orig_loaded_skills[s_slot] 
		local skill_name = skill:get_state_name()
		pe.states[skill_name] = skill:get_conf()
		pe.loaded_skills[skill.id] = skill
		table.insert(pe.state_order, 2, skill_name)
		battle.proxy: refresh_skill_buttons()
	end

end

function unload_skill( args )
	if args == nil then
		return
	end

	local player = model.get_player()
	player:unload_skill(tonumber(args[1]))
	player:remove_skill(tostring(args[1]))
end

function hide_skill_buttons()
	local battle_layer = director.get_cur_battle().proxy
	if battle_layer ~= nil then
		battle_layer:hide_skill_buttons()
	end
end
function show_skill_buttons()
	local battle_layer = director.get_cur_battle().proxy
	if battle_layer ~= nil then
		battle_layer:show_skill_buttons()
	end
end

function finish_tutorial()
	server.tutor_done()
end
-- 新手引导事件 end
