local model				= import('model.interface')
local layer				= import( 'world.layer' )
local ui_const			= import( 'ui.ui_const' )
local combat_conf		= import('ui.chose_characters_layer.chose_characters_ui_conf')
local utf8_utils		= import('utils.utf8')
local avatar_info		= import('ui.avatar_info_layer.avatar_info_layer')
local chose_characters_tx = import('ui.chose_characters_layer.chose_characters_tx')
local char				= import( 'world.char' )
local role_model		= import('ui.chose_characters_layer.role_model')
local locale				= import( 'utils.locale' )
local msg_queue = import( 'ui.msg_ui.msg_queue' )
local trie_tree = import('utils.trie_tree')

chose_characters_layer = lua_class('chose_characters_layer',layer.ui_layer)

local _role_type = 'cike'
local nick_name_size = 14
local cike_pos = {0, 0}
local qishi_pos = {0, 0}
local model_zorder = 1
local tx_zorder = 2
local back_tx_zorder = -1000

local _tx_json 	= 'gui/ui_choose_tx/ui_chose_tx.ExportJson'

function chose_characters_layer:_init()
	super(chose_characters_layer,self)._init('gui/main/ui_choose.ExportJson')
	self:init_lbl_font()
	math.randomseed(os.time())  
	self.is_remove = false
	self:set_is_gray(false)
	
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2, VisibleSize.height/2)

	self.btn_qishi	= self:get_widget('btn_qishi')
	self.btn_cike 	= self:get_widget('btn_cike')
	self.btn_ok 	= self:get_widget('btn_ok')
	self.btn_rand 	= self:get_widget('btn_rand')
	self.pal_cike	= self:get_widget('pal_cike')
	self.pal_qishi	= self:get_widget('pal_qishi')

	self.txt_nick_name = self:get_widget('txt_nick_name')

	self:set_handler("btn_qishi", self.character_qishi_event)
	self:set_handler("btn_cike", self.character_cike_event)
	self:set_handler("btn_ok", self.ok_button_event)
	self:set_handler("btn_rand", self.rand_button_event)

	--人物模型
	self.cike_model = role_model.role_model({role_type = 'cike'})
	self.qishi_model = role_model.role_model({role_type = 'qishi'})
	self.cike_model:set_position(cike_pos[1], cike_pos[2])
	self.qishi_model:set_position(qishi_pos[1], qishi_pos[2])
	self.pal_cike:addChild(self.cike_model.entity.cc, model_zorder)			
	self.pal_qishi:addChild(self.qishi_model.entity.cc, model_zorder)
	self.cike_model:play_anim('idle', nil, -1)
	
	--特效
	chose_characters_tx.load_json_file(_tx_json)
	self.cike_tx = chose_characters_tx.chose_characters_tx()
	self.qishi_tx = chose_characters_tx.chose_characters_tx()
	self.cike_back_tx = chose_characters_tx.chose_characters_tx()
	self.qishi_back_tx = chose_characters_tx.chose_characters_tx()
	self.cike_select_tx = chose_characters_tx.chose_characters_tx()
	self.qishi_select_tx = chose_characters_tx.chose_characters_tx()
	self.cike_tx:create_armature('Ui_Chose_tx', 'Stand2', 25, 0)
	self.qishi_tx:create_armature('Ui_Chose_tx', 'Stand', 25, 0)
	self.cike_back_tx:create_armature('Ui_Chose_tx', 'Stand5', 70, -1)
	self.qishi_back_tx:create_armature('Ui_Chose_tx', 'Stand4', 70, -1)
	self.cike_select_tx:create_armature('Ui_Chose_tx', 'Stand7', 70, -1)
	self.qishi_select_tx:create_armature('Ui_Chose_tx', 'Stand7', 70, -1)

	self.cike_model:add_tx(self.cike_tx, tx_zorder)
	self.qishi_model:add_tx(self.qishi_tx, tx_zorder)
	self.cike_model:add_tx(self.cike_back_tx, back_tx_zorder)
	self.qishi_model:add_tx(self.qishi_back_tx, back_tx_zorder)
	self.cike_model:add_tx(self.cike_select_tx, tx_zorder)
	self.qishi_model:add_tx(self.qishi_select_tx, tx_zorder)

	self.qishi_tx:set_visible(false)
	self.qishi_back_tx:set_visible(false)
	self.qishi_select_tx:set_visible(false)
