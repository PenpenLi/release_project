local layer					= import( 'world.layer' )
local anim_trigger 			= import( 'ui.main_ui.anim_trigger')
local ui_const				= import( 'ui.ui_const' )
local ui_mgr 				= import( 'ui.ui_mgr' )
local model 				= import( 'model.interface' )
local director				= import( 'world.director')
local head_icon				= import( 'ui.head_icon.head_icon' )
local pvp_const				= import( 'const.pvp_const')
local info_panel			= import( 'ui.avatar_info_layer.info_panel')
local avatar_info_layer		= import( 'ui.avatar_info_layer.avatar_info_layer')
local avatar				= import( 'model.avatar' )
pvp_layer = lua_class('pvp_layer',layer.ui_layer)

local _json_path = 'gui/main/pvp_1.ExportJson'
local _checkbox_count = 4

function pvp_layer:_init(  )
	super(pvp_layer,self)._init(_json_path,true)

	self.is_remove = false

	self.cur_channel = 1
	self.cur_pos = 0
	self.view_item = {}

	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2,VisibleSize.height/2)

	self.player = model.get_player()
	self.player.final_attrs:final_combat_attr()

	self.panel = self.widget:getChildByName('Panel_34')
	self.item_1 = self.widget:getChildByName('item_1')
	self.item_2 = self.widget:getChildByName('item_2')
	self.item_3 = self.widget:getChildByName('item_3')

	self.my_point = self.panel:getChildByName('my_point')
	self.my_point:setString(self.player:get_pvp_point())
	self.my_honor = self.panel:getChildByName('my_honor')
	self.my_honor:setString(self.player:get_pvp_honor())

	self.list = self.panel:getChildByName('ListView')
	self.rule = self.panel:getChildByName('rule')
	self.rule:setVisible(false)
	self.refresh = self.panel:getChildByName('refresh')
	self.count_down = self.refresh:getChildByName('count_down')

	self.lab_1 = self.panel:getChildByName('lab_1')
	self.ticket = self.panel:getChildByName('ticket')
	self.lab_2 = self.panel:getChildByName('lab_2')

	self.checkbox = {}
	for i=1, _checkbox_count do
		self.checkbox[i] = self.panel:getChildByName('CheckBox_' .. i)
		self:set_handler('CheckBox_' .. i, self.checkbox_event)
	end
	--默认选中第一项
	self.checkbox[1]:setSelectedState(true)
	self.checkbox[1]:setTouchEnabled(false)
	--self:checkbox_fun_1()
	ui_mgr.schedule_once(0, self, self.first_init)

	self:init_lbl_font()


	local inner_content = self.list:getInnerContainer() 
	local init_num = 4
	local function tick_item()
		local x, y = inner_content:getPosition()
		if self.list:getChildrenCount() >= init_num and y > -100 then
			self.cur_pos = self.cur_pos + 1
			local item_data = self.view_item[self.cur_pos]
			if item_data == nil then
				return
			end
			self:_create_cell(item_data, self.cur_pos)
		elseif self.list:getChildrenCount() <= 1 then
			for i = 1, init_num do
				self.cur_pos = self.cur_pos + 1
				local item_data = self.view_item[self.cur_pos]
				if item_data == nil then
					break
				end
				self:_create_cell(item_data, self.cur_pos)
			end
			self.list:jumpToTop()
		end
		--print(self.list:getChildrenCount())
	end
	self.tick_item = cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick_item, 0, false)
end

function pvp_layer:first_init()
	self:checkbox_fun_1(true)
	self:set_handler("close_button", self.close_button_event)
	self:set_handler("refresh", self.refresh_button_event)
	--tick
	self:time_tick()
	local function tick()
		--检查是否移除ui
		self:time_tick()
	end
	self.tick = cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick, 1, false)

	--防守
	self.set_defense = self.panel:getChildByName('set_defense')
	self.set_defense:addTouchEventListener(
			function ( sender, event_type )
				if event_type == ccui.TouchEventType.ended then
					ui_mgr.create_ui(import('ui.pvp_skill_layer.pvp_skill_layer'), 'pvp_skill_layer')
				end
			end
		)

	--兑换
	self.shop = self.panel:getChildByName('shop')
	self.shop:addTouchEventListener(
			function ( sender, event_type )
				if event_type == ccui.TouchEventType.ended then
					local exchange	= ui_mgr.create_ui(import('ui.dhshop_layer.dhshop_layer'), 'dhshop_layer')
					exchange:set_proxy_type( 1 )
					exchange:reload()
				end
			end
		)
