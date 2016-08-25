local director			= import( 'world.director')
local timer				= import( 'utils.timer' )
local msg_queue 		= import( 'ui.msg_ui.msg_queue' )
local locale			= import( 'utils.locale' )
local ui_guide			= import( 'world.ui_guide' )
local stack 			= import( 'utils.stack' )
local queue 			= import( 'utils.queue' )
local dequeue 			= import( 'utils.dequeue' )

ui_name = {}
ui_scene = {}
ui_dequeue = {}
ui_his_dequeue = {}
gray_ui_stack = {}
wait_ui_queue = {}  -- create once when scene was created
--ui_scene_stack = {}

local _timer_id
local _shared_ui_guide
local hide_main_ui_node = nil

function create_ui( mod, name )
	if mod == nil then
		print('create_ui failure (module nil): ', name)
		return
	end
	local scene = director.get_scene()
	if scene == nil then
		print('create_ui failure (scene nil): ', name)
	end

	local ui_node = mod[name]()
	--ui_node.name = name
	if ui_node == nil then
		print('create_ui failure (node nil): ', name)
	end

	local scene_name = scene._name
	ui_name[name] = scene_name
	if ui_scene[scene_name] == nil then
		ui_scene[scene_name] = {}
		ui_dequeue[scene_name] = dequeue.dequeue()
		gray_ui_stack[scene_name] = stack.stack()
	end

	--设置背景
	if ui_node.is_gray then
		local top_ui_node = gray_ui_stack[scene_name]:front()
		if top_ui_node ~= nil then
			top_ui_node.gray_col:setVisible(false)
		end
		ui_node.gray_col = cc.LayerColor:create( cc.c4b(0,0,0,180) )
		ui_node.gray_col:setPosition(0,0)
		ui_node.cc:addChild(ui_node.gray_col, ZUIGray)
		gray_ui_stack[scene_name]:push(ui_node)
	end
	ui_dequeue[scene_name]:push_back({node = ui_node, mod = mod, name = name})
	ui_scene[scene_name][name] = ui_node

	scene.cc:addChild(ui_node.cc, 0)

	enter_ui_trigger()
	print("[ui_mgr][create ui]", scene_name, name)
	return ui_node
end

function get_ui( name )
	local scene_name = ui_name[name]
	if scene_name == nil or ui_scene[scene_name] == nil then
		return nil
	end
	return ui_scene[scene_name][name]
end

function remove_node( scene_name, name, node )
	print("[ui_mgr][remove ui]", scene_name, name)
	node:release()
	node.cc:removeFromParent()
	ui_name[name] = nil
	ui_scene[scene_name][name] = nil
	node.is_remove = true
	--更新背景
	if node == gray_ui_stack[scene_name]:front() then --移除的ui是栈顶UI时才更新
		if node.is_gray == true then
			gray_ui_stack[scene_name]:pop()
			local top_ui
			for i = 1, gray_ui_stack[scene_name]:size() do
				top_ui = gray_ui_stack[scene_name]:front()
				if top_ui == nil then
					break
				end
				if top_ui.is_remove == false then
					top_ui.gray_col:setVisible(true)
					break
				else
					gray_ui_stack[scene_name]:pop()
				end
			end
		end
	end
	enter_ui_trigger()

end

function check_remove_ui()
	for name, scene_name in pairs(ui_name) do
		local node = ui_scene[scene_name][name]
		if node.is_remove == true then
			remove_node(scene_name, name, node)
		end
	end
end

local function add_to_his(scene_name)
	if ui_dequeue[scene_name] == nil then
		return
	end
	if ui_his_dequeue[scene_name] == nil then
		ui_his_dequeue[scene_name] = dequeue.dequeue()
	else
		ui_his_dequeue[scene_name]:clear()
	end
	local top_ui
	for i = 1, ui_dequeue[scene_name]:size() do
		top_ui = ui_dequeue[scene_name]:pop_front()
	--	print('top!!!!!!!!!!!!!!!!!!  ', top_ui.node._name)
		if top_ui ~= nil and top_ui.node.is_remove ~= true
			and top_ui.node._name ~= 'main_map' and top_ui.node._name ~= 'main_surface_layer' then
			ui_his_dequeue[scene_name]:push_back({mod = top_ui.mod, name = top_ui.name})
			print('[ui_mgr][add his ui] ', scene_name, top_ui.name)
		end
	end
