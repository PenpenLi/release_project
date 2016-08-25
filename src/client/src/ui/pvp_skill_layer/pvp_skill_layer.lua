local layer					= import( 'world.layer' )
local model 				= import( 'model.interface' )
local director				= import( 'world.director' )
local skill_cell 			= import( 'ui.pvp_skill_layer.skill_cell' ) 
local skill_list_panel  	= import( 'ui.pvp_skill_layer.skill_list_panel' )
local skill_display_panel 	= import( 'ui.pvp_skill_layer.skill_display_panel' )
local locale				= import( 'utils.locale' )
local anim_trigger 			= import( 'ui.main_ui.anim_trigger')
local ui_const				= import( 'ui.ui_const' )

pvp_skill_layer = lua_class('pvp_skill_layer',layer.ui_layer)
local load_texture_type = TextureTypePLIST
local touch = true

function set_touch( is_touch )
	touch = is_touch
end

function get_touch(  )
	return touch
end


function pvp_skill_layer:_init(  )
	
	super(pvp_skill_layer,self)._init('gui/main/ui_skill.ExportJson',true)

	touch = true

	self.scene_id = 1
	self.widget:setPosition(VisibleSize.width/2-10, VisibleSize.height/2)
	self.skill_display_panel = skill_display_panel.skill_display_panel(self)
 	self.skill_list_panel = skill_list_panel.skill_list_panel(self)

 	--战斗按钮
	self.battle_button 	= self:get_widget('battle_button')
	self:set_handler("battle_button", self.battle_button_event)
	--self:get_widget('lbl_battle_button'):setFontName(ui_const.UiLableFontType)
	self:get_widget('lbl_battle_button'):setString('保存设置')--locale.get_value('skill_battle_button'))


	--self:get_widget('lbl_resistance'):setFontName(ui_const.UiLableFontType)
	self:get_widget('lbl_resistance'):setString(locale.get_value('skill_select_resistance'))
	self:set_handler("close_button", self.close_button_event)
	--检查是否移除技能选择界面
	self.is_remove = false
end

function pvp_skill_layer:get_skill_display_panel(  )
	return self.skill_display_panel
end

function pvp_skill_layer:set_scene_id( id )
	self.scene_id = id
end


function pvp_skill_layer:battle_button_event( sender, eventType )

	if touch == false or director.is_loading() then
		return
	end
	
	if eventType == ccui.TouchEventType.ended then
		-- server.begin_battle(self.scene_id)

		--同步pvp防守skills到服务端
		local avatar = model.get_player()
		local pvp_def_skills = avatar:get_pvp_def_skills()
		local send = {}
		for i,v in pairs(pvp_def_skills) do
			send[i] = v.id
		end
		send[1] = send[1] or -1
		send[2] = send[2] or -1
		send[3] = send[3] or -1
		
		-- dir(send_loaded)
		server._sync_pvp_def_skills(send)

		sender:setTouchEnabled(false)
		self.cc:setVisible(false)			
		self.is_remove = true
	end
end

function pvp_skill_layer:close_button_event( sender, eventtype )
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

function pvp_skill_layer:release(  )
	-- body
	print('remove ui_skill.plise')
	--cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( eicon_set )
	-- cc.SpriteFrameCache: getInstance(): removeSpriteFramesFromFile( 'gui/ui_skill/ui_skill0.plist' )
	-- cc.SpriteFrameCache: getInstance(): removeSpriteFramesFromFile( 'gui/ui_skill/ui_skill1.plist' )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( sicon_set )
	super(pvp_skill_layer,self).release()
	self.is_remove = false
end


