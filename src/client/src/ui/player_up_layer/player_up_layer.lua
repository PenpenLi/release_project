local layer 				= import('world.layer')
local lbl_format			= import( 'ui.player_up_layer.ui_lbl_format' )
local ui_const 				= import( 'ui.ui_const' )
local locale				= import( 'utils.locale' )
local anim_trigger 			= import( 'ui.main_ui.anim_trigger')
local model 				= import( 'model.interface' )

player_up_layer = lua_class( 'player_up_layer' ,layer.ui_layer)

local _json_name = 'ui_player_up.ExportJson'
local _json_file = 'gui/global/ui_player_up.ExportJson'

function player_up_layer:_init(  )
	super(player_up_layer,self)._init(_json_file,true)
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2,VisibleSize.height/2)
	-- --黑屏
	self:init_lbl_font()
	self.is_remove = false
	self.touch_count = 0
	--self:set_pro_cont( )
	self:set_handler('yes_button',self.yes_button_event)
end


--对文字的描边
function player_up_layer:init_lbl_font(  )
	for name, val in pairs(lbl_format.ui_label) do
		self['lbl_' .. name] = self:get_widget('lbl_' .. name)
		local temp_label = self['lbl_' .. name]
		if temp_label ~= nil then
			--temp_label:setFontName(ui_const.UiLableFontType)
			if locale.get_value('lvup_' .. name) ~= ' ' then
				temp_label:setString(locale.get_value('lvup_' .. name))		--如果传入的name在languane是没有的，就会返回以个空字符串
			end
			if val.edge ~= nil and val.edge > 0 then 					--edge的值大于0就描边
				temp_label:enableOutline(ui_const.UilableStroke, val.edge)  ---，描边，厚度 role_ui_conf.lua中role_ui_label的edge
			end
		end
	end
end

--设置属性数值
function player_up_layer:set_pro_cont( bef_level ,bef_att,bef_hp,bef_def,bef_crit )
	local player  = model.get_player()
	local final_attr = player:get_attr()
	--local bef_level = player.level-1
	local cur_level = player.level
	self.lbl_level:setString(cur_level)
	self.lbl_bef_attack:setString(bef_att)
	self.lbl_cur_attack:setString(final_attr:get_attack())
	self.lbl_bef_hp:setString(bef_hp)
	self.lbl_cur_hp:setString(final_attr:get_max_hp())
	self.lbl_bef_def:setString(bef_def)
	self.lbl_cur_def:setString(final_attr:get_defense())
	self.lbl_bef_crit:setString(bef_crit)
	self.lbl_cur_crit:setString(final_attr:get_crit_level())

end



function player_up_layer:play_start_anim( call_back )

	self.call_back=call_back

	self:play_action(_json_name,'up')
	self:play_action(_json_name,'light')
end

function player_up_layer:play_end_anim(  )
	local function callFunc(  )
		self.is_remove = true
		--anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_UP_ANIM,false)
	end
	local callFuncObj=cc.CallFunc:create(callFunc)
	self:play_action(_json_name,'down',callFuncObj)

end


function player_up_layer:yes_button_event( sender ,eventType )
	if eventType == ccui.TouchEventType.began then

	elseif eventType == ccui.TouchEventType.moved then

	elseif eventType == ccui.TouchEventType.ended then
			sender:setTouchEnabled(false)
			self:play_end_anim()
			self.call_back()
	elseif eventType == ccui.TouchEventType.canceled then
		
	end
end


function player_up_layer:touch_begin_event( touch, event )
	-- body
	if self.touch_count > 0 then
		return
	end
	self.touch_count = self.touch_count + 1
	self:play_end_anim()
	self.call_back()

end

function player_up_layer:reload(  )
	super(player_up_layer,self).reload()
end



--释放
function player_up_layer:release(  )
	print('remove player_up_layer plist')
	self.is_remove = false
	super(player_up_layer,self).release()
	--ccs.ActionManagerEx:getInstance():releaseActionsByJsonName(_json_name)
end
