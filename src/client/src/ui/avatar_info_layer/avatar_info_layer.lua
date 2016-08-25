local combat_conf			= import( 'ui.avatar_info_layer.avatar_info_ui_conf' )
local layer					= import( 'world.layer' )
local model 				= import( 'model.interface' )
local locale				= import( 'utils.locale' )
local music_mgr				= import( 'world.music_mgr' )
local anim_trigger 			= import( 'ui.main_ui.anim_trigger')
local ui_const 				= import( 'ui.ui_const' )
local char					= import( 'world.char' )
local ui_mgr				= import( 'ui.ui_mgr' )

avatar_info_layer = lua_class('avatar_info_layer',layer.ui_layer)
local _jsonfile = 'gui/main/ui_avatar_info.ExportJson'
local eicon_set = 'icon/e_icons.plist'
local sicon_set = 'icon/s_icons.plist'
local load_texture_type = TextureTypePLIST

local strength_lv_name = {'power', 'courage', 'technique', 'life', 'strong', 'tenacity'}

function avatar_info_layer:_init( )

	super(avatar_info_layer,self)._init(_jsonfile,true)
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2, VisibleSize.height/2)
	self:set_handler("btn_close", self.close_button_event)
	--是否移除
	self.is_remove = false

	self:get_widgets(combat_conf.avatar_info_ui_btn)
	self:get_widgets(combat_conf.avatar_info_ui_pal)
	self:get_widgets(combat_conf.avatar_info_ui_lbl)
	self:get_widgets(combat_conf.avatar_info_ui_img)
	self:set_handlers(combat_conf.avatar_info_ui_btn)
	self.btn_avatar_detail:setTouchEnabled(false)
	self.btn_avatar_detail:setSelectedState(true)
	self.pal_avatar_detail:setVisible(true)

	self.model = nil
end

function avatar_info_layer:set_info(info_data)
	ui_mgr.schedule_once(0, self, self._set_info, info_data)
end

function avatar_info_layer:_set_info(info_data)
	if info_data == nil then
		return 
	end

	--------------------------------多语言---------------------------
	for widget, v in pairs(combat_conf.avatar_info_ui_lbl) do
		if v.text ~= nil then
			self[widget]:setString(locale.get_value(combat_conf.avatar_info_ui_lbl[widget].text))
		end
	end
	-----------------------------------------------------------------
	--------------------------------描边---------------------------
	for widget, v in pairs(combat_conf.avatar_info_ui_lbl) do
		if v.edge ~= nil then
			self[widget]:enableOutline(ui_const.UilableStroke, v.edge)
		end
	end

	for k, v in pairs(info_data) do
		local widget_name = 'lbl_' .. k
		if self[widget_name] ~= nil then
			if type(v) == 'number' then 
				self[widget_name]:setString(math.floor(v+0.5)) --四舍5入
			elseif type(v) == 'string' then 
				self[widget_name]:setString(v)
			end
		end
	end
	--------------------------------------------------------------
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( eicon_set )
	local wear_data = info_data.wear
	for k, v in pairs(wear_data) do 
		local equip = info_data:get_equip(v)
		local equip_type = equip:get_type()
		local equip_icon = equip:get_icon()
		local equip_color = equip:get_color()
		self['img_' .. equip_type]:loadTexture(equip_icon, load_texture_type)
		self:set_equip_color(equip_type, equip_color)
		self:set_equip_btn_listener(self['img_' .. equip_type], equip)
		--dir(equip)
	end
	--dir(equips_data['20003'].data)
	--装备
	-- for widget, v in pairs(combat_conf.avatar_info_ui_img) do
	-- 	if v.e_type ~= nil then
	-- 		local e_id = info_data.wear[v.e_type]
	-- 		local texture_path = data[v.e_type][e_id]['icon']
	-- 		self[widget]:loadTexture(texture_path, load_texture_type)
	-- 	end
	-- end 

	--精通等级
	local strength_lv = info_data:get_strength_lv()
	for i = 1, 6 do
		local x = math.ceil(strength_lv[i]/10)*10
		self['lbl_strength_lv_' .. i]:setString(strength_lv[i])
		self['lbl_strength_lv_' .. i*10+i]:setString(locale.get_value('info_level_' .. x))
	end

	for k, v in pairs(info_data.final_attrs) do
		local widget_name = 'lbl_' .. k
		if self[widget_name] ~= nil then
			if type(v) == 'number' then 
				self[widget_name]:setString(math.floor(v+0.5)) --四舍5入
			elseif type(v) == 'string' then 
				self[widget_name]:setString(v)
			end
		end
	end

	--角色模型
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( sicon_set )
	local shadow_widget = self:get_widget('Image_3')
	self.player = create_char_model(info_data, 'idle')					--加载玩家动画信息
	shadow_widget:addChild(self.player.cc)			--然后把玩家动画加到这个阴影上
	shadow_widget:setLocalZOrder(11111)
	shadow_widget:setAnchorPoint(cc.p(0.5, 0.5))	--设置阴影的锚点
	self.player.cc:setAnchorPoint(cc.p(0.5, 0))		--设置玩家的锚点在脚下。底边中点
	local shadow_size = shadow_widget:getLayoutSize()	--获取阴影的大小
	self.player.cc:setPosition(shadow_size.width/2-10,shadow_size.height*2/3)	--设置玩家位置
	local index = 1
	for i,v in ipairs( info_data:get_pvp_def_skills() ) do
		self['img_skill_'..index]:loadTexture(v.data.icon, load_texture_type)
		self['img_skill_'..index]:setVisible(true)
		index = index + 1
		if index > 3 then
			break
		end
	end
	-- for i = index, 3 do 
	-- 	self['img_skill_'..index]:setVisible(false)
	-- end


	local f_def = 0
	local i_def = 0
	local n_def = 0
	if info_data:get_pvp_def_skills() ~= nil then
		for _, skill in pairs(info_data:get_pvp_def_skills()) do
			f_def = f_def + skill:get_f_def()
			i_def = i_def + skill:get_i_def()
			n_def = n_def + skill:get_n_def()
		end
	end

	self.lbl_f_def:setString(f_def)
	self.lbl_i_def:setString(i_def)
	self.lbl_n_def:setString(n_def)
