local director			= import( 'world.director' )
local char				= import( 'world.char' )
local ui_const			= import( 'ui.ui_const' )
local model 			= import( 'model.interface' )
local entity			= import( 'world.entity' )
local layer				= import( 'world.layer' )
local ui_mgr 			= import(  'ui.ui_mgr' )
local net_model 		= import( 'network.interface' )
local anim_trigger 		= import( 'ui.main_ui.anim_trigger' )
local chat_list			= import( 'ui.chat_box_layer.chat_list' )
local rich_text_layout  = import( 'ui.chat_box_layer.rich_text' )
local message_box		= import( 'ui.message_box')
local model 			= import( 'model.interface' )
local utf_untils		= import( 'utils.utf8')
local head_icon				= import( 'ui.head_icon.head_icon' )
local locale				= import( 'utils.locale' )
local combat_conf		= import('ui.chat_box_layer.chat_box_layer_conf')
local trie_tree = import('utils.trie_tree')

chat_box_layer = lua_class('chat_box_layer', layer.ui_layer)

recent_message = nil
has_new_msg = false
default_tar = {}

local max_length = 200
local default_hight = 70
local single_line_len = 65
local single_line_hight = 27
local cell_width = 780
local cell_high = 60
local text_off_set = {-425, -85}
local private_x, private_y

local all_msg_list = chat_list.chat_list()
local private_list = chat_list.chat_list()
local lianmeng_list = chat_list.chat_list()
local channelSwitch =   --获取聊天频道
{
    ['all'] 		= all_msg_list,
    ['private'] 	= private_list,
    ['lianmeng']	= lianmeng_list,
}

function chat_box_layer:_init(  )	
	super(chat_box_layer,self)._init('gui/main/chat_1.ExportJson', true)
	self.is_remove = false
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width / 2, VisibleSize.height / 2)

	self.pre_channel = 'all'     --记录当前所在的聊天频道

	self.tag = 0
	self.cur_pos = 0
	self.view_item = {}

	self.player = model.get_player()
	private_x, private_y = self:get_widget('ScrollView_30'):getPosition()
	self.all_label		= self:get_widget('label_all')
	self.private_label	= self:get_widget('label_private')
	self.send_button 	= self:get_widget('button_send')
	self.level_label 	= self:get_widget('label_level')
	self.time_label 	= self:get_widget('label_time')
	self.title_label	= self:get_widget('label_title')
	self.content_label 	= self:get_widget('label_content')
	self.chating_list 	= self:get_widget('list_chat')
	self.chat_cell 		= self:get_widget('button_chatcell')
	self.allmsg_button 	= self:get_widget('button_all')
	self.lianmeng_button= self:get_widget('button_lianmeng')
	self.private_button = self:get_widget('button_private')
	self.button_close 	= self:get_widget('button_close')
	self.target_label	= self:get_widget('lbl_target')
	self.img_new_msg	= self:get_widget('img_new_msg')
	self.allmsg_button:setSelectedState(true)
	self.allmsg_button:setTouchEnabled(false) 
	self:set_handler("button_send", self.send_button_event)
	self:set_handler("button_close", self.close_button_event)
	self:set_handler("button_all", self.allmsg_button_event)
	self:set_handler("button_lianmeng", self.lianmeng_button_event)
	self:set_handler("button_private", self.private_button_event)

	self.chating_list:ignoreAnchorPointForPosition(true)

	self.target_label:enableOutline(ui_const.UilableStroke, 5) --描边

	self.target_id = nil --私聊对象信息
	self.target_name 	 = nil

	self:init_lbl_font()

	self.img_new_msg:setVisible(has_new_msg)

	self:debug()   --debug!!!!!!!!!

	self:change_channel('all', false) --设置频道为 综合

	self:init_data()
	--ui_mgr.schedule_once(0, self, self.init_data)
end

