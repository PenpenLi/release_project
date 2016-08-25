local director			= import( 'world.director' )
local model				= import( 'model.interface' )
local ui_mgr			= import( 'ui.ui_mgr' )
local common_condition	= import( 'world.common_condition' )

-- UI GUIDE LOGIC
_event_list = {}
local _cur_guide = nil
local _all_done = true

function init_guide()
	--DEBUG LOG
	--print(':::::::::::::::::: init guide :::::::::::::::::: ')
	local player = model.get_player()
	_all_done = player:get_ui_guide_all_done()
	if _all_done == true then
		return
	end

	-- build _event_list = { 'some_event'={ id, id }, 'other_event'={ id ... } }
	for k, v in pairs(data.guide) do
		if player:check_guide_done(k) == true then
			--已完成
		else
			--未完成
			_all_done = false
			local key = v.trigger
			if key ~= nil then
				if _event_list[key] == nil then
					_event_list[key] = {}
				end
				local is_exist = false
				for _, cv in pairs(_event_list[key]) do
					if cv == k then
						is_exist = true
						break
					end
				end
				if is_exist == false then
					table.insert(_event_list[key], k)
				end
			end
		end
	end

end

function _remove_id_from_eventlist( id )
	local d = data.guide[id]
	if d == nil then
		return
	end

	local list = _event_list[d.trigger]
	if list ~= nil then
		for k, v in pairs(list) do
			if v == id then
				table.remove(list, k)
				break
			end
		end

		if #list == 0 then
			_event_list[d.trigger] = nil
		end
	end
end

function trigger( event_key )
	--保留这个输出至配置完新手界面引导
	--DEBUG LOG
	print('>>>>>>>>> trigger name: ', event_key)
	if _all_done == true then
		--DEBUG LOG condition
		--print('  ...! all event done' )
		return
	end

	local c_list = _event_list[event_key]
	if c_list ~= nil then
		for k, v in pairs(c_list) do
			if _check_condition(v) == true then
				--DEBUG LOG condition
				--print('  ...! condition [' .. v .. '] TRUE [o]')
				_show_guide(v)
				break
			end
			--DEBUG LOG condition
			--print('  ...! condition [' .. v .. '] FALSE [x]')
		end
	end
end

function check_touch( layer_name, button_name, tag, eventtype )
	--DEBUG LOG
	--print( '|||TOUCH_ID|||\t', layer_name, button_name, tag)
	local d = data.button_control
	if d[layer_name] ~= nil and d[layer_name][button_name] ~= nil then
		tag = tostring(tag) or 'nil'
		local dd = d[layer_name][button_name][tag]
		if dd ~= nil then
			local ddd = data.sub_sys_switch[dd.subsys_id]
			if ddd then
				local player = model.get_player()
				if common_condition.reach_level( player, ddd.lv ) == false then
					if eventtype == ccui.TouchEventType.ended then
						--TODO: 多语言
						alert('等级不够 ' .. ddd.lv)
					end
					return false
				end
				if common_condition.finish_battle( player, ddd.battle_id ) == false then
					if eventtype == ccui.TouchEventType.ended then
						--TODO: 多语言
						alert('还没通关 ' .. ddd.battle_id)
					end
					return false
				end
			end
		end
	end
	return true
end

function alert( msg )
	local msg_ui = ui_mgr.create_ui(import('ui.msg_ui.msg_ok_layer'), 'msg_ok_layer')
	msg_ui:set_tip(msg)
	--print(' msg content:', msg_ui:get_tip())
end

function pass_condition( cond_flag )
	--DEBUG LOG
	--print(' +++ pass condition: "' .. cond_flag .. '"')
	if _all_done then
		return
	end

	local player = model.get_player()
	player:set_guide_state_done( cond_flag )
end

