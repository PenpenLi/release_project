
local model 				= import( 'model.interface' )
local combat_attr 			= import( 'model.combat' )
local ui_const				= import( 'ui.ui_const' )
local locale				= import( 'utils.locale' )

skill_display_panel = lua_class('skill_display_panel')
local load_texture_type = TextureTypePLIST
local sicon_set = 'icon/s_icons.plist'

function skill_display_panel:_init( layer )
	
	self.layer = layer
	local player = model.get_player()
	self.combat_attr = player:get_final_attrs()
	--三个主动
	self.skill_cell_a_1 = self.layer:get_widget('skill_cell_a_1')
	self.skill_cell_a_2 = self.layer:get_widget('skill_cell_a_2')
	self.skill_cell_a_3 = self.layer:get_widget('skill_cell_a_3')

	--三个被动
	self.skill_cell_b_1 = self.layer:get_widget('skill_cell_b_1')
	self.skill_cell_b_2 = self.layer:get_widget('skill_cell_b_2')
	self.skill_cell_b_3 = self.layer:get_widget('skill_cell_b_3')

	--火抗 
	self.fire_defence 	= self.layer:get_widget('fire_defence')
	--self.fire_defence:setFontName(ui_const.UiLableFontType)
	--冰抗
	self.ice_defence 	= self.layer:get_widget('ice_defence')
	--self.ice_defence:setFontName(ui_const.UiLableFontType)
	--自然抗
	self.nature_defence = self.layer:get_widget('nature_defence')
	--self.nature_defence:setFontName(ui_const.UiLableFontType)

	self.lbl_f_def = self.layer:get_widget('lbl_f_def')
	--self.lbl_f_def:setFontName(ui_const.UiLableFontType)
	self.lbl_f_def:setString(locale.get_value('skill_f_def'))
	self.lbl_i_def = self.layer:get_widget('lbl_i_def')
	--self.lbl_i_def:setFontName(ui_const.UiLableFontType)
	self.lbl_i_def:setString(locale.get_value('skill_i_def'))
	self.lbl_n_def = self.layer:get_widget('lbl_n_def')
	--self.lbl_n_def:setFontName(ui_const.UiLableFontType)
	self.lbl_n_def:setString(locale.get_value('skill_n_def'))

	--self:update_defence_info( )


end


--更新选择面板

function skill_display_panel:update_display()
	cc.SpriteFrameCache:getInstance():addSpriteFrames( sicon_set )
	local cast_skill = model.get_player():get_pvp_def_skills()  --装备的技能
	for idx = 1, 3 do
		local sk = cast_skill[idx]
		if sk ~= nil  then
			local btn = self[string.format("skill_cell_a_%d",idx)]
			if btn:getChildByTag(10) ==nil then

				local equip = ccui.ImageView:create()
				equip:loadTexture( sk.data.icon ,load_texture_type)
				equip:setPosition( 97/2, 97/2 )
				equip:setAnchorPoint( 0.5, 0.5 )
				btn:addChild(equip,0,10)

			end
		end
	end
	for idx = 4, 6 do
		local sk = cast_skill[idx]
		if sk ~= nil then
			local btn = self[string.format("skill_cell_b_%d",idx-3)]
			if btn:getChildByTag(10) ==nil then
				local equip = ccui.ImageView:create()
				equip:loadTexture( sk.data.icon, load_texture_type )
				equip:setPosition( 97/2, 97/2 )
				equip:setAnchorPoint( 0.5, 0.5 )
				btn:addChild(equip,0,10)

			end
		end
	end
	self:update_defence_info()


end



function skill_display_panel:replace_icon( id ,file, pro_type ,type ,level )

	local btn = self[string.format("skill_cell_%s_%d",type,id)]
	local equip = ccui.ImageView:create()
	equip:loadTexture( file ,load_texture_type)
	equip:setPosition( 97/2, 97/2 )
	equip:setAnchorPoint( 0.5, 0.5 )
	btn:addChild(equip,0,10)

	self:update_defence_info()

end

function skill_display_panel:delete_icon( id ,type )

	local btn = self[string.format("skill_cell_%s_%d",type,id)]
	btn:removeChildByTag(10)
	self:update_defence_info()
end


--更新
function skill_display_panel:update_defence_info( )

	local player = model.get_player()

	local f_def = 0
	local i_def = 0
	local n_def = 0
	if player:get_pvp_def_skills() ~= nil then
		for _, skill in pairs(player:get_pvp_def_skills()) do
			f_def = f_def + skill:get_f_def()
			i_def = i_def + skill:get_i_def()
			n_def = n_def + skill:get_n_def()
		end
	end

	self.fire_defence:setString(f_def)
	self.ice_defence:setString(i_def)
	self.nature_defence:setString(n_def)
end