end

function avatar_info_layer:get_widgets(widgets)
	for widget, _ in pairs(widgets) do
		self[widget] = self:get_widget(widget)
	end
end

function avatar_info_layer:set_handlers( widgets )
	for widget, v in pairs(widgets) do
		if v.handler ~= nil then
			self:set_handler(widget, self[v.handler])
		end
	end
end

function avatar_info_layer:close_button_event( sender, eventtype )
		if eventtype == ccui.TouchEventType.began then
		
		elseif eventtype == ccui.TouchEventType.moved then
	  
		elseif eventtype == ccui.TouchEventType.ended then
			anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_UP_ANIM,false)
			self.cc:setVisible(false)
			self.is_remove = true
		elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end

function avatar_info_layer:check_button_event( sender, eventtype )
	if eventtype == ccui.TouchEventType.began then
	elseif eventtype == ccui.TouchEventType.moved then
	elseif eventtype == ccui.TouchEventType.ended then
		local widget_name = sender:getName()
		for name, _ in pairs(combat_conf.avatar_info_ui_btn) do
			if self[name] ~= nil then

				if name == widget_name then
					self[name]:setTouchEnabled(false)
				else
					self[name]:setTouchEnabled(true)
					self[name]:setSelectedState(false)
				end
			end
		end

		local view_name = combat_conf.avatar_info_ui_btn[widget_name].visible_view
		for name, _ in pairs(combat_conf.avatar_info_ui_pal) do
			if self[name] ~= nil then
				if name == view_name then
					self[name]:setVisible( true )
				else
					self[name]:setVisible( false )
				end
			end
		end
	elseif eventtype == ccui.TouchEventType.canceled then
	end
end

function avatar_info_layer:set_equip_color( equip_type, equip_color )
	local colors = {'green', 'blue', 'purple', 'orange'}
	local color = string.lower(equip_color)
	
	for _, c in pairs(colors) do
		local widget_name = equip_type .. '_' .. c
		if color == c then
			self:get_widget(widget_name):setVisible(true)
			self:get_widget(widget_name):setLocalZOrder(100000)
		else
			self:get_widget(widget_name):setVisible(false)
		end
	end
end

function avatar_info_layer:set_equip_btn_listener(widget, equip)
	local function button_event(sender, eventtype)
		if eventtype == ccui.TouchEventType.began then

		elseif eventtype == ccui.TouchEventType.moved then

		elseif eventtype == ccui.TouchEventType.ended then
			local ui_info = ui_mgr.create_ui(import('ui.equip_sys_layer.equipment_info_panel'), 'equipment_info_panel')
			cc.SpriteFrameCache: getInstance(): addSpriteFrames( eicon_set )
			ui_info:show_strength_panel(false)
			ui_info:set_head_img(equip:get_icon())
			ui_info:set_equip_name(equip:get_name(),equip:get_level(),equip:get_color())
			ui_info:set_cell_color( equip:get_color() )
			ui_info:set_main_value(equip:get_prop_value())
			ui_info:set_main_pro_img(equip:get_prop_key())
			ui_info:set_main_name(equip:get_prop_key())
			ui_info:set_activation_value(equip:get_activate_prop_value())
			ui_info:set_activation_pro_img(equip:get_activate_prop_key())
			ui_info:set_activation_name(equip:get_activate_prop_key())
			ui_info:hide_equip_btn()
			ui_info:hide_activate_btn()
			ui_info:hide_strengthen_btn()
			ui_info:play_up_anim()
			ui_info:set_main_state(true)
		end
	end
	widget:setTouchEnabled(true)
	widget:addTouchEventListener( button_event )
end

--create char by 'info.role_type'  'info.wear'  'info.equips'
function create_char_model(info, anim_key)
	local conf = import('char.'..info.role_type) 
	local entity_anim = char.char(conf)
	entity_anim.cc:setLocalZOrder(11110)
	local wear = info.wear
	if wear ~= nil then 
		entity_anim:change_equip(entity_anim.equip_conf.weapon, info.equips[tostring(wear.weapon)])
		entity_anim:change_equip(entity_anim.equip_conf.helmet, info.equips[tostring(wear.helmet)])
		entity_anim:change_equip(entity_anim.equip_conf.armor, info.equips[tostring(wear.armor)])
	end
	entity_anim.anim = nil

	if anim_key ~= nil then
		for k, v in pairs(conf) do
			if type(v) == 'table' and v.anim ~= nil
		   and (k == anim_key) then
				entity_anim.anim = v.anim
			end
		end
		--让玩家播放一下动画
		entity_anim:play_anim(entity_anim.anim)
	end
	return entity_anim
end
