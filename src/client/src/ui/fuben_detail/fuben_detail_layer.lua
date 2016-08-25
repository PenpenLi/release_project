local layer					= import( 'world.layer' )
local main_map				= import( 'ui.main_map' )
local ui_mgr 				= import( 'ui.ui_mgr' )
local ui_const 				= import( 'ui.ui_const' )
local model 				= import( 'model.interface' )
local math_ext				= import( 'utils.math_ext')
local locale				= import( 'utils.locale' )

fuben_detail_layer = lua_class('fuben_detail_layer',layer.ui_layer)
local load_texture_type = TextureTypePLIST
local eicon_set = 'icon/e_icons.plist'
local json_path = 'gui/main/fuben_detail.ExportJson'
local iicon_set = 'icon/item_icons.plist'
local sicon_set = 'icon/s_icons.plist'
local soul_set  = 'icon/soul_icons.plist'

function fuben_detail_layer:_init(  )
	
	super(fuben_detail_layer,self)._init(json_path, true)

	self.widget:setPosition(VisibleSize.width/2 ,VisibleSize.height/2)
	--黑色背景

	self.fuben_img = self:get_widget('Image_4')
	self.enemy_list = self:get_widget('enemy_list')
	self.boss_panel = self:get_widget('boss_panel')
	self.monster_panel = self:get_widget('monster_panel')

	self.item_list = self:get_widget('item_list')
	self.item_panel = self:get_widget('item_panel')
	self.reset_button = self:get_widget('reset_button')
	self.lbl_surplus_count = self:get_widget('lbl_surplus_count')


	self:set_handler("Button_26", self.close_button_event)
	self:set_handler("Button_24", self.battle_button_event)

	self.is_remove = false
	self.fuben_id = 1
	self.player = model.get_player()
end

function fuben_detail_layer:set_fuben_id(fuben_id)
	self.fuben_id = fuben_id
	local d = data.fuben[fuben_id]
	local fuben_type = d.type
	--隐藏重置信息
	self:set_reset_widget()
	self:get_widget('energy_cost'):setString(d.energy)
	self:get_widget('desc'):setString(d.fuben_description)
	self:get_widget('title'):setString(d.name)
	self:get_widget('lbl_fighting_num'):setString(d.fighting_capability)

	self.sweep_10 	= self:get_widget('sweep_10')
	self.sweep_1 	= self:get_widget('sweep_1')

	self:set_sweep()
end

function fuben_detail_layer:set_reset_widget()
	local daily_limit 	= data.fuben[self.fuben_id].daily_limit
	if daily_limit == nil then
		self.lbl_surplus_count:setVisible(false)
		self.reset_button:setVisible(false)
	else 
	    local star_id = math_ext.get_star_id(self.fuben_id)
	    local bid   = tostring(star_id)
		self.lbl_surplus_count:setVisible(true)
		local fuben_daily 	= self.player:get_one_fuben_daily( bid )
		fuben_daily = fuben_daily or 0
		local daily_limit 	= data.fuben[self.fuben_id].daily_limit
		local remain_time 		= daily_limit - fuben_daily
		self.lbl_surplus_count:setString(locale.get_value_with_var('fuben_daily_time',{time = remain_time,time_daily = daily_limit}))
		if remain_time == 0 then
			self.reset_button:setVisible(true)
			self:set_handler("reset_button", self.reset_button_event)
		else 
			self.reset_button:setVisible(false)
		end
	end
	
end

function fuben_detail_layer:close_button_event( sender, eventtype )
	if eventtype == ccui.TouchEventType.began then
	elseif eventtype == ccui.TouchEventType.moved then
	elseif eventtype == ccui.TouchEventType.ended then
			sender:setTouchEnabled(false)
			self.is_remove = true
			
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end

