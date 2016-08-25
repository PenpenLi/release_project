local layer				= import( 'world.layer' )
local anim_trigger 		= import( 'ui.main_ui.anim_trigger')
local model 			= import( 'model.interface' )
local combat_conf		= import( 'ui.main_ui.main_surface_ui_conf' )
local main_map			= import( 'ui.main_map' )
local locale			= import( 'utils.locale' )
local ui_const			= import( 'ui.ui_const' )
local ui_mgr			= import( 'ui.ui_mgr' )
local rich_text			= import( 'ui.chat_box_layer.rich_text' )
local chat_ui			= import( 'ui.chat_box_layer.chat_box_layer')
local head_icon			= import( 'ui.head_icon.head_icon' )
local msg_queue 		= import( 'ui.msg_ui.msg_queue' )

main_surface_layer = lua_class('main_surface_layer',layer.ui_layer)

local roll_speed = 45
local chat_list_width = 350
local roll_times = 3

function main_surface_layer:_init(  )


	super(main_surface_layer,self)._init()
	--self.layer_mgr = layer
	self.player 	= model.get_player()
	self.is_remove = false
	--聊天
	self.chat_panel = ccs.GUIReader:getInstance():widgetFromJsonFile('gui/main/chat_panel.ExportJson')
	self.cc:addChild(self.chat_panel,1)
	self.chat_panel:ignoreAnchorPointForPosition(true)
	self.chat_panel:setPosition(0,0)
	self.chat_list = self:get_widget(self.chat_panel,"chat_list")
	self.chat_list_x = self.chat_list:getPositionX()
	self.nickname = self:get_widget(self.chat_panel,'name_label')
	self.chat_msg = self:get_widget(self.chat_panel,'chat_label')
	--self.chat_label:ignoreContentAdaptWithSize(false) self.nickname self.chat_msg
	--头像
	self.head_panel = ccs.GUIReader:getInstance():widgetFromJsonFile('gui/main/head_panel.ExportJson')
	self.cc:addChild(self.head_panel,1)
	self.head_panel:ignoreAnchorPointForPosition(true)
	self.head_panel:setPosition(0,VisibleSize.height)
	self.head_btn = self:get_widget(self.head_panel, "Panel_16")
	self.head = head_icon.head_icon(model.get_player().role_type, model.get_player().wear.helmet)
	--self.head.cc:setPosition(self.head_btn:getContentSize().width/2, 0)
	self:get_widget(self.head_panel,"button_1"):addChild(self.head.cc)

	--菜单列表
	self.menu_panel = ccs.GUIReader:getInstance():widgetFromJsonFile('gui/main/menu_panel.ExportJson')
	self.cc:addChild(self.menu_panel,1)
	self.menu_panel:ignoreAnchorPointForPosition(true)
	self.menu_panel:setPosition(VisibleSize.width,0)

	--物品信息
	self.good_info_panel = ccs.GUIReader:getInstance():widgetFromJsonFile('gui/main/good_info_panel.ExportJson')
	self.cc:addChild(self.good_info_panel,1)
	self.good_info_panel:ignoreAnchorPointForPosition(true)
	self.good_info_panel:setPosition(VisibleSize.width,VisibleSize.height)


	--右边按钮
	self.right_panel = ccs.GUIReader:getInstance():widgetFromJsonFile('gui/main/right_panel.ExportJson')
	self.cc:addChild(self.right_panel,1)
	self.right_panel:ignoreAnchorPointForPosition(true)
	self.right_panel:setPosition(VisibleSize.width,VisibleSize.height/2)
	--self.btn_mail = self:get_widget(self.right_panel, "button_09")

	self.cc:setVisible(false)
	--注册事件
	anim_trigger.remove_event(anim_trigger.MAIN_SURFACE_DOWN_ANIM)
	anim_trigger.remove_event(anim_trigger.MAIN_SURFACE_UP_ANIM)
	self:regist_up_anim( )
	self:regist_down_anim( )
	self:set_is_gray(false)


	--延迟播放动画
		self.cc:setVisible(true)
	local function callFunc( )
		self.cc:setVisible(true)
		anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_UP_ANIM,false)
		--self:set_btns_no_touch(  )
	end
	local callFuncObj=cc.CallFunc:create(callFunc)
	--self.cc:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), callFuncObj))

	--更新lbl信息
	self:updata_lbl_info()

	--人物头像
	local function button_1_event(  sender, eventtype  )
		if eventtype == ccui.TouchEventType.ended then
			--ui_mgr.create_ui(import('ui.equip_sys_layer.equip_sys_layer'), 'equip_sys_layer')
			ui_mgr.create_ui(import('ui.setup_layer.setup_layer'), 'setup_layer')
			--sender:setTouchEnabled(false)
			--anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_DOWN_ANIM,false)
		end
	end

	--聊天
	local function button_2_event(  sender, eventtype  )
		if eventtype == ccui.TouchEventType.ended then
			--anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_DOWN_ANIM,false)
			ui_mgr.create_ui(import('ui.chat_box_layer.chat_box_layer'), 'chat_box_layer')
			--sender:setTouchEnabled(false)
		end
	end

	--装备界面
	local function button_3_event(  sender, eventtype  )
		if eventtype == ccui.TouchEventType.ended then
			ui_mgr.create_ui(import('ui.equip_sys_layer.equip_sys_layer'), 'equip_sys_layer')
			--sender:setTouchEnabled(false)
			--anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_DOWN_ANIM,false)
		end
	end


	--背包界面
	local function button_4_event(  sender, eventtype  )
		if eventtype == ccui.TouchEventType.ended then
			ui_mgr.create_ui(import('ui.bag_system_layer.bag_system_layer'), 'bag_system_layer')
			--sender:setTouchEnabled(false)
			--anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_DOWN_ANIM,false)
		end
	end

	--魔灵界面
	local function button_5_event(  sender, eventtype  )
		if eventtype == ccui.TouchEventType.ended then
			anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_DOWN_ANIM,false)
			ui_mgr.create_ui(import('ui.soul_system.soul_page_panel'), 'soul_page_panel')
			--ui_mgr.create_ui(import('ui.active_ui.active_layer'), 'active_layer')
			--ui_mgr.reload()
		end
	end

	--精通界面
	local function button_6_event(  sender, eventtype  )
		if eventtype == ccui.TouchEventType.ended then
			anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_DOWN_ANIM,false)
			ui_mgr.create_ui(import('ui.proficient_layer.proficient_layer'), 'proficient_layer')
			--ui_mgr.reload()
		end
	end

	--地图界面
	local function button_7_event(  sender, eventtype  )
		if eventtype == ccui.TouchEventType.ended then
			-- anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_DOWN_ANIM,false)
			-- local temp_ui = ui_mgr.create_ui(import('ui.strengthen_layer.strengthen_layer'), 'strengthen_layer')
			-- ui_mgr.reload()
			anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_DOWN_ANIM,false)
			local temp_ui = ui_mgr.create_ui(import('ui.map_layer.map_layer'), 'map_layer')
			--temp_ui:open_common_map()
			--ui_mgr.reload()
		end
	end

	--签到界面
	local function button_8_event(  sender, eventtype  )
		if eventtype == ccui.TouchEventType.ended then
			anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_DOWN_ANIM,false)
			ui_mgr.create_ui(import('ui.sign_in_layer.sign_in_layer'), 'sign_in_layer')
		end
	end


	--商城界面
	local function button_9_event(  sender, eventtype  )
		if eventtype == ccui.TouchEventType.ended then
			ui_mgr.create_ui(import('ui.market_layer.market_layer'), 'market_layer')
		end
	end

	--活动界面
	local function button_10_event(  sender, eventtype  )
		if eventtype == ccui.TouchEventType.ended then
			anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_DOWN_ANIM,false)
			ui_mgr.create_ui(import('ui.active_ui.active_layer'), 'active_layer')
		end
	end

	--任务界面
	local function button_11_event(  sender, eventtype  )
		if eventtype == ccui.TouchEventType.ended then
			anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_DOWN_ANIM,false)
			ui_mgr.create_ui(import('ui.task_layer.task_layer'), 'task_layer')
			--ui_mgr.reload()
		end
	end

	local function midas_touch_event(  sender, eventtype  )
		if eventtype == ccui.TouchEventType.ended then
			anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_DOWN_ANIM,false)
			local midas_cnt = self.player:get_midas_touch()
			local total_times = data.vip[self.player.vip.lv + 1].midas_max
			if midas_cnt < total_times then
				ui_mgr.create_ui(import('ui.midas_touch_layer.midas_touch_layer'), 'midas_touch_layer')
			else
				ui_mgr.create_ui(import('ui.midas_touch_layer.midas_touch_tip'), 'midas_touch_tip')
			end
		end
	end

	local function market_touch_event(  sender, eventtype  )
		if eventtype == ccui.TouchEventType.ended then
			anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_DOWN_ANIM,false)
			ui_mgr.create_ui(import('ui.market_layer.market_layer'), 'market_layer')
		end
	end

	local function energy_touch_event( sender, eventtype)
		if eventtype == ccui.TouchEventType.ended then
			local msg_ui = ui_mgr.create_ui(import('ui.msg_ui.msg_ok_cancel_layer'), 'msg_ok_cancel_layer')
			local buy_time_limit = self.player:get_vip_buy_energy_time()
			local buy_data		= data.energy_purchase[self.player.energy_buy_daily + 1]
			if self.player.energy_buy_daily >= buy_time_limit then
				msg_ui:set_tip(locale.get_value_with_var('energy_buy_time_limit',{time = self.player.energy_buy_daily}))
				msg_ui:set_button_name('取消','vip特权')
				msg_ui:set_cancel_function(self.goto_vip)
			else 
				msg_ui:set_tip(locale.get_value_with_var('energy_buy',{diamond =buy_data.diamond, energy = buy_data.energy, time = self.player.energy_buy_daily}))
				msg_ui:set_ok_function(self.buy_energy)
			end
		end
	end

	--self.button_4= self:get_widget(self.menu_panel,"button_4")
	self:set_widget_handler( self:get_widget('head_panel',"button_"..EnumMainSfeBtn.btn_head), button_1_event)  	--头像按钮
	self:set_widget_handler( self:get_widget('chat_panel',"button_"..EnumMainSfeBtn.btn_chat), button_2_event)		--聊天按钮
	self:set_widget_handler( self:get_widget('menu_panel',"button_"..EnumMainSfeBtn.btn_achievement), button_3_event)		--人物按钮
	self:set_widget_handler( self:get_widget('menu_panel',"button_"..EnumMainSfeBtn.btn_bag), button_4_event)		--背包按钮
	self:set_widget_handler( self:get_widget('menu_panel',"button_"..EnumMainSfeBtn.btn_soul), button_5_event)		--魔灵按钮
	self:set_widget_handler( self:get_widget('menu_panel',"button_"..EnumMainSfeBtn.btn_proficient), button_6_event)		--精通按钮
	self:set_widget_handler( self:get_widget('menu_panel',"button_"..EnumMainSfeBtn.btn_map), button_7_event)		--战役按钮
	self:set_widget_handler( self:get_widget('right_panel',"button_"..EnumMainSfeBtn.btn_sign), button_8_event)		--签到按钮
	self:set_widget_handler( self:get_widget('right_panel',"button_"..EnumMainSfeBtn.btn_market), button_9_event)		--商城按钮
	self:set_widget_handler( self:get_widget('right_panel',"button_"..EnumMainSfeBtn.btn_activity), button_10_event)	--活动按钮
	self:set_widget_handler( self:get_widget('right_panel',"button_"..EnumMainSfeBtn.btn_assignment), button_11_event)	--任务

	self:set_widget_handler( self:get_widget('good_info_panel', 'button_8_0_1'), midas_touch_event)
	self:set_widget_handler( self:get_widget('good_info_panel', 'button_8_0'), market_touch_event)
	self:set_widget_handler( self:get_widget('good_info_panel', 'button_energy'), energy_touch_event)

	--设置红点显示
	self:init_equip_red()
	self:init_read_t()
	self:init_sign_in()
	self:reword_remind()
