local model 			= import( 'model.interface' )
local ui_const = import( 'ui.ui_const' )
bag_cell				= lua_class('bag_cell')

local load_texture_type = TextureTypePLIST
-- EnumLevel = 
-- {
-- 	White		= 'White',	--	白色
-- 	Green		= 'Green',	--	绿色
-- 	Blue	 	= 'Blue',	--	蓝色
-- 	Purple 		= 'Purple',	--	紫色
-- 	Orange		= 'Orange',	--	橙色

-- }
function bag_cell:_init( layer )
	-- body
	self.layer = layer

	self:create_cell( )
	self.data = nil
	self.txt_goods_quantity = self.cell:getChildByName('txt_good_quantity')
	--self.txt_goods_quantity:setFontName(ui_const.UiLableFontType)
	self.txt_goods_quantity:enableOutline(ui_const.UilableStroke, 2)
	self.txt_goods_quantity:setVisible(false)
end

function bag_cell:get_cell(  )
	return self.cell
end

function bag_cell:create_cell(  )
	self.cell	= self.layer:get_widget('list_cell'):clone()
	self.cell:setName('temp_cell')
	--return self.cell
end

function bag_cell:set_item_id( id  )
	self.id = id
end

function bag_cell:get_item_id(  )
	return self.id
end

--设置格子相应类型数据
function bag_cell:set_data( data )
	-- body
	self.data = data
end

function bag_cell:get_data(  )
	
	return self.data
end

--设置等级
function bag_cell:set_cell_level( level )
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
function bag_cell:set_cell_Image( file )
	local equip = self.cell:getChildByName('cell_img')
	equip:loadTexture( file ,load_texture_type)
end

--设置是否装备了
function bag_cell:set_cell_state( is_equipped )
	--装备了就显示锁住图标，和标记为装备了
	if is_equipped == 'true' then
		self.cell:setName(is_equipped)
		--self.cell:getChildByName('purple'):setVisible(true)
	else
		self.cell:setName(is_equipped)
		--self.cell:getChildByName('purple'):setVisible(false)
	end

end

--设置格子为第几件装备
function bag_cell:set_cell_number( number )
	self.number = number
end

function bag_cell:get_cell_number( )
	return self.number
end

--设置格子是否为选中状态
function bag_cell:set_selected_state( is_select )
	self.cell:setSelectedState(is_select)
end

--设置格子是否可以点击
function bag_cell:set_touch_enabled( is_touch )
	self.cell:setTouchEnabled(is_touch)
end

--设置格子坐标
function bag_cell:set_position( x, y )
	self.cell:setPosition( x, y )
end

--物品的类型，是装备？、宝石、道具
function bag_cell:set_goods_type( id )
	self.type = id 
end

function bag_cell:get_goods_type(  )
	return self.type
end


--设置叠加
function bag_cell:set_goods_quantity( qut )
	self.quantity = qut
	self.txt_goods_quantity:setVisible(true)
	self.txt_goods_quantity:setString('x'..qut)
end

--获得数量
function bag_cell:get_goods_quantity(  )
	return self.quantity
end
