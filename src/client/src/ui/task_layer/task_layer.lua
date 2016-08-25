local layer 				= import('world.layer')
local anim_trigger 			= import( 'ui.main_ui.anim_trigger')
local ui_const 				= import( 'ui.ui_const' )
local tasked_btn 			= import( 'ui.task_layer.tasked_btn' )
local tasking_btn 			= import( 'ui.task_layer.tasking_btn' )
local navigation_bar		= import( 'ui.equip_sys_layer.navigation_bar' ) 
local model 				= import( 'model.interface' )
local table_utils 			= import( 'engine.table_utils' )
local task_reward 			= import( 'ui.task_layer.task_reward' )
local ui_mgr 				= import( 'ui.ui_mgr' )
local msg_queue 			= import( 'ui.msg_ui.msg_queue' )
local locale				= import( 'utils.locale' )
local ui_guide				= import( 'world.ui_guide' )


task_layer = lua_class( 'task_layer' , layer.ui_layer )
local _json_path = 'gui/main/task_panel.ExportJson'
local renwu_set = 'icon/renwu.plist'
local iicon_set = 'icon/item_icons.plist'
local eicon_set = 'icon/e_icons.plist'
local soul_set = 'icon/soul_icons.plist'

function task_layer:_init(  )
	super(task_layer,self)._init(_json_path,true)

	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2,VisibleSize.height/2)


	self.task_type = 1
	
	self.is_remove 		= false

	self.close_button = self:get_widget('close_button')
	self:set_handler('close_button',self.close_button_event)

	local lbl_daily_button = self:get_widget('lbl_daily_button')
	--lbl_daily_button:setFontName(ui_const.UiLableFontType)
	lbl_daily_button:setString('日常任务')
	lbl_daily_button:enableOutline(ui_const.UilableStroke, 2)

	local lbl_thread_button = self:get_widget('lbl_thread_button')
	--lbl_thread_button:setFontName(ui_const.UiLableFontType)
	lbl_thread_button:setString('主线任务')
	lbl_thread_button:enableOutline(ui_const.UilableStroke, 2)


	--控制显示剩下的任务条
	self.first_creat = true
	self.bar = self:get_widget('bar')
	self.bar:setVisible(false)
	self.barbg = self:get_widget('barbg')
	self.bar:setScale9Enabled(true)
	--任务列表
	self.task_list = self:get_widget('task_list')
	self.navigation_bar = navigation_bar.navigation_bar(self.bar,self.barbg, self.task_list)

	self.daily_button = self:get_widget('daily_button')
	self:set_handler('daily_button',self.daily_button_event)
	self.daily_button:setTouchEnabled(false)
	self.daily_button:setSelectedState(true)

	self.thread_button = self:get_widget('thread_button')
	self:set_handler('thread_button',self.thread_button_event)
	
	self:reload()
end

function task_layer:cal_table_length( t )
	local i = 0
	for k,v in pairs(t) do
		if v ~= 1 then
			i = i+1
		end
	end
	return i
end

function task_layer:reset_list_event(  )
	local function scrollViewEvent(sender, evenType)

	end
	self.task_list:addEventListener(scrollViewEvent)
end

function task_layer:add_daily_task( task_data )
	ui_mgr.schedule_once(0, self, self._add_daily_task, task_data)
end