end

function main_surface_layer:init_read_t()

	self:set_red_point_visible(EnumMainSfeBtn.btn_activity,true)
	local read_str	= cc.UserDefault:getInstance():getStringForKey("had_read")
	local read_table	= {}
	local has_read	= 0
	if read_str ~= '' then
	 	for m in string.gmatch(read_str,'[^|]+') do
	 		if m ~= '' and m ~= nil then
	 			has_read = has_read + 1
	 		end
	 	end
	end
	local need_read = 0
	for i,v in pairs(data.notice) do 
		need_read = need_read + 1
	end
	for i,v in pairs(data.activities) do 
		local year, month, day, hour = self:time_to_str(v.end_time)
		local end_date = {['year'] = tonumber(year),  ['month'] = tonumber(month),  ['day'] = tonumber(day),  ['hour'] = tonumber(hour)}
		local end_time_stamp = os.time(end_date)
		local year, month, day, hour = self:time_to_str(v.start_time)
		local start_date = {['year'] = tonumber(year),  ['month'] = tonumber(month),  ['day'] = tonumber(day),  ['hour'] = tonumber(hour)}
		local start_time_stamp = os.time(start_date)
		local now_time = os.time()
		if end_time_stamp > now_time and now_time > start_time_stamp then
			need_read = need_read + 1
		end	
	end
	if has_read >= need_read then
		self:set_red_point_visible(EnumMainSfeBtn.btn_activity,false)
	end
