local model 				= import( 'model.interface' )
local char					= import( 'world.char' )
local layer					= import( 'world.layer' )
local main_map				= import( 'ui.main_map' )
local soul_cont_panel		= import( 'ui.soul_system.soul_cont_panel' )
local ui_mgr 				= import(  'ui.ui_mgr' ) 
local soul_page_panel 		= import( 'ui.soul_system.soul_page_panel' )
local ui_const 				= import( 'ui.ui_const' )
local soul_tx 				= import('ui.soul_system.soul_tx')

soul_info_panel = lua_class( 'ui.soul_system.soul_info_panel' ,layer.ui_layer )


local load_texture_type = TextureTypePLIST
local _json_path = 'gui/main/ui_soul_info.ExportJson'

function soul_info_panel:_init(  )
	
	super(soul_info_panel,self)._init(_json_path,true)
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2 ,VisibleSize.height/2)

	self.shadow_widget = self:get_widget('shadow')
	local player_pos = self.shadow_widget:getWorldPosition()
	local clickable_size = {width = 250, height = 220 }
	self.char_layer_x1 = player_pos.x - clickable_size.width/2
	self.char_layer_x2 = player_pos.x + clickable_size.width/2
	self.char_layer_y1 = player_pos.y 
	self.char_layer_y2 = player_pos.y + clickable_size.height

	self:init_skill_data()
	--经验
	self:init_exp()
	--是否显示介绍界面
	self.show_list = false

	--星星等级
	self.star_level = self:get_widget( 'Image_23' )

	--描边
	self:get_widget('Label_13'):enableOutline(ui_const.UilableStroke, 2)
	self:get_widget('lbl_frag_sount'):enableOutline(ui_const.UilableStroke, 2)
	self:get_widget('Label_7'):enableOutline(ui_const.UilableStroke, 2)
	--介绍按钮
	self.intro_button = self:get_widget( 'Button_35' )
	self.intro_button:setVisible(false)
	self:set_handler('Button_35', self.intro_button_event)
	--按钮	
	self.back_button  = self:get_widget('Button_25')
	self:set_handler('Button_25', self.back_button_event)

	-- self.help_button  = self:get_widget('Button_9')
	-- self:set_handler('Button_9', self.help_button_event)

	self:set_handler('guide_button', self.guide_tips_event)

	self.star_button = self:get_widget('Button_6')
	self:set_handler('Button_6', self.up_star_event)

	--灵魂进度条
	self.frag_bar = self:get_widget('soul_frag_bar')
	self.lbl_frag_count = self:get_widget('lbl_frag_sount')


	--是否移除 取动画，去data里面数据，是本地exl表
	self.is_remove = false


	--测试
	self:update_frag_bar()
	self:reload( )

end

function soul_info_panel:init_skill_data(  )
	local avatar = model.get_player()
	self.skills = avatar:get_skills()
	local skill_id = soul_page_panel.get_skill_id()
	self.skill_id = skill_id
	self.skill_data = self.skills[self.skill_id]
end

function soul_info_panel:init_exp( )
	self.lbl_exp = self:get_widget('Label_16')
	self.level = self.skill_data:get_level()
	self.sum_exp = self.skill_data:get_exp()
	local bef_level = self.level-1
	if self.level >=80 then
		self.lbl_exp:setString('等级已到满')
		return
	end
	if bef_level > 0 and self.level <80 then
		local player = model.get_player()
		local player_lv =player:get_level() 
		if self.level ~= player_lv then
			local show_exp = self.sum_exp - data.soul_upgrade[bef_level].sum_exp
			if show_exp >= data.soul_upgrade[self.level].exp then
				show_exp = show_exp - data.soul_upgrade[self.level].exp
				self.lbl_exp:setString(''.. show_exp .. '/' .. data.soul_upgrade[self.level].exp)
			else
				self.lbl_exp:setString(''.. show_exp .. '/' .. data.soul_upgrade[self.level].exp)
			end
		else
			local show_exp = self.sum_exp - data.soul_upgrade[bef_level].sum_exp

			self.lbl_exp:setString(''.. show_exp .. '/' .. data.soul_upgrade[self.level].exp)
			
		end
		
	else

		self.lbl_exp:setString(''.. self.sum_exp .. '/' .. data.soul_upgrade[self.level].exp)
	end
end


function soul_info_panel:update_soul_info(  )
	self:reload_json()
	local skill_id = soul_page_panel.get_skill_id()
	local avatar = model.get_player()
	self.skills = avatar:get_skills()
	self.skill_id = skill_id
	if self.entity_anim == nil then
		self:update_anim(self.skills[skill_id].data.anim)
	end
	-- 星级
	if self.star_anim == nil then
		self:set_star_level( self.skills[skill_id].data.star )
	end
	-- 等级
	self:set_level( self.skills[skill_id].lv )
	--设置名称
	self:set_name( self.skills[skill_id].data.name )
	self:update_list(  )
