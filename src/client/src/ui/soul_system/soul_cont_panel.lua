local model 				= import( 'model.interface' )
local locale				= import( 'utils.locale' )
local ui_const 				= import( 'ui.ui_const' )
local shaders 				= import( 'utils.shaders' )




soul_cont_panel = lua_class('soul_cont_panel')

local _font_size = 20
local _edgSize = 2

function soul_cont_panel:_init( layer ,tile_nam ,skill_id)
	
	self.layer = layer 
	local avatar = model.get_player()
	self.skills = avatar:get_skills()
	self.skill_id = skill_id
	self:create_lbl(  )
	self.title_lbl = self.panel:getChildByName('Image_30'):getChildByName('tile_name')
	--self.title_lbl:setFontName(ui_const.UiLableFontType)

	self.r_width = 310
	--保存设置了的高度Label_7
	self.lbl_dis = 10
	self.setted_height = 0 
	self.panel_dis = 20
	self:set_Content( tile_nam )
	self.info_count = 1

	
	
end

function soul_cont_panel:create_lbl(  )
	self.panel = self.layer:get_widget('lbl_panel'):clone()
	self.panel:setName('cont')
	self.panel:ignoreAnchorPointForPosition(true)
end

function soul_cont_panel:get_panel(  )
	return self.panel
end

function soul_cont_panel:set_tile_name( name )
	self.title_lbl:setString(name)
end

function soul_cont_panel:set_Content( tile_nam )
	-- body
	
	self.info_count = 1
	if tile_nam == 'jieshao' then
		self:set_tile_name('灵魂介绍')
		local intro = self.skills[self.skill_id]:get_tips()
		self:create_intro_lbl(intro)
		self:create_pro_data_lbl()
		self:create_resistance_lbl()
		self:set_content( self.panel:getLayoutSize().width ,self.setted_height )
	end

	if tile_nam == 'binding' then

		self:set_tile_name('灵魂绑定')
		self:create_binding_lbl()
		self:set_content( self.panel:getLayoutSize().width ,self.setted_height )
	end

	if tile_nam == 'starinfo' then

		self:set_tile_name('星级信息')
		self:create_star_lbl( )

		self:set_content( self.panel:getLayoutSize().width ,self.setted_height )
	end


end

--c创建灵魂绑定
function soul_cont_panel:create_star_lbl(  )
	
	local str = {}
	local id = self.skills[self.skill_id]:get_id()
	local star = self.skills[self.skill_id].data.star
	local orange = cc.c3b(255,  206,   56)

	for i=1,5 do
		
		local skill_data = data.skill[id][i] 
		if skill_data ~= nil then
			local value = skill_data.star_value
			if value ~= nil  then
				local info = skill_data.star_tips
				if i>star then
					self:create_binding_cont(i,info,orange,value,true)
				else
					self:create_binding_cont(i,info,orange,value,false)
				end
			else
				local info = skill_data.star_tips
				if i>star then
					self:create_binding_cont(i,info,orange,nil,true)
				else
					self:create_binding_cont(i,info,orange,nil,false)
				end
			end
		end

	end
	self.setted_height = self.setted_height + self.panel_dis

end

--c创建灵魂绑定
function soul_cont_panel:create_binding_lbl(  )
	local img_height = self.title_lbl:getLayoutSize().height
	local str = {}
	str[1] = '蘑菇:一起出战,攻击力提升/<num>伤害值,防御力提升/<num>。'
	str[2] = '雷鸟:一起出战,敏捷提升/<num>,攻击力提升/<num>。'
	str[3] = '火狼:一起出战,攻击力提升/<num>伤害值,防御力提升/<num>。'
	str[4] = '小鹿:一起出战,生命值提升/<num>值,防御力提升/<num>。'
	-- for i=1,4 do
	-- 	self:create_binding_cont(i)
	-- end
	local green = cc.c3b(172,  236,   0)
	for k,v in ipairs(str) do
		self:create_binding_cont(k,v,green,{30,50},false)
	end


end

