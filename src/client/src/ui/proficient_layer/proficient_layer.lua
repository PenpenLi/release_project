local layer 				= import('world.layer')
local combat_conf			= import( 'ui.proficient_layer.proficient_ui_conf' )
local locale				= import( 'utils.locale' )
local ui_const 				= import( 'ui.ui_const' )
local anim_trigger 			= import( 'ui.main_ui.anim_trigger')
local model 				= import( 'model.interface' )
local msg_queue 			= import( 'ui.msg_ui.msg_queue' )
local proficient_tx			= import( 'ui.proficient_layer.proficient_tx' )
local proficient_sel_tx			= import( 'ui.proficient_layer.proficient_sel_tx' )
local ui_mgr				= import( 'ui.ui_mgr' )
local ui_guide				= import( 'world.ui_guide' )
local director				= import( 'world.director' )

proficient_layer = lua_class('proficient_layer',layer.ui_layer)
local load_texture_type = TextureTypePLIST
local _json_path = 'gui/main/ui_proficient.ExportJson'
local icon_set = 'icon/item_icons.plist'

function proficient_layer:_init(  )
	super(proficient_layer,self)._init(_json_path,true)

	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2,VisibleSize.height/2)


	self.is_remove = false
	self.need_gold = 0
	self:init_lbl_font()
	self:updata_player_info()

	self:set_handler('close_button',self.close_button_event)

	self.lbl_item_name = self:get_widget('lbl_item_name')

	self.courage_button = self:get_widget('courage_button')
	self.strong_button = self:get_widget('strong_button')
	self.life_button = self:get_widget('life_button')
	self.tenacity_button = self:get_widget('tenacity_button')
	self.technique_button = self:get_widget('technique_button')
	self.power_button = self:get_widget('power_button')
	self.prom_button = self:get_widget('prom_button')
	self.advanced_button  = self:get_widget('advanced_button')
	self.quick_prom_button = self:get_widget('quick_prom_button')
	self.btn_bottom_img = self:get_widget('btn_bottom_img')


	self:set_handler('courage_button',self.courage_button_event)
	self:set_handler('strong_button',self.strong_button_event)
	self:set_handler('life_button',self.life_button_event)
	self:set_handler('tenacity_button',self.tenacity_button_event)
	self:set_handler('technique_button',self.technique_button_event)
	self:set_handler('power_button',self.power_button_event)

	self:set_handler('prom_button',self.prom_button_event)
	self:set_handler('advanced_button',self.advanced_button_event)
	self:set_handler('quick_prom_button',self.quick_prom_button_event)
	--默认显示力量
	self.proft_name = '力量'
	self.proft_img_name = 'power'
	self.proft_high_order = EnumProficientTypes.power
	self.power_button:setTouchEnabled(false)

	--精通属性图标
	self.pro_1_img = self:get_widget('pro_1_img')
	self.pro_2_img = self:get_widget('pro_2_img')

	self:updata_button()
	self:update_right_panel()
	-- self:chech_button_state()
	-- ui_mgr.schedule_once(0, self, self.updata_button)
	ui_mgr.schedule_once(0, self, self.first_init)
end

function proficient_layer:first_init()
	--self:update_right_panel()
	self:chech_button_state()
end

--对文字的描边
function proficient_layer:init_lbl_font(  )
	for name, val in pairs(combat_conf.proficient_ui_label) do
		self['lbl_' .. name] = self:get_widget('lbl_' .. name)
		local temp_label = self['lbl_' .. name]
		self['txt_' .. name] = self:get_widget('txt_' .. name)
		local temp_txt = self['txt_' .. name]

		if temp_label ~= nil then
			--temp_label:setFontName(ui_const.UiLableFontType)
			if locale.get_value('prof_' .. name) ~= ' ' then
			 	temp_label:setString(locale.get_value('prof_' .. name))		--如果传入的name在languane是没有的，就会返回以个空字符串
			end

			temp_label:enableOutline(ui_const.UilableStroke, 1)  ---，描边，厚度 role_ui_conf.lua中role_ui_label的edge

		end

		if temp_txt ~= nil then
			--temp_txt:setFontName(ui_const.UiLableFontType)

		end


	end
end