end

function main_surface_layer:init_sign_in()
	if model.get_player():is_today_signed() then
		self:set_red_point_visible(EnumMainSfeBtn.btn_sign, false)
	else
		self:set_red_point_visible(EnumMainSfeBtn.btn_sign, true)
	end
end

---装备界面红显示-------------------
function main_surface_layer:init_equip_red(  )
	for k,v in pairs(EnumEquip) do
		local is_red = self:set_equip_red_pos( v )
		if is_red == true then
			self:set_red_point_visible(EnumMainSfeBtn.btn_achievement, is_red)
			return
		else
			self:set_red_point_visible(EnumMainSfeBtn.btn_achievement, is_red)
		end
	end
end

function main_surface_layer:set_equip_red_pos( equip_type )
	local cur_type = equip_type
	self.equip_keys = {}
	local player = model.get_player()
	self.cur_wearing_idx = player:get_wear(cur_type):get_id()
	local player_lv = player:get_level()
	local equips = player:get_equips()
	for id, it in pairs(data[cur_type]) do
		if player_lv >=  it.Lv  then
			if equips[tostring(id)] == nil and id ~= self.cur_wearing_idx then
				local cur_num = player:get_one_equip_frag(it.color..'_'..cur_type)
				local need_num  =  data.equipment_activation[it.color..'_'..cur_type]
				
				if cur_num >= need_num then
					
					return true
				end
				
			end
		end

	end
	return false
