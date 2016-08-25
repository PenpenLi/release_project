local layer					= import( 'world.layer' )
local anim_trigger 			= import( 'ui.main_ui.anim_trigger')
local ui_const				= import( 'ui.ui_const' )
local ui_mgr 				= import( 'ui.ui_mgr' )
local model 				= import( 'model.interface' )
local combat_conf			= import( 'ui.lottery_layer.lottery_ui_conf' )
local ui_const 				= import( 'ui.ui_const' )
local locale				= import( 'utils.locale' )
local lottery_tx 			= import( 'ui.lottery_layer.lottery_tx' )
local lottery_items_panel 	= import( 'ui.lottery_layer.lottery_items_panel' )
local lottery_npc 			= import( 'ui.lottery_layer.lottery_npc' )
local ui_guide				= import( 'world.ui_guide' )
local msg_queue				= import( 'ui.msg_ui.msg_queue' )

lottery_layer = lua_class('lottery_layer',layer.ui_layer)

local _avatar 		= nil
local _cd_time 		= 5 * 60
local eicon_set 	= 'icon/e_icons.plist'
local iicon_set 	= 'icon/item_icons.plist'
local soul_set 		= 'icon/soul_icons.plist'
local _one_gold 	= 100
local _ten_gold 	= 900
local _one_diamond 	= 100
local _ten_diamond 	= 900
local _json_path	= 'gui/main/ui_lottery.ExportJson'
local _molingzhili_id 	= 90002
local _molingzhixin_id 	= 90003

function lottery_layer:_init(  )

	super(lottery_layer,self)._init(_json_path,true)
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2,VisibleSize.height/2)

	self:init_lbl_font()
	self:update_gold_diamond()
	self.close_button = self:get_widget('close_button')
	self:set_handler("close_button", self.close_button_event)
	self.chong_button = self:get_widget('Button_5')

	--金币一抽和十抽
	self.gl_one_btn = self:get_widget('gl_one_btn')
	self.gl_ten_btn = self:get_widget('gl_ten_btn')
	self:set_handler("gl_one_btn", self.gl_one_btn_event)
	self:set_handler("gl_ten_btn", self.gl_ten_btn_event)

	--砖石一抽和十抽按钮
	self.dl_one_btn = self:get_widget('dl_one_btn')
	self.dl_ten_btn = self:get_widget('dl_ten_btn')
	self:set_handler("dl_one_btn", self.dl_one_btn_event)
	self:set_handler("dl_ten_btn", self.dl_ten_btn_event)

	self.lbl_one_gold:setString(_one_gold)
	self.lbl_ten_gold:setString(_ten_gold)
	self.lbl_one_diamond:setString(_one_diamond)
	self.lbl_ten_diamond:setString(_ten_diamond)
	self.gl_free = false
	self.dl_free = false
	--金币倒数更新
	self:update_gl_lbl()
	self:update_dl_lbl()

	--加入npc
	self:add_npc()

	local function tick()
		--检查是否移除ui
		self:time_tick()
	end
	self.tick = cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick, 1, false)
end

--加入npc动画
function lottery_layer:add_npc(  )
	self.npc = lottery_npc.lottery_npc()
	self.widget:addChild(self.npc.cc,0)
	self.npc:play_anim(0,0-100)
end



--对文字的描边
function lottery_layer:init_lbl_font(  )
	for name, val in pairs(combat_conf.lottery_ui_lbl) do
		self['lbl_' .. name] = self:get_widget('lbl_' .. name)
		local temp_label = self['lbl_' .. name]
		if temp_label ~= nil then
			if locale.get_value('lottery_' .. name) ~= ' ' then
				temp_label:setString(locale.get_value('lottery_' .. name))		--如果传入的name在languane是没有的，就会返回以个空字符串
			end
			if val.edge ~= nil and val.edge > 0 then 					--edge的值大于0就描边
				temp_label:enableOutline(ui_const.UilableStroke, val.edge)  ---，描边，厚度 role_ui_conf.lua中role_ui_label的edge
			end
		end
	end
end



--更新钱，砖石
function lottery_layer:update_gold_diamond(  )
	local player = model.get_player()
	
	if player['money'] ~= nil then
		self.lbl_gold:setString(player['money']) 
	end
	if player['diamond'] ~= nil then
		self.lbl_diamond:setString(player['diamond']) 
	end
