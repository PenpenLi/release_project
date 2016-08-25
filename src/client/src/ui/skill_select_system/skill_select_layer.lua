local msg_queue         	= import(  'ui.msg_ui.msg_queue')
local layer					= import( 'world.layer' )
local model 				= import( 'model.interface' )
local director				= import( 'world.director' )
local skill_cell 			= import( 'ui.skill_select_system.skill_cell' ) 
local skill_list_panel  	= import( 'ui.skill_select_system.skill_list_panel' )
local skill_display_panel 	= import( 'ui.skill_select_system.skill_display_panel' )
local locale				= import( 'utils.locale' )
local anim_trigger 			= import( 'ui.main_ui.anim_trigger')
local ui_const				= import( 'ui.ui_const' )

skill_select_layer = lua_class('skill_select_layer',layer.ui_layer)
local load_texture_type = TextureTypePLIST
local touch = true

function set_touch( is_touch )
	touch = is_touch
end

function get_touch(  )
	return touch
end


function skill_select_layer:_init(  )
	
	super(skill_select_layer,self)._init('gui/main/ui_skill.ExportJson',true)

	touch = true

	self.scene_id = 1
	self.widget:setPosition(VisibleSize.width/2-10, VisibleSize.height/2)
	self.skill_display_panel = skill_display_panel.skill_display_panel(self)
 	self.skill_list_panel = skill_list_panel.skill_list_panel(self)

 	--战斗按钮
	self.battle_button 	= self:get_widget('battle_button')
	self:set_handler("battle_button", self.battle_button_event)
	--self:get_widget('lbl_battle_button'):setFontName(ui_const.UiLableFontType)
	self:get_widget('lbl_battle_button'):setString(locale.get_value('skill_battle_button'))


	--self:get_widget('lbl_resistance'):setFontName(ui_const.UiLableFontType)
	self:get_widget('lbl_resistance'):setString(locale.get_value('skill_select_resistance'))
	self:set_handler("close_button", self.close_button_event)
	--检查是否移除技能选择界面
	self.is_remove = false


end

function skill_select_layer:get_skill_display_panel(  )
	return self.skill_display_panel
end

function skill_select_layer:get_list_panel(  )
	return self.skill_list_panel
end

function skill_select_layer:set_scene_id( id )
	self.scene_id = id
end


function skill_select_layer:battle_button_event( sender, eventType )

	if touch == false or director.is_loading() then
		return
	end
	
	if eventType == ccui.TouchEventType.ended then
		-- touch = false
		-- self.battle_button:setTouchEnabled(false)
		--cc.SpriteFrameCache: getInstance(): removeSpriteFramesFromFile( 'gui/ui_black_bg/ui_black_bg0.plist' )
		-- self:release( )
		
		--同步loaded_skills到服务端
		local avatar = model.get_player()
		local loaded_skills = avatar:get_loaded_skills()
		local send_loaded = {}
		for i,v in pairs(loaded_skills) do
			send_loaded[i] = v.id
		end
		send_loaded[1] = send_loaded[1] or -1
		send_loaded[2] = send_loaded[2] or -1
		send_loaded[3] = send_loaded[3] or -1

		server._sync_loaded_skills(send_loaded)

		--判断是否竞技场battle
		if self.scene_id == 9527 then
			local ticket = avatar:get_pvp_ticket()
			local count = ticket.count
			if count <= 0 then
				msg_queue.add_msg('券用完')
				return
			end
			server.pvp_battle_begin(self.scene_id)
			return
		end

		server.begin_battle(self.scene_id)
		director.show_loading()
		-- director.enter_battle_scene(self.scene_id)
	end
	
end


function skill_select_layer:close_button_event( sender, eventtype )
	if touch == false then
		return
	end
	if eventtype == 0 then
			print('press close')
		end
		if eventtype == ccui.TouchEventType.began then
		
		elseif eventtype == ccui.TouchEventType.moved then
	  
		elseif eventtype == ccui.TouchEventType.ended then
				sender:setTouchEnabled(false)
				--ui_mgr.create_ui(import('ui.map.map_layer'), 'map_layer')
				self.cc:setVisible(false)
				--anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_UP_ANIM,false)
				
				self.is_remove = true
				 
		elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end

function skill_select_layer:release(  )
	-- body
	print('remove ui_skill.plise')
	--cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( eicon_set )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( sicon_set )
	-- cc.SpriteFrameCache: getInstance(): removeSpriteFramesFromFile( 'gui/ui_skill/ui_skill0.plist' )
	-- cc.SpriteFrameCache: getInstance(): removeSpriteFramesFromFile( 'gui/ui_skill/ui_skill1.plist' )

	super(skill_select_layer,self).release()
	self.is_remove = false
end