end
---------------------------------------------

--更新文字信息

function main_surface_layer:updata_lbl_info(  )
	self.player 	= model.get_player()
	for name, val in pairs(combat_conf.main_surface_ui_txt) do 	--读出main_surface_ui_txt文件的table
		--名字加前缀，就可以读出相应的名字label控件
		

		self['txt_' .. name] = self:get_widget(val.widget,'txt_'..name)	--一样，这样就可以读出相应的数值的label控件
		--把读出来的控件存到self的一个table中
		local temp_val = self['txt_'..name]
		if temp_val ~= nil then
			--temp_val:setFontName(ui_const.UiLableFontType)
			if self.player[name] ~= nil then
				temp_val:setString(self.player[name]) --把玩家的战斗属性值设置到这个Val label中
			else
				temp_val:setString(val.text)
			end
			if val.edge ~= nil and val.edge > 0 then 					--edge的值大于0就描边
				temp_val:enableOutline(ui_const.UilableStroke, val.edge)  ---，描边，厚度 role_ui_conf.lua中role_ui_label的edge
			end
		end

	end



	for name, val in pairs(combat_conf.main_surface_ui_txt) do
		self['lbl_' .. name] = self:get_widget(val.widget,'lbl_'..name)	
		local temp_label = self['lbl_' .. name]
		
		if temp_label ~= nil then
			
			--temp_label:setFontName(ui_const.UiLableFontType)
			-- temp_label:setString(val.text)
			temp_label:setString(locale.get_value('main_ui_' .. name))
			if val.edge ~= nil and val.edge > 0 then
				temp_label:enableOutline(ui_const.UilableStroke, val.edge)
			end
		end
	end

	--更新聊天消息
	local msg = chat_ui.get_recent_msg()
	if msg ~= nil then
		self:updata_msg(msg)
	end


	self.head:change_equip(self.player.wear['helmet'])