function fuben_detail_layer:battle_button_event( sender, eventtype )
	if eventtype == ccui.TouchEventType.began then
	elseif eventtype == ccui.TouchEventType.moved then
	elseif eventtype == ccui.TouchEventType.ended then
			--sender:setTouchEnabled(false)
			ui_mgr.create_ui(import('ui.skill_select_system.skill_select_layer'), 'skill_select_layer')
			ui_mgr.get_ui('skill_select_layer'):set_scene_id(self.fuben_id)
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end

function fuben_detail_layer:reset_button_event(sender, eventtype)
	if eventtype == ccui.TouchEventType.began then
	elseif eventtype == ccui.TouchEventType.moved then
	elseif eventtype == ccui.TouchEventType.ended then
		local msg_ui = ui_mgr.create_ui(import('ui.msg_ui.msg_ok_cancel_layer'), 'msg_ok_cancel_layer')
		local reset_time_limit 	= self.player:get_vip_reset_JY_time()
		local reset_time_daily	= self.player:get_fuben_reset_daily()
		if reset_time_daily >= reset_time_limit then
			msg_ui:set_tip(locale.get_value_with_var('reset_limit',{time = reset_time_daily}))
			msg_ui:set_button_name('取消','vip特权')
			msg_ui:set_cancel_function(self.goto_vip)
		else 
			msg_ui:set_tip(locale.get_value_with_var('reset_battle',{time = reset_time_daily, time_daily = reset_time_limit}))
			msg_ui:set_ok_function(reset_battle,self.fuben_id)
		end
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end

function reset_battle( id )
	server.reset_one_fuben_daily(id)
end

function fuben_detail_layer:goto_vip()
	local vip_ui = ui_mgr.create_ui(import('ui.market_layer.market_layer'), 'market_layer')
	vip_ui:jump_to_layer( 2 )
end

function fuben_detail_layer:set_fuben_img(  )
	--local file = self.fuben_id
	local d = data.fuben[self.fuben_id]
	local file = d.fuben_thumbnail
	self.fuben_img:loadTexture( file )
end

function fuben_detail_layer:add_entity_img()
	cc.SpriteFrameCache:getInstance():addSpriteFrames( sicon_set )
	ccs.GUIReader:getInstance():widgetFromJsonFile(json_path)
	local d = data.fuben[self.fuben_id]
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



function fuben_detail_layer:add_item_img(  )
	cc.SpriteFrameCache:getInstance():addSpriteFrames( eicon_set )
	cc.SpriteFrameCache:getInstance():addSpriteFrames( iicon_set )
	cc.SpriteFrameCache:getInstance():addSpriteFrames( soul_set )
	ccs.GUIReader:getInstance():widgetFromJsonFile(json_path)

	local d = data.fuben[self.fuben_id+2]

	if d == nil then -- 针对塔防玩法
		d = data.fuben[self.fuben_id]
	end

	---首次掉落
	local star_id = math_ext.get_star_id(self.fuben_id)
	local star   = self.player:get_fuben_star(star_id)

	self.item_icon1 = {} --记录掉落的物品id
	if d.drop ~= nil then
		for _, d_item in pairs(d.drop) do
			for v,_ in pairs(d_item) do
				if v ~= 0 then
					local item_id = data.store_item[v].item
					local is_same = false
					for _,i_id in pairs(self.item_icon1) do
						if item_id == i_id then
							is_same = true
							break
						else
							is_same = false
						end
					end
					if is_same == false then			
						table.insert(self.item_icon1,item_id)
					end
				end
			end

		end

	end
	if star == 0 then
		
		if d.first_drop ~= nil then
			
			for k,v in pairs(d.first_drop) do
			
				if self:is_same_item(v) == false then
					
					local item_id = data.store_item[v].item
					local item_key=data.item_id[item_id]
					local img_panel = self.item_panel:clone()
					img_panel:ignoreAnchorPointForPosition(true)
					img_panel:setName('it_p')
					local img_btn = img_panel:getChildByName('item_button')
					img_btn:loadTextureNormal(data[item_key][item_id].icon,load_texture_type)
					img_btn:loadTexturePressed(data[item_key][item_id].icon,load_texture_type)
					self:set_item_color(img_btn,data[item_key][item_id].color)
					self.item_list:addChild(img_panel)
					--设置按钮
					self:set_item_btn_handler(img_btn,item_id)

				end
			end
		end
	end

	--掉落
	local item_icon2 = {} --对掉落内部进行自我重复判断
	if d.drop ~= nil then
		for _, d_item in pairs(d.drop) do
		
				for v,_ in pairs(d_item) do
					
					if v ~= 0 then
						local item_id = data.store_item[v].item
						local is_same = false
						for _,i_id in pairs(item_icon2) do
							if item_id == i_id then
								is_same = true
								break
							else
								is_same = false
							end
						end
						if is_same == false then
							table.insert(item_icon2,item_id)
							local item_key=data.item_id[item_id]
							local img_panel = self.item_panel:clone()
							img_panel:setName('it_p')
							img_panel:ignoreAnchorPointForPosition(true)
							if item_key ~= nil then
								local img_btn = img_panel:getChildByName('item_button')
								img_btn:loadTextureNormal(data[item_key][item_id].icon,load_texture_type)
								img_btn:loadTexturePressed(data[item_key][item_id].icon,load_texture_type)
								self:set_item_color(img_btn,data[item_key][item_id].color)
								self.item_list:addChild(img_panel)
								self:set_item_btn_handler(img_btn,item_id)
							end
						end

					end
				end
		end
	end

	--self.item_list:setPositionX(self.item_list:getPositionX()+((6-self.item_list:getChildrenCount())*44))
