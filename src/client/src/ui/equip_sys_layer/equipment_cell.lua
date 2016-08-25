local ui_const = import( 'ui.ui_const' )
local shaders  = import( 'utils.shaders' )
equipment_cell	= lua_class('equipment_cell')


local load_texture_type = TextureTypePLIST

function equipment_cell:_init( layer ,is_call )
	-- body
	self.layer = layer
	self.is_call = is_call
	self:create_equip_cell( is_call )
	--装备名称


end

function equipment_cell:get_equip_cell(  )
	return self.list_cell
end

function equipment_cell:get_button(  )
	return self.button
end

function equipment_cell:create_equip_cell( is_call )

	--格子容器
	if is_call == true then
		self.list_cell	= self.layer:get_widget('call_cell'):clone()
		self.list_cell:setName('cell_panel')
		self.list_cell:ignoreAnchorPointForPosition(true)
		self.button = self.list_cell:getChildByName('button')

	else
		self.list_cell	= self.layer:get_widget('no_call_cell'):clone()
		self.list_cell:setName('cell_panel')
		self.list_cell:ignoreAnchorPointForPosition(true)
		self.button = self.list_cell:getChildByName('button')
		self.activation_pro_img = self.button:getChildByName('activation_pro_img')
		self.main_pro_img = self.button:getChildByName('main_pro_img')
		self.lbl_frag_count = self.button:getChildByName('lbl_frag_count')
	
		self.lbl_frag_count:enableOutline(ui_const.UilableStroke, 1)
		self.frag_barbg = self.button:getChildByName('frag_barbg')
		self.frag_icon = self.button:getChildByName('frag_icon')
		self.frag_bar = self.frag_barbg:getChildByName('frag_bar')
		self.red_pos = self.list_cell:getChildByName('red_position')
		self.red_pos:setVisible(false)
		self:set_panel_gray()
	end
	--武器框框
	self.cell = self.button:getChildByName('cell')
	self.lbl_equip_name = self.button:getChildByName('lbl_equip_name')
	
	self.lbl_equip_name:enableOutline(ui_const.UilableStroke, 1)
	self.lbl_main_value = self.button:getChildByName('lbl_main_value')
	
	self.lbl_main_value:enableOutline(ui_const.UilableStroke, 1)
	self.lbl_activation_value = self.button:getChildByName('lbl_activation_value')
	self.lbl_activation_value:enableOutline(ui_const.UilableStroke, 1)
	
	--主属性的图片 附加属性图标
	self.main_pro_img = self.button:getChildByName('main_pro_img')
	self.activation_pro_img = self.button:getChildByName('activation_pro_img')
end


function equipment_cell:get_is_call(  )
	return self.is_call 
end

--变灰
function equipment_cell:set_panel_gray(  )
	self:set_gray( self.activation_pro_img )
	self:set_gray( self.main_pro_img)
end

--变灰
function equipment_cell:set_gray( sp ,num )

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




--设置等级
function equipment_cell:set_cell_level( level )
	self.color = level
	if level == EnumLevel.White then
		
		self.cell:getChildByName('green'):setVisible(false)
		self.cell:getChildByName('blue'):setVisible(false)
		self.cell:getChildByName('purple'):setVisible(false)
		self.cell:getChildByName('orange'):setVisible(false)
	elseif level == EnumLevel.Green then
		
		self.cell:getChildByName('green'):setVisible(true)
		self.cell:getChildByName('blue'):setVisible(false)
		self.cell:getChildByName('purple'):setVisible(false)
		self.cell:getChildByName('orange'):setVisible(false)
	elseif level == EnumLevel.Blue then
		
		self.cell:getChildByName('green'):setVisible(false)
		self.cell:getChildByName('blue'):setVisible(true)
		self.cell:getChildByName('purple'):setVisible(false)
		self.cell:getChildByName('orange'):setVisible(false)
	elseif level == EnumLevel.Purple then
		
		self.cell:getChildByName('green'):setVisible(false)
		self.cell:getChildByName('blue'):setVisible(false)
		self.cell:getChildByName('purple'):setVisible(true)
		self.cell:getChildByName('orange'):setVisible(false)
	elseif level == EnumLevel.Orange then
		
		self.cell:getChildByName('green'):setVisible(false)
		self.cell:getChildByName('blue'):setVisible(false)
		self.cell:getChildByName('purple'):setVisible(false)
		self.cell:getChildByName('orange'):setVisible(true)
	else
		--print('没有这个等级')
	end
