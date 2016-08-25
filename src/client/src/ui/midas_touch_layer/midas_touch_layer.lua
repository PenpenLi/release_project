local layer 			= import('world.layer')
local ui_mgr 			= import( 'ui.ui_mgr' ) 
local combat_conf		= import( 'ui.midas_touch_layer.midas_touch_cont' )
local locale			= import( 'utils.locale' )
local anim_trigger 		= import( 'ui.main_ui.anim_trigger')
local ui_const			= import( 'ui.ui_const' )
local model             = import( 'model.interface')

local load_texture_type = TextureTypePLIST

midas_touch_layer = lua_class('midas_touch_layer',layer.ui_layer)
local _json_file 	= 'gui/main/midas_touch_1.ExportJson'

function midas_touch_layer:_init( )

	super(midas_touch_layer,self)._init(_json_file,true)
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2,VisibleSize.height/2)

	self:set_handler('Button_close', self.close_button_event)
	self:set_handler('Button_use_once', self.use_once_event) --使用一次
	self:set_handler('Button_use_rep', self.use_rep_event) --连续使用


	self.player = model.get_player()
	self.list_view = self:get_widget('ListView_12')
	self.touch_times_label = self:get_widget('lbl_times_left')
	self:get_widget('Panel_40'):setVisible(false)
	self:get_widget('Panel_37'):setVisible(false)
	self:finish_init()
	self:init_msg()
end

function midas_touch_layer:init_msg( )
	local cnt = self.player:get_midas_touch()
	self.total_times = self.player:get_vip_midas_time()
	self.touch_times_label:setString(cnt .. '/' .. self.total_times)
	if cnt >= self.total_times then
		ui_mgr.create_ui(import('ui.midas_touch_layer.midas_touch_tip'), 'midas_touch_tip')
	else
		local diamond = data.midas_touch[cnt + 1].diamond
		self.gold = data.midas_touch[cnt + 1].gold
		local continue_touch_times = 3 + self.player:get_midas_con_cnt() * 2
		local diamond_cnt = 0
		local gold_cnt  = 0
		for i = 1, continue_touch_times do
			if cnt + i > self.total_times then break end
			diamond_cnt = diamond_cnt + data.midas_touch[cnt + i].diamond
			gold_cnt = gold_cnt + data.midas_touch[cnt + i].gold
		end
		
		self:get_widget('lbl_diamond_num_1'):setString(tostring(diamond))
		self:get_widget('lbl_diamond_num_2'):setString(tostring(diamond_cnt))
		self:get_widget('lbl_diamond_num_3'):setString(tostring(diamond))

		self:get_widget('lbl_gold_num_1'):setString(tostring(self.gold))
		self:get_widget('lbl_gold_num_2'):setString(tostring(gold_cnt))
		self:get_widget('lbl_use_repeat'):setString(locale.get_value_with_var('midas_touch_use_repeat', {times = continue_touch_times}))
	end
end

function midas_touch_layer:finish_init()
	for name, val in pairs(combat_conf.midas_touch_1_ui_label) do 	--读出role_ui_conf文件的table
		self['lbl_' .. name] = self:get_widget('lbl_' .. name) --名字加前缀，就可以读出相应的名字label控件
		--self['txt_' .. name] = self:get_widget('txt_' .. name)	--一样，这样就可以读出相应的数值的label控件
		local temp_name = self['lbl_' .. name]			--把读出来的控件存到self的一个table中
		if temp_name ~= nil then 						--名字不为空，就设置字体类似，和显示的内容
			temp_name:setFontName(ui_const.UiLableFontType)
			local label_value = locale.get_value('midas_touch_' .. name)
			if label_value ~= nil then
				temp_name:setString(label_value)	
			end	
			if val.edge ~= nil and val.edge > 0 then 					--edge的值大于0就描边
				temp_name:enableOutline(ui_const.UilableStroke, val.edge)  ---，描边，厚度 role_ui_conf.lua中role_ui_label的edge
			end
		end
	end
end

function midas_touch_layer:use_once_event( sender, eventType )
	if eventType == ccui.TouchEventType.began then
		
	elseif eventType == ccui.TouchEventType.moved then
	  
	elseif eventType == ccui.TouchEventType.ended then
		if self.player.midas_touch_cnt >= self.total_times then
			ui_mgr.create_ui(import('ui.midas_touch_layer.midas_touch_tip'), 'midas_touch_tip')
		else
			server.midas_touch()
		end
	elseif eventType == ccui.TouchEventType.canceled then
		
	end
end

function midas_touch_layer:use_rep_event( sender, eventType )
	if eventType == ccui.TouchEventType.began then
		
	elseif eventType == ccui.TouchEventType.moved then
	  
	elseif eventType == ccui.TouchEventType.ended then
		if self.player.midas_touch_cnt >= self.total_times then
			ui_mgr.create_ui(import('ui.midas_touch_layer.midas_touch_tip'), 'midas_touch_tip')
		else
			server.midas_touch_continue()
		end
	elseif eventType == ccui.TouchEventType.canceled then
		
	end
end

function midas_touch_layer:set_critical_mul( critical_mul )
	self.critical_mul = critical_mul
end

function midas_touch_layer:reload( )
	super(midas_touch_layer,self).reload()
	if self.critical_mul == nil then
		return
	end
	self:get_widget('Panel_37'):setVisible(true)
	local result_panel = self:get_widget('Panel_40'):clone()
	result_panel:ignoreAnchorPointForPosition(true)
	result_panel:setVisible(true)
	result_panel:setName('result_panel')
	local gold_num = self.gold * self.critical_mul
	result_panel:getChildByName('lbl_gold_num_3'):setString(tostring(gold_num))
	result_panel:getChildByName('lbl_critical_mul'):setString(locale.get_value_with_var('midas_touch_critical_mul', {multiple = self.critical_mul}))
	self.list_view:pushBackCustomItem(result_panel)
	self.critical_mul = nil
	self:init_msg()
end

--移除操作
function midas_touch_layer:release( ) 
	self.is_remove = false
	super(midas_touch_layer,self).release()
	-- body
end

--关闭按钮
function midas_touch_layer:close_button_event( sender,eventtype )

	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  
	elseif eventtype == ccui.TouchEventType.ended then
		self.cc:setVisible(false)
		anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_UP_ANIM,false)
		self.is_remove = true
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end
