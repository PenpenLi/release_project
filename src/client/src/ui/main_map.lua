local layer					= import( 'world.layer' )
-- local director				= import( 'world.director' )
local char					= import( 'world.char' )
local model 				= import( 'model.interface' )
local ui_mgr 				= import( 'ui.ui_mgr' )
local anim_trigger 			= import( 'ui.main_ui.anim_trigger')
local ui_const				= import( 'ui.ui_const' )
local avatar_info_layer		= import( 'ui.avatar_info_layer.avatar_info_layer' )
local ui_guide				= import( 'world.ui_guide' )

main_map = lua_class('main_map', layer.ui_layer)
local load_texture_type = TextureTypePLIST

-- 按钮触摸事件
local _button_touch_x
local _button_moved = false
local _button_ui_mapping = {
	h_1 = {'ui.mailbox_layer.mailbox_layer', 'mailbox_layer'},
	h_2 = {'ui.shop_layer.shop_layer', 'shop_layer'},
	h_3 = {'ui.strengthen_layer.strengthen_layer', 'strengthen_layer'},
	h_4 = {'ui.lottery_layer.lottery_layer', 'lottery_layer'},
	h_5 = {'ui.pvp_ui.pvp_layer', 'pvp_layer'},
	h_9 = {'ui.td_ui.td_map_layer', 'td_map_layer'},
	h_6 = {'ui.boss_layer.boss_layer', 'boss_layer'},
	h_10 = {'ui.warriortest_layer.warriortest_layer', 'warriortest_layer'},
}

function main_map:_init()
	super(main_map, self)._init()
	ui_guide.init_guide()
	self:init_main()
	self:set_is_gray(false)
	self.is_remove = false
end

function main_map:release()
	ui_guide.release_guide_layer()
	self.is_remove = true
	super(main_map, self).release()
end 

local _touch = {}

function main_map:fix_offset_bound()
	if self.x_offset < 0 then
		self.x_offset = 0
	end
	if self.x_offset > 1364 then
		self.x_offset = 1364
	end
end

function main_map:init_players()
	local players = model.get_players()
	math.randomseed(os.time())
	for oid, player in pairs(players) do
		local player = model.get_player()
		local entity_anim = avatar_info_layer.create_char_model(player, 'idle')
		entity_anim.cc:setPosition(math.random(2400),80-math.random(20))	--设置玩家位置
		self.layer1:addChild(entity_anim.cc)
	end
end

function main_map:init_main()
	local home_json = 'gui/main/city2500x640.ExportJson'
	self.main = ccs.GUIReader:getInstance():widgetFromJsonFile(home_json)
	self.widget = self.main
	self:record_plist_from_json(home_json)
	self.cc:addChild(self.main)
	self.layer0 = self:get_widget('0')
	self.layer1 = self:get_widget('01')
	self.layer2 = self:get_widget('02')
	self.layer3 = self:get_widget('03')
	self.layer4 = self:get_widget('04')
	self.layer5 = self:get_widget('05')
	self.x_offset = 940
	self.inertia = 0
	self.hold = false

	--self:init_players()

	local function on_touch_begin(touches, event)
		for _, touch in ipairs(touches) do
			local id = touch:getId()
			local pos = touch:getLocation()
			_touch[id] = pos
		end
		self.hold = true
	end

	local function on_touch_move(touches, event)
		if ui_guide.is_guiding() == true then
			return true
		end
		for _, touch in ipairs(touches) do
			local id = touch:getId()
			local pos = touch:getLocation()
			if _touch[id] == nil then
				_touch[id] = pos
				self.hold = true
			end
			self.inertia = _touch[id].x - pos.x
			self.x_offset = self.x_offset + _touch[id].x - pos.x
			_touch[id] = pos
			self:fix_offset_bound()
		end
	end

	local function on_touch_end(touches, event)
		for _, touch in ipairs(touches) do
			local id = touch:getId()
			local pos = touch:getLocation()
			_touch[id] = nil
			for i = 1, 10 do 
				local tmp_widget = self:get_widget('h_'..tostring(i))
				if tmp_widget ~= nil then
					tmp_widget:setTouchEnabled(true)
				end
			end
		end
		self.hold = false
	end

	local listener = cc.EventListenerTouchAllAtOnce:create()
	listener:registerScriptHandler(on_touch_begin,cc.Handler.EVENT_TOUCHES_BEGAN )
	listener:registerScriptHandler(on_touch_move,cc.Handler.EVENT_TOUCHES_MOVED )
	listener:registerScriptHandler(on_touch_end,cc.Handler.EVENT_TOUCHES_ENDED )
	self.cc:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.layer1)
	for i = 1, 10 do 
		local btn = self:get_widget('h_'..tostring(i))

		local function button_event( sender, eventype )
			if eventype == ccui.TouchEventType.began then
				_button_touch_x = sender:getTouchBeganPosition().x
				self.hold = true
			elseif eventype == ccui.TouchEventType.moved then
				local mov_x = sender:getTouchMovePosition().x
				if _button_touch_x == nil then
					_button_touch_x = mov_x
					self.hold = true
				end
				if math.abs(mov_x - sender:getTouchBeganPosition().x) > 10 then
					_button_moved = true
				end
				self.inertia = _button_touch_x - mov_x
				self.x_offset = self.x_offset + self.inertia
				_button_touch_x = mov_x
				self:fix_offset_bound()
			elseif eventype == ccui.TouchEventType.ended then
				local to_ui = _button_ui_mapping[sender:getName()]
				if _button_moved ~= true and to_ui then
					anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_DOWN_ANIM,false)
					ui_mgr.create_ui(import(to_ui[1]), to_ui[2])
					--ui_mgr.reload()
				end
				_button_moved = false
				self.hold = false
			elseif eventype == ccui.TouchEventType.canceled then
			end
		end
		self:set_widget_handler(btn, button_event, i)
	end

end

--哪个x点在屏幕中心
function main_map:set_middle_x( mid_x_pos )
	self.x_offset = mid_x_pos - VisibleSize.width / 2
	self:fix_offset_bound()
end

function main_map:tick(  )
	if math.abs(self.inertia) > 1.0 and not self.hold then
		self.inertia = self.inertia/1.1
		self.x_offset = self.x_offset + self.inertia
		self:fix_offset_bound()
	end

	--self.x_offset = self.x_offset + 1
	self.layer0:setPosition(cc.p(-self.x_offset*1.2,0))  --1.2
	self.layer1:setPosition(cc.p(-self.x_offset*1,0))  
	self.layer2:setPosition(cc.p(-self.x_offset*0.9,0))  --0.8
	self.layer3:setPosition(cc.p(-self.x_offset*0.8,0))  --0.6
	self.layer4:setPosition(cc.p(-self.x_offset*0.6,0))  --0.4
	self.layer5:setPosition(cc.p(-self.x_offset*0.3,0))  --0.4
end

--主界面
function main_map:init_main_surface(  )

	self.main_surface_layer = ui_mgr.create_ui(main_surface_layer.main_surface_layer, 'main_surface_layer')
	--self.cc:addChild(self.main_surface_layer.cc,0)
	self.main_surface_layer.widget:setPosition(0,0)
end

function main_map:reload()

end
