local model 			= import( 'model.interface' )
local ui_const = import( 'ui.ui_const' )
strengthen_cell				= lua_class('strengthen_cell')

local load_texture_type = TextureTypePLIST

function strengthen_cell:_init( layer )
	-- body
	self.layer = layer
	self:create_cell( )
	self.data = nil
end

function strengthen_cell:get_equip_cell(  )
	return self.cell
end

function strengthen_cell:get_box(  )
	return self.box
end

function strengthen_cell:create_cell(  )
	self.cell	= self.layer:get_widget('list_cell'):clone()
	self.cell:setName('l_cell')
	self.box = self.cell:getChildByName('box')
	self.cell_img = self.cell:getChildByName('cell_img')
	self.head_img = self.cell_img:getChildByName('img')
	self.lbl_equip_name = self.box:getChildByName('lbl_equip_name')
	self.lbl_main_value = self.box:getChildByName('lbl_main_value')
	self.lbl_activation_value = self.box:getChildByName('lbl_activation_value')
	self.main_pro_img = self.box:getChildByName('main_pro_img')
	self.activation_pro_img = self.box:getChildByName('activation_pro_img')

end



function strengthen_cell:set_equip_name( name,level )
	if level <= 0 then
		self.lbl_equip_name:setString(name)
		self.lbl_equip_name:setColor(Color[self.color])
		return
	end
	self.lbl_equip_name:setString(name .. '+'.. level)
	self.lbl_equip_name:setColor(Color[self.color])
end 

--设置格子相应类型数据
function strengthen_cell:set_data( data )
	-- body
	self.data = data
end

function strengthen_cell:get_data(  )
	
	return self.data
end

function strengthen_cell:set_id( idx )
	self.id = idx
end

function strengthen_cell:get_id(  )
	return self.id 
end



--设置等级
function strengthen_cell:set_cell_level( level )
	self.color = level
	if level == EnumLevel.White then
		self.cell_img:getChildByName('green'):setVisible(false)
		self.cell_img:getChildByName('blue'):setVisible(false)
		self.cell_img:getChildByName('purple'):setVisible(false)
		self.cell_img:getChildByName('orange'):setVisible(false)
	elseif level == EnumLevel.Green then
		self.cell_img:getChildByName('green'):setVisible(true)
		self.cell_img:getChildByName('blue'):setVisible(false)
		self.cell_img:getChildByName('purple'):setVisible(false)
		self.cell_img:getChildByName('orange'):setVisible(false)
	elseif level == EnumLevel.Blue then
		self.cell_img:getChildByName('green'):setVisible(false)
		self.cell_img:getChildByName('blue'):setVisible(true)
		self.cell_img:getChildByName('purple'):setVisible(false)
		self.cell_img:getChildByName('orange'):setVisible(false)
	elseif level == EnumLevel.Purple then
		self.cell_img:getChildByName('green'):setVisible(false)
		self.cell_img:getChildByName('blue'):setVisible(false)
		self.cell_img:getChildByName('purple'):setVisible(true)
		self.cell_img:getChildByName('orange'):setVisible(false)
	elseif level == EnumLevel.Orange then
		self.cell_img:getChildByName('green'):setVisible(false)
		self.cell_img:getChildByName('blue'):setVisible(false)
		self.cell_img:getChildByName('purple'):setVisible(false)
		self.cell_img:getChildByName('orange'):setVisible(true)
	else
		--print('没有这个等级')
	end

end

--设置图案
function strengthen_cell:set_cell_Image( file )
	self.head_img:loadTexture( file ,load_texture_type)
end

--设置是否装备了
function strengthen_cell:set_cell_state( is_equipped )
	--装备了就显示锁住图标，和标记为装备了
	if is_equipped == 'true' then
		self.cell:setName(is_equipped)
		
	else
		self.cell:setName(is_equipped)
		
	end

end


function strengthen_cell:set_main_value( value )
	if value == nil then
		value = 0
	end
	self.lbl_main_value:setString(''..value)
end

function strengthen_cell:set_activation_value( value )
	if value == nil then
		value = 0
	end
	self.lbl_activation_value:setString(value)
end

function strengthen_cell:set_main_pro_img( pro_name )
	if pro_name == nil then
		self.main_pro_img:setVisible(false)
		return
	end
	self.main_pro_img:loadTexture('strengthen_'..pro_name .. '.png',load_texture_type)
end

function strengthen_cell:set_activation_pro_img( pro_name )
	if pro_name == nil then
		self.activation_pro_img:setVisible(false)
		return
	end
	self.activation_pro_img:loadTexture('strengthen_'..pro_name .. '.png',load_texture_type)
end


--设置格子为第几件装备
function strengthen_cell:set_cell_number( number )
	self.number = number
end

function strengthen_cell:get_cell_number( )
	return self.number
end

--设置格子是否为选中状态
function strengthen_cell:set_selected_state( is_select )
	self.box:setSelectedState(is_select)
end

--设置格子是否可以点击
function strengthen_cell:set_touch_enabled( is_touch )
	self.box:setTouchEnabled(is_touch)
end

--设置格子坐标
function strengthen_cell:set_position( x, y )
	self.cell:setPosition( x, y )
end

--物品的类型，是装备？、宝石、道具
function strengthen_cell:set_equip_type( id )
	self.type = id 
end

function strengthen_cell:get_equip_type(  )
	return self.type
end

---设置数据

function strengthen_cell:set_equip_data( data )
	self.equip_data = data
end

function strengthen_cell:get_equip_data(  )
	return self.equip_data
end