function chat_box_layer:init_data()
	local inner_content = self.chating_list:getInnerContainer() 
	local init_num = 4
	local function tick()
		local x, y = inner_content:getPosition()
		if self.chating_list:getChildrenCount() >= init_num and y > -100 then
			self.cur_pos = self.cur_pos + 1
			local item_data = self.view_item[self.cur_pos]
			if item_data == nil then
				return
			end
			self:_create_msg_cell(item_data)
		elseif self.chating_list:getChildrenCount() <= 1 then
			for i = 1, init_num do
				self.cur_pos = self.cur_pos + 1
				local item_data = self.view_item[self.cur_pos]
				if item_data == nil then
					break
				end
				self:_create_msg_cell(item_data)
			end
			self.chating_list:jumpToTop()
		end
		--print(y)
	end
	self.tick = cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick, 0, false)
end

local function get_len(str)

	return string.len(str)
	-- local len = 0
 --    local currentIndex = 1
 --    while currentIndex <= #str do
 --        local char = string.byte(str, currentIndex)
 --        local siz = utf_untils.chsize(char)
 --        currentIndex = currentIndex + siz
 --        if siz > 1 then 
 --        	len = len + 2
 --        else
 --        	len = len + 1
 --        end
 --    end
 --    return len
end

function chat_box_layer:change_channel(channel, is_reload)
	self.tag = 0
	self.cur_pos = 0
	self.view_item = {}

	if channel == 'all' then
		self.input_text = self:get_widget('text_all_input')
		self.all_label:setVisible(true)
		self.private_label:setVisible(false)
		self.allmsg_button:setTouchEnabled(false)
		self.lianmeng_button:setTouchEnabled(true)
		self.private_button:setTouchEnabled(true)
		self.lianmeng_button:setSelectedState(false)
		self.private_button:setSelectedState(false)
		self.pre_channel = 'all'
		self:update_list('all', is_reload)
		if is_reload ~= false then
			ui_mgr.schedule_once(0, self, self.update_list, 'all', is_reload)
		end
	elseif channel == 'private' then
		self.input_text = self:get_widget('text_private_input') 
		self.private_label:setVisible(true)
		self.all_label:setVisible(false)
		self.allmsg_button:setTouchEnabled(true)
		self.lianmeng_button:setTouchEnabled(true)
		self.private_button:setTouchEnabled(false)
		self.allmsg_button:setSelectedState(false)
		self.lianmeng_button:setSelectedState(false)
		has_new_msg = false
		self.img_new_msg:setVisible(has_new_msg)
		if default_tar.nickname ~= nil and default_tar.user_id ~= nil then
			self:set_chat_target(default_tar.user_id, default_tar.nickname)
		end
		self:adapt_private_input_pos()
		self.pre_channel = 'private'
		if is_reload ~= false then
			ui_mgr.schedule_once(0, self, self.update_list, 'private', is_reload)
		end
	elseif channel == 'lianmeng' then
		self.all_label:setVisible(true)
		self.private_label:setVisible(false)
		self.allmsg_button:setTouchEnabled(true)
		self.private_button:setTouchEnabled(true)
		self.lianmeng_button:setTouchEnabled(false)
		self.allmsg_button:setSelectedState(false)
		self.private_button:setSelectedState(false)
		self.pre_channel = 'lianmeng'
		if is_reload ~= false then
			ui_mgr.schedule_once(0, self, self.update_list, 'lianmeng', is_reload)
		end
	end
end

--对文字的描边, 多语言
function chat_box_layer:init_lbl_font(  )
	for name, val in pairs(combat_conf.chat_box_layer_label) do
		self['lbl_' .. name] = self:get_widget('lbl_' .. name)
		local temp_label = self['lbl_' .. name]
		if temp_label ~= nil then
			if val.edge ~= nil and val.edge > 0 then 					--edge的值大于0就描边
				temp_label:enableOutline(ui_const.UilableStroke, val.edge)  ---，描边，厚度 role_ui_conf.lua中role_ui_label的edge
			end
			temp_label:setString(locale.get_value('chat_' .. name))
		end
	end
