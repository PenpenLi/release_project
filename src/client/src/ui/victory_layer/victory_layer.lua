local layer 			= import('world.layer')
local battle_layer 		= import('world.battle_layer')
local director			= import( 'world.director' )
local operate_cmd 		= import('ui.operate_cmd')
local model 			= import( 'model.interface' )
local state_mgr			= import( 'game_logic.state_mgr' )
local ui_const 			= import( 'ui.ui_const' )


local vir_skill 		= import('ui.victory_layer.vir_skill')
local ui_mgr 				= import( 'ui.ui_mgr' ) 

victory_layer = lua_class('victory_layer',layer.ui_layer)
local eicon_set 	= 'icon/e_icons.plist'
local iicon_set 	= 'icon/item_icons.plist'
local sicon_set 	= 'icon/s_icons.plist'
local soul_set 		= 'icon/soul_icons.plist'
local _to_scene_id 	= nil ---切换场景id
local _lbl_time		= 1.5
local _json_file 	= 'gui/battle/Ui_V.ExportJson'
local _json_name 	= 'Ui_V.ExportJson'
local _box_file 	= 'gui/baoxiang/baoxiang.ExportJson'




function victory_layer:_init(  )
	-- body
	--super(victory_layer,self)._init()
	cc.SpriteFrameCache:getInstance():addSpriteFrames( eicon_set )
	cc.SpriteFrameCache:getInstance():addSpriteFrames( iicon_set )
	cc.SpriteFrameCache:getInstance():addSpriteFrames( soul_set )
	self:create_defeated(  )
	self.is_remove = false
	self.remove_touch = false
	
	self.victory_count = 0
end

function victory_layer:create_defeated(  )
	-- body
	super(victory_layer,self)._init(_json_file,true)
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2,VisibleSize.height/2)



	-- --黑屏

	--先隐藏星星
	for i = 1 , 3 do 
		self:get_widget('star_'..i):setVisible(false)
	end

	--先隐藏升级
	self.lvup_img = self:get_widget('LV')
	self.lvup_img:setVisible(false)

	--钱
	self.lbl_money = self:get_widget('lbl_money')
	--self.lbl_money:setFontName(ui_const.UiLableFontType)
	self.lbl_money:setString('0')


	--宝石
	self.lbl_gem   = self:get_widget('lbl_gem')
	--self.lbl_gem:setFontName(ui_const.UiLableFontType)
	self.lbl_gem:setString('0')


	--玩家经验值
	self.lbl_gain_exp = self:get_widget('lbl_p_exp') 
	--self.lbl_gain_exp:setFontName(ui_const.UiLableFontType)
	self.lbl_gain_exp:setString('0')


	--玩家总经验比
	self.lbl_real_exp = self:get_widget('lbl_real_exp')
	--self.lbl_real_exp:setFontName(ui_const.UiLableFontType)
	--
	--是否飚数字
	self.is_tick = false

	--钱
	self.money = 0
	self.money_count = 0
	self.money_ok = false
	self.money_add = 0

	self.gem = 0
	self.gem_count = 0
	self.gem_ok = false
	self.gem_add = 0

	self.gain_exp = 0
	self.gain_exp_count = 0
	self.gain_exp_ok = false
	self.gain_exp_add = 0

	self.is_calculated = false

	--开一个计时器

	local function t_tick()
		self:tick()
	end
	self.v_tick = cc.Director:getInstance():getScheduler():scheduleScriptFunc(t_tick, 0, false)


	--经验条
	self.exp_bar = self:get_widget('Image_30')
	
	self.bar_length = self.exp_bar:getLayoutSize().width


	self.bef_level 	= 0
	self.bef_need_exp 	= 0
	self.bef_exp 	= 0
	self.cur_level 	= 0
	self.cur_exp 	= 0
	self.gain_exp 	= 0
	self.cur_need_exp 	= 0
	self.jin_count = 0


	--加入宝箱
	self.add_box = false
	self.box = nil

	self.cc:setVisible(false)

	--技能列表
	self.skill_list = self:get_widget('ListView_1')

	--战灵经验
	self.soul_exp = 0

end


function victory_layer:set_bef_attack( att )
	self.bef_attack = att
end

function victory_layer:set_bef_defense( def )
	self.bef_defense = def
end

function victory_layer:set_bef_crit( crit )
	self.bef_crit_level = crit
end

function victory_layer:set_bef_hp( hp )
	self.bef_hp = hp 
end

function victory_layer:set_bef_skills( skill )
	self.bef_skills = skill