end

--金币一抽
function lottery_layer:gl_one_btn_event( sender, event_type )
	if event_type == ccui.TouchEventType.ended then
		if self.gl_free == true then
			self:set_button_touch(false)
			server.lottery_draw_one_by_money('free')
			ui_guide.pass_condition('first_lot_coin')
		else
			self:set_button_touch(false)
			local player = model.get_player()
			local gold = player:get_money()
			if gold < _one_gold then
				self:set_button_touch(true)
			end
			server.lottery_draw_one_by_money()
			ui_guide.pass_condition('first_lot_coin')
		end
	end
end

function lottery_layer:gl_one_event( goods_id, exist )
	msg_queue.add_item_msg(_molingzhili_id,1)
	self:set_button_touch(false)
	local temp_tx = ui_mgr.get_ui('lottery_tx')
	local temp_pl = ui_mgr.get_ui('lottery_items_panel')
	if temp_tx ~= nil and temp_pl ~=nil then
		
		temp_tx:set_remove()
		temp_pl:set_remove()
	end
	local function callFunc(  )
		local function call_back(  )
			local tp = ui_mgr.create_ui(import( 'ui.lottery_layer.lottery_items_panel' ), 'lottery_items_panel')
			tp:set_lottery_type(true)
			tp:set_lottery_count(true)
			tp:update_one_gl(goods_id,exist)

		end
		local tx = ui_mgr.create_ui(import( 'ui.lottery_layer.lottery_tx' ), 'lottery_tx')
		tx:play_anim(call_back)
	end
	local callFuncObj=cc.CallFunc:create(callFunc)
	self.cc:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),callFuncObj))
end



--金币十抽
function lottery_layer:gl_ten_btn_event( sender, event_type )
	if event_type == ccui.TouchEventType.ended then
		self:set_button_touch(false)
		local player = model.get_player()
		local gold = player:get_money()
		if gold < _ten_gold then
			self:set_button_touch(true)
		end
		server.lottery_draw_ten_by_money( )
	end
end

function lottery_layer:gl_ten_event( goods_ids ,exists)
	msg_queue.add_item_msg(_molingzhili_id,10)
	self:set_button_touch(false)
	local temp_tx = ui_mgr.get_ui('lottery_tx')
	local temp_pl = ui_mgr.get_ui('lottery_items_panel')
	if temp_tx ~= nil and temp_pl ~=nil then
		
		temp_tx:set_remove()
		temp_pl:set_remove()
	end
	local function callFunc(  )
		local function call_back(  )
			local tp = ui_mgr.create_ui(import( 'ui.lottery_layer.lottery_items_panel' ), 'lottery_items_panel')
			tp:set_lottery_type(true) --设置抽奖类型，金币true 砖石 false
			tp:set_lottery_count(false) --true 抽十次，false 抽一次
			tp:update_ten_gl(goods_ids,exists)

		end
		local tx = ui_mgr.create_ui(import( 'ui.lottery_layer.lottery_tx' ), 'lottery_tx')
		tx:play_anim(call_back)
	end
	local callFuncObj=cc.CallFunc:create(callFunc)
	self.cc:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),callFuncObj))


end

--砖石一抽
function lottery_layer:dl_one_btn_event( sender, event_type )
	if event_type == ccui.TouchEventType.ended then
		if self.dl_free == true then
			self:set_button_touch(false)
			server.lottery_draw_one_by_diamond('free')
			ui_guide.pass_condition('first_lot_gem')
		else
			local player = model.get_player()
			local diamond = player:get_diamond()
			if diamond < _one_diamond then
				self:set_button_touch(true)
			end
			server.lottery_draw_one_by_diamond()
			ui_guide.pass_condition('first_lot_gem')
		end
	end
end