end

--设置私聊对象
function chat_box_layer:set_chat_target(user_id, nickname)
	if user_id == nil or nickname == nil then
		return
	end
	self.target_id = user_id
	self.target_name = nickname
	self.target_label:setString(locale.get_value_with_var('chat_set_target', {target=nickname}))
	self:adapt_private_input_pos()
	
end

--创建聊天信息
function chat_box_layer:create_msg_cell(msg_data)
	if self._item_height == nil then
		self._item_height = self.chat_cell:getContentSize().height
	end

	self.tag = self.tag + 1
	self.view_item[self.tag] = msg_data

end

function chat_box_layer:_create_msg_cell(msg_data)
	if msg_data['msg'] == nil or msg_data['lv'] == nil or msg_data['hour'] == nil or msg_data['min'] == nil or msg_data['title'] == nil then
		return 
	end
	--print(msg_data['msg'])
	self.content_label:setString(" ")
	self.level_label:setString(msg_data['lv'])
	self.time_label:setString(string.format("%02d:%02d",msg_data['hour'],msg_data['min']))
	if msg_data.channel == 'all' then 
		self.title_label:setString(locale.get_value_with_var(msg_data.title.msg, msg_data.title.var))
	elseif msg_data.channel == 'lianmeng' then 
		self.title_label:setString(locale.get_value_with_var(msg_data.title.msg, msg_data.title.var))
	elseif msg_data.channel == 'private' then
		if msg_data.title ~= nil then
			self.title_label:setString(locale.get_value_with_var(msg_data.title.msg, msg_data.title.var))
		end
	end 

	local rich = rich_text_layout.rich_text_layout(msg_data, cell_width, cell_high)
	local cell =  self.chat_cell:clone()
	local text_hight = math.ceil(rich:get_len() / single_line_len) * single_line_hight
	cell:setContentSize(cell:getContentSize().width, default_hight + text_hight)
	local pal_cell = cell:getChildByName('pal_cell')
	local icon = pal_cell:getChildByName('image_head')--self:get_widget('image_head')
	local head = head_icon.head_icon(msg_data.role_type, msg_data.helmet_id)
	head:set_scale(0.40)
	if msg_data.role_type == 'qishi' then 
		head:set_offset(-67, 58)
	elseif msg_data.role_type == 'cike' then
		head:set_offset(-67, 60)
	end
	icon:addChild(head.cc)

	self:set_icon_handel(icon, msg_data)
	pal_cell:setPosition( cc.p( cell:getContentSize().width, cell:getContentSize().height)) 
	local pal_cell_x, pal_cell_y = pal_cell:getPosition()
	rich.rich_text:setPosition( pal_cell_x + text_off_set[1], pal_cell_y + text_off_set[2] )
	cell:addChild(rich.rich_text)
	--layout:setContentSize(cell:getContentSize().width, cell:getContentSize().height)
	--layout:addChild(cell)
	cell:setPosition(cell:getContentSize().width/2, cell:getContentSize().height/2)
	self.chating_list:pushBackCustomItem(cell)
	--self.chating_list:jumpToTop()
end

--设置头像触发事件
function chat_box_layer:set_icon_handel( icon, msg_data )

	local function button_event( sender,eventtype )
		if eventtype == ccui.TouchEventType.began then
			
		elseif eventtype == ccui.TouchEventType.moved then
		  
		elseif eventtype == ccui.TouchEventType.ended then
			local player_info = ui_mgr.create_ui(import('ui.avatar_info_layer.info_panel'), 'info_panel', false, false)
			player_info:set_user_id(msg_data._id)
			player_info:set_nickname(msg_data.nick_name)
			player_info:set_head_icon(head_icon.head_icon(msg_data.role_type, msg_data.helmet_id))
			player_info:set_role_type(msg_data.role_type)

			player_info:play_up_anim()
			player_info:set_lv(msg_data.lv)
			player_info:set_party('没有公会')  --test!!!!!!
		elseif eventtype == ccui.TouchEventType.canceled then
				
		end
	end
	icon:addTouchEventListener(button_event)
