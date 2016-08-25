local layer 				= import('world.layer')
local ui_const 				= import( 'ui.ui_const' )

box_reward_layer = lua_class('awardbox_reward_layer_info',layer.ui_layer)
local load_texture_type = TextureTypePLIST
local first = true
local renwu_set = 'icon/renwu.plist'
local iicon_set = 'icon/item_icons.plist'
local eicon_set = 'icon/e_icons.plist'
local soul_set = 'icon/soul_icons.plist'

function box_reward_layer:_init(  )
	super(box_reward_layer,self)._init('gui/main/boxc_1.ExportJson',true)

	self.is_remove = false
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2,VisibleSize.height/2)

	self:play_up_anim()
	self.list = self:get_widget('list_item')
	self.btn_ok = self:get_widget('btn_ok')

end

--弹出动画
function box_reward_layer:play_up_anim(  )

	self:play_action('boxc_1.ExportJson','Animation0')
	self:play_action('boxc_1.ExportJson','Animation1')


end

--收回动画
function box_reward_layer:play_down_anim(  )
	local function callFunc(  )
		self.is_remove = true
	end
	local callFuncObj=cc.CallFunc:create(callFunc)
   self:play_action('boxc_1.ExportJson','down',callFuncObj)
	

end

function box_reward_layer:set_yes_button_handel(func)
	local function button_event( sender,eventtype )
		if eventtype == ccui.TouchEventType.began then
		elseif eventtype == ccui.TouchEventType.moved then
		elseif eventtype == ccui.TouchEventType.ended then
			func()

		elseif eventtype == ccui.TouchEventType.canceled then
		end
	end
	self.btn_ok:addTouchEventListener(button_event)
end

--设置

function box_reward_layer:release(  )
	-- body
	self.is_remove = false
	--ccs.ActionManagerEx:getInstance():releaseActionsByJsonName('task_tips.ExportJson')
	super(box_reward_layer,self).release()
end

function box_reward_layer:reload(  )
	super(box_reward_layer,self).reload()
end

function box_reward_layer:set_reward( rwd_data )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( renwu_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( iicon_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( eicon_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( soul_set )
	--pushBackElement
	local index = 1
--	deep_dir(rwd_data)
	for _, item in pairs(rwd_data) do
		if item.i_type ~= nil then
			if item.i_type == 'proxy_money' then
				local pal_item = self:get_widget('pal_proxy_money'):clone()
				local number = pal_item:getChildByName('lbl_p_money_num')
				--img:loadTexture(rwd_data[index].k ..'.png',load_texture_type)
				--img:setVisible(true)
				number:setString('x' .. item.number)
				self.list:pushBackCustomItem(pal_item)
				--number:setVisible(true)
			end
		elseif type(item) == 'table' then
			local pal_item = self:get_widget('pal_item'):clone()
			local item_type = data.item_id[item.id]
			local icon = data[item_type][item.id].icon
			local img = pal_item:getChildByName('img_item')
			local number = pal_item:getChildByName('lbl_item_num')
			img:loadTexture(icon,load_texture_type)
			img:setScale(0.5)
			number:setString('x' .. item.number)
			dir(self.list)
			self.list:pushBackCustomItem(pal_item)
		end
		index = index + 1
	end
end