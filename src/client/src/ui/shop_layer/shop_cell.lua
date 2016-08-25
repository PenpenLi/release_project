local ui_const 				= import( 'ui.ui_const' )

shop_cell = lua_class( 'shop_cell' )
local load_texture_type = TextureTypePLIST

function shop_cell:_init( layer )
	self.layer = layer
	self:create_cell()
	self.img = self.cell:getChildByName('item_view')

	--名字
	self.lbl_name = self.cell:getChildByName('lbl_item_name')
	--self.lbl_name:setFontName(ui_const.UiLableFontType)
	self.lbl_name:enableOutline(ui_const.UilableStroke, 1)

	--数量
	self.lbl_quantity = self.cell:getChildByName('lbl_quantity')
	--self.lbl_quantity:setFontName(ui_const.UiLableFontType)
	self.lbl_quantity:enableOutline(ui_const.UilableStroke, 1)
	self.lbl_quantity:setVisible(false)
	--价钱
	self.lbl_tem_price = self.cell:getChildByName('lbl_tem_price')
	--self.lbl_tem_price:setFontName(ui_const.UiLableFontType)
	self.lbl_tem_price:enableOutline(ui_const.UilableStroke, 1)
	self.price_img =self.cell:getChildByName('money_img')
end

function shop_cell:create_cell(  )
	self.cell	= self.layer:get_widget('list_cell'):clone()
	self.cell:setName('cell')
end


function shop_cell:get_cell(  )
	return self.cell
end

--设置格子oid
function shop_cell:set_oid( number )
	self.oid = number
end

function shop_cell:get_oid(  )
	return self.oid
end

--设置格子图片
function shop_cell:set_img( file )
	if file == nil then
		print('no file')
		return nil
	end
	self.img:loadTexture( file ,load_texture_type)
end


--设置等级
function shop_cell:set_cell_level( level )
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
		self.lbl_name:setColor(Color.Green)
	elseif level == EnumLevel.Blue then
		self.cell:getChildByName('green'):setVisible(false)
		self.cell:getChildByName('blue'):setVisible(true)
		self.cell:getChildByName('purple'):setVisible(false)
		self.cell:getChildByName('orange'):setVisible(false)
		self.lbl_name:setColor(Color.Blue)
	elseif level == EnumLevel.Purple then
		self.cell:getChildByName('green'):setVisible(false)
		self.cell:getChildByName('blue'):setVisible(false)
		self.cell:getChildByName('purple'):setVisible(true)
		self.cell:getChildByName('orange'):setVisible(false)
		self.lbl_name:setColor(Color.Purple)
	elseif level == EnumLevel.Orange then
		self.cell:getChildByName('green'):setVisible(false)
		self.cell:getChildByName('blue'):setVisible(false)
		self.cell:getChildByName('purple'):setVisible(false)
		self.cell:getChildByName('orange'):setVisible(true)
		self.lbl_name:setColor(Color.Orange)
	else
		print('没有这个等级', level)
	end
end


function shop_cell:set_name(s)
	self.lbl_name:setString(s)
end

function shop_cell:set_price( server_data )
	local price = 0
	if server_data:get_gold() ~= nil then
		price = server_data:get_gold()
		self:set_price_img( 'gold' )
	else
		price = server_data:get_diamond()
		self:set_price_img( 'diamond' )
	end
	self.lbl_tem_price:setString('' .. price)
end

function shop_cell:set_quantity( s )
	self.lbl_quantity:setString(''..s)
end

function shop_cell:set_price_img( file )
	self.price_img:loadTexture( 'shop_small_'..file ..'.png' ,load_texture_type)
end

function shop_cell:set_number( server_data )
	local quantity = 1
	local num = server_data:get_number()
	if  num ~= nil then
		quantity = num
	end
	self.lbl_quantity:setVisible(true)
	self.lbl_quantity:setString('x' .. quantity)
end

