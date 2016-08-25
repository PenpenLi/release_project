local layer 				= import('world.layer')
local ui_const 				= import( 'ui.ui_const' )

task_reward = lua_class('task_reward',layer.ui_layer)
local load_texture_type = TextureTypePLIST
local first = true
local renwu_set = 'icon/renwu.plist'
local iicon_set = 'icon/item_icons.plist'
local eicon_set = 'icon/e_icons.plist'
local soul_set = 'icon/soul_icons.plist'

function task_reward:_init(  )
	super(task_reward,self)._init('gui/main/task_tips.ExportJson',true)

	self.is_remove = false
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2,VisibleSize.height/2)


	--文本字体
	self.lbl_reward_img_1 = self:get_widget('lbl_reward_img_1')
	--self.lbl_reward_img_1:setFontName(ui_const.UiLableFontType)
	self.lbl_reward_img_1:enableOutline(ui_const.UilableStroke, 1)
	self.lbl_reward_img_2 = self:get_widget('lbl_reward_img_2')
	--self.lbl_reward_img_2:setFontName(ui_const.UiLableFontType)
	self.lbl_reward_img_2:enableOutline(ui_const.UilableStroke, 1)
	self.lbl_reward_img_3 = self:get_widget('lbl_reward_img_3')
	--self.lbl_reward_img_3:setFontName(ui_const.UiLableFontType)
	self.lbl_reward_img_3:enableOutline(ui_const.UilableStroke, 1)
	self.lbl_yes_button = self:get_widget('lbl_yes_button')
	--self.lbl_yes_button:setFontName(ui_const.UiLableFontType)
	self.lbl_yes_button:enableOutline(ui_const.UilableStroke, 1)


	self.reward_img_1 = self:get_widget('reward_img_1')
	self.reward_img_2 = self:get_widget('reward_img_2')
	self.reward_img_3 = self:get_widget('reward_img_3')
	self.reward_img_1:setVisible(false)
	self.lbl_reward_img_1:setVisible(false)
	self.reward_img_2:setVisible(false)
	self.lbl_reward_img_2:setVisible(false)
	self.reward_img_3:setVisible(false)
	self.lbl_reward_img_3:setVisible(false)
	self.lbl_title = self:get_widget('lbl_title')
	--self.lbl_title:setFontName(ui_const.UiLableFontType)

	self.yes_button = self:get_widget('yes_button')
	self:set_handler('yes_button',self.yes_button_event)

	self:play_up_anim()

end

function task_reward:yes_button_event( sender, eventType )
	if eventType == ccui.TouchEventType.began then
		
	elseif eventType == ccui.TouchEventType.moved then
	  
	elseif eventType == ccui.TouchEventType.ended then
		sender:setTouchEnabled(false)
		sender:setBright(true)
		self:play_down_anim( )
	elseif eventType == ccui.TouchEventType.canceled then
			
	end
end


--弹出动画
function task_reward:play_up_anim(  )

	self:play_action('task_tips.ExportJson','up')
	self:play_action('task_tips.ExportJson','anim')


end

--收回动画
function task_reward:play_down_anim(  )
	local function callFunc(  )
		local task_layer = import('ui.ui_mgr').get_ui('task_layer')
		if task_layer ~= nil then
			task_layer:reload()
		end
		self.is_remove = true
		
	end
	local callFuncObj=cc.CallFunc:create(callFunc)
   self:play_action('task_tips.ExportJson','down',callFuncObj)
	

end


--设置

function task_reward:release(  )
	-- body
	self.is_remove = false
	--ccs.ActionManagerEx:getInstance():releaseActionsByJsonName('task_tips.ExportJson')
	super(task_reward,self).release()
end

function task_reward:reload(  )
	super(task_reward,self).reload()
end



function task_reward:set_reward( rwd_data )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( renwu_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( iicon_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( eicon_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( soul_set )
	local count = #rwd_data

	for i=1,count do
		if rwd_data[i].k == 'items' then
			local item_type = data.item_id[rwd_data[i].v]
			local icon = data[item_type][rwd_data[i].v].icon
			local img = self['reward_img_' .. i]
			local number = self['lbl_reward_img_'..i]
			img:loadTexture(icon,load_texture_type)
			img:setVisible(true)
			img:setScale(0.35)
			number:setString('x' .. rwd_data[i].num)
			number:setVisible(true)
		else
			local img = self['reward_img_' .. i]
			local number = self['lbl_reward_img_'..i]
			img:loadTexture(rwd_data[i].k ..'.png',load_texture_type)
			img:setVisible(true)

			number:setString('x' .. rwd_data[i].v)
			number:setVisible(true)

		end

	end
end