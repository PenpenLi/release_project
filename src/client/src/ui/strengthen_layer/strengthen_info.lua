local ui_const 				= import( 'ui.ui_const' )
local model 				= import( 'model.interface' )
local locale				= import( 'utils.locale' )
local ui_mgr 				= import( 'ui.ui_mgr' )
local ui_guide				= import( 'world.ui_guide' )

strengthen_info = lua_class('strengthen_info')
local load_texture_type = TextureTypePLIST
local eicon_set = 'icon/e_icons.plist'

function strengthen_info:_init( layer )
	self.layer = layer
				
	self.goods_view_table 	= nil
	self.goods_view_num		= nil
	self:init_view()
	self:init_lbl()
end

function strengthen_info:init_lbl(  )
	self.lbl_equip_name = self.layer:get_widget('lbl_equip_name')
	self.lbl_next_prop_name = self.layer:get_widget('lbl_next_prop_name')
	self.lbl_prop_name = self.layer:get_widget('lbl_prop_name')
	self.lbl_next_prop_value = self.layer:get_widget('lbl_next_prop_value')
	self.lbl_prop_value = self.layer:get_widget('lbl_prop_value')
	self.lbl_gold = self.layer:get_widget('lbl_gold')
	self.lbl_frag_count = self.layer:get_widget('lbl_frag_count')
	self.strengthen_button = self.layer:get_widget('strengthen_button')

	local function str_btn_event(_, sender,eventtype )
		if eventtype == ccui.TouchEventType.began then
		
		elseif eventtype == ccui.TouchEventType.moved then
	  
		elseif eventtype == ccui.TouchEventType.ended then
			self.layer:set_fc()
			server.strengthen_equip(self.id)
			ui_guide.pass_condition( 'first_eq_strengthen' )
		elseif eventtype == ccui.TouchEventType.canceled then
				
		end
	end 

	local function guide_tips_event(_, sender, eventType )
		if eventType == ccui.TouchEventType.ended then
			local qh_stone_id
			for k, v in pairs(data.equip_qh_stone) do
				if v.color == self.color then
					qh_stone_id = k
					break
				end
			end
			if qh_stone_id ~= nil then
				self.guide_tips_layer = ui_mgr.create_ui(import('ui.guide_tips_layer.guide_tips_layer'), 'guide_tips_layer')
				self.guide_tips_layer:gain_from(qh_stone_id)
			end
		end
	end

	self.layer:set_handler('strengthen_button', str_btn_event)
	self.layer:set_handler('guide_button', guide_tips_event)
end

function strengthen_info:set_info_panel_visible( is_visible )
	self.layer:get_widget('Panel_1'):setVisible(is_visible)
end

--初始化信息框的图片框状态。
function strengthen_info:init_view(  )
	self.goods_view = self.layer:get_widget('equip_view')
	self.goods_view:getChildByName('green'):setVisible(false)
	self.goods_view:getChildByName('blue'):setVisible(false)
	self.goods_view:getChildByName('purple'):setVisible(false)
	self.goods_view:getChildByName('orange'):setVisible(false)
	self.frag_icon = self.layer:get_widget('frag_icon')
	self.frag_bar = self.layer:get_widget('frag_bar')
end


--显示装备信息
function strengthen_info:show_cell_property( equip_id ,good_type )
	cc.SpriteFrameCache:getInstance():addSpriteFrames( eicon_set )
	-- body
	local player = model.get_player()
	local equips = player:get_equips()
	local goods_data = nil

	if equips ~= nil then
		goods_data = equips[tostring(equip_id)]
	else
		goods_data = nil
		return
	end
	if self.goods_view:getChildByTag(10)~=nil then
		self.goods_view:removeChildByTag(10)
	end
	self.goods_view_num = nil
	self.goods_view_table = nil
	self.id = equip_id
	self.eq_level = goods_data:get_level()
	self.color = goods_data:get_color()
	local icon_img = ccui.ImageView:create()
	icon_img:loadTexture( goods_data:get_icon(), load_texture_type )
	icon_img:setPosition( 0, 0 )
	icon_img:setAnchorPoint( 0, 0 )
	self.goods_view:addChild(icon_img,0,10)
	self.goods_view_num=equip_index
	self.goods_view_table = goods_data
	self:init_cell_color()
	self:set_cell_color(self.goods_view,goods_data:get_color())
	--设置名字
	self:set_equip_name(equip_id)
	self:set_cur_pro(equip_id)
	self:set_next_pro(equip_id)
	self:set_bar_img(self.color)
	self:set_bar_data(player:get_one_equip_qh_stone(goods_data:get_color()),goods_data:get_req_qh_stone())
	self:set_gold(goods_data:get_req_qh_gold())
	self:check_button_state()
