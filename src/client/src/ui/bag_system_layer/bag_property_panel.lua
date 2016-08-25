
local model 			= import( 'model.interface' )
local combat_conf		= import( 'ui.bag_system_layer.bag_ui_conf' )
local ui_const			= import( 'ui.ui_const' )

bag_property_panel = lua_class('bag_property_panel')

function bag_property_panel:_init( layer )
	self.layer = layer

end


function bag_property_panel:updata_lbl_info(  )
	local player = model.get_player()
	for name, val in pairs(combat_conf.bag_ui_label) do 	--读出main_surface_ui_txt文件的table
		--名字加前缀，就可以读出相应的名字label控件
		local temp_val = nil

		if val.widget == 'good_info_panel' then
			self['txt_' .. name] = self.layer:get_widget('txt_'..name)
			temp_val = self['txt_'..name]	
		end
		--把读出来的控件存到self的一个table中
		
		if temp_val ~= nil then
			--temp_val:setFontName(ui_const.UiLableFontType)
			if player[name] ~= nil then
				temp_val:setString(player[name]) --把玩家的战斗属性值设置到这个Val label中
			else
				temp_val:setString(val.text)
			end
			if val.edge ~= nil and val.edge > 0 then 					--edge的值大于0就描边
				temp_val:enableOutline(ui_const.UilableStroke, val.edge)  ---，描边，厚度 role_ui_conf.lua中role_ui_label的edge
			end
		end

	end
end