function soul_cont_panel:create_binding_cont( i ,str,color,numbers,is_grey )

	local img_height = 0
	if i == 1 then
		img_height = self.title_lbl:getLayoutSize().height
	end
	local richText = ccui.RichText:create()
	richText:enableOutline(ui_const.UilableStroke,_edgSize)
	richText:ignoreContentAdaptWithSize(false)
	
	local lbl_width = self.panel:getLayoutSize().width-70

	richText:setContentSize(cc.size(lbl_width, 0))

	--local str = '蘑菇 : 一起出击，攻击力提升/<num>伤害值，防御力提升/<num>。'

	local temp_str = ''
	local num_table = numbers
	local font_size = 21
	local label = string_split(str,':')
	local name = label[1] .. ':'
	local re1 
	if is_grey == true then
		re1 = ccui.RichElementText:create(1, cc.c3b(204,  204,   204), 255,name , ui_const.UiLableFontType, font_size)

	else
		re1 = ccui.RichElementText:create(1, color, 255,name , ui_const.UiLableFontType, font_size)
	end
	richText:pushBackElement(re1)
	temp_str = temp_str..name

	local cont = label[2]
	local cont_lbl = string_split(cont,'/')
	

	local  i = 0
	for k,v in pairs(cont_lbl) do

		str = v
		local lb = string_split(str,'>')
		if lb[1] == '<num' then
			i = i+1
			local num = string.gsub(lb[1], "<num", ''.. num_table[i]) 
			local re1
			local re2
			if is_grey == true then
				re1 = ccui.RichElementText:create(1, cc.c3b(204,  204,   204), 255, num, ui_const.UiLableFontType, font_size)
				re2 = ccui.RichElementText:create(1, cc.c3b(204,  204,  204), 255, lb[2], ui_const.UiLableFontType, font_size)

			else
				re1 = ccui.RichElementText:create(1, cc.c3b(243,  63,   0), 255, num, ui_const.UiLableFontType, font_size)
				re2 = ccui.RichElementText:create(1, cc.c3b(251,  241,  201), 255, lb[2], ui_const.UiLableFontType, font_size)
			end
			richText:pushBackElement(re1)
			richText:pushBackElement(re2)
			local s = string.gsub(str, "<num>", ''.. num_table[i] )
			temp_str = temp_str..s
		else
			local re1
			if is_grey == true then
				re1 = ccui.RichElementText:create(1, cc.c3b(204,  204,  204), 255, lb[1], ui_const.UiLableFontType, font_size)
				
			else
				re1 = ccui.RichElementText:create(1, cc.c3b(251,  241,  201), 255, lb[1], ui_const.UiLableFontType, font_size)
			end
			richText:pushBackElement(re1)
			temp_str = temp_str..str
		end
		
	end
	
	local rich_height  = self:jisuangaodu(temp_str,self.r_width,font_size)
	self.panel:addChild(richText)
	richText:setContentSize(cc.size(self.r_width, rich_height))
	richText:setAnchorPoint(cc.p(0.5,0.5))

	


	--加入图片
	local img = ccui.ImageView:create()
	img:loadTexture("s_info_mark.png",TextureTypePLIST)
	richText:setPosition(img:getLayoutSize().width+img:getLayoutSize().width/2+self.r_width/2,-(self.setted_height + img_height+rich_height/2+self.lbl_dis))
	img:setPosition(cc.p(img:getLayoutSize().width, richText:getPositionY()+rich_height/2-img:getLayoutSize().height/2))

	if is_grey == true then
		shaders.SpriteSetGray(img:getVirtualRenderer())
	end
	img:setTag(i)
	self.panel:addChild(img)

	self.setted_height =self.setted_height + img_height+self.lbl_dis+rich_height

end



--创建介绍

function soul_cont_panel:create_intro_lbl( cont )
	local img_height = self.title_lbl:getLayoutSize().height
	local _richText = ccui.RichText:create()

	_richText:enableOutline(ui_const.UilableStroke,_edgSize)
	_richText:ignoreContentAdaptWithSize(false)
	
	local lbl_width = self.panel:getLayoutSize().width-40
	_richText:setContentSize(cc.size(lbl_width, 0))
	
	--local str = '用利爪对前方敌人造成/<num>点伤害,并造成/<num>秒眩晕'
	--local str = self.skills[self.skill_id]:get_tips()
	local str = cont
	local label = string_split(str,'/')
	local temp_str = ''
	local num_table = {30,2}
	local font_size = 23
	local  i = 0
	for k,v in pairs(label) do

		str = v
		local label = string_split(str,'>')
		if label[1] == '<num' then
			i = i+1
			local num = string.gsub(label[1], "<num", ''.. num_table[i]) 
			local re1 = ccui.RichElementText:create(1, cc.c3b(243,  63,   0), 255, num, ui_const.UiLableFontType, _font_size)
			local re2 = ccui.RichElementText:create(1, cc.c3b(251,  241,  201), 255, label[2], ui_const.UiLableFontType, _font_size)
			
			_richText:pushBackElement(re1)
			_richText:pushBackElement(re2)
			local s = string.gsub(str, "<num>", ''.. num_table[i] )
			temp_str = temp_str..s
		else
			local re1 = ccui.RichElementText:create(1, cc.c3b(251,  241,  201), 255, label[1], ui_const.UiLableFontType, _font_size)
			_richText:pushBackElement(re1)
			temp_str = temp_str..str
		end
		
	end
	local rich_height,rich_width = self:jisuangaodu(temp_str,lbl_width,_font_size)
	self.panel:addChild(_richText)
	_richText:setContentSize(cc.size(self.r_width, rich_height))
	_richText:setAnchorPoint(cc.p(0.5,0.5))
	
	local dis = self.lbl_dis -2
	if self.info_count == 1 then
		
		self.info_count = self.info_count + 1
		_richText:setPosition(self.panel:getLayoutSize().width/2-dis,-(img_height+rich_height/2+self.lbl_dis+self.setted_height))
		self.setted_height = img_height+self.lbl_dis+rich_height+self.lbl_dis
	else
		
		self.info_count = self.info_count + 1
		_richText:setPosition(self.panel:getLayoutSize().width/2-dis,-(self.setted_height+rich_height/2))
		self.setted_height = self.setted_height+rich_height+self.lbl_dis

	end
	--print('高度11111111111：',rich_height, _extend.get_richtext_size(self._richText).width, _extend.get_richtext_size(self._richText).height)
