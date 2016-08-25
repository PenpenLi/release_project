local ui_const			= import( 'ui.ui_const' )

dhshop_cell	= lua_class( 'dhshop_cell' )

function dhshop_cell:_init( layer )
	self.layer	=	layer
	self:create_cell( )
	self:init_lbl( )
end

function dhshop_cell:create_cell()
	self.cell = self.layer:get_widget( 'list_cell' ):clone( )
	self.btn  = self.cell:getChildByName( 'button' )
	self.cell:setName( 'good' )
end

function dhshop_cell:get_cell()
	return self.cell
end

function dhshop_cell:get_btn()
	return self.btn
end

function dhshop_cell:init_lbl()
	self.lbl_item_name	= self.btn:getChildByName( 'lbl_item_name' )
	self.lbl_price	= self.btn:getChildByName( 'lbl_price' )
	self.item_img		= self.btn:getChildByName( 'item_img' )
	self.proxy_icon		= self.btn:getChildByName( 'proxy_icon' )
end

function dhshop_cell:set_item_name(name)
	self.lbl_item_name:setString(name)
end

function dhshop_cell:set_item_img( route,t )
	if t ~= nil then
		self.item_img:loadTexture(route,t)
	else
		self.item_img:loadTexture(route)
	end
end

function dhshop_cell:set_proxy_icon( route, t)
	if t ~= nil then
		self.proxy_icon:loadTexture(route,t)
	else
		self.proxy_icon:loadTexture(route)
	end
	self.proxy_icon:setScale(0.5)
end

function dhshop_cell:set_price(title)
	self.lbl_price:setString(title)
end