end

--对文字的描边, 多语言
function chose_characters_layer:init_lbl_font(  )
	for name, val in pairs(combat_conf.chose_characters_ui_label) do
		self['lbl_' .. name] = self:get_widget('lbl_' .. name)
		local temp_label = self['lbl_' .. name]
		if temp_label ~= nil then
			if val.edge ~= nil and val.edge > 0 then 					--edge的值大于0就描边
				temp_label:enableOutline(ui_const.UilableStroke, val.edge)  ---，描边，厚度 role_ui_conf.lua中role_ui_label的edge
			end
			temp_label:setString(locale.get_value('chose_' .. name))
		end
	end
end

--角色1
function chose_characters_layer:character_qishi_event( sender, eventtype )
	
	if eventtype == ccui.CheckBoxEventType.selected then
		_role_type = 'qishi'

		self.cike_tx:set_visible(false)
		self.cike_back_tx:set_visible(false)
		self.cike_select_tx:set_visible(false)
		self.qishi_tx:set_visible(true)
		self.qishi_back_tx:set_visible(true)
		self.qishi_select_tx:set_visible(true)

		self.qishi_tx:play_animation()
		self.qishi_model:play_secected_anim()
		self.cike_model:stop()
	elseif eventtype == ccui.CheckBoxEventType.unselected then
		sender:setTouchEnabled(true)
	end

end

--角色2
function chose_characters_layer:character_cike_event( sender, eventtype )
	
	if eventtype == ccui.CheckBoxEventType.selected then
		_role_type = 'cike'

		self.cike_tx:set_visible(true)
		self.cike_back_tx:set_visible(true)
		self.cike_select_tx:set_visible(true)
		self.qishi_tx:set_visible(false)
		self.qishi_back_tx:set_visible(false)
		self.qishi_select_tx:set_visible(false)

		self.cike_tx:play_animation()
		self.cike_model:play_secected_anim()
		self.qishi_model:stop()
	elseif eventtype == ccui.CheckBoxEventType.unselected then
		sender:setTouchEnabled(true)	
	end

end


--确定按钮
function chose_characters_layer:ok_button_event( sender, eventtype )
	
	if eventtype == ccui.TouchEventType.began then
	
	elseif eventtype == ccui.TouchEventType.moved then

	elseif eventtype == ccui.TouchEventType.ended then
			local director = import('world.director')
			local nick_name = self.txt_nick_name:getStringValue()--self.txt_nick_name:getStringValue()
			if utf8_utils.utf8size(nick_name) > nick_name_size then
				msg_queue.add_msg(locale.get_value('msg_chose_over_length'))
				return 
			end
			if nick_name == '' then 
				msg_queue.add_msg(locale.get_value('msg_chose_nil'))
				return 
			end

			if nick_name:find("%s+") then
				msg_queue.add_msg(locale.get_value('msg_chose_illegal'))
				return 
			end

			local flag = trie_tree.illegal_words:gfind(nick_name)
			if flag ~= false then 
				msg_queue.add_msg(locale.get_value('msg_chose_illegal'))
				print('illegal')
				return
			end
			server.create_avatar({role_type = _role_type, nick_name = nick_name})
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end

--随机名字按钮
function chose_characters_layer:rand_button_event( sender, eventtype )
	
	if eventtype == ccui.TouchEventType.began then
	
	elseif eventtype == ccui.TouchEventType.moved then

	elseif eventtype == ccui.TouchEventType.ended then
		local d = data.namelist

		local first_index = math.random(#d[1].name)
		local second_index = math.random(#d[2].name)
		local nick_name = d[1].name[first_index] .. "·" ..d[2].name[second_index]
		self.txt_nick_name:setText(nick_name)
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end

end

function chose_characters_layer:release( )
	--移除角色选择界面plist
	print('remove ui_choose0.plist')
	cc.SpriteFrameCache: getInstance(): removeSpriteFramesFromFile( 'gui/ui_choose/ui_choose0.plist')
	self.is_remove = true
 	--super(chose_characters_layer,self).release()
end