end



function fuben_detail_layer:set_sweep_handler(btn, battle_id, time, vip)
	local function button_event(sender, eventType)

		if eventType == ccui.TouchEventType.began then
			
		elseif eventType == ccui.TouchEventType.moved then
		  
		elseif eventType == ccui.TouchEventType.ended then
			server.sweep(battle_id, time, vip)
		elseif eventType == ccui.TouchEventType.canceled then
				
		end

	end
	btn:addTouchEventListener(button_event)
end

function fuben_detail_layer:is_same_item( item )
	
	local item_id = data.store_item[item].item
	for _,dpv in pairs(self.item_icon1) do
		
		if dpv == item_id then
			return true
		end
	end
	return false
end

function fuben_detail_layer:set_item_color( cell,color )
	cell:getChildByName('White'):setVisible(false)
	cell:getChildByName('Green'):setVisible(false)
	cell:getChildByName('Blue'):setVisible(false)
	cell:getChildByName('Purple'):setVisible(false)
	cell:getChildByName('Orange'):setVisible(false)
	cell:getChildByName(color):setVisible(true)
end

function fuben_detail_layer:set_sweep()
	self.lbl_sweep_name = self:get_widget('lbl_sweep_name')
	self.lbl_sweep_num 	= self:get_widget('lbl_sweep_num')
	self.sweep_img 		= self:get_widget('sweep_img')
	local pt_fuben_condition = self.fuben_id > 1000 and self.fuben_id < 3000 and self.fuben_id > self.player:get_fuben()
	local jy_fuben_condition = self.fuben_id > 3000 and self.fuben_id < 5000 and self.fuben_id > self.player:get_elite_fuben()
	if pt_fuben_condition or jy_fuben_condition then
		self.sweep_10:setVisible(false)
		self.sweep_1:setVisible(false)
		self.lbl_sweep_name:setVisible(false)
		self.lbl_sweep_num:setVisible(false)
		self.sweep_img:setVisible(false)
	else
		local sweep_ticket = self.player:get_sweep_ticket()
		local energy =	self.player:get_energy()
		local vip_lv = self.player:get_vip().lv
		local need_energy = data.fuben[self.fuben_id].energy
		local time_limit	= data.fuben[self.fuben_id].daily_limit
	    local star_id = math_ext.get_star_id(self.fuben_id)
		local daily_play = self.player:get_one_fuben_daily(tostring(star_id))
		daily_play = daily_play or 0
		local can_play 
		if time_limit ~= nil then
			can_play = time_limit - daily_play
		else 
			can_play = 100
		end
		local lbl_sweep_btn = self.sweep_10:getChildByName('lbl_sweep_btn')
		self.lbl_sweep_name:setString('扫荡券')
		self.lbl_sweep_num:setString('x' .. sweep_ticket)
		if vip_lv < 4 then
			lbl_sweep_btn:setString('无法扫荡')
			self:set_sweep_handler(self.sweep_10, self.fuben_id, 10, 4)
		else
			local energy_t = math.floor(energy / need_energy)
			if sweep_ticket > energy_t then
				if energy_t < can_play then
					sweep_time = energy_t
				else
					sweep_time = can_play
				end
			else
				if sweep_ticket < can_play then
					sweep_time = sweep_ticket
				else
					sweep_time = can_play
				end
			end
			if sweep_time > 10 then
				sweep_time = 10
			end
			lbl_sweep_btn:setString('扫荡x' .. sweep_time)
			if sweep_time == 0 then
				sweep_time = 1
			end
			self:set_sweep_handler(self.sweep_10, self.fuben_id, sweep_time, 4)
		end
		self:set_sweep_handler(self.sweep_1, self.fuben_id, 1, 0)
	end
