local layer					= import( 'world.layer' )
local anim_trigger 			= import( 'ui.main_ui.anim_trigger')
local ui_const				= import( 'ui.ui_const' )
local ui_mgr 				= import( 'ui.ui_mgr' )
td_detail = lua_class('td_detail',layer.ui_layer)
local sicon_set = 'icon/s_icons.plist'
local json_path = 'gui/main/td_map_3.ExportJson'
local load_texture_type = TextureTypePLIST

function td_detail:_init(  )
	super(td_detail,self)._init(json_path,true)

	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2,VisibleSize.height/2)

	self.battle_id = 1000

	self.panel = self.widget:getChildByName('Panel_1')
	self.boss_panel = self.panel:getChildByName('boss_panel')
	-- self.boss_panel:ignoreAnchorPointForPosition(true)
	self.monster_panel = self.panel:getChildByName('monster_panel')
	-- self.monster_panel:ignoreAnchorPointForPosition(true)
	self.enemy_list = self.panel:getChildByName('Panel_29'):getChildByName('enemy_list')
	self.panel:getChildByName('Panel_29'):ignoreAnchorPointForPosition(true)
	self.enemy_list:ignoreAnchorPointForPosition(true)

	self:set_handler("close_button", self.close_button_event)
	self.continue = self.panel:getChildByName('continue')
	self.continue:addTouchEventListener(
		function ( sender, event_type )
			if event_type == ccui.TouchEventType.ended then
				ui_mgr.create_ui(import('ui.skill_select_system.skill_select_layer'), 'skill_select_layer')
				ui_mgr.get_ui('skill_select_layer'):set_scene_id(self.battle_id)
			end
		end
		)
end

function td_detail:set_battle_id( battle_id )
	self.battle_id = battle_id or 1000
end

function td_detail:set_complete(  )
	local label = self.continue:getChildByName('Label_5')
	label:setString('已完成')
	self.continue:setTouchEnabled(false)
end

--设置怪物按钮事件
function td_detail:set_entity_btn_handler( btn ,v )
	local function evenType(sender, eventype)
		local temp_ui
		if eventype == ccui.TouchEventType.began then
			if ui_mgr.get_ui('soul_tips_layer') == nil then
				temp_ui = ui_mgr.create_ui(import('ui.tips_layer.soul_tips_layer'),'soul_tips_layer')
				temp_ui:set_content(v,self.battle_id)
				local posx = btn:getWorldPosition().x-btn:getContentSize().width/2
				local posy = btn:getWorldPosition().y
				temp_ui:set_center_position(VisibleSize.width/2, VisibleSize.height/2)
			end
		elseif eventype == ccui.TouchEventType.moved then
		  
		elseif eventype == ccui.TouchEventType.ended then
			temp_ui = ui_mgr.get_ui('soul_tips_layer')
			if temp_ui ~= nil then
				temp_ui:set_remove()
			end
		elseif eventype == ccui.TouchEventType.canceled then
			temp_ui = ui_mgr.get_ui('soul_tips_layer')
			if temp_ui ~= nil then
				temp_ui:set_remove()
			end
		end

	end 
	btn:addTouchEventListener(evenType)
end

function td_detail:add_entity_img()
	cc.SpriteFrameCache:getInstance():addSpriteFrames( sicon_set )
	ccs.GUIReader:getInstance():widgetFromJsonFile(json_path)
	local d = data.fuben[self.battle_id]
	if d.monster_icon.monster ~= nil then
		for k,v in pairs(d.monster_icon.monster) do
			local b = self.monster_panel:clone()
			b:ignoreAnchorPointForPosition(true)
			b:setName('m_p')
			local img_btn = b:getChildByName('monster_button')
			local icon = data.monster_model[v].icon
			img_btn:loadTextureNormal(icon,load_texture_type)
			img_btn:loadTexturePressed(icon,load_texture_type)
			--设置属性
			img_btn:getChildByName(data.monster_model[v].element_type ..'_img'):setVisible(true)
			self.enemy_list:addChild(b)
			--设置点击事件，按出介绍框
			self:set_entity_btn_handler(img_btn,v)
		end
	end
	if d.monster_icon.boss ~= nil then
		for k,v in pairs(d.monster_icon.boss) do
			local b = self.boss_panel:clone()
			b:ignoreAnchorPointForPosition(true)
			b:setName('b_p')
			local img_btn = b:getChildByName('boss_button')
			local icon = data.monster_model[v].icon
			img_btn:loadTextureNormal(icon,load_texture_type)
			img_btn:loadTexturePressed(icon,load_texture_type)
			self.enemy_list:addChild(b)
			--设置属性
			img_btn:getChildByName(data.monster_model[v].element_type ..'_img'):setVisible(true)
			--设置点击事件，按出介绍框
			self:set_entity_btn_handler(img_btn,v)
		end
	end
end

function td_detail:close_button_event( sender, event_type )
	if event_type == ccui.TouchEventType.ended then
		sender:setTouchEnabled(false)
		self.cc:setVisible(false)
		self.is_remove = true
		anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_UP_ANIM,false)
	end
end

function td_detail:release(  )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( sicon_set )
	super(td_detail,self).release()
end
