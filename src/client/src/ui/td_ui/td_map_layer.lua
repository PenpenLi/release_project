local layer					= import( 'world.layer' )
local anim_trigger 			= import( 'ui.main_ui.anim_trigger')
local main_map				= import( 'ui.main_map' )
local ui_const				= import( 'ui.ui_const' )
local model 				= import( 'model.interface' )
local ui_mgr 				= import( 'ui.ui_mgr' )
local shaders				= import( 'utils.shaders' )
local math_ext				= import( 'utils.math_ext')
local locale				= import( 'utils.locale' )
local director			= import( 'world.director')

td_map_layer = lua_class('td_map_layer',layer.ui_layer)

local _td_n 	= 10
local _td_begin	= 7000

function td_map_layer:_init(  )
	super(td_map_layer,self)._init('gui/main/td_map.ExportJson',true)

	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2,VisibleSize.height/2)

	self:set_handler("close_button", self.close_button_event)

	self.panel = self.widget:getChildByName('Panel')
	self.btn_panel = self.panel:getChildByName('ScrollView_4'):getChildByName('Image_2')

	-- 规则说明按钮
	self.rule = self.panel:getChildByName('rule')
	self.rule:addTouchEventListener(
			function ( sender, event_type )
				if event_type == ccui.TouchEventType.ended then
					local rule_ui = ui_mgr.create_ui(import('ui.td_ui.td_rule'), 'td_rule')
					local rule1 = locale.get_value('td_rule_1')
					rule1 =  string.gsub(rule1, '\\n', "\n")
					local rule2 = locale.get_value('td_rule_2')
					rule2 =  string.gsub(rule2, '\\n', "\n")
					rule_ui:add_rule(rule1, 22, Color.Rice_Yellow)
					rule_ui:add_rule(rule2, 22, Color.Dark_Yellow)
				end
			end
		)
	self.exchange = self.panel:getChildByName('exchange')
	self.exchange:addTouchEventListener(
			function ( sender, event_type )
				if event_type == ccui.TouchEventType.ended then
					local exchange	= ui_mgr.create_ui(import('ui.dhshop_layer.dhshop_layer'), 'dhshop_layer')
					exchange:set_proxy_type(2)
					exchange:reload()

				end
			end
		)

	self.btn = {}				-- 关卡按钮
	self.chests = {}			-- 宝箱按钮
	self.chests_bg = {}			-- 宝箱背光
	self:set_btn_event()

	-- 获取副本star信息
	local avatar = model.get_player()
	self.td_fuben = avatar:get_td_fuben()
	self.td_chests = avatar:get_td_chests()
	--print('-------------------', self.td_fuben)
	--dir(self.td_chests)

	-- 设置当前可打的关卡
	self.permit_id = self:set_permit_btn()
	self:set_chests_status()
end

function td_map_layer:set_chests_status(  )
	for i=1, _td_n do
		if self.td_chests[i] == -1 then --不可领
			self.chests[i]:setTouchEnabled(false)
			self.chests_bg[i]:setVisible(false)
		elseif self.td_chests[i] == 0 then --已领
			self.chests[i]:setBright(false)
			self.chests_bg[i]:setVisible(false)
		elseif self.td_chests[i] == 1 then --待领
			self.chests_bg[i]:setVisible(true)
		end
	end
	-- self:play_action('td_map.ExportJson','ani_3')
end

function td_map_layer:set_Gray( i )
	local sprite = self.btn[i]
	sprite:setTouchEnabled(false)
	shaders.SpriteSetGray(sprite:getVirtualRenderer(), 0.3)
end

function td_map_layer:set_light( i, open )
	local sprite = self.btn[i]
	sprite:setTouchEnabled(true)
	shaders.SpriteSetGray(sprite:getVirtualRenderer(), 1)

	-- if open then
	-- 	local sprite2 = self.chests[i]
	-- 	sprite2:setBright(false)
	-- end
end

function td_map_layer:set_permit_btn(  )

	local flag = nil
	for i=1, _td_n do
		local battle_id = _td_begin -1 + i
		if self.td_fuben >= battle_id then
			self:set_light(i, true)
		else
			if flag == nil then
				flag = 1
				self:set_light(i)
			else
				self:set_Gray(i)
			end
		end
	end
end

function td_map_layer:reload()
	super(td_map_layer,self).reload()

	local avatar = model.get_player()
	self.td_fuben = avatar:get_td_fuben()
	self.td_chests = avatar:get_td_chests()

	self:set_permit_btn()
	self:set_chests_status()
end

function td_map_layer:set_btn_event(  )

	local function btn_event( sender, event_type )
		if event_type == ccui.TouchEventType.ended then
			local split = string_split(sender:getName(), '_')
			if split[1] == 'b' then 	-- 点了关卡
				local battle_id = _td_begin - 1 + split[2]
				local td_detail = ui_mgr.create_ui(import('ui.td_ui.td_detail'), 'td_detail')
				td_detail:set_battle_id(battle_id)
				td_detail:add_entity_img()
				if battle_id <= self.td_fuben then
					td_detail:set_complete()
				end
			elseif split[1] == 'c' then -- 点了宝箱
				local c_id = tonumber(split[2])
				print('-c_id-', c_id, self.td_chests[c_id])
				if self.td_chests[c_id] ~= 1 then
					return
				end

				server.get_td_award(c_id)
				director.show_loading()
			end
		end
	end

	for i=1, _td_n do
		self.btn[i] = self.btn_panel:getChildByName('b_'..i)
		self.btn[i]:addTouchEventListener(btn_event)

		self.chests[i] = self.btn_panel:getChildByName('c_'..i)
		self.chests[i]:addTouchEventListener(btn_event)

		self.chests_bg[i] = self.btn_panel:getChildByName('cl_'..i)
	end
end

function td_map_layer:close_button_event( sender, event_type )

	if event_type == ccui.TouchEventType.ended then
		sender:setTouchEnabled(false)
		self.cc:setVisible(false)
		self.is_remove = true
		anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_UP_ANIM,false)	
	end
end

function td_map_layer:release(  )
	
	super(td_map_layer,self).release()
end
