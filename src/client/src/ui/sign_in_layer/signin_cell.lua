
signin_cell	= lua_class('signin_cell')
local shaders  = import( 'utils.shaders' )
local signin_tx 		= import( 'ui.sign_in_layer.signin_tx' )
local load_texture_type = TextureTypePLIST

function signin_cell:_init( layer  )
	-- body
	self.layer = layer
	self:create_cell()
end

function signin_cell:set_img( item_id )
	self.item_id = item_id
	local _type = data.item_id[item_id]
	local img_file = data[_type][item_id].icon
	self.button:getChildByName('Image_19'):loadTexture(img_file, load_texture_type)
end

function signin_cell:get_btn( )
	return self.button
end

function signin_cell:get_item_id( )
	return self.item_id
end

function signin_cell:set_num( item_num )
	self.button:getChildByName('lbl_num'):setString('X' .. tostring(item_num))
end

function signin_cell:create_cell( ) --原始的cell

	--格子容器
	self.list_cell	= self.layer:get_widget('Panel_15'):clone()
	self.list_cell:setName('cell_panel')
	self.button = self.list_cell:getChildByName('Button_17')
	self.list_cell:setVisible(true)
	self.list_cell:ignoreAnchorPointForPosition(true)
	self.list_cell:getChildByName('Image_15'):setVisible(false) --不发光
	
	self.button:getChildByName('Image_20'):setVisible(false) --未领取
	self.button:getChildByName('Image_18'):setVisible(false) --非vip

	self.vip_img = self.button:getChildByName('Image_18')
	self.item_img = self.button:getChildByName('Image_19')
end

function signin_cell:set_actived( ) --发光的cell
	self.list_cell:getChildByName('Image_15'):setVisible(true)
end

function signin_cell:set_checked()
	self.button:getChildByName('Image_20'):setVisible(true)
	self.list_cell:getChildByName('Image_15'):setVisible(false)
end

function signin_cell:set_unchecked( )
	self.button:getChildByName('Image_20'):setVisible(false)

	
end

function signin_cell:set_unlighted( )
	self.list_cell:getChildByName('Image_15'):setVisible(false) --不发光
end

function signin_cell:set_panel_gray(  )
	self:set_gray( self.item_img )
	self:set_gray( self.vip_img)
	self:remove_tx()
end

function signin_cell:set_gray( sp, num)
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

function signin_cell:set_vip( vip_lv )
	self.button:getChildByName('Image_18'):setVisible(true) --vip
	local imge_name = 'sign_vip_' .. vip_lv ..'.png'
	--print(imge_name)
	self.button:getChildByName('Image_18'):loadTexture(imge_name, TextureTypePLIST)
end

function signin_cell:play_tx()
	
	self.tx = signin_tx.signin_tx()
	self.tx:play_sel_anim()
	self.tx.cc:setLocalZOrder(10)
	self.list_cell:addChild(self.tx.cc)
end

function signin_cell:remove_tx()
	if self.tx == nil then
		return
	end
	self.tx:remove()
	self.tx = nil
end