local ui_const 			= import( 'ui.ui_const' )

vir_item = lua_class('vir_item')
local load_texture_type = TextureTypePLIST

function vir_item:_init( layer )
	self.layer = layer

	self:create_cell()	
	self.img = self.cell:getChildByName('item_img')
	self.lbl_name = self.cell:getChildByName('lbl_item_name')
	--self.lbl_name:setFontName(ui_const.UiLableFontType)
	self.cell:getChildByName('green'):setVisible(false)
	self.cell:getChildByName('blue'):setVisible(false)
	self.cell:getChildByName('purple'):setVisible(false)
	self.cell:getChildByName('orange'):setVisible(false)
	self.cell:getChildByName('white'):setVisible(false)
end

function vir_item:create_cell()
	self.cell	= self.layer:get_widget('item_cell'):clone()
	self.cell:setName('item')
end

function vir_item:get_cell(  )
	return self.cell
end

function vir_item:set_img( file )
	self.img:loadTexture( file ,load_texture_type)
end

function vir_item:set_name( name ,color )
	self.lbl_name:setString(name)
	self.lbl_name:setColor(Color[color])
	self.lbl_name:enableOutline(ui_const.UilableStroke, ui_const.UilableEdg)
end

function vir_item:set_color( color )
	
	if color == EnumLevel.White then
		self.cell:getChildByName('white'):setVisible(true)
	elseif color == EnumLevel.Green then
		
		self.cell:getChildByName('green'):setVisible(true)

	elseif color == EnumLevel.Blue then

		self.cell:getChildByName('blue'):setVisible(true)

	elseif color == EnumLevel.Purple then

		self.cell:getChildByName('purple'):setVisible(true)

	elseif color == EnumLevel.Orange then

		self.cell:getChildByName('orange'):setVisible(true)
	else
		self.cell:getChildByName('white'):setVisible(true)
	end
end
