local layer				= import( 'world.layer' )
local ui_const			= import( 'ui.ui_const' )
local message_box		= import( 'ui.message_box')
local anim_trigger 		= import( 'ui.main_ui.anim_trigger' )
local model 				= import( 'model.interface' )
local ui_mgr			= import( 'ui.ui_mgr' )
local msg_queue = import( 'ui.msg_ui.msg_queue' )

info_panel = lua_class('info_panel', layer.ui_layer)

local head_icon_scale = 0.40
local qishi_icon_offset = {-67, 58}
local cike_icon_offset = {-67, 60}

function info_panel:_init( )	
	super(info_panel,self)._init('gui/main/chat_2.ExportJson', true)
	self.is_remove = false
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2,VisibleSize.height/2)

	self.head_icon = nil
	self.user_id	= nil
	self.nickname 	= nil
	self.chat_box	= nil
	self.close_btn  = self:get_widget('info_close')
	self.icon 		= self:get_widget('img_icon')
	self.lv 		= self:get_widget('label_lv')
	self.name		= self:get_widget('label_name')
	self.party		= self:get_widget('label_party')
	self.info_btn	= self:get_widget('btn_info')
	self.friend_btn = self:get_widget('btn_friend')
	self.chat_btn	= self:get_widget('btn_chat')
	self.btn_defriend = self:get_widget('btn_defriend')

	self:set_handler("info_close", self.close_button_event)
	self:set_handler("btn_chat", self.chat_button_event)
	self:set_handler("btn_info", self.info_button_event)
	self:set_handler("btn_defriend", self.defriend_button_event)
end

function info_panel:set_lv( lv )
	self.lv:setString(lv)
end

function info_panel:set_party( party )
	self.party:setString(party)
end

function info_panel:set_user_id(id)
	self.user_id = id
end

function info_panel:set_nickname(nickname)
	self.nickname = nickname
	self.name:setString(self.nickname)
end

function info_panel:get_user_id()
	return self.user_id
end

function info_panel:get_nickname()
	return self.nickname
end

function info_panel:set_role_type(role_type)
	self.role_type = role_type
end

function info_panel:set_avatar_info(info)
	self:set_role_type(info.role_type)
	self:set_user_id(info.id)
	-- self:set_party(info.party)
	self:set_lv(info.level)
	self:set_nickname(info.nick_name)
end

function info_panel:set_head_icon( head )
	self.head_icon = head
	self.head_icon:set_scale(head_icon_scale)
	if self.role_type == 'qishi' then
		self.head_icon:set_offset(qishi_icon_offset[1], qishi_icon_offset[2])
	elseif self.role_type == 'cike' then
		self.head_icon:set_offset(cike_icon_offset[1], cike_icon_offset[2])
	end
	self.icon:addChild(self.head_icon.cc)
end

function info_panel:chat_button_event(  sender, eventtype  )
	if eventtype == ccui.TouchEventType.began then
	elseif eventtype == ccui.TouchEventType.moved then
	elseif eventtype == ccui.TouchEventType.ended then
		local my_id = model.get_player():get_id()
		if my_id == self.user_id then 
			msg_queue.add_msg("不能对自己聊天")
			return 
		end
		
		local chat_box = ui_mgr.get_ui('chat_box_layer')
		if chat_box == nil then
			chat_box = ui_mgr.create_ui('ui.chat_box_layer.chat_box_layer', 'chat_box_layer')
		end
		chat_box:change_channel('private')
		chat_box:set_chat_target(self.user_id, self.nickname)
		chat_box.private_button:setSelectedState(true)
		self:play_down_anim()
	elseif eventtype == ccui.TouchEventType.canceled then
	end
end

function info_panel:info_button_event( sender, eventtype )
	if eventtype == ccui.TouchEventType.began then
		elseif eventtype == ccui.TouchEventType.moved then
		elseif eventtype == ccui.TouchEventType.ended then
			self:play_down_anim()
			server.get_player_info(self.user_id)
		elseif eventtype == ccui.TouchEventType.canceled then
	end
end

function info_panel:close_button_event(  sender, eventtype  )
	if eventtype == ccui.TouchEventType.began then
	elseif eventtype == ccui.TouchEventType.moved then
	elseif eventtype == ccui.TouchEventType.ended then
		self:play_down_anim()
		
	elseif eventtype == ccui.TouchEventType.canceled then
	end
end

function info_panel:defriend_button_event( sender, eventtype )
	if eventtype == ccui.TouchEventType.began then
	elseif eventtype == ccui.TouchEventType.moved then
	elseif eventtype == ccui.TouchEventType.ended then
		local player = model.get_player()
		local my_id = player:get_id()
		if my_id == self.user_id then 
			msg_queue.add_msg("不能屏蔽自己")
			return 
		end

		player:add_screen_player(self.user_id)
		local chat_box = ui_mgr.get_ui('chat_box_layer')
		if chat_box ~= nil then
			chat_box:reload()
		end
		msg_queue.add_msg("已屏蔽 "..self.nickname)
		self:play_down_anim()
		
	elseif eventtype == ccui.TouchEventType.canceled then
	end
end

function info_panel:play_up_anim(  )
	self:play_action('chat_2.ExportJson','up')
end

--播放收起动画
function info_panel:play_down_anim( )
	local function callFunc(  )
		self.is_remove = true
	end
	local callFuncObj=cc.CallFunc:create(callFunc)
	self:play_action('chat_2.ExportJson','down',callFuncObj)
end

function info_panel:release( )
	self.is_remove = true
	--ccs.ActionManagerEx:getInstance():releaseActionsByJsonName('chat_2.ExportJson')
	super(info_panel,self).release()
end
