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
local locale			= import( 'utils.locale' )
local msg_queue 		= import( 'ui.msg_ui.msg_queue' )
local music_mgr			= import( 'world.music_mgr' )

sys_setup_layer = lua_class('sys_setup_layer',layer.ui_layer)

local _json = 'gui/main/setup_3.ExportJson'

function sys_setup_layer:_init()
	super(sys_setup_layer,self)._init(_json, true)
	self.is_remove = false
	self:set_handler('btn_close', self.close_button_event)

	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2, VisibleSize.height/2)
	self.bg_music_box = self:get_widget('btn_bg_music')
	self.bg_music_box:addEventListener(bg_music_event)
	self.game_music_box = self:get_widget('btn_music')
	self.game_music_box:addEventListener(music_effect_event)

	self:get_widget('lbl_push_setup'):setVisible(false)
	self:get_widget('lbl_energy_warn'):setVisible(false)
	self:get_widget('lbl_shop_refresh'):setVisible(false)
	self:get_widget('lbl_other_visible'):setVisible(false)
	self.other_visible_box = self:get_widget('btn_other_visible')
	self.other_visible_box:setVisible(false)
	self.energy_remind_box = self:get_widget('btn_energy_warn')
	self.energy_remind_box:setVisible(false)
	self.refresh_shop_box  = self:get_widget('btn_shop_refresh')
	self.refresh_shop_box:setVisible(false)
	self:init_settings()
	self:init_lbl_font()
end

function bg_music_event( sender, eventType )
	if eventType == ccui.CheckBoxEventType.selected then
        if music_mgr._is_bg_enable == false then
        	music_mgr.alter_bg_music_enable()
        	if music_mgr._is_normal_bg_playing == false then
        		music_mgr.preload_normal_bg_music()
        		music_mgr.play_normal_bg_music()
        	end
        end
    else
    	if music_mgr._is_bg_enable then
    		music_mgr.alter_bg_music_enable()
    	end
    end 
end

function music_effect_event( sender, eventType )
	if eventType == ccui.CheckBoxEventType.selected then
        if music_mgr._is_ef_enable == false then
        	music_mgr.alter_ef_sound_enable()
        end
    else
    	if music_mgr._is_ef_enable then
    		music_mgr.alter_ef_sound_enable()
    	end
    end 
end

--对文字的描边, 多语言
function sys_setup_layer:init_lbl_font(  )
	for name, val in pairs(combat_conf.sys_setup_ui_label) do
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

function sys_setup_layer:init_settings() 
	local bg_music_on = cc.UserDefault:getInstance():getBoolForKey('bg_music_on', true)
	if bg_music_on then
		self.bg_music_box:setSelectedState(true)
	end
	local game_music_on = cc.UserDefault:getInstance():getBoolForKey('game_music_on', true)
	if game_music_on then
		self.game_music_box:setSelectedState(true)
	end
	local show_other_player = cc.UserDefault:getInstance():getBoolForKey('show_other_player', true)
	if show_other_player then
		self.other_visible_box:setSelectedState(true)
	end
	local energy_remind = cc.UserDefault:getInstance():getBoolForKey('energy_remind', true)
	if energy_remind then
		self.energy_remind_box:setSelectedState(true)
	end
	local refresh_shop = cc.UserDefault:getInstance():getBoolForKey('shop_refresh', true)
	if refresh_shop then
		self.refresh_shop_box:setSelectedState(true)
	end
end

function sys_setup_layer:save_conf( )
	cc.UserDefault:getInstance():setBoolForKey("bg_music_on", self.bg_music_box:getSelectedState())
	cc.UserDefault:getInstance():setBoolForKey("game_music_on", self.game_music_box:getSelectedState())
	cc.UserDefault:getInstance():setBoolForKey("show_other_player", self.other_visible_box:getSelectedState())
	cc.UserDefault:getInstance():setBoolForKey("energy_remind", self.energy_remind_box:getSelectedState())
	cc.UserDefault:getInstance():setBoolForKey("shop_refresh", self.refresh_shop_box:getSelectedState())
end

function sys_setup_layer:close_button_event(  sender, eventtype  )
	if eventtype == ccui.TouchEventType.began then
	elseif eventtype == ccui.TouchEventType.moved then
	elseif eventtype == ccui.TouchEventType.ended then
		self:save_conf()
		self.cc:setVisible(false)
		self.is_remove = true
	elseif eventtype == ccui.TouchEventType.canceled then
	end
end