function _check_condition( id )
	--DEBUG LOG
	--print('  === ckecking condition, id: ' .. id )
	if _cur_guide ~= nil then
		--DEBUG LOG condition
		--print('    ...! cur guide exist [' .. _cur_guide .. ']')
		return false
	end
	local d = data.guide[id]
	if d == nil then
		--DEBUG LOG condition
		--print('    ...! nil data ' .. id)
		return false
	end

	local player = model.get_player()
	--this done
	if player:check_guide_done_remote(id) == true then
		--DEBUG LOG condition
		--print('    ...! this done [' .. id .. ']')
		return false
	end

	--pre step
	if d.pre_step ~= nil and player:check_guide_done(d.pre_step) == false then
		--DEBUG LOG condition
		--print('    ...! pre step not done [' .. d.pre_step .. ']')
		return false
	end

	--conditions
	local flag_and = true
	if d.condition then
		for _, or_cond in pairs(d.condition) do
			flag_and = true
			for con_key, con_arg in pairs(or_cond) do
				--DEBUG LOG condition
				--print('    ......? OR <' .. con_key .. '> arg: ' .. con_arg )
				if string.sub(con_key, 1, 1) == '!' then
					--条件成立则剪（条件不成立继续）
					local pfunc = string.sub(con_key, 2)
					if type(common_condition[pfunc]) == 'function' then
						if common_condition[pfunc]( player, con_arg ) == true then
							flag_and = false
							break
						end
					else
						flag_and = false
						break
					end
				else
					--条件不成立则剪
					if type(common_condition[con_key]) == 'function' then
						if common_condition[con_key]( player, con_arg ) == false then
							flag_and = false
							break
						end
					else
						flag_and = false
						break
					end
				end
				--DEBUG LOG condition
				--print('    ......! result: ', flag_and)
			end
			if flag_and == true then
				return true
			end
		end
		--所有"or条件"都不符合
		return false
	end
	return true
end

function _show_guide( id )
	--已显示guide，不再进入其他的guide
	--DEBUG LOG
	--print('  ... show guide ' .. id )
	if _cur_guide ~= nil then
		return
	end

	set_cur_guide(id)
	local d = data.guide[id]
	if d == nil then
		return
	end

	local cur_scene = director.get_scene()
	local guide_layer = ui_mgr.get_shared_guider()
	guide_layer: set_touchable_area(0, 0, 0, 0)

	local function delay_show()
		guide_layer: set_touchable_area( d.click_area[1], d.click_area[2], d.click_area[3], d.click_area[4], d.gesture_ori)
		guide_layer: show_tip( d.tip_key, d.json, d.tip_pos)
		guide_layer: show_gesture( 'gesture_jump', d.gesture_pos, d.gesture_ori)
	end

	-- delay_show()
	local delay_time = d.delay or 0
	guide_layer.cc: runAction( cc.Sequence: create( cc.DelayTime: create( delay_time ), cc.CallFunc: create( delay_show ) ) )

	if type(cur_scene.layer.set_middle_x) == 'function' and d.scene_x_offset ~= nil then
		cur_scene.layer:set_middle_x(d.scene_x_offset)
	end

	--When this guide finish
	guide_layer.done_guide_cb = function()
		--DEBUG LOG
		--print( ' ----------- done guide call back [' .. id .. '] ---------------')
		local player = model.get_player()
		player:set_guide_done_cache( id )
		if d.fin_pre == nil or d.fin_pre == id then 
			player:guide_done_big_step()
		end

		reset_cur_guide()
		guide_layer.done_guide_cb = nil

		--try show next guide
		if d.next_step ~= nil and _check_condition(d.next_step) then
			_show_guide(d.next_step)
		end
	end

end

function release_guide_layer()
	reset_cur_guide()
	ui_mgr.destroy_guider()
end

function set_cur_guide(id)
	_cur_guide = id
end

function reset_cur_guide()
	_cur_guide = nil
end

function touch_ended()
	--某个按钮点中了
	if _cur_guide == nil then
		return
	end

	local guide_layer = ui_mgr.get_shared_guider()
	guide_layer: reset_guide()
	if guide_layer.done_guide_cb ~= nil and type(guide_layer.done_guide_cb) == 'function' then
		guide_layer.done_guide_cb()
	end
end

function is_guiding()
	if _cur_guide == nil then
		return false
	else
		return true
	end
end

function touch_type_check(guide_type)
	if _cur_guide == nil then
		return false
	end
	local d = data.guide[_cur_guide]
	if d == nil then
		return false
	end
	return d.guide_type == guide_type
end
