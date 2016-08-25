local layer					= import( 'world.layer' )
local ui_const 				= import( 'ui.ui_const' )
local anim_trigger 			= import( 'ui.main_ui.anim_trigger')
local strengthen_list 		= import( 'ui.strengthen_layer.strengthen_list' )
local strengthen_info		= import( 'ui.strengthen_layer.strengthen_info' )
local strengthen_tx			= import( 'ui.strengthen_layer.strengthen_tx' )
local ui_mgr				= import( 'ui.ui_mgr' )
local model                 = import( 'model.interface')
local msg_queue        	    = import(  'ui.msg_ui.msg_queue')

strengthen_layer = lua_class( 'strengthen_layer',layer.ui_layer )
local load_texture_type = TextureTypePLIST
local eicon_set = 'icon/e_icons.plist'
local _json_path = 'gui/main/ui_strengthen.ExportJson'

function strengthen_layer:_init(  )
	--cc.SpriteFrameCache:getInstance():addSpriteFrames( eicon_set )
	super(strengthen_layer,self)._init(_json_path,true)

	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2,VisibleSize.height/2)


	--关闭按钮
	self:set_handler("close_button", self.close_button_event)
	--播放动画
	self:play_action('ui_strengthen.ExportJson','updown')
	self:init_panels()
	self:reload()
end

function strengthen_layer:set_selecet_id( idx )
	self.selecet_id = idx
	self.strengthen_list:set_select_id(idx)
end


function strengthen_layer:init_panels(  )
	self.strengthen_info = strengthen_info.strengthen_info(self)
	self.strengthen_list = strengthen_list.strengthen_list(self)

end


function strengthen_layer:close_button_event( sender, eventtype )

	if eventtype == ccui.TouchEventType.began then
	
	elseif eventtype == ccui.TouchEventType.moved then
  
	elseif eventtype == ccui.TouchEventType.ended then

			 self.cc:setVisible(false)
			 if self.selecet_id == nil then
			 	anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_UP_ANIM,false)
			 end
			 self.is_remove = true
	elseif eventtype == ccui.TouchEventType.canceled then
			
	end
end

function strengthen_layer:get_list_panel( )
	return self.strengthen_list
end

function strengthen_layer:get_info_panel( )
	return self.strengthen_info
end

function strengthen_layer:play_tx(  )
	local ly = self:get_widget('Panel_1')
	local tx = strengthen_tx.strengthen_tx()
	self.cc:addChild(tx.cc)
	local pos2 = ly:getWorldPosition()
	local btn = self:get_widget('strengthen_button')
	local pos1 = btn:getWorldPosition()
	local equip_view = self:get_widget('equip_view')
	local pos3 = equip_view:getWorldPosition()
	tx:play_anim2(pos1.x,pos1.y,pos2.x,pos2.y,pos3.x,pos3.y)
	tx.cc:setLocalZOrder(1000000)
end

function strengthen_layer:reload_ui(  )
	self.strengthen_info = strengthen_info.strengthen_info(self)
	
	self.strengthen_list:update_list()
end

function strengthen_layer:set_fc( )
	self.fc = math.floor(model.get_player().final_attrs:get_fighting_capacity() + 0.5)
end



function strengthen_layer:reload(  )
	super(strengthen_layer,self).reload()
	self:reload_ui()
	if self.fc == nil then
		return
	end
	local new_fc = math.floor(model.get_player().final_attrs:get_fighting_capacity() + 0.5)
	if new_fc ~= self.fc then
		msg_queue.add_battle_msg(new_fc - self.fc)
	end
	self.fc = new_fc
end


function strengthen_layer:release(  )
	print('remove strengthen_layer')
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( eicon_set )
	--ccs.ActionManagerEx:getInstance():releaseActionsByJsonName('ui_strengthen.ExportJson')
	super(strengthen_layer,self).release()
end