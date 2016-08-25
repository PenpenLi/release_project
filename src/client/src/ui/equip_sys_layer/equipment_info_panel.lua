local layer					= import( 'world.layer' )
local combat_conf 			= import( 'ui.equip_sys_layer.equip_ui_cont' )
local ui_const 				= import( 'ui.ui_const' )
local locale				= import( 'utils.locale' )
local model 				= import( 'model.interface' )
local ui_mgr 				= import( 'ui.ui_mgr' )
local msg_queue        		= import( 'ui.msg_ui.msg_queue')
local equip_activate_tx		= import( 'ui.equip_sys_layer.equip_activate_tx' )
local ui_guide				= import( 'world.ui_guide' )


equipment_info_panel = lua_class('equipment_info_panel',layer.ui_layer)
local load_texture_type = TextureTypePLIST
local eicon_set = 'icon/e_icons.plist'
local _json_path = 'gui/main/ui_role_info.ExportJson'
local _json_name = 'ui_role_info.ExportJson'


function equipment_info_panel:_init(  )
	
	super(equipment_info_panel,self)._init( _json_path,true )

	
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2,VisibleSize.height/2)

	--是否移除
	self.is_remove = false
	self.cell=self:get_widget('cell')
	self.equip_img = self.cell:getChildByName('equip_img')
	self.main_pro_img = self:get_widget('main_pro_img')
	self.activation_pro_img = self:get_widget('activation_pro_img')

	self.strengthen_button = self:get_widget('strengthen_button')
	self.equip_button = self:get_widget('equip_button')
	self.strength_panel = self:get_widget('strength_panel')
	self.activate_button	= self:get_widget('activate_button')

	self:set_handler('strengthen_button',self.strengthen_button_event)
	self:set_handler('equip_button',self.equip_button_event)
	self:set_handler('activate_button',self.activate_button_event)
	self:set_handler('close_button',self.close_button_event)

	self:set_handler('guide_button', self.guide_tips_event)
	self.guide_button = self:get_widget('guide_button')
	self.guide_button:setVisible(false)
	
	self.frag_bar = self:get_widget('frag_bar')
	self.frag_icon = self:get_widget('frag_icon')
	--默认未装备
	
	self:init_lbl_font()
	self:set_main_state(false)
end

--对文字的描边
function equipment_info_panel:init_lbl_font(  )
	for name, val in pairs(combat_conf.equip_ui_label) do
		self['lbl_' .. name] = self:get_widget('lbl_' .. name)
		local temp_label = self['lbl_' .. name]
		if temp_label ~= nil then
			--temp_label:setFontName(ui_const.UiLableFontType)
			if locale.get_value('role_' .. name) ~= ' ' then
				temp_label:setString(locale.get_value('role_' .. name))		--如果传入的name在languane是没有的，就会返回以个空字符串
			end
			if val.edge ~= nil and val.edge > 0 then 					--edge的值大于0就描边
				temp_label:enableOutline(ui_const.UilableStroke, val.edge)  ---，描边，厚度 role_ui_conf.lua中role_ui_label的edge
			end
		end
	end
end

function equipment_info_panel:set_cont(  )
	local player = model.get_player()
	local equips = player:get_equips()
	local equip_data = equips[tostring(self.id)]
	self:set_head_img(equip_data:get_icon())
	self:set_equip_name(equip_data:get_name())
	self:set_cell_color( equip_data:get_color() )
	self:set_main_value(equip_data:get_prop_value())
	self:set_main_pro_img(equip_data:get_prop_key())
	self:set_main_name(equip_data:get_prop_key())
	self:set_activation_value(equip_data:get_activate_prop_value())
	self:set_activation_pro_img(equip_data:get_activate_prop_key())
	self:set_activation_name(equip_data:get_activate_prop_key())
	self.icon = equip_data:get_icon()
	self.color = equip_data:get_color()
	self.level = equip_data:get_level()
	self.requirement = equip_data:get_req_qh_stone()
	local player = model.get_player()
	self:set_frag_bat(player:get_one_equip_frag(self.color))
end

function equipment_info_panel:updata_conent(  )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( eicon_set )
	local player = model.get_player()
	local equips = player:get_equips()

	local equip_data = equips[tostring(self.id)]
	self:set_head_img(equip_data:get_icon())
	self:set_equip_name(equip_data:get_name(),equip_data:get_level(),equip_data:get_color())
	self:set_cell_color( equip_data:get_color() )
	self:set_main_value(equip_data:get_prop_value())
	self:set_main_pro_img(equip_data:get_prop_key())
	self:set_main_name(equip_data:get_prop_key())
	self:set_activation_value(equip_data:get_activate_prop_value())
	self:set_activation_pro_img(equip_data:get_activate_prop_key())
	self:set_activation_name(equip_data:get_activate_prop_key())
end



function equipment_info_panel:set_stone_requirement( req )
	self.requirement = req