end

function soul_info_panel:update_anim( file_name )
	

	self.conf = import('char.' .. file_name)
	self.entity_anim = char.char(self.conf)
	self.entity_anim.cc:setLocalZOrder(3)
	self.animset = {}			--用来放不同状态名字key对应的动画table
	self.cur_anim_key = '' 
	self.first_key = 'idle'
	self.first_anim = nil

	for k, v in pairs(self.conf) do
		if type(v) == 'table' and v.anim ~= nil
	   and (k == 'idle' or k == 'attack' or  k == 'run') then
			if k == 'idle' then
				self.first_key = k
				self.first_anim = v.anim
				
				self.cur_anim_key = k
				print(self.cur_anim_key)
			end
			self.animset[k] = v.anim

		end
	end

	self.entity_anim:play_anim(self.animset[self.cur_anim_key])
	if self.conf.boss == true then
		self.entity_anim.cc:setScale(0.55)
	else
		self.entity_anim.cc:setScale(0.8)
	end

	self.entity_anim.cc:ignoreAnchorPointForPosition(true)
	self.shadow_widget:setAnchorPoint(cc.p(0.5, 0.5))	--设置阴影的锚点
	self.entity_anim.armature:setAnchorPoint(cc.p(0.5, 0))	
	local shadow_size = self.shadow_widget:getLayoutSize()	--获取阴影的大小
	self.entity_anim.cc:setPosition(shadow_size.width/2,shadow_size.height*2/4)	--设置玩家位置
	self.shadow_widget:addChild(self.entity_anim.cc)

	local function click_began(sender, eventType)

		-- 点击角色切换动作 点击某个区域，就切换动作
		local touch_pos = sender:getLocation()
		if touch_pos.x > self.char_layer_x1 and touch_pos.x < self.char_layer_x2
		and touch_pos.y > self.char_layer_y1 and touch_pos.y < self.char_layer_y2 then
			self:alter_anim()
		end
	end


	local listener1 = cc.EventListenerTouchOneByOne:create()
	listener1:setSwallowTouches(true)
	listener1:registerScriptHandler(click_began, cc.Handler.EVENT_TOUCH_BEGAN )
	local eventDispatcher = self.cc:getEventDispatcher()
	--监听器就附到动画层身上。
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, self.entity_anim.cc)
end

---点击换魔灵的动画
function soul_info_panel:alter_anim()

	local next_key = self.cur_anim_key
	local next_anim = nil
	for k, v in pairs(self.animset) do
		if self.cur_anim_key == 'idle' and k == 'run' then
			next_key = k
			next_anim = v
			break
		end
		if self.cur_anim_key == 'run' and k == 'attack' then
			next_key = k
			next_anim = v
			break
		end
		if self.cur_anim_key == 'attack' and k == 'idle' then
			next_key = k
			next_anim = v
			break
		end
	end

	self.entity_anim:play_anim(next_anim)
	self.cur_anim_key = next_key

end

function soul_info_panel:set_star_level( level )
	self:reload_json()
	for i=1,5 do
		if i <= level then
			local widget_name = 'star_'..i
			self:get_widget(widget_name):setVisible(true)
			if i == level then
				return
			end
			
		end
		
	end
	
end


function soul_info_panel:back_button_event( sender, eventType )
	if eventType == ccui.TouchEventType.ended then

		sender:setTouchEnabled(false)
		--self.cc:setVisible(false)
		local soul_page = ui_mgr.get_ui('soul_page_panel')
		soul_page.cc:setVisible(true)
		--soul_page:update_page()
		self.is_remove = true
	elseif eventType == ccui.TouchEventType.canceled then
			
	end
end

function soul_info_panel:help_button_event( sender, eventType )
	
	--按下去就移除介绍
	-- if eventType == ccui.TouchEventType.began then

	-- 	self:get_widget('list'):removeAllChildren()
	-- 	self.show_list = true
	-- 	self:update_star_info(  )

 -- 	elseif eventType == ccui.TouchEventType.ended then
 -- 	--松开就显示介绍
 -- 			self:get_widget('list'):removeAllChildren()
	-- 		self:update_list( )
	-- 		self.show_list = false

	-- elseif eventType == ccui.TouchEventType.canceled then
	-- 		self:get_widget('list'):removeAllChildren()
	-- 		self:update_list( )
	-- 		self.show_list = false
	-- end