end

--设置名字
function strengthen_info:set_equip_name( equip_id )
	local player = model.get_player()
	local equips = player:get_equips()
	local eq_data = equips[tostring(equip_id)]
	local lv = eq_data:get_level()
	if lv<=0 or lv==nil then 
		self.lbl_equip_name:setString(eq_data:get_name())
		self.lbl_equip_name:setColor(Color[eq_data:get_color()])
		return
	end
	self.lbl_equip_name:setString(eq_data:get_name()..'+'..eq_data:get_level())
	self.lbl_equip_name:setColor(Color[eq_data:get_color()])
end

--设置现在属性

function strengthen_info:set_cur_pro( equip_id )
	local player = model.get_player()
	local equips = player:get_equips()
	local eq_data = equips[tostring(equip_id)]

	--多语言待改
	self.lbl_prop_name:setString(locale.get_value('role_' .. eq_data:get_prop_key()))
	self.lbl_prop_value:setString(eq_data:get_prop_value())

end

function strengthen_info:set_next_pro( equip_id )
	local player = model.get_player()
	local equips = player:get_equips()
	local eq_data = equips[tostring(equip_id)]
	local eq_type = data.item_id[equip_id]
	self.lbl_next_prop_name:setString(locale.get_value('role_' .. eq_data:get_prop_key()))
	local next_value = eq_data:get_prop_value()+eq_data:get_prop_growth()
	self.lbl_next_prop_value:setString(next_value)
end
function strengthen_info:init_cell_color( )
	self.goods_view:getChildByName('green'):setVisible(false)
	self.goods_view:getChildByName('blue'):setVisible(false)
	self.goods_view:getChildByName('purple'):setVisible(false)
	self.goods_view:getChildByName('orange'):setVisible(false)
end

function strengthen_info:set_cell_color( cell,level )
	self.color = level
	if level == EnumLevel.Green then
		
		cell:getChildByName('green'):setVisible(true)

	elseif level == EnumLevel.Blue then
		
		cell:getChildByName('blue'):setVisible(true)

	elseif level == EnumLevel.Purple then

		cell:getChildByName('purple'):setVisible(true)

	elseif level == EnumLevel.Orange then

		cell:getChildByName('orange'):setVisible(true)
	end
end

--设置进度条颜色
function strengthen_info:set_bar_img( color )
	self.frag_icon:loadTexture('strengthen_'..color..'.png',load_texture_type)
	self.frag_bar:loadTexture('strengthen_'..color..'_bar.png',load_texture_type)
end

--设置进度条的数值
function strengthen_info:set_bar_data(num,need_frag)

	-- local need_frag = data.equipment_lv[self.color ][self.eq_level+1].stone
	-- local need_frag = data.equipment_lv[self.color ][self.eq_level+1].stone
	if self.eq_level >= 30 then
		self.frag_bar:setPositionX(self.frag_bar:getContentSize().width)
		self.lbl_frag_count:setString('已达最高级' )
		return
	end

	if num == nil then
		num = 0
	end
	local perc = num/need_frag
	if perc>=1 then
		perc = 1
		self.lbl_frag_count:setString('可强化')
		self.lbl_frag_count:setColor(Color.White)
	else
		self.lbl_frag_count:setColor(Color.Red)
		self.lbl_frag_count:setString(num ..'/'.. need_frag )
	end 
	self.frag_bar:setPositionX(self.frag_bar:getContentSize().width*perc)

end

function strengthen_info:set_gold( num )
	if self.eq_level >= 30 then
		self.lbl_gold:setString('已达最高级')
		return
	end
	local player = model.get_player()
	local gold = player:get_money()
	if gold < num then
		self.lbl_gold:setColor(Color.Red)
	else
		self.lbl_gold:setColor(Color.White)
	end
	self.lbl_gold:setString(num)
end

function strengthen_info:check_button_state(  )
	if self.eq_level >= 30 then
		self.strengthen_button:setTouchEnabled(false)
		return
	end
	self.strengthen_button:setTouchEnabled(true)
end