end

function equipment_info_panel:set_head_img( file )
	self.icon = file
	self.equip_img:loadTexture(file,load_texture_type)
end


--设置进度条颜色
function equipment_info_panel:set_bar_img( color ,pos )
	self.frag_icon:loadTexture('role_'..color..'_' ..pos..'.png',load_texture_type)
	self.frag_bar:loadTexture('role_max_'..color..'_bar.png',load_texture_type)
	self.guide_button:setVisible(true)
	for k, v in pairs(data.equip_frag) do
		if v.color == color and v.position == pos then
			self.frag_id = k
			break
		end
	end
end

function equipment_info_panel:guide_tips_event( sender, eventType )
	if eventType == ccui.TouchEventType.ended then
		self.guide_tips_layer = ui_mgr.create_ui(import('ui.guide_tips_layer.guide_tips_layer'), 'guide_tips_layer')
		if self.frag_id ~= nil then
			self.guide_tips_layer:gain_from(self.frag_id)
		end
	end
end

function equipment_info_panel:set_equip_name( name ,lv,color )
	self.name = name
	if lv == nil or lv <=0 then
		self.lbl_equip_name:setString(name)
		self.lbl_equip_name:setColor(Color[color])
		return
	end
	self.lbl_equip_name:setString(name .. '+'.. lv)
	self.lbl_equip_name:setColor(Color[color])
end

function equipment_info_panel:set_equip_level( level )
	self.level = level
	self.lbl_equip_name:setString(self.name.. ' +' .. level)

end
--设置主属性
function equipment_info_panel:set_main_name(pro_name)
	self.lbl_main_name:setString(locale.get_value('role_' .. pro_name))
end

function equipment_info_panel:set_main_state( is_wearing )
	
	if is_wearing == true then
		self.lbl_main_state:setString(locale.get_value('role_worn'))
		SpriteSetGray(self.equip_button:getVirtualRenderer())
		self.equip_button:setTouchEnabled(false)
	else
		self.lbl_main_state:setString(locale.get_value('role_no_wear'))

	end
end


function equipment_info_panel:set_main_value( value )
	if value == nil then
		value = 0
	end
	self.lbl_main_value:setString(''..value)
end

function equipment_info_panel:set_main_pro_img( pro_name )
	self.main_pro_img:loadTexture(pro_name .. '.png',load_texture_type)
end

function equipment_info_panel:set_activation_pro_img( pro_name )
	self.activation_pro_img:loadTexture(pro_name .. '.png',load_texture_type)
end

--设置激活属性
function equipment_info_panel:set_activation_name( pro_name )
	self.lbl_activation_name:setString(locale.get_value('role_' .. pro_name))
end

function equipment_info_panel:set_activation_value( value )

	if value == nil then
		value = 0
	end
	self.lbl_activation_value:setString(value)
end

--设置进度条显示
function equipment_info_panel:set_frag_bat( num )
	local need_frag = self.requirement
	local perc = num/need_frag
	if perc>=1 then
		perc = 1
	end 
	self.frag_bar:setPositionX(self.frag_bar:getContentSize().width*perc)
	if num >= need_frag then
		self.lbl_frag_count:setString('可激活')
	else
		self.lbl_frag_count:setString(num ..'/'.. need_frag )
	end
end



function equipment_info_panel:set_cell_color( level )
	if level == EnumLevel.White then
		
		self.cell:getChildByName('green'):setVisible(false)
		self.cell:getChildByName('blue'):setVisible(false)
		self.cell:getChildByName('purple'):setVisible(false)
		self.cell:getChildByName('orange'):setVisible(false)
	elseif level == EnumLevel.Green then
		
		self.cell:getChildByName('green'):setVisible(true)
		self.cell:getChildByName('blue'):setVisible(false)
		self.cell:getChildByName('purple'):setVisible(false)
		self.cell:getChildByName('orange'):setVisible(false)
	elseif level == EnumLevel.Blue then
		
		self.cell:getChildByName('green'):setVisible(false)
		self.cell:getChildByName('blue'):setVisible(true)
		self.cell:getChildByName('purple'):setVisible(false)
		self.cell:getChildByName('orange'):setVisible(false)
	elseif level == EnumLevel.Purple then
		
		self.cell:getChildByName('green'):setVisible(false)
		self.cell:getChildByName('blue'):setVisible(false)
		self.cell:getChildByName('purple'):setVisible(true)
		self.cell:getChildByName('orange'):setVisible(false)
	elseif level == EnumLevel.Orange then
		
		self.cell:getChildByName('green'):setVisible(false)
		self.cell:getChildByName('blue'):setVisible(false)
		self.cell:getChildByName('purple'):setVisible(false)
		self.cell:getChildByName('orange'):setVisible(true)
	else
		--print('没有这个等级')
	end
	self.color = level
end

