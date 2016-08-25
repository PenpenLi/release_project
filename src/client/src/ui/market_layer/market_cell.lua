local ui_const			= import( 'ui.ui_const' )

market_cell	= lua_class( 'market_cell' )

function market_cell:_init( layer )
	self.layer	=	layer
	self:create_cell( )
	self:init_lbl( )
end

function market_cell:create_cell()
	self.cell = self.layer:get_widget( 'good_panel' ):clone( )
	self.btn  = self.cell:getChildByName( 'good_btn' )
	self.cell:setName( 'good' )
end

function market_cell:get_cell()
	return self.cell
end

function market_cell:get_btn()
	return self.btn
end

function market_cell:init_lbl()
	self.lbl_good_name	= self.btn:getChildByName( 'lbl_good_name' )
	self.lbl_good_price	= self.btn:getChildByName( 'lbl_good_price' )
	self.lbl_good_title	= self.btn:getChildByName( 'lbl_good_title' )
	self.recommend_img	= self.btn:getChildByName( 'recommend_img' )
	self.good_img		= self.btn:getChildByName( 'good_img' )
	self.recommend_img:setVisible(false)  
end

function market_cell:set_good_name(name)
	self.lbl_good_name:setString(name)
end

function market_cell:set_good_img( route,t )
	self.good_img:loadTexture(route,t)
end

function market_cell:set_good_price(price)
	self.lbl_good_price:setString(tostring(price))
end

function market_cell:set_good_title(title)
	self.lbl_good_title:setString(title)
end

function market_cell:set_recommend(flag)
	self.recommend_img:setVisible(flag)
end

