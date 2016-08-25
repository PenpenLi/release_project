local director			= import( 'world.director' )
local ui_const			= import( 'ui.ui_const' )
local model 			= import( 'model.interface' )
local entity			= import( 'world.entity' )
local layer				= import( 'world.layer' )
local ui_mgr 			= import(  'ui.ui_mgr' )
local net_model 		= import( 'network.interface' )
local anim_trigger 		= import( 'ui.main_ui.anim_trigger' )
local model 			= import( 'model.interface' )
local locale			= import( 'utils.locale' )
local boss_cell			= import('ui.boss_layer.boss_cell')
local scroll_view		= import('ui.boss_layer.scroll_view')
local shader 			= import( 'utils.shaders' )
local combat_conf		= import( 'ui.boss_layer.boss_ui_cont' )
local box_tx 			= import( 'ui.boss_layer.box_tx' )

local _json = 'gui/main/bossfuben_1.ExportJson'

boss_layer = lua_class('boss_layer', layer.ui_layer)

local max_num = 3

function boss_layer:_init(  )	
	super(boss_layer,self)._init(_json, true)
	self.widget:ignoreAnchorPointForPosition(true)
	self.is_remove = false

	self:set_handler('btn_close', self.close_button_event)
	self:set_handler('btn_refresh', self.refresh_button_event)
	self:set_handler('btn_honor_stroe', self.store_button_event)
	self:set_handler('btn_help', self.help_button_event)
	self.list_boss = scroll_view.scroll_view(self:get_widget('list_boss'))--self:get_widget('list_boss')
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2, VisibleSize.height/2)

	for i = 1, max_num do
		if self.img_award == nil then
			self.img_award = {}
			self.img_award_open = {}
			self.img_award_tx = {}
		end
		self.img_award[i] = self:get_widget('img_award_' .. i)
		self.img_award_open[i] = self:get_widget('img_award_open_' .. i)
		self.img_award_tx[i] = self:get_widget('img_award_tx_' .. i)
		self:set_award_handel(self.img_award[i], i)
	end
	ui_mgr.schedule_once(0, self, self.init_list)
	self:update_award()
	self:init_lbl_font()

	self:init_box_tx()
end

function boss_layer:init_box_tx()
	box_tx.load_json_file()
	for i = 1, max_num do
		if self.box_tx == nil then
			self.box_tx = {}
		end
		self.box_tx[i] = box_tx.box_tx()
		self.box_tx[i]:create_armature('UI_boss_challenge_tx', 'Stand', 16, 0, 0.5)
		self.img_award_open[i]:addChild(self.box_tx[i].armature)
		self.box_tx[i]:set_scale(1.3)
		self.box_tx[i]:set_position(32, 30)
	end
end

function boss_layer:init_lbl_font(  )
	for name, val in pairs(combat_conf.boss_ui_label) do
		self['lbl_' .. name] = self:get_widget('lbl_' .. name)
		local temp_label = self['lbl_' .. name]
		if temp_label ~= nil then
			if val.edge ~= nil and val.edge > 0 then 					--edge的值大于0就描边
				temp_label:enableOutline(ui_const.UilableStroke, val.edge)  ---，描边，厚度 role_ui_conf.lua中role_ui_label的edge
			end
			temp_label:setString(locale.get_value('boss_' .. name))
		end
	end
end

function boss_layer:close_button_event(  sender, eventtype  )
	if eventtype == ccui.TouchEventType.began then
	elseif eventtype == ccui.TouchEventType.moved then
	elseif eventtype == ccui.TouchEventType.ended then
		anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_UP_ANIM,false)
		self.cc:setVisible(false)
		self.is_remove = true
		
	elseif eventtype == ccui.TouchEventType.canceled then
	end
end

--设置cell触发事件
function boss_layer:set_cell_handel( cell )
	local function button_event( sender,eventtype )
		if eventtype == ccui.TouchEventType.began then
		elseif eventtype == ccui.TouchEventType.moved then
		elseif eventtype == ccui.TouchEventType.ended then
			local skill_ui = ui_mgr.create_ui(import('ui.skill_select_system.skill_select_layer'), 'skill_select_layer')
			skill_ui:set_scene_id(cell.battle_id)

		elseif eventtype == ccui.TouchEventType.canceled then
		end
	end
	cell:get_btn():addTouchEventListener(button_event)
end

function boss_layer:set_award_handel( widget, index )
	local function button_event( sender,eventtype )
		if eventtype == ccui.TouchEventType.began then
		elseif eventtype == ccui.TouchEventType.moved then
		elseif eventtype == ccui.TouchEventType.ended then
			self.box_tx[index]:play_animation()
			server.get_boss_award(index)
			director.show_loading()
		elseif eventtype == ccui.TouchEventType.canceled then
		end
	end
	widget:addTouchEventListener(button_event)
