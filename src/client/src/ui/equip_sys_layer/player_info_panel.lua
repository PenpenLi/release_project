
local char				= import( 'world.char' )
local entity			= import( 'world.entity' )
local char				= import( 'world.char' )
local model 			= import( 'model.interface' )
local music_mgr			= import( 'world.music_mgr' )
local combat_conf		= import( 'ui.equip_sys_layer.equip_ui_cont' )
local layer				= import( 'world.layer' )
local locale			= import( 'utils.locale' )
local combat			= import( 'model.combat' )
local msg_queue 		= import( 'ui.msg_ui.msg_queue' )
local ui_mgr			= import( 'ui.ui_mgr' )

player_info_panel = lua_class('player_info_panel')
local eicon_set = 'icon/e_icons.plist'
local load_texture_type = TextureTypePLIST
local _icon_img_tag					= 10


function player_info_panel:_init( layer )
	
	self.layer = layer
--隐藏红点
	for _, equip_type in pairs(EnumEquip) do
		local cell = self.layer:get_widget(equip_type..'_cell')
		local redpos = cell:getChildByName('red_position')
		redpos:setVisible(false)
	end

	
	
	--玩家等级 经验设置
	self:init_level_exp()
	self.layer:get_lbl_with_name('lbl_panel_attack'):setString( locale.get_value('role_capacity')..':' .. self:getIntPart(model.get_player().final_attrs:get_fighting_capacity()))

	ui_mgr.schedule_once(0, self, self.first_init)
end 

function player_info_panel:first_init()
	local shadow_widget = self.layer:get_widget('role_shadow') ---阴影的位置，用于拿取坐标显示玩家
	--点击换动作的触摸范围的设置
	local player_pos = shadow_widget:getWorldPosition()
	local clickable_size = {width = 160, height = 220 }
	self.char_layer_x1 = player_pos.x - clickable_size.width/2
	self.char_layer_x2 = player_pos.x + clickable_size.width/2
	self.char_layer_y1 = player_pos.y 
	self.char_layer_y2 = player_pos.y + clickable_size.height
	--主角动画
	local player = model.get_player()
	print('名字：',player.role_type)

	local conf = import('char.'..player.role_type) 
	self.player = self:add_char()					--加载玩家动画信息
	shadow_widget:addChild(self.player.cc)			--然后把玩家动画加到这个阴影上
	shadow_widget:setLocalZOrder(11111)
	shadow_widget:setAnchorPoint(cc.p(0.5, 0.5))	--设置阴影的锚点
	self.player.cc:setAnchorPoint(cc.p(0.5, 0))		--设置玩家的锚点在脚下。底边中点
	local shadow_size = shadow_widget:getLayoutSize()	--获取阴影的大小
	self.player.cc:setPosition(shadow_size.width/2-10,shadow_size.height*2/3)	--设置玩家位置

	--正在使用的装备
	self.equip_table = {}

	-- for  i=1, 6 do
	-- 	table.insert(self.equip_table,self.layer:get_widget(string.format("cell_%d", i)))
	-- end

	--local weapon = 
	--一进装备面板，就选中人物格子的武器

	self.sel_type = EnumEquip.equip_type_weapon
	--人物旁边六个格子加载图片

	self:equip_cell_check( )
	self:update_panel()
end

function player_info_panel:init_level_exp(  )
	local player = model.get_player()
	local level = player:get_level()
	self.layer:get_lbl_with_name('lbl_role_level'):setString(locale.get_value('role_role_level') .. ' '.. level)
	self.cur_need_exp = data.level[player.level].exp
	self.cur_exp = player.exp
	local bef_level = player.level-1
	local bef_exp = 0
	if bef_level > 0 then
		bef_exp = data.level[player.level-1].sum_exp
	end
	self.cur_view_exp = self.cur_exp - bef_exp
	self.layer:get_lbl_with_name('lbl_role_exp'):setString(self.cur_view_exp ..'/'.. self.cur_need_exp)
end