end

--创建循环属性 
function soul_cont_panel:create_pro_data_lbl(  )

	local pro_table = {}
	pro_table['skill_cd'] = self.skills[self.skill_id]:get_cd()
	pro_table['skill_mana_cost'] = self.skills[self.skill_id]:get_mana_cost()
	pro_table['skill_f_att'] = self.skills[self.skill_id]:get_f_att()
	pro_table['skill_i_att'] = self.skills[self.skill_id]:get_i_att()
	pro_table['skill_n_att'] = self.skills[self.skill_id]:get_n_att()

	for key,value in pairs(pro_table) do
		if value > 0 then
			local richText = ccui.RichText:create()
			
			richText:enableOutline(ui_const.UilableStroke,_edgSize)
			richText:ignoreContentAdaptWithSize(false)
			
			richText:setContentSize(cc.size(self.panel:getLayoutSize().width-40, 0))
			local name = locale.get_value('soul_'..key)
			local value = tostring(value)
			local temp_str = ''
			local font_size = 22
			local re1 = ccui.RichElementText:create(1, cc.c3b(243,  63,   0), 255, name .. '：', ui_const.UiLableFontType, _font_size)
			local re2 = ccui.RichElementText:create(1, cc.c3b(251,  241,  201), 255, value, ui_const.UiLableFontType, _font_size)
					
			richText:pushBackElement(re1)
			richText:pushBackElement(re2)
			temp_str = name..'：'..value

			local rich_height = self:jisuangaodu(temp_str,self.panel:getLayoutSize().width-40,_font_size)
			richText:setContentSize(cc.size(self.panel:getLayoutSize().width-40, rich_height))
			self.panel:addChild(richText)

			richText:setPosition(self.panel:getLayoutSize().width/2,-(self.setted_height+rich_height/2))
			self.setted_height = self.setted_height+rich_height
		
		end
	end
		self.setted_height = self.setted_height+self.lbl_dis

end

function soul_cont_panel:create_resistance_lbl(  )

	local pro_table = {}
	pro_table['skill_f_def'] = self.skills[self.skill_id]:get_f_def()
	pro_table['skill_i_def'] = self.skills[self.skill_id]:get_i_def()
	pro_table['skill_n_def'] = self.skills[self.skill_id]:get_n_def()

	local rich_height = 0
	local rich_width = 0
	local img_height = 0
	for key,value in pairs(pro_table) do
		if value > 0 then
			local richText = ccui.RichText:create()
			richText:getDescription()
			richText:enableOutline(ui_const.UilableStroke,_edgSize)

			richText:ignoreContentAdaptWithSize(false)
			
			richText:setContentSize(cc.size(self.panel:getLayoutSize().width-40, 0))
			local temp_str = ''
			local font_size = 23
			--local str = '火抗' .. '：'.. '1222'..'  '
			local name = locale.get_value('soul_'..key)
			local value = tostring(value)
			--local label = string_split(str,'：')
			local re1 = ccui.RichElementText:create(1, cc.c3b(255,  160,   2), 255, name .. '：', ui_const.UiLableFontType, _font_size)
			local re2 = ccui.RichElementText:create(1, cc.c3b(251,  241,  201), 255, value, ui_const.UiLableFontType, _font_size)
			richText:pushBackElement(re1)
			richText:pushBackElement(re2)
			--temp_str = str
			temp_str = name..'：'..value
			rich_height = self:jisuangaodu(temp_str,self.panel:getLayoutSize().width-40,_font_size)
			richText:setContentSize(cc.size(self.panel:getLayoutSize().width-40, rich_height))
			self.panel:addChild(richText)
			richText:setPosition(30+self.panel:getLayoutSize().width/2,-(self.setted_height+rich_height/2))
			
			--加入图片
			local img = ccui.ImageView:create()
			img:loadTexture( key .. ".png",1)
			img:setPosition(cc.p(30, -(self.setted_height+rich_height/2)))
			img:setScale(0.6)
			self.panel:addChild(img)

			--累计高度
			self.setted_height = self.setted_height+rich_height
		end

	end
		self.setted_height = self.setted_height+self.panel_dis
	
end

function soul_cont_panel:set_content( w ,h )
	self.panel:setContentSize(w,h)
end

function soul_cont_panel:get_content(  )
	return self.panel:getContentSize()
end

function soul_cont_panel:jisuangaodu( temp_str ,width ,font_size )
	--local LB = cc.Label:createWithTTF(temp_str, ui_const.UiLableFontType, font_size)
	local LB = cc.Label:create()
	LB:setSystemFontName(ui_const.UiLableFontType)
	LB:enableOutline(ui_const.UilableStroke,_edgSize)
	LB:setWidth(width)
	LB:setSystemFontSize(font_size)
	LB:setString(temp_str)	
	self.panel:addChild(LB)

	local height = LB:getBoundingBox().height
	local width  = LB:getBoundingBox().width
	LB:removeFromParent()
	return height ,width
end