end

--对文字的描边
function pvp_layer:init_lbl_font(  )

end

function pvp_layer:time_tick(  )

	--刷新按钮
	local now = os.time() - self.player:get_cs_time()
	local next_time = self.player:get_pvp_candidate_refresh_time()

	if now >= next_time then
		self.count_down:setString('刷新')
		self.refresh:setTouchEnabled(true)
	else
		local sub = next_time - now
		local sec = math.floor(sub % 60)
		local min = math.floor(sub / 60)
		local hour = math.floor(sub / 60 / 60)
		local str = string.format("%02d:%02d:%02d", hour, min, sec)

		self.count_down:setString(str)
		self.refresh:setTouchEnabled(false)
	end

	--券恢复
	local pvp_ticket = self.player:get_pvp_ticket()
	local count = pvp_ticket.count

	self.ticket:setString(count)

	if count >= pvp_const.Ticket then
		self.lab_2:setString('卷已满')
		return
	end

	local time = pvp_ticket.time
	local sub2 = now - time
	if sub2 >= pvp_const.TicketRecoverTime then
		self.lab_2:setString('00:00:00')
		return
	end

	sub2 = pvp_const.TicketRecoverTime - sub2
	local sec = math.floor(sub2 % 60)
	local min = math.floor(sub2 / 60)
	local hour = math.floor(sub2 / 60 / 60)
	local str2 = string.format("%02d:%02d:%02d", hour, min, sec)

	self.lab_2:setString(str2)
end

function pvp_layer:refresh_point(  )
	self.my_point:setString(self.player:get_pvp_point())
end

function pvp_layer:refresh_honor(  )
	self.my_honor:setString(self.player:get_pvp_honor())
end

function pvp_layer:refresh_button_event( sender, event_type )
	if event_type == ccui.TouchEventType.ended then
		local now_cb_id = self:now_checkbox_touch_id()
		server._refresh_pvp_checkbox_ui( now_cb_id )
	end
end

--被回调，然后刷新UI
function pvp_layer:refresh_pvp_checkbox_ui( cb_id )
	--self['checkbox_fun_' .. cb_id](self)
	ui_mgr.schedule_once(0, self, self['checkbox_fun_' .. cb_id])
end

function pvp_layer:now_checkbox_touch_id(  )
	local checkbox_id = 1
	for i=1, _checkbox_count do
		if self.checkbox[i]:getSelectedState() then
			checkbox_id = i
			break
		end
	end
	return checkbox_id
end

function pvp_layer:checkbox_event( sender, event_type )

	if event_type == ccui.TouchEventType.ended then
		local split = string_split(sender:getName(), '_')
		local touch_id = tonumber(split[2])

		for i=1, _checkbox_count do
			if i ~= touch_id then
				self.checkbox[i]:setSelectedState(false)
				self.checkbox[i]:setTouchEnabled(true)
			else
				self.checkbox[i]:setTouchEnabled(false)
			end
		end
		self.rule:setVisible(false)
		self.refresh:setVisible(false)

		self.lab_1:setVisible(false)
		self.ticket:setVisible(false)
		self.lab_2:setVisible(false)

		self['checkbox_fun_' .. touch_id](self)
		self.cur_channel = touch_id
	end
end

function pvp_layer:pvp_avatar_info_layer( info )
	local avatar_info_layer = ui_mgr.create_ui(import('ui.avatar_info_layer.avatar_info_layer'), 'avatar_info_layer')
	local a_info = info
	if info['get_nick_name'] == nil then
		a_info = avatar.avatar()
		a_info:init_server_data(info)
		a_info:finish_server_data()
	end
	avatar_info_layer:set_info(a_info)
end

--对战
function pvp_layer:checkbox_fun_1( is_first )
	self.refresh:setVisible(true)
	self.lab_1:setVisible(true)
	self.lab_2:setVisible(true)
	self.ticket:setVisible(true)

	local pvp_ticket = self.player:get_pvp_ticket()
	self.ticket:setString(pvp_ticket.count)
	if is_first then
		self:_checkbox_fun_1()
	else
		ui_mgr.schedule_once(0, self, self._checkbox_fun_1)
	end
end