end


--更新聊天内容UI
function chat_box_layer:update_list(channel, is_reload) 

	self:reload_json()
	if self.pre_channel ~= channel and self.pre_channel ~= 'all' and channel ~= 'system' then
		return 
	end
	local tmp_list = nil
	if channel == 'system' then 
		channel = self.pre_channel
	end
	tmp_list = channelSwitch[self.pre_channel]
	if tmp_list == nil then 
		return 
	end

	local screen_player = model.get_player():get_screen_player()
	self.chating_list:removeAllItems()
	self.tag = 0
	self.cur_pos = 0
	self.view_item = {}
	local j = tmp_list.pos
	for i = 1, 1000 do
		if tmp_list.msg[j] ~=nil and screen_player[tmp_list.msg[j]._id] ~= true then
			self:create_msg_cell(tmp_list.msg[j])
		end
		j = (j+1)%tmp_list.maxi_num
		if j == tmp_list.pos then
			break
		end
	end
end

--获取聊天频道
function chat_box_layer:get_pre_type()
	if self.allmsg_button:getSelectedState() == true then
		return'all'
	elseif self.lianmeng_button:getSelectedState() == true then
		return 'lianmeng'
	else
		return 'private'
	end
end

function chat_box_layer:send_button_event( sender, eventtype )
	if eventtype == ccui.TouchEventType.began then
	elseif eventtype == ccui.TouchEventType.moved then
	elseif eventtype == ccui.TouchEventType.ended then
		local channel = self:get_pre_type()
		local text = self.input_text:getStringValue()
		--空串
		if text == "" or text:find("[^%s]") == nil then
			local msg_queue = import( 'ui.msg_ui.msg_queue' )
			msg_queue.add_msg(locale.get_value('chat_input_msg'))
			return
		end
		--超长
		if get_len(text) > max_length then
			local msg_queue = import( 'ui.msg_ui.msg_queue' )
			msg_queue.add_msg(locale.get_value('msg_over_length'))
			return 
		end
		--词库屏蔽
		if trie_tree.illegal_words:gfind(text) then
			print('illegal')
			return
		end
		if channel == 'all' then
			server.say({
				msg = text, 
				channel = channel, 
				role_type = self.player:get_role_type(),
				helmet_id = self.player.wear.helmet,
				})
			self.input_text:setText("")
		elseif channel == 'private' then
			if self.target_id == nil or self.target_name == nil then
				local msg_queue = import( 'ui.msg_ui.msg_queue' )
				msg_queue.add_msg(locale.get_value('chat_without_target'))
				return
			end
			server.say({
				msg = text, 
				channel = channel, 
				role_type = self.player:get_role_type(), 
				target_id = self.target_id, 
				target_nickname = self.target_name,
				helmet_id = self.player.wear.helmet,
				})--text, channel, self.target_username, self.target_name)
			self.input_text:setText("")
		end
		self.input_text:didNotSelectSelf()
	elseif eventtype == ccui.TouchEventType.canceled then
	end
end

function chat_box_layer:close_button_event(  sender, eventtype  )
	if eventtype == ccui.TouchEventType.began then
	elseif eventtype == ccui.TouchEventType.moved then
	elseif eventtype == ccui.TouchEventType.ended then
		self.input_text:didNotSelectSelf()
		anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_UP_ANIM,false)
		self.cc:setVisible(false)
		self.is_remove = true		
	elseif eventtype == ccui.TouchEventType.canceled then
	end
end