end 
function soul_info_panel:intro_button_event( sender, eventType )
 	if eventType == ccui.TouchEventType.ended then

		sender:setTouchEnabled(false)
		self:update_list(  )
		self.intro_button:setVisible(false)
		self.help_button:setTouchEnabled(true)
	elseif eventType == ccui.TouchEventType.canceled then
			
	end
end 

function soul_info_panel:guide_tips_event( sender, eventType )
	if eventType == ccui.TouchEventType.ended then
		self.guide_tips_layer = ui_mgr.create_ui(import('ui.guide_tips_layer.guide_tips_layer'), 'guide_tips_layer')
		local soul_stone_id = data.soul_stone_map[tonumber(self.skill_id)]
		self.guide_tips_layer:gain_from(soul_stone_id)
	end
end


--设置等级
function soul_info_panel:set_level( level )
	self:get_widget('Label_15'):setString('等级 : ' .. level)
end

--设置怪物名字
function soul_info_panel:set_name( name )
	self:get_widget('Label_13'):setString(name)
end

function soul_info_panel:update_list(  )
	self:reload_json()
	local length = #self:get_widget('list'):getChildren()
	if length > 0 then
		self:get_widget('list'):removeAllChildren()
	end
	local panel1 = soul_cont_panel.soul_cont_panel(self,'jieshao',self.skill_id)
	local cell = panel1:get_panel()
	self:get_widget('list'):addChild(cell)

	local panel2 = soul_cont_panel.soul_cont_panel(self,'starinfo',self.skill_id)
	local cell2 = panel2:get_panel()
	self:get_widget('list'):addChild(cell2)

	local panel3 = soul_cont_panel.soul_cont_panel(self,'binding',self.skill_id)
	local cell3 = panel3:get_panel()
	self:get_widget('list'):addChild(cell3)
end


function soul_info_panel:update_star_info(  )
	self:reload_json()
	local panel1 = soul_cont_panel.soul_cont_panel(self,'starinfo',self.skill_id)
	local cell = panel1:get_panel()
	self:get_widget('list'):addChild(cell)
end

function soul_info_panel:update_frag_bar(  )
	--碎片
	local avatar = model.get_player()
	local soul_frag = avatar:get_soul_frag()
	local skills = avatar:get_skills()

	local s_data = skills[self.skill_id]
	local s_level = s_data:get_star()+1
	if s_level > 5 then
		self.frag_bar:setPositionX(self.frag_bar:getContentSize().width)
		self.lbl_frag_count:setString(  '已达到顶级' )
		self.star_button:setVisible(false)
		return
	end
	local cur_frag = soul_frag[self.skill_id]
	local need_frag = data.soul_evolution[s_level].piece
	if cur_frag == nil then
		cur_frag = 0
	end

	if need_frag == nil then
		need_frag = 0
	end
	self.lbl_frag_count:setString(  cur_frag ..'/'.. need_frag )

	--碎片进度条
	local perc = cur_frag/need_frag
	if perc>=1 then
		perc = 1
	end 
	self.frag_bar:setPositionX(self.frag_bar:getContentSize().width*perc)
end

function soul_info_panel:up_star_event( sender, eventType )
	
	if eventType == ccui.TouchEventType.began then



 	elseif eventType == ccui.TouchEventType.ended then
 		local avatar = model.get_player()
		server.skill_up_star(self.skill_id)

	elseif eventType == ccui.TouchEventType.canceled then

	end
end

function soul_info_panel:play_star_anim()
	if self.star_anim == nil then

		self.star_anim = soul_tx.soul_tx()
		self.star_anim.cc:setLocalZOrder(1000000)
		self.cc:addChild(self.star_anim.cc)
		self:reload_json()
		local star_id = self.skills[self.skill_id].data.star
		local img_name = 'star_'..star_id
		local star_img = self:get_widget(img_name)
		local s_pos = star_img:getWorldPosition()
		local e_pos = self.shadow_widget:getWorldPosition()
		local function cb(  )
			self:set_star_level( self.skills[self.skill_id].data.star )
			self.star_anim = nil
		end 
		self.star_anim:play_star_anim(s_pos,e_pos,cb)
		self.star_anim.cc:setLocalZOrder(1000000)
	end
end


function soul_info_panel:release(  )

	self.entity_anim:release()
	self:get_widget('list'):removeAllChildren()
	self.is_remove = false
	super(soul_info_panel, self).release()
end

function soul_info_panel:reload(  )
	super(soul_info_panel,self).reload()
	self:reload_json()
	self:update_soul_info( ) 
	self:update_frag_bar( )
end