-- 角色属性更新
function proficient_layer:updata_player_info()
	self.model = model.get_player()
	self.model:init_combat_attr()

	local player_attr = self.model.final_attrs
	--print('攻击力：',self.aftertime_attrs.attack)
	self.lbl_force:setString((locale.get_value('prof_force') .. ' : ' .. self:getIntPart(player_attr:get_fighting_capacity())))
	self.txt_max_hp:setString(self:getIntPart(player_attr.max_hp))
	self.txt_attack:setString(self:getIntPart(player_attr.attack))
	self.txt_defense:setString(self:getIntPart(player_attr.defense))
	self.txt_crit_level:setString(self:getIntPart(player_attr.crit_level))

end

function proficient_layer:updata_button()

	local player = model.get_player()
	local strength_pros = player:get_strength_lv()			--获取玩家身上的属性
	for k , v in pairs(EnumProficientTypes) do 

		local prof_type = v
		local cur_level = strength_pros[prof_type] --当前要精通的属性
		local will_level = prof_type*100000+(cur_level + 1)
		local gold 
		local idx 
		local will_lv_data = data.avatar_strengthen[will_level]
		if will_lv_data ~= nil then
			gold = will_lv_data.gold
			idx = will_lv_data.item_id
		end

		if cur_level >=80 then
			self[k.. '_button']:getChildByName('up_img'):setVisible(false)
		else
			if idx == nil then
				if player:get_money() >= gold and player:get_level() > cur_level then
					self[k.. '_button']:getChildByName('up_img'):setVisible(true)
				else
					self[k.. '_button']:getChildByName('up_img'):setVisible(false)
				end
			else
				local num = self:get_item_oid_number(idx)
				if num ~= nil and num > 1  and player:get_level() > cur_level then
					self[k.. '_button']:getChildByName('up_img'):setVisible(true)
				else
					self[k.. '_button']:getChildByName('up_img'):setVisible(false)
				end
			end
		end

	end


end

function proficient_layer:getIntPart( x )
	-- body
	local i,_ = math.modf(x)
	return i
end


function proficient_layer:set_prof_button_touch( btn )
	self.courage_button:setTouchEnabled(true)
	self.strong_button:setTouchEnabled(true)
	self.life_button:setTouchEnabled(true)
	self.tenacity_button:setTouchEnabled(true)
	self.technique_button:setTouchEnabled(true)
	self.power_button:setTouchEnabled(true)

	btn:setTouchEnabled(false)
	btn:setHighlighted(false)
end



--关闭按钮
function proficient_layer:close_button_event( sender,eventtype )

	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  
	elseif eventtype == ccui.TouchEventType.ended then
		self.cc:setVisible(false)

		anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_UP_ANIM,false)
		self.is_remove = true
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end

function proficient_layer:courage_button_event( sender,eventtype )

	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  
	elseif eventtype == ccui.TouchEventType.ended then
		self:set_prof_button_touch(sender)
		self:set_bottom_img(sender)
		self.proft_img_name = 'courage'
		self.proft_name = locale.get_value('prof_name_courage')
		self.proft_high_order = EnumProficientTypes.courage

		self:update_right_panel()
		self:chech_button_state()

	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end

function proficient_layer:strong_button_event( sender,eventtype )

	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  
	elseif eventtype == ccui.TouchEventType.ended then
		self:set_prof_button_touch(sender)
		self:set_bottom_img(sender)
		self.proft_img_name = 'strong'
		self.proft_name = locale.get_value('prof_name_strong')
		self.proft_high_order = EnumProficientTypes.strong


		self:update_right_panel()
		self:chech_button_state()
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end


function proficient_layer:life_button_event( sender,eventtype )

	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  
	elseif eventtype == ccui.TouchEventType.ended then

		self:set_prof_button_touch(sender)
		self:set_bottom_img(sender)
		self.proft_img_name = 'life'
		self.proft_name = locale.get_value('prof_name_life')
		self.proft_high_order = EnumProficientTypes.life

		self:update_right_panel()
		self:chech_button_state()
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end