function chat_box_layer:allmsg_button_event( sender, eventtype )
	if eventtype == ccui.TouchEventType.began then
	elseif eventtype == ccui.TouchEventType.moved then
	elseif eventtype == ccui.TouchEventType.ended then
		self.input_text:didNotSelectSelf()
		self:change_channel('all')
		
	elseif eventtype == ccui.TouchEventType.canceled then
	end
end

function chat_box_layer:lianmeng_button_event( sender, eventtype )
	if eventtype == ccui.TouchEventType.began then
	
	elseif eventtype == ccui.TouchEventType.moved then
  
	elseif eventtype == ccui.TouchEventType.ended then
		self.input_text:didNotSelectSelf()
		self:change_channel('lianmeng')
		
	elseif eventtype == ccui.TouchEventType.canceled then
	
	end
end

function chat_box_layer:private_button_event( sender, eventtype )
	if eventtype == ccui.TouchEventType.began then
	elseif eventtype == ccui.TouchEventType.moved then
	elseif eventtype == ccui.TouchEventType.ended then
		self.input_text:didNotSelectSelf()
		self:change_channel('private')

	elseif eventtype == ccui.TouchEventType.canceled then
	end
end

function chat_box_layer:adapt_private_input_pos()
	local input_view = self:get_widget('ScrollView_30') 
	input_view:setPosition(private_x + self.target_label:getContentSize().width + 8, private_y)
end

function chat_box_layer:get_cur_channel()
	return self.pre_channel
end

function chat_box_layer:reload()
	super(chat_box_layer,self).reload()
	self:update_list(self.pre_channel)
end

function chat_box_layer:release()
	super(chat_box_layer,self).release()
	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.tick)
end

--聊天记录
function load_history(h_pos, h_max_num, history)
	if h_pos == nil or h_max_num == nil or history == nil then 
		return
	end
	--把旧数据顶掉
	all_msg_list:clear()
	local j = h_pos
	for i=1, 500 do
		if history[tonumber(j)] ~= nil then
			add_to_list(history[j])
		end
		j = j%h_max_num+1
		if j == h_pos then
			break
		end
	end
end

function add_to_list(msg_data)
	if msg_data['msg'] == '' then
		return
	end
	
	local channel = msg_data['channel']
	local tmp_list = nil
	if channel == 'system' then 
		channel = 'all'
	end
	tmp_list = channelSwitch[channel]
	if tmp_list == nil then 
		return
	end
	tmp_list:add_msg(msg_data)
	-- if channel ~= 'all' then 
	-- 	tmp_list = channelSwitch['all']
	-- 	tmp_list:add_msg(msg_data)
	-- end
	if channel == 'private' then
		if msg_data.title.msg and msg_data.title.msg == 'chat_first_title' then
			set_default_tar({nickname = msg_data.nick_name, user_id = msg_data._id})
		end
		has_new_msg = true
		local chat_box = ui_mgr.get_ui('chat_box_layer')
		if chat_box and chat_box.pre_channel ~= 'private' then
			chat_box.img_new_msg:setVisible(has_new_msg)
		end
	end

end

function set_default_tar(tar)
	if tar.nickname and tar.user_id then
		default_tar = tar
	end
end

function set_recent_msg(msg)
	recent_message = msg
end

function get_recent_msg()
	return recent_message
end
------------------------------------------debug----------------------------------
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

function chat_box_layer:send_debug_info(  sender, eventtype  )
	if eventtype == ccui.TouchEventType.began then
	elseif eventtype == ccui.TouchEventType.moved then
	elseif eventtype == ccui.TouchEventType.ended then
		local cmd = self.input_text:getStringValue()
		local cmd_str, args = get_gm_cmd(cmd,' ')
		if cmd_str ~= nil then
			server.gm_cmd(cmd_str, args)
		end
	elseif eventtype == ccui.TouchEventType.canceled then
	end
end

function chat_box_layer:debug()
	self:set_handler("Image_4", self.send_debug_info)
end
-----------------------------------------------------------------------------