function equipment_info_panel:set_id( id  )
	self.id = id 
end

function equipment_info_panel:set_activation_state( activate )
	if activate == true then
		self.lbl_activation_state:setString((locale.get_value('role_activated')))
	else
		self.lbl_activation_state:setString((locale.get_value('role_no_activate')))
	end
end


function equipment_info_panel:show_strength_panel( is_show )
	if is_show == true then
		self.strengthen_button:setVisible(false)
		self.equip_button:setVisible(false)
		self.strength_panel:setVisible(true)
	else
		self.strengthen_button:setVisible(true)
		self.equip_button:setVisible(true)
		self.strength_panel:setVisible(false)
	end

end


--加入强化界面按钮
function equipment_info_panel:strengthen_button_event( sender,eventtype )

	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  
	elseif eventtype == ccui.TouchEventType.ended then
		
		local temp_ui = ui_mgr.get_ui('strengthen_layer')
		if temp_ui ~= nil then
			return
		end
		temp_ui = ui_mgr.create_ui(import('ui.strengthen_layer.strengthen_layer'),'strengthen_layer')
		temp_ui:set_selecet_id(self.id)
		temp_ui:reload()
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end

--装备按钮
function equipment_info_panel:equip_button_event( sender,eventtype )

	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  	
	elseif eventtype == ccui.TouchEventType.ended then
			self.fc = math.floor(model.get_player().final_attrs:get_fighting_capacity() + 0.5)
			local _k = ui_mgr.get_ui('equip_sys_layer'):get_player_info_panel():get_sel_cell()
			sender:setTouchEnabled(false)
			SpriteSetGray(sender:getVirtualRenderer())
			local player = model.get_player()
			self:set_main_state(true)
			player:change_equip(tostring(self.id))
			ui_mgr.get_ui('equip_sys_layer'):get_player_info_panel():update_cell_View( _k, self.icon,self.color )
			self:play_down_anim( )
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end
--变灰
function SpriteSetGray(sprite)

	local gl_state = cc.GLProgramState:create(cc.GLProgram:createWithFilenames('shaders/ccShader_PositionTextureColor_noMVP.vert','shaders/ccFilterShader_saturation.frag'))
	gl_state:setUniformFloat('u_saturation', 0.1)
	sprite:setGLProgramState(gl_state)
end
--强化升级按钮
function equipment_info_panel:activate_button_event( sender,eventtype )

	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  
	elseif eventtype == ccui.TouchEventType.ended then
		--server.strengthen_equip(self.id)
		self.fc = math.floor(model.get_player().final_attrs:get_fighting_capacity() + 0.5)
		server.activate_equip( self.id )
		ui_guide.pass_condition( 'first_eq_activation' )
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end



--关闭按钮

function equipment_info_panel:close_button_event( sender,eventtype )

	if eventtype == ccui.TouchEventType.began then
		
	elseif eventtype == ccui.TouchEventType.moved then
	  
	elseif eventtype == ccui.TouchEventType.ended then
		self:play_down_anim( )
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end




--播放弹出动画
function equipment_info_panel:play_up_anim(  )

	self:play_action('ui_role_info.ExportJson','up')
end

--播放收起动画
function equipment_info_panel:play_down_anim( )
	local function callFunc(  )
		self.is_remove = true
	end
	local callFuncObj=cc.CallFunc:create(callFunc)
	self:play_action('ui_role_info.ExportJson','down',callFuncObj)
end

function equipment_info_panel:set_activation_info(  )

	local ui_info = ui_mgr.get_ui('equipment_info_panel')
	ui_info:set_activation_state(true)
	ui_info:show_strength_panel(false)
	self.guide_button:setVisible(false)
	local pos = self.cell:getWorldPosition()
	local tx_ui = equip_activate_tx.equip_activate_tx()
	self.cc:addChild(tx_ui.cc)
	tx_ui:play_anim(pos.x,pos.y)
	tx_ui.cc:setLocalZOrder(1000)
end


function equipment_info_panel:reload(  )
	super(equipment_info_panel,self).reload()
	self:reload_json()
	self:updata_conent()
	if self.fc == nil then
		return
	end
	local new_fc = math.floor(model.get_player().final_attrs:get_fighting_capacity() + 0.5)
	if new_fc ~= self.fc then
		msg_queue.add_battle_msg(new_fc - self.fc)
	end
	self.fc = new_fc
end


function equipment_info_panel:release( )

	--ccs.ActionManagerEx:getInstance():releaseActionsByJsonName(_json_name)
	super(equipment_info_panel,self).release()
	self.is_remove = false
end

function equipment_info_panel:hide_equip_btn()
	self.equip_button:setVisible(false)
end

function equipment_info_panel:hide_activate_btn()
	self.activate_button:setVisible(false)
end

function equipment_info_panel:hide_strengthen_btn()
	self.strengthen_button:setVisible(false)
end