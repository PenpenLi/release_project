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
local sys_setup_layer	= import( 'ui.setup_layer.sys_setup_layer' )
local change_nickname_layer = import( 'ui.setup_layer.change_nickname_layer' )
local ui_mgr			= import( 'ui.ui_mgr' )
local head_icon			= import( 'ui.head_icon.head_icon' )
local director          = import( 'world.director')

setup_layer = lua_class('setup_layer',layer.ui_layer)

local _json = 'gui/main/setup_1.ExportJson'

function setup_layer:_init()
	super(setup_layer,self)._init(_json, true)
	self.is_remove = false
	self:set_handler('btn_close', self.close_button_event)
	self:set_handler('btn_chang_nickname', self.change_button_event)
	self:set_handler('btn_setup', self.setup_button_event)
	self:set_handler('btn_logout', self.logout_button_event)
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2, VisibleSize.height/2)
	
	self:init_lbl_font()
	self:set_info()
end

--对文字的描边, 多语言
function setup_layer:init_lbl_font(  )
	for name, val in pairs(combat_conf.setup_ui_label) do
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

function setup_layer:set_info()
	self:set_head_icon()
	local player = model.get_player()
	self.lbl_lv = self:get_widget('lbl_lv')
	self.lbl_exp = self:get_widget('lbl_exp')
	self.lbl_party = self:get_widget('lbl_party')
	self.lbl_nickname = self:get_widget('lbl_nickname')
	self.lbl_lv:setString(player:get_level())
	self.lbl_exp:setString(player:get_exp())
	self.lbl_nickname:setString(player:get_nick_name())
end

function setup_layer:set_head_icon()
	self.head_icon = head_icon.head_icon(model.get_player().role_type, model.get_player().wear.helmet)
	self:get_widget('img_head'):addChild(self.head_icon.cc)
end

function setup_layer:close_button_event(  sender, eventtype  )
	if eventtype == ccui.TouchEventType.began then
	elseif eventtype == ccui.TouchEventType.moved then
	elseif eventtype == ccui.TouchEventType.ended then
		anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_UP_ANIM,false)
		self.cc:setVisible(false)
		self.is_remove = true
	elseif eventtype == ccui.TouchEventType.canceled then
	end
end

function setup_layer:logout_button_event( sender, eventtype )
	if eventtype == ccui.TouchEventType.began then
	elseif eventtype == ccui.TouchEventType.moved then
	elseif eventtype == ccui.TouchEventType.ended then
		self:realease()
		disconnect_server()
		director.init()
	elseif eventtype == ccui.TouchEventType.canceled then
	end
end


function setup_layer:setup_button_event(  sender, eventtype  )
	if eventtype == ccui.TouchEventType.began then
	elseif eventtype == ccui.TouchEventType.moved then
	elseif eventtype == ccui.TouchEventType.ended then
		ui_mgr.create_ui(sys_setup_layer, 'sys_setup_layer')
	elseif eventtype == ccui.TouchEventType.canceled then
	end
end 

function setup_layer:change_button_event(  sender, eventtype  )
	if eventtype == ccui.TouchEventType.began then
	elseif eventtype == ccui.TouchEventType.moved then
	elseif eventtype == ccui.TouchEventType.ended then
		ui_mgr.create_ui(change_nickname_layer, 'change_nickname_layer')
	elseif eventtype == ccui.TouchEventType.canceled then
	end
end 

function setup_layer:reload()
	super(setup_layer,self).reload()
	self:set_info()
end

function setup_layer:realease( )
	self.is_remove = false
	super(setup_layer,self).release()
end