function proficient_layer:tenacity_button_event( sender,eventtype )

	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  
	elseif eventtype == ccui.TouchEventType.ended then

		self:set_prof_button_touch(sender)
		self:set_bottom_img(sender)
		self.proft_img_name = 'tenacity'
		self.proft_name = locale.get_value('prof_name_tenacity')
		self.proft_high_order = EnumProficientTypes.tenacity


		self:update_right_panel()
		self:chech_button_state()
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end


function proficient_layer:technique_button_event( sender,eventtype )

	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  
	elseif eventtype == ccui.TouchEventType.ended then

		self:set_prof_button_touch(sender)
		self:set_bottom_img(sender)
		self.proft_img_name = 'technique'
		self.proft_name = locale.get_value('prof_name_technique')
		self.proft_high_order = EnumProficientTypes.technique

		self:update_right_panel()
		self:chech_button_state()
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end


function proficient_layer:power_button_event( sender,eventtype )

	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  
	elseif eventtype == ccui.TouchEventType.ended then

		self:set_prof_button_touch(sender)
		self:set_bottom_img(sender)
		self.proft_img_name = 'power'
		self.proft_name = locale.get_value('prof_name_power')
		self.proft_high_order = EnumProficientTypes.power

		self:update_right_panel()
		self:chech_button_state()
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end

--升级按钮
function proficient_layer:prom_button_event( sender,eventtype )

	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  
	elseif eventtype == ccui.TouchEventType.ended then
		local player = model.get_player()
		local will_level = self.will_level
		local w_level = will_level%100
		local cur_level  = player:get_level()
		local gold = data.avatar_strengthen[will_level].gold
		if player:get_money() >= gold then
			if w_level <= cur_level then
				self.fc =  math.modf(player.final_attrs:get_fighting_capacity())
				server.strengthen(will_level)
				ui_guide.pass_condition( 'first_proficiency' )
			else
				msg_queue.add_msg('天赋等级不能超过人物等级')
			end
		else
			msg_queue.add_msg('没钱了,请充值')
		end
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end

--进阶按钮
function proficient_layer:advanced_button_event( sender,eventtype )

	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  
	elseif eventtype == ccui.TouchEventType.ended then

		local will_level = self.will_level
		local item_number =self.item_number
		if item_number == nil then
			item_number = 0
		end

		if item_number >= 1  then
			self.fc =  math.modf(model.get_player().final_attrs:get_fighting_capacity())
			server.strengthen(will_level)
		else
			msg_queue.add_msg('没有这物品')
		end
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end

--一键升级
function proficient_layer:quick_prom_button_event( sender,eventtype )
	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  
	elseif eventtype == ccui.TouchEventType.ended then
		local player = model.get_player()
		local will_level = self.will_level
		local cur_level = player:get_level()
		local w_level = will_level%100
		local gold = data.avatar_strengthen[will_level].gold
		if player:get_money() >= gold then
			if w_level <= cur_level then
				self.fc =  math.modf(player.final_attrs:get_fighting_capacity())
				director.show_loading()
				server.strengthens(will_level)
			else
				msg_queue.add_msg('天赋等级不能超过人物等级')
			end
		else
			msg_queue.add_msg('没钱了,请充值')
		end
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end

function proficient_layer:cal_sum_pro( level ,pro_name )
	local sum = 0
	for i = 1 ,level do
		local id = self.proft_high_order*100000+i
		sum = sum + data.avatar_strengthen[id][pro_name]
	end
	return sum
end


