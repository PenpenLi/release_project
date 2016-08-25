local layer 			= import('world.layer')
local director			= import( 'world.director' )
local ui_mgr 			= import( 'ui.ui_mgr' ) 
local combat_conf		= import( 'ui.sign_in_layer.signin_ui_cont' )
local anim_trigger 		= import( 'ui.main_ui.anim_trigger')
local locale			= import( 'utils.locale' )
local ui_const			= import( 'ui.ui_const' )
local model             = import( 'model.interface')
local navigation_bar	= import( 'ui.equip_sys_layer.navigation_bar' ) 
local signin_cell       = import('ui.sign_in_layer.signin_cell')
local msg_queue         = import('ui.msg_ui.msg_queue')


local load_texture_type = TextureTypePLIST

sign_in_layer = lua_class('sign_in_layer',layer.ui_layer)
local eicon_set 	= 'icon/e_icons.plist'
local dicon_set     = 'icon/renwu.plist'
local item_icon_set = 'icon/item_icons.plist'
local common_icon_set = 'icon/common.plist'
local soul_icon_set = 'icon/soul_icons.plist'
local _json_file 	= 'gui/main/sign.ExportJson'

function sign_in_layer:_init( )

	super(sign_in_layer,self)._init(_json_file,true)
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2,VisibleSize.height/2)
	
	self:set_handler('lbl_close_btn', self.close_button_event)
	self:set_handler('lbl_help_btn', self.show_help_event)


	self:get_widget('Panel_7'):setVisible(false)
	self:get_widget('Panel_15'):setVisible(false)
	self:get_widget('lbl_title'):setString('')

	self.sign_in_times = model.get_player().sign_in_times
	--控制显示剩下的任务条
	self.first_creat = true
	self.bar = self:get_widget('bar')
	self.bar:setVisible(false)
	self.barbg = self:get_widget('barbg')
	self.bar:setScale9Enabled(true)
	--任务列表
	self.item_list = self:get_widget('ScrollView_9')
	self.navigation_bar = navigation_bar.navigation_bar(self.bar,self.barbg, self.item_list)

	self.player = model.get_player()
	self.is_remove 		= false
	self.cur_date = os.date('*t', os.time() - 21600)
	self:finish_init()
	ui_mgr.schedule_once(0, self, self.init_reward_items)
end

function sign_in_layer:finish_init()
	for name, val in pairs(combat_conf.signin_ui_label) do 	--读出role_ui_conf文件的table
		self['lbl_' .. name] = self:get_widget('lbl_' .. name) --名字加前缀，就可以读出相应的名字label控件
		--self['txt_' .. name] = self:get_widget('txt_' .. name)	--一样，这样就可以读出相应的数值的label控件
		local temp_name = self['lbl_' .. name]			--把读出来的控件存到self的一个table中
		--local temp_val = self['txt_' .. name]
		if temp_name ~= nil then 						--名字不为空，就设置字体类似，和显示的内容
			temp_name:setFontName(ui_const.UiLableFontType)
			local label_value = locale.get_value('signin_' .. name)
			if label_value ~= nil then
				temp_name:setString(label_value)	
			end	
			if val.edge ~= nil and val.edge > 0 then 					--edge的值大于0就描边
				temp_name:enableOutline(ui_const.UilableStroke, val.edge)  ---，描边，厚度 role_ui_conf.lua中role_ui_label的edge
			end
		end
	end
	local title = 'm_' .. self.cur_date.month
	self['lbl_title']:setString(locale.get_value('signin_' .. title))
end

function cmp( a, b ) --比较函数，用于按日期排序,保证一月内显示的图标顺序相同
	if string.len(a) < string.len(b) then
		return true
	end
	local i = string.find(a, '-', 6)
	local day1 = tonumber(string.sub(a, i + 1))
	local j = string.find(b, '-', 6)
	local day2 = tonumber(string.sub(b, j + 1))
	return day1 < day2
end