-- 添加玩家动画
function player_info_panel:add_char()
	--TODO: 换成配置的import文件
	local player = model.get_player()


	local conf = import('char.'..player.role_type) 
	local entity_anim = char.char(conf)
	entity_anim.cc:setLocalZOrder(11110)

	local player = model.get_player()
	entity_anim:change_equip(entity_anim.equip_conf.weapon, player:get_wear('weapon'))
	entity_anim:change_equip(entity_anim.equip_conf.helmet, player:get_wear('helmet'))
	entity_anim:change_equip(entity_anim.equip_conf.armor, player:get_wear('armor'))

	self.animset = {}			--用来放不同状态名字key对应的动画table
	self.cur_anim_key = '' 
	self.first_key = 'idle'
	self.first_anim = nil

	for k, v in pairs(conf) do
		if type(v) == 'table' and v.anim ~= nil
	   and (k == 'attack' or k == 'idle' or k == 'run') then
			if self.first_anim == nil then
				self.first_key = k
				self.first_anim = v.anim
			end
			self.animset[k] = v.anim
			self.cur_anim_key = k
		end
	end
	--让玩家播放一下动画
	entity_anim:play_anim(self.animset[self.cur_anim_key])

	local function click_began(sender, eventType)

		-- 点击角色切换动作 点击某个区域，就切换动作
		local touch_pos = sender:getLocation()
		if touch_pos.x > self.char_layer_x1 and touch_pos.x < self.char_layer_x2
		and touch_pos.y > self.char_layer_y1 and touch_pos.y < self.char_layer_y2 then
			self:alter_anim()
		end
	end

	local function char_click(sender, eventType)
		print('click end')
	end

	local listener1 = cc.EventListenerTouchOneByOne:create()
	listener1:setSwallowTouches(true)
	-- listener1:registerScriptHandler(char_click, cc.Handler.EVENT_TOUCH_BEGAN )
	--设置click_began函数绑定触摸监听器
	listener1:registerScriptHandler(click_began, cc.Handler.EVENT_TOUCH_BEGAN )
	listener1:registerScriptHandler(char_click, cc.Handler.EVENT_TOUCH_ENDED )
	local eventDispatcher = self.layer.cc:getEventDispatcher()
	--监听器就附到动画层身上。
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, entity_anim.cc)
	--返回动画层
	return entity_anim
end

function player_info_panel:play_first_anim()
	self.player:play_anim(self.animset['idle'])
end



---点击换主角的动画
function player_info_panel:alter_anim()
	local flag = false
	local next_key = self.cur_anim_key
	local next_anim = nil
	for k, v in pairs(self.animset) do
		if flag == true then
			next_key = k
			next_anim = v
			break
		end
		if flag == false and self.cur_anim_key == k then
			flag = true
		end
	end
	if self.cur_anim_key == next_key and self.first_anim ~= nil then
		self.player:play_anim(self.first_anim)
		self.cur_anim_key = self.first_key
	elseif next_anim ~= nil then
		self.player:play_anim(next_anim)
		self.cur_anim_key = next_key
	end
end

function player_info_panel:equip_cell_check(  )
	-- body

	local player = model.get_player()
	for _, equip_type in pairs(EnumEquip) do

		self.wearing_icon = player:get_wear(equip_type):get_icon()
		self.wearing_color = player:get_wear(equip_type):get_color()
		local cell = self.layer:get_widget(equip_type..'_cell')
		self[equip_type..'_cell'] = cell
		--加载已装相应装备的图片
		cc.SpriteFrameCache: getInstance(): addSpriteFrames( eicon_set )
		local equip = ccui.ImageView:create()
		print('物品图标',self.wearing_icon)
		equip:loadTexture( self.wearing_icon,load_texture_type)
		equip:setPosition( 0, 0 )
		equip:setAnchorPoint( 0, 0 )
		cell:addChild(equip,0)
		equip:setTag(_icon_img_tag)

		--设置边框颜色
		self:set_cell_level(cell,self.wearing_color)

		self:set_red_pos(cell,equip_type)

		local  function selected_event( sender,eventType )
			music_mgr.ui_click()
			if eventType == ccui.CheckBoxEventType.selected then
				---恢复字体颜色
				----------
				self.layer:get_equipment_list_panel():set_cur_wearing_type( equip_type )
				sender:setTouchEnabled(false)
				self.layer:get_equipment_list_panel():update_equip_list()
				--self.layer:get_equipment_list_panel():check_show_table()
				--更新右栏的文字显示
				self:set_equip_title( equip_type )

				self.sel_cell:setSelectedState(false)
				self.sel_cell:setTouchEnabled(true)
				self.sel_cell = cell
				self.sel_type = equip_type

			elseif eventType == ccui.CheckBoxEventType.unselected then
				sende:setTouchEnabled(true)
			end
		end

		if self.sel_type == equip_type then
			cell:setSelectedState(true)
			cell:setTouchEnabled(false)
			self.sel_cell = cell
		end
		cell:setTag(equip_type)
		cell:addEventListener(selected_event)


	end