function pvp_layer:_create_cell(v, i)
	if self.cur_channel == 1 then
		local pvp_flag = self.player:get_pvp_candidate_flag()
		local cell = self.item_1:clone()
		cell:ignoreAnchorPointForPosition(true)
		cell:getChildByName('name'):setString(v:get_nick_name())
		cell:getChildByName('lv'):setString('Lv.' .. v:get_level())
		cell:getChildByName('fc'):setString(v:get_fc())
		cell:getChildByName('point'):setString(v:get_pvp_point())
		
		local function info( sender, event_type )
			if event_type == ccui.TouchEventType.ended then
				self:vs_event(v)
			end
		end

		local function detail_info( sender, event_type )
			if event_type == ccui.TouchEventType.ended then
				self:pvp_avatar_info_layer(v)
			end
		end

		--vs 按钮
		if pvp_flag[v.id] == 0 then
			local vs_btn = cell:getChildByName('vs')
			vs_btn:setVisible(true)
			vs_btn:addTouchEventListener(info)

			cell:getChildByName('point_bg'):setVisible(true)
			--算荣誉值
			local formula = pvp_const.HonorFormula
			local env = {b = v, a = self.player}
			setfenv(formula,env)()
			local add_point = self:check_max_min(env.s)
			local point = cell:getChildByName('add_point')
			point:setVisible(true)
			point:setString('+' .. add_point)
		else 	-- 挑战过且胜利
			cell:getChildByName('victory'):setVisible(true)
		end
		--头像
		local head = cell:getChildByName('head')
		head:setTouchEnabled(true)
		head:addTouchEventListener(detail_info)
		local head_s = head_icon.head_icon(v:get_role_type(), v.wear.helmet)
		head:addChild(head_s.cc)
		self.list:pushBackCustomItem(cell)
	
	elseif self.cur_channel == 3 then
	--------------rank--------------
		local rank_data, rank_num = self.player:get_pvp_rank()
		local cell = self.item_3:clone()
		cell:ignoreAnchorPointForPosition(true)
		
		cell:getChildByName('name'):setString(v.nick_name)
		cell:getChildByName('lv'):setString('Lv.' .. v.lv)
		cell:getChildByName('fc'):setString(math.floor(v.fc))
		cell:getChildByName('point'):setString(v.pvp_point)

		local function detail_info( sender, event_type )
			if event_type == ccui.TouchEventType.ended then
				self:pvp_avatar_info_layer(v)
			end
		end

		--头像
		local head = cell:getChildByName('head')
		head:setTouchEnabled(true)
		head:addTouchEventListener(detail_info)
		local head_s = head_icon.head_icon(v.role_type, v.wear.helmet)
		head:addChild(head_s.cc)

		--名次
		if i <= 3 then
			local r = cell:getChildByName('r_' .. i)
			r:setVisible(true)
		else
			local r = cell:getChildByName('r_' .. 4)

			if i == #rank_data and rank_num ~= nil then
				r:setString('NO.' .. rank_num)
			else
				r:setString('NO.' .. i)
			end
			r:setVisible(true)
		end
		self.list:pushBackCustomItem(cell)
	end

	
end

function pvp_layer:_checkbox_fun_1()
	local pvp_candidate = self.player:get_pvp_candidate()
	

	self.cur_pos = 0
	self.view_item = {}
	self.list:removeAllItems()
	self.list:jumpToTop()
	self:reload_json()
	
	for i,v in pairs(pvp_candidate) do
		
		table.insert(self.view_item, v)
	
	end
end

function pvp_layer:vs_event( player2 )
	self.player:set_pvp_player(player2.id)
	local fight_layer = ui_mgr.create_ui(import('ui.pvp_ui.fight_layer'), 'fight_layer')
	fight_layer:set_player_data( self.player, player2 )
end

--战斗记录
function pvp_layer:checkbox_fun_2(  )
	self.list:setVisible(true)
	ui_mgr.schedule_once(0, self, self._checkbox_fun_2)
end

