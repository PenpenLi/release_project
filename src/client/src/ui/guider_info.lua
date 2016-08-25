local layer		= import( 'world.layer' )
local director	= import( 'world.director' )
local locale	= import( 'utils.locale' )
local ui_const			= import( 'ui.ui_const' )

local cjson = require 'cjson'

guider_info = lua_class('guider_info', layer.ui_layer)

local _gesture_json = 'skeleton/Gesture/Gesture.ExportJson'

function guider_info:_init( export_json )
	super( guider_info, self )._init( export_json, false )
	self.widget: ignoreAnchorPointForPosition( true )
	self.widget: setPosition(VisibleSize.width/2, VisibleSize.height/2)
	local paths = string_split( export_json, '/' )
	self.json = paths[#paths]
	self.visible = false
	self.next_anim = { anim = nil, callback = nil }
	self.cur_anim = { anim = nil, callback = nil }
	self.mid_x = VisibleSize.width / 2
	self.mid_y = VisibleSize.height / 2

	if self.json == 'guide_basicop_1.ExportJson' then
		self:set_operation_tipsfont()
	end
end

function guider_info:set_tips( post_fix )
	if post_fix == nil then
		return
	end
	local title_key = 'tutor_title_' .. post_fix
	local tips_key = 'tutor_tips_' .. post_fix
	local img_key = 'tutor_img_' .. post_fix
	local tmp_title = self: get_widget('Label_6_0')
	if tmp_title ~= nil then
		tmp_title: enableOutline(ui_const.UilableStroke, 1)
		tmp_title: setString(locale.get_value(title_key))
	end
	local tmp_tips = self: get_widget('Label_6')
	if tmp_tips ~= nil then
		tmp_tips: setString(locale.get_value(tips_key))
	end
	local tmp_image = self: get_widget('Image_4')
	if tmp_image ~= nil then
		tmp_image: loadTexture(locale.get_value(img_key))
	end
end

function guider_info:set_operation_tipsfont( )
	local lbl_tmp = {}
	lbl_tmp[1] = self: get_widget('Label_5')
	lbl_tmp[2] = self: get_widget('Label_5_0')
	lbl_tmp[3] = self: get_widget('Label_5_1')

	for i = 1, 3 do
		if lbl_tmp[i] ~= nil then
			-- lbl_tmp[i]: enableOutline(ui_const.UilableStroke, 2)
		end
	end
end

function guider_info:play_anim( anim, callback )
	-- 添加动画
	self.next_anim.anim = anim
	self.next_anim.callback = callback
	if self.cur_anim.anim == nil then
		-- 已经没有动画播放了
		self:start_play()
	else
		-- 当前没有动画在播
	end
end

function guider_info:start_play()
	if self.next_anim.anim == nil then
		-- 没有要播放的动画
		self.cur_anim = {}
		return
	end
	if self.next_anim.anim == self.cur_anim.anim then
		-- 将要播放和当前播放的是同一个
		self.cur_anim = {}
		self.next_anim = {}
		return
	end

	self.cur_anim = self.next_anim
	self.next_anim = {}
	local function combine_cb()
		self:update_visibility()
		if self.cur_anim.callback ~= nil then
			self.cur_anim.callback()
		end
		self: start_play()
	end
	local comcb_obj = cc.CallFunc: create(combine_cb)
	self.cc: setVisible( true )
	self:play_action( self.json, self.cur_anim.anim, comcb_obj )
end

function guider_info:update_visibility()
	self.cc: setVisible( self.visible )
end

function guider_info:set_later_visible( vis )
	self.visible = vis
	if self.gesture_armature ~= nil and vis == false then
		self.gesture_armature: setVisible( false )
	end
end

function guider_info:show_gesture( g_name, g_pos, g_ori )
	if self.gesture_armature == nil then
		ccs.ArmatureDataManager: getInstance(): addArmatureFileInfo( _gesture_json )
		self.gesture_armature = ccs.Armature: create( 'Gesture' )
		self.cc: addChild( self.gesture_armature )
		self.gesture_mov = {}

		local json_obj = cjson.decode(cc.FileUtils:getInstance(): getStringFromFile( _gesture_json ))
		for k, v in pairs(json_obj.animation_data[1].mov_data) do
			self.gesture_mov[v.name] = v.dr
		end
	end
	g_pos = g_pos or {0, 0}
	local x, y = self:get_ori_pos( g_ori )
	self.gesture_armature: setPosition( x + g_pos[1], y + g_pos[2] )
	self.gesture_armature: setVisible( true )
	self.gesture_armature: getAnimation(): play( g_name, self.gesture_mov[g_name], -1 )
end

function guider_info:hide_gesture( )
	if self.gesture_armature ~= nil then
		self.gesture_armature: setVisible( false )
	end
end

function guider_info:release()
	--ccs.ArmatureDataManager: getInstance(): removeArmatureFileInfo( _gesture_json )
	ccs.ArmatureDataManager: destroyInstance()
	super( guider_info, self ).release()
end

function guider_info:get_ori_pos( ori_conf )
	if ori_conf == nil then
		return self.mid_x, self.mid_y
	elseif ori_conf == '左上' then
		return 0, VisibleSize.height
	elseif ori_conf == '左中' then
		return 0, self.mid_y
	elseif ori_conf == '左下' then
		return 0, 0
	elseif ori_conf == '中上' then
		return self.mid_x, VisibleSize.height
	elseif ori_conf == '正中' then
		return self.mid_x, self.mid_y
	elseif ori_conf == '中下' then
		return self.mid_x, 0
	elseif ori_conf == '右上' then
		return VisibleSize.width, VisibleSize.height
	elseif ori_conf == '右中' then
		return VisibleSize.width, self.mid_y
	elseif ori_conf == '右下' then
		return VisibleSize.width, 0
	else
		return self.mid_x, self.mid_y
	end
end
