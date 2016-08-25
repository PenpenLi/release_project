
local entity				= import( 'world.entity' )
local char					= import( 'world.char' )
local model 				= import( 'model.interface' )
local music_mgr				= import( 'world.music_mgr' )
local combat_conf			= import( 'ui.equip_sys_layer.equip_ui_cont' )
local layer					= import( 'world.layer' )
local locale				= import( 'utils.locale' )
local anim_trigger 			= import( 'ui.main_ui.anim_trigger')
local ui_const 				= import( 'ui.ui_const' )
local locale				= import( 'utils.locale' )
local ui_mgr				= import( 'ui.ui_mgr' )

local equipment_list_panel 	= import( 'ui.equip_sys_layer.equipment_list_panel' )
local player_info_panel 	= import( 'ui.equip_sys_layer.player_info_panel' )


equip_sys_layer = lua_class('equip_sys_layer',layer.ui_layer)

local eicon_set = 'icon/e_icons.plist'
local _json_path = 'gui/main/ui_role.ExportJson'


function equip_sys_layer:_init(  )
	--cc.SpriteFrameCache: getInstance(): addSpriteFrames( eicon_set )
	super(equip_sys_layer,self)._init( _json_path,true )

	--locale.set_locale( 'cn' )								--翻译语言 cn 中文，en 英语
	self.model = model.get_player()
	self.model:unbound_entity() 
	self:finish_init()

	self:set_handler("equip_close_button", self.close_button_event)
	--是否移除
	self.is_remove = false
end


function equip_sys_layer:finish_init(  )

	self.widget:setPosition(VisibleSize.width/2-5, VisibleSize.height/2)

	self.model:init_combat_attr()

	local player_attr = self.model.final_attrs

	for name, val in pairs(combat_conf.role_combat_attr) do 	--读出role_ui_conf文件的table
		self['lbl_' .. name] = self:get_widget('lbl_' .. name) --名字加前缀，就可以读出相应的名字label控件
		self['txt_' .. name] = self:get_widget('txt_' .. name)	--一样，这样就可以读出相应的数值的label控件
		local temp_name = self['lbl_' .. name]			--把读出来的控件存到self的一个table中
		local temp_val = self['txt_' .. name]
		if temp_name ~= nil then 						--名字不为空，就设置字体类似，和显示的内容
			--temp_name:setFontName(ui_const.UiLableFontType)
			temp_name:setString(locale.get_value('role_' .. name)) --读取data中language 中名字对应的table,在init设置的语言类型对应的名称
			temp_name:enableOutline(ui_const.UilableStroke, 1)
		end
		if temp_val ~= nil then
			--temp_val:setFontName('fonts/msyh.ttf')
			if player_attr[name] ~= nil then
				temp_val:setString(player_attr[name]) --把玩家的战斗属性值设置到这个Val label中
			else
				temp_val:setString('0')
			end
			temp_val:enableOutline(ui_const.UilableStroke, 1)
		end
	end


	for name, val in pairs(combat_conf.role_ui_label) do
		self['lbl_' .. name] = self:get_widget('lbl_' .. name)
		local temp_label = self['lbl_' .. name]
		if temp_label ~= nil then
			--temp_label:setFontName(ui_const.UiLableFontType)
			temp_label:setString(locale.get_value('role_' .. name))		--如果传入的name在languane是没有的，就会返回以个空字符串
			if val.edge ~= nil and val.edge > 0 then 					--edge的值大于0就描边
				temp_label:enableOutline(ui_const.UilableStroke, val.edge)  ---，描边，厚度 role_ui_conf.lua中role_ui_label的edge
			end
		end
	end
	self.equipment_list_panel = equipment_list_panel.equipment_list_panel(self)
	self.player_info_panel		= player_info_panel.player_info_panel(self)
	ui_mgr.schedule_once(0, self, self._finish_init)
end

function equip_sys_layer:_finish_init()
	self.equipment_list_panel:update_equip_list()
end

function equip_sys_layer:close_button_event( sender, eventtype )
	if eventtype == 0 then
			print('press close')
			--music_mgr.ui_click()
		end
		if eventtype == ccui.TouchEventType.began then
		
		elseif eventtype == ccui.TouchEventType.moved then
	  
		elseif eventtype == ccui.TouchEventType.ended then
				self.cc:setVisible(false)
				self.is_remove = true
				anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_UP_ANIM,false)

		elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end

function equip_sys_layer:update_equip_layer( )
	self.equipment_list_panel:update_equip_list( )
	
end

function equip_sys_layer:get_player_info_panel( )
	return self.player_info_panel
end

function equip_sys_layer:get_equipment_list_panel( )
	return self.equipment_list_panel
end

function equip_sys_layer:get_model( )
	return self.model
end

function equip_sys_layer:get_lbl_with_name( name )
	return self[name]
end

function equip_sys_layer:get_txt_with_name( name )
	return self[name]
end


function equip_sys_layer:release( )
	print('remove equip_sys_layer')
	
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( eicon_set )
	-- cc.SpriteFrameCache: getInstance(): removeSpriteFramesFromFile( 'gui/ui_role/ui_role0.plist' )
	-- cc.SpriteFrameCache: getInstance(): removeSpriteFramesFromFile( 'gui/ui_role/ui_role1.plist' )
	self.player_info_panel:release()
	super(equip_sys_layer,self).release()
	self.is_remove = false
end

-- function equip_sys_layer:set_activation_info(  )
-- 	self.equipment_list_panel:set_activation_info()
-- end

function equip_sys_layer:reload(  )
	super(equip_sys_layer,self).reload()
	self.player_info_panel:play_first_anim()
	self.player_info_panel:update_panel()
	self.equipment_list_panel:update_equip_list( )
	self.equipment_list_panel:reload_ui()
end
