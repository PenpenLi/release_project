local ui_const = import( 'ui.ui_const' )
vir_skill = lua_class(' vir_skill ')
local load_texture_type = TextureTypePLIST

function vir_skill:_init( layer )
	self.layer = layer 
	self:create_cell(  )
	
	self.head_view = self.cell:getChildByName('head_view')
	self.lbl_exp = self.cell:getChildByName('lbl_exp')
	self.lbl_level = self.cell:getChildByName('lbl_level')
	self.level_up = self.cell:getChildByName('level_up')
	self.level_up:setVisible(false)

end

function vir_skill:create_cell(  )
	self.cell = self.layer:get_widget('vir_sk_msg'):clone()
	self.cell:ignoreAnchorPointForPosition(true)
	self.cell:setName('temp')

end

function vir_skill:get_cell(  )
	return self.cell
end

function vir_skill:set_head_view( img )
	self.head_view:loadTexture( img ,load_texture_type )
end

function vir_skill:set_level( lv )
	self.lbl_level:setString(lv)
end

function vir_skill:set_exp( ep )
	self.lbl_exp:setString('EXP+'..ep)
end

function vir_skill:set_level_up( bef_level,cur_level )
	if bef_level < cur_level then
		self.level_up:setVisible(true)
	else
		self.level_up:setVisible(false)
	end

end