function task_layer:_add_daily_task( task_data)
	self:reload_json()
	self:reset_list_event( )
	local player = model.get_player()
	local task_data
	if self.task_type == 2 then
		task_data = player:get_quests()
	elseif self.task_type == 1 then
		task_data = player:get_quests_daily()
	end
	self.task_list:removeAllChildren()
	self.task_list:jumpToTop()
	
	self.task_count = self:cal_table_length(task_data)
	local cur_count = self.task_count

	local start_count = 3

	if self.task_count<= start_count then
		
		self.task_count = start_count
		--排序，完成的在前面
		local keys = {}
		local ed_keys = {}
		local ing_keys = {}
		for k , v in pairs(task_data) do
			if v ~= 1 and v:is_complete() == true then
				table.insert(ed_keys, k)
			elseif v ~= 1 then
				table.insert(ing_keys, k)
			end
		end
		local function cmp(a,b)
			return a < b
		end
		table.sort(ed_keys, cmp)
		table.sort(ing_keys, cmp)
		for _, v in pairs(ed_keys) do
			table.insert(keys,v)
		end

		for _, v in pairs(ing_keys) do
			table.insert(keys,v)
		end


		local cnt = 0
		for i=1,cur_count do
			local index = keys[i]
			self:create_task_cell( index,task_data,i )
		end
		
		local height = self:get_widget('tasking_button'):getContentSize().height
		self.task_list:setInnerContainerSize(cc.size(740,self.task_count*144))
		self.navigation_bar:init_bar(start_count,self.task_count,430)
		self.bar:setVisible(true)
		return
	end

	--缓冲创建列表
	if self.task_count>start_count then
		--排序，完成的在前面
		local keys = {}
		local ed_keys = {}
		local ing_keys = {}
		for k , v in pairs(task_data) do
			if v ~= 1 and v:is_complete() == true then
				table.insert(ed_keys, k)
			elseif v ~= 1 then
				table.insert(ing_keys, k)
			end
		end
		local function cmp(a,b)
			return a < b
		end
		table.sort(ed_keys, cmp)
		table.sort(ing_keys, cmp)
		for _, v in pairs(ed_keys) do
			table.insert(keys,v)
		end

		for _, v in pairs(ing_keys) do
			table.insert(keys,v)
		end

		local cnt = 0
		for i=1,self.task_count do
			local index =  keys[i]

			self:create_task_cell( index,task_data,i )
		end
		-- local function listViewEvent()

		-- 	if self.first_creat == true then
		-- 		self.first_creat = false
		-- 		local n = self.task_count-start_count
		-- 		self:reload_json()
		-- 		for i=1 , n do
		-- 			local index = keys[i+start_count]
		-- 			self:create_task_cell( index ,task_data,i+start_count)
		-- -- 		end
		-- -- 	end

		-- -- end
		self.task_list:setInnerContainerSize(cc.size(740,self.task_count*144))
		self.navigation_bar:init_bar(start_count,self.task_count,430)
		self.bar:setVisible(true)
		
	end
end


