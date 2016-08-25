local layer 		= import('world.layer')
local locale		= import('utils.locale')
local complete_layer	=  import('ui.fuben_detail.complete_layer')
local anim_trigger 			= import( 'ui.main_ui.anim_trigger')
local item_layer		= import('ui.fuben_detail.item_layer')
local ex_reward_layer		= import('ui.fuben_detail.ex_reward_layer')
local reward_layer		= import('ui.fuben_detail.reward_layer')
local ui_mgr 			= import( 'ui.ui_mgr' )

sweep_layer			= lua_class('sweep_layer',layer.ui_layer)
local eicon_set			= 'icon/e_icons.plist'
local iicon_set 		= 'icon/item_icons.plist'
local soul_set  		= 'icon/soul_icons.plist'
local _json_path 	= 'gui/main/fuben_detail_3.ExportJson'
local load_texture_type 	= TextureTypePLIST

function sweep_layer:_init( )
	super(sweep_layer,self)._init(_json_path,true)
	self.list 	= self:get_widget('list')
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width / 2, VisibleSize.height / 2)
	self.is_remove = false
	self.f_time = 20
	self.s_time = 0.1
	self.can_remove = false
end

function sweep_layer:create_cell( battle_id, reward_table, ex_reward )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( eicon_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( iicon_set )
	cc.SpriteFrameCache:getInstance():addSpriteFrames( soul_set )
	self.reward_table = reward_table
	self.ex_reward = ex_reward
	self.battle_id = battle_id
	self.tick_time = 0
	self.create_time = 0
	self.r_t_time = 0
	self.create_r_time = 0
	self.create_reward_flag = false
	self.t_i = 1
	self.r_i = 1
	self.need_release = {}
	self:create_part()

end

function sweep_layer:play_up_anim( battle_id, reward_table, ex_reward )
	local function callFunc(  )
		self:create_cell( battle_id, reward_table, ex_reward )
	end
	local callFuncObj=cc.CallFunc:create(callFunc)
	self:play_action('fuben_detail_3.ExportJson','up',callFuncObj)
end

function sweep_layer:play_down_anim()
	local function callFunc(  )
		self.is_remove = true
	end
	local callFuncObj=cc.CallFunc:create(callFunc)
	self:play_action('fuben_detail_3.ExportJson','down',callFuncObj)
end

function sweep_layer:create_part()
	local key = 0
	local battle 	= data.fuben[self.battle_id]
	local lbl_battle
	local lbl_money 
	local lbl_exp	
	local reward_img
	self.reward = self.reward_table[self.t_i]

	if self.reward == nil then 
		self:create_complete()
		return 
	end

	self.tick_time = 0
	if #self.reward == 0 then
		self.create_time = self.f_time
	else
		self.create_time = self.f_time * #self.reward
	end
	local reward_l = reward_layer.reward_layer()
	table.insert(self.need_release,reward_l)
	self.list_cell = reward_l:get_widget()
	local list_cell = self.list_cell
	local list = self.list
	if #self.reward >= 1 then
		reward_l:set_lbl_visible( false )
	end
	local function callFunc(  )
		reward_l:release_action('fuben_detail_4.ExportJson')
		self:create_reward_item()
	end
	
	local function jump()
		list:jumpToBottom()
		local callFuncObj=cc.CallFunc:create(callFunc)
		list_cell:setVisible(true)
		reward_l:play_action('fuben_detail_4.ExportJson','Animation0',callFuncObj)
	end
	list_cell:setVisible(false)
	local seq = cc.Sequence:create(list:pushBackCustomItem( list_cell ),cc.CallFunc:create(jump))
	self.cc:runAction(seq)

	
	local sweep_key = 'sweep_battle_' .. self.t_i
	reward_l:set_battle(sweep_key)
	reward_l:set_gold(battle.gold)
	reward_l:set_exp(battle.exp)
	local img_name
	self.r_i = 1
	self.create_reward_flag = true
	self.t_i = self.t_i + 1

end

function sweep_layer:create_complete()
	local list = self.list
	local complete = complete_layer.complete_layer()
	table.insert(self.need_release,complete)
	local p_complete = complete:get_complete()
	list:pushBackCustomItem(p_complete)
	local function play_xz()
		complete:play_action('fuben_detail_2.ExportJson','xz')
		self:create_exreward( )
	end
	local function jump()
		list:jumpToBottom()
		complete:play_action('fuben_detail_2.ExportJson','up2',cc.CallFunc:create(play_xz))
	end
	local seq = cc.Sequence:create(list:pushBackCustomItem( complete ),cc.CallFunc:create(jump))
	self.cc:runAction(seq)
	self.tick_time = 1
	self.create_time = self.f_time
	self.create_ex_reward = true
end


function  sweep_layer:create_exreward( )
	local list = self.list
	local reward_l = ex_reward_layer.ex_reward_layer()
	table.insert(self.need_release,reward_l)
	self.list_cell = reward_l:get_widget()
	self.ex_item_list = self.list_cell:getChildByName('item_list')
	local list_cell = self.list_cell
	local list = self.list
	if #self.ex_reward >= 1 then
		reward_l:set_lbl_visible( false )
	end
	local function create_call_back()
		reward_l:release_action('fuben_detail_5.ExportJson')
		self:create_ex_reward_item()
	end
	local function jump()
		list:jumpToBottom()
		reward_l:play_action('fuben_detail_5.ExportJson','down',cc.CallFunc:create(create_call_back))
	end
	local seq = cc.Sequence:create(list:pushBackCustomItem( list_cell ),cc.CallFunc:create(jump))
	self.cc:runAction(seq)

	self.r_t_time = 1
	self.create_r_time = 10
	self.r_i = 1
	self.create_reward_flag = true
end

function sweep_layer:create_ex_reward_item( )
	if self.ex_reward == nil then
		self.create_reward_flag = false
		self.can_remove = true
		return 
	end
	local drop = self.ex_reward[self.r_i]
	local ex_reward_list = ccui.Helper:seekWidgetByName(self.list_cell, 'item_list')
	self.r_t_time = 0
	self.create_r_time = self.f_time
	if drop == nil then
		self.can_remove = true
		return
	end

	local ex_reward_item = item_layer.item_layer()
	table.insert(self.need_release,ex_reward_item)
	local reward_widget = ex_reward_item:get_item_widget()
	local item_type = data.item_id[drop[1]]
	local item 		= data[item_type][drop[1]]
	local item_btn	= ex_reward_item:get_btn()
	if item.color ~= nil then 
		ex_reward_item:set_img_frame( item.color )
	end
	ex_reward_item:set_num(drop[2])
	self.r_i = self.r_i + 1
	ex_reward_item:set_img(item.icon,load_texture_type)
	ex_reward_list:pushBackCustomItem(reward_widget)
	self:set_item_touch_handler(item_btn,drop[1])
	local function create_ex()
		ex_reward_item:release_action('fuben_detail_6.ExportJson')
		self:create_ex_reward_item()
	end
	ex_reward_item:play_action('fuben_detail_6.ExportJson','Animation0',cc.CallFunc:create(create_ex))
end

function sweep_layer:create_reward_item( )
	if self.reward == nil then
		self:create_part()
		return 
	end

	local drop = self.reward[self.r_i]
	self.r_t_time = 0
	self.create_r_time = self.f_time
	if drop == nil then
		self.create_reward_flag = false
		self:create_part()
		return
	end
	local reward_list = ccui.Helper:seekWidgetByName(self.list_cell, 'item_list')
	local reward_item = item_layer.item_layer()
	table.insert(self.need_release,reward_item)
	local reward_widget = reward_item:get_item_widget()
	local item_type = data.item_id[drop[1]]
	local item 		= data[item_type][drop[1]]
	local item_btn	= reward_item:get_btn()
	reward_item:set_num(drop[2])
	self.r_i = self.r_i + 1
	reward_item:set_img(item.icon,load_texture_type)
	reward_list:pushBackCustomItem(reward_widget)
	self:set_item_touch_handler(item_btn,drop[1])
	if item.color ~= nil then 
		reward_item:set_img_frame( item.color )
	end
	local function create_call_back()
		reward_item:release_action('fuben_detail_6.ExportJson')
		self:create_reward_item()
	end
	reward_item:play_action('fuben_detail_6.ExportJson','Animation0',cc.CallFunc:create(create_call_back))
end


function sweep_layer:set_item_touch_handler(btn,item_id)
	local function button_event(sender,eventType)
		if eventType == ccui.TouchEventType.began then

		elseif eventType == ccui.TouchEventType.moved then

		elseif eventType == ccui.TouchEventType.ended then
			if item_id ~= nil then
				local temp_ui = ui_mgr.create_ui(import('ui.tips_layer.item_tips_layer'),'item_tips_layer')
				temp_ui:set_content(item_id)
				temp_ui:set_center_position(VisibleSize.width/2,VisibleSize.height/2)
				temp_ui:play_up_anim()
			end
		end
	end
	btn:addTouchEventListener(button_event)
end

function sweep_layer:touch_end_event()
	if self.can_remove then
		self:play_down_anim()
	end
end

function sweep_layer:release()
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( eicon_set )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( iicon_set )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( soul_set )
	super(sweep_layer,self).release()
	for i,v in pairs(self.need_release) do 
		v:release()
	end
	self.is_remove 		= false
end