--更新右面板
function proficient_layer:update_right_panel(  )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( icon_set )
	self:reload_json()
	self:set_proficient_img(self.proft_img_name)
	self:set_proficient_name(self.proft_name)


	--设置升级信息
	local player = model.get_player()
	local strength_pros = player:get_strength_lv()			--获取玩家身上的属性
	local cur_level = strength_pros[self.proft_high_order] --当前要精通的属性
	-- print('=================================================')
	-- dir(player:get_strength_lv())
	-- print('=================================================')
	self.cur_level = cur_level
	local pros = {}
	local pros_sum = {}
	self:set_proficient_level(cur_level)
	local will_level = self.proft_high_order*100000+(cur_level + 1)
	self.will_level = will_level
	local nx_lv_data = data.avatar_strengthen[will_level]
	if nx_lv_data ~= nil then
		local attack = nx_lv_data.attack
		local crit_level = nx_lv_data.crit_level
		local max_hp  = nx_lv_data.max_hp
		local defense = nx_lv_data.defense
		
		if attack >0  then
			pros['attack'] = attack
			pros_sum['sum-attack'] = self:cal_sum_pro(self.cur_level,'attack')
		end

		if crit_level >0 then
			pros['crit_level'] = crit_level
			pros_sum['sum-crit_level'] = self:cal_sum_pro(self.cur_level,'crit_level')
		end

		if max_hp >0 then
			pros['max_hp'] = max_hp
			pros_sum['sum-max_hp'] = self:cal_sum_pro(self.cur_level,'max_hp')
		end

		if defense >0 then
			pros['defense'] = defense
			pros_sum['sum-defense'] = self:cal_sum_pro(self.cur_level,'defense')
		end

	end
	if cur_level + 1 > 80 then
		local bf_level = self.proft_high_order*100000+(cur_level - 1)
		local bf_lv_data = data.avatar_strengthen[bf_level]
		if bf_lv_data ~= nil then
			local attack = bf_lv_data.attack
			local crit_level = bf_lv_data.crit_level
			local max_hp  = bf_lv_data.max_hp
			local defense = bf_lv_data.defense
			
			if attack >0  then
				pros_sum['sum-attack'] = self:cal_sum_pro(self.cur_level,'attack')
			end

			if crit_level >0 then
				pros_sum['sum-crit_level'] = self:cal_sum_pro(self.cur_level,'crit_level')
			end

			if max_hp >0 then
				pros_sum['sum-max_hp'] = self:cal_sum_pro(self.cur_level,'max_hp')
			end

			if defense >0 then
				pros_sum['sum-defense'] = self:cal_sum_pro(self.cur_level,'defense')
			end

		end
		self:set_proficient_level(cur_level)
		self:set_prof_pro(pros,pros_sum)
		self:set_price()
		self.lbl_tips:setString(cur_level ..'级已超神！')
		self:show_common_panel()
		return
	else
	--设置附加的属性lbl和图标显示
		self:set_prof_pro(pros,pros_sum)
	end
	--遇到用到物品，代表用到进阶面板
	if data.avatar_strengthen[will_level].item_id == nil then
		--设置价钱
		local gold = data.avatar_strengthen[will_level].gold

		self.need_gold = gold
		self:set_price( gold )
		local adv_level = (self:getIntPart(cur_level/10)+1)*10
		self.advanced_level = adv_level
		if adv_level < 80 then
			--self.lbl_tips:setString(adv_level ..'级可以进阶')
			self.lbl_tips:setString(locale.get_value_with_var('prof_tips',{times = adv_level+1}))
		else
			--self.lbl_tips:setString(adv_level ..'级超越众神')
			self.lbl_tips:setString(locale.get_value_with_var('prof_end_tips',{times = adv_level}))
		end

		--显示普通界面00
		--self[self.proft_img_name .. '_button']:getChildByName('up_img'):setVisible(false)
		self:show_common_panel()



	else
		--设置需要物品名字，和数量
		local idx = data.avatar_strengthen[will_level].item_id
		
		self.item_number = self:get_item_oid_number(idx)
		if self.item_number == nil then
			self.item_number = 0
		end

		local item_name = data.material[idx].name
		local item_img = data.material[idx].icon
		self:set_item_name(item_name,self.item_number)
		self:set_item_img(item_img)
		local next_level = cur_level+10
		self:set_advanced_tips(next_level)
		--显示进阶界面\
		--self[self.proft_img_name .. '_button']:getChildByName('up_img'):setVisible(true)

		self:show_advanced_panel()
	end

end

--获取物品数量
function proficient_layer:get_item_oid_number( idx )
	local player = model.get_player()
	local items = player:get_items()
	local item_number = 0
	for _, v in pairs(items) do
		if v.id == idx then
			item_number = v:get_number()
		end
	end
	return item_number
end

--设置显示下一等级数
function proficient_layer:set_proficient_level( level )
	local lv = level
	self.lbl_level:setString('Lv: '.. lv)
	local level_name = math.abs(self:getIntPart((level-1)/10)+1)*10
	if level_name >= 80 then
		level_name = 80
	end
	self.lbl_proficient_level:setString(locale.get_value('prof_level_'..level_name))
	if level >= 80 then
		self.lbl_add_level:setVisible(false)
		return
	end
	self.lbl_add_level:setVisible(true)
	self.lbl_add_level:setPositionX(self.lbl_level:getPositionX()+self.lbl_level:getContentSize().width)