function task_layer:create_task_cell( index ,task_data,pos_index)
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( renwu_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( iicon_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( eicon_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( soul_set )
	local cell_type = task_data[index]:is_complete()
	local rwd_data = {}
	local sever_data = task_data[index]:get_reward()
	local count = 0
	
	if sever_data.exp ~= nil then
		count = count + 1
		local value = sever_data.exp
		rwd_data[count] = {k='exp',v=value}
	end
	if sever_data.diamond ~= nil then
		count = count + 1
		local value = sever_data.diamond
		rwd_data[count] = {k='diamond',v=value}
	end
	if sever_data.gold ~= nil then
		count = count + 1
		local value = sever_data.gold
		rwd_data[count] = {k='gold',v=value}
	end
	if sever_data.energy ~= nil then
		count = count + 1
		local value = sever_data.energy
		rwd_data[count] = {k='energy',v=value}
	end

	if sever_data.items ~= nil then
		
		for id,value in ipairs(sever_data.items) do
			count = count + 1
			local value = value
			local number = task_data[index]:get_items_count()
			if number == nil then
				number = 0
			end
			rwd_data[count] = {k='items',v=value,num=number}
		end
	end

	if cell_type == false then
		local btn = tasking_btn.tasking_btn(self)
		self.task_list:addChild(btn:get_btn())
		btn:get_btn():setTag(pos_index)
		btn:get_btn():setPosition(348,144*self.task_count-144*((pos_index)-1)-144/2)
		btn:set_task_title(task_data[index]:get_title())
		btn:set_task_cont(task_data[index]:get_desc())
		btn:set_reward(rwd_data)
		btn:set_id(index)
		btn:set_task_img(task_data[index]:get_icon())
		if task_data[index]:get_quest_time_limit() ~= nil then
			btn:set_target_food( locale.get_value( 'food_target' ) )
		else 
			btn:set_target(task_data[index]:get_quest_counter())
		end

		if task_data[index]:get_ui_type() ~= nil then

			local function tasking_handler(sender, eventType)
				if eventType == ccui.TouchEventType.ended then
					if task_data[index].data.ui_type ~= nil then
						self:open_ui(task_data[index])
					end
					--msg_queue.add_msg('未完成任务！')
				end
			end

			self:set_widget_handler(btn:get_btn(), tasking_handler, index)
			self:set_widget_handler(btn:get_go_btn(), tasking_handler, index)
		else
			btn:get_go_btn():setVisible(false)
		end
	end

	if cell_type == true then

		local btn = tasked_btn.tasked_btn(self)
		self.task_list:addChild(btn:get_btn())
		btn:get_btn():setTag(pos_index)
		btn:get_btn():setPosition(348,144*self.task_count-144*((pos_index)-1)-144/2)
		btn:set_task_title(task_data[index]:get_title())
		btn:set_task_cont(task_data[index]:get_desc())
		btn:set_reward(rwd_data)
		btn:set_id(index)
		btn:set_task_img(task_data[index]:get_icon())
		if task_data[index]:get_quest_condition() == 'yueKa' then
			btn:set_target( locale.get_value_with_var( 'month_card',{times = task_data[index]:get_complete_count()} ) )
		end
		local function tasked_handler(sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				local task_reward = ui_mgr.create_ui(import('ui.task_layer.task_reward'), 'task_reward')
				task_reward:set_reward(rwd_data)
				server.finish_quest( self.task_type,index )
				ui_guide.pass_condition( 'first_quest_reward' )
			end
		end
		self:set_widget_handler(btn:get_btn(),tasked_handler, index)
	end

end


function task_layer:init_task()

	-- local player = model.get_player()
	-- local quest = player:get_quests_daily()
	-- self:add_daily_task()


end

function task_layer:open_ui( task_data )
	local ui_type = task_data.data.ui_type
	local battle_id = task_data.data.battle_id
	local temp_lbl = string_split(EnumUiType[ui_type].file,'.')
	local temp_ui = ui_mgr.create_ui(import(EnumUiType[ui_type].file),temp_lbl[3])
	if ui_type == EnumUiType.common_map.type then
		if battle_id ~= nil then
			temp_ui:open_turn_commonPage(battle_id)
		else
			temp_ui:open_common_map()
		end
	elseif ui_type == EnumUiType.elite_map.type then
		temp_ui:open_elite_map()
	elseif ui_type == EnumUiType.fuben_detail.type then
		if battle_id ~= nil then
			temp_ui:set_fuben_id(battle_id)
			temp_ui:set_fuben_img()
			temp_ui:add_entity_img()
			temp_ui:add_item_img()
		end
	end
end


function task_layer:daily_button_event( sender,eventType )
	if eventType == ccui.CheckBoxEventType.selected then
		sender:setTouchEnabled(false)
		sender:setSelectedState(true)
		self.thread_button:setTouchEnabled(true)
		self.thread_button:setSelectedState(false)
		self.first_creat = true

		self.task_type = 1
		self:add_daily_task()
	elseif eventType == ccui.CheckBoxEventType.unselected then
		sender:setTouchEnabled(true)	
	end
end


function task_layer:thread_button_event( sender,eventType )
	if eventType == ccui.CheckBoxEventType.selected then
		sender:setTouchEnabled(false)
		sender:setSelectedState(true)

		self.daily_button:setTouchEnabled(true)
		self.daily_button:setSelectedState(false)
		self.first_creat = true

		self.task_type = 2
		self:add_daily_task()
	elseif eventType == ccui.CheckBoxEventType.unselected then
		sender:setTouchEnabled(true)	
	end
end


--关闭按钮
function task_layer:close_button_event( sender,eventtype )

	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  
	elseif eventtype == ccui.TouchEventType.ended then
		self.cc:setVisible(false)

		anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_UP_ANIM,false)
		self.is_remove = true
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end

--更新

function task_layer:reload(  )
	super(task_layer,self).reload()
	self.first_creat = true
	self:add_daily_task()
end

--释放
function task_layer:release(  )
	-- body
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( renwu_set )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( eicon_set )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( iicon_set )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( soul_set )
	super(task_layer,self).release()
	self.is_remove 		= false
end

