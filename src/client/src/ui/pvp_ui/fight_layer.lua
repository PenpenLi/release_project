local layer					= import( 'world.layer' )
local anim_trigger 			= import( 'ui.main_ui.anim_trigger')
local ui_const				= import( 'ui.ui_const' )
local ui_mgr 				= import( 'ui.ui_mgr' )
local director				= import( 'world.director')
local avatar_info_layer		= import( 'ui.avatar_info_layer.avatar_info_layer' )
local model 				= import( 'model.interface' )
local msg_queue         	= import(  'ui.msg_ui.msg_queue')
fight_layer = lua_class('fight_layer',layer.ui_layer)
local load_texture_type = TextureTypePLIST
local sicon_set = 'icon/s_icons.plist'

function fight_layer:_init(  )
	super(fight_layer,self)._init('gui/main/pvp_2.ExportJson',true)

	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2,VisibleSize.height/2)
	self.panel = self.widget:getChildByName('Panel_1')
	self:set_handler("close_button", self.close_button_event)
	self:set_handler("fight", self.fight_button_event)
	self:set_handler("skill", self.skill_button_event)

	self.player = model.get_player()
end

function fight_layer:fight_button_event( sender, event_type )
	if event_type == ccui.TouchEventType.ended then

		local ticket = self.player:get_pvp_ticket()
		local count = ticket.count
		if count <= 0 then
			msg_queue.add_msg('券用完')
			return
		end

		director.show_loading()
		server.pvp_battle_begin(9527)
	end
end

function fight_layer:skill_button_event( sender, event_type )
	ui_mgr.create_ui(import('ui.skill_select_system.skill_select_layer'), 'skill_select_layer')
	ui_mgr.get_ui('skill_select_layer'):set_scene_id(9527)

	-- close
	sender:setTouchEnabled(false)
	self.cc:setVisible(false)
	self.is_remove = true
	anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_UP_ANIM,false)
end

function fight_layer:set_player_data( player1, player2 )
	ui_mgr.schedule_once(0, self, self._set_player_data, player1, player2)
end

function fight_layer:_set_player_data(player1, player2)
	cc.SpriteFrameCache:getInstance():addSpriteFrames( sicon_set )

	self.panel:getChildByName('my_name'):setString(player1.nick_name)
	self.panel:getChildByName('my_fc'):setString(math.floor(player1.fc))

	for i,v in pairs( player1:get_loaded_skills() ) do
		local my_skill_image = self.panel:getChildByName('my_skill_' .. i)
		my_skill_image:loadTexture(v.data.icon,load_texture_type)
		my_skill_image:setVisible(true)
	end

	local shadow_widget = self.panel:getChildByName('my_Image')
	local p_anim = avatar_info_layer.create_char_model(player1, 'idle')
	shadow_widget:addChild(p_anim.cc)
	shadow_widget:setLocalZOrder(11111)
	shadow_widget:setAnchorPoint(cc.p(0.5, 0.5))							--设置阴影的锚点
	p_anim.cc:setAnchorPoint(cc.p(0.5, 0))									--设置玩家的锚点在脚下。底边中点
	local shadow_size = shadow_widget:getLayoutSize()						--获取阴影的大小
	p_anim.cc:setPosition(shadow_size.width/2-10,shadow_size.height*2/3)	--设置玩家位置

	self.panel:getChildByName('his_name'):setString(player2.nick_name)
	self.panel:getChildByName('his_fc'):setString(math.floor(player2.fc))

	for i,v in pairs( player2:get_pvp_def_skills() ) do
		local his_skill_image = self.panel:getChildByName('his_skill_' .. i)
		his_skill_image:loadTexture(v.data.icon,load_texture_type)
		his_skill_image:setVisible(true)
	end

	local shadow_widget2 = self.panel:getChildByName('his_Image')
	local p2_anim = avatar_info_layer.create_char_model(player2, 'idle')
	p2_anim.cc:setScaleX(-1)
	shadow_widget2:addChild(p2_anim.cc)
	shadow_widget2:setLocalZOrder(11111)
	shadow_widget2:setAnchorPoint(cc.p(0.5, 0.5))							--设置阴影的锚点
	p2_anim.cc:setAnchorPoint(cc.p(0.5, 0))									--设置玩家的锚点在脚下。底边中点
	local shadow_size2 = shadow_widget2:getLayoutSize()						--获取阴影的大小
	p2_anim.cc:setPosition(shadow_size.width/2-10,shadow_size.height*2/3)	--设置玩家位置
end

function fight_layer:close_button_event( sender, event_type )
	if event_type == ccui.TouchEventType.ended then
		sender:setTouchEnabled(false)
		self.cc:setVisible(false)
		self.is_remove = true
		anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_UP_ANIM,false)
	end
end

function fight_layer:release(  )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( sicon_set )
	super(fight_layer,self).release()
end