end


--释放
function fuben_detail_layer:release(  )

	--移除tips
	local soul_tips = ui_mgr.get_ui('soul_tips_layer')
	if soul_tips ~= nil then
		soul_tips:set_remove()
	end
	local item_tips = ui_mgr.get_ui('item_tips_layer')
	if item_tips ~= nil then
		item_tips:set_remove()
	end

	self.is_remove = false
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( eicon_set )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( iicon_set )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( sicon_set )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( soul_set )
	super(fuben_detail_layer, self).release()
	

end

function fuben_detail_layer:reload()
	super(fuben_detail_layer,self).reload()
	self:set_sweep()
	self:set_reset_widget()
end


--设置怪物按钮事件
function fuben_detail_layer:set_entity_btn_handler( btn ,v )
	local function evenType(sender, eventype)
		local temp_ui
		if eventype == ccui.TouchEventType.began then
			if ui_mgr.get_ui('soul_tips_layer') == nil then
				temp_ui = ui_mgr.create_ui(import('ui.tips_layer.soul_tips_layer'),'soul_tips_layer')
				temp_ui:set_content(v,self.fuben_id)
				local posx = btn:getWorldPosition().x-btn:getContentSize().width/2
				local posy = btn:getWorldPosition().y
				temp_ui:set_position(posx,posy)
				--temp_ui:play_up_anim()
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

--设置物品按钮事件
function fuben_detail_layer:set_item_btn_handler( btn ,id )
	local function evenType(sender, eventype)
		local temp_ui
		if eventype == ccui.TouchEventType.began then
			if ui_mgr.get_ui('item_tips_layer') == nil then
				temp_ui = ui_mgr.create_ui(import('ui.tips_layer.item_tips_layer'),'item_tips_layer')
				temp_ui:set_content(id)
				local posx = btn:getWorldPosition().x-btn:getContentSize().width/2
				local posy = btn:getWorldPosition().y
				temp_ui:set_position(posx,posy)
				--temp_ui:play_up_anim()
			end
		elseif eventype == ccui.TouchEventType.moved then
		  
		elseif eventype == ccui.TouchEventType.ended then
			temp_ui = ui_mgr.get_ui('item_tips_layer')
			if temp_ui ~= nil then
				temp_ui:set_remove()
			end
		elseif eventype == ccui.TouchEventType.canceled then
			temp_ui = ui_mgr.get_ui('item_tips_layer')
			if temp_ui ~= nil then
				temp_ui:set_remove()
			end
		end

	end 
	btn:addTouchEventListener(evenType)
end