end

--设置精通类型图标
function proficient_layer:set_proficient_img( name )
	self:get_widget('title_icon'):loadTextureNormal('prof_'.. name ..'.png',load_texture_type)
end

--设置精通类型的标题
function proficient_layer:set_proficient_name( name )
	self.lbl_proficient_name:setString(name)
end


--设置显示的附加属性显示
function proficient_layer:set_prof_pro( pros , pros_sum )

	local i = 0
	local j = 0
	self.lbl_pro_1_value:setVisible(false)
	self.lbl_pro_2_value:setVisible(false)
	self.lbl_pro_1_add_value:setVisible(false)
	self.lbl_pro_2_add_value:setVisible(false)
	self.pro_1_img:setVisible(false)
	self.pro_2_img:setVisible(false)
	self.model = model.get_player()
	self.model:init_combat_attr()
	local player_attr = self.model.final_attrs
	for k,v in pairs(pros_sum) do
		
		j = j + 1
		local label = string_split(k,'-')
		local pro_name= label[2]
		local cur_value = self['lbl_pro_' .. j ..'_value']
		cur_value:setVisible(true)
		local sum_pro_name = k
		local sum_pro_value = pros_sum[sum_pro_name]
		cur_value:setString(''.. sum_pro_value)
		self['pro_'.. j ..'_img']:setVisible(true)
		self['pro_'.. j ..'_img']:loadTexture('prof_'.. pro_name ..'.png',load_texture_type)
		if pros[pro_name]~=nil and pros[pro_name] > 0 then
			i = i + 1 	
			local add_value = self['lbl_pro_' .. i ..'_add_value']
			add_value:setVisible(true)
			add_value:setString('+'.. pros[pro_name])
			local width_1 = cur_value:getContentSize().width
			add_value:setPositionX(cur_value:getPositionX()+width_1)

		end
	end
end

--设置价钱
function proficient_layer:set_price( gold )
	local player = model.get_player()
	if gold == nil or gold <= 0 then
		self.lbl_gold:setString('已达到顶级')
		return
	end
	if player:get_money() >= gold then
		self.lbl_gold:setColor(Color.White)
	else
		self.lbl_gold:setColor(Color.Red)
	end
	self.lbl_gold:setString(''.. gold)
end

--设置物品图标
function proficient_layer:set_item_img( file )
	self:get_widget('Image_28'):loadTexture(file,load_texture_type)
end

function proficient_layer:set_item_name( name ,number )
	self.lbl_item_name:setString(' '..name..'('.. number ..'/1)')
end

function proficient_layer:set_advanced_tips( level )

	self.lbl_advanced_tips:setString(locale.get_value_with_var('prof_advanced_tips',{times = level-10+1})..locale.get_value('prof_level_'..level) ..'天赋')
end

--变灰
function SpriteSetGray(sprite,num)

	local gl_state = cc.GLProgramState:create(cc.GLProgram:createWithFilenames('shaders/ccShader_PositionTextureColor_noMVP.vert','shaders/ccFilterShader_saturation.frag'))
	gl_state:setUniformFloat('u_saturation',num)
	sprite:setGLProgramState(gl_state)
end

--检查按钮是不是可以控
function proficient_layer:chech_button_state(  )
	local player = model.get_player()
	local player_lv = player:get_level()

	if player:get_money() >= self.need_gold and self.cur_level < 80 then
		self.prom_button:setTouchEnabled(true)
		self.quick_prom_button:setTouchEnabled(true)
		SpriteSetGray(self.quick_prom_button:getVirtualRenderer(),1)
		SpriteSetGray(self.prom_button:getVirtualRenderer(),1)

	else
		self.prom_button:setTouchEnabled(false)
		self.quick_prom_button:setTouchEnabled(false)
		SpriteSetGray(self.quick_prom_button:getVirtualRenderer(),0.3)
		SpriteSetGray(self.prom_button:getVirtualRenderer(),0.3)
	end

	if self.item_number == nil then
		self.item_number = 0
	end
	if self.item_number >= 1 and self.cur_level < 80 and player_lv > self.cur_level then
		self.advanced_button:setTouchEnabled(true)
		SpriteSetGray(self.advanced_button:getVirtualRenderer(),1)
	else
		self.advanced_button:setTouchEnabled(false)
		SpriteSetGray(self.advanced_button:getVirtualRenderer(),0.3)
	end