end

function remove_scene_ui( scene_name )
	local uis = ui_scene[scene_name]
	if uis == nil then
		return
	end
	add_to_his(scene_name)
	gray_ui_stack[scene_name]:clear()
	for name, node in pairs(uis) do
		remove_node(scene_name, name, node)
	end
end

function reload(  )
	for name, scene_name in pairs(ui_name) do
		print("[ui_mgr][reload]", scene_name, name)
		ui_scene[scene_name][name]:reload()
	end
end

function add_wait_ui( scene_name, mod, name )
	--tutor bug!!!!!!!!!
	if name == 'guide_ui_info' then
		return
	end
	--------------------
	local wait_ui = {mod = mod, name = name}
	if wait_ui_queue[scene_name] == nil then
		wait_ui_queue[scene_name] = queue.queue()
	end
	print('[ui_mgr][add wait ui] ', scene_name, name)
	wait_ui_queue[scene_name]:push(wait_ui)
end

function create_wait_ui()
	local scene = director.get_scene()
	local scene_name = scene._name
	local wait_ui
	local ui_q = wait_ui_queue[scene_name]
	if ui_q == nil then
		return 
	end
	for i = 1, ui_q:size() do
		wait_ui = ui_q:pop()
		if wait_ui ~= nil then
			create_ui(wait_ui.mod, wait_ui.name)
		end
	end
end

function hide_loading()
	-- 完成
	if _timer_id ~= nil then
		timer.remove_time(_timer_id)
		_timer_id = nil
	end
	director.hide_loading()
end

function cut_loading()
	-- 超时返回
	if _timer_id ~= nil then
		timer.remove_time(_timer_id)
		_timer_id = nil
		local msg = locale.get_value_with_var( 'msg_time_out' )
		msg_queue.add_msg(msg)
	end
	director.hide_loading()
end

function show_loading()
	_timer_id = timer.set_timer(3, cut_loading)
	director.show_loading()
end

function get_shared_guider()
	if _shared_ui_guide == nil then
		_shared_ui_guide = create_ui(import('ui.guide_ui_info'), 'guide_ui_info')
		_shared_ui_guide.cc: setLocalZOrder(ZUITutor)
	end
	return _shared_ui_guide
end

function destroy_guider()
	if _shared_ui_guide ~= nil then
		_shared_ui_guide.is_remove = true
		_shared_ui_guide = nil
	end
end

function enter_ui_trigger()
	local lastArrival = -1
	local topUIName = ''
	for k, v in pairs(ui_name) do
		local tmpArrival = ui_scene[v][k].cc:getOrderOfArrival()
		if lastArrival < tmpArrival and k ~= 'guide_ui_info' then
			topUIName = k
			lastArrival = tmpArrival
		end
	end
	--print('top ---------------------------  ', topUIName)
	ui_guide.trigger('topui_' .. topUIName)
end

function schedule_once(time, e, cal_back, ...)
	time = time or 0
	local func_once = nil
	local args = {...}
	local function func()
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(func_once)
		if e == nil then
			cal_back(unpack(args))
		else
			cal_back(e, unpack(args))
		end
	end
	func_once = cc.Director:getInstance():getScheduler():scheduleScriptFunc(func, time, false)
end

function update_lbl( str )
	--主界面金钱更新
	local main_ui = get_ui('main_surface_layer')
	if main_ui ~= nil then
		main_ui:reload_lbl()
	end

	local shop_ui = get_ui('shop_layer')
	if shop_ui ~= nil then
		shop_ui:reload_lbl()
	end

	local bag_ui = get_ui('bag_system_layer')
	if bag_ui ~= nil then
		bag_ui:reload_lbl()
	end

	local lottery_ui = get_ui('lottery_layer')
	if lottery_ui ~= nil then
		lottery_ui:reload_lbl()
	end



end
