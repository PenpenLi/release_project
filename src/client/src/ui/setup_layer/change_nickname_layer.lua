local model				= import('model.interface')
local anim_trigger 		= import( 'ui.main_ui.anim_trigger')
local layer				= import( 'world.layer' )
local ui_const			= import( 'ui.ui_const' )
local combat_conf		= import('ui.setup_layer.setup_ui_conf')
local utf8_utils		= import('utils.utf8')
local avatar_info		= import('ui.avatar_info_layer.avatar_info_layer')
local chose_characters_tx = import('ui.chose_characters_layer.chose_characters_tx')
local char				= import( 'world.char' )
local role_model		= import('ui.chose_characters_layer.role_model')
local locale				= import( 'utils.locale' )
local msg_queue = import( 'ui.msg_ui.msg_queue' )
local ui_mgr			= import( 'ui.ui_mgr' )

change_nickname_layer = lua_class('change_nickname_layer',layer.ui_layer)

local _json = 'gui/main/setup_2.ExportJson'

function change_nickname_layer:_init()
	super(change_nickname_layer,self)._init(_json, true)
	self.is_remove = false
	math.randomseed(os.time())  
	self:set_handler('btn_close', self.close_button_event)
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2, VisibleSize.height/2)

	self:set_handler('btn_rand', self.rand_button_event)
	self:set_handler('btn_ok', self.ok_button_event)
	self.txt_nick_name = self:get_widget('txt_nickname')
	self.txt_nick_name:setText(model.get_player():get_nick_name())
	self:init_lbl_font()
end

-- 对文字的描边, 多语言
function change_nickname_layer:init_lbl_font(  )
	for name, val in pairs(combat_conf.change_name_ui_label) do
		self['lbl_' .. name] = self:get_widget('lbl_' .. name)
		local temp_label = self['lbl_' .. name]
		if temp_label ~= nil then
			if val.edge ~= nil and val.edge > 0 then 					--edge的值大于0就描边
				temp_label:enableOutline(ui_const.UilableStroke, val.edge)  ---，描边，厚度 role_ui_conf.lua中role_ui_label的edge
			end
			temp_label:setString(locale.get_value('setup_' .. name))
		end
	end
end

function change_nickname_layer:close_button_event(  sender, eventtype  )
	if eventtype == ccui.TouchEventType.began then
	elseif eventtype == ccui.TouchEventType.moved then
	elseif eventtype == ccui.TouchEventType.ended then
		self:close_ui()
	elseif eventtype == ccui.TouchEventType.canceled then
	end
end


function change_nickname_layer:close_ui()
	self.cc:setVisible(false)
	self.is_remove = true
end

--随机名字按钮
function change_nickname_layer:rand_button_event( sender, eventtype )
	
	if eventtype == ccui.TouchEventType.began then
	
	elseif eventtype == ccui.TouchEventType.moved then

	elseif eventtype == ccui.TouchEventType.ended then
		local d = data.namelist

		local first_index = math.random(#d[1].name)
		local second_index = math.random(#d[2].name)
		local nick_name = d[1].name[first_index] .. "·" ..d[2].name[second_index]
		self.txt_nick_name:setText(nick_name)
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end

end

function change_nickname_layer:ok_button_event( sender, eventtype )
	
	if eventtype == ccui.TouchEventType.began then
	
	elseif eventtype == ccui.TouchEventType.moved then

	elseif eventtype == ccui.TouchEventType.ended then
			local nick_name_size = 14
			local director = import('world.director')
			local nick_name = self.txt_nick_name:getStringValue()--self.txt_nick_name:getStringValue()
			if utf8_utils.utf8size(nick_name) > nick_name_size then
				msg_queue.add_msg(locale.get_value('msg_chose_over_length'))
				return 
			end
			if nick_name == '' then 
				msg_queue.add_msg(locale.get_value('msg_chose_nil'))
				return 
			end

			if nick_name:find("%s+") then
				msg_queue.add_msg(locale.get_value('msg_chose_illegal'))
				return 
			end
			local msg_box = ui_mgr.create_ui(import('ui.msg_ui.msg_ok_cancel_layer'), 'msg_ok_cancel_layer')
			msg_box:set_func_tip(locale.get_value_with_var('setup_payfor_change_name', {diamond = 100}), function()
				server.change_nick_name(nick_name)
			end)
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end