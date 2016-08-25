local ui_const = import( 'ui.ui_const' )

soul_card = lua_class('soul_card')

local load_texture_type = TextureTypePLIST


function soul_card:_init( layer ,type)
	
	self.layer = layer
	self.soul_data = nil
	self.card = nil
	self.is_call = true
	self:create_card(type)

	--属性图片

	self.pro_view = self.button:getChildByName('pro_view')
	self.name = self.button:getChildByName('name')
	self.level = self.button:getChildByName('level')
	self.level_bg = self.button:getChildByName('level_bg')
	self.head_view = self.button:getChildByName('head_view')
	self.pro_level = self.button:getChildByName('pro_level')
	self.pro_level:setVisible(true)
	self.call_panel = self.card:getChildByName('call')
	self.lbl_bar = self.call_panel:getChildByName('Label_91')
	self.bar = self.call_panel:getChildByName('ScrollView_88'):getChildByName('Image_89')
	self.call_panel:setVisible(false)

	--设置字体
	--self.level:setFontName(ui_const.UiLableFontType)
	--self.name:setFontName(ui_const.UiLableFontType)
	--self.lbl_bar:setFontName(ui_const.UiLableFontType)
	self.level:enableOutline(ui_const.UilableStroke, 1)
	self.name:enableOutline(ui_const.UilableStroke, 1)
	self.lbl_bar:enableOutline(ui_const.UilableStroke, 1)
end

function soul_card:get_card(  )
	return self.card
end

function soul_card:get_button(  )
	return self.button
end
	
function soul_card:create_card( total_type )

	if total_type == EnumSkillTypes.active then

		self.card = self.layer:get_widget('soul_card_unact'):clone()
		self.button = self.card:getChildByName('card')
	elseif total_type == EnumSkillTypes.passive then

		self.card = self.layer:get_widget('soul_card_act'):clone()
		self.button = self.card:getChildByName('card')

	end
	self.card:setName('card_panel')
	self.card:ignoreAnchorPointForPosition(true)

end

function soul_card:set_no_call( )

	self.pro_view:setVisible(false)
	self.pro_level:setVisible(false)
	self.level:setVisible(false)
	self.level_bg:setVisible(false)
	self.call_panel:setVisible(true)
	self:set_head_gray( )
	self.is_call = false
end

function soul_card:set_is_call( call )
	self.is_call = call

	if self.is_call == false then
		self.button:loadTexturePressed('skill2/skill2 (36).png',TextureTypePLIST)
	end
end

function soul_card:get_is_call(  )
	return self.is_call 
end

--设置战灵头像
function soul_card:set_head_view( img_name )

	self.head_view:loadTexture( img_name ,load_texture_type )
	self.head_img_name = img_name
end

function soul_card:set_head_gray(  )

	self:set_gray( self.card )
end

function soul_card:set_gray( v )

	local children = v:getChildren()
	if children and #children > 0 then
			--遍历子对象设置
		for i,v in ipairs(children) do

			if self:can_gray(v:getName()) then
				SpriteSetGray(v:getVirtualRenderer())
				self:set_gray(v)
			end

		end
	end
end

function soul_card:can_gray( name )
	local names = {'call','name','level'}
	local temp = true
	for _,v in pairs(names) do
		if name == v then
			temp = false
		end
	end
	return temp
end

function SpriteSetGray(sprite)

	local gl_state = cc.GLProgramState:create(cc.GLProgram:createWithFilenames('shaders/ccShader_PositionTextureColor_noMVP.vert','shaders/ccFilterShader_saturation.frag'))
	gl_state:setUniformFloat('u_saturation', 0.3)
	sprite:setGLProgramState(gl_state)
end


--设置属性图标
function soul_card:set_pro_type( pro_name )
	--pro_name 要是字符串
	self.pro_view:loadTexture(pro_name..'.png',load_texture_type)

end

-- --设置属性等级
function soul_card:set_pro_level( level )
	
	if level == 0 then
		self.pro_level:setVisible(false)
	else
		self.pro_level:loadTexture('star_'..level ..'.png' , load_texture_type)
	end
end

--设置战灵名称

function soul_card:set_name( name )
	
	self.name:setString(name)
end

--设置战灵等级
function soul_card:set_level( level )
	
	self.level:setString(''..level)
end

function soul_card:set_skill_id( id )
	self.skill_id = id
end

function soul_card:set_bar_lbl( num,evolution )
	if num < evolution then
		self.lbl_bar:setString(num ..'/'.. evolution)
	end
	if num >= evolution then
		self.lbl_bar:setString('可召唤')
	end
	

end

function soul_card:set_bar_view( num,evolution )
	local perc = num/evolution
	if perc>=1 then
		perc = 1
		self:set_can_call(true)
	else
		self:set_can_call(false)
	end

	self.bar:setPositionX(self.bar:getContentSize().width*perc)
	
end
 

function soul_card:set_can_call( call )
	self.can_call = call
end

function soul_card:get_can_call(  )
	return self.can_call
end