end

function player_info_panel:set_red_pos(cell,equip_type)
	local redpos = cell:getChildByName('red_position')
	local cur_type = equip_type

	self.equip_keys = {}
	local player = model.get_player()
	self.cur_wearing_idx = player:get_wear(cur_type):get_id()
	local player_lv = player:get_level()
	local equips = player:get_equips()
	for id, it in pairs(data[cur_type]) do
		if player_lv >=  it.Lv  then
	 		
			if equips[tostring(id)] == nil and id ~= self.cur_wearing_idx then
				local cur_num = player:get_one_equip_frag(it.color..'_'..cur_type)
				local need_num  =  data.equipment_activation[it.color..'_'..cur_type]
				if cur_num >= need_num then
					redpos:setVisible(true)
					return
				end
				
			end
		end

	end
	redpos:setVisible(false)
	
end


function player_info_panel:release(  )
	self.player:release()
end

function player_info_panel:get_player( )
	return self.player
end

--更新标题
function player_info_panel:set_equip_title( equip_type )
	--更新右栏的文字显示
	self.layer:get_equipment_list_panel():set_equip_title(locale.get_value('role_lbl_'..equip_type))
end

function player_info_panel:update_cell_View( cell ,file , color )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( eicon_set )
	if cell:getChildByTag(_icon_img_tag) ~= nil then
		cell:removeChildByTag(_icon_img_tag)
	end
	--加入图片
	local view = ccui.ImageView:create()
	view:loadTexture( file,load_texture_type)
	view:setAnchorPoint(cc.p(0, 0))
	view:setTag(_icon_img_tag)
	cell:addChild(view, 0)
	--设置边框颜色
	self:set_cell_level(cell,color)
end

function player_info_panel:update_panel()

	self:play_first_anim()
	self:updata()
	self:update_red_pos()
end

-- 角色属性更新
function player_info_panel:updata()

	local player = model.get_player()
	self.layer:get_lbl_with_name('lbl_panel_attack'):setString( locale.get_value('role_capacity')..':' .. self:getIntPart(player.final_attrs:get_fighting_capacity()))
	self.layer:get_txt_with_name('txt_max_hp'):setString(self:getIntPart(player.final_attrs.max_hp))
	self.layer:get_lbl_with_name('txt_attack'):setString(self:getIntPart(player.final_attrs.attack))
	self.layer:get_lbl_with_name('txt_defense'):setString(self:getIntPart(player.final_attrs.defense))
	self.layer:get_lbl_with_name('txt_crit_level'):setString(self:getIntPart(player.final_attrs.crit_level))
end

--更新检查红点
function player_info_panel:update_red_pos( )
	self:set_red_pos(self.sel_cell,self.sel_type)
end

--设置等级
function player_info_panel:set_cell_level(cell,level )
	if level == EnumLevel.White then
		
		cell:getChildByName('green'):setVisible(false)
		cell:getChildByName('blue'):setVisible(false)
		cell:getChildByName('purple'):setVisible(false)
		cell:getChildByName('orange'):setVisible(false)
	elseif level == EnumLevel.Green then
		
		cell:getChildByName('green'):setVisible(true)
		cell:getChildByName('blue'):setVisible(false)
		cell:getChildByName('purple'):setVisible(false)
		cell:getChildByName('orange'):setVisible(false)
	elseif level == EnumLevel.Blue then
		
		cell:getChildByName('green'):setVisible(false)
		cell:getChildByName('blue'):setVisible(true)
		cell:getChildByName('purple'):setVisible(false)
		cell:getChildByName('orange'):setVisible(false)
	elseif level == EnumLevel.Purple then
		
		cell:getChildByName('green'):setVisible(false)
		cell:getChildByName('blue'):setVisible(false)
		cell:getChildByName('purple'):setVisible(true)
		cell:getChildByName('orange'):setVisible(false)
	elseif level == EnumLevel.Orange then
		
		cell:getChildByName('green'):setVisible(false)
		cell:getChildByName('blue'):setVisible(false)
		cell:getChildByName('purple'):setVisible(false)
		cell:getChildByName('orange'):setVisible(true)
	else
		--print('没有这个等级')
	end
end

function player_info_panel:getIntPart( x )
	-- body

	return math.floor(x+0.5)
end





--获取人物周边六个格仔当前选中格仔
function player_info_panel:get_sel_cell(  )
	return self.sel_cell
end
