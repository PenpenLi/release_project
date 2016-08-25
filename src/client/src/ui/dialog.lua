local director			= import( 'world.director' )
local model				= import( 'model.interface' )
local ui_layer			= import( 'world.layer' )
local ui_const			= import( 'ui.ui_const' )
local char				= import( 'world.char' )

dialog = lua_class('dialog', ui_layer.ui_layer)

local character_zorder 	= 10
local text_zorder 		= 11

function dialog:_init()
	super(dialog, self)._init('gui/battle/Ui_duihua.ExportJson')

	self.black_root = ccs.GUIReader:getInstance():widgetFromJsonFile('gui/battle/Ui_Black.ExportJson')
	self.cc:addChild(self.black_root,0,0)
	self.black_root:setPosition(0,0)
	--self.cc:addChild(self.black_root,1,-100)
	self.black_root:setLocalZOrder(-100)

	self.widget:setLocalZOrder(1)

	self.next_dia_id = nil
	self.dialog_end_cb = nil
	self.loaded_armatures = {}
	self.cur_dialog = ''

	-- self.back_ground = ccs.GUIReader:getInstance():widgetFromJsonFile('gui/battle/Ui_Black.ExportJson')
	self.back_layer = cc.Layer: create()
	self.cc:addChild(self.back_layer)

	local function click_began()
		return true
	end
	local function click_ended()
		self:next_dialog()
	end

	self.dialog_listener = cc.EventListenerTouchOneByOne: create()
	self.dialog_listener:setSwallowTouches(true)
	self.dialog_listener:registerScriptHandler(click_began, cc.Handler.EVENT_TOUCH_BEGAN)
	self.dialog_listener:registerScriptHandler(click_ended, cc.Handler.EVENT_TOUCH_ENDED)
	self.eventDispatcher = self.cc:getEventDispatcher()
	self.eventDispatcher:addEventListenerWithSceneGraphPriority(self.dialog_listener, self.back_layer)


	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2,0)

	local left_char = self:get_widget('Image_3')
	self.left_char_pos = left_char:getWorldPosition()

	local right_char = self:get_widget('Image_2')
	self.right_char_pos = right_char:getWorldPosition()

	self.label_subtitle	= self:get_widget('Label_4')
	--self.label_subtitle:setFontName('fonts/msyh.ttf')
	self.label_subtitle:enableOutline(ui_const.UilableStroke, 2)
	self.label_subtitle:setLocalZOrder( text_zorder )

	self.label_character = self:get_widget('Label_3')
	--self.label_character:setFontName('fonts/msyh.ttf')
	self.label_character:enableOutline(ui_const.UilableStroke, 2)
	self.label_character:setLocalZOrder( text_zorder )

	self.subtitle_x_pos, self.subtitle_y_pos = self.label_subtitle: getPosition()
	_, self.character_y_pos = self.label_character: getPosition()
end

function dialog:on_enter()
	director.get_scene():pause()
end

function dialog:on_exit()
end

function dialog:set_dialog_end_cb( func )
	self.dialog_end_cb = func
end

function dialog:trigger_dialog_end()
	if self.dialog_end_cb ~= nil then
		self.dialog_end_cb()
	end
end

function dialog:show_dialog( diag_id )
	local diag_data = data.dialog[diag_id]
	if diag_data == nil then
		print(' diag_data nil ')
		return
	end
	if diag_data.json ~= nil then
		self:play_animation( diag_data )
	end

	local actor_name = diag_data.name
	if actor_name == '{@MY_NAME}' then
		actor_name = model.get_player():get_nick_name()
	end
	if actor_name ~= nil then
		self.label_character:setString( actor_name )
	end

	local str_subtitle = diag_data.subtitle
	if str_subtitle ~= nil then
		str_subtitle = string.gsub(str_subtitle, '{@MY_NAME}', model.get_player():get_nick_name())
	end
	self.label_subtitle:setString( str_subtitle )
	self.next_dia_id = diag_data.next_id
end

