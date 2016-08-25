local layer		= import( 'world.layer' )
local director	= import( 'world.director' )
local locale	= import( 'utils.locale' )
local ui_const	= import( 'ui.ui_const' )

local cjson = require 'cjson'

guide_ui_info = lua_class('guide_ui_info', layer.ui_layer)

function guide_ui_info: _init()
	super( guide_ui_info, self )._init()
	self.tip_json 		= 'gui/main/guide_left.ExportJson'
	self.tip_ui 		= {}
	self.cur_json		= nil
	self.gesture_json 	= 'skeleton/Gesture/Gesture.ExportJson'
	self.gesture_name 	= 'Gesture'
	self.touchable_area	= {0, 0, 0, 0}
	self:setup_touchlayer()
	self.mid_x = VisibleSize.width / 2
	self.mid_y = VisibleSize.height / 2
	self:set_is_gray(false)
end

function guide_ui_info: setup_touchlayer()
	self.touchlayer = cc.Layer:create()
	
	local listener = cc.EventListenerTouchOneByOne:create()
	listener: setSwallowTouches(true)
	listener: registerScriptHandler( function(touch, event)
		return self:touch_begin_event(touch, event)
	end,cc.Handler.EVENT_TOUCH_BEGAN)

	listener: registerScriptHandler( function(touch, event)
		return self:touch_move_event(touch, event)
	end,cc.Handler.EVENT_TOUCH_MOVED)

	listener: registerScriptHandler( function(touch, event)
		return self:touch_end_event(touch, event)
	end,cc.Handler.EVENT_TOUCH_ENDED)

	self.touchlayer: getEventDispatcher(): addEventListenerWithSceneGraphPriority( listener, self.touchlayer )
	self.cc: addChild(self.touchlayer)
end

function guide_ui_info: set_touchable_area( x1, y1, x2, y2, c_ori )
	local x, y = self:get_ori_pos(c_ori)
	self.layer_touchable = false
	x1 = x1 or 0
	y1 = y1 or 0
	x2 = x2 or 0
	y2 = y2 or 0
	if x1 > x2 then
		self.touchable_area[3] = x + x1
		self.touchable_area[1] = x + x2
	else
		self.touchable_area[1] = x + x1
		self.touchable_area[3] = x + x2
	end
	if y1 > y2 then
		self.touchable_area[4] = y + y1
		self.touchable_area[2] = y + y2
	else
		self.touchable_area[2] = y + y1
		self.touchable_area[4] = y + y2
	end

end

function guide_ui_info: set_layer_touchable( t_able )
	self.layer_touchable = t_able
end

function guide_ui_info: touch_begin_event( touch, event )
	--print('begin')
	local loc = touch:getLocation()
	local ui_guide = import('world.ui_guide')
	if ui_guide.touch_type_check(2) == true then
		ui_guide.touch_ended()
		return true
	end

	if self.layer_touchable == true then
		return false
	elseif loc.x > self.touchable_area[1] and loc.y > self.touchable_area[2]
	and loc.x < self.touchable_area[3] and loc.y < self.touchable_area[4] then
		--可点击范围穿透
		if ui_guide.touch_type_check(3) == true then
			ui_guide.touch_ended()
		end
		return false
	else
		return true
	end
end
function guide_ui_info: touch_move_event( touch, event )
	--print('move')
	return false
end
function guide_ui_info: touch_end_event( touch, event )
	return false
end

function guide_ui_info: show_tip( post_fix, json, pos )
	if post_fix == nil then
		return
	end

	if self.tip_ui[json] == nil then
		if json == nil then
			self.tip_ui[json] = ccs.GUIReader: getInstance(): widgetFromJsonFile( self.tip_json )
		else
			self.tip_ui[json] = ccs.GUIReader: getInstance(): widgetFromJsonFile( json )
		end
		self.cc: addChild( self.tip_ui[json] )
	end
	local tip_label = ccui.Helper: seekWidgetByName(self.tip_ui[json], 'Label_1')
	local tips_key = 'guide_' .. post_fix
	tip_label: setString(locale.get_value(tips_key))

	if pos ~= nil then
		self.tip_ui[json]: setPosition( VisibleSize.width + pos[1], VisibleSize.height + pos[2] )
	else
		self.tip_ui[json]: setPosition( VisibleSize.width, VisibleSize.height )
	end
	self.tip_ui[json]: setVisible(true)
	self.cur_json = json
end

function guide_ui_info: hide_tip()
	if self.tip_ui[self.cur_json] ~= nil then
		self.tip_ui[self.cur_json]: setVisible(false)
	end
end

function guide_ui_info: show_gesture( g_name, g_pos, g_ori )
	if self.gesture_armature == nil then
		ccs.ArmatureDataManager: getInstance(): addArmatureFileInfo( self.gesture_json )
		self.gesture_armature = ccs.Armature: create( self.gesture_name )
		self.cc: addChild( self.gesture_armature )
		self.gesture_mov = {}

		local json_obj = cjson.decode(cc.FileUtils:getInstance(): getStringFromFile( self.gesture_json ))
		for k, v in pairs(json_obj.animation_data[1].mov_data) do
			self.gesture_mov[v.name] = v.dr
		end
	end
	g_pos = g_pos or {0, 0}
	local x, y = self:get_ori_pos(g_ori)
	self.gesture_armature: setPosition( x + g_pos[1], y + g_pos[2] )
	self.gesture_armature: setVisible( true )
	self.gesture_armature: getAnimation(): play( g_name, self.gesture_mov[g_name], -1 )
end

function guide_ui_info: get_ori_pos( ori_conf )
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

function guide_ui_info: hide_gesture( )
	if self.gesture_armature ~= nil then
		self.gesture_armature: setVisible( false )
	end
end

function guide_ui_info: reset_guide()
	self:hide_gesture()
	self:hide_tip()
	self:set_layer_touchable(true)
end

function guide_ui_info: release()
	self.is_remove = false
	for k, v in pairs(self.tip_ui) do
		v:removeFromParent()
		self.tip_ui[k] = nil
	end
	ccs.GUIReader: destroyInstance()
	ccs.ArmatureDataManager: getInstance(): removeArmatureFileInfo( self.gesture_json )
	super( guide_ui_info, self ).release()
end