function lottery_layer:dl_one_event( goods_id ,exist)
	msg_queue.add_item_msg(_molingzhixin_id,1)
	self:set_button_touch(false)
	local temp_tx = ui_mgr.get_ui('lottery_tx')
	local temp_pl = ui_mgr.get_ui('lottery_items_panel')
	if temp_tx ~= nil and temp_pl ~=nil then
		
		temp_tx:set_remove()
		temp_pl:set_remove()
	end
	local function callFunc(  )
		local function call_back(  )
			local tp = ui_mgr.create_ui(import( 'ui.lottery_layer.lottery_items_panel' ), 'lottery_items_panel')
			tp:set_lottery_type(false)
			tp:set_lottery_count(true)
			tp:update_one_gl(goods_id,exist)

		end
		local tx = ui_mgr.create_ui(import( 'ui.lottery_layer.lottery_tx' ), 'lottery_tx')
		tx:play_anim(call_back)
	end
	local callFuncObj=cc.CallFunc:create(callFunc)
	self.cc:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),callFuncObj))
end


--砖石十抽
function lottery_layer:dl_ten_btn_event( sender, event_type )
	if event_type == ccui.TouchEventType.ended then
		self:set_button_touch(false)

		local player = model.get_player()
		local diamond = player:get_diamond()
		if diamond < _ten_diamond then
			self:set_button_touch(true)
		end
		server.lottery_draw_ten_by_diamond( )
	end
end

function lottery_layer:dl_ten_event( goods_ids,exists )
	msg_queue.add_item_msg(_molingzhixin_id,10)
	self:set_button_touch(false)
	local temp_tx = ui_mgr.get_ui('lottery_tx')
	local temp_pl = ui_mgr.get_ui('lottery_items_panel')
	if temp_tx ~= nil and temp_pl ~=nil then
		
		temp_tx:set_remove()
		temp_pl:set_remove()
	end
	local function callFunc(  )
		local function call_back(  )
			local tp = ui_mgr.create_ui(import( 'ui.lottery_layer.lottery_items_panel' ), 'lottery_items_panel')
			tp:set_lottery_type(false) --设置抽奖类型，金币true 砖石 false
			tp:set_lottery_count(false) --true 抽十次，false 抽一次
			tp:update_ten_gl(goods_ids,exists)
			
		end
		local tx = ui_mgr.create_ui(import( 'ui.lottery_layer.lottery_tx' ), 'lottery_tx')
		tx:play_anim(call_back)
	end
	local callFuncObj=cc.CallFunc:create(callFunc)
	self.cc:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),callFuncObj))


end


function lottery_layer:set_button_touch( is_touch )
	if is_touch == true then
		self.gl_one_btn:setTouchEnabled(true)
		self.gl_ten_btn:setTouchEnabled(true)
		self.dl_one_btn:setTouchEnabled(true)
		self.dl_ten_btn:setTouchEnabled(true)
		self.close_button:setTouchEnabled(true)
		self.chong_button:setTouchEnabled(true)
	else
		self.gl_one_btn:setTouchEnabled(false)
		self.gl_ten_btn:setTouchEnabled(false)
		self.dl_one_btn:setTouchEnabled(false)
		self.dl_ten_btn:setTouchEnabled(false)
		self.close_button:setTouchEnabled(false)
		self.chong_button:setTouchEnabled(false)
	end
end

function lottery_layer:draw_button_event(  )

	local function money_draw_one( sender, event_type )
		if event_type == ccui.TouchEventType.ended then
			print('money_draw_one', sender:getName())
			server.lottery_draw_one_by_money('free')
		end
	end

	local function money_draw_ten( sender, event_type )
		if event_type == ccui.TouchEventType.ended then
			print('money_draw_ten', sender:getName())
		end
	end

	local function diamond_draw_one( sender, event_type )
		if event_type == ccui.TouchEventType.ended then
			print('diamond_draw_one', sender:getName())
		end
	end

	local function diamond_draw_ten( sender, event_type )
		if event_type == ccui.TouchEventType.ended then
			print('diamond_draw_ten', sender:getName())
		end
	end

	self.money_draw_one:addTouchEventListener(money_draw_one)
	self.money_draw_ten:addTouchEventListener(money_draw_ten)
	self.diamond_draw_one:addTouchEventListener(diamond_draw_one)
	self.diamond_draw_ten:addTouchEventListener(diamond_draw_ten)
end



function lottery_layer:close_button_event( sender, event_type )
	if event_type == ccui.TouchEventType.ended then
		sender:setTouchEnabled(false)
		self.cc:setVisible(false)
		self.is_remove = true
		anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_UP_ANIM,false)
	end
end


function lottery_layer:time_tick(  )
	
	self:update_gl_lbl()
	self:update_dl_lbl()

end