end



--动画升起实现

function main_surface_layer:regist_up_anim(  )
	--暂停触摸
	local function play_anim(  )
		-- if ui_mgr.gray_ui_stack.main_scene:size() > 2 then
		-- 	return
		-- end
		--self.head:retain()
		--self:set_btns_no_touch(  )
		local function callFunc( )
			--恢复触摸
			self:set_btns_can_touch(  )
		end
		local callFuncObj=cc.CallFunc:create(callFunc)
		--更新lbl信息
		self:updata_lbl_info()
		self:reload()
		-- self:play_action('chat_panel.ExportJson','up')
		-- self:play_action('head_panel.ExportJson','up')
		-- self:play_action('menu_panel.ExportJson','up')
		-- self:play_action('good_info_panel.ExportJson','up',callFuncObj)
	end
	anim_trigger.regist_event(anim_trigger.MAIN_SURFACE_UP_ANIM, play_anim)
end



--动画降下实现

function main_surface_layer:regist_down_anim( )

	local function play_anim(  )
		-- if ui_mgr.gray_ui_stack.main_scene:size() > 2 then
		-- 	return
		-- end
		--self.head:retain()
		self:set_btns_no_touch(  )
		--更新lbl信息
		self:updata_lbl_info()
		self:play_action('chat_panel.ExportJson','down')
		self:play_action('head_panel.ExportJson','down')
		self:play_action('menu_panel.ExportJson','down')
		self:play_action('good_info_panel.ExportJson','down')
	end 


	--anim_trigger.regist_event(anim_trigger.MAIN_SURFACE_DOWN_ANIM, play_anim)

end

--控制所有按钮不可按

function main_surface_layer:set_btns_no_touch(  )
	
	for i = 1, 11 do
		self['button_'.. i]:setTouchEnabled(false)
	end

end

--控制所有按钮可按
function main_surface_layer:set_btns_can_touch(  )
		for i = 1, 11 do
		self['button_'.. i]:setTouchEnabled(true)
	end

end


function main_surface_layer:get_widget(widget_name,name)
	--覆写get_widget
	local widget = nil
	if type(widget_name) == 'string' then
		widget = self[widget_name]
	else
		widget = widget_name
	end

	self[name] = ccui.Helper:seekWidgetByName(widget, name)
	return self[name]
end

function main_surface_layer:release()
	self.is_remove = true
	cc.SpriteFrameCache: getInstance(): removeSpriteFramesFromFile( 'gui/ui_main_surface/Ui-main0.plist' )
	super(main_surface_layer,self).release()
end

function get_gm_cmd( s, p )
	p = p or '%s'
	p = string.format( '[^%s]+', p )
	local cmd = nil
	local result = {}
 	for m in string.gmatch( s, p ) do
 		if cmd == nil then
 			cmd = m
 		else
			table.insert( result, m )
		end
	end
	return cmd, result
end

function main_surface_layer:send_debug_info(  sender, eventtype  )
	if eventtype == ccui.TouchEventType.ended then
		local cmd = self:get_widget(self.chat_panel,"TextField_8"):getStringValue()
		print("----------------",cmd)
		local cmd_str, args = get_gm_cmd(cmd,' ')
		if cmd_str ~= nil then
			server.gm_cmd(cmd_str, args)
		end
	end
