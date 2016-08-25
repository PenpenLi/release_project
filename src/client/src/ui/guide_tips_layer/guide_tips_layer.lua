local layer 			= import('world.layer')
local combat_conf		= import( 'ui.guide_tips_layer.guide_tips_cont' )
local anim_trigger 		= import( 'ui.main_ui.anim_trigger')
local locale			= import( 'utils.locale' )
local ui_const			= import( 'ui.ui_const' )
local model             = import( 'model.interface')
local ui_mgr 			= import( 'ui.ui_mgr' )
local shaders  			= import( 'utils.shaders' )
local msg_queue 		= import( 'ui.msg_ui.msg_queue' )

local load_texture_type = TextureTypePLIST
local _star_space = 1000

guide_tips_layer = lua_class('guide_tips_layer',layer.ui_layer)
local _json_file 	= 'gui/main/ui_item_guide.ExportJson'
local item_icon_set = 'icon/item_icons.plist'
local soul_icon_set = 'icon/soul_icons.plist'
local fuben_icon_set = 'icon/fuben_icons.plist'

function guide_tips_layer:_init( )

	super(guide_tips_layer,self)._init(_json_file,true)
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2,VisibleSize.height/2)
	
	self:set_handler('Button_close', self.close_button_event)


	self:get_widget('Panel_8'):setVisible(false)
	self:get_widget('Panel_8_0'):setVisible(false)
	self.guide_panel = self:get_widget('Panel_1')
	self:finish_init()
end

function guide_tips_layer:finish_init()
	for name, val in pairs(combat_conf.guide_tips_ui_label) do 	--读出role_ui_conf文件的table
		self['lbl_' .. name] = self:get_widget('lbl_' .. name) --名字加前缀，就可以读出相应的名字label控件
		--self['txt_' .. name] = self:get_widget('txt_' .. name)	--一样，这样就可以读出相应的数值的label控件
		local temp_name = self['lbl_' .. name]			--把读出来的控件存到self的一个table中
		--local temp_val = self['txt_' .. name]
		if temp_name ~= nil then 						--名字不为空，就设置字体类似，和显示的内容
			temp_name:setFontName(ui_const.UiLableFontType)
			if val.edge ~= nil and val.edge > 0 then 					--edge的值大于0就描边
				temp_name:enableOutline(ui_const.UilableStroke, val.edge)  ---，描边，厚度 role_ui_conf.lua中role_ui_label的edge
			end
		end
	end
	self['lbl_goto']:setString(locale.get_value('guide_tips_goto'))
end

