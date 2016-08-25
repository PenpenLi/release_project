local combat_conf			= import( 'ui.bag_system_layer.bag_ui_conf' )
local layer					= import( 'world.layer' )
local model 				= import( 'model.interface' )
local locale				= import( 'utils.locale' )
local bag_info_panel		= import( 'ui.bag_system_layer.bag_info_panel' )
local bag_list_panel 		= import( 'ui.bag_system_layer.bag_list_panel' ) 
local bag_cell				= import( 'ui.bag_system_layer.bag_cell' )
local bag_property_panel 	= import( 'ui.bag_system_layer.bag_property_panel' ) 
local music_mgr				= import( 'world.music_mgr' )
local anim_trigger 			= import( 'ui.main_ui.anim_trigger')
local ui_const 				= import( 'ui.ui_const' )

bag_system_layer = lua_class('bag_system_layer',layer.ui_layer)
local load_texture_type = TextureTypePLIST
local eicon_set = 'icon/e_icons.plist'
local _jsonfile = 'gui/main/ui_bag.ExportJson'

function bag_system_layer:_init(  )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( eicon_set )
	super(bag_system_layer,self)._init(_jsonfile,true)
	

	self:set_handler("close_button", self.close_button_event)
	--locale.set_locale( 'cn' )
	self.model = model.get_player()
	self.model:unbound_entity() 
	self:finish_init()
	--创建信息面板
	self.bag_info_panel = bag_info_panel.bag_info_panel(self)
	self.bag_info_panel:set_info_panel_visible(false)
	--创建列表
	self.bag_list_panel = bag_list_panel.bag_list_panel(self)

	--创建金钱，砖石
	self.bag_property_panel = bag_property_panel.bag_property_panel(self)
	--刷新金钱，砖石
	self.bag_property_panel:updata_lbl_info()

	--是否移除
	self.is_remove = false
end


function bag_system_layer:close_button_event( sender, eventtype )
	if eventtype == 0 then
			print('press close')
			music_mgr.ui_click()
		end
		if eventtype == ccui.TouchEventType.began then
		
		elseif eventtype == ccui.TouchEventType.moved then
	  
		elseif eventtype == ccui.TouchEventType.ended then
				 self.cc:setVisible(false)
				 anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_UP_ANIM,false)
				 self.is_remove = true
		elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end

function bag_system_layer:finish_init(  )
	self.widget:setPosition(VisibleSize.width/2, VisibleSize.height/2)
	for name, val in pairs(combat_conf.bag_ui_label) do
		self['lbl_' .. name] = self:get_widget('lbl_' .. name)
		local temp_label = self['lbl_' .. name]
		if temp_label ~= nil then
			--temp_label:setFontName(ui_const.UiLableFontType)
			temp_label:setString(locale.get_value('bag_' .. name))		--如果传入的name在languane是没有的，就会返回以个空字符串
			if val.edge ~= nil and val.edge > 0 then 					--edge的值大于0就描边
				temp_label:enableOutline(ui_const.UilableStroke, val.edge)  ---，描边，厚度 role_ui_conf.lua中role_ui_label的edge
			end
		end
	end
end

function bag_system_layer:get_model( )
	return self.model
end

function bag_system_layer:get_bag_list_panel( )
	return self.bag_list_panel
end

function bag_system_layer:get_bag_info_panel( )
	return self.bag_info_panel
end

---更新背包数据和界面
function bag_system_layer:update_bag_layer( )
	
	self.bag_list_panel:update_equip_list()
	self.bag_property_panel:updata_lbl_info()
end

--释放plise文件
function bag_system_layer:release(  )
	print('release bag_system_layer')
	
	super(bag_system_layer,self).release()
	self.is_remove = false
end

--更新金钱
function bag_system_layer:reload_lbl(  )
	super(bag_system_layer,self).reload()
	self.bag_property_panel:updata_lbl_info()
end

function bag_system_layer:reload(  )
	super(bag_system_layer,self).reload()
	print('update bag_system_layer')
	self:update_bag_layer( )
end