end

function main_surface_layer:reword_remind()
	local quest = self.player:get_quests()
	local quest_daily = self.player:get_quests_daily()
	for i,v in pairs(quest) do
		if v ~= 1 and v:is_complete() then
			self:set_red_point_visible( EnumMainSfeBtn.btn_assignment,true )
			return
		end
	end
	for i,v in pairs(quest_daily) do
		if v ~= 1 and v:is_complete() then
			self:set_red_point_visible( EnumMainSfeBtn.btn_assignment,true )
			return 
		end
	end
	self:set_red_point_visible( EnumMainSfeBtn.btn_assignment,false )

end

function main_surface_layer:updat_head(  )
	if self.head ~= nil then
		self.head.cc:removeFromParent()
		self.head = head_icon.head_icon(model.get_player().role_type, model.get_player().wear.helmet)
		--self.head.cc:setPosition(self.head_btn:getContentSize().width/2, 0)
		self:get_widget(self.head_panel,"button_1"):addChild(self.head.cc)
	end
end

--设置红点显示
function main_surface_layer:set_red_point_visible( id,isVisible )
	local name = 'button_'..id

	if isVisible == true then
		self[name]:getChildByName(name..'_red'):setVisible(true)
	else
		self[name]:getChildByName(name..'_red'):setVisible(false)
	end
end


--主界面更新
function main_surface_layer:reload()
	super(main_surface_layer,self).reload()
	self:updat_head()
	self:updata_lbl_info()
	self:init_equip_red()
	self:init_read_t()
	self:init_sign_in()
	self:reword_remind()
end

--更新金钱
function main_surface_layer:reload_lbl(  )
	super(main_surface_layer,self).reload()
	self:updata_lbl_info()
end

--更新聊天信息
function main_surface_layer:updata_msg( msg_data )
	local msg = rich_text.rich_text_layout(msg_data)
	local cnt = 0
	if msg_data.channel == 'private' then 
		return
	else
		ccs.GUIReader:getInstance():widgetFromJsonFile('gui/main/chat_panel.ExportJson')
		
		self.nickname:setString(msg_data.nick_name .. ':')
		self.chat_msg:setString(msg.text)
		local nickname = self.nickname:clone()
		local msg_text = self.chat_msg:clone()
		self.chat_list:removeAllChildren()
		self.chat_list:pushBackCustomItem(nickname)
		self.chat_list:pushBackCustomItem(msg_text)
	end
	local move = cc.MoveBy:create(1,cc.p(-roll_speed, 0))


	local call_func=cc.CallFunc:create(function()
			self.chat_list_x = self.chat_list_x - roll_speed
			if self.chat_list_x < - self.nickname:getContentSize().width - self.chat_msg:getContentSize().width then
				self.chat_list:setPositionX(chat_list_width)
				self.chat_list_x = chat_list_width
				cnt = cnt + 1
				if cnt > roll_times then
					self.chat_list:stopAllActions()
					self.chat_list:removeAllChildren()
				end
			end
		end
		)
	self.chat_list:stopAllActions()
	self.chat_list:runAction(cc.RepeatForever:create(cc.Sequence:create(move, call_func)))
end


function main_surface_layer:buy_energy()
	server.buy_energy()
end

function main_surface_layer:goto_vip()
	local vip_ui = ui_mgr.create_ui(import('ui.market_layer.market_layer'), 'market_layer')
	vip_ui:jump_to_layer( 2 )
end

function main_surface_layer:time_to_str( time_str )
	local i,j = string.find(time_str,'-')
	local year = string.sub(time_str,1,i - 1)
	time_str 	= string.sub(time_str,i + 1,-1)
	i,j 	= string.find(time_str,'-')
	local month = string.sub(time_str,1,i - 1)
	time_str 	= string.sub(time_str,i + 1,-1)
	i,j 	= string.find(time_str,'-')
	local day	= string.sub(time_str,1,i - 1)
	local hour	= string.sub(time_str,i + 1,-1)
	return year,month,day,hour
end
