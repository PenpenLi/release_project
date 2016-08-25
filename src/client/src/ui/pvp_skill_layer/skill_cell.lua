local ui_const = import( 'ui.ui_const' )


skill_cell = lua_class('skill_cell')

local load_texture_type = TextureTypePLIST
-- EnumLevel = 
-- {
-- 	fire		= 1,	--	火
-- 	ice			= 2,	--	冰
-- 	nature	 	= 3,	--	自然

-- }
function skill_cell:_init( layer , total_type )
	-- body
	self.layer = layer
	self.skill_data = nil

	--主动还是被动技能
	self.total_type = total_type

	--火冰自然，属性
	self.pro_type = pro_type
	self:create_cell( total_type )

	self.lbl_grade = self.cell:getChildByName('dengji')
	--self.lbl_grade:setFontName(ui_const.UiLableFontType)

	--星星等级
	self.star_level = self.cell:getChildByName('star_level')
	--头像
	self.head_view = self.cell:getChildByName('head_view')
	--属性图
	self.pro_view = self.cell:getChildByName('pro_view')
	--战灵名称
	self.name = self.cell:getChildByName('name')
	--self.name:setFontName(ui_const.UiLableFontType)

end

function skill_cell:get_cell(  )
	return self.cell
end

function skill_cell:create_cell( total_type )

	if total_type == EnumSkillTypes.active then
		self.cell	= self.layer:get_widget('skill_cell_a'):clone()
	elseif total_type == EnumSkillTypes.passive then
		self.cell	= self.layer:get_widget('skill_cell_p'):clone()
	end
end

--设置格子相应类型数据
function skill_cell:set_skill_data( data )
	self.skill_data = data
end

function skill_cell:get_skill_data(  )
	return self.skill_data
end

function skill_cell:set_skill_idx( idx )
	self.idx = idx
end

function skill_cell:get_skill_idx(  )
	return self.idx 
end

--设置技能等级
function skill_cell:set_star_level( level )
	-- self.pro_type = pro_type
	self.star_level:setVisible(true)
	if level == 0 then
		self.star_level:setVisible(false)
	else
		self.star_level:loadTexture('soul_star_'..level ..'.png' , load_texture_type)
	end
end


function skill_cell:set_head_view( img_name )
	self.head_view:loadTexture( img_name ,load_texture_type )
end

--设置属性图标
function skill_cell:set_pro_type( pro_name )
	--pro_name 要是字符串
	self.pro_view:loadTexture('soul_' .. pro_name .. '.png',load_texture_type)

end

--设置名称

function skill_cell:set_name( name )
	self.name:setString(name)
end


--设置图片为黑色
function skill_cell:set_cell_Image_gray( )
	self.cell:setColor(cc.c3b(180, 180, 180))
end

function skill_cell:restore_cell_Image_color( )
	self.cell:setColor(cc.c3b(255, 255, 255))
end

--设置是否装备了
function skill_cell:set_cell_state( is_equipped )
	--装备了就显示锁住图标，和标记为装备了
	self.cell:setHighlighted(false)
	if is_equipped == 'true' then
		self.cell:setName(is_equipped)
		self.cell:getChildByName('tick'):setVisible(true)
	else
		self.cell:setName(is_equipped)
		self.cell:getChildByName('tick'):setVisible(false)
	end

end

function skill_cell:get_cell_state(  )
	return self.cell:getChildByName('tick'):isVisible()
end

--设置格子为第几件装备
function skill_cell:set_cell_number( number )
	self.cell:setTag(number)
end

function skill_cell:get_cell_number( )
	return self.cell:getTag()
end

--设置格子是否为选中状态
function skill_cell:set_selected_state( is_select )
	--self.cell:setSelectedState(is_select)
	self.cell:setHighlighted(false)
end

--设置格子是否可以点击
function skill_cell:set_touch_enabled( is_touch )
	self.cell:setTouchEnabled(is_touch)
end

--设置格子坐标
function skill_cell:set_position( x, y )
	self.cell:setPosition( x, y )
end

--设置技能的属性类型，火，冰，自然
function skill_cell:get_skill_pro_type(  )
	return self.pro_type
end

--设置技能的主动还是被动
function skill_cell:get_skill_total_type(  )
	return self.total_type
end

--设置技能的等级
function skill_cell:set_cell_grade( grade )

	self.lbl_grade:setString( '' ..grade )
end