function sign_in_layer:init_reward_items( )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( eicon_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( dicon_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( item_icon_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( common_icon_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( soul_icon_set )
	self.item_list:removeAllChildren()
	self.item_list:jumpToTop()
	--local cur_date = os.date('*t', os.time() - 21600)
	local pattern = self.cur_date.year .. '-' .. self.cur_date.month .. '-' --模式匹配
	local keys = {}
	for k, _ in pairs(data.sign_in) do -- 排序
		if string.find(k, pattern) ~= nil then
			table.insert(keys, k)
		end
	end
	table.sort(keys, cmp)
	self:get_widget('lbl_addup_times'):setString(tostring(self.sign_in_times))
	local t = 1
	local col = 0
	local line_space = 5
	local height = self:get_widget('Button_17'):getContentSize().height
	local init_x = 69
	local scroll_h = 7 * (height + line_space) 
	local init_y   = scroll_h - height / 2
	for _, v in ipairs(keys) do --v是日期
		local item_id  = data.sign_in[v]['reward'][1]
		local item_num = data.sign_in[v]['reward'][2]
		local vip_lv   = data.sign_in[v]['vip_lv_needed']

		local list_cell = signin_cell.signin_cell(self)
		list_cell.list_cell:setTag(t)
		self:set_signin_handler(list_cell)

		list_cell:set_num(item_num)
		if vip_lv ~= 0 then  -- 0 表示非vip
			list_cell:set_vip(vip_lv)
		end
		--设置图片
		list_cell:set_img(item_id)
		if t <= self.sign_in_times then --已领取
			list_cell:set_checked()
			list_cell:set_panel_gray() --变灰
		elseif t == self.sign_in_times + 1 and not self.player:is_today_signed() then --今天未领取
			self.can_sign = true
			list_cell:play_tx()
			--self.item_num = item_num
			self.reward_cell = list_cell
		end
		t = t + 1
		self.item_list:addChild(list_cell.list_cell)
		
		list_cell.list_cell:setPosition(init_x + 140 * col, init_y)
		col = col + 1
		if col == 5 then --开始新行
			col = 0
			init_y = init_y - (height + line_space)
		end
		
	end

	self.item_list:setInnerContainerSize(cc.size(715, scroll_h))
	self.navigation_bar:init_bar(4, 7, self.item_list:getContentSize().height)
	self.bar:setVisible(true)
end

function sign_in_layer:set_signin_handler( cell )
	local function button_event(sender, eventType)
		
		if eventType == ccui.TouchEventType.ended then
			if  cell.list_cell:getTag() == self.sign_in_times + 1 and self.can_sign then
				server.sign_in() --签到 
			else --显示物品信息
				local item_id = cell:get_item_id()
				if item_id ~= nil then
					local temp_ui = ui_mgr.create_ui(import('ui.tips_layer.item_tips_layer'),'item_tips_layer')
					temp_ui:set_content(item_id)
					temp_ui:set_center_position(VisibleSize.width/2,VisibleSize.height/2)
					temp_ui:play_up_anim()
				end
			end
		end
	end
	cell:get_btn():addTouchEventListener(button_event)
end


function sign_in_layer:reload( )
	super(sign_in_layer,self).reload()
	self.reward_cell:set_unlighted()
	self.reward_cell:set_checked()
	self.reward_cell:set_panel_gray() --变灰
	self:get_widget('lbl_addup_times'):setString(tostring(self.sign_in_times + 1)) --标题天数 + 1
	self.can_sign = false
end

--移除操作
function sign_in_layer:release( ) --记得移除图标的plist文件
	self.is_remove = false
	--ccs.ActionManagerEx:getInstance():releaseActionsByJsonName('sign_1.ExportJson')
	super(sign_in_layer,self).release()

	cc.SpriteFrameCache: getInstance(): removeSpriteFramesFromFile( eicon_set )
	cc.SpriteFrameCache: getInstance(): removeSpriteFramesFromFile( dicon_set )
	cc.SpriteFrameCache: getInstance(): removeSpriteFramesFromFile( item_icon_set )
	cc.SpriteFrameCache: getInstance(): removeSpriteFramesFromFile( common_icon_set )
	cc.SpriteFrameCache: getInstance(): removeSpriteFramesFromFile( soul_icon_set )
	-- body
end

function sign_in_layer:show_help_event(sender,eventtype )
	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  
	elseif eventtype == ccui.TouchEventType.ended then
		local help_msg1 = locale.get_value('signin_help1')
		--help_msg1 = string.gsub(help_msg1, ',', ',\n')
		local help_msg = help_msg1 .. '\n\n' .. locale.get_value('signin_help2')
		self.help_layer = ui_mgr.create_ui(import('ui.msg_ui.msg_ok_layer'), 'msg_ok_layer')
		--self.help_layer = ui_mgr.create_ui(import('ui.msg_ui.msg_ok_cancel_layer'), 'msg_ok_cancel_layer')
		self.help_layer:set_tip(help_msg)
	elseif eventtype == ccui.TouchEventType.canceled then
		
	end
end

--关闭按钮
function sign_in_layer:close_button_event( sender,eventtype )

	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  
	elseif eventtype == ccui.TouchEventType.ended then
		self.cc:setVisible(false)

		anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_UP_ANIM,false)
		self.is_remove = true
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end

function sign_in_layer:touch_move_event( touch, event )

end

function sign_in_layer:touch_end_event( touch, event )

end