end

function victory_layer:set_scene_data( data )
	self.scene_data = data
end
--设置战灵经验
function victory_layer:set_soul_exp( ep )
	self.soul_exp =  ep
end
--初始化技能
function victory_layer:init_skills(  )
	cc.SpriteFrameCache:getInstance():addSpriteFrames( sicon_set )
	local avatar = model.get_player()	
	local cast_skill = avatar:get_loaded_skills()  --装备的技能
	for i=1,6 do
		if cast_skill[i] ~= nil and self.bef_skills[i] ~= nil then
			local cl = vir_skill.vir_skill(self)
			local cell = cl:get_cell()
			self.skill_list:addChild(cell)
			cl:set_head_view(cast_skill[i].data.icon)
			cl:set_level(cast_skill[i].lv)
			cl:set_level_up(self.bef_skills[i],cast_skill[i].lv)
			cl:set_exp(self.soul_exp)
		end
	end
	local sk_count = self:cal_table_lgt(cast_skill)
	if  sk_count <= 0 or sk_count == nil then
		return 
	end
	local cell_width = self:get_widget('vir_sk_msg'):getLayoutSize().width/2
	self.skill_list:setPositionX(self.skill_list:getPositionX()+(cell_width*(6-sk_count)))
	
	

end



--计算技能table长度
function victory_layer:cal_table_lgt( t )
	local i = 0
	for k,v in pairs(t) do
		i = i + 1 
	end

	return i
end

--设置tick
function victory_layer:set_tick( )
	self.is_tick = true

end

--设置钱
function victory_layer:set_money( m )
	if m == nil then
		return
	end
	self.money = math.ceil(m)
	self.money_add = math.ceil(self.money / (_lbl_time*Fps))

end

--设置宝石
function victory_layer:set_gem( g )
	if g == nil then
		return
	end
	self.gem = math.ceil(g)
	self.gem_add = math.ceil(self.gem / (_lbl_time*Fps))
end

--设置获得经验值
function victory_layer:set_gain_exp( e )
	if e == nil then
		return
	end
	--print('获得经验',self.gain_exp)
	self.gain_exp =  math.ceil(e)
	self.gain_exp_add = math.ceil(self.gain_exp / (_lbl_time*Fps))

end

function victory_layer:set_bef_lv( lv )
	self.bef_level = lv
end

function victory_layer:cal_exp_level(  )
	local player  = model.get_player()
	self.cur_need_exp = data.level[player.level].exp
	self.cur_exp  = player.exp
	self.cur_level = player.level
	--print('之前等级和现在',self.bef_level,self.cur_level)

	self.bef_exp  = self.cur_exp - self.gain_exp
	if self.bef_exp < 0 then

		self.bef_exp = 0
	end

	
	self.bef_need_exp = data.level[self.bef_level].exp

	self.bar_seep = self.gain_exp_add

end


function victory_layer:set_items( it )
	self.items = it
end

function victory_layer:update_bar(  )

	-- print('-----------------打印状态·····················')
	-- print('之前等级：',self.bef_level)
	-- print('之前等级升级需要的经验：',self.bef_need_exp)
	-- print('之前总经验：',self.bef_exp)
	-- print('现在等级：',self.cur_level)
	-- print('现在总经验：',self.cur_exp)
	-- print('副本获得经验：',self.gain_exp)
	-- print('当前升级需要的经验：',self.cur_need_exp)

	--以前等级的总经验值
	local temp_level = self.bef_level-1
	--
	if temp_level == 0 then
		self.bef_sum_exp = 0
	else
		self.bef_sum_exp = data.level[self.bef_level-1].sum_exp
	end

	local temp_level2 = self.cur_level-1
	if temp_level2 == 0 then
		self.cur_sum_exp = 0
	else
		self.cur_sum_exp = data.level[self.cur_level-1].sum_exp
	end
	
	--之前状态显示进度条处于的数值

	self.bef_view_exp  = 0 
	if self.bef_exp >= self.bef_sum_exp then
		self.bef_view_exp = self.bef_exp - self.bef_sum_exp
	else
		self.bef_view_exp = self.bef_exp
	end
	--print('以前的经验和以前总：',self.bef_exp,self.bef_sum_exp)

	--现在状态显示进度条处于的数值
	self.cur_view_exp  = 0 
	if self.cur_exp >= self.cur_sum_exp then
		self.cur_view_exp = self.cur_exp - self.cur_sum_exp
	else
		self.cur_view_exp = self.cur_exp
	end

	--设置进度条一开始显示数值
	self.lbl_real_exp:setString(''..self.bef_view_exp .. '/' ..self.bef_need_exp )
	local number = self.bef_view_exp/self.bef_need_exp
	self.exp_bar:setPositionX(0-(self.bar_length-self.bar_length*number))
	--print('初始位置:',-(self.bar_length-self.bar_length*number))
	--开始更新进度条
	self.exp_bar_ok = false

	--显示升级图标
	--print('等级',self.cur_level,self.bef_level)
	if self.cur_level > self.bef_level then
		self.lvup_img:setVisible(true)
	end