end


function proficient_layer:calculate_quick_gold(  )

	local end_level = self.proft_high_order*100000+self.advanced_level
	local sum = 0
	for i=self.will_level,end_level do
		sum = sum + data.avatar_strengthen[i].gold
	end

	return sum 

end



--显示普通面板
function proficient_layer:show_common_panel(  )
	self:get_widget('Panel_26'):setVisible(false)
	self:get_widget('Panel_41'):setVisible(true)
	

end

--显示进阶面板
function proficient_layer:show_advanced_panel(  )

	self:get_widget('Panel_26'):setVisible(true)
	self:get_widget('Panel_41'):setVisible(false)
end

function proficient_layer:play_tx(  )
	local player = model.get_player()
	local strength_pros = player:get_strength_lv()	

	local prof_type = EnumProficientTypes[self.proft_img_name]
	local cur_level = strength_pros[prof_type] --当前要精通的属性
	local will_level = prof_type*100000+(cur_level)
	local gold 
	local idx 
	local will_lv_data = data.avatar_strengthen[will_level]
	self:check_fc()
	if will_lv_data ~= nil then
		gold = will_lv_data.gold
		idx = will_lv_data.item_id
	end

	if idx ~= nil then 

		local ly = self:get_widget('six_star_img')
		local tx = proficient_tx.proficient_tx()
		tx.cc:setLocalZOrder(110000000)
		self.cc:addChild(tx.cc,110000000)

		local ly_pos = ly:getWorldPosition()
		local icn = self:get_widget(self.proft_img_name..'_button')
		local icn_pos = icn:getWorldPosition()
		tx:play_jj_anim(ly_pos,icn_pos)
		
	else
		local ly = self:get_widget('six_star_img')
		local tx = proficient_tx.proficient_tx()
		tx.cc:setLocalZOrder(110000000)
		self.cc:addChild(tx.cc,110000000)
		local ly_pos = ly:getWorldPosition()
		tx:play_sj_anim(ly_pos)
		

	end
end

function proficient_layer:player_sel_tx(  )
	if self.sel_tx == nil then
		self.sel_tx = proficient_sel_tx.proficient_sel_tx()
		self.cc:addChild(self.sel_tx.cc)
	end
	
	local icn = self:get_widget(self.proft_img_name..'_button')
	local icn_pos = icn:getWorldPosition()
	self.sel_tx:play_sel_anim(icn_pos.x,icn_pos.y)
	self.sel_tx.cc:setLocalZOrder(10)
end

function proficient_layer:check_fc()
	if self.fc == nil then
		return
	end
	local new_fc = math.modf(model.get_player().final_attrs:get_fighting_capacity())
	if new_fc ~= self.fc then
		msg_queue.add_battle_msg(new_fc - self.fc)
	end
	self.fc = new_fc
end

function proficient_layer:set_bottom_img( btn )
	local posx,posy = btn:getPosition()
	self.btn_bottom_img:setPosition(posx,posy)
end


function proficient_layer:reload(  )
	super(proficient_layer,self).reload()
	self:reload_json()
	self:updata_button()
	self:updata_player_info()
	self:update_right_panel()
	self:chech_button_state()
	-- ui_mgr.schedule_once(0, self, self.updata_button)
	-- ui_mgr.schedule_once(0.1, self, self.updata_player_info)
	-- ui_mgr.schedule_once(0.2, self, self.update_right_panel)
	-- ui_mgr.schedule_once(0.3, self, self.chech_button_state)
end

function proficient_layer:release(  )
	-- body
	if self.sel_tx ~= nil then
		self.sel_tx:release()
	end
	self.is_remove = false
	cc.SpriteFrameCache: getInstance(): removeSpriteFramesFromFile( icon_set )
	super(proficient_layer,self).release()
end