function guide_tips_layer:gain_from( item_id)
	self.tips = {}
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( item_icon_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( soul_icon_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( fuben_icon_set )
	--print('================item_id ==', item_id)
	local item_type = data.item_id[item_id]
	local item_name = data[item_type][item_id].name
	local icon = data[item_type][item_id].icon
	self:get_widget('lbl_res_name'):setString(item_name)
	self:get_widget('Image_27'):loadTexture(icon, load_texture_type)
	for i = 1, 3 do
		local pathway_type = data.guide_tips[item_id]['pathway' .. i .. '_type']
		if pathway_type ~= nil then
			local panel
			if pathway_type == 1 then --副本关卡
				panel = self:get_widget('Panel_8'):clone()
				panel:getChildByName('lbl_percent'):setVisible(false)
				local fuben_id = data.guide_tips[item_id]['pathway' .. i .. '_content']
				local fuben_icon = data.guide_tips[item_id]['pathway' .. i .. '_icon']
				local fuben_img = panel:getChildByName('Image_15')
				fuben_img:loadTexture(fuben_icon, load_texture_type)
				fuben_img:setScale(0.7)
				local f = data.fuben[fuben_id]
				local instance_name = f.name
				local chap_id = f.chapter_id
				if f.type == 'JY' then
					instance_name = instance_name .. locale.get_value('guide_tips_elite')
					local lbl_percent = panel:getChildByName('lbl_percent')
					lbl_percent:setVisible(true)
					self:set_finish_per(fuben_id, lbl_percent)
					chap_id = chap_id - 30
				end
				local chap_name = locale.get_value_with_var('guide_tips_chap', {chapter_id = chap_id}) .. ' ' .. locale.get_value('map_' .. chap_id)
				panel:getChildByName('lbl_chapter'):setString(chap_name)
				panel:getChildByName('lbl_instance'):setString(instance_name)
				local function goto_event( sender, eventtype )
					self:goto_button_event(sender, eventtype)
				end
				self:set_panel_gray(panel, fuben_id)
				local goto_btn = panel:getChildByName('Button_battle'):getChildByName('Button_goto')
				goto_btn:setTag(fuben_id)
				goto_btn:addTouchEventListener(goto_event)
			elseif pathway_type == 2 then --shop
				panel = self:get_widget('Panel_8_0'):clone()
				panel:getChildByName('lbl_shop_name'):setString(locale.get_value('guide_tips_shop_title'))
				local shop_id = data.guide_tips[item_id]['pathway' .. i .. '_content']
				local shop_name = locale.get_value('guide_tips_shop_' .. shop_id)
				local gain_msg  = locale.get_value_with_var('guide_tips_which_shop', {shop_name = shop_name})
				panel:getChildByName('lbl_shop_name_0'):setString(gain_msg)
			end
			if panel ~= nil then
				panel:setVisible(true)
				self.guide_panel:addChild(panel)
				panel:setPosition(3, 90 - (i - 1) * 125 )
			end
		end
	end
end

function guide_tips_layer:set_panel_gray(panel, battle_id )
	if not self:_verify_battle_id(battle_id) then
		if self.tips[battle_id] == nil then
			self.tips[battle_id] = 3
		end
	end
	if not self:_verify_energy_for_fuben(battle_id) then
		self.tips[battle_id] = 1
	end
	if self.tips[battle_id] == 3 then
		self:set_gray(panel:getChildByName('Image_15'))
	end
end

function guide_tips_layer:set_finish_per( battle_id, lbl_percent )
	local d = data.fuben[battle_id]
	local fuben_id = d.instance_id
	local chapter_id = d.chapter_id
	local star_id = chapter_id * _star_space + fuben_id
	local time = self:_get_fuben_daily(star_id)
	lbl_percent:setString((3 - time) .. '/3')
	if time >= 3 then
		self.tips[battle_id] = 2
	end
end

function guide_tips_layer:_get_fuben_daily(star_id)
	local bid = tostring(star_id)
	local time = model.get_player().fuben_daily[bid]
	if time == nil then
		return 0
	end
	return time
end

function guide_tips_layer:_verify_battle_id( battle_id )
	local d = data.fuben[battle_id]
	local fuben_id = d.instance_id
	local chapter_id = d.chapter_id
	local star_id = chapter_id * _star_space + fuben_id
	local fuben = model.get_player().fuben
	local elite_fuben = model.get_player().elite_fuben
	
	if d.type == 'JY' then
		local pre_barrier = d.pre_barrier
		if pre_barrier ~= nil then
			for k, v in ipairs(pre_barrier) do
				if v > fuben then
					return false
				end
			end
		end
		if elite_fuben == 0 or (elite_fuben ~= 0 and d.id > elite_fuben) then
			return false
		end
	elseif d.type == nil then
		if fuben == 0 or (fuben ~= 0 and d.id > fuben) then
            return false
        end
	end
	if d.lv_limit ~= nil and model.get_player().level < d.lv_limit then
		self.tips[battle_id] = 1
		return false
	end
	-- if d.daily_limit ~= nil and self:_get_fuben_daily(star_id) >= d.daily_limit then
	-- 	return false
	-- end
	return true
end

function guide_tips_layer:_verify_energy_for_fuben(battle_id)
	local d = data.fuben[battle_id]
	if d == nil then
		return false
	end
	if d.energy ~= nil and model.get_player().energy < d.energy then
		return false
	end
	return true
end

--1.体力不足  提示'体力不足'  标记为 1
--2.已达到当天进入副本限制 提示'今天挑战次数已满' 标记为 2
--3.未打到副本，提示'本关卡尚未开启' 标记为 3
function guide_tips_layer:goto_button_event( sender, eventType ) 
	if eventType == ccui.TouchEventType.ended then
		local battle_id = sender:getTag()
		local tips_type = self.tips[battle_id]
		if tips_type ~= nil then
			if tips_type == 1 then
				msg_queue.add_msg(locale.get_value('msg_not_fit_fuben'))
				return
			elseif tips_type == 2 then
				msg_queue.add_msg(locale.get_value('msg_fuben_limit'))
				return
			elseif tips_type == 3 then
				msg_queue.add_msg(locale.get_value('msg_fuben_not_open'))
				return
			end
		end
		ui_mgr.create_ui(import('ui.fuben_detail.fuben_detail_layer'), 'fuben_detail_layer')
		ui_mgr.get_ui('fuben_detail_layer'):set_fuben_id(battle_id)
		ui_mgr.get_ui('fuben_detail_layer'):set_fuben_img()
		ui_mgr.get_ui('fuben_detail_layer'):add_entity_img()
		ui_mgr.get_ui('fuben_detail_layer'):add_item_img()		
	end
end

function guide_tips_layer:set_gray( sp, num)
	local children = sp:getChildren()

	if num == nil then
		num = 0.1
	end
	shaders.SpriteSetGray(sp:getVirtualRenderer(), num)
	if children and #children > 0 then
		--遍历子对象设置
		for i,v in ipairs(children) do
			shaders.SpriteSetGray(v:getVirtualRenderer(),num)
			self:set_gray(v, num)
		end
	end
end

function guide_tips_layer:reload( )
	super(guide_tips_layer,self).reload()
end

--移除操作
function guide_tips_layer:release( ) 
	print('guide_tips_layer release')
	self.is_remove = false
	super(guide_tips_layer,self).release()
	cc.SpriteFrameCache: getInstance(): removeSpriteFramesFromFile( item_icon_set )
	cc.SpriteFrameCache: getInstance(): removeSpriteFramesFromFile( soul_icon_set )
	cc.SpriteFrameCache: getInstance(): removeSpriteFramesFromFile( fuben_icon_set )
	-- body
end

--关闭按钮
function guide_tips_layer:close_button_event( sender,eventtype )

	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  
	elseif eventtype == ccui.TouchEventType.ended then
		self.cc:setVisible(false)

		--anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_UP_ANIM,false)
		self.is_remove = true
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end