end

function boss_layer:solve_boss()
	local d = data.boss_battle
	local player = model.get_player()
	local cur_boss = player:get_cur_boss()
	local finish_boss = player:get_finish_boss()
	local not_cur_boss = {}
	local unknow_boss = {}
	local fuben = player:get_fuben()

	for id, boss in pairs(d) do
		if cur_boss[tostring(id)] == nil then
			if boss.unlock <= fuben then
				if finish_boss[tostring(id)] == nil then
					not_cur_boss[id] = boss
				end
			else
				unknow_boss[id] = boss
			end
		end
	end
	return cur_boss, finish_boss, not_cur_boss, unknow_boss
end

function boss_layer:init_list()
	self:reload_json()
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( 'icon/s_icons.plist' )
	self.list_boss:remove_all_children()

	local cur_boss, finish_boss, not_cur_boss, unknow_boss = self:solve_boss()

	local cur_boss_num = self:get_table_lgt(cur_boss)
	local finish_boss_num = self:get_table_lgt(finish_boss)
	local not_cur_boss_num = self:get_table_lgt(not_cur_boss)

	if cur_boss_num + finish_boss_num < 3 and not_cur_boss_num > 0 then
		server.refresh_boss(1)
		cur_boss, finish_boss, not_cur_boss, unknow_boss = self:solve_boss()
	end

	local list = {}
	local d = data.boss_battle
	for id, boss in pairs(d) do 
		local pal_cell = boss_cell.boss_cell(self, tonumber(id))
		local cell = pal_cell:get_cell()
		cell:ignoreAnchorPointForPosition(true)
		self:set_cell_handel(pal_cell)
		--self.list_boss:push_back_item(cell)
		pal_cell:get_btn():setTouchEnabled(true)
		if cur_boss[tostring(id)] ~= nil then
			pal_cell:set_cur()
		elseif finish_boss[tostring(id)] ~= nil then
			pal_cell:set_finish()
		elseif not_cur_boss[id] ~= nil then
			pal_cell:set_not_cur()
		elseif unknow_boss[id] ~= nil then
			pal_cell:set_unknow()
		end
		table.insert(list, pal_cell)
	end

	table.sort(list, function(q, p) return q.unlock_id < p.unlock_id end)
	for k, v in pairs(list) do
		self.list_boss:push_back_item(v:get_cell(), v:get_battle_id(), false)
		self.list_boss:add_to_list(v, v:get_battle_id())
	end
	

	-- --选中的BOSS
	-- for id, boss in pairs(cur_boss) do
	-- 	local pal_cell = boss_cell.boss_cell(self, tonumber(id))
	-- 	local cell = pal_cell:get_cell()
	-- 	cell:ignoreAnchorPointForPosition(true)
	-- 	self:set_cell_handel(pal_cell)
	-- 	self.list_boss:push_back_item(cell)
	-- end
	-- --没选中的BOSS
	-- for id, boss in pairs(not_cur_boss) do
	-- 	local pal_cell = boss_cell.boss_cell(self, tonumber(id))
	-- 	local cell = pal_cell:get_cell()
	-- 	cell:ignoreAnchorPointForPosition(true)
	-- 	self:set_cell_handel(pal_cell)
	-- 	self.list_boss:push_back_item(cell)
	-- 	shader.SpriteSetGray(pal_cell:get_boss_icon():getVirtualRenderer(), 0.3)
	-- 	pal_cell:get_btn():setTouchEnabled(false)
	-- end
	-- --不能打的BOSS
	-- for id, boss in pairs(unknow_boss) do
	-- 	local pal_cell = boss_cell.boss_cell(self, tonumber(id))
	-- 	local cell = pal_cell:get_cell()
	-- 	cell:ignoreAnchorPointForPosition(true)
	-- 	self:set_cell_handel(pal_cell)
	-- 	self.list_boss:push_back_item(cell)
	-- 	shader.SpriteSetGray(pal_cell:get_boss_icon():getVirtualRenderer(), 0)
	-- 	pal_cell:get_btn():setTouchEnabled(false)
	-- end
end

function boss_layer:update_list()
	local cur_boss, finish_boss, not_cur_boss, unknow_boss = self:solve_boss()
	local d = data.boss_battle
	for id, boss in pairs(d) do
		local pal_cell = self.list_boss:get_item_by_tag(id)	
		if cur_boss[tostring(id)] ~= nil then
			pal_cell:set_cur()
		elseif finish_boss[tostring(id)] ~= nil then
			pal_cell:set_finish()
		elseif not_cur_boss[id] ~= nil then
			pal_cell:set_not_cur()
		elseif unknow_boss[id] ~= nil then
			pal_cell:set_unknow()
		end
	end
end

