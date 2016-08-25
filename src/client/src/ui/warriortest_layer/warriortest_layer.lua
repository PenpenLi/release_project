local layer					= import( 'world.layer' )
local anim_trigger 			= import( 'ui.main_ui.anim_trigger')
local ui_const				= import( 'ui.ui_const' )
local ui_mgr 				= import( 'ui.ui_mgr' )
local combat_conf			= import( 'ui.warriortest_layer.warriortest_ui_cont' )
local ui_const				= import( 'ui.ui_const' )
local locale				= import( 'utils.locale' )

warriortest_layer = lua_class('warriortest_layer',layer.ui_layer)

function warriortest_layer:_init(  )
	super(warriortest_layer,self)._init('gui/main/ui_warriortest.ExportJson',true)

	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2,VisibleSize.height/2)

	self:init_lbl_font()
	self:set_handler("close_button", self.close_button_event)

	self.btn_1 = self:get_widget('btn_1')
	self.btn_2 = self:get_widget('btn_2')
	self.btn_3 = self:get_widget('btn_3')
	self.btn_4 = self:get_widget('btn_4')

	self.btn_1:addTouchEventListener(
		function (sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				self:enter_battle(9001)
			end
		end
	)
	self.btn_2:addTouchEventListener(
		function (sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				-- self:enter_battle(9002)
			end
		end
	)
	self.btn_3:addTouchEventListener(
		function (sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				-- self:enter_battle(9003)
			end
		end
	)
	self.btn_4:addTouchEventListener(
		function (sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				-- self:enter_battle(9004)
			end
		end
	)
end

function warriortest_layer:enter_battle( battle_id )
	ui_mgr.create_ui(import('ui.skill_select_system.skill_select_layer'), 'skill_select_layer')
	ui_mgr.get_ui('skill_select_layer'):set_scene_id(battle_id)
end

function warriortest_layer:close_button_event( sender, event_type )
	if event_type == ccui.TouchEventType.ended then
		sender:setTouchEnabled(false)
		self.cc:setVisible(false)
		self.is_remove = true
		anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_UP_ANIM,false)
	end
end

function warriortest_layer:release(  )
	super(warriortest_layer,self).release()
end

function warriortest_layer:init_lbl_font(  )
	print('init_lbl_font')
	for name, val in pairs(combat_conf.warriortest_ui_label) do
		print('name, val', name, val)
		self['lbl_' .. name] = self:get_widget('lbl_' .. name)
		local temp_label = self['lbl_' .. name]
		if temp_label ~= nil then
			if val.edge ~= nil and val.edge > 0 then 						--edge的值大于0就描边
				temp_label:enableOutline(ui_const.UilableStroke, val.edge)  --描边，厚度 role_ui_conf.lua中role_ui_label的edge
			end
			temp_label:setString(locale.get_value('warriortest_' .. name))
		end
	end
end