end

--设置图案
function equipment_cell:set_cell_Image( file )

	--往格子加图片
	local equip = ccui.ImageView:create()
	equip:loadTexture( file ,load_texture_type)
	equip:setPosition( 0, 0 )
	equip:setAnchorPoint( 0, 0 )
	-- equip:setColor(cc.c3b(150,150,150))
	-- equip:setOpacity(180)
	self.cell:addChild(equip,0)

	if self.is_call == false then

		shaders.SpriteSetGray(equip:getVirtualRenderer(),0.1)
	end
end

function equipment_cell:set_main_value( value )
	if value == nil then
		value = 0
	end
	self.lbl_main_value:setString(''..value)
end

function equipment_cell:set_activation_value( value )
	if value == nil then
		value = 0
	end
	self.lbl_activation_value:setString(value)
end

function equipment_cell:set_main_pro_img( pro_name )
	if pro_name == nil then
		self.main_pro_img:setVisible(false)
		return
	end
	self.main_pro_img:loadTexture(pro_name .. '.png',load_texture_type)
end

function equipment_cell:set_activation_pro_img( pro_name )
	if pro_name == nil then
		self.activation_pro_img:setVisible(false)
		return
	end
	self.activation_pro_img:loadTexture(pro_name .. '.png',load_texture_type)
end


--设置碎片百分比显示
function equipment_cell:set_frag_bat( num ,eq_type)
	local need_frag = data.equipment_activation[self.equip_data.color..'_'..eq_type]
	local perc = num/need_frag
	if perc>=1 then
		perc = 1
	end 
	self.frag_bar:setPositionX(self.frag_bar:getContentSize().width*perc)
	if num >= need_frag then
		self.lbl_frag_count:setString('可激活')
		self.red_pos:setVisible(true)
	else
		self.lbl_frag_count:setString(num ..'/'.. need_frag )
	end
end

--设置是否装备了
function equipment_cell:set_equip_state( is_equipped )
	--装备了就显示锁住图标，和标记为装备了
	self.is_equipped = is_equipped
	local make_tick = self.cell:getChildByName('make_tick')
	if is_equipped == true and make_tick ~= nil then
		--self.cell:setName(is_equipped)
		self:set_main_pro_state(true)
		make_tick:setVisible(true)
	end
	if is_equipped == false and make_tick ~= nil then
		--self.cell:setName(is_equipped)
		make_tick:setVisible(false)
		self:set_main_pro_state(false)
	end

end

function equipment_cell:get_equip_state(  )
	return self.is_equipped
end

function equipment_cell:set_equip_name( name ,lv,color)
	if lv == nil or lv <=0 then
		self.lbl_equip_name:setString(name)
		self.lbl_equip_name:setColor(Color[color])
		return
	end
	self.lbl_equip_name:setString(name .. '+'.. lv)
	self.lbl_equip_name:setColor(Color[color])
end

--设置格子为第几件装备
function equipment_cell:set_equip_number( number )
	self.number = number
end
function equipment_cell:get_equip_number(  )
	return self.number
end

--设置格子是否为选中状态
function equipment_cell:set_selected_state( is_select )
	self.cell:setSelectedState(is_select)
end

--设置格子是否可以点击
function equipment_cell:set_touch_enabled( is_touch )
	self.cell:setTouchEnabled(is_touch)
end

--设置格子坐标
function equipment_cell:set_position( x, y )
	self.list_cell:setPosition( x, y )
end

---设置数据

function equipment_cell:set_equip_data( data )
	self.equip_data = data
end

function equipment_cell:get_equip_data(  )
	return self.equip_data
end


--设置进度条颜色
function equipment_cell:set_bar_img( color , pos)
	self.frag_icon:loadTexture('role_'..color..'_' ..pos..'.png',load_texture_type)
	self.frag_bar:loadTexture('role_min_'..color..'_bar.png',load_texture_type)
end
--

function equipment_cell:set_main_pro_state( is_equipped )
	if is_equipped == true then
		self:set_gray(self.main_pro_img,1)
		self.lbl_main_value:setColor(cc.c3b(255, 206,   56))
	else
		self:set_gray(self.main_pro_img)
		self.lbl_main_value:setColor(cc.c3b(204, 204,   204))
	end
end