function boss_layer:update_award()
	local player = model.get_player()
	local finish_boss = player:get_finish_boss()
	local finish_num = self:get_table_lgt(finish_boss)
	local finish_boss_num = self:get_table_lgt(finish_boss)
	local index = 1
	--print('--------------------------------------', finish_num)
	for i = 1, finish_num do
		if index > max_num then
			break
		end
		self.img_award[i]:setTouchEnabled(true)
		self.img_award_tx[i]:setVisible(true)
		index = index + 1
		self:play_action('bossfuben_1.ExportJson','box' .. i)
	end
	for i = index, max_num do
		shader.SpriteSetGray(self.img_award[i]:getVirtualRenderer(), 0)
		self.img_award[i]:setTouchEnabled(false)
		self.img_award_tx[i]:setVisible(false)
	end
	local boss_award = player:get_boss_award()
	for k, v in pairs(boss_award) do
		if type(k) == 'number' and k <= max_num and v == 1 then
			self.img_award[k]:setVisible(false)
			self.img_award_open[k]:setVisible(true)
			self.img_award_tx[k]:setVisible(false)
		elseif v ~= 1 then
			self.img_award[k]:setVisible(true)
			self.img_award_open[k]:setVisible(false)
		end
	end
end

function boss_layer:get_table_lgt( table )
	local cnt = 0
	for k, v in pairs(table) do
		cnt = cnt + 1
	end
	return cnt
end

function boss_layer:reload()
	super(boss_layer,self).reload()
	self:update_list()
	self:update_award()
end

function boss_layer:refresh_button_event( sender, eventtype )
	if eventtype == ccui.TouchEventType.began then
	elseif eventtype == ccui.TouchEventType.moved then
	elseif eventtype == ccui.TouchEventType.ended then
		local finish_boss_num = self:get_table_lgt(model.get_player():get_finish_boss())
		if finish_boss_num >= max_num then
			local msg_queue = import( 'ui.msg_ui.msg_queue' )
			msg_queue.add_msg('已打完，不能刷新')
			return 
		end
		local msg_box = ui_mgr.create_ui(import('ui.msg_ui.msg_ok_cancel_layer'), 'msg_ok_cancel_layer')
		--server.refresh_boss()
		local string = locale.get_value_with_var('boss_refresh_msg', {diamond = import('model.rmb_cost').get_cost_by_id(7)})
		msg_box:set_tip(string)
		msg_box.tip_label:enableOutline(ui_const.UilableStroke, ui_const.UilableEdg)
		msg_box:set_font_size(25)
		msg_box:set_ok_function(function() server.refresh_boss() end)
	elseif eventtype == ccui.TouchEventType.canceled then
	end
end

function boss_layer:help_button_event( sender, eventtype )
	if eventtype == ccui.TouchEventType.began then
	elseif eventtype == ccui.TouchEventType.moved then
	elseif eventtype == ccui.TouchEventType.ended then
		local rule_ui = ui_mgr.create_ui(import('ui.td_ui.td_rule'), 'td_rule')
		local rule1 = locale.get_value('boss_rule_1')
		rule1 =  string.gsub(rule1, '\\n', "\n")
		local rule2 = locale.get_value('boss_rule_2')
		rule2 =  string.gsub(rule2, '\\n', "\n")
		rule_ui:add_rule(rule1, 22, Color.Rice_Yellow)
		rule_ui:add_rule(rule2, 22, Color.Dark_Yellow)
	elseif eventtype == ccui.TouchEventType.canceled then
	end
end

function boss_layer:store_button_event( sender, eventtype )
	if eventtype == ccui.TouchEventType.began then
		elseif eventtype == ccui.TouchEventType.moved then
		elseif eventtype == ccui.TouchEventType.ended then
			local exchange	= ui_mgr.create_ui(import('ui.dhshop_layer.dhshop_layer'), 'dhshop_layer')
			exchange:set_proxy_type( 2 )
			exchange:reload()
		elseif eventtype == ccui.TouchEventType.canceled then
	end
end


-- function boss_layer:get_award_data(box_id)
-- 	local d = data.box_drop[box_id]
-- 	if d == nil then
-- 		return
-- 	end
-- 	local rwd_data = {}
-- 	local count = 0
	
-- 	if d.proxy_money ~= nil then
-- 		count = count + 1
-- 		local value = d.proxy_money
-- 		rwd_data[count] = {k='diamond',v=value}
-- 	end
-- 	if d.money ~= nil then
-- 		count = count + 1
-- 		local value = d.money
-- 		rwd_data[count] = {k='gold',v=value}
-- 	end

-- 	if d.drop ~= nil then
		
-- 		for id,value in pairs(d.drop) do
-- 			count = count + 1
-- 			local number = value[2]
-- 			if number == nil then
-- 				number = 0
-- 			end
-- 			rwd_data[count] = {k='items',v=value,num=number}
-- 		end
-- 	end
-- 	return 
-- end