function lottery_layer:update_gl_lbl(  )

	local avatar = model.get_player()
	local last = avatar:get_lottery_m_time()
	self:get_widget('lbl_gl_free_count'):setVisible(false)
	self:get_widget('gl_free_cd_panel'):setVisible(true)
	local time = os.time()-avatar:get_cs_time()
	local all_time = 60
	local temp = time - last
	local t = all_time - temp
	--print('CD总时间:'..all_time ..'以前时间：'..last ..'现在时间：'..time .. '已运行时间'.. temp ..'剩余时间：'.. t)
	--时间到了
	--dir(avatar.lottery)
	local num = avatar:get_lottery_m_free()
	if t<=0 or num<=0 then
		self.gl_free = true

		self:get_widget('lbl_gl_free_count'):setVisible(true)
		self:get_widget('gl_free_cd_panel'):setVisible(false)
		
		self:get_widget('lbl_gl_free_count'):setString(locale.get_value('lottery_free_count')..num ..'/5')
		self.lbl_gl_one_btn:setString(locale.get_value('lottery_free'))
		if num<=0 then
			self.gl_free = false
			self.lbl_gl_one_btn:setString(locale.get_value('lottery_gl_one_btn'))
		end
		return 
	end

	--事件还未到
	local sec = t % 60
	if sec < 10 then
		sec = '0'..sec
	end
	local min = math.floor(t/60) %60
	--print('分：',min)
	if min < 10 then
		min = '0'..min
	end
	local hour = math.floor((t/60)/60)
	if hour < 10 then
		hour = '0'..hour
	end
  	--print(hour ..'时'.. min .. '分'..sec)
  	self.gl_free = false
  	self:get_widget('lbl_gl_time'):setString(hour ..':'.. min .. ':'..sec)
  	self:get_widget('lbl_free_g_tips'):setString(locale.get_value('lottery_freed'))
  	self.lbl_gl_one_btn:setString(locale.get_value('lottery_gl_one_btn'))
end


function lottery_layer:update_dl_lbl(  )

	local avatar = model.get_player()
	local last = avatar:get_lottery_d_time()
	self:get_widget('lbl_dl_free_count'):setVisible(false)
	self:get_widget('dl_free_cd_panel'):setVisible(true)
	local time = os.time()-avatar:get_cs_time()
	local all_time = 60
	local temp = time - last
	local t = all_time - temp
	--print('CD总时间:'..all_time ..'以前时间：'..last ..'现在时间：'..time .. '已运行时间'.. temp ..'剩余时间：'.. t)
	--时间到了
	--dir(avatar.lottery)
	local num = 1
	if t<=0  then
		self.dl_free = true

		self:get_widget('lbl_dl_free_count'):setVisible(true)
		self:get_widget('dl_free_cd_panel'):setVisible(false)
		
		self:get_widget('lbl_dl_free_count'):setString(locale.get_value('lottery_free_count')..num ..'/1')
		self.lbl_dl_one_btn:setString(locale.get_value('lottery_free'))
		-- if num<1 then
		-- 	self.dl_free = false
		-- 	self.lbl_dl_one_btn:setString('抽一次')
		-- end
		return 
	end

	--事件还未到
	local sec = t % 60
	if sec < 10 then
		sec = '0'..sec
	end
	local min = math.floor(t/60) %60
	--print('分：',min)
	if min < 10 then
		min = '0'..min
	end
	local hour = math.floor((t/60)/60)
	if hour < 10 then
		hour = '0'..hour
	end
  	--print(hour ..'时'.. min .. '分'..sec)
  	self.dl_free = false
  	self:get_widget('lbl_dl_time'):setString(hour ..':'.. min .. ':'..sec)
  	self:get_widget('lbl_free_d_tips'):setString(locale.get_value('lottery_freed'))
  	self.lbl_dl_one_btn:setString(locale.get_value('lottery_gl_one_btn'))
end



function lottery_layer:reload(  )
	super(lottery_layer,self).reload()
	self:update_gold_diamond()
end

--更新金钱
function lottery_layer:reload_lbl(  )
	super(lottery_layer,self).reload()
	self:update_gold_diamond()
end

function lottery_layer:release(  )
	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.tick)
	self.is_remove = false
	self.npc:release()
	super(lottery_layer,self).release()
end