function pvp_layer:_checkbox_fun_2()
	self.cur_pos = 0
	self.view_item = {}
	self.list:removeAllItems()
	self.list:jumpToTop()
	self:reload_json()
	-- self.refresh:setVisible(true) -- 战斗记录不需要刷新，服务器增加记录时，会马上同步到客户端avatar

	local record_data = self.player:get_pvp_record()
	for i,v in ipairs(record_data) do
		local cell = self.item_2:clone()
		cell:ignoreAnchorPointForPosition(true)
		self.list:pushBackCustomItem(cell)

		cell:getChildByName('name'):setString(v.his_data.nick_name)
		cell:getChildByName('lv'):setString('Lv.' .. v.his_data.lv)
		cell:getChildByName('fc'):setString(math.floor(v.his_data.fc))

		--多久之前的战斗记录
		local now = os.time()
		local sub = now - v.time
		if sub < 0 then sub = 0 end
		local hour = math.floor(sub / 60 / 60)
		cell:getChildByName('time'):setString(hour .. '小时前')

		local function detail_info( sender, event_type )
			if event_type == ccui.TouchEventType.ended then
				self:pvp_avatar_info_layer(v.his_data)
			end
		end

		--头像
		local head = cell:getChildByName('head')
		head:setTouchEnabled(true)
		head:addTouchEventListener(detail_info)
		local head_s = head_icon.head_icon(v.his_data.role_type, v.his_data.wear.helmet)
		head:addChild(head_s.cc)

		if v.challenge >= 1 then
			cell:getChildByName('challenge'):setVisible(true)
		else
			cell:getChildByName('defense'):setVisible(true)
		end

		local function info( sender, event_type )
			if event_type == ccui.TouchEventType.ended then
				self:record_vs_event(v, i)
			end
		end

		if v.result >= 1 then
			cell:getChildByName('victory_label'):setVisible(true)
			cell:getChildByName('victory'):setVisible(true)
		else
			cell:getChildByName('fail_label'):setVisible(true)
			cell:getChildByName('point_bg'):setVisible(true)
			cell:getChildByName('add_point'):setVisible(true)

			local vs_btn = cell:getChildByName('vs')
			vs_btn:setVisible(true)
			vs_btn:addTouchEventListener(info)

			--算积分
			local formula = pvp_const.HonorFormula
			local env = {b = v.his_data, a = self.player}
			setfenv(formula,env)()
			local add_point = self:check_max_min(env.s)
			cell:getChildByName('add_point'):setString('+' .. add_point)
		end
	end
end

function pvp_layer:record_vs_event( record_player, id )
	local player2 = self.player:pvp_record_to_player(record_player.his_data)
	self.player:set_pvp_is_revenge( id )

	local fight_layer = ui_mgr.create_ui(import('ui.pvp_ui.fight_layer'), 'fight_layer')
	fight_layer:set_player_data( self.player, player2 )
end

--世界排名
function pvp_layer:checkbox_fun_3(  )
	self.list:setVisible(true)
	ui_mgr.schedule_once(0, self, self._checkbox_fun_3)
end

function pvp_layer:_checkbox_fun_3()
	self.cur_pos = 0
	self.view_item = {}
	self.list:removeAllItems()
	self.list:jumpToTop()
	self:reload_json()

	local rank_data, rank_num = self.player:get_pvp_rank()
	for i,v in ipairs(rank_data) do
		table.insert(self.view_item, v)
	end
end

--规则奖励
function pvp_layer:checkbox_fun_4(  )
	self.list:setVisible(false)
	self.rule:setVisible(true)
end

-- --防守设置
-- function pvp_layer:checkbox_fun_5(  )
-- 	self.list:removeAllItems()
-- 	self.checkbox[5]:setTouchEnabled(true)
-- 	self.checkbox[5]:setSelectedState(false)

-- 	ui_mgr.create_ui(import('ui.pvp_skill_layer.pvp_skill_layer'), 'pvp_skill_layer')
-- end

-- --荣誉商店
-- function pvp_layer:checkbox_fun_6(  )
-- 	self.list:removeAllItems()
-- 	print('checkbox_fun_6')
-- end

function pvp_layer:close_button_event( sender, event_type )
	if event_type == ccui.TouchEventType.ended then
		sender:setTouchEnabled(false)
		self.cc:setVisible(false)
		self.is_remove = true
		anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_UP_ANIM,false)
	end
end

function pvp_layer:check_max_min(s)
    local ans = math.floor(s)
    if ans >= 0 then
        if ans > pvp_const.Point_abs_max then
            ans = pvp_const.Point_abs_max
        end 
        if ans < pvp_const.Point_abs_min then
            ans = pvp_const.Point_abs_min
        end 
    else
        if ans < -pvp_const.Point_abs_max then
            ans = -pvp_const.Point_abs_max
        end 
        if ans > -pvp_const.Point_abs_min then
            ans = -pvp_const.Point_abs_min  
        end 
    end 
    return ans 
end

function pvp_layer:release(  )
	if self.tick ~= nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.tick)
	end
	if self.tick_item ~= nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.tick_item)
	end
	super(pvp_layer,self).release()
end