end

--更新
function victory_layer:tick(  )
	if self.is_tick == true then
		
		if self.money_ok == false then
			
			if self.money > 0 and self.money_count < self.money then
				self.money_count = self.money_count+self.money_add 
				self.lbl_money:setString(self.money_count)
			end
			if self.money <= self.money_count then
				self.lbl_money:setString('' .. self.money)
				self.money_ok = true
			end
		end


		if self.gem_ok == false then
			
			if self.gem > 0 and self.gem_count < self.gem then
				self.gem_count = self.gem_count+self.gem_add 
				self.lbl_gem:setString(self.gem_count)
			end
			if self.gem <= self.gem_count then
				self.lbl_gem:setString('' .. self.gem)
				self.gem_ok = true
				
			end
		end

		if self.gain_exp_ok == false then
			
			if self.gain_exp > 0 and self.gain_exp_count < self.gain_exp then
				self.gain_exp_count = self.gain_exp_count+self.gain_exp_add 
				self.lbl_gain_exp:setString(self.gain_exp_count)
			end
			if self.gain_exp <= self.gain_exp_count then
				self.lbl_gain_exp:setString('' .. self.gain_exp)
				self.gain_exp_ok = true
				
			end
		end

		if self.exp_bar_ok == false then
					
			self:move_exp_bar()

		end
		
		if self.money_ok == true and self.gem_ok == true and self.gain_exp_ok== true and self.exp_bar_ok == true and self.add_box== false  then
			self.is_calculated = true
			if #self.items ~= 0 then
				self.add_box = true
				local function callFunc( )
					--恢复触摸
					self.box = ui_mgr.create_ui(import( 'ui.victory_layer.vir_box' ), 'vir_box')
					
				end
				local callFuncObj=cc.CallFunc:create(callFunc)
				self.cc:runAction(cc.Sequence:create(cc.DelayTime:create(0.4),callFuncObj))
			end

		end


	end
end


function victory_layer:move_exp_bar( )
	--等级相同
	if self.bef_level == self.cur_level then
		
		self.bef_view_exp = self.bef_view_exp+self.bar_seep
		if self.bef_view_exp >= self.cur_view_exp then
			self.bef_view_exp = self.cur_view_exp
			self.exp_bar_ok = true
		end
		local number = (self.bef_view_exp)/self.bef_need_exp
		self.exp_bar:setPositionX(0-(self.bar_length-self.bar_length*number))
		self.lbl_real_exp:setString(''..self.bef_view_exp .. '/' ..self.bef_need_exp )
	else
	--不同等级就根据等级差，让进度条运行几次
		--相差等级
		local dis_level = (self.cur_level - self.bef_level)+1
		
		if self.jin_count < dis_level-1 then
			local start_level = self.bef_level+self.jin_count
			local temp_need_exp = data.level[start_level].exp
			self.bef_view_exp = self.bef_view_exp+self.bar_seep
			if self.bef_view_exp >= temp_need_exp then
				self.bef_view_exp = 0
				self.exp_bar:setPositionX(-self.bar_length)
				self.jin_count = self.jin_count + 1
			end
			local number = (self.bef_view_exp)/temp_need_exp
			self.lbl_real_exp:setString(''..self.bef_view_exp .. '/' ..temp_need_exp )
			self.exp_bar:setPositionX(0-(self.bar_length-self.bar_length*number))
		
		end

		if self.jin_count == dis_level-1 then
			
			if self.cur_exp >= data.level[self.cur_level-1].sum_exp then
				self.cur_view_exp = self.cur_exp - data.level[self.cur_level-1].sum_exp
			else
				self.cur_view_exp = self.cur_exp
			end
			local start_level = self.cur_level
			local temp_need_exp = data.level[start_level].exp
			self.bef_view_exp = self.bef_view_exp+self.bar_seep
			if self.bef_view_exp >= self.cur_view_exp then
				self.bef_view_exp = self.cur_view_exp
				self.jin_count = self.jin_count + 1
				local function set_exp_bar_ok(  )
					self.exp_bar_ok = true
					
				end

				self.player_up = ui_mgr.create_ui(import('ui.player_up_layer.player_up_layer'), 'player_up_layer')
				self.player_up:set_pro_cont( self.bef_level ,self.bef_attack,self.bef_hp,self.bef_defense,self.bef_crit_level)
				self.player_up:play_start_anim(set_exp_bar_ok)
			end
			local number = (self.bef_view_exp)/temp_need_exp
			self.lbl_real_exp:setString(''..self.bef_view_exp .. '/' ..temp_need_exp )
			self.exp_bar:setPositionX(0-(self.bar_length-self.bar_length*number))
		end
	end