function dialog:next_dialog()
	if self.next_dia_id == nil then
		print(' call back ')
		-- callback
		self:trigger_dialog_end()
		return
	end
	self:show_dialog( self.next_dia_id )
end

function dialog:end_dialog()
	for k, v in pairs(self.loaded_armatures) do
		print('remove loaded armature: ', k)
		-- local j = 'skeleton/' .. k .. '/' .. k .. '.ExportJson'
		if k == '{@MY_JSON}' then
		else
			local j = 'skeleton/' .. k
			ccs.ArmatureDataManager: getInstance(): removeArmatureFileInfo( j )
		end
		v: removeFromParent()
		self.loaded_armatures[k] = nil
	end
	if self.eventDispatcher ~= nil and self.dialog_listener ~= nil then
		self.eventDispatcher:removeEventListener(self.dialog_listener)
	end
	director.get_scene():resume()
end

function dialog:release()
	super(dialog, self).release()
end

function dialog:add_character( json, arm_name )
	-- local j = 'skeleton/' .. json .. '/' .. json .. '.ExportJson'
	--TODO: 检查add不到的情况
	if json == '{@MY_JSON}' then
		local player = model.get_player()
		local conf = import('char.'.. player:get_role_type())
		local entity_anim = char.char(conf)
		self.cc: addChild( entity_anim.cc )
		entity_anim.cc: setLocalZOrder( character_zorder )
		self.loaded_armatures[json] = entity_anim
	else
		local j = 'skeleton/' .. json 
		ccs.ArmatureDataManager: getInstance(): removeArmatureFileInfo( j )
		ccs.ArmatureDataManager: getInstance(): addArmatureFileInfo( j )
		local temp_armature = ccs.Armature:create( arm_name )
		self.cc: addChild( temp_armature )
		temp_armature: setLocalZOrder( character_zorder )
		self.loaded_armatures[json] = temp_armature
	end
end

function dialog:play_animation( dialog_data )
	local fc = dialog_data.framecount or 100
	local start = dialog_data.start or 1
	local loop = dialog_data.loop or 0

	if self.loaded_armatures[self.cur_dialog] ~= nil then
		self.loaded_armatures[self.cur_dialog]: setVisible( false )
	end

	if self.loaded_armatures[dialog_data.json] == nil then
		self:add_character(dialog_data.json, dialog_data.arm_name)
	end

	if self.loaded_armatures[dialog_data.json] ~= nil then
		local cur_armature = self.loaded_armatures[dialog_data.json]
		self.cur_dialog = dialog_data.json

		dialog_data.y_offset = dialog_data.y_offset or 0
		dialog_data.scale = dialog_data.scale or 1
		if dialog_data.position == 'left' then
			cur_armature: setPosition( {x = self.left_char_pos.x, y = self.left_char_pos.y + dialog_data.y_offset} )
			self.label_subtitle: setPosition( self.subtitle_x_pos + 80, self.subtitle_y_pos ) 
			--self.label_character: setPosition( self.subtitle_x_pos + 80, self.character_y_pos ) 
		else
			cur_armature: setPosition( {x = self.right_char_pos.x, y = self.right_char_pos.y + dialog_data.y_offset} )
			self.label_subtitle: setPosition( self.subtitle_x_pos, self.subtitle_y_pos ) 
			--self.label_character: setPosition( self.subtitle_x_pos, self.character_y_pos ) 
		end
		-- cur_armature: setScale( dialog_data.scale )
		cur_armature: setScaleX( dialog_data.scale )
		cur_armature: setScaleY( math.abs(dialog_data.scale) )
		cur_armature: getAnimation(): play(dialog_data.animation, fc, loop)
		cur_armature: getAnimation(): gotoAndPlay(start)
		cur_armature: setVisible( true )
		-- print(' text zorder: ', self.label_subtitle: getLocalZOrder(), self.label_character: getLocalZOrder())
		-- print(' anim zorder: ', self.loaded_armatures[dialog_data.json]: getLocalZOrder())
	end
end
