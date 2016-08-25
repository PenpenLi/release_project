
local model 				= import( 'model.interface' )
local combat_attr 			= import( 'model.combat' )
local ui_const 				= import( 'ui.ui_const' )
local locale				= import( 'utils.locale' )
local skill_select_layer	= import( 'ui.skill_select_system.skill_select_layer' )

skill_display_panel 		= lua_class('skill_display_panel')
local load_texture_type 	= TextureTypePLIST
local sicon_set 			= 'icon/s_icons.plist'
local skill0_png 			= 'Soul/Soul (6).png'
function skill_display_panel:_init( layer )
	
	self.layer = layer
	local player = model.get_player()
	self.combat_attr = player:get_final_attrs()

	--技能1
	local function skill1_button_event(_, sender, eventtype )
		if skill_select_layer.get_touch() == false then
			return
		end

		if eventtype == ccui.TouchEventType.ended then
			if self.is_skilled_1 == false then
				return
			end
			local btn = self.skill_cell_a_1
			btn:loadTextureNormal(skill0_png,load_texture_type)
			btn:loadTexturePressed(skill0_png,load_texture_type)
			model.get_player():load_skill(1,nil)
			self.is_skilled_1 = false
			self.layer:get_list_panel():cancel_skill_by_pos(1)
		end
	end

	--技能2
	local function skill2_button_event(_, sender, eventtype )
		if skill_select_layer.get_touch() == false then
			return
		end

		if eventtype == ccui.TouchEventType.ended then
			if self.is_skilled_2 == false then
				return
			end
			local btn = self.skill_cell_a_2
			btn:loadTextureNormal(skill0_png,load_texture_type)
			btn:loadTexturePressed(skill0_png,load_texture_type)
			model.get_player():load_skill(2,nil)
			self.is_skilled_2 = false
			self.layer:get_list_panel():cancel_skill_by_pos(2)
		end
	end

	--技能3
	local function skill3_button_event(_, sender, eventtype )
		if skill_select_layer.get_touch() == false then
			return
		end

		if eventtype == ccui.TouchEventType.ended then
			if self.is_skilled_3 == false then
				return
			end
			local btn = self.skill_cell_a_3
			btn:loadTextureNormal(skill0_png,load_texture_type)
			btn:loadTexturePressed(skill0_png,load_texture_type)
			model.get_player():load_skill(3,nil)
			self.is_skilled_3 = false
			self.layer:get_list_panel():cancel_skill_by_pos(3)
		end
	end

	--三个主动
	self.skill_cell_a_1 = self.layer:get_widget('skill_cell_a_1')
	self.skill_cell_a_2 = self.layer:get_widget('skill_cell_a_2')
	self.skill_cell_a_3 = self.layer:get_widget('skill_cell_a_3')
	self.is_skilled_1 = false
	self.is_skilled_2 = false
	self.is_skilled_3 = false
	self.layer:set_handler('skill_cell_a_1', skill1_button_event)
	self.layer:set_handler('skill_cell_a_2', skill2_button_event)
	self.layer:set_handler('skill_cell_a_3', skill3_button_event)

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
	self.layer:reload_json()
	cc.SpriteFrameCache:getInstance():addSpriteFrames( sicon_set )
	local cast_skill = model.get_player():get_loaded_skills()  --装备的技能
	for idx = 1, 3 do
		local sk = cast_skill[idx]
		if sk ~= nil  then
			local btn = self[string.format("skill_cell_a_%d",idx)]
			if self['is_skilled_'..idx] == false then

				btn:loadTextureNormal(sk.data.icon,load_texture_type)
				btn:loadTexturePressed(sk.data.icon,load_texture_type)
				self['is_skilled_'..idx] = true

			end
		end
	end

	self:update_defence_info()


end



function skill_display_panel:replace_icon( id ,file, pro_type ,type ,level )
	self.layer:reload_json()
	cc.SpriteFrameCache:getInstance():addSpriteFrames( sicon_set )
	local btn = self[string.format("skill_cell_%s_%d",type,id)]

	btn:loadTextureNormal(file,load_texture_type)
	btn:loadTexturePressed(file,load_texture_type)
	self['is_skilled_'..id] = true
	self:update_defence_info()

end

function skill_display_panel:delete_icon( id ,type )
	self.layer:reload_json()
	local btn = self[string.format("skill_cell_%s_%d",type,id)]
	
	btn:loadTextureNormal(skill0_png,load_texture_type)
	btn:loadTexturePressed(skill0_png,load_texture_type)
	self['is_skilled_'..id] = false
	self:update_defence_info()
end


--更新
function skill_display_panel:update_defence_info( )
	local player = model.get_player()
	self.combat_attr = player:get_final_attrs()
	self.fire_defence:setString(self.combat_attr:get_f_def())
	self.ice_defence:setString(self.combat_attr:get_i_def())
	self.nature_defence:setString(self.combat_attr:get_n_def())
end