end



function victory_layer:renew_button_callback_event2(  )

	self.cc:setVisible(false)
	--复活满血状态
	local player = model.get_player().entity			--获得玩家
	player.combat_attr:reset_relive( player )			--复活玩家
	director.get_scene():resume()						--恢复更新
	director.enter_battle_scene(1)						--进入到第一个战斗场景
end



--设置显示星星数
function victory_layer:set_star( count )
	if count == 0 or count <=0 then
		return
	end
	for i = 1 , count do 
		self:get_widget('star_'..i):setVisible(true)
	end
end

function victory_layer:reload( )
	super(victory_layer,self).reload()
end




--播放动画
function victory_layer:play_anim()
	self.cc:setVisible(true)
	--director.get_scene():pause()
	local function callFunc(  )
		self:set_tick()
	end
	local callFuncObj=cc.CallFunc:create(callFunc)
	self:play_action(_json_name,'Animation0')
	self:play_action(_json_name,'up',callFuncObj)

end

--移除操作
function victory_layer:release(  )

	print('remove victory_layer')
	-- cc.SpriteFrameCache: getInstance(): removeSpriteFramesFromFile( 'gui/ui_vir/Ui-V0.plist' )
	-- cc.SpriteFrameCache: getInstance(): removeSpriteFramesFromFile( 'gui/ui_vir/Ui-V1.plist' )
	ccs.ArmatureDataManager: getInstance(): removeArmatureFileInfo(_box_file)
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( eicon_set )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( iicon_set )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( sicon_set )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( soul_set )
	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.v_tick)
	--super(victory_layer,self).release()
	self.is_remove = false
	-- body
end


--触摸事件
function victory_layer:touch_begin_event( touch, event )
	-- body
	if self.box ~= nil and self.box:get_open() == true then
		local function call_back(  )
			self.vir_list = ui_mgr.create_ui(import('ui.victory_layer.vir_list'), 'vir_list')
			local function remove_call(  )
				self.vir_list:can_remove()
			end
			local function go_callback(  )
				self.cc:setVisible(false)
				self.vir_list = nil
				self.is_remove = true 
				director.get_scene():resume()
				local ui_queue = ui_mgr.ui_his_dequeue['main_scene']
				if ui_queue ~= nil then
					local top_ui
					for i = 1, 1 do
						top_ui = ui_queue:pop_front()
						if top_ui ~= nil then
							ui_mgr.add_wait_ui('main_scene', top_ui.mod, top_ui.name)
						end
					end
				end
				director.enter_scene(import( 'world.main_scene' ), 'main_scene')
			end 
			self.vir_list:add_items(self.items)
			self.vir_list:play_anim(remove_call)
			self.vir_list:go_to_destination(go_callback)
			self.victory_count = self.victory_count + 1
		end

		self.box:open_box(call_back)
		
	end

	if #self.items == 0 and self.victory_count <= 0 and self.is_calculated == true then
		self.is_calculated = false
		self.victory_count = self.victory_count + 1
		self.is_remove = true  
		local ui_queue = ui_mgr.ui_his_dequeue['main_scene']
		if ui_queue ~= nil then
			local top_ui
			for i = 1, 1 do
				top_ui = ui_queue:pop_front()
				if top_ui ~= nil then
					ui_mgr.add_wait_ui('main_scene', top_ui.mod, top_ui.name)
				end
			end
		end
		director.enter_scene(import( 'world.main_scene' ), 'main_scene')
	end 

end


function victory_layer:touch_move_event( touch, event )

end

function victory_layer:touch_end_event( touch, event )

end

function victory_layer:set_touch_begin_event(func)
	self.touch_